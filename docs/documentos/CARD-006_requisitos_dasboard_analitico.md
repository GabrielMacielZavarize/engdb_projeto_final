# Requisitos do Dashboard Analítico

## Dashboard Proposto

Dashboard analítico baseado no dataset [[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce/data?select=olist_order_payments_dataset.csv)

A proposta é desenvolver um dashboard simples, objetivo e visualmente limpo, seguindo o padrão definido em sala de aula.

O dashboard terá apenas:

* 4 KPIs principais.
* 2 gráficos.
* Filtros básicos para análise.

A ideia não é criar um painel com muitas informações, cards ou gráficos. O foco é apresentar somente os principais indicadores do marketplace de forma clara e organizada.

## Objetivo

Apresentar uma visão geral do desempenho do marketplace Olist, permitindo acompanhar:

* Receita total.
* Quantidade de pedidos.
* Ticket médio.
* Tempo médio de entrega.
* Vendas por mês.
* Categorias mais vendidas.

## Base de Dados

O dashboard será construído a partir das principais tabelas do dataset Olist:

* `olist_orders_dataset.csv`
* `olist_order_payments_dataset.csv`
* `olist_order_items_dataset.csv`
* `olist_products_dataset.csv`
* `product_category_name_translation.csv`
* `olist_customers_dataset.csv`

Essas tabelas serão utilizadas para calcular os indicadores, relacionar pedidos com pagamentos, produtos, categorias e informações dos clientes.

## KPIs do Dashboard

A primeira versão do dashboard terá apenas quatro KPIs.

### KPI 1 - Receita Total

Exibe o valor total arrecadado com os pedidos.

* **Fonte:** `olist_order_payments_dataset.csv`
* **Campo:** `payment_value`
* **Cálculo:** soma dos valores pagos.

Exemplo:

```text id="4l0i6g"
R$ 25.430,00
```

### KPI 2 - Quantidade de Pedidos

Exibe o total de pedidos realizados.

* **Fonte:** `olist_orders_dataset.csv`
* **Campo:** `order_id`
* **Cálculo:** contagem distinta de pedidos.

Exemplo:

```text id="tezzin"
1.245 pedidos
```

### KPI 3 - Ticket Médio

Exibe o valor médio gasto por pedido.

* **Fontes:** `olist_order_payments_dataset.csv` e `olist_orders_dataset.csv`
* **Cálculo:** receita total dividida pela quantidade de pedidos.

```text id="6ld3xe"
Ticket Médio = Receita Total / Quantidade de Pedidos
```

Exemplo:

```text id="8z7k20"
R$ 120,50
```

### KPI 4 - Tempo Médio de Entrega

Exibe o tempo médio de entrega dos pedidos.

* **Fonte:** `olist_orders_dataset.csv`
* **Campos:** `order_approved_at` e `order_delivered_customer_date`
* **Cálculo:** média da diferença entre a data de entrega e a data de aprovação.

Exemplo:

```text id="rjz3ik"
12 dias
```

## Gráficos do Dashboard

A primeira versão terá apenas dois gráficos.

### Gráfico 1 - Vendas por Mês

Mostra a evolução das vendas ao longo do tempo.

* **Métrica:** receita total.
* **Dimensão:** mês e ano da compra.
* **Visualização:** gráfico de linha ou coluna.

### Gráfico 2 - Top 10 Categorias Vendidas

Mostra as dez categorias com maior volume de vendas.

* **Métrica:** quantidade vendida.
* **Dimensão:** categoria do produto.
* **Visualização:** gráfico de barras horizontais.

## Filtros

O dashboard poderá conter filtros simples para facilitar a análise.

Filtros previstos:

* Período.
* Categoria.
* Status do pedido.
* Estado do cliente.
* Tipo de pagamento.

## Layout Inicial

O dashboard será desenvolvido no formato **One Page View**, com todos os elementos principais em uma única tela.

Estrutura prevista:

* Cabeçalho com título e filtros.
* Linha com os 4 KPIs principais.
* Área com os 2 gráficos principais.

## Esboço Inicial

![DER Preliminar](../imagens/imagem_layout_dashboard.png)

## Requisitos Funcionais

### RF01 - Exibir Receita Total

O dashboard deve exibir a receita total conforme os filtros aplicados.

### RF02 - Exibir Quantidade de Pedidos

O dashboard deve exibir a quantidade total de pedidos.

### RF03 - Exibir Ticket Médio

O dashboard deve exibir o ticket médio dos pedidos.

### RF04 - Exibir Tempo Médio de Entrega

O dashboard deve exibir o tempo médio de entrega dos pedidos.

### RF05 - Exibir Vendas por Mês

O dashboard deve apresentar um gráfico com as vendas agrupadas por mês.

### RF06 - Exibir Top 10 Categorias Vendidas

O dashboard deve apresentar um gráfico com as dez categorias mais vendidas.

### RF07 - Permitir Aplicação de Filtros

O dashboard deve permitir aplicar filtros básicos aos KPIs e gráficos.

### RF08 - Atualizar Dados Conforme Filtros

Ao aplicar filtros, os KPIs e gráficos devem ser atualizados automaticamente.

## Observações

O dashboard deve ser simples, direto e sem excesso de informações.

A primeira versão deverá conter somente os quatro KPIs e os dois gráficos definidos neste documento. Outros cards, gráficos, tabelas ou análises complementares poderão ser avaliados apenas futuramente.

Os valores exibidos deverão estar alinhados com as transformações da camada Gold do Data Warehouse.

## Pontos para Validação

* Confirmar se pedidos cancelados serão removidos dos cálculos.
* Confirmar como será calculado o tempo médio de entrega.
* Confirmar se o Top 10 categorias será ordenado por quantidade vendida.
* Validar se os filtros definidos estarão disponíveis na camada Gold.
* Validar se o layout segue o padrão definido em sala de aula.

## Documentação

- [requisitos_dashboard_analitico_olist.pdf](https://github.com/user-attachments/files/28807209/requisitos_dashboard_analitico_olist.pdf)