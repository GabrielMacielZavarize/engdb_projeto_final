# Camadas do Pipeline (Landing → Bronze → Silver → Gold)

Implementação da arquitetura medalhão sobre o dataset Olist — **issue #38**
(épico #15). São quatro notebooks Spark/Delta parametrizáveis (padrão da
[#24](../PIPELINE-24_notebook_standard.md)), executáveis via Papermill e
prontos para a DAG do Airflow (#31).

| Camada | Notebook | Origem → Destino | Formato |
|--------|----------|------------------|---------|
| Landing | `notebooks/landing/landing_ingestao.ipynb` | Supabase (`source`) → `landing/` | CSV cru |
| Bronze | `notebooks/bronze/bronze_ingestao.ipynb` | `landing/` → `bronze/` | Delta (incremental) |
| Silver | `notebooks/silver/silver_conformacao.ipynb` | `bronze/` → `silver/` | Delta (conformado) |
| Gold | `notebooks/gold/gold_modelo_dimensional.ipynb` | `silver/` → `gold/` | Delta (estrela) |

Convenção de paths no Data Lake (MinIO, via `s3a://`):

```text
s3a://datalake/
├── landing/olist/<tabela>/ingestion_date=<run_date>/   # CSV bruto
├── bronze/olist/<tabela>/                              # Delta tipado
├── silver/olist/<tabela>/                              # Delta conformado
└── gold/
    ├── olist/dim_*  fact_*                              # modelo dimensional
    └── _control/fact_checkpoints/                       # watermark dos fatos
```

A origem é o **Supabase** (schema `source`); a conexão usa o *Session pooler*
(IPv4) — ver [Modelo Físico (Supabase)](../modelagem/CARD-007_modelo_fisico_banco_origem.md).

---

## Landing — ingestão bruta

Lê as 10 tabelas do schema `source` via **Spark JDBC** e grava como **CSV sem
transformação**, particionado por `ingestion_date`. É a fonte da verdade para
reprocessar as camadas seguintes sem reconsultar a origem.

- Driver JDBC do PostgreSQL carregado via `extra_packages`
  (`org.postgresql:postgresql:42.7.4`).
- Credenciais e endpoint vêm das variáveis `SOURCE_DB_*` / `MINIO_*`
  (injetadas pelo `docker-compose`).

## Bronze — Delta tipado e incremental

Converte o CSV da Landing em **Delta Lake** aplicando os **tipos corretos**
(timestamps, inteiros e `decimal(12,2)`), já que a origem é relacional e o
schema é conhecido. Acrescenta metadados de linhagem (`_ingestion_date`,
`_bronze_loaded_at`) e preserva `created_at`/`updated_at` como timestamps para
apoiar a detecção de mudanças da origem.

A carga é **incremental e idempotente**: na primeira execução cria a tabela; nas
seguintes faz `MERGE` pela **chave primária** (`whenMatchedUpdateAll` /
`whenNotMatchedInsertAll`), de modo que reexecutar a mesma data não duplica.

## Silver — limpeza e conformação

Aplica qualidade de dados sobre o Bronze:

- `trim` em todos os textos e UF (estado) em maiúsculas;
- remoção de duplicatas por chave primária;
- **integridade referencial** (espelha `sql/02_validate_source_data.sql`):
  descarta órfãos (itens, pagamentos, reviews e remessas sem pedido; pedidos e
  endereços sem cliente; itens sem produto/vendedor) e zera o `category_id` de
  produtos cuja categoria não existe.

Saída em Delta conformado, reescrito a cada execução (a incrementalidade fica no
Bronze, a montante).

## Gold — modelo dimensional (estrela)

Monta o modelo dimensional consumido pelo dashboard (CARD-006).

### Dimensões

| Dimensão | Chave natural | SCD | Observação |
|----------|---------------|-----|------------|
| `dim_date` | `date_sk` (YYYYMMDD) | — | gerada a partir da faixa de datas dos pedidos |
| `dim_customer` | `customer_id` | **Tipo 2** | cidade/UF/zip/unique_id |
| `dim_seller` | `seller_id` | **Tipo 2** | cidade/UF/zip |
| `dim_product` | `product_id` | **Tipo 2** | categoria + dimensões físicas |

### Fatos

| Fato | Grão | Medidas principais | Serve |
|------|------|--------------------|-------|
| `fact_orders` | pedido | `order_payment_value`, `delivery_days`, flags | KPIs 1–4, Vendas por mês |
| `fact_order_items` | item do pedido | `price`, `freight_value` | Top 10 categorias |
| `fact_payments` | pagamento | `payment_value`, `payment_type` | receita por forma de pagamento |

### SCD Tipo 2 (dimensões)

Cada dimensão histórica carrega `valid_from`, `valid_to`, `is_current` e uma
**surrogate key determinística** `*_sk = xxhash64(chave_natural, _hash)`, onde
`_hash = sha2(atributos)`. A versão de cada registro é função do conteúdo, então
o SK é estável entre execuções (idempotência).

O versionamento é feito em duas etapas com `MERGE` Delta:

1. **inserir versões novas** — registros cujo SK ainda não existe entram como
   vigentes (`is_current = true`, `valid_to = null`);
2. **expirar versões antigas** — quando um atributo muda, a linha vigente
   anterior daquela chave natural recebe `is_current = false` e
   `valid_to = run_date`.

### Checkpoint (carga incremental dos fatos)

Cada fato mantém um **watermark** próprio em
`gold/_control/fact_checkpoints` (tabela Delta `fact_name → watermark`). A cada
execução o notebook processa apenas os pedidos com
`order_purchase_timestamp > watermark` e, ao final, grava o novo máximo. Em uma
reexecução sem dados novos, nada é processado — base para a demo de carga
incremental (#33).

---

## Como executar localmente

Pré-requisitos: Docker em execução e `.env` preenchido (incluindo `SOURCE_DB_*`
do Supabase). A imagem `engdb-airflow:local` já traz PySpark, Delta e Papermill.

```powershell
# 1) MinIO + bucket do Data Lake
docker compose up -d minio createbuckets

# 2) Executa as 4 camadas em sequência via Papermill (container efêmero)
docker compose --profile airflow run --rm --no-deps airflow bash -c '
  papermill notebooks/landing/landing_ingestao.ipynb  notebooks/runs/landing_out.ipynb  -p run_date 2026-06-17
  papermill notebooks/bronze/bronze_ingestao.ipynb    notebooks/runs/bronze_out.ipynb   -p run_date 2026-06-17
  papermill notebooks/silver/silver_conformacao.ipynb notebooks/runs/silver_out.ipynb
  papermill notebooks/gold/gold_modelo_dimensional.ipynb notebooks/runs/gold_out.ipynb -p run_date 2026-06-17
'
```

> Os caminhos dentro do container são relativos a `/opt/airflow` (a pasta
> `notebooks/` é montada por volume). A última célula do notebook Gold imprime
> os 4 KPIs e os 2 gráficos calculados a partir da camada Gold, validando a
> aderência ao dashboard.

A primeira execução baixa os JARs (`hadoop-aws`, `postgresql`, `delta`) via Ivy;
as seguintes reaproveitam o cache.
