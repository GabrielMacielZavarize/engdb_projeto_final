# Índice da Documentação - Projeto Engenharia de Dados (Olist)

Bem-vindo à documentação do projeto. Este arquivo serve como ponto de entrada central para todos os documentos, diagramas e referências.

## 📑 Estrutura de Documentação

### 1️⃣ Domínio e Escopo (CARD-001)
- [Definição do Domínio](./dominio/CARD-001_definicao_dominio.md) — Visão geral, análise do dataset Olist, KPIs e indicadores preliminares

### 2️⃣ Modelagem de Dados (CARDS 002-003)
- [Justificativa de Seleção de Atributos](./modelagem/CARD-002_justificativa_selecao_atributos.md) — Por que cada entidade foi selecionada
- [DER Inicial Olist](./modelagem/CARD-003_der_inicial_olist.md) — Diagrama de entidades e relacionamentos
- [Dicionário de Dados](./modelagem/CARD-003_dicionario_dados_inicial.md) — Definições de campos e tipos

### 3️⃣ Arquitetura de Dados (CARDS 004-005)
- [Arquitetura Técnica do Pipeline](./arquitetura/CARD-004_arquitetura_tecnica_pipeline.md) — Ingestão, processamento e armazenamento
- [Diagrama da Arquitetura de Dados](./arquitetura/CARD-005_diagrama_arquitetura_dados.md) — Visão técnica dos componentes

### 4️⃣ Dashboards e Análises (CARD-006)
- [Requisitos do Dashboard](./dashboards/CARD-006_requisitos_dashboard.md) — KPIs, métricas e mockups

---

## 📦 Artefatos Complementares

### 📄 Documentos PDF
Todos os arquivos originais em PDF estão em `docs/documentos/`:
- `Analise.do.Dataset.pdf` — Análise completa do dataset Olist
- `Arquitetura.de.Dados.pdf` — Documentação técnica da arquitetura
- `DER.-.Preliminar.pdf` — DER preliminar em alta resolução
- `dicionario_dados_olist.pdf` — Dicionário completo de dados
- `requisitos_dashboard_analitico_olist.pdf` — Requisitos do dashboard
- `diagrama.entidade.e.relacionamento.pdf` — DER detalhado
- E mais...

### 🖼️ Imagens e Diagramas
Todos os artefatos visuais estão em `docs/imagens/`:
- `DER_preliminar.png` — Diagrama ER preliminar
- `der_inicial_olist.png` — DER inicial do Olist
- `der_logico.png` — DER lógico
- `fluxo_operacional.jpeg` — Fluxo da operação de vendas
- `diagrama_miro.png` — Diagrama colaborativo (Miro)
- `diagrama_por_IA.jpeg` — Diagrama gerado por IA
- `imagem_layout_dashboard.png` — Layout do dashboard
- `modelo_original_olist.png` — Modelo original do Olist

---

## 🚀 Como Usar Esta Documentação

1. **Iniciantes**: Comece por [Definição do Domínio](./dominio/CARD-001_definicao_dominio.md)
2. **Modeladores**: Consulte a seção de [Modelagem](./modelagem/)
3. **Arquitetos**: Veja [Arquitetura de Dados](./arquitetura/)
4. **Analistas**: Acesse [Requisitos do Dashboard](./dashboards/CARD-006_requisitos_dashboard.md)

---

## 📚 Fluxo Recomendado de Leitura



## 🔍 Sumário por Tema

| Tema | Documento | Tipo |
|------|-----------|------|
| Visão Geral | CARD-001 | Markdown + PDF |
| Dataset | CARD-001, Análise PDF | Análise |
| Modelagem | CARDS 002-003 | Markdown + DER |
| Arquitetura | CARDS 004-005 | Markdown + Diagramas |
| Analytics | CARD-006 | Markdown + Mockup |

---

## 📌 Observações

- Todos os documentos estão em Markdown para facilitar versionamento e revisão via Git
- PDFs estão disponíveis como referência complementar
- Imagens podem ser referenciadas nos documentos ou visualizadas diretamente
- A estrutura está organizada por camadas: Domínio → Modelagem → Arquitetura → Analytics

---

**Última atualização**: June 11, 2026  
**Versão**: 1.0  
**Branch**: migrar-issues-docs