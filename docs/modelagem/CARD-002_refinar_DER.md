# Justificativa da Seleção de Atributos no DER Lógico

## Contexto

Durante a evolução do DER preliminar para a versão lógica do modelo de dados, optou-se por não incluir todas as colunas disponíveis no dataset Olist.

A seleção dos atributos foi realizada com base nos objetivos do projeto, nas regras de negócio definidas e nos indicadores analíticos que serão construídos nas etapas posteriores do pipeline de dados.

O objetivo desta decisão foi manter o modelo mais legível, facilitar o entendimento do domínio e destacar apenas os atributos com relevância operacional e analítica.

---

## DER Lógico




![DER Lógico](../imagens/der_logico.png)


---

# Critérios de Seleção dos Atributos

A definição dos atributos seguiu os seguintes critérios:

* Relevância para o domínio de negócio;
* Suporte aos indicadores analíticos definidos;
* Necessidade para construção do modelo dimensional;
* Manutenção da legibilidade do modelo;
* Redução de complexidade desnecessária.

Foram priorizados atributos que contribuem diretamente para análises de vendas, clientes, logística e desempenho comercial.

---

# Entidades e Justificativas

## Customers

Foram mantidos os atributos relacionados à identificação e localização dos clientes.

### Justificativa

Essas informações poderão ser utilizadas futuramente em:

* Análises geográficas;
* Segmentação de clientes;
* Construção de dimensões analíticas.

---

## Orders

Foram mantidos os atributos relacionados ao ciclo de vida do pedido e às datas do processo de compra.

### Justificativa

Esses campos são fundamentais para:

* Quantidade de pedidos;
* Análise temporal das vendas;
* Tempo médio de entrega;
* Construção da dimensão tempo.

---

## Order Items

Foram mantidos os atributos relacionados aos produtos vendidos e aos valores financeiros.

### Justificativa

Esta entidade representa o detalhamento das vendas e servirá como uma das principais fontes para:

* Receita total;
* Ticket médio;
* Volume comercializado;
* Indicadores de vendas.

---

## Products

Foram mantidos atributos relacionados à categorização e características físicas dos produtos.

### Justificativa

Essas informações permitem:

* Análises por categoria;
* Agrupamento de produtos;
* Possíveis análises logísticas relacionadas ao peso e dimensões.

---

## Categories

Foram mantidos o identificador e o nome da categoria.

### Justificativa

Necessário para:

* Análises por categoria;
* Ranking de categorias;
* Métrica Top 10 Categorias Vendidas.

---

## Sellers

Foram mantidos os atributos de identificação e localização dos vendedores.

### Justificativa

Permitem análises futuras relacionadas a:

* Participação dos vendedores nas vendas;
* Distribuição geográfica dos vendedores;
* Desempenho regional.

---

## Payments

Foram mantidos os atributos relacionados ao método e valor do pagamento.

### Justificativa

Esses campos serão utilizados em:

* Indicadores financeiros;
* Validação da receita;
* Análise de meios de pagamento.

---

## Reviews

Foram mantidos os atributos relacionados à avaliação dos pedidos.

### Justificativa

Permitem análises futuras de:

* Satisfação dos clientes;
* Qualidade do serviço;
* Avaliação da experiência de compra.

---

## Addresses

A entidade foi criada como complemento ao modelo transacional.

### Justificativa

Possibilita representar informações de localização dos clientes de forma organizada e alinhada às necessidades analíticas do projeto.

---

## Shipments

A entidade foi criada a partir dos dados de pedidos para representar o processo logístico.

### Justificativa

Sua inclusão facilita o entendimento do fluxo operacional e possibilita análises relacionadas ao processo de entrega.

---

# Referência do Dataset Original

Durante a etapa de modelagem foi utilizada como referência a estrutura de relacionamentos disponibilizada pela Olist.



![Modelo Original Olist](../imagens/modelo_original_olist.png)


---

## Adaptação para o Projeto

A partir da estrutura original disponibilizada pela Olist, foi desenvolvido um DER adaptado às necessidades do domínio definido pela equipe.

As adaptações realizadas tiveram como objetivo:

* Adequar o modelo aos requisitos da disciplina;
* Facilitar a construção do Data Warehouse;
* Atender aos KPIs e métricas definidos;
* Melhorar a legibilidade da documentação;
* Simplificar a implementação do pipeline de dados.

---

# Conclusão

A seleção dos atributos foi realizada de forma estratégica, buscando equilibrar simplicidade, clareza e capacidade analítica.

O modelo resultante mantém todas as informações necessárias para suportar os indicadores de negócio definidos no projeto, ao mesmo tempo em que reduz a complexidade do modelo transacional e facilita sua evolução para as camadas analíticas do Data Lake e Data Warehouse.
