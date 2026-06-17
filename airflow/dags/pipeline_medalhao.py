"""DAG do pipeline medalhão (issue #31, épico #16).

Orquestra as quatro camadas do Data Lake na ordem
**Landing → Bronze → Silver → Gold**, cada uma executando o notebook
Spark/Delta correspondente via Papermill (mesma base da DAG de smoke-test
da #30). Os notebooks foram validados localmente na #38.

- A data lógica do Airflow (`{{ ds }}`) é repassada como `run_date` para as
  camadas que particionam/versionam por data (Landing, Bronze, Gold). A Silver
  reprocessa todo o Bronze, então não recebe `run_date`.
- Cada execução grava os notebooks de saída em
  `notebooks/runs/<AAAAMMDD>/<camada>.ipynb` (pasta ignorada no git).
- Agendamento e parâmetros mais finos ficam na #32; a demo de carga
  incremental, na #33.
"""
from __future__ import annotations

import pendulum
from airflow.models.dag import DAG
from airflow.operators.bash import BashOperator

NOTEBOOKS = "/opt/airflow/notebooks"
# Pasta de saída por execução (Jinja resolvido pelo Airflow em tempo de run).
RUNS_DIR = NOTEBOOKS + "/runs/{{ ds_nodash }}"

# Notebook de cada camada e se ela recebe run_date.
LAYERS = [
    ("landing", "landing/landing_ingestao.ipynb", True),
    ("bronze", "bronze/bronze_ingestao.ipynb", True),
    ("silver", "silver/silver_conformacao.ipynb", False),
    ("gold", "gold/gold_modelo_dimensional.ipynb", True),
]

default_args = {
    "retries": 2,
    "retry_delay": pendulum.duration(minutes=2),
}


def papermill_command(task_id: str, notebook_rel: str, with_run_date: bool) -> str:
    """Monta o comando Papermill da camada (mantém o Jinja `{{ ds }}` literal)."""
    src = NOTEBOOKS + "/" + notebook_rel
    out = RUNS_DIR + "/" + task_id + ".ipynb"
    params = " -p run_date {{ ds }}" if with_run_date else ""
    return (
        "mkdir -p " + RUNS_DIR + " && "
        "papermill " + src + " " + out + params + " --log-output"
    )


with DAG(
    dag_id="pipeline_medalhao",
    description="Pipeline medalhão Olist: Landing -> Bronze -> Silver -> Gold (Spark/Delta no MinIO)",
    schedule=None,  # disparo manual; agendamento fica na #32
    start_date=pendulum.datetime(2026, 1, 1, tz="UTC"),
    catchup=False,
    default_args=default_args,
    tags=["pipeline", "medalhao", "spark", "delta"],
) as dag:
    previous = None
    for task_id, notebook_rel, with_run_date in LAYERS:
        task = BashOperator(
            task_id=task_id,
            bash_command=papermill_command(task_id, notebook_rel, with_run_date),
        )
        if previous is not None:
            previous >> task
        previous = task
