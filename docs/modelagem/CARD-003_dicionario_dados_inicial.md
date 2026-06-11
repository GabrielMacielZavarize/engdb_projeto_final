# Dicionário de Dados Inicial — Dataset Olist

## Objetivo

Este documento apresenta o dicionário de dados inicial elaborado a partir do dataset público da Olist.

O objetivo é documentar as principais entidades identificadas no modelo transacional, suas finalidades de negócio e os relacionamentos que servirão de base para a construção do banco de dados, Data Lake e Data Warehouse do projeto.

---

# Tabelas Identificadas

As seguintes entidades foram consideradas durante a modelagem inicial:

| Tabela                            |
| --------------------------------- |
| customers                         |
| geolocation                       |
| orders                            |
| order_items                       |
| order_payments                    |
| order_reviews                     |
| products                          |
| sellers                           |
| product_category_name_translation |
| entregas                          |

---

# Finalidade das Entidades

## customers

Armazena informações relacionadas aos clientes cadastrados na plataforma.

### Finalidade

Permitir identificação dos clientes e análises futuras relacionadas ao comportamento de compra e segmentação geográfica.

---

## geolocation

Contém informações geográficas associadas aos prefixos de CEP.

### Finalidade

Apoiar análises regionais e enriquecimento de dados de localização.

---

## orders

Armazena os pedidos realizados pelos clientes.

### Finalidade

Representar o ciclo de vida das compras realizadas na plataforma.

---

## order_items

Contém o detalhamento dos produtos presentes em cada pedido.

### Finalidade

Representar o nível transacional das vendas.

---

## order_payments

Armazena informações sobre os pagamentos realizados.

### Finalidade

Suportar análises financeiras e validação dos indicadores de receita.

---

## order_reviews

Contém as avaliações realizadas pelos clientes.

### Finalidade

Permitir análises relacionadas à satisfação dos consumidores.

---

## products

Armazena informações dos produtos comercializados.

### Finalidade

Suportar análises por produto e categoria.

---

## sellers

Contém informações dos vendedores cadastrados na plataforma.

### Finalidade

Permitir análises de desempenho comercial e distribuição geográfica.

---

## product_category_name_translation

Tabela responsável pela tradução das categorias dos produtos.

### Finalidade

Padronizar e facilitar análises por categoria.

---

## entregas

Entidade derivada a partir dos dados de pedidos.

### Finalidade

Representar o processo logístico e permitir análises relacionadas à entrega.

---

# Estrutura Documentada

Para cada entidade foram identificados:

* Colunas principais;
* Tipos de dados sugeridos;
* Chaves primárias;
* Chaves estrangeiras;
* Relacionamentos.

Essas definições servirão como base para a construção do modelo lógico e físico do banco de dados.

---

# Observações

## Tabela Entregas

A tabela `entregas` foi modelada como uma entidade derivada de `orders`.

Essa tabela não existe originalmente no dataset público da Olist, mas foi criada para representar de forma explícita o processo logístico e atender aos requisitos analíticos do projeto.

---

## Geolocalização

Os relacionamentos envolvendo a tabela `geolocation` foram tratados como relacionamentos lógicos baseados em prefixo de CEP.

Isso ocorre porque o atributo `geolocation_zip_code_prefix` não possui unicidade garantida no dataset original.

---

## Categorias de Produtos

A relação entre:

* `products.product_category_name`
* `product_category_name_translation.product_category_name`

foi considerada lógica e opcional.

Foram identificados casos de:

* Produtos sem categoria definida;
* Categorias sem tradução correspondente.

---

# Documento

- [Dicionário de Dados Inicial — Olist](https://github.com/user-attachments/files/28782359/dicionario_dados_olist.pdf)
