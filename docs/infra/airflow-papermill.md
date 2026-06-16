# Airflow + Papermill (Orquestração)

Adiciona o **Airflow** (LocalExecutor) ao ambiente Docker, executando notebooks
via **Papermill**. É a base do épico **#16 (ORQUESTRACAO)** — issue **#30**.

> **Origem dos dados:** o banco transacional de origem é o **Supabase** (carregado
> pelo Pedro). O PostgreSQL local do `docker-compose` é reaproveitado apenas como
> **banco de metadados do Airflow** (banco `airflow`, criado automaticamente).

## Arquitetura
- Imagem custom (`docker/airflow/Dockerfile`): Airflow 2.10.5 + Papermill + PySpark/Delta + Java 17.
- Um único container roda `scheduler` + `webserver` (LocalExecutor) — leve para máquinas com pouca RAM.
- Metadados no PostgreSQL (`postgres` do compose, banco `airflow`).
- DAGs em `airflow/dags/`, notebooks em `notebooks/` (montados no container).

O serviço fica atrás do **profile `airflow`**, então o `docker compose up -d` padrão
continua subindo só a base (MinIO + Postgres). O Airflow sobe sob demanda.

## Pré-requisitos
- Ambiente base (issue #20) funcionando.
- ~2 GB de RAM livres para o Airflow.

## Como subir

```bash
# (uma vez) gere uma Fernet key e coloque em AIRFLOW_FERNET_KEY no .env
docker run --rm apache/airflow:2.10.5-python3.11 \
  python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"

# build + subir base + Airflow
docker compose --profile airflow up -d --build
```

A primeira vez faz o build da imagem (baixa Java + PySpark) — pode demorar alguns minutos.

## Acessar e validar

- **UI do Airflow:** http://localhost:8080 — login `admin` / `admin` (ajustável no `.env`).
- Ative e dispare a DAG **`smoke_test_papermill`** (ou via CLI):

```bash
docker compose exec airflow airflow dags trigger smoke_test_papermill
docker compose exec airflow airflow dags list-runs -d smoke_test_papermill
```

Sucesso esperado: a task `run_notebook` fica **success** e o notebook executado é
gravado em `notebooks/output/smoke_test_out.ipynb` (e um arquivo de teste aparece
em `datalake/landing/_smoke_test.txt` no MinIO).

## Encerrar

```bash
docker compose --profile airflow down       # para tudo, mantém os dados
```
