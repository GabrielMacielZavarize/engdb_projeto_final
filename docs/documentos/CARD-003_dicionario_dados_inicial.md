## Entrega da tarefa — Dicionário de Dados Inicial e DER Olist

Foi elaborado o dicionário de dados inicial do dataset público da Olist, contemplando as tabelas identificadas no modelo transacional:

- `customers`
- `geolocation`
- `orders`
- `order_items`
- `order_payments`
- `order_reviews`
- `products`
- `sellers`
- `product_category_name_translation`
- `entregas`

Também foi criado o Diagrama Entidade-Relacionamento (DER) com base no dicionário de dados e nas relações identificadas entre as tabelas.

### Arquivos anexados nesta issue

- [Dicionário de Dados Inicial — Olist](https://github.com/user-attachments/files/28782359/dicionario_dados_olist.pdf)
- [Diagrama Entidade-Relacionamento — Olist](https://github.com/user-attachments/files/28782442/diagrama.entidade.e.relacionamento.pdf)

### Observações importantes

A tabela `entregas` foi modelada como tabela derivada de `orders`, pois não existe como arquivo CSV original no dataset público da Olist, mas foi citada no escopo da tarefa.

Os relacionamentos com `geolocation` foram tratados como relacionamentos lógicos por prefixo de CEP, pois `geolocation_zip_code_prefix` não é único no arquivo original.

A relação entre `products.product_category_name` e `product_category_name_translation.product_category_name` também foi tratada como lógica/opcional, pois existem produtos sem categoria e categorias sem tradução na base bruta.

### Status

Critérios de aceite atendidos:

- Todas as tabelas do dataset Olist foram documentadas.
- As finalidades de negócio das tabelas foram descritas.
- As colunas principais foram descritas com tipos de dados sugeridos.
- Chaves primárias, estrangeiras e relacionamentos foram identificados.
- O DER inicial foi criado para apoiar as próximas etapas de modelagem.