# CARD-006 — Levantar Requisitos para o Dashboard Analítico

Link da issue: https://github.com/GabrielMacielZavarize/engdb_projeto_final/issues/6

## Responsável

* Carlos (`CarlosSchefferr`)

## Objetivo

Definir os requisitos funcionais do dashboard analítico que será desenvolvido ao
final do projeto, garantindo que os KPIs, especificações e filtros definidos
sejam contemplados pela modelagem analítica e pelas transformações futuras.

O dashboard terá como objetivo apresentar uma visão consolidada dos principais
indicadores relacionados a vendas, pedidos, bilheteria e tempo de entrega,
permitindo a análise do desempenho do domínio escolhido pela equipe.

## Escopo do documento

* Definição dos KPIs principais do dashboard.
* Detalhamento das regras de cálculo dos indicadores.
* Definição das especificações analíticas previstas.
* Identificação dos filtros relevantes para análise dos dados.
* Proposta inicial de layout no formato One Page View.
* Registro dos requisitos funcionais e critérios de aceite.
* Pontos de validação necessários com a equipe.

## KPIs definidos

Os KPIs definidos inicialmente pela equipe são:

* Receita Total
* Quantidade de Pedidos
* Bilheteria
* Tempo de Entrega

## Especificações definidas

As especificações analíticas previstas para o dashboard são:

* Vendas por Mês
* Top 10 Categorias Vendidas

## Atividades (a executar)

1. Revisar os KPIs definidos pela equipe:

   * Receita Total
   * Quantidade de Pedidos
   * Bilheteria
   * Tempo de Entrega

2. Documentar a definição de cada KPI, incluindo:

   * objetivo do indicador
   * regra de cálculo
   * formato de exibição
   * observações de negócio
   * dependências de dados

3. Revisar as especificações analíticas definidas:

   * Vendas por Mês
   * Top 10 Categorias Vendidas

4. Identificar os filtros relevantes para análise dos dados, considerando:

   * período
   * mês
   * ano
   * categoria
   * produto
   * status do pedido
   * canal de venda
   * localidade ou região

5. Propor o layout inicial do dashboard no formato One Page View.

6. Documentar o esboço inicial do dashboard no repositório.

7. Validar os requisitos do dashboard com a equipe.

## Detalhamento dos KPIs

### Receita Total

A Receita Total representa o valor total gerado pelas vendas realizadas no
período analisado.

Este indicador tem como objetivo permitir o acompanhamento do faturamento geral
do negócio, considerando os filtros aplicados no dashboard.

Regra de cálculo:

```text
Receita Total = soma do valor total dos pedidos válidos
```

Formato de exibição:

```text
R$ 25.430,00
```

Observações:

* Pedidos cancelados não devem ser considerados caso exista essa informação na
  base de dados.
* O cálculo deve considerar o período selecionado nos filtros.
* A regra final de status válido deverá ser validada com a equipe.

### Quantidade de Pedidos

A Quantidade de Pedidos representa o total de pedidos registrados no período
analisado.

Este indicador tem como objetivo acompanhar o volume de pedidos realizados e
permitir comparações ao longo do tempo.

Regra de cálculo:

```text
Quantidade de Pedidos = contagem total de pedidos
```

Formato de exibição:

```text
1.245 pedidos
```

Observações:

* A equipe deverá validar se pedidos cancelados serão considerados ou removidos
  do cálculo.
* O indicador deve ser atualizado conforme os filtros aplicados no dashboard.

### Bilheteria

A Bilheteria representa o valor arrecadado com vendas relacionadas a bilhetes,
ingressos ou entradas, conforme o domínio definido no projeto.

Este indicador tem como objetivo acompanhar a arrecadação específica de
bilheteria, caso essa informação esteja presente no escopo e nos dados
disponíveis.

Regra de cálculo:

```text
Bilheteria = soma do valor dos bilhetes vendidos
```

Formato de exibição:

```text
R$ 12.800,00
```

Observações:

* Este KPI depende da confirmação do domínio do projeto.
* Caso o domínio não envolva bilhetes, ingressos ou eventos, a equipe deverá
  ajustar a definição do indicador.
* A regra final deve considerar apenas registros válidos para análise.

### Tempo de Entrega

O Tempo de Entrega representa o tempo médio entre a criação do pedido e a sua
entrega ou conclusão.

Este indicador tem como objetivo avaliar a eficiência operacional do processo de
entrega.

Regra de cálculo:

```text
Tempo de Entrega = média(data/hora de entrega - data/hora do pedido)
```

Formato de exibição:

```text
42 minutos
```

Observações:

* Pedidos sem data de entrega não devem ser considerados no cálculo da média.
* A unidade de tempo deve ser validada com a equipe, podendo ser minutos, horas
  ou dias.
* O cálculo depende da existência de campos de data/hora de pedido e entrega na
  base de dados.

## Especificações analíticas

### Vendas por Mês

A visualização de Vendas por Mês deverá apresentar a evolução das vendas ao
longo do tempo, agrupando os valores por mês e ano.

Objetivo:

* Identificar crescimento ou queda nas vendas.
* Observar sazonalidade.
* Comparar o desempenho entre diferentes períodos.

Métrica principal:

```text
Receita Total
```

Dimensão principal:

```text
Mês/Ano
```

Visualização sugerida:

* Gráfico de linhas; ou
* Gráfico de colunas.

Observações:

* A visualização deve respeitar os filtros aplicados no dashboard.
* O agrupamento deve considerar a data do pedido ou a data de venda, conforme
  definido pela equipe.

### Top 10 Categorias Vendidas

A visualização de Top 10 Categorias Vendidas deverá apresentar as dez categorias
com maior desempenho no período analisado.

Objetivo:

* Identificar as categorias mais relevantes.
* Apoiar a análise de concentração de vendas.
* Comparar o desempenho entre categorias.

Métrica principal:

```text
Quantidade vendida ou Receita Total
```

Dimensão principal:

```text
Categoria
```

Visualização sugerida:

* Gráfico de barras horizontais; ou
* Tabela ranqueada.

Ordenação:

```text
Do maior para o menor valor
```

Observações:

* A equipe deverá validar se o ranking será ordenado por quantidade vendida ou
  por receita total.
* A visualização deve apresentar no máximo dez categorias.
* A visualização deve respeitar os filtros aplicados no dashboard.

## Filtros relevantes

Os filtros permitem que o usuário analise os indicadores a partir de diferentes
recortes dos dados.

Filtros sugeridos:

* Período
* Mês
* Ano
* Categoria
* Produto
* Status do pedido
* Canal de venda
* Região ou localidade
* Tipo de entrega
* Evento, caso aplicável ao domínio

Filtros prioritários para a primeira versão:

* Período
* Categoria
* Status do pedido
* Região ou localidade

Observações:

* Os filtros finais dependem dos campos disponíveis na base de dados.
* Todos os KPIs e gráficos devem ser atualizados conforme os filtros aplicados.
* A disponibilidade dos filtros deverá ser validada após a análise do dataset.

## Proposta de layout One Page View

O dashboard será desenvolvido em formato One Page View, concentrando as
informações principais em uma única tela.

A estrutura inicial proposta é:

```text
┌──────────────────────────────────────────────────────────────┐
│ Dashboard Analítico                                           │
│ Filtros: Período | Categoria | Status | Região                │
├──────────────┬──────────────┬──────────────┬─────────────────┤
│ Receita Total│ Qtd. Pedidos │ Bilheteria   │ Tempo Entrega   │
│ R$ 25.430,00 │ 1.245        │ R$ 12.800,00 │ 42 min          │
├──────────────────────────────────────────────────────────────┤
│ Vendas por Mês                                                │
│ Gráfico de linhas ou colunas                                  │
├──────────────────────────────┬───────────────────────────────┤
│ Top 10 Categorias Vendidas   │ Pedidos por Status             │
│ Gráfico de barras            │ Gráfico de barras/pizza        │
├──────────────────────────────┴───────────────────────────────┤
│ Tabela resumida / Informações complementares                  │
└──────────────────────────────────────────────────────────────┘
```

## Estrutura visual sugerida

### Cabeçalho

* Título do dashboard.
* Filtros principais.
* Período selecionado.

### Primeira linha

Cards com os principais KPIs:

* Receita Total
* Quantidade de Pedidos
* Bilheteria
* Tempo de Entrega

### Segunda linha

Gráfico principal:

* Vendas por Mês

### Terceira linha

Visualizações comparativas:

* Top 10 Categorias Vendidas
* Pedidos por Status

### Quarta linha

Área complementar:

* Tabela resumida
* Detalhamento por categoria, status ou região

## Requisitos funcionais

### RF01 — Exibir Receita Total

O dashboard deve exibir a receita total considerando os filtros aplicados pelo
usuário.

### RF02 — Exibir Quantidade de Pedidos

O dashboard deve exibir a quantidade total de pedidos realizados no período
selecionado.

### RF03 — Exibir Bilheteria

O dashboard deve exibir o valor total de bilheteria, quando essa informação
estiver disponível na base de dados.

### RF04 — Exibir Tempo de Entrega

O dashboard deve exibir o tempo médio de entrega dos pedidos, considerando
apenas registros com datas válidas.

### RF05 — Exibir Vendas por Mês

O dashboard deve apresentar uma visualização gráfica da receita total agrupada
por mês e ano.

### RF06 — Exibir Top 10 Categorias Vendidas

O dashboard deve apresentar as dez categorias com maior desempenho, considerando
a métrica definida pela equipe.

### RF07 — Permitir aplicação de filtros

O dashboard deve permitir a aplicação de filtros relevantes para análise dos
dados.

### RF08 — Atualizar indicadores conforme filtros

Ao aplicar filtros, todos os cards e gráficos do dashboard devem ser atualizados
conforme os critérios selecionados.

## Requisitos não funcionais

### RNF01 — Visualização em página única

O dashboard deve seguir o formato One Page View, evitando navegação entre várias
páginas para análise dos principais indicadores.

### RNF02 — Clareza visual

Os indicadores devem ser apresentados de forma clara, objetiva e de fácil
interpretação.

### RNF03 — Consistência dos dados

Os valores exibidos no dashboard devem estar alinhados com as regras de negócio,
com a modelagem analítica e com as transformações definidas no pipeline.

### RNF04 — Organização da informação

Os KPIs principais devem ficar no topo da tela, enquanto gráficos e análises
detalhadas devem ser posicionados abaixo.

## Dependências

* CARD-001 — Definir Domínio e Escopo do Projeto

A definição final dos indicadores depende do domínio escolhido pela equipe e dos
campos disponíveis no dataset utilizado.

## Pontos para validação com a equipe

* Confirmar se o KPI Bilheteria se aplica ao domínio do projeto.
* Definir se pedidos cancelados serão considerados nos indicadores.
* Confirmar se o Top 10 Categorias Vendidas será ordenado por quantidade vendida
  ou por receita total.
* Validar a unidade de exibição do Tempo de Entrega.
* Confirmar quais filtros estarão disponíveis na base de dados.
* Validar se o layout One Page View atende ao objetivo do projeto.

## Critérios de aceite

* Documento `docs/CARD-006_requisitos_dashboard_analitico.md` criado e com
  histórico no repositório.
* KPIs detalhados com definição, objetivo, regra de cálculo e formato de
  exibição.
* Especificações analíticas documentadas.
* Filtros relevantes identificados.
* Esboço inicial do dashboard documentado.
* Requisitos validados pela equipe.

## Estratégia de versionamento e entrega

* Criar branch `feat/CARD-006-dashboard-requirements` para o documento.
* Adicionar o documento em `docs/CARD-006_requisitos_dashboard_analitico.md`.
* Abrir pull request referenciando a issue `#006`.
* Solicitar revisão da equipe.
* Ajustar o documento conforme os comentários recebidos.

## Plano de validação

* Revisão do documento em pull request.
* Validação dos KPIs com a equipe.
* Confirmação dos filtros disponíveis conforme a base de dados.
* Checklist dos critérios de aceite preenchido no PR.

## Próximos passos sugeridos

1. Validar com a equipe os pontos em aberto sobre Bilheteria, pedidos cancelados
   e ordenação do Top 10 Categorias.
2. Ajustar o documento conforme as decisões do grupo.
3. Criar ou anexar o esboço visual do dashboard no formato One Page View.
4. Utilizar este documento como base para a modelagem analítica e para as
   transformações futuras.

---

*Versão inicial criada em: 2026-06-09*
