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

## Reproduzir em outra máquina (após `git pull`)

Para deixar o ambiente pronto em outra máquina (o driver Starburst já vem
embutido na imagem via `docker/metabase/Dockerfile`, então não é preciso baixar
`.jar` manualmente):

```powershell
# 1) Configurar segredos (não versionado). Preencher SOURCE_DB_USER/PASSWORD do Supabase.
copy .env.example .env

# 2) Subir o object storage e o bucket
docker compose up -d minio createbuckets

# 3) Rodar o pipeline (popula a Gold no MinIO). run_date conforme a equipe.
docker compose --profile airflow run --rm --no-deps -e CONNECTION_CHECK_MAX_COUNT=0 airflow bash -c '
  papermill notebooks/landing/landing_ingestao.ipynb     notebooks/runs/landing.ipynb -p run_date 2026-06-22
  papermill notebooks/bronze/bronze_ingestao.ipynb       notebooks/runs/bronze.ipynb  -p run_date 2026-06-22
  papermill notebooks/silver/silver_conformacao.ipynb    notebooks/runs/silver.ipynb
  papermill notebooks/gold/gold_modelo_dimensional.ipynb notebooks/runs/gold.ipynb    -p run_date 2026-06-22
'

# 4) Subir o serving (builda a imagem do Metabase com o driver Starburst 5.0.0)
docker compose --profile serving up -d --build

# 5) Registrar as tabelas da Gold no Trino
docker compose exec -T trino trino < docker/trino/register_gold_tables.sql
```

> O dashboard "One Page" é montado **manualmente** no Metabase. Os SQLs finais
> de cada card estão em [`../dashboards/dashboard_queries.sql`](../dashboards/dashboard_queries.sql)
> e o layout/visualizações em [`../dashboards/dashboard_one_page.md`](../dashboards/dashboard_one_page.md).

## ⚠️ Hive Metastore efêmero — re-registrar a Gold após `down`/`up`

O Hive Metastore deste projeto usa **Derby embutido, com armazenamento efêmero**
(sem volume): os registros das tabelas vivem dentro do próprio container. Por
isso, **todo ciclo de `docker compose down` seguido de `up` apaga o registro das
tabelas da Gold no Trino** (os dados Delta em si continuam intactos no MinIO).

Depois de subir o ambiente novamente, **registre de novo as tabelas da Gold**:

```powershell
docker compose exec -T trino trino < docker/trino/register_gold_tables.sql
```

Antes de abrir o dashboard para apresentação, **valide** que a Gold está
disponível no Trino:

```powershell
docker compose exec trino trino --execute "SELECT count(*) FROM delta.gold.fact_orders"
```

O resultado esperado é **`15001`**. Se vier vazio ou com erro de schema/tabela,
a re-registração acima ainda não foi feita — rode o `register_gold_tables.sql`
antes de continuar, ou todos os cards do dashboard falharão.

## Notas

- O Hive Metastore usa Derby embutido (efêmero): se recriar o container, rode o
  `register_gold_tables.sql` de novo.
- O driver Starburst/Trino do Metabase é baixado no build da imagem
  (`docker/metabase/Dockerfile`, release **5.0.0** = linha Metabase 0.50.x);
  não versionamos o `.jar`.
- O Trino acessa o MinIO via S3 nativo (`s3://datalake/...`, `path-style`),
  com credenciais lidas das variáveis `MINIO_ROOT_USER`/`MINIO_ROOT_PASSWORD`.
