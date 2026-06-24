-- ==========================================================================
-- Dashboard Olist — One Page : SQLs finais dos 6 cards
-- Banco no Metabase: "Olist Gold - Trino"  (engine Starburst, catálogo delta, schema gold)
-- Cada bloco corresponde a uma pergunta (card) montada manualmente no Metabase.
-- ==========================================================================

-- --------------------------------------------------------------------------
-- 1) Receita Total
-- --------------------------------------------------------------------------
SELECT
  COALESCE(SUM(order_payment_value), 0) AS receita_total
FROM delta.gold.fact_orders;

-- --------------------------------------------------------------------------
-- 2) Quantidade de Pedidos
-- --------------------------------------------------------------------------
SELECT
  COUNT(DISTINCT order_id) AS quantidade_pedidos
FROM delta.gold.fact_orders;

-- --------------------------------------------------------------------------
-- 3) Ticket Médio
-- --------------------------------------------------------------------------
SELECT
  COALESCE(
    SUM(order_payment_value)
    / NULLIF(COUNT(DISTINCT order_id), 0),
    0
  ) AS ticket_medio
FROM delta.gold.fact_orders;

-- --------------------------------------------------------------------------
-- 4) Tempo Médio de Entrega
-- --------------------------------------------------------------------------
SELECT
  ROUND(AVG(CAST(delivery_days AS DOUBLE)), 2)
    AS tempo_medio_entrega_dias
FROM delta.gold.fact_orders
WHERE is_delivered = TRUE
  AND delivery_days IS NOT NULL;

-- --------------------------------------------------------------------------
-- 5) Vendas por Mês
-- --------------------------------------------------------------------------
SELECT
  d.year_month,
  COALESCE(SUM(f.order_payment_value), 0) AS receita_total
FROM delta.gold.fact_orders AS f
INNER JOIN delta.gold.dim_date AS d
  ON d.date_sk = f.date_sk
GROUP BY d.year_month
ORDER BY d.year_month;

-- --------------------------------------------------------------------------
-- 6) Top 10 Categorias Vendidas
-- --------------------------------------------------------------------------
SELECT
  p.product_category_name AS categoria,
  COUNT(*) AS quantidade_vendida
FROM delta.gold.fact_order_items AS i
INNER JOIN delta.gold.dim_product AS p
  ON p.product_sk = i.product_sk
WHERE p.is_current = TRUE
GROUP BY p.product_category_name
ORDER BY quantidade_vendida DESC
LIMIT 10;
