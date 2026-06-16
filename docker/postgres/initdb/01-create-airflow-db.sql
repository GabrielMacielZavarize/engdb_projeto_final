-- Cria o banco de metadados do Airflow no PostgreSQL do projeto, se ainda
-- não existir. Executado automaticamente pelo entrypoint do PostgreSQL na
-- primeira inicialização do volume (issue #30).
SELECT 'CREATE DATABASE airflow'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'airflow')\gexec
