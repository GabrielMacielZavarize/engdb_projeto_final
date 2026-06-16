"""DAG de smoke-test do épico de orquestração (#16 / issue #30).

Executa um notebook simples via Papermill para validar que o Airflow consegue
rodar notebooks parametrizados. Serve de base para a DAG real do pipeline
medalhão (issue #31).
"""
from __future__ import annotations

import pendulum
from airflow.models.dag import DAG
from airflow.operators.bash import BashOperator

with DAG(
    dag_id="smoke_test_papermill",
    description="Valida a execução de notebooks via Papermill no Airflow",
    schedule=None,  # disparo manual
    start_date=pendulum.datetime(2026, 1, 1, tz="UTC"),
    catchup=False,
    tags=["smoke", "orquestracao"],
) as dag:
    run_notebook = BashOperator(
        task_id="run_notebook",
        bash_command=(
            "mkdir -p /opt/airflow/notebooks/output && "
            "papermill /opt/airflow/notebooks/smoke_test.ipynb "
            "/opt/airflow/notebooks/output/smoke_test_out.ipynb "
            "-p mensagem 'pipeline engdb' "
            "-p execucao '{{ run_id }}'"
        ),
    )
