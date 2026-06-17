# Especificação dos KPIs e Métricas do Dashboard

## Objetivo

Documentar as regras de negócio, os SQLs de referência e as tabelas da camada Gold necessárias para a construção do dashboard analítico da Olist no Metabase.

O dashboard seguirá o formato **One Page View**, com quatro KPIs e dois gráficos, conforme definido em `CARD-006_requisitos_dashboard.md`.

---

## Premissas gerais

* A camada Gold é a fonte oficial dos dados consumidos pelo dashboard.
* Os SQLs utilizam sintaxe compatível com o Trino.
* As consultas usam `gold` como nome de schema de referência. O prefixo deverá ser ajustado caso o catálogo ou schema publicado no Trino possua outro nome.
* Os indicadores financeiros utilizam `fact_orders.order_payment_value`, que já representa o valor total dos pagamentos agregado por pedido.
* Nesta primeira versão, os indicadores consideram todos os pedidos disponíveis na Gold. O status poderá ser restringido pelo filtro do dashboard.
* O Tempo Médio de Entrega considera somente pedidos entregues e com tempo de entrega preenchido.
* O Top 10 de Categorias é ordenado pela quantidade de itens vendidos. Cada linha de `fact_order_items` representa um item do pedido.

---

## 1. Receita Total

### Definição

Representa o valor total pago pelos pedidos disponíveis na camada Gold.

### Regra de negócio

```text
Receita Total = soma do valor total pago por pedido
```

### Fonte

* Fato: `fact_orders`
* Campo: `order_payment_value`

### SQL de referência

```sql
SELECT
    COALESCE(SUM(order_payment_value), 0) AS receita_total
FROM gold.fact_orders;
```

---

## 2. Quantidade de Pedidos

### Definição

Representa a quantidade total de pedidos únicos registrados na camada Gold.

### Regra de negócio

```text
Quantidade de Pedidos = contagem distinta de order_id
```

### Fonte

* Fato: `fact_orders`
* Campo: `order_id`

### SQL de referência

```sql
SELECT
    COUNT(DISTINCT order_id) AS quantidade_pedidos
FROM gold.fact_orders;
```

---

## 3. Ticket Médio

### Definição

Representa o valor médio pago por pedido.

### Regra de negócio

```text
Ticket Médio = Receita Total / Quantidade de Pedidos
```

### Fonte

* Fato: `fact_orders`
* Campos: `order_payment_value` e `order_id`

### SQL de referência

```sql
SELECT
    COALESCE(
        SUM(order_payment_value)
        / NULLIF(COUNT(DISTINCT order_id), 0),
        0
    ) AS ticket_medio
FROM gold.fact_orders;
```

---

## 4. Tempo Médio de Entrega

### Definição

Representa a média de dias entre a aprovação do pedido e a entrega ao cliente.

O campo `delivery_days` é calculado na Gold a partir de:

```text
order_delivered_customer_date - order_approved_at
```

### Regra de negócio

* Considerar somente pedidos entregues.
* Desconsiderar registros sem tempo de entrega.
* Apresentar o resultado em dias.

### Fonte

* Fato: `fact_orders`
* Campos: `delivery_days` e `is_delivered`

### SQL de referência

```sql
SELECT
    ROUND(AVG(CAST(delivery_days AS DOUBLE)), 2)
        AS tempo_medio_entrega_dias
FROM gold.fact_orders
WHERE is_delivered = TRUE
  AND delivery_days IS NOT NULL;
```

---

## 5. Vendas por Mês

### Definição

Apresenta a evolução mensal da receita, considerando o mês e o ano da compra.

### Regra de negócio

```text
Vendas por Mês = soma do valor pago, agrupada pelo mês da compra
```

### Fonte

* Fato: `fact_orders`
* Dimensão: `dim_date`
* Relacionamento: `fact_orders.date_sk = dim_date.date_sk`
* Campos: `order_payment_value` e `year_month`

### SQL de referência

```sql
SELECT
    d.year_month,
    COALESCE(SUM(f.order_payment_value), 0) AS receita_total
FROM gold.fact_orders AS f
INNER JOIN gold.dim_date AS d
    ON d.date_sk = f.date_sk
GROUP BY d.year_month
ORDER BY d.year_month;
```

### Visualização

Gráfico de linha ou de colunas, ordenado cronologicamente.

---

## 6. Top 10 Categorias Vendidas

### Definição

Apresenta as dez categorias com a maior quantidade de itens vendidos.

### Regra de negócio

```text
Quantidade Vendida = quantidade de linhas da fact_order_items por categoria
```

### Fonte

* Fato: `fact_order_items`
* Dimensão: `dim_product`
* Relacionamento: `fact_order_items.product_sk = dim_product.product_sk`
* Campo: `product_category_name`

### SQL de referência

```sql
SELECT
    p.product_category_name AS categoria,
    COUNT(*) AS quantidade_vendida
FROM gold.fact_order_items AS i
INNER JOIN gold.dim_product AS p
    ON p.product_sk = i.product_sk
WHERE p.is_current = TRUE
GROUP BY p.product_category_name
ORDER BY quantidade_vendida DESC
LIMIT 10;
```

### Visualização

Gráfico de barras horizontais, ordenado da categoria mais vendida para a menos vendida.

---

## Mapeamento de fatos e dimensões

| Indicador              | Fato principal     | Dimensões relacionadas     | Dados utilizados              |
| ---------------------- | ------------------ | -------------------------- | ----------------------------- |
| Receita Total          | `fact_orders`      | `dim_date`, `dim_customer` | Valor pago, período e cliente |
| Quantidade de Pedidos  | `fact_orders`      | `dim_date`, `dim_customer` | Pedido, período e cliente     |
| Ticket Médio           | `fact_orders`      | `dim_date`, `dim_customer` | Valor pago e pedido           |
| Tempo Médio de Entrega | `fact_orders`      | `dim_date`, `dim_customer` | Dias de entrega e status      |
| Vendas por Mês         | `fact_orders`      | `dim_date`                 | Valor pago e mês da compra    |
| Top 10 Categorias      | `fact_order_items` | `dim_product`, `dim_date`  | Item vendido e categoria      |

### Tabelas complementares para filtros

| Filtro            | Tabela e campo                      |
| ----------------- | ----------------------------------- |
| Período           | `dim_date.full_date`                |
| Categoria         | `dim_product.product_category_name` |
| Status do pedido  | `fact_orders.order_status`          |
| Estado do cliente | `dim_customer.customer_state`       |
| Tipo de pagamento | `fact_payments.payment_type`        |

---

## Cuidados na aplicação dos filtros

* Os filtros devem atualizar os KPIs e os gráficos de forma consistente.
* O filtro de categoria exige relacionar os itens e produtos aos pedidos.
* O filtro de tipo de pagamento exige relacionar `fact_payments` aos pedidos pelo campo `order_id`.
* Ao filtrar KPIs por categoria ou tipo de pagamento, devem ser utilizados pedidos distintos, evitando a duplicação de `order_payment_value`.
* Para o Top 10 de Categorias, o filtro de status exige o relacionamento entre `fact_order_items` e `fact_orders` pelo campo `order_id`.

---

## Resultado esperado

A especificação fornece o contrato inicial entre a camada Gold e o dashboard, contemplando:

* quatro KPIs com regras de negócio e SQLs de referência;
* duas métricas para visualização gráfica;
* mapeamento das tabelas fato e dimensões;
* identificação das tabelas necessárias para os filtros;
* cuidados para evitar duplicação de valores nas consultas.

---

## Referências do projeto

* `docs/dashboards/CARD-006_requisitos_dashboard.md`
* `docs/pipeline/CARD-038_camadas_pipeline.md`
* `notebooks/gold/gold_modelo_dimensional.ipynb`
* Épico relacionado: `#17`
* Sub-issue relacionada: `#25`
  ::: 
