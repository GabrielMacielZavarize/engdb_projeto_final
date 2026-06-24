# Modelo Físico do Banco de Origem no Supabase

## Contexto

Este documento consolida a modelagem física do banco de origem do projeto no **Supabase (PostgreSQL)** com base no DER lógico documentado nos cards anteriores:

- [CARD-002 - Justificativa de Seleção de Atributos](./CARD-002_justificativa_selecao_atributos.md)
- [CARD-003 - DER Inicial Olist](./CARD-003_der_inicial_olist.md)
- Imagem de referência: `docs/imagens/der_logico.png`

O objetivo desta etapa é transformar o DER lógico em um schema executável, com chaves primárias, chaves estrangeiras, tipos e constraints suficientes para garantir integridade na carga da massa sintética.

## Estrutura física adotada

O banco foi organizado no schema `source`, que representa a camada transacional de origem dentro do projeto no Supabase.

As tabelas criadas são:

- `source.categories`
- `source.customers`
- `source.sellers`
- `source.products`
- `source.orders`
- `source.addresses`
- `source.payments`
- `source.reviews`
- `source.shipments`
- `source.order_items`

## Decisões de modelagem

O modelo físico segue o DER lógico e adiciona algumas proteções importantes para a carga:

- `reviews.order_id` e `shipments.order_id` possuem `UNIQUE` para preservar a cardinalidade `1:1`.
- `payments` preserva a identidade lógica por `payment_id`, mas também garante unicidade de `order_id + payment_sequential`.
- `order_items` preserva a chave lógica `order_item_id` como identificador global do item, o que exige valores únicos já na massa sintética gerada.
- `products.category_id` é opcional (`NULL`) porque a própria documentação do projeto indica que nem todo produto precisa ter categoria preenchida.
- Campos numéricos de valor, peso, dimensões e quantidade possuem checks de não negatividade.
- Todas as tabelas possuem `created_at` e `updated_at` para permitir detecção de mudanças na origem.
- O campo `updated_at` é mantido por trigger em updates comuns e também pode ser definido explicitamente pelos scripts de demonstração.

## Controles para carga incremental

A origem `source` precisa expor uma forma simples de identificar registros novos ou alterados.
Para isso, todas as tabelas carregadas pelo pipeline recebem as colunas:

- `created_at`: data/hora de criação do registro na origem;
- `updated_at`: data/hora da última alteração relevante do registro.

Essas colunas são criadas com `default current_timestamp`, possuem validação
`updated_at >= created_at` e são indexadas por `updated_at`. O DDL também cria
uma função/trigger para atualizar `updated_at` automaticamente quando um registro
for modificado sem informar um valor explícito.

Como a carga inicial usa arquivos CSV/JSON gerados a partir do dataset Olist,
`created_at` e `updated_at` não precisam existir nos arquivos de entrada. O
loader informa somente as colunas de negócio e o PostgreSQL preenche os campos
de controle pelos defaults.

## Chaves de negócio para SCD Tipo 2

As dimensões históricas definidas na camada Gold usam as seguintes chaves de
negócio:

| Dimensão Gold | Tabela(s) de origem | Chave de negócio | Atributos versionados principais |
| ------------- | ------------------- | ---------------- | -------------------------------- |
| `dim_customer` | `source.customers` | `customer_id` | `customer_unique_id`, CEP, cidade e UF |
| `dim_seller` | `source.sellers` | `seller_id` | CEP, cidade e UF |
| `dim_product` | `source.products` + `source.categories` | `product_id` | categoria, peso, fotos e dimensões físicas |
| `dim_date` | gerada na Gold | `date_sk` | dimensão estática de calendário |

Observação sobre clientes: o dataset Olist também possui `customer_unique_id`,
mas o modelo Gold atual usa `customer_id` como chave natural da `dim_customer`,
pois é a chave que relaciona diretamente clientes e pedidos no schema `source`.

Para os fatos, os grãos usados pela Gold continuam:

| Fato Gold | Tabela(s) de origem | Chave/grão |
| --------- | ------------------- | ---------- |
| `fact_orders` | `source.orders` + pagamentos agregados | `order_id` |
| `fact_order_items` | `source.order_items` | `order_item_id` |
| `fact_payments` | `source.payments` | `payment_id` |

## Arquivos versionados

Os artefatos da implementação ficaram organizados assim:

- DDL principal: [`sql/01_create_source_schema.sql`](https://github.com/GabrielMacielZavarize/engdb_projeto_final/blob/main/sql/01_create_source_schema.sql)
- Validação pós-carga: [`sql/02_validate_source_data.sql`](https://github.com/GabrielMacielZavarize/engdb_projeto_final/blob/main/sql/02_validate_source_data.sql)
- Cenário de mudanças para demo incremental: [`sql/03_seed_incremental_demo.sql`](https://github.com/GabrielMacielZavarize/engdb_projeto_final/blob/main/sql/03_seed_incremental_demo.sql)
- Geração da massa reduzida: [`scripts/build_reduced_source_data.ps1`](https://github.com/GabrielMacielZavarize/engdb_projeto_final/blob/main/scripts/build_reduced_source_data.ps1)
- Script de carga para Supabase/PostgreSQL: [`scripts/load_source_data.ps1`](https://github.com/GabrielMacielZavarize/engdb_projeto_final/blob/main/scripts/load_source_data.ps1)

## Estratégia de recorte da massa

Como o dataset original da Olist é maior do que o necessário para o trabalho, a carga no Supabase deve utilizar uma **massa reduzida, mas representativa**.

O script `build_reduced_source_data.ps1` foi pensado para isso:

- mira um volume mínimo total de `100.000` linhas somando as 10 tabelas;
- seleciona um subconjunto de pedidos com distribuição por mês, evitando concentrar tudo em um único ano ou período;
- preserva variedade de `order_status`, importante para filtros do dashboard;
- mantém os relacionamentos necessários entre pedidos, pagamentos, itens, produtos, vendedores e clientes;
- gera IDs técnicos compatíveis com o modelo físico para `addresses`, `payments`, `shipments` e `order_items`;
- exporta um `expected-counts.json` e um `selection-summary.json` para apoiar a validação da carga.

Na prática, o fluxo recomendado é:

1. baixar os CSVs do Kaggle para `data/raw/olist/`;
2. executar o script de geração da massa reduzida para produzir `data/source/`;
3. usar o loader para enviar `data/source/` ao Supabase.

## Contrato esperado para os arquivos de carga

O script espera uma pasta com um arquivo por entidade, em `CSV` ou `JSON`, usando os nomes abaixo:

- `categories`
- `customers`
- `sellers`
- `products`
- `orders`
- `addresses`
- `payments`
- `reviews`
- `shipments`
- `order_items`

Formatos aceitos:

- `nome_da_tabela.csv`
- `nome_da_tabela.json`
- `nome_da_tabela.jsonl`
- `nome_da_tabela.ndjson`

### Colunas esperadas por tabela

#### `categories`

- `category_id`
- `product_category_name`

#### `customers`

- `customer_id`
- `customer_unique_id`
- `customer_zip_code_prefix`
- `customer_city`
- `customer_state`

#### `sellers`

- `seller_id`
- `seller_zip_code_prefix`
- `seller_city`
- `seller_state`

#### `products`

- `product_id`
- `category_id`
- `product_name_length`
- `product_description_length`
- `product_photos_qty`
- `product_weight_g`
- `product_length_cm`
- `product_height_cm`
- `product_width_cm`

#### `orders`

- `order_id`
- `customer_id`
- `order_status`
- `order_purchase_timestamp`
- `order_approved_at`
- `order_delivered_carrier_date`
- `order_delivered_customer_date`
- `order_estimated_delivery_date`

#### `addresses`

- `address_id`
- `customer_id`
- `zip_code`
- `city`
- `state`

#### `payments`

- `payment_id`
- `order_id`
- `payment_sequential`
- `payment_type`
- `payment_installments`
- `payment_value`

#### `reviews`

- `review_id`
- `order_id`
- `review_score`
- `review_creation_date`
- `review_answer_timestamp`

#### `shipments`

- `shipment_id`
- `order_id`
- `shipment_status`
- `shipped_at`
- `delivered_at`

#### `order_items`

- `order_item_id`
- `order_id`
- `product_id`
- `seller_id`
- `shipping_limit_date`
- `price`
- `freight_value`

> As colunas `created_at` e `updated_at` fazem parte das tabelas no Supabase,
> mas não são obrigatórias nos arquivos de carga. Quando omitidas, recebem os
> valores definidos pelo banco.

## Como executar no Supabase

### Pré-requisitos

- Um projeto Supabase com acesso à string de conexão PostgreSQL.
- `psql` instalado na máquina cliente.
- Os arquivos da massa sintética em uma pasta local.

> **Onde achar a connection string (painel novo do Supabase):** botão verde
> **"Connect"** no topo do dashboard → seção **Session pooler**. A conexão
> direta (`db.<ref>.supabase.co`) hoje só resolve em **IPv6**; como o pipeline
> roda em containers Docker que saem por **IPv4**, padronizamos o uso do
> **pooler** (`aws-1-<regiao>.pooler.supabase.com`, porta `5432`), cujo usuário
> vem como `postgres.<project-ref>`.

### Exemplo de execução

```powershell
.\scripts\build_reduced_source_data.ps1 `
  -RawDir ".\data\raw\olist" `
  -OutputDir ".\data\source" `
  -TargetOrders 15000 `
  -MinimumTotalRows 100000

.\scripts\load_source_data.ps1 `
  -ConnectionString "postgresql://postgres.[PROJECT-REF]:[SENHA]@aws-1-sa-east-1.pooler.supabase.com:5432/postgres?sslmode=require" `
  -DataDir ".\data\source" `
  -ExpectedCountsFile ".\data\source\expected-counts.json"
```

O script:

1. aplica o DDL, caso necessário;
2. limpa as tabelas do schema `source`;
3. carrega os arquivos na ordem correta de dependência;
4. executa as validações SQL de integridade;
5. compara as contagens finais com um JSON opcional de volumes esperados.

## Como disparar o cenário de mudanças incrementais

Depois da primeira carga no Supabase, execute o seed de demonstração:

```powershell
psql `
  "postgresql://postgres.[PROJECT-REF]:[SENHA]@aws-1-sa-east-1.pooler.supabase.com:5432/postgres?sslmode=require" `
  -X `
  -v ON_ERROR_STOP=1 `
  -f ".\sql\03_seed_incremental_demo.sql"
```

O script `03_seed_incremental_demo.sql` prepara um cenário reproduzível:

- normaliza todos os registros existentes para o checkpoint base
  `2026-01-01 00:00:00`;
- aplica updates em cliente, vendedor, produto, pedido, pagamento e remessa com
  `updated_at = '2026-01-02 00:00:00'`;
- insere uma nova categoria, cliente, vendedor, produto, pedido, endereço,
  pagamento, avaliação, remessa e item de pedido;
- cria o pedido demo com `order_purchase_timestamp = '2019-01-15 10:00:00'`,
  posterior ao período original do Olist, para facilitar a demonstração de
  checkpoint dos fatos.

Consulta rápida para conferir o que mudou após o checkpoint base:

```sql
select 'customers' as table_name, count(*) as changed_rows
from source.customers
where updated_at > timestamp '2026-01-01 00:00:00'
union all
select 'sellers', count(*)
from source.sellers
where updated_at > timestamp '2026-01-01 00:00:00'
union all
select 'products', count(*)
from source.products
where updated_at > timestamp '2026-01-01 00:00:00'
union all
select 'orders', count(*)
from source.orders
where updated_at > timestamp '2026-01-01 00:00:00'
union all
select 'payments', count(*)
from source.payments
where updated_at > timestamp '2026-01-01 00:00:00'
order by table_name;
```

## Volume mínimo esperado para o trabalho

Para atender ao critério acadêmico de volume mínimo, a recomendação atual do projeto é gerar a massa com:

- `TargetOrders = 15000`
- `MinimumTotalRows = 100000`

Com essa configuração, o volume das tabelas maiores compensa naturalmente dimensões menores como `categories` e `sellers`, sem achatar o recorte temporal ou os filtros do dashboard.

## Formato do arquivo opcional de contagens esperadas

Caso a massa sintética seja gerada com volume conhecido, recomenda-se manter um arquivo `expected-counts.json` com estrutura semelhante a esta:

```json
{
  "categories": 71,
  "customers": 1000,
  "sellers": 200,
  "products": 500,
  "orders": 3000,
  "addresses": 1000,
  "payments": 3200,
  "reviews": 2500,
  "shipments": 3000,
  "order_items": 7800
}
```

## Validações implementadas

O arquivo `sql/02_validate_source_data.sql` executa:

- contagem de linhas por tabela;
- checagem das colunas de controle `created_at` e `updated_at`;
- checagem de relacionamentos órfãos;
- checagem de duplicidade indevida em relacionamentos `1:1`;
- checagem de duplicidade em `payments(order_id, payment_sequential)`;
- checagem de duplicidade em `order_items(order_id, order_item_id)`.

Se qualquer uma dessas validações retornar inconsistência, o processo encerra com erro.

## Observações

- O modelo físico foi desenhado para a **massa sintética aderente ao DER lógico**, e não para ingestão direta dos CSVs originais do dataset público da Olist.
- Identificadores como `address_id`, `payment_id`, `shipment_id` e `order_item_id` precisam existir nos arquivos gerados, porque fazem parte do modelo lógico adotado pelo projeto.
- Como o projeto utilizará Supabase, a carga foi implementada com `psql` e `\copy`, o que permite importar arquivos locais para um PostgreSQL remoto com `sslmode=require`.
- A conexão padronizada do projeto é via **Session pooler** (IPv4); a conexão direta do Supabase passou a ser IPv6-only e não funciona de dentro dos containers Docker do pipeline.
- O schema físico pode ser usado tanto no Supabase quanto em qualquer PostgreSQL compatível.
