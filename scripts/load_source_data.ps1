[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ConnectionString,

    [string]$DataDir = "data/source",

    [string]$PsqlPath = "psql",

    [string]$SchemaFile = "sql/01_create_source_schema.sql",

    [string]$ValidationFile = "sql/02_validate_source_data.sql",

    [string]$ExpectedCountsFile,

    [switch]$SkipSchema
)

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptRoot "..")
$tempFiles = New-Object System.Collections.Generic.List[string]

$tableSpecs = @(
    @{
        Name = "categories"
        Columns = @("category_id", "product_category_name")
        Aliases = @("product_categories")
    },
    @{
        Name = "customers"
        Columns = @(
            "customer_id",
            "customer_unique_id",
            "customer_zip_code_prefix",
            "customer_city",
            "customer_state"
        )
        Aliases = @()
    },
    @{
        Name = "sellers"
        Columns = @(
            "seller_id",
            "seller_zip_code_prefix",
            "seller_city",
            "seller_state"
        )
        Aliases = @()
    },
    @{
        Name = "products"
        Columns = @(
            "product_id",
            "category_id",
            "product_name_length",
            "product_description_length",
            "product_photos_qty",
            "product_weight_g",
            "product_length_cm",
            "product_height_cm",
            "product_width_cm"
        )
        Aliases = @()
    },
    @{
        Name = "orders"
        Columns = @(
            "order_id",
            "customer_id",
            "order_status",
            "order_purchase_timestamp",
            "order_approved_at",
            "order_delivered_carrier_date",
            "order_delivered_customer_date",
            "order_estimated_delivery_date"
        )
        Aliases = @()
    },
    @{
        Name = "addresses"
        Columns = @(
            "address_id",
            "customer_id",
            "zip_code",
            "city",
            "state"
        )
        Aliases = @()
    },
    @{
        Name = "payments"
        Columns = @(
            "payment_id",
            "order_id",
            "payment_sequential",
            "payment_type",
            "payment_installments",
            "payment_value"
        )
        Aliases = @()
    },
    @{
        Name = "reviews"
        Columns = @(
            "review_id",
            "order_id",
            "review_score",
            "review_creation_date",
            "review_answer_timestamp"
        )
        Aliases = @()
    },
    @{
        Name = "shipments"
        Columns = @(
            "shipment_id",
            "order_id",
            "shipment_status",
            "shipped_at",
            "delivered_at"
        )
        Aliases = @()
    },
    @{
        Name = "order_items"
        Columns = @(
            "order_item_id",
            "order_id",
            "product_id",
            "seller_id",
            "shipping_limit_date",
            "price",
            "freight_value"
        )
        Aliases = @("order-items")
    }
)

function Resolve-RepoPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return (Resolve-Path $PathValue).Path
    }

    return (Resolve-Path (Join-Path $repoRoot $PathValue)).Path
}

function Normalize-FilePathForPsql {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    return $PathValue.Replace("\", "/").Replace("'", "''")
}

function Resolve-DataFile {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$TableSpec,
        [Parameter(Mandatory = $true)]
        [string]$RootDir
    )

    $baseNames = @($TableSpec.Name) + $TableSpec.Aliases
    $extensions = @(".csv", ".json", ".jsonl", ".ndjson")

    foreach ($baseName in $baseNames) {
        foreach ($extension in $extensions) {
            $candidate = Join-Path $RootDir ($baseName + $extension)
            if (Test-Path -LiteralPath $candidate) {
                return (Resolve-Path $candidate).Path
            }
        }
    }

    throw "Arquivo nao encontrado para a tabela '$($TableSpec.Name)' em '$RootDir'."
}

function Convert-JsonFileToCsv {
    param(
        [Parameter(Mandatory = $true)]
        [string]$InputPath,
        [Parameter(Mandatory = $true)]
        [string[]]$Columns
    )

    $outputPath = Join-Path ([System.IO.Path]::GetTempPath()) (
        "{0}_{1}.csv" -f
        [System.IO.Path]::GetFileNameWithoutExtension($InputPath),
        [System.Guid]::NewGuid().ToString("N")
    )

    $extension = [System.IO.Path]::GetExtension($InputPath).ToLowerInvariant()

    if ($extension -in @(".jsonl", ".ndjson")) {
        Get-Content -LiteralPath $InputPath |
            Where-Object { $_.Trim().Length -gt 0 } |
            ForEach-Object { $_ | ConvertFrom-Json } |
            Select-Object -Property $Columns |
            Export-Csv -LiteralPath $outputPath -NoTypeInformation -Encoding UTF8
    }
    else {
        $jsonText = Get-Content -LiteralPath $InputPath -Raw
        $records = $jsonText | ConvertFrom-Json

        if ($records -isnot [System.Collections.IEnumerable] -or $records -is [string]) {
            $records = @($records)
        }

        $records |
            Select-Object -Property $Columns |
            Export-Csv -LiteralPath $outputPath -NoTypeInformation -Encoding UTF8
    }

    $tempFiles.Add($outputPath) | Out-Null
    return $outputPath
}

function Invoke-Psql {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    & $PsqlPath @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "psql retornou codigo $LASTEXITCODE."
    }
}

function Get-TableCount {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TableName
    )

    $result = & $PsqlPath `
        $ConnectionString `
        -X `
        -qAt `
        -v ON_ERROR_STOP=1 `
        -c "select count(*) from source.$TableName;"

    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao consultar a contagem da tabela '$TableName'."
    }

    return [int64]($result.Trim())
}

try {
    $null = Get-Command $PsqlPath -ErrorAction Stop

    $resolvedDataDir = Resolve-RepoPath -PathValue $DataDir
    $resolvedSchemaFile = Resolve-RepoPath -PathValue $SchemaFile
    $resolvedValidationFile = Resolve-RepoPath -PathValue $ValidationFile

    if (-not $SkipSchema) {
        Write-Host "Aplicando DDL em $resolvedSchemaFile..."
        Invoke-Psql -Arguments @(
            $ConnectionString,
            "-X",
            "-v", "ON_ERROR_STOP=1",
            "-f", $resolvedSchemaFile
        )
    }

    $truncateOrder = @(
        "source.order_items",
        "source.shipments",
        "source.reviews",
        "source.payments",
        "source.addresses",
        "source.orders",
        "source.products",
        "source.sellers",
        "source.customers",
        "source.categories"
    )

    $copyStatements = New-Object System.Collections.Generic.List[string]
    $copyStatements.Add("\set ON_ERROR_STOP on") | Out-Null
    $copyStatements.Add("begin;") | Out-Null
    $copyStatements.Add(("truncate table {0};" -f ($truncateOrder -join ", "))) | Out-Null

    foreach ($tableSpec in $tableSpecs) {
        $sourceFile = Resolve-DataFile -TableSpec $tableSpec -RootDir $resolvedDataDir
        $extension = [System.IO.Path]::GetExtension($sourceFile).ToLowerInvariant()

        if ($extension -in @(".json", ".jsonl", ".ndjson")) {
            Write-Host "Convertendo $sourceFile para CSV temporario..."
            $sourceFile = Convert-JsonFileToCsv -InputPath $sourceFile -Columns $tableSpec.Columns
        }

        $normalizedPath = Normalize-FilePathForPsql -PathValue $sourceFile
        $columnList = ($tableSpec.Columns -join ", ")

        $copyStatements.Add(
            ("\copy source.{0} ({1}) from '{2}' with (format csv, header true, null '', encoding 'UTF8');" -f
                $tableSpec.Name,
                $columnList,
                $normalizedPath)
        ) | Out-Null
    }

    $copyStatements.Add("commit;") | Out-Null

    $copyScriptPath = Join-Path ([System.IO.Path]::GetTempPath()) (
        "load_source_{0}.sql" -f [System.Guid]::NewGuid().ToString("N")
    )
    [System.IO.File]::WriteAllText(
        $copyScriptPath,
        ($copyStatements -join [Environment]::NewLine),
        (New-Object System.Text.UTF8Encoding($false))
    )
    $tempFiles.Add($copyScriptPath) | Out-Null

    Write-Host "Carregando arquivos da pasta $resolvedDataDir..."
    Invoke-Psql -Arguments @(
        $ConnectionString,
        "-X",
        "-v", "ON_ERROR_STOP=1",
        "-f", $copyScriptPath
    )

    Write-Host "Executando validacoes SQL..."
    Invoke-Psql -Arguments @(
        $ConnectionString,
        "-X",
        "-v", "ON_ERROR_STOP=1",
        "-f", $resolvedValidationFile
    )

    if ($ExpectedCountsFile) {
        $resolvedExpectedCountsFile = Resolve-RepoPath -PathValue $ExpectedCountsFile
        $expectedCounts = Get-Content -LiteralPath $resolvedExpectedCountsFile -Raw |
            ConvertFrom-Json
        $mismatches = New-Object System.Collections.Generic.List[string]

        foreach ($tableSpec in $tableSpecs) {
            $tableName = $tableSpec.Name
            $expectedValue = $expectedCounts.$tableName

            if ($null -eq $expectedValue) {
                continue
            }

            $actualValue = Get-TableCount -TableName $tableName

            if ([int64]$expectedValue -ne $actualValue) {
                $mismatches.Add(
                    ("Tabela '{0}': esperado={1}, encontrado={2}" -f
                        $tableName,
                        $expectedValue,
                        $actualValue)
                ) | Out-Null
            }
        }

        if ($mismatches.Count -gt 0) {
            throw ("Validacao de contagens falhou:`n{0}" -f
                ($mismatches -join [Environment]::NewLine))
        }

        Write-Host "Contagens esperadas validadas com sucesso."
    }

    Write-Host "Carga finalizada com sucesso."
}
finally {
    foreach ($tempFile in $tempFiles) {
        if (Test-Path -LiteralPath $tempFile) {
            Remove-Item -LiteralPath $tempFile -Force
        }
    }
}
