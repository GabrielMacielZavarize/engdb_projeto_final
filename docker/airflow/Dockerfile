# Imagem do Airflow com Papermill + dependências do pipeline (PySpark/Delta).
# Base do épico #16 (ORQUESTRACAO) — issue #30.
FROM apache/airflow:2.10.5-python3.11

# Java é necessário para o PySpark (motor de transformação do pipeline).
USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends openjdk-17-jdk-headless procps \
 && apt-get clean && rm -rf /var/lib/apt/lists/*
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Script que garante o banco de metadados do Airflow no PostgreSQL.
COPY docker/airflow/ensure_metadata_db.py /opt/airflow/ensure_metadata_db.py

USER airflow
RUN pip install --no-cache-dir \
      papermill==2.6.0 \
      ipykernel==6.29.5 \
      minio==7.2.10 \
      pyspark==3.5.4 \
      delta-spark==3.2.1 \
 && python -m ipykernel install --user --name python3 --display-name python3
