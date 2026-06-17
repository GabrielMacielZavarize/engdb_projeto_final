"""DAG do pipeline medalhão (issues #31 e #32, épico #16).

Orquestra as quatro camadas do Data Lake na ordem
**Landing → Bronze → Silver → Gold**, cada uma executando o notebook
Spark/Delta correspondente via Papermill (mesma base da DAG de smoke-test
da #30). Os notebooks foram validados localmente na #38.

Agendamento e parametrização (#32):
- **Agendado** via Airflow (`schedule="@daily"`, `catchup=False`) — sem usar
  cron do SO / agendador do Windows.
- **Parâmetros** (UI "Trigger DAG w/ config" ou `airflow dags trigger --conf`):
  - `run_date`: data de referência `YYYY-MM-DD`; vazio usa a data lógica (`ds`).
  - `target_layer`: `all` (padrão) ou uma camada específica para reprocessar
    só ela.
- A data efetiva é repassada como `run_date` às camadas que particionam/
  versionam por data (Landing, Bronze, Gold). A Silver reprocessa todo o
  Bronze, então não recebe `run_date`.
- Saída por execução em `notebooks/runs/<AAAAMMDD>/<camada>.ipynb` (ignorada
  no git). `retries=2` e `sla=2h` por task.
"""
from __future__ import annotations

import pendulum
from airflow.models.dag import DAG
from airflow.models.param import Param
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
    "sla": pendulum.duration(hours=2),
}

DOC_MD = """
### Pipeline medalhão (Olist)

Executa **Landing → Bronze → Silver → Gold** (Spark/Delta no MinIO) via Papermill.

- **Agendado:** roda automaticamente (`schedule=@daily`, `catchup=False`) — o
  agendador do Airflow cuida disso, sem cron do SO.
- **Manual com parâmetros** (UI *Trigger DAG w/ config* ou CLI):
  - `run_date` — `YYYY-MM-DD`; vazio usa a data lógica (`ds`).
  - `target_layer` — `all` (padrão) ou `landing`/`bronze`/`silver`/`gold` para
    reprocessar só uma camada.

```
airflow dags trigger pipeline_medalhao \\
  --conf '{"run_date":"2026-06-17","target_layer":"silver"}'
```
"""


def papermill_command(task_id: str, notebook_rel: str, with_run_date: bool) -> str:
    """Comando Papermill da camada, com guarda de `target_layer`.

    Mantém o Jinja (`{{ ds }}`, `{{ params.* }}`) literal para o Airflow
    renderizar em tempo de execução.
    """
    src = NOTEBOOKS + "/" + notebook_rel
    out = RUNS_DIR + "/" + task_id + ".ipynb"
    run_date_param = " -p run_date {{ params.run_date or ds }}" if with_run_date else ""
    papermill = (
        "mkdir -p " + RUNS_DIR + " && "
        "papermill " + src + " " + out + run_date_param + " --log-output"
    )
    # Só executa se target_layer for 'all' ou exatamente esta camada.
    guard = (
        'if [ "{{ params.target_layer }}" = "all" ] || '
        '[ "{{ params.target_layer }}" = "' + task_id + '" ]; then '
        + papermill +
        '; else echo "[skip] camada ' + task_id + ' (target_layer={{ params.target_layer }})"; fi'
    )
    return guard


with DAG(
    dag_id="pipeline_medalhao",
    description="Pipeline medalhão Olist: Landing -> Bronze -> Silver -> Gold (Spark/Delta no MinIO)",
    schedule="@daily",  # agendamento pelo Airflow (sem cron do SO)
    start_date=pendulum.datetime(2026, 6, 1, tz="UTC"),
    catchup=False,
    default_args=default_args,
    params={
        "run_date": Param(
            default=None,
            type=["null", "string"],
            description="Data de referência (YYYY-MM-DD). Vazio = usa a data lógica (ds).",
        ),
        "target_layer": Param(
            default="all",
            enum=["all", "landing", "bronze", "silver", "gold"],
            description="Executa só a camada escolhida (ou todas).",
        ),
    },
    doc_md=DOC_MD,
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
