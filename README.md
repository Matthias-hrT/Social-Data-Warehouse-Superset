# Social Data Warehouse & BI: Programa Família Acolhedora (SUAS)

## Sobre o Projeto

Este repositório contém a arquitetura completa de Engenharia de Dados e Business Intelligence desenvolvida como Trabalho de Conclusão de Curso (TCC) em Engenharia de Computação. O objetivo central é transformar dados abertos brutos do Censo SUAS (Sistema Único de Assistência Social), com foco no programa Família Acolhedora, em métricas analíticas acionáveis para a gestão pública.

O projeto abrange o fluxo de ponta a ponta: extração e tratamento dos dados brutos governamentais, aplicação de regras de negócio e cortes estatísticos para otimização do armazenamento, modelagem estrutural do Data Warehouse e a disponibilização visual em dashboards interativos.

## Arquitetura e Modelagem de Dados

O Data Warehouse foi projetado utilizando uma abordagem metodológica híbrida, unindo os principais conceitos da literatura de modelagem de dados para suprir a complexidade do domínio social:

* **Ralph Kimball & Margy Ross:** Utilização do ciclo de vida dimensional, foco na entrega de valor ao usuário final e adoção estrita de *Dimensões Conformadas* e *Chaves Substitutas (Surrogate Keys)*.

* **W. H. Inmon:** Aplicação dos conceitos de separação física e lógica por meio de uma robusta área de *Data Staging* isolada para garantir a qualidade dos dados (*Data Quality*) antes da persistência no repositório analítico.

* **Matteo Golfarelli & Stefano Rizzi:** Implementação da topologia em **Constelação de Fatos (Esquema Galáxia / Fact Constellation)**. Esta escolha foi fundamental para resolver os conflitos de granularidade das bases abertas, permitindo que múltiplas Tabelas Fato independentes (Acolhimento, Unidades, Famílias e Equipes) compartilhem o mesmo conjunto de dimensões.

**Destaques Técnicos:**

* **SCD Tipo 2 (Slowly Changing Dimensions):** Implementação de versionamento histórico para rastrear o ciclo de vida e as mudanças nos atributos das dimensões.

* **Otimização Anti-Table Bloat:** Aplicação de regra de negócio híbrida na fase de Staging: variáveis qualitativas vitais à proteção juvenil foram mantidas, enquanto ruídos estatísticos em motivos parentais marginais sofreram corte por volumetria, garantindo *Views* de altíssima performance para o motor do BI.

## Tecnologias Utilizadas

* **ETL & Integração:** Pentaho Data Integration (PDI / Kettle) para extração, higienização (tratamento de inconsistências do IBGE e nulos), tipagem e carga.

* **Armazenamento e DW:** PostgreSQL para a construção da camada analítica e criação de *Views* materializadas (*One Big Table logic*) para o consumo da ferramenta de visualização.

* **Business Intelligence:** Apache Superset para processamento das séries temporais (*Time Grain* nativo) e visualização interativa das métricas de quebra de vínculos protetivos.

## Estrutura do Repositório

* **`Pentaho/`**: Transformações (`.ktr`) e Jobs (`.kjb`) desenvolvidos no PDI.

  * `auxiliares/`: Transformações de suporte ao fluxo, como a configuração de variáveis dinâmicas (Set Variables) para a execução do ETL.

  * `dimensoes/`: Transformações responsáveis por popular e historizar (SCD2) as dimensões conformadas.

  * `fato/`: Tratamento de regras de negócio, estatística e carga das tabelas fato.

  * `jobs/`: Organização do fluxo contínuo de ETL.

* **`Planilhas/`**: Conjunto de dados brutos e processados.

  * `Processados/`: Diretório de arquivamento. Os arquivos já utilizados pelo pipeline são movidos automaticamente para cá, limpando a pasta principal para receber os novos arquivos dos anos subsequentes.

  * `arquivo_auxiliar_geografia.csv`: Fonte aberta original do projeto.

* **`SQL/`**: Scripts estruturais do Data Warehouse.

  * `criacaoTabelas.sql`: DDL do Esquema Galáxia no PostgreSQL (Fatos, Dimensões e Chaves Estrangeiras).

  * `viewAcolhimento.sql`, `viewEquipe.sql`, `viewFamilias.sql`, `viewUnidades.sql`: Views otimizadas que abstraem as SKs (*Surrogate Keys*) e entregam modelos *One Big Table* prontos para o consumo analítico.

## Dashboards e Visualizações

*capturas de tela dos painéis finais do Apache Superset*

## Fundamentação Teórica e Bibliografia

As decisões arquiteturais e metodológicas deste projeto foram embasadas nas seguintes obras de referência:

* **KIMBALL, Ralph; ROSS, Margy.** *The Data Warehouse Toolkit: The Complete Guide to Dimensional Modeling.* Wiley, 2.ed.

* **GOLFARELLI, Matteo; RIZZI, Stefano.** *Data Warehouse Design: Modern Principles and Methodologies.* McGraw-Hill.

* **INMON, W. H.** *Building the Data Warehouse.* Wiley, 3.ed.

## Como Reproduzir o Ambiente

1. **Banco de Dados:** Execute os scripts da pasta `/SQL` em uma instância PostgreSQL local para gerar o schema `sfa`, as tabelas e views.

2. **Pipeline de Dados:** Abra os arquivos da pasta `/Pentaho` no PDI, configure a string de conexão local e execute o fluxo a partir dos `/jobs` para popular o DW utilizando as bases brutas localizadas em `/Planilhas`.

3. **Visualização:** Conecte o Apache Superset ao banco criado e importe as *Views* (ex: `vw_superset_fato_acolhimento`) como *Datasets* físicos para iniciar as análises.
