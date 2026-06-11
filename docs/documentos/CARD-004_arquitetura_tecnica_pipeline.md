# Definição da Arquitetura Técnica da Solução

## Contexto

Para a construção do pipeline de dados baseado no dataset Olist, foi definida uma arquitetura em camadas seguindo o modelo Medalhão: Landing, Bronze, Silver e Gold.

Essa abordagem foi escolhida por separar claramente os dados brutos, os dados padronizados, os dados tratados e os dados preparados para análise. Com isso, o pipeline fica mais organizado, rastreável e fácil de evoluir durante as próximas etapas do projeto.

O objetivo desta decisão é definir uma base técnica simples, reproduzível e adequada ao escopo acadêmico do projeto, sem adicionar complexidade desnecessária.

---

## O que foi decidido e abordado

### Arquitetura Medalhão

Foi adotada a arquitetura Medalhão como padrão lógico do pipeline.

**Justificativa:**

A arquitetura Medalhão facilita a organização dos dados por nível de tratamento. Ela também ajuda a manter separação de responsabilidades entre ingestão, limpeza, transformação e consumo analítico.

---

### Camada Landing

A camada Landing será responsável por armazenar os arquivos originais do dataset Olist, sem transformação.

**Justificativa:**

Manter os dados originais preservados permite rastreabilidade e facilita reprocessamentos futuros caso alguma regra de transformação precise ser corrigida.

---

### Camada Bronze

A camada Bronze será responsável por armazenar os dados em formato mais adequado para processamento, mantendo estrutura próxima à origem.

**Justificativa:**

Essa camada funciona como uma primeira padronização dos dados, permitindo leitura mais eficiente pelo pipeline sem aplicar regras de negócio complexas neste momento.

---

### Camada Silver

A camada Silver será responsável por armazenar dados tratados, tipados, padronizados e consistentes.

**Justificativa:**

Essa etapa concentra as principais regras de limpeza e preparação dos dados, como tratamento de nulos, padronização de tipos, remoção de inconsistências e junções entre entidades relacionadas.

---

### Camada Gold

A camada Gold será responsável por armazenar dados prontos para análise e visualização.

**Justificativa:**

Essa camada será usada para gerar visões analíticas, indicadores e tabelas finais voltadas para consumo por dashboards, relatórios ou consultas exploratórias.

---

### Processamento com Apache Spark

Foi definido o uso do Apache Spark como ferramenta principal de processamento dos dados.

**Justificativa:**

O Spark é uma ferramenta amplamente utilizada em engenharia de dados para processamento em lote. Mesmo que o volume do dataset Olist seja controlado, sua utilização aproxima o projeto de um cenário real de pipeline de dados.

---

### Linguagem de Desenvolvimento

Foi definido o uso de Python com PySpark para desenvolvimento das transformações.

**Justificativa:**

Python possui boa integração com o ecossistema de dados, é simples de manter e facilita a escrita das transformações. O PySpark permite utilizar os recursos do Spark mantendo uma sintaxe acessível para a equipe.

---

### Formato de Armazenamento

Foi definido o uso de arquivos Parquet como formato principal para as camadas processadas.

**Justificativa:**

Parquet é um formato colunar eficiente para leitura analítica, possui boa integração com Spark e reduz o custo de leitura quando comparado a formatos como CSV.

---

### Ambiente de Desenvolvimento

Foi definido que o ambiente deve ser reproduzível localmente, preferencialmente com Docker.

**Justificativa:**

O uso de Docker reduz problemas de configuração entre os integrantes da equipe e facilita a execução do projeto em diferentes máquinas.

---

### Orquestração

Para a orquestração do pipeline, foram consideradas ferramentas como Airflow e Prefect.

**Justificativa:**

Airflow é uma ferramenta madura e muito utilizada no mercado, enquanto Prefect tende a ser mais simples para projetos menores e ambientes locais. A escolha final pode considerar o nível de complexidade desejado para a entrega.

---

### Visualização e Consumo Analítico

Para visualização dos dados, podem ser utilizadas ferramentas como Metabase, Superset ou Power BI.

**Justificativa:**

Essas ferramentas permitem consumir os dados da camada Gold e criar dashboards ou análises de forma mais clara para apresentação dos resultados do projeto.

---

## Fluxo Proposto

1. Ingestão dos arquivos originais do dataset Olist na camada Landing.
2. Conversão e padronização inicial dos dados na camada Bronze.
3. Limpeza, tratamento e integração dos dados na camada Silver.
4. Criação de tabelas analíticas e indicadores na camada Gold.
5. Consumo dos dados finais por ferramenta de visualização ou análise.

---

## Recomendações Técnicas

- Utilizar Spark com PySpark para processamento dos dados.
- Utilizar Parquet nas camadas Bronze, Silver e Gold.
- Preservar os arquivos originais na camada Landing.
- Separar claramente scripts de ingestão, transformação e geração das tabelas analíticas.
- Manter validações básicas de qualidade de dados em cada etapa do pipeline.
- Registrar logs de execução para facilitar identificação de erros.
- Priorizar uma arquitetura simples e reproduzível para todos os membros da equipe.

---

## Validação da Arquitetura

A arquitetura proposta atende ao objetivo da issue por definir o fluxo geral do pipeline, as camadas de armazenamento, as tecnologias principais e os pontos de decisão técnica necessários para iniciar a implementação.

A partir desta definição, a equipe pode avançar para a criação da estrutura inicial do projeto e para a implementação do primeiro fluxo de dados.