[CmdletBinding()]
param(
    [string]$RawDir = "data/raw/olist",
    [string]$OutputDir = "data/source",
    [int]$TargetOrders = 15000,
    [int]$MinimumTotalRows = 100000,
    [int]$MinOrdersPerMonth = 1,
    [int]$MinOrdersPerStatus = 5
)

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptRoot "..")

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

function Select-EvenlySpacedRecords {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Records,
        [Parameter(Mandatory = $true)]
        [int]$Count
    )

    if ($Count -le 0 -or $Records.Count -eq 0) {
        return @()
    }

    if ($Count -ge $Records.Count) {
        return @($Records)
    }

    $selected = New-Object System.Collections.Generic.List[object]
    $lastIndex = -1

    for ($i = 0; $i -lt $Count; $i++) {
        $rawIndex = [math]::Floor((($i + 0.5) * $Records.Count) / $Count)
        $index = [math]::Min($Records.Count - 1, [int]$rawIndex)

        if ($index -le $lastIndex) {
            $index = $lastIndex + 1
        }

        if ($index -ge $Records.Count) {
            $index = $Records.Count - 1
        }

        $selected.Add($Records[$index]) | Out-Null
        $lastIndex = $index
    }

    return $selected.ToArray()
}

function Get-ProportionalAllocation {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Groups,
        [Parameter(Mandatory = $true)]
        [int]$Target,
        [int]$MinPerGroup = 0
    )

    $allocation = @{}

    foreach ($group in $Groups) {
        $allocation[$group.Name] = 0
    }

    if ($Target -le 0 -or $Groups.Count -eq 0) {
        return $allocation
    }

    $eligibleGroups = @($Groups | Where-Object { $_.Count -gt 0 })

    if ($eligibleGroups.Count -eq 0) {
        return $allocation
    }

    if ($Target -lt $eligibleGroups.Count) {
        $MinPerGroup = 0
    }

    $remainingTarget = $Target

    if ($MinPerGroup -gt 0) {
        foreach ($group in $eligibleGroups) {
            $baseAllocation = [math]::Min($MinPerGroup, $group.Count)
            $allocation[$group.Name] = $baseAllocation
            $remainingTarget -= $baseAllocation
        }
    }

    if ($remainingTarget -le 0) {
        return $allocation
    }

    $totalRemainingCapacity = 0
    foreach ($group in $eligibleGroups) {
        $totalRemainingCapacity += ($group.Count - $allocation[$group.Name])
    }

    if ($remainingTarget -ge $totalRemainingCapacity) {
        foreach ($group in $eligibleGroups) {
            $allocation[$group.Name] = $group.Count
        }

        return $allocation
    }

    $fractionRows = New-Object System.Collections.Generic.List[object]

    foreach ($group in $eligibleGroups) {
        $capacity = $group.Count - $allocation[$group.Name]

        if ($capacity -le 0) {
            continue
        }

        $rawShare = ($remainingTarget * $capacity) / $totalRemainingCapacity
        $extraAllocation = [int][math]::Floor($rawShare)
        $allocation[$group.Name] += $extraAllocation

        $fractionRows.Add([pscustomobject]@{
            Name = $group.Name
            Fraction = $rawShare - $extraAllocation
            RemainingCapacity = $capacity - $extraAllocation
            OriginalCount = $group.Count
        }) | Out-Null
    }

    $allocatedTotal = 0
    foreach ($group in $eligibleGroups) {
        $allocatedTotal += $allocation[$group.Name]
    }

    $leftover = $Target - $allocatedTotal

    while ($leftover -gt 0) {
        $nextGroups = @(
            $fractionRows |
                Where-Object { $_.RemainingCapacity -gt 0 } |
                Sort-Object Fraction, OriginalCount, Name -Descending
        )

        if ($nextGroups.Count -eq 0) {
            break
        }

        foreach ($group in $nextGroups) {
            if ($leftover -le 0) {
                break
            }

            if ($group.RemainingCapacity -le 0) {
                continue
            }

            $allocation[$group.Name] += 1
            $group.RemainingCapacity -= 1
            $leftover -= 1
        }
    }

    return $allocation
}

function Convert-ToNullableValue {
    param(
        [AllowNull()]
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $null
    }

    return $Value
}

function Get-MonthKey {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Timestamp
    )

    return ([datetime]$Timestamp).ToString("yyyy-MM")
}

function Get-ShipmentStatus {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Order
    )

    if (-not [string]::IsNullOrWhiteSpace($Order.order_delivered_customer_date)) {
        return "delivered"
    }

    if (-not [string]::IsNullOrWhiteSpace($Order.order_delivered_carrier_date)) {
        return "shipped"
    }

    switch ($Order.order_status) {
        "canceled" { return "canceled" }
        "unavailable" { return "unavailable" }
        "approved" { return "processing" }
        "created" { return "pending" }
        "invoiced" { return "processing" }
        "processing" { return "processing" }
        default { return $Order.order_status }
    }
}

function Export-TableCsv {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [object[]]$Rows
    )

    if ($Rows.Count -eq 0) {
        @() | Export-Csv -LiteralPath $PathValue -NoTypeInformation -Encoding UTF8
        return
    }

    $Rows | Export-Csv -LiteralPath $PathValue -NoTypeInformation -Encoding UTF8
}

try {
    $resolvedRawDir = Resolve-RepoPath -PathValue $RawDir

    if ([System.IO.Path]::IsPathRooted($OutputDir)) {
        $resolvedOutputDir = $OutputDir
    }
    else {
        $resolvedOutputDir = Join-Path $repoRoot $OutputDir
    }

    New-Item -ItemType Directory -Force -Path $resolvedOutputDir | Out-Null

    $requiredFiles = @{
        customers = "olist_customers_dataset.csv"
        orders = "olist_orders_dataset.csv"
        order_items = "olist_order_items_dataset.csv"
        order_payments = "olist_order_payments_dataset.csv"
        order_reviews = "olist_order_reviews_dataset.csv"
        products = "olist_products_dataset.csv"
        sellers = "olist_sellers_dataset.csv"
        categories = "product_category_name_translation.csv"
    }

    foreach ($requiredFile in $requiredFiles.GetEnumerator()) {
        $filePath = Join-Path $resolvedRawDir $requiredFile.Value
        if (-not (Test-Path -LiteralPath $filePath)) {
            throw "Arquivo obrigatorio nao encontrado: $filePath"
        }
    }

    Write-Host "Lendo arquivos brutos do Kaggle em $resolvedRawDir..."
    $rawOrders = Import-Csv (Join-Path $resolvedRawDir $requiredFiles.orders)
    $rawOrderItems = Import-Csv (Join-Path $resolvedRawDir $requiredFiles.order_items)
    $rawPayments = Import-Csv (Join-Path $resolvedRawDir $requiredFiles.order_payments)
    $rawReviews = Import-Csv (Join-Path $resolvedRawDir $requiredFiles.order_reviews)
    $rawCustomers = Import-Csv (Join-Path $resolvedRawDir $requiredFiles.customers)
    $rawProducts = Import-Csv (Join-Path $resolvedRawDir $requiredFiles.products)
    $rawSellers = Import-Csv (Join-Path $resolvedRawDir $requiredFiles.sellers)
    $rawCategoryTranslations = Import-Csv (Join-Path $resolvedRawDir $requiredFiles.categories)

    $orderIdsWithItems = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($row in $rawOrderItems) {
        $null = $orderIdsWithItems.Add($row.order_id)
    }

    $orderIdsWithPayments = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($row in $rawPayments) {
        $null = $orderIdsWithPayments.Add($row.order_id)
    }

    $eligibleOrders = @(
        $rawOrders |
            Where-Object {
                $orderIdsWithItems.Contains($_.order_id) -and
                $orderIdsWithPayments.Contains($_.order_id)
            } |
            Sort-Object @{ Expression = { [datetime]$_.order_purchase_timestamp } }, order_id
    )

    if ($eligibleOrders.Count -eq 0) {
        throw "Nenhum pedido elegivel encontrado para gerar a massa reduzida."
    }

    $finalTargetOrders = [math]::Min($TargetOrders, $eligibleOrders.Count)

    Write-Host "Selecionando $finalTargetOrders pedidos com distribuicao temporal..."

    $reservedOrderIds = [System.Collections.Generic.HashSet[string]]::new()
    $selectedOrders = New-Object System.Collections.Generic.List[object]

    $ordersByStatus = @($eligibleOrders | Group-Object order_status | Sort-Object Name)
    foreach ($statusGroup in $ordersByStatus) {
        $reserveCount = [math]::Min($MinOrdersPerStatus, $statusGroup.Count)
        $statusRecords = @(
            $statusGroup.Group |
                Sort-Object @{ Expression = { [datetime]$_.order_purchase_timestamp } }, order_id
        )

        foreach ($order in (Select-EvenlySpacedRecords -Records $statusRecords -Count $reserveCount)) {
            if ($reservedOrderIds.Add($order.order_id)) {
                $selectedOrders.Add($order) | Out-Null
            }
        }
    }

    $remainingTargetOrders = $finalTargetOrders - $selectedOrders.Count

    $remainingOrdersPool = @(
        $eligibleOrders |
            Where-Object { -not $reservedOrderIds.Contains($_.order_id) }
    )

    $ordersByMonth = @(
        $remainingOrdersPool |
            Group-Object { Get-MonthKey -Timestamp $_.order_purchase_timestamp } |
            Sort-Object Name
    )

    $monthlyAllocation = Get-ProportionalAllocation `
        -Groups $ordersByMonth `
        -Target $remainingTargetOrders `
        -MinPerGroup $MinOrdersPerMonth

    foreach ($monthGroup in $ordersByMonth) {
        $monthCount = $monthlyAllocation[$monthGroup.Name]

        if ($monthCount -le 0) {
            continue
        }

        $monthRecords = @(
            $monthGroup.Group |
                Sort-Object @{ Expression = { [datetime]$_.order_purchase_timestamp } }, order_id
        )

        foreach ($order in (Select-EvenlySpacedRecords -Records $monthRecords -Count $monthCount)) {
            $selectedOrders.Add($order) | Out-Null
        }
    }

    if ($selectedOrders.Count -lt $finalTargetOrders) {
        $selectedOrderIdsForTopUp = [System.Collections.Generic.HashSet[string]]::new()
        foreach ($row in $selectedOrders) {
            $null = $selectedOrderIdsForTopUp.Add($row.order_id)
        }

        $missingOrders = $finalTargetOrders - $selectedOrders.Count
        $topUpPool = @(
            $eligibleOrders |
                Where-Object { -not $selectedOrderIdsForTopUp.Contains($_.order_id) }
        )

        foreach ($order in (Select-EvenlySpacedRecords -Records $topUpPool -Count $missingOrders)) {
            $selectedOrders.Add($order) | Out-Null
        }
    }

    $selectedOrdersFinal = @(
        $selectedOrders |
            Sort-Object @{ Expression = { [datetime]$_.order_purchase_timestamp } }, order_id
    )

    $selectedOrderIds = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($row in $selectedOrdersFinal) {
        $null = $selectedOrderIds.Add($row.order_id)
    }

    Write-Host "Derivando entidades relacionadas..."

    $selectedCustomersIds = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($row in $selectedOrdersFinal) {
        $null = $selectedCustomersIds.Add($row.customer_id)
    }

    $selectedOrderItemsRaw = @(
        $rawOrderItems |
            Where-Object { $selectedOrderIds.Contains($_.order_id) } |
            Sort-Object order_id, @{ Expression = { [int]$_.order_item_id } }, product_id, seller_id
    )

    $selectedProductIds = [System.Collections.Generic.HashSet[string]]::new()
    $selectedSellerIds = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($row in $selectedOrderItemsRaw) {
        $null = $selectedProductIds.Add($row.product_id)
        $null = $selectedSellerIds.Add($row.seller_id)
    }

    $selectedCustomersRaw = @(
        $rawCustomers |
            Where-Object { $selectedCustomersIds.Contains($_.customer_id) } |
            Sort-Object customer_id
    )

    $selectedProductsRaw = @(
        $rawProducts |
            Where-Object { $selectedProductIds.Contains($_.product_id) } |
            Sort-Object product_id
    )

    $selectedSellersRaw = @(
        $rawSellers |
            Where-Object { $selectedSellerIds.Contains($_.seller_id) } |
            Sort-Object seller_id
    )

    $referencedCategoryNames = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($row in $selectedProductsRaw) {
        if (-not [string]::IsNullOrWhiteSpace($row.product_category_name)) {
            $null = $referencedCategoryNames.Add($row.product_category_name)
        }
    }

    $orderedCategoryNames = New-Object System.Collections.Generic.List[string]
    $seenCategories = [System.Collections.Generic.HashSet[string]]::new()

    foreach ($row in $rawCategoryTranslations) {
        if (
            -not [string]::IsNullOrWhiteSpace($row.product_category_name) -and
            $referencedCategoryNames.Contains($row.product_category_name) -and
            $seenCategories.Add($row.product_category_name)
        ) {
            $orderedCategoryNames.Add($row.product_category_name) | Out-Null
        }
    }

    foreach ($name in ($referencedCategoryNames | Sort-Object)) {
        if ($seenCategories.Add($name)) {
            $orderedCategoryNames.Add($name) | Out-Null
        }
    }

    $categoryIdMap = @{}
    $categoriesOut = New-Object System.Collections.Generic.List[object]
    $categoryId = 1

    foreach ($categoryName in $orderedCategoryNames) {
        $categoryIdMap[$categoryName] = $categoryId
        $categoriesOut.Add([pscustomobject]@{
            category_id = $categoryId
            product_category_name = $categoryName
        }) | Out-Null
        $categoryId += 1
    }

    $customersOut = @(
        foreach ($row in $selectedCustomersRaw) {
            [pscustomobject]@{
                customer_id = $row.customer_id
                customer_unique_id = $row.customer_unique_id
                customer_zip_code_prefix = [int]$row.customer_zip_code_prefix
                customer_city = $row.customer_city
                customer_state = $row.customer_state
            }
        }
    )

    $addressesOut = @(
        foreach ($row in $selectedCustomersRaw) {
            [pscustomobject]@{
                address_id = "addr_$($row.customer_id)"
                customer_id = $row.customer_id
                zip_code = $row.customer_zip_code_prefix.PadLeft(5, '0')
                city = $row.customer_city
                state = $row.customer_state
            }
        }
    )

    $sellersOut = @(
        foreach ($row in $selectedSellersRaw) {
            [pscustomobject]@{
                seller_id = $row.seller_id
                seller_zip_code_prefix = [int]$row.seller_zip_code_prefix
                seller_city = $row.seller_city
                seller_state = $row.seller_state
            }
        }
    )

    $productsOut = @(
        foreach ($row in $selectedProductsRaw) {
            $mappedCategoryId = $null
            if (
                -not [string]::IsNullOrWhiteSpace($row.product_category_name) -and
                $categoryIdMap.ContainsKey($row.product_category_name)
            ) {
                $mappedCategoryId = $categoryIdMap[$row.product_category_name]
            }

            [pscustomobject]@{
                product_id = $row.product_id
                category_id = $mappedCategoryId
                product_name_length = Convert-ToNullableValue $row.product_name_lenght
                product_description_length = Convert-ToNullableValue $row.product_description_lenght
                product_photos_qty = Convert-ToNullableValue $row.product_photos_qty
                product_weight_g = Convert-ToNullableValue $row.product_weight_g
                product_length_cm = Convert-ToNullableValue $row.product_length_cm
                product_height_cm = Convert-ToNullableValue $row.product_height_cm
                product_width_cm = Convert-ToNullableValue $row.product_width_cm
            }
        }
    )

    $ordersOut = @(
        foreach ($row in $selectedOrdersFinal) {
            [pscustomobject]@{
                order_id = $row.order_id
                customer_id = $row.customer_id
                order_status = $row.order_status
                order_purchase_timestamp = $row.order_purchase_timestamp
                order_approved_at = Convert-ToNullableValue $row.order_approved_at
                order_delivered_carrier_date = Convert-ToNullableValue $row.order_delivered_carrier_date
                order_delivered_customer_date = Convert-ToNullableValue $row.order_delivered_customer_date
                order_estimated_delivery_date = Convert-ToNullableValue $row.order_estimated_delivery_date
            }
        }
    )

    $paymentsOut = @(
        foreach ($paymentGroup in (
            $rawPayments |
                Where-Object { $selectedOrderIds.Contains($_.order_id) } |
                Group-Object { "$($_.order_id)|$($_.payment_sequential)" } |
                Sort-Object Name
        )) {
            $chosenPayment = @(
                $paymentGroup.Group |
                    Sort-Object @{ Expression = { [decimal]$_.payment_value } }, payment_type -Descending |
                    Select-Object -First 1
            )[0]

            [pscustomobject]@{
                payment_id = "pay_$($chosenPayment.order_id)_$($chosenPayment.payment_sequential)"
                order_id = $chosenPayment.order_id
                payment_sequential = [int]$chosenPayment.payment_sequential
                payment_type = $chosenPayment.payment_type
                payment_installments = [int]$chosenPayment.payment_installments
                payment_value = $chosenPayment.payment_value
            }
        }
    )

    $reviewsOut = @(
        foreach ($reviewGroup in (
            $rawReviews |
                Where-Object { $selectedOrderIds.Contains($_.order_id) } |
                Group-Object order_id |
                Sort-Object Name
        )) {
            $chosenReview = @(
                $reviewGroup.Group |
                    Sort-Object `
                        @{ Expression = { if ([string]::IsNullOrWhiteSpace($_.review_answer_timestamp)) { [datetime]::MinValue } else { [datetime]$_.review_answer_timestamp } } }, `
                        @{ Expression = { [datetime]$_.review_creation_date } }, `
                        review_id -Descending |
                    Select-Object -First 1
            )[0]

            [pscustomobject]@{
                review_id = "rev_$($chosenReview.order_id)"
                order_id = $chosenReview.order_id
                review_score = [int]$chosenReview.review_score
                review_creation_date = $chosenReview.review_creation_date
                review_answer_timestamp = Convert-ToNullableValue $chosenReview.review_answer_timestamp
            }
        }
    )

    $shipmentsOut = @(
        foreach ($row in $selectedOrdersFinal) {
            [pscustomobject]@{
                shipment_id = "shp_$($row.order_id)"
                order_id = $row.order_id
                shipment_status = Get-ShipmentStatus -Order $row
                shipped_at = Convert-ToNullableValue $row.order_delivered_carrier_date
                delivered_at = Convert-ToNullableValue $row.order_delivered_customer_date
            }
        }
    )

    $orderItemsOut = New-Object System.Collections.Generic.List[object]
    $globalOrderItemId = 1
    foreach ($row in $selectedOrderItemsRaw) {
        $orderItemsOut.Add([pscustomobject]@{
            order_item_id = $globalOrderItemId
            order_id = $row.order_id
            product_id = $row.product_id
            seller_id = $row.seller_id
            shipping_limit_date = $row.shipping_limit_date
            price = $row.price
            freight_value = $row.freight_value
        }) | Out-Null

        $globalOrderItemId += 1
    }

    Write-Host "Gravando massa reduzida em $resolvedOutputDir..."

    Export-TableCsv -PathValue (Join-Path $resolvedOutputDir "categories.csv") -Rows $categoriesOut.ToArray()
    Export-TableCsv -PathValue (Join-Path $resolvedOutputDir "customers.csv") -Rows $customersOut
    Export-TableCsv -PathValue (Join-Path $resolvedOutputDir "sellers.csv") -Rows $sellersOut
    Export-TableCsv -PathValue (Join-Path $resolvedOutputDir "products.csv") -Rows $productsOut
    Export-TableCsv -PathValue (Join-Path $resolvedOutputDir "orders.csv") -Rows $ordersOut
    Export-TableCsv -PathValue (Join-Path $resolvedOutputDir "addresses.csv") -Rows $addressesOut
    Export-TableCsv -PathValue (Join-Path $resolvedOutputDir "payments.csv") -Rows $paymentsOut
    Export-TableCsv -PathValue (Join-Path $resolvedOutputDir "reviews.csv") -Rows $reviewsOut
    Export-TableCsv -PathValue (Join-Path $resolvedOutputDir "shipments.csv") -Rows $shipmentsOut
    Export-TableCsv -PathValue (Join-Path $resolvedOutputDir "order_items.csv") -Rows $orderItemsOut.ToArray()

    $counts = [ordered]@{
        categories = $categoriesOut.Count
        customers = $customersOut.Count
        sellers = $sellersOut.Count
        products = $productsOut.Count
        orders = $ordersOut.Count
        addresses = $addressesOut.Count
        payments = $paymentsOut.Count
        reviews = $reviewsOut.Count
        shipments = $shipmentsOut.Count
        order_items = $orderItemsOut.Count
    }

    $totalRowsGenerated = 0
    foreach ($countValue in $counts.Values) {
        $totalRowsGenerated += [int]$countValue
    }

    if ($totalRowsGenerated -lt $MinimumTotalRows) {
        throw (
            "A massa gerada ficou abaixo do minimo exigido. " +
            "Total gerado: $totalRowsGenerated linhas. " +
            "Minimo esperado: $MinimumTotalRows. " +
            "Aumente o valor de -TargetOrders."
        )
    }

    $counts | ConvertTo-Json | Set-Content `
        -LiteralPath (Join-Path $resolvedOutputDir "expected-counts.json") `
        -Encoding UTF8

    $selectedProductsById = @{}
    foreach ($row in $selectedProductsRaw) {
        $selectedProductsById[$row.product_id] = $row
    }

    $topCategories = @(
        $selectedOrderItemsRaw |
            Group-Object {
                $product = $selectedProductsById[$_.product_id]
                if ($null -eq $product -or [string]::IsNullOrWhiteSpace($product.product_category_name)) {
                    return "sem_categoria"
                }

                return $product.product_category_name
            } |
            Sort-Object Count -Descending |
            Select-Object -First 10 |
            ForEach-Object {
                [ordered]@{
                    category = $_.Name
                    sold_items = $_.Count
                }
            }
    )

    $summary = [ordered]@{
        generated_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
        source = "Kaggle Olist raw CSV"
        target_orders = $TargetOrders
        minimum_total_rows = $MinimumTotalRows
        selected_orders = $ordersOut.Count
        total_rows_generated = $totalRowsGenerated
        counts = $counts
        orders_by_month = @(
            $ordersOut |
                Group-Object { Get-MonthKey -Timestamp $_.order_purchase_timestamp } |
                Sort-Object Name |
                ForEach-Object {
                    [ordered]@{
                        month = $_.Name
                        orders = $_.Count
                    }
                }
        )
        order_status_distribution = @(
            $ordersOut |
                Group-Object order_status |
                Sort-Object Count -Descending |
                ForEach-Object {
                    [ordered]@{
                        status = $_.Name
                        orders = $_.Count
                    }
                }
        )
        payment_type_distribution = @(
            $paymentsOut |
                Group-Object payment_type |
                Sort-Object Count -Descending |
                ForEach-Object {
                    [ordered]@{
                        payment_type = $_.Name
                        payments = $_.Count
                    }
                }
        )
        customer_state_distribution = @(
            $customersOut |
                Group-Object customer_state |
                Sort-Object Count -Descending |
                ForEach-Object {
                    [ordered]@{
                        state = $_.Name
                        customers = $_.Count
                    }
                }
        )
        top_categories = $topCategories
    }

    $summary | ConvertTo-Json -Depth 6 | Set-Content `
        -LiteralPath (Join-Path $resolvedOutputDir "selection-summary.json") `
        -Encoding UTF8

    Write-Host "Massa reduzida gerada com sucesso."
    Write-Host ("Total de linhas geradas: {0}" -f $totalRowsGenerated)
    Write-Host ($counts | ConvertTo-Json -Compress)
}
catch {
    Write-Error $_
    exit 1
}
