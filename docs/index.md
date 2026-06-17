# Projeto Final de Engenharia de Dados

Pipeline de dados de ponta a ponta sobre o dataset público da **Olist** (e-commerce brasileiro),
da ingestão dos dados até a visualização dos indicadores em um dashboard analítico.

## Sobre o projeto

A solução implementa uma arquitetura completa de Engenharia de Dados:

- Banco de **origem** transacional (PostgreSQL/Supabase) modelado a partir do dataset Olist;
- **Data Lake** em arquitetura **Medalhão** (Landing → Bronze → Silver → Gold) sobre object storage;
- Processamento e transformação com **Apache Spark** + **Delta Lake**;
- **Orquestração** das cargas com **Apache Airflow** (executando notebooks via **Papermill**);
- Camada analítica **dimensional** (fatos e dimensões) com carga incremental (SCD2 + checkpoint);
- **Dashboard** One Page View com 4 KPIs e 2 métricas.

## Jornada do dado

```
Origem (Supabase) → Landing → Bronze → Silver → Gold → Trino → Metabase
                    └──────── MinIO (Data Lake / Delta) ────────┘
            orquestrado por Apache Airflow + Papermill
```

## Equipe

- Gabriel Maciel Zavarize
- Nícolas Machado Cardoso
- Pedro Harter
- Wilian Vieira Fernandes
- Carlos Scheffer

## Tecnologias

Python · Apache Spark · Delta Lake · MinIO · Apache Airflow + Papermill · Trino · Metabase · PostgreSQL/Supabase · Docker · MkDocs Material

## Como navegar

- **Domínio** — definição do negócio e análise do dataset.
- **Modelagem** — DER, dicionário de dados e modelo físico da origem.
- **Arquitetura** — arquitetura técnica e diagramas da solução.
- **Pipeline & Infraestrutura** — padrão dos notebooks e o ambiente Docker.
- **Dashboard** — requisitos dos indicadores analíticos.
