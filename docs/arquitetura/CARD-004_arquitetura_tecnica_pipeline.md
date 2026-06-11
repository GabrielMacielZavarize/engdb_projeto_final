# Definição da Arquitetura Técnica da Solução

## Contexto

Para a construção do pipeline de dados baseado no dataset Olist, foi definida uma arquitetura em camadas seguindo o modelo Medalhão: Landing, Bronze, Silver e Gold.

Essa abordagem foi escolhida por separar claramente os dados brutos, os dados padronizados, os dados tratados e os dados preparados para análise. Com isso, o pipeline torna-se mais organizado, rastreável e de fácil manutenção ao longo do desenvolvimento do projeto.

O objetivo desta decisão é definir uma base técnica simples, reproduzível e adequada ao escopo acadêmico do trabalho, evitando complexidade desnecessária.

---

# Arquitetura Medalhão

Foi adotada a arquitetura Medalhão como padrão lógico para organização do pipeline de dados.

## Justificativa

A arquitetura Medalhão facilita a separação das responsabilidades de cada etapa do processamento de dados, permitindo uma evolução gradual do pipeline e melhor rastreabilidade dos dados.

### Benefícios

* Separação clara entre dados brutos e dados analíticos;
* Facilidade de manutenção;
* Reprocessamento simplificado;
* Melhor organização das transformações;
* Maior controle de qualidade dos dados.

---

# Camadas do Pipeline

## Landing

Responsável pelo armazenamento dos arquivos originais do dataset Olist sem qualquer transformação.

### Objetivo

Preservar os dados originais para auditoria, rastreabilidade e reprocessamento.

### Características

* Dados brutos;
* Sem alterações;
* Fonte única da verdade.

---

## Bronze

Responsável pelo armazenamento dos dados convertidos para um formato adequado ao processamento.

### Objetivo

Padronizar minimamente os dados para consumo pelas etapas seguintes.

### Características

* Estrutura próxima à origem;
* Conversão para formato analítico;
* Sem regras de negócio complexas.

---

## Silver

Responsável pelos dados tratados, consistentes e integrados.

### Objetivo

Aplicar regras de qualidade e transformação.

### Principais Processamentos

* Tratamento de valores nulos;
* Conversão de tipos;
* Remoção de inconsistências;
* Integração entre entidades;
* Padronização de atributos.

---

## Gold

Responsável pela disponibilização dos dados para consumo analítico.

### Objetivo

Disponibilizar tabelas prontas para dashboards, relatórios e análises.

### Características

* Dados agregados;
* Indicadores calculados;
* Visões analíticas;
* Estruturas otimizadas para consulta.

---

# Tecnologias Definidas

## Apache Spark

Ferramenta principal para processamento dos dados.

### Justificativa

O Apache Spark é amplamente utilizado em projetos de Engenharia de Dados e permite processar grandes volumes de dados de forma distribuída.

Mesmo que o volume do dataset Olist seja moderado, sua utilização aproxima o projeto de cenários encontrados no mercado.

---

## Python e PySpark

Linguagem e framework escolhidos para implementação das transformações.

### Justificativa

* Facilidade de desenvolvimento;
* Grande adoção no mercado;
* Integração nativa com Spark;
* Curva de aprendizado adequada para a equipe.

---

## Formato Parquet

Formato principal de armazenamento para as camadas processadas.

### Justificativa

* Formato colunar;
* Leitura eficiente;
* Compressão otimizada;
* Excelente integração com Spark.

---

## Docker

Ferramenta utilizada para padronização do ambiente de desenvolvimento.

### Justificativa

O Docker permite que todos os integrantes utilizem o mesmo ambiente de execução, reduzindo problemas de configuração e dependências.

---

# Orquestração

Foram consideradas as seguintes ferramentas:

* Apache Airflow
* Prefect

## Justificativa

### Airflow

* Ferramenta consolidada no mercado;
* Grande comunidade;
* Forte aderência a projetos de Engenharia de Dados.

### Prefect

* Configuração simplificada;
* Boa opção para ambientes locais;
* Menor complexidade operacional.

A escolha definitiva será realizada durante a implementação do pipeline.

---

# Visualização e Consumo Analítico

As seguintes ferramentas foram consideradas para construção dos dashboards:

* Metabase
* Apache Superset
* Power BI

## Justificativa

Todas permitem consumir dados da camada Gold e construir visualizações para análise dos resultados do projeto.

---

# Fluxo Proposto

```text
Dataset Olist
        ↓
Landing
        ↓
Bronze
        ↓
Silver
        ↓
Gold
        ↓
Dashboard / BI
```

---

# Recomendações Técnicas

* Utilizar Apache Spark com PySpark para processamento.
* Utilizar formato Parquet nas camadas Bronze, Silver e Gold.
* Preservar os arquivos originais na camada Landing.
* Separar scripts de ingestão, transformação e publicação.
* Implementar validações básicas de qualidade de dados.
* Registrar logs de execução.
* Priorizar simplicidade e reprodutibilidade da solução.

---

# Validação da Arquitetura

A arquitetura proposta atende aos requisitos do projeto ao definir:

* Fluxo completo de processamento;
* Camadas de armazenamento;
* Tecnologias principais;
* Estratégia de transformação dos dados;
* Alternativas de orquestração;
* Alternativas de visualização.

Com essa definição, a equipe possui uma base sólida para iniciar a implementação do pipeline de dados e das etapas analíticas previstas no projeto.

---

# Artefatos Relacionados

* DER Preliminar
* DER Lógico
* Dicionário de Dados
* Definição do Domínio
* Requisitos do Dashboard
