#  Análise do Dataset

## Dataset Escolhido

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce/data?select=olist_order_payments_dataset.csv)

## Objetivo

Utilizar dados de um marketplace para a construção de uma arquitetura de Engenharia de Dados, contemplando ingestão, armazenamento em Data Lake, transformações com Spark, modelagem dimensional e visualização de indicadores em dashboard.

## Principais Entidades

* **Clientes**

  * Fonte: `olist_customers_dataset.csv`
  * Registros: 99.441

* **Pedidos**

  * Fonte: `olist_orders_dataset.csv`
  * Registros: 99.441

* **Produtos**

  * Fonte: `olist_products_dataset.csv`
  * Registros: 32.951

* **Vendedores**

  * Fonte: `olist_sellers_dataset.csv`
  * Registros: 3.095

* **Pagamentos**

  * Fonte: `olist_order_payments_dataset.csv`
  * Registros: 99.440

* **Avaliações**

  * Fonte: `olist_order_reviews_dataset.csv`
  * Registros: 98.410

* **Entregas**

  * Fonte: Tabela derivada a partir dos dados de pedidos
  * Registros: A definir

* **Categorias**

  * Fonte: `product_category_name_translation.csv`
  * Registros: 71

* **Endereços**

  * Fonte: `olist_geolocation_dataset.csv`
  * Registros: 1.000.163

* **Itens do Pedido**

  * Fonte: `olist_order_items_dataset.csv`
  * Registros: 98.666

## Justificativa da Escolha

O dataset Olist foi selecionado por representar um cenário real de comércio eletrônico, contendo informações sobre clientes, pedidos, produtos, pagamentos, avaliações e logística. Além disso, apresenta um volume significativo de dados, permitindo a construção de pipelines de processamento e análises de negócio compatíveis com os requisitos do projeto.

## Sugestão de KPIs

### KPI 1 - Receita Total

Valor total arrecadado considerando todos os pagamentos realizados.

### KPI 2 - Quantidade de Pedidos

Total de pedidos registrados na plataforma.

### KPI 3 - Ticket Médio

Valor médio gasto por pedido.

### KPI 4 - Tempo Médio de Entrega

Tempo médio entre a aprovação do pedido e sua entrega ao cliente.

## Sugestão de Métricas

### Métrica 1 - Vendas por Mês

Análise temporal da evolução das vendas ao longo do período disponível.

### Métrica 2 - Top 10 Categorias Vendidas

Ranking das categorias com maior volume de vendas.

## Observações

O dataset original possui nove tabelas principais. Para atender aos requisitos do projeto, serão criadas entidades complementares derivadas dos dados existentes, como a tabela de Entregas, permitindo a expansão do modelo transacional e a construção do Data Warehouse.

## Documento

[Análise do Dataset.pdf](https://github.com/user-attachments/files/28689848/Analise.do.Dataset.pdf)






