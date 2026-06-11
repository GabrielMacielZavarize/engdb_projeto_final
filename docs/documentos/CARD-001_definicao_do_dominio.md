# Definição do Domínio

## Descrição do Negócio

O projeto consiste na implementação de uma arquitetura de Engenharia de Dados baseada em um marketplace de comércio eletrônico inspirado na Olist.

A plataforma conecta clientes, vendedores e produtos em um ambiente de vendas online, permitindo que consumidores realizem compras através do marketplace enquanto vendedores disponibilizam seus produtos para comercialização.

O sistema registra todas as etapas da jornada de compra, incluindo cadastro de clientes, realização de pedidos, processamento de pagamentos, envio de produtos, entregas e avaliações realizadas pelos consumidores.

Os dados gerados serão utilizados para alimentar um ambiente analítico capaz de fornecer indicadores estratégicos sobre vendas, desempenho logístico, comportamento dos clientes e performance dos vendedores.

---



![Fluxo Operacional](../imagens/fluxo_operacional.jpeg)

---

## Regras de Negócio

* Um cliente pode realizar vários pedidos.
* Um pedido pode conter um ou mais produtos.
* Um produto pertence a uma categoria.
* Um vendedor pode vender diversos produtos.
* Um pedido deve possuir ao menos um pagamento associado.
* Um pedido pode receber uma avaliação após a entrega.
* Cada entrega está associada a um pedido.
* O tempo de entrega será calculado utilizando as datas de aprovação e entrega do pedido.


## Documento

[Definição do Domínio.pdf](https://github.com/user-attachments/files/28690145/Definicao.do.Dominio.pdf)