# Serving — Trino + Metabase sobre a Gold

Camada de consumo do projeto (issue #46): o **Trino** lê as tabelas **Delta** da
camada Gold direto no MinIO e o **Metabase** monta o dashboard analítico
(One Page) em cima do Trino. Um **Hive Metastore** (Derby embutido) é incluído
porque o conector `delta_lake` do Trino exige um metastore.

```text
Gold (Delta no MinIO)  ──►  Trino (catálogo delta_lake)  ──►  Metabase (dashboard)
                              └── Hive Metastore (Derby)
```

Os serviços ficam no profile **`serving`** do `docker-compose.yml`, separados do
pipeline. Em máquinas com pouca RAM (ex.: 8GB), **suba o serving sem o Airflow/Spark
rodando ao mesmo tempo**.

## Subir

```powershell
# MinIO precisa estar no ar e a Gold já populada pelo pipeline
docker compose up -d minio
docker compose --profile serving up -d
```

| Serviço | URL | Observação |
|---------|-----|------------|
| Trino | http://localhost:8090 | UI/API (porta 8080 do host é do Airflow) |
| Metabase | http://localhost:3000 | primeiro acesso pede criar o usuário admin |

## Registrar as tabelas da Gold no Trino

Uma vez (após a Gold existir), registra as tabelas Delta no catálogo `delta`:

```powershell
docker compose exec -T trino trino < docker/trino/register_gold_tables.sql
```

Conferindo:

```sql
SHOW TABLES FROM delta.gold;
SELECT sum(order_payment_value) AS receita_total FROM delta.gold.fact_orders;
```

## Conectar o Metabase ao Trino

No Metabase (Admin → Databases → Add): driver **Starburst/Trino**, host `trino`,
porta `8080` (porta interna na rede `datalake`), catálogo `delta`, schema `gold`,
usuário qualquer (ex.: `admin`), sem senha.

> A construção dos cards (4 KPIs + 2 gráficos) é a issue **#48**. O SQL de
> referência de cada indicador está em
> [CARD-025](../dashboards/CARD-025_especificacao_kpis_metricas.md).

## Notas

- O Hive Metastore usa Derby embutido (efêmero): se recriar o container, rode o
  `register_gold_tables.sql` de novo.
- O Trino acessa o MinIO via S3 nativo (`s3://datalake/...`, `path-style`),
  com credenciais lidas das variáveis `MINIO_ROOT_USER`/`MINIO_ROOT_PASSWORD`.
