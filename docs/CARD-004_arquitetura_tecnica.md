# CARD-004 — Definir Arquitetura Técnica da Solução

Link da issue: https://github.com/GabrielMacielZavarize/engdb_projeto_final/issues/4

## Responsável

- Nicolas (`nicolasmacardoso`)

## Objetivo

Documentar a arquitetura técnica do pipeline de dados baseado no dataset Olist,
adotando a arquitetura Medalhão (Landing → Bronze → Silver → Gold) e
registrando decisões, tecnologias e justificativas para a equipe.

## Escopo do documento

- Visão geral e diagrama lógico do pipeline.
- Tecnologias e ferramentas por camada.
- Estratégia de armazenamento e formatos.
- Execução do Apache Spark durante desenvolvimento e produção.
- Orquestração e observabilidade.
- Visualização/consumo analítico.
- Plano de validação e critérios de aceite.

## Atividades (a executar)

1. Escrever um resumo executivo descrevendo o objetivo do pipeline e o estilo
   Medalhão.
2. Desenhar um diagrama lógico (PNG/SVG) mostrando ingestão, processamento,
   armazenamento e consumo.
3. Para cada camada (Landing, Bronze, Silver, Gold) listar:
   - tecnologia de armazenamento (ex.: object store, filesystem)
   - formato de arquivo (ex.: Parquet, Delta Lake)
   - política de particionamento e retenção
4. Definir como o Apache Spark será executado:
   - modo de desenvolvimento (ex.: local com Docker / Spark local / Databricks)
   - modo de produção (ex.: Spark on Kubernetes, EMR, Databricks)
   - gerenciamento de dependências e versões (ex.: imagens Docker, virtualenv)
5. Avaliar e escolher orquestrador (ex.: Airflow, Prefect, Dagster), com prós
   e contras.
6. Propor ferramenta(s) de visualização/BI (ex.: Metabase, Superset, PowerBI)
   com justificativa de custo/integração.
7. Incluir recomendações para qualidade de dados (checks), logging e alertas.
8. Registrar todas as decisões em um documento versionado no repositório.

## Critérios de aceite

- Documento `docs/CARD-004_arquitetura_tecnica.md` criado e com histórico no
  repositório.
- Fluxo de dados descrito desde a ingestão até consumo analítico.
- Tecnologias selecionadas com justificativa objetiva (prós/contras).
- Plano de execução do Spark definido para dev e produção.
- Arquitetura validada pela equipe (pull request + revisão).

## Recomendações iniciais (opções sugeridas)

- Armazenamento:
  - Landing: S3 / MinIO (object store) — dados brutos em formato original +
    cópia em Parquet
  - Bronze: Parquet ou Delta Lake (raw + minimal transformação)
  - Silver: Delta Lake (dados limpos, colunas tipadas, joins consolidados)
  - Gold: Parquet/Delta otimizado para consumo analítico (tabelas particionadas)

- Formato e catalogação:
  - Preferir `Parquet` para compatibilidade; `Delta Lake` se desejar ACID,
    versionamento e time-travel.
  - Adotar um catálogo (Hive Metastore / Glue / catalog local) para tabelas.

- Apache Spark:
  - Desenvolvimento: executar em Docker com Spark local (imagem padronizada),
    permitindo testes reproduzíveis.
  - Produção: Spark on Kubernetes ou EMR/Databricks (dependendo do orçamento
    e disponibilidade).

- Orquestração:
  - Airflow: maturidade e grande ecossistema (bom para equipes com experiência).
  - Prefect/Dagster: alternativa moderna, fácil de testar localmente e com
    bom modelo de deploy.

- Observabilidade / Qualidade de Dados:
  - Usar Great Expectations para checks de qualidade ou implementar checks
    customizados no pipeline.
  - Centralizar logs em um serviço (Elastic Stack / Loki + Grafana).

- Visualização / BI:
  - Metabase ou Superset para dashboards rápidos e self-service.
  - PowerBI/Looker se houver necessidade corporativa e licença.

## Estratégia de versionamento e entrega

- Criar branch `feat/CARD-004-architecture` para o documento e assets (diagramas).
- Abrir PR referenciando a issue `#4` e solicitar revisão dos responsáveis.

## Plano de validação

- Revisão técnica em PR com pelo menos um approver.
- Checklist de critérios de aceite preenchido no PR.

## Próximos passos sugeridos (curto prazo)

1. Validar as recomendações com a equipe (reunião rápida — 30 min).
2. Escolher orquestrador e formato de storage (decisão bloqueante para infra).
3. Implementar um POC mínimo: ingestão → Bronze → leitura em Spark local.

---

_Versão inicial criada em: 2026-06-09_
