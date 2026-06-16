#!/usr/bin/env python3
"""Garante que o banco de metadados `airflow` exista no PostgreSQL.

O PostgreSQL do projeto (issue #20) é reaproveitado como banco de metadados do
Airflow. A origem dos dados de negócio é o Supabase — este banco local guarda
apenas o estado interno do Airflow.
"""
import os
import time

import psycopg2
from psycopg2 import OperationalError

HOST = "postgres"
USER = os.environ["POSTGRES_USER"]
PWD = os.environ["POSTGRES_PASSWORD"]
ADMIN_DB = os.environ.get("POSTGRES_DB", "postgres")

conn = None
for attempt in range(1, 31):
    try:
        conn = psycopg2.connect(host=HOST, user=USER, password=PWD, dbname=ADMIN_DB)
        break
    except OperationalError:
        print(f"Aguardando PostgreSQL... ({attempt})")
        time.sleep(2)

if conn is None:
    raise SystemExit("PostgreSQL não respondeu a tempo.")

conn.autocommit = True
cur = conn.cursor()
cur.execute("SELECT 1 FROM pg_database WHERE datname = 'airflow'")
if cur.fetchone():
    print("Banco de metadados 'airflow' já existe.")
else:
    cur.execute("CREATE DATABASE airflow")
    print("Banco de metadados 'airflow' criado.")
cur.close()
conn.close()
