# Diagrama da Arquitetura de Dados

## Objetivo

Documentar visualmente a arquitetura de dados do projeto, demonstrando o fluxo das informações desde a origem dos dados até a camada de consumo analítico.

O diagrama tem como finalidade facilitar o entendimento da solução proposta, evidenciando os componentes utilizados, o fluxo de processamento e as tecnologias envolvidas em cada etapa do pipeline.

---

# Diagrama da Arquitetura

## Versão Elaborada no Miro


![DER Preliminar](../imagens/diagrama_miro.png)

### Link para Visualização

- https://miro.com/welcomeonboard/dkova28rS2FnazJoK0hwK1BvVnF3UWNZVTN3RGFQaW1KUHJ0VXlPNlU3UHMycG0xYzlYSjRxeXluSE56enJPSzVLUEUyckRqMHo0NXppcGw5SkxzVGhySWcyZjVjZlpKREMrRHJKaEhRaWxEY21NR0FxblVBZG4wN3M4U2N4a1FQdGo1ZEV3bUdPQWRZUHQzSGl6V2NBPT0hdjE=?share_link_id=925417688732
---

## Versão Elaborada com Apoio de IA

![DER Preliminar](../imagens/diagrama_por_IA.jpeg)

---

# Fluxo dos Dados

O fluxo de dados do projeto segue as etapas descritas abaixo:

1. Dataset Olist
2. Apache Airflow
3. Landing Zone
4. Bronze Layer
5. Silver Layer
6. Gold Layer
7. Metabase

---
# Arquitetura Medalhão

O projeto adota a Arquitetura Medalhão (Medallion Architecture), organizada em quatro camadas principais:

```text
Landing
   ↓
Bronze
   ↓
Silver
   ↓
Gold
```

Essa abordagem promove a separação das responsabilidades do pipeline e facilita a evolução das transformações ao longo do ciclo de vida dos dados.

---

# Tecnologias Utilizadas

| Componente       | Tecnologia             |
| ---------------- | ---------------------- |
| Origem dos Dados | Dataset Olist (CSV)    |
| Orquestração     | Apache Airflow         |
| Processamento    | Apache Spark (PySpark) |
| Landing          | CSV                    |
| Bronze           | Delta Lake             |
| Silver           | Delta Lake             |
| Gold             | Delta Lake             |
| Visualização     | Metabase               |

---

# Resumo da Arquitetura

## Origem dos Dados

Arquivos CSV do dataset Olist.

## Orquestração

Apache Airflow responsável pela execução e monitoramento do pipeline.

## Processamento

Apache Spark (PySpark) utilizado para ingestão, transformação e agregação dos dados.

## Armazenamento

Arquitetura Medalhão utilizando:

* CSV na camada Landing;
* Delta Lake nas camadas Bronze;
* Delta Lake nas camadas Silver;
* Delta Lake nas camadas Gold.

## Visualização

Metabase utilizado para criação de dashboards e relatórios analíticos.

---

# Benefícios da Arquitetura

* Separação clara das etapas do pipeline;
* Facilidade de manutenção;
* Reprocessamento simplificado;
* Melhor rastreabilidade dos dados;
* Escalabilidade para futuras evoluções;
* Organização adequada para projetos de Engenharia de Dados.

---

# Artefatos Relacionados

* Definição do Domínio
* DER Preliminar
* DER Lógico
* Dicionário de Dados
* Arquitetura Técnica da Solução
* Requisitos do Dashboard

---

# Documentos de Referência

 * [Arquitetura de Dados.pdf](https://github.com/user-attachments/files/28799755/Arquitetura.de.Dados.pdf)
* Diagrama elaborado no Miro
* Diagrama elaborado com apoio de IA
