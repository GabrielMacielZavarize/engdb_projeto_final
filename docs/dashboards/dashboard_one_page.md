# Dashboard Olist — One Page

Documentação do dashboard analítico de página única, construído **manualmente**
no Metabase sobre a camada Gold (Delta) servida pelo Trino.

> Os SQLs finais de cada card estão versionados em
> [`dashboard_queries.sql`](dashboard_queries.sql).

## Conexão no Metabase

| Item | Valor |
|------|-------|
| Banco (database) | `Olist Gold - Trino` |
| Engine | **Starburst** (driver 5.0.0, embutido na imagem do Metabase) |
| Host | `trino` |
| Porta | `8080` (porta interna na rede `datalake`) |
| Catálogo | `delta` |
| Schema | `gold` |
| Usuário | `admin` (sem senha, sem SSL) |

## Layout (One Page)

Organização em duas linhas:

```text
┌───────────────┬───────────────┬───────────────┬───────────────┐
│ Receita Total │ Qtd. Pedidos  │ Ticket Médio  │ Tempo Médio   │   ← Linha 1: 4 KPIs
│   (número)    │   (número)    │   (número)    │ de Entrega    │
├───────────────┴───────────────┼───────────────┴───────────────┤
│        Vendas por Mês          │     Top 10 Categorias          │   ← Linha 2: 2 gráficos
│        (gráfico de linha)      │     (barras horizontais)       │
└────────────────────────────────┴────────────────────────────────┘
```

- **Primeira linha:** os quatro KPIs, lado a lado, com o mesmo tamanho.
- **Segunda linha:** **Vendas por Mês** e **Top 10 Categorias Vendidas**, lado a lado.

## Cards e visualizações

| # | Card | Visualização | Formatação |
|---|------|--------------|------------|
| 1 | Receita Total | Número (scalar) | Moeda **BRL**, exibição **compacta** |
| 2 | Quantidade de Pedidos | Número (scalar) | Inteiro (0 casas decimais) |
| 3 | Ticket Médio | Número (scalar) | Moeda **BRL**, **2 casas decimais** |
| 4 | Tempo Médio de Entrega | Número (scalar) | Número com sufixo **` dias`** |
| 5 | Vendas por Mês | **Gráfico de linha** | Eixo X = `year_month`, Eixo Y = `receita_total` |
| 6 | Top 10 Categorias Vendidas | **Barras horizontais** (tipo *row*) | Dimensão = `categoria`, Métrica = `quantidade_vendida` |

## Valores validados

Executados sobre a Gold populada com `run_date=2026-06-22`:

| KPI | Valor |
|-----|-------|
| Receita Total | **R$ 2.390.742,00** |
| Quantidade de Pedidos | **15.001** |
| Ticket Médio | **R$ 159,37** |
| Tempo Médio de Entrega | **12 dias** |

## Filtros

**Não foram incluídos filtros** neste dashboard, conforme alinhamento atual da
equipe para esta entrega.

## Como recriar os cards manualmente no Metabase

1. **Conectar o banco:** Admin → Databases → Add → **Starburst**, com os dados da
   tabela "Conexão no Metabase" acima. Aguardar o sync do schema.
2. **Criar a coleção** (opcional, para organizar): `Dashboard Olist — One Page`.
3. **Criar as 6 perguntas** (New → SQL query), uma para cada bloco de
   [`dashboard_queries.sql`](dashboard_queries.sql), selecionando o banco
   `Olist Gold - Trino`. Salvar com os nomes: *Receita Total*, *Quantidade de
   Pedidos*, *Ticket Médio*, *Tempo Médio de Entrega*, *Vendas por Mês*,
   *Top 10 Categorias Vendidas*.
4. **Ajustar a visualização** de cada card conforme a tabela "Cards e
   visualizações" (número/moeda/sufixo, linha, barras horizontais).
5. **Criar o dashboard** `Dashboard Olist` e adicionar os 6 cards, posicionando
   os 4 KPIs na primeira linha e os 2 gráficos na segunda (One Page).
6. **Não adicionar filtros** (dispensados nesta entrega).
7. Salvar e exportar a evidência (print/PDF) do dashboard finalizado.
