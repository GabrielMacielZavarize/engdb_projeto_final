# Projeto Final — Engenharia de Dados (Olist)

Pipeline de dados **ponta a ponta** sobre o [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), seguindo a **arquitetura medalhão** (Landing → Bronze → Silver → Gold) com processamento em Spark/Delta, orquestração no Airflow e um dashboard analítico no Metabase.

- 📖 **Documentação (MkDocs):** https://gabrielmacielzavarize.github.io/engdb_projeto_final/
- 🗃️ **Origem dos dados:** Supabase (PostgreSQL) · **Data Lake:** MinIO (Delta Lake)

---

## Visão geral

```text
 Supabase (PostgreSQL)            MinIO (Data Lake / Delta)                 Consumo
 ┌──────────────┐   JDBC   ┌──────────┬──────────┬──────────┬──────────┐  ┌────────┐   ┌──────────┐
 │ schema source│ ───────► │ Landing  │  Bronze  │  Silver  │   Gold   │─►│ Trino  │──►│ Metabase │
 │ (10 tabelas) │          │  (CSV)   │ (Delta)  │ (Delta)  │ (estrela)│  │ (SQL)  │   │(dashboard)│
 └──────────────┘          └──────────┴──────────┴──────────┴──────────┘  └────────┘   └──────────┘
        ▲                         └──── Spark + Delta (PySpark) ────┘
        │
   Apache Airflow  ──  orquestra as 4 camadas via Papermill (DAG `pipeline_medalhao`, agendada)
```

- **Landing** — ingestão bruta da origem (CSV, sem transformação).
- **Bronze** — Delta tipado, carga **incremental e idempotente** (`MERGE` por PK).
- **Silver** — limpeza, padronização e integridade referencial.
- **Gold** — modelo **dimensional (estrela)** com **SCD Tipo 2** nas dimensões e **checkpoint** (watermark) na carga incremental dos fatos.
- **Serving** — **Trino** lê o Delta da Gold e o **Metabase** entrega o dashboard *One Page* (4 KPIs + 2 gráficos).

## Stack

| Camada | Tecnologia |
|--------|-----------|
| Origem | Supabase (PostgreSQL) |
| Data Lake | MinIO (object storage S3) + Delta Lake |
| Processamento | Apache Spark / PySpark |
| Orquestração | Apache Airflow + Papermill |
| Consumo (SQL) | Trino + Hive Metastore |
| Dashboard | Metabase |
| Documentação | MkDocs Material → GitHub Pages |
| Ambiente | Docker / Docker Compose |

## Estrutura do repositório

```text
airflow/dags/      DAGs do Airflow (pipeline_medalhao)
docker/            Dockerfiles e configs (airflow, trino, hive, metabase, postgres)
docs/              Documentação (publicada via MkDocs)
notebooks/         Notebooks das camadas (landing/bronze/silver/gold) + template
sql/               DDL da origem, validações e seed da demo incremental
scripts/           Geração e carga da massa de origem
docker-compose.yml Toda a stack (profiles: base, airflow, serving)
mkdocs.yml
.env.example       Modelo de variáveis de ambiente (copie para .env)
```

## Pré-requisitos

- Docker + Docker Compose
- Arquivo `.env` (copie de `.env.example` e preencha o acesso ao Supabase):
  ```bash
  cp .env.example .env   # preencher SOURCE_DB_USER e SOURCE_DB_PASSWORD (Session pooler do Supabase)
  ```

## Serviços e portas

| Serviço | URL | Login |
|---------|-----|-------|
| MinIO (console) | http://localhost:9001 | `minioadmin` / `minioadmin` |
| Airflow (UI) | http://localhost:8080 | `admin` / `admin` |
| Trino (UI) | http://localhost:8090 | — |
| Metabase (dashboard) | http://localhost:3000 | (definido no 1º acesso) |

---

## 🎬 Roteiro de demonstração

Mostra o ciclo completo: **buckets vazios → Airflow carrega os dados → dashboard lendo a Gold**.

### 1) Buckets vazios

```bash
docker compose up -d minio createbuckets
# esvazia o Data Lake (mantém a config do Metabase)
docker run --rm --network engdb_datalake -e MC_HOST_local=http://minioadmin:minioadmin@minio:9000 \
  minio/mc:RELEASE.2025-08-13T08-35-41Z rm --recursive --force --dangerous local/datalake/
```
Abra o **MinIO** (http://localhost:9001) e mostre o bucket `datalake` **vazio**.

### 2) Executar o Airflow para a carga

```bash
docker compose --profile airflow up -d --build
```
No **Airflow** (http://localhost:8080), abra a DAG **`pipeline_medalhao`** e clique em **Trigger**. Acompanhe as tasks `landing → bronze → silver → gold`. Ao terminar, volte ao MinIO e mostre os prefixos `landing/ bronze/ silver/ gold/` **populados**.

> Alternativa headless (sem a UI), executando as 4 camadas direto via Papermill:
> ```bash
> docker compose --profile airflow run --rm --no-deps -e CONNECTION_CHECK_MAX_COUNT=0 airflow bash -c '
>   papermill notebooks/landing/landing_ingestao.ipynb     notebooks/runs/landing.ipynb -p run_date 2026-06-24
>   papermill notebooks/bronze/bronze_ingestao.ipynb       notebooks/runs/bronze.ipynb  -p run_date 2026-06-24
>   papermill notebooks/silver/silver_conformacao.ipynb    notebooks/runs/silver.ipynb
>   papermill notebooks/gold/gold_modelo_dimensional.ipynb notebooks/runs/gold.ipynb    -p run_date 2026-06-24
> '
> ```

### 3) Dashboard lendo a Gold

```bash
# (em máquina de 8GB, pare o Airflow antes para liberar RAM: docker compose --profile airflow stop)
docker compose --profile serving up -d --build
docker compose exec -T trino trino < docker/trino/register_gold_tables.sql
docker compose exec trino trino --execute "SELECT count(*) FROM delta.gold.fact_orders"   # esperado: 15001
```
Abra o **Metabase** (http://localhost:3000) e mostre o dashboard **One Page** (4 KPIs + 2 gráficos). Detalhes em [`docs/dashboards/dashboard_one_page.md`](docs/dashboards/dashboard_one_page.md).

---

## Destaques técnicos

- **Arquitetura medalhão** com Delta Lake (ACID, `MERGE`, time-travel) sobre object storage.
- **SCD Tipo 2** nas dimensões (`valid_from`/`valid_to`/`is_current`, surrogate key determinística).
- **Carga incremental por checkpoint** (watermark por fato) — reprocessar não duplica.
- **Orquestração** pelo Airflow (DAG agendada, sem cron do SO), executando notebooks via Papermill.
- **Consumo desacoplado** via Trino (SQL ANSI sobre o Delta), consumido pelo Metabase.

## Dashboard — KPIs (One Page)

| Indicador | Valor (massa atual) |
|-----------|---------------------|
| Receita Total | ~ R$ 2.390.000 |
| Quantidade de Pedidos | 15.001 |
| Ticket Médio | R$ 159,37 |
| Tempo Médio de Entrega | ~ 12 dias |

Gráficos: **Vendas por Mês** e **Top 10 Categorias Vendidas**. Evidências em `docs/dashboards/evidencias/`.

## Equipe

| Integrante | GitHub | Frente |
|-----------|--------|--------|
| Gabriel Maciel Zavarize | [@GabrielMacielZavarize](https://github.com/GabrielMacielZavarize) | Infra / Orquestração |
| Nicolas Cardoso | [@nicolasmacardoso](https://github.com/nicolasmacardoso) | Pipeline |
| Pedro Harter | [@PedroHarter](https://github.com/PedroHarter) | Dados / Origem |
| Wilian Vieira | [@WilianVieiraF](https://github.com/WilianVieiraF) | Documentação |
| Carlos Scheffer | [@CarlosSchefferr](https://github.com/CarlosSchefferr) | Dashboard |

## Padrões de contribuição

Issues → branch por issue → Conventional Commits → Pull Request com revisão → *squash merge* na `main` (protegida). Detalhes em [`docs/PADROES.md`](docs/PADROES.md).
