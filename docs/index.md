# Índice da Documentação - Projeto Engenharia de Dados (Olist)

Bem-vindo à documentação do projeto. Este arquivo serve como ponto de entrada central para os documentos, diagramas e referências do repositório.

## Estrutura de Documentação

### 1. Domínio e Escopo
- [Definição do Domínio](./dominio/CARD-001_definicao_dominio.md) — Visão geral, análise do dataset Olist, KPIs e indicadores preliminares.

### 2. Modelagem de Dados
- [Justificativa de Seleção de Atributos](./modelagem/CARD-002_justificativa_selecao_atributos.md) — Critérios usados na construção do DER lógico.
- [DER Inicial Olist](./modelagem/CARD-003_der_inicial_olist.md) — Diagrama de entidades e relacionamentos identificado a partir do dataset.
- [Dicionário de Dados](./modelagem/CARD-003_dicionario_dados_inicial.md) — Definições de campos, entidades e observações de modelagem.
- [Modelo Físico do Banco de Origem](./modelagem/CARD-007_modelo_fisico_banco_origem.md) — DDL, processo de carga e validação no Supabase/PostgreSQL.

### 3. Arquitetura de Dados
- [Arquitetura Técnica do Pipeline](./arquitetura/CARD-004_arquitetura_tecnica_pipeline.md) — Camadas do pipeline, tecnologias e recomendações.
- [Diagrama da Arquitetura de Dados](./arquitetura/CARD-005_diagrama_arquitetura_dados.md) — Visão dos componentes e fluxo da solução.

### 4. Dashboards e Análises
- [Requisitos do Dashboard](./dashboards/CARD-006_requisitos_dashboard.md) — KPIs, métricas e requisitos analíticos.

---

## Artefatos Complementares

### Documentos PDF
Todos os arquivos originais em PDF estão em `docs/documentos/`:

- `Analise.do.Dataset.pdf` — Análise completa do dataset Olist.
- `Arquitetura.de.Dados.pdf` — Documentação técnica da arquitetura.
- `DER.-.Preliminar.pdf` — DER preliminar em alta resolução.
- `dicionario_dados_olist.pdf` — Dicionário completo de dados.
- `requisitos_dashboard_analitico_olist.pdf` — Requisitos do dashboard.
- `diagrama.entidade.e.relacionamento.pdf` — DER detalhado.

### Imagens e Diagramas
Todos os artefatos visuais estão em `docs/imagens/`:

- `DER_preliminar.png` — Diagrama ER preliminar.
- `der_inicial_olist.png` — DER inicial do Olist.
- `der_logico.png` — DER lógico.
- `fluxo_operacional.jpeg` — Fluxo da operação de vendas.
- `diagrama_miro.png` — Diagrama colaborativo em Miro.
- `diagrama_por_IA.jpeg` — Diagrama gerado com apoio de IA.
- `imagem_layout_dashboard.png` — Layout do dashboard.
- `modelo_original_olist.png` — Modelo original do Olist.

---

## Como Usar Esta Documentação

1. Iniciantes: comece por [Definição do Domínio](./dominio/CARD-001_definicao_dominio.md).
2. Modelagem: siga para os documentos em [modelagem](./modelagem/), incluindo o modelo físico.
3. Arquitetura: consulte os documentos em [arquitetura](./arquitetura/).
4. Analytics: finalize em [Requisitos do Dashboard](./dashboards/CARD-006_requisitos_dashboard.md).

---

## Sumário por Tema

| Tema | Documento | Tipo |
|------|-----------|------|
| Visão Geral | CARD-001 | Markdown + PDF |
| Dataset | CARD-001, análise PDF | Análise |
| Modelagem | CARDS 002-003 e CARD-007 | Markdown + DER + SQL |
| Arquitetura | CARDS 004-005 | Markdown + Diagramas |
| Analytics | CARD-006 | Markdown + Mockup |

---

## Observações

- Todos os documentos estão em Markdown para facilitar versionamento e revisão via Git.
- Os PDFs permanecem disponíveis como referência complementar.
- A estrutura está organizada por camadas: domínio → modelagem → arquitetura → analytics.

---

**Última atualização**: June 12, 2026  
**Versão**: 1.1  
**Branch**: dados/banco-origem
