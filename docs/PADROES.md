# Padrões de Contribuição — Projeto Final de Engenharia de Dados

Este documento define os padrões de escrita para **Issues**, **Branches**, **Commits** e **Pull Requests** do projeto.
O objetivo é simular um ambiente real de desenvolvimento, manter o histórico legível e facilitar a avaliação individual da equipe.

> Equipe: Gabriel, Nicolas, Pedro, Wilian, Carlos.
> Stack do projeto: PostgreSQL (origem) · MinIO (Data Lake / object storage) · Apache Spark · Delta Lake · Airflow + Papermill (orquestração) · Trino · Metabase · MkDocs.

---

## 1. Issues

Toda atividade do projeto **deve** existir como uma Issue antes de virar código.

### 1.1 Título

Formato: `[ÁREA] Verbo no infinitivo + objeto`

| Área | Uso |
|------|-----|
| `[INFRA]` | docker-compose, MinIO, serviços, configuração de ambiente |
| `[DADOS]` | geração de massa, banco de origem, cargas |
| `[PIPELINE]` | camadas do data lake (landing/bronze/silver/gold), Spark |
| `[ORQUESTRACAO]` | DAGs Airflow, papermill, agendamento |
| `[DASHBOARD]` | Trino, Metabase, KPIs e métricas |
| `[DOCS]` | MkDocs, README, documentação |
| `[REPO]` | configurações do GitHub, proteção de branch, labels |

Exemplos:
- `[DADOS] Gerar massa de dados sintética com Faker (3 anos, 10k+ linhas)`
- `[PIPELINE] Implementar camada Bronze em Delta Lake`

### 1.2 Corpo (template)

```markdown
## Contexto
Por que esta tarefa existe e como se encaixa no projeto.

## Objetivo
O que deve ser entregue, em uma frase.

## Tarefas
- [ ] Passo 1
- [ ] Passo 2

## Critérios de Aceite
- [ ] Resultado verificável 1
- [ ] Resultado verificável 2

## Dependências
Issues que precisam estar concluídas antes (ou "Nenhuma").

## Definição de Pronto (DoD)
Código revisado via PR, documentação atualizada no /docs e critérios de aceite atendidos.
```

### 1.3 Labels

- **Prioridade:** `alta`, `média`, `baixa`
- **Tipo:** `epic`, `documentation`, `enhancement`, `bug`
- **Apoio:** `good first issue`, `help wanted`

### 1.4 Épicos e Sub-issues

Tarefas grandes viram um **Épico** (label `epic`). O épico é um guarda-chuva que lista as sub-issues
em formato de checklist. Cada sub-issue referencia o épico com `Épico relacionado: #<n>`.

---

## 2. Branches

A branch `main` é protegida: **nada entra sem Pull Request aprovado**.

Formato: `<tipo>/<n-issue>-<descricao-curta-kebab>`

| Tipo | Uso |
|------|-----|
| `feat` | nova funcionalidade |
| `fix` | correção de bug |
| `docs` | documentação |
| `infra` | ambiente / docker / serviços |
| `chore` | tarefas de manutenção, configs |
| `refactor` | refatoração sem mudar comportamento |

Exemplos:
- `feat/12-geracao-massa-faker`
- `infra/15-docker-compose-minio`
- `docs/8-migrar-comentarios-issues`

Regras:
- Uma branch por issue.
- Sempre criada a partir da `main` atualizada.
- Nome em minúsculas, palavras separadas por hífen.

---

## 3. Commits

Seguimos **Conventional Commits** (já em uso no repositório).

Formato: `<tipo>(<escopo>): <descrição no imperativo>`

```
feat(pipeline): adicionar ingestão da camada landing
fix(airflow): corrigir caminho do notebook no papermill
docs(mkdocs): publicar dicionário de dados
infra(minio): configurar bucket do data lake
```

Regras:
- Descrição no **imperativo** e em minúsculas ("adicionar", não "adicionado").
- Sem ponto final no título; máx. ~72 caracteres.
- Referencie a issue no corpo: `Refs #12` ou `Closes #12`.
- Tipos: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`, `ci`, `build`.

---

## 4. Pull Requests

### 4.1 Título

Mesmo padrão dos commits: `<tipo>(<escopo>): <descrição>`.

### 4.2 Corpo (template)

```markdown
## Descrição
O que este PR faz e por quê.

## Issue relacionada
Closes #<n>

## O que foi feito
- Item 1
- Item 2

## Como testar
Passos para validar localmente (comandos, prints, etc).

## Checklist
- [ ] Segui os padrões deste documento
- [ ] Atualizei a documentação no /docs quando aplicável
- [ ] O PR está vinculado a uma issue
- [ ] Solicitei revisão de ao menos 1 colega
```

### 4.3 Regras

- PR pequeno e focado em uma issue.
- Mínimo de **1 aprovação** antes do merge.
- Usar **Squash and merge** para manter o histórico limpo.
- A branch é deletada após o merge.

---

## 5. Fluxo resumido

1. Pegue/abra uma **Issue**.
2. Crie a **branch** a partir da `main`.
3. Faça **commits** pequenos e descritivos.
4. Abra um **PR** vinculado à issue (`Closes #n`).
5. Peça **revisão**; após aprovação, faça **squash and merge**.
6. Atualize a documentação no **/docs**.
