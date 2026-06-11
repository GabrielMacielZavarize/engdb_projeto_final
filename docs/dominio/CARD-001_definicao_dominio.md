# Definição do Domínio e Escopo do Projeto

## Visão Geral

Antes do desenvolvimento da arquitetura de dados, foi necessário definir o domínio de negócio que serviria como base para todas as etapas do projeto.

A escolha do domínio considerou os requisitos da disciplina, a disponibilidade de dados, a viabilidade técnica de implementação e a capacidade de gerar indicadores analíticos relevantes para a construção do dashboard final.

O domínio definido servirá como referência para a modelagem do banco transacional, construção do Data Lake, implementação das transformações de dados e desenvolvimento do modelo dimensional.

## Análise do Dataset

### Dataset Escolhido

Brazilian E-Commerce Public Dataset by Olist

### Objetivo

Utilizar dados de um marketplace para a construção de uma arquitetura de Engenharia de Dados contemplando:

- Ingestão de dados
- Armazenamento em Data Lake
- Processamento utilizando Apache Spark
- Modelagem dimensional
- Construção de dashboards analíticos

### Principais Entidades

| Entidade | Fonte | Registros |
| --- | --- | --- |
| Clientes | olist_customers_dataset.csv | 99.441 |
| Pedidos | olist_orders_dataset.csv | 99.441 |
| Produtos | olist_products_dataset.csv | 32.951 |
| Vendedores | olist_sellers_dataset.csv | 3.095 |
| Pagamentos | olist_order_payments_dataset.csv | 99.440 |
| Avaliações | olist_order_reviews_dataset.csv | 98.410 |
| Entregas | Tabela derivada | A definir |
| Categorias | product_category_name_translation.csv | 71 |
| Endereços | olist_geolocation_dataset.csv | 1.000.163 |
| Itens do Pedido | olist_order_items_dataset.csv | 98.666 |

### Justificativa da Escolha

O dataset Olist foi selecionado por representar um cenário real de comércio eletrônico, contendo informações sobre clientes, pedidos, produtos, pagamentos, avaliações e logística.

Além disso, apresenta um volume significativo de dados, permitindo a construção de pipelines de processamento e análises de negócio compatíveis com os requisitos do projeto.

## Indicadores Preliminares

### KPIs

- **KPI 1 - Receita Total**: Valor total arrecadado considerando todos os pagamentos realizados.
- **KPI 2 - Quantidade de Pedidos**: Total de pedidos registrados na plataforma.
- **KPI 3 - Ticket Médio**: Valor médio gasto por pedido.
- **KPI 4 - Tempo Médio de Entrega**: Tempo médio entre a aprovação do pedido e sua entrega ao cliente.

### Métricas

- **Métrica 1 - Vendas por Mês**: Análise temporal da evolução das vendas ao longo do período disponível.
- **Métrica 2 - Top 10 Categorias Vendidas**: Ranking das categorias com maior volume de vendas.

## Observações

O dataset original possui nove tabelas principais.

Para atender aos requisitos do projeto, serão criadas entidades complementares derivadas dos dados existentes, como a tabela de entregas, permitindo a expansão do modelo transacional e a construção do Data Warehouse.

## Definição do Domínio

### Descrição do Negócio

O projeto consiste na implementação de uma arquitetura de Engenharia de Dados baseada em um marketplace de comércio eletrônico inspirado na Olist.

A plataforma conecta clientes, vendedores e produtos em um ambiente de vendas online, permitindo que consumidores realizem compras através do marketplace enquanto vendedores disponibilizam seus produtos para comercialização.

O sistema registra todas as etapas da jornada de compra, incluindo:

- Cadastro de clientes
- Realização de pedidos
- Processamento de pagamentos
- Envio de produtos
- Entregas
- Avaliações realizadas pelos consumidores

Os dados gerados serão utilizados para alimentar um ambiente analítico capaz de fornecer indicadores estratégicos sobre:

- Vendas
- Desempenho logístico
- Comportamento dos clientes
- Performance dos vendedores

### Fluxo Operacional do Negócio


![Fluxo Operacional](../imagens/fluxo_operacional.jpeg)

### Regras de Negócio

- Um cliente pode realizar vários pedidos.
- Um pedido pode conter um ou mais produtos.
- Um produto pertence a uma categoria.
- Um vendedor pode vender diversos produtos.
- Um pedido deve possuir ao menos um pagamento associado.
- Um pedido pode receber uma avaliação após a entrega.
- Cada entrega está associada a um pedido.
- O tempo de entrega será calculado utilizando as datas de aprovação e entrega do pedido.

## DER Preliminar

O diagrama abaixo representa as principais entidades identificadas no domínio de negócio do projeto e seus relacionamentos iniciais.

O modelo foi elaborado com base na análise do dataset Olist e servirá como referência para as etapas posteriores de modelagem lógica e física do banco de dados.

![DER Preliminar](../imagens/der_preliminar.png)

### Principais Relacionamentos

- Um cliente pode realizar vários pedidos.
- Um cliente pode possuir um ou mais endereços.
- Um pedido pode conter um ou mais itens.
- Cada item de pedido está associado a um produto e a um vendedor.
- Um produto pertence a uma única categoria.
- Um pedido pode possuir um ou mais pagamentos.
- Um pedido pode receber uma avaliação após sua conclusão.
- Um pedido possui informações relacionadas ao processo de entrega.

### Finalidade do DER

O DER preliminar tem como objetivo fornecer uma visão inicial da estrutura de dados do projeto, facilitando a compreensão das entidades de negócio e servindo como base para:

- Implementação do banco transacional
- Construção do Data Lake
- Desenvolvimento do modelo dimensional
- Construção dos dashboards analíticos

## Artefatos Relacionados

### Documentos

- [Análise do Dataset.pdf](https://github.com/user-attachments/files/28689848/Analise.do.Dataset.pdf)
- [Definição do Domínio.pdf](https://github.com/user-attachments/files/28690145/Definicao.do.Dominio.pdf)
- [DER - Preliminar.pdf](https://github.com/user-attachments/files/28690540/DER.-.Preliminar.pdf)

### Imagens

- Fluxo Operacional do Negócio
- DER Preliminar
