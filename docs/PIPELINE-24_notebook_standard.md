# [PIPELINE] Padrão de notebooks / scripts Spark + Delta (Issue #24)

Este documento descreve a convenção de pastas, padrões de parametrização
(compatível com Papermill), configuração mínima do Spark para Delta e S3A
(MinIO), e convenções de nomes de tabelas/paths para as camadas Landing,
Bronze, Silver e Gold.

Estrutura de pastas recomendada

- `notebooks/landing/` — notebooks de ingestão (raw)
- `notebooks/bronze/` — transformações mínimas (persistência raw -> bronze)
- `notebooks/silver/` — limpeza e consolidação
- `notebooks/gold/` — modelos de consumo/aggregações e objetos prontos para BI
- `notebooks/template/` — notebook-template parametrizável

Notebook-template

- Deve ter uma célula marcada com a tag `parameters` contendo as variáveis
  que serão sobrescritas pelo Papermill (ex.: `source_path`, `target_path`,
  `run_date`, `minio_endpoint`, `minio_access_key`, `minio_secret_key`).
- Incluir célula de inicialização do Spark com configuração para Delta e S3A.
- Incluir um exemplo de leitura/escrita em Delta (escrever uma pequena
  DataFrame de exemplo para validar end-to-end).

Configuração mínima do Spark (exemplo)

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("notebook-template") \
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog") \
    .config("spark.hadoop.fs.s3a.endpoint", minio_endpoint) \
    .config("spark.hadoop.fs.s3a.access.key", minio_access_key) \
    .config("spark.hadoop.fs.s3a.secret.key", minio_secret_key) \
    .config("spark.hadoop.fs.s3a.path.style.access", "true") \
    .getOrCreate()
```

Conveniência Delta / MinIO

- Recomendamos usar `Parquet` no princípio, e adotar `Delta Lake` para camadas
  que necessitem de versionamento/ACID/time-travel.
- Usar URL estilo `s3a://bucket/path/...` para leitura/escrita.

Convenção de nomes

- Paths: `s3a://<bucket>/landing/<dataset>/<source>/<year=YYYY>/...`
- Tabelas: `<project>_<layer>_<dataset>` — ex.: `engdb_gold_orders`

Parametrização Papermill

- Marcar célula `parameters` no começo do notebook com variáveis padrão.
- Exemplo de execução local com Papermill:

```powershell
powershell> papermill notebooks/template/template_notebook.ipynb notebooks/runs/run_output.ipynb -p run_date 2026-06-16 -p target_path s3a://minio-bucket/bronze/orders
```

Critérios de aceite

- Notebook-template executa (local) e grava/ler Delta em MinIO (pode usar
  dados de exemplo).
- Parâmetros podem ser sobrescritos via Papermill.
- Documentação adicionada em `/docs`.

---

_Versão inicial: 2026-06-16_
