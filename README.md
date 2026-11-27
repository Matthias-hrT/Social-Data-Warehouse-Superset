# Social Data Warehouse & BI: Programa Família Acolhedora (Censo SUAS 2024)

## Sobre o projeto

Este repositório reúne os artefatos técnicos do Trabalho de Conclusão de Curso (TCC) de Engenharia de Computação da UTFPR (Câmpus Apucarana):

> VANZELA, Matheus Hirata. *Aplicação de Business Intelligence em dados abertos governamentais para suporte a tomada de decisão*. Trabalho de Conclusão de Curso (Bacharelado em Engenharia de Computação) – Universidade Tecnológica Federal do Paraná, Apucarana, 2026. Orientador: Prof. Dr. Wendel Góes Pedrozo.

O objetivo é transformar os microdados do Censo SUAS 2024 (programa Família Acolhedora e unidades de acolhimento institucional para crianças e adolescentes) em indicadores analíticos consistentes, por meio de um Data Warehouse em PostgreSQL, rotinas de ETL no Pentaho Data Integration e painéis interativos no Apache Superset. A solução usa exclusivamente ferramentas de código aberto.

## Arquitetura e modelagem

- **Constelação de Fatos** (Golfarelli e Rizzi), com quatro tabelas fato de granularidades distintas (`fato_unidades`, `fato_acolhimento`, `fato_equipe`, `fato_familias`) que compartilham três dimensões conformadas (`dim_geografia`, `dim_gestao`, `dim_tempo`).
- **Modelagem dimensional** conforme Kimball: dimensões conformadas, chaves substitutas (*surrogate keys*) e membro desconhecido (SK = 0).
- **SCD tipo 2** nas dimensões `dim_geografia` e `dim_gestao` (colunas `version`, `date_from`, `date_to`), preparadas para receber edições futuras do Censo.
- **Tratamento de dados no PDI** (limpeza, padronização textual, correção de códigos IBGE, tipagem) antes da carga, seguindo os princípios de qualidade de dados e *staging* de Inmon.
- **Valores ausentes:** `-1` marca "sem resposta" em métricas numéricas; `NULL` indica atributo não aplicável à modalidade. As agregações descartam o `-1`.
- **12 Materialized Views** (4 consolidadas por tabela fato e 8 temáticas com *unpivot*) isolam as regras de negócio e simplificam o consumo pelo Superset.

## Tecnologias

| Camada | Ferramenta | Versão |
|---|---|---|
| Banco de dados | PostgreSQL | 18.1 |
| ETL | Pentaho Data Integration (Kettle), versão legada disponível em [ambientelivre/legacy-pentaho-ce](https://github.com/ambientelivre/legacy-pentaho-ce) | 9.4 |
| Visualização | Apache Superset (Docker) | 6.1.0 |
| Cliente SQL | pgAdmin 4 | 9.11 |

## Estrutura do repositório

```
Pentaho/
  auxiliares/   data_versionamento.ktr   (data de referência do Censo, usada no versionamento)
  dimensoes/    Dim_Geografia.ktr, Dim_Gestao.ktr, Dim_Tempo.ktr
  fato/         Fato_Unidades.ktr, Fato_Acolhimento.ktr, Fato_Equipe.ktr, Fato_Familias.ktr
  jobs/         TCC.kjb (job principal), Job Fatos.kjb (carga das tabelas fato)
Planilhas/      arquivos de entrada do ETL (ver "Dados")
SQL/            criacaoTabelas.sql, view*.sql (12 views), validarDados.sql
```

### Scripts SQL

| Arquivo | O que faz |
|---|---|
| `criacaoTabelas.sql` | Cria o esquema `sfa`, as dimensões, as tabelas fato e as chaves estrangeiras |
| `viewUnidades.sql`, `viewAcolhimento.sql`, `viewFamilias.sql`, `viewEquipe.sql` | Views consolidadas: `vw_fato_unidades`, `vw_fato_acolhimento`, `vw_fato_familias`, `vw_fato_equipe` |
| `viewRaca.sql`, `viewIdade.sql`, `viewMotivo.sql`, `viewCondicao.sql`, `viewTempo.sql`, `viewSaida.sql`, `viewReadmissao.sql`, `viewDivulgacao.sql` | Views temáticas com *unpivot* (`vw_fato_acolhimento_raca`, `_idade`, `_motivo`, `_condicao`, `_tempo`, `_saida`, `_readmissao` e `vw_fato_unidades_divulgacao`) |
| `validarDados.sql` | Consultas de verificação do DW, cada uma com o resultado esperado |

## Dados

Os microdados são do **Censo SUAS 2024**, do Ministério do Desenvolvimento e Assistência Social, Família e Combate à Fome (MDS): <https://aplicacoes.mds.gov.br/sagi/snas/vigilancia/index2.php>.

| Arquivo | Origem | Está no repositório? |
|---|---|---|
| `Dados_Gerais.csv`, `RH_Equipe.csv`, `RH_Familia.csv` (programa Família Acolhedora) | Portal de dados abertos do MDS | Sim, em `Planilhas/Processados/` |
| `Unidade_Acolhimento.csv` (abrigos institucionais e casas-lar) | Cedida diretamente pelo MDS; **não consta no portal de dados abertos** | **Não.** Deve ser solicitada ao MDS |
| `arquivo_auxiliar_geografia.csv` e `municipios.csv` | Tabela de municípios e códigos IBGE e coordenadas (latitude e longitude) dos municípios, do repositório aberto [kelvins/municipios-brasileiros](https://github.com/kelvins/municipios-brasileiros), estruturado a partir de dados oficiais do IBGE | Sim |

Os dados tratados são agregados ou descritivos (sem nome, documento ou endereço residencial de pessoas) e tratam-se de dados anonimizados no sentido da LGPD. Detalhes na seção 3.8 do TCC.

## Como reproduzir

**Pré-requisitos:** PostgreSQL, Pentaho Data Integration 9.4 e Apache Superset (ver versões acima).

1. **Banco de dados:** crie um banco no PostgreSQL e execute `SQL/criacaoTabelas.sql`. Em seguida, execute os 12 arquivos `SQL/view*.sql` para criar as visões materializadas.
2. **Arquivos de entrada:** coloque os quatro CSVs do Censo diretamente na pasta `Planilhas/`. Os três arquivos do Família Acolhedora estão em `Planilhas/Processados/`, porque o job arquiva os arquivos depois de usá-los: copie-os de volta para `Planilhas/` antes de rodar. O `Unidade_Acolhimento.csv` deve ser obtido junto ao MDS.
3. **ETL:** abra os arquivos da pasta `Pentaho/` no PDI, ajuste a conexão com o seu PostgreSQL e execute `jobs/TCC.kjb`. O job começa limpando as tabelas fato (a carga é repetível), carrega as dimensões e depois as fatos, arquiva os arquivos processados e atualiza as visões materializadas.
   - Nos passos de leitura dos CSVs, mantenha a codificação **UTF-8**. Com outra codificação, os acentos são gravados de forma corrompida.
4. **Verificação:** execute `SQL/validarDados.sql` e compare cada resultado com a linha `Esperado`.
5. **Visualização:** conecte o Apache Superset ao banco e crie *datasets* a partir das 12 visões `vw_*`. Os painéis do trabalho (abas Unidades, Acolhimento e Famílias e Equipe) estão descritos e ilustrados no capítulo 4 do TCC.

## Limitações a ter em mente

- O Censo é declaratório e transversal (data de referência 31/08/2024); não há série histórica.
- Os mapas usam o centro de cada município, e não a localização exata das unidades.
- O custo mensal da Família Acolhedora informado na fonte é incompatível com os demais indicadores e não deve ser comparado ao das unidades institucionais (seção 4.6.1 do TCC).

## Referências principais

- GOLFARELLI, Matteo; RIZZI, Stefano. *Data Warehouse Design: Modern Principles and Methodologies*. McGraw-Hill, 2009.
- INMON, W. H. *Como Construir o Data Warehouse*. Rio de Janeiro: Campus, 1997.
- KIMBALL, Ralph. *The Data Warehouse Toolkit: The Complete Guide to Dimensional Modeling*. John Wiley & Sons, 1996.

<!-- Depois de adicionar as capturas (Figuras 11 a 13 do TCC) numa pasta imagens/, remova este comentário:
## Painéis
![Aba Unidades](imagens/aba_unidades.png)
![Aba Acolhimento](imagens/aba_acolhimento.png)
![Aba Famílias e Equipe](imagens/aba_familias_equipe.png)
-->
