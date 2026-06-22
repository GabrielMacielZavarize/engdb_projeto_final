-- Registra as tabelas Delta da camada Gold no catálogo `delta` do Trino — issue #46.
-- Executar uma vez após subir o serving e ter a Gold populada pelo pipeline:
--   docker compose exec -T trino trino < docker/trino/register_gold_tables.sql
-- (Idempotente: IF NOT EXISTS no schema; re-registrar uma tabela já registrada dá erro,
--  então use system.unregister_table antes se precisar reapontar.)

-- Schema SEM location explícito: o Hive Metastore não acessa o S3, então deixamos
-- o location default (local, inofensivo). O que importa é o `table_location` s3://
-- de cada tabela no register_table abaixo — quem lê o S3 é o Trino.
CREATE SCHEMA IF NOT EXISTS delta.gold;

CALL delta.system.register_table(schema_name => 'gold', table_name => 'dim_date',        table_location => 's3a://datalake/gold/olist/dim_date');
CALL delta.system.register_table(schema_name => 'gold', table_name => 'dim_customer',    table_location => 's3a://datalake/gold/olist/dim_customer');
CALL delta.system.register_table(schema_name => 'gold', table_name => 'dim_seller',      table_location => 's3a://datalake/gold/olist/dim_seller');
CALL delta.system.register_table(schema_name => 'gold', table_name => 'dim_product',     table_location => 's3a://datalake/gold/olist/dim_product');
CALL delta.system.register_table(schema_name => 'gold', table_name => 'fact_orders',     table_location => 's3a://datalake/gold/olist/fact_orders');
CALL delta.system.register_table(schema_name => 'gold', table_name => 'fact_order_items',table_location => 's3a://datalake/gold/olist/fact_order_items');
CALL delta.system.register_table(schema_name => 'gold', table_name => 'fact_payments',   table_location => 's3a://datalake/gold/olist/fact_payments');

-- Conferência rápida:
SHOW TABLES FROM delta.gold;
