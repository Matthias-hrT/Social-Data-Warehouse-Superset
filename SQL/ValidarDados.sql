-- =====================================================================
-- validarDados.sql
-- Consultas de verificação do Data Warehouse (esquema sfa) - Censo SUAS 2024
--
-- COMO USAR
--   1. Rode o job completo do Pentaho (carga das dimensões e das fatos).
--   2. Confirme que as 12 views materializadas foram atualizadas
--      (refresh materialized view).
--   3. Rode cada bloco abaixo no pgAdmin e compare com a linha "Esperado".
--
-- Cada bloco indica a Seção ou o Quadro do TCC que ele sustenta.
-- Os valores esperados são os da carga final do trabalho (Censo SUAS 2024).
--
-- Observação: o valor -1 é o marcador técnico de "sem resposta".
-- Por isso as somas usam nullif(coluna, -1), que ignora esse marcador.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1) Linhas carregadas e integridade das chaves  (Quadro 4 e Seção 4.3)
--    fks_nulas   = registros com alguma chave estrangeira vazia
--    sk_*_zero   = registros ligados ao "membro desconhecido" (SK = 0)
--    Esperado: dim_geografia 2073 | dim_gestao 3 | dim_tempo 1
--              fato_unidades 3502 | fato_acolhimento 670
--              fato_equipe 2270   | fato_familias 3598
--              e ZERO em fks_nulas, sk_geo_zero e sk_gestao_zero.
-- ---------------------------------------------------------------------
select 'dim_geografia' as tabela, count(*) as linhas,
       null::bigint as fks_nulas, null::bigint as sk_geo_zero, null::bigint as sk_gestao_zero
from sfa.dim_geografia
union all select 'dim_gestao', count(*), null, null, null from sfa.dim_gestao
union all select 'dim_tempo',  count(*), null, null, null from sfa.dim_tempo
union all
select 'fato_unidades', count(*),
       count(*) filter (where sk_geografia is null or sk_gestao is null or sk_tempo is null),
       count(*) filter (where sk_geografia = 0),
       count(*) filter (where sk_gestao = 0)
from sfa.fato_unidades
union all
select 'fato_acolhimento', count(*),
       count(*) filter (where sk_geografia is null or sk_gestao is null or sk_tempo is null),
       count(*) filter (where sk_geografia = 0),
       count(*) filter (where sk_gestao = 0)
from sfa.fato_acolhimento
union all
select 'fato_equipe', count(*),
       count(*) filter (where sk_geografia is null or sk_gestao is null or sk_tempo is null),
       count(*) filter (where sk_geografia = 0),
       count(*) filter (where sk_gestao = 0)
from sfa.fato_equipe
union all
select 'fato_familias', count(*),
       count(*) filter (where sk_geografia is null or sk_gestao is null or sk_tempo is null),
       count(*) filter (where sk_geografia = 0),
       count(*) filter (where sk_gestao = 0)
from sfa.fato_familias;


-- ---------------------------------------------------------------------
-- 2) Auditoria do marcador -1  (Quadro 5 e Seção 4.3)
--    com_menos1 = registros sem resposta | validos = registros com valor >= 0
--    Esperado (com_menos1 / validos):
--      vl_custo_mensal            1728 / 1774
--      vl_subsidio_mensal           28 /  642   (só Família Acolhedora)
--      nu_capacidade                 0 / 2832   (só unidades institucionais)
--      nu_acolhidos_atual (unid.)    0 / 3502
--      nu_acolhidos_atual (acolh.)   0 /  670
--      nu_acolhidos_12m              8 /  662
-- ---------------------------------------------------------------------
select 'vl_custo_mensal (fato_unidades)' as atributo,
       count(*) filter (where vl_custo_mensal = -1) as com_menos1,
       count(*) filter (where vl_custo_mensal >= 0) as validos
from sfa.fato_unidades
union all
select 'vl_subsidio_mensal (fato_unidades)',
       count(*) filter (where vl_subsidio_mensal = -1),
       count(*) filter (where vl_subsidio_mensal >= 0)
from sfa.fato_unidades
union all
select 'nu_capacidade (fato_unidades)',
       count(*) filter (where nu_capacidade = -1),
       count(*) filter (where nu_capacidade >= 0)
from sfa.fato_unidades
union all
select 'nu_acolhidos_atual (fato_unidades)',
       count(*) filter (where nu_acolhidos_atual = -1),
       count(*) filter (where nu_acolhidos_atual >= 0)
from sfa.fato_unidades
union all
select 'nu_acolhidos_atual (fato_acolhimento)',
       count(*) filter (where nu_acolhidos_atual = -1),
       count(*) filter (where nu_acolhidos_atual >= 0)
from sfa.fato_acolhimento
union all
select 'nu_acolhidos_12m (fato_acolhimento)',
       count(*) filter (where nu_acolhidos_12m = -1),
       count(*) filter (where nu_acolhidos_12m >= 0)
from sfa.fato_acolhimento;


-- ---------------------------------------------------------------------
-- 3) Totais para conferir com os cartões do Superset  (Seções 3.7 e 4.6.2)
--    Esperado: unidades 3502 | acolhidos_atuais 2477 | acolhidos_12m 4023
--              pbf 1055 | baixa_renda 984 | profissionais 2270 | familias 3598
-- ---------------------------------------------------------------------
select (select count(*) from sfa.fato_unidades)                         as unidades,
       (select sum(nullif(nu_acolhidos_atual, -1)) from sfa.fato_acolhimento) as acolhidos_atuais,
       (select sum(nullif(nu_acolhidos_12m, -1))   from sfa.fato_acolhimento) as acolhidos_12m,
       (select sum(nullif(nu_pbf, -1))             from sfa.fato_acolhimento) as pbf,
       (select sum(nullif(nu_baixa_renda, -1))     from sfa.fato_acolhimento) as baixa_renda,
       (select count(*) from sfa.fato_equipe)                           as profissionais,
       (select count(*) from sfa.fato_familias)                         as familias;

-- Readmissões por destino anterior.  Esperado: 142 | 80 | 47 (total 269)
select sum(nullif(nu_readm_fam_origem, -1))  as fam_origem,
       sum(nullif(nu_readm_fam_extensa, -1)) as fam_extensa,
       sum(nullif(nu_readm_adocao, -1))      as adocao
from sfa.fato_acolhimento;


-- ---------------------------------------------------------------------
-- 4) Consistência interna da fato_acolhimento  (Quadro 6)
--    Compara: total por sexo x soma das faixas etárias, e
--    total de acolhidos x (masculino + feminino).
--    Esperado: linhas = 670 e ZERO nas três colunas de divergência.
-- ---------------------------------------------------------------------
with t as (
  select nu_acolhidos_atual, nu_masc_total, nu_fem_total,
         coalesce(nullif(nu_masc_0a2,-1),0)   + coalesce(nullif(nu_masc_3a5,-1),0)
       + coalesce(nullif(nu_masc_6a11,-1),0)  + coalesce(nullif(nu_masc_12a13,-1),0)
       + coalesce(nullif(nu_masc_14a15,-1),0) + coalesce(nullif(nu_masc_16a17,-1),0)
       + coalesce(nullif(nu_masc_18mais,-1),0) as soma_masc,
         coalesce(nullif(nu_fem_0a2,-1),0)    + coalesce(nullif(nu_fem_3a5,-1),0)
       + coalesce(nullif(nu_fem_6a11,-1),0)   + coalesce(nullif(nu_fem_12a13,-1),0)
       + coalesce(nullif(nu_fem_14a15,-1),0)  + coalesce(nullif(nu_fem_16a17,-1),0)
       + coalesce(nullif(nu_fem_18mais,-1),0) as soma_fem
  from sfa.fato_acolhimento
)
select count(*) as linhas,
       count(*) filter (where nu_masc_total >= 0 and nu_masc_total <> soma_masc) as masc_diverge,
       count(*) filter (where nu_fem_total  >= 0 and nu_fem_total  <> soma_fem)  as fem_diverge,
       count(*) filter (where nu_acolhidos_atual >= 0 and nu_masc_total >= 0 and nu_fem_total >= 0
                          and nu_acolhidos_atual <> nu_masc_total + nu_fem_total) as total_diverge
from t;

-- Unidades de Família Acolhedora sem nenhum acolhido na data do Censo.
-- Esperado: 261 (de 670)
select count(*) filter (where nu_acolhidos_atual = 0) as fa_sem_acolhidos,
       count(*) as fa_total
from sfa.fato_acolhimento;


-- ---------------------------------------------------------------------
-- 5) Modalidades, capacidade e ocupação  (Seção 4.6.1)
--    Esperado: Abrigo Institucional 2046 | Casa-Lar 752
--              Família Acolhedora 670 | Outro 34
--              vagas 46825 | acolhidos 30600 | taxa_ocupacao 65.35
-- ---------------------------------------------------------------------
select ds_modalidade as modalidade, count(*) as unidades
from sfa.fato_unidades
group by 1
order by 2 desc;

select sum(nu_capacidade)       filter (where nu_capacidade >= 0)       as vagas,
       sum(nu_acolhidos_atual)  filter (where nu_acolhidos_atual >= 0)  as acolhidos,
       round(100.0 * sum(nu_acolhidos_atual) filter (where nu_acolhidos_atual >= 0)
                   / sum(nu_capacidade)      filter (where nu_capacidade >= 0), 2) as taxa_ocupacao
from sfa.fato_unidades
where ds_modalidade not ilike 'fam%';      -- só unidades institucionais


-- ---------------------------------------------------------------------
-- 6) Custo mensal declarado por modalidade  (Seções 4.3 e 4.6.1)
--    Esperado (unidades com custo / total):
--      Abrigo 1190/2046 | Casa-Lar 521/752 | Outro 18/34 | Família Acolhedora 45/670
--      Soma institucional = 139.636.198,60 | Soma geral = 360.739.517,60
-- ---------------------------------------------------------------------
select ds_modalidade as modalidade,
       count(*)                                     as unidades,
       count(*) filter (where vl_custo_mensal >= 0) as com_custo,
       round(100.0 * count(*) filter (where vl_custo_mensal >= 0) / count(*), 1) as pct_com_custo
from sfa.fato_unidades
group by 1
order by 1;

-- Mediana, média e soma (só unidades que informaram o custo).
-- Esperado: mediana Abrigo 66.817,10 | Casa-Lar 40.100,00 | Família Acolhedora 3.116.437,00
--           média Abrigo 87.882,23
select ds_modalidade as modalidade,
       count(*)                                                                  as n,
       round((percentile_cont(0.5) within group (order by vl_custo_mensal))::numeric, 2) as mediana,
       round(avg(vl_custo_mensal)::numeric, 2)                                   as media,
       sum(vl_custo_mensal)                                                      as soma
from sfa.fato_unidades
where vl_custo_mensal >= 0
group by 1
order by 1;

-- Custo por acolhido = soma dos custos / soma dos acolhidos.
-- Esperado: Abrigo 7.536,74 | Casa-Lar 6.592,53 | Outro 4.735,89
--           Família Acolhedora 453.080,57 (valor implausível, ver bloco 8)
select ds_modalidade as modalidade,
       round(sum(vl_custo_mensal) / nullif(sum(nu_acolhidos_atual), 0), 2) as custo_por_acolhido
from sfa.fato_unidades
where vl_custo_mensal >= 0 and nu_acolhidos_atual >= 0
group by 1
order by 1;


-- ---------------------------------------------------------------------
-- 7) Valores extremos nas unidades institucionais  (Seção 4.6.1)
--    Critério de Tukey sobre o custo POR ACOLHIDO: acima de Q3 + 1,5 x (Q3 - Q1).
--    Os dados NÃO são alterados; é só uma análise de sensibilidade.
--    Esperado (unidades / acima_do_limite):
--      Abrigo Institucional 1162 / 107  (limite ~ 18.640)
--      Casa-Lar              495 /  43  (limite ~ 14.929)
--      Outro                  18 /   2
--    mediana_custo_por_acolhido: ~6.667 | ~5.045 | ~5.750
-- ---------------------------------------------------------------------
with base as (
  select ds_modalidade as modalidade, vl_custo_mensal,
         vl_custo_mensal / nullif(nu_acolhidos_atual, 0) as custo_por_acolhido
  from sfa.fato_unidades
  where vl_custo_mensal > 0
    and nu_acolhidos_atual > 0
    and ds_modalidade not ilike 'fam%'
), lim as (
  select modalidade,
         percentile_cont(0.25) within group (order by custo_por_acolhido) as q1,
         percentile_cont(0.50) within group (order by custo_por_acolhido) as mediana,
         percentile_cont(0.75) within group (order by custo_por_acolhido) as q3
  from base
  group by modalidade
)
select l.modalidade,
       count(*)                                        as unidades,
       round(l.mediana::numeric, 0)                    as mediana_custo_por_acolhido,
       round((l.q3 + 1.5 * (l.q3 - l.q1))::numeric, 0) as limite_superior,
       count(*) filter (where b.custo_por_acolhido > l.q3 + 1.5 * (l.q3 - l.q1)) as acima_do_limite,
       sum(b.vl_custo_mensal)                          as soma_total,
       sum(b.vl_custo_mensal) filter (where b.custo_por_acolhido <= l.q3 + 1.5 * (l.q3 - l.q1)) as soma_sem_extremos
from base b
join lim l using (modalidade)
group by l.modalidade, l.mediana, l.q1, l.q3
order by l.modalidade;


-- ---------------------------------------------------------------------
-- 8) Custo da Família Acolhedora: por que os valores são implausíveis  (Seção 4.6.1)
--    Um serviço de Família Acolhedora gasta com subsídio (valor x acolhidos)
--    mais equipe e estrutura. O custo mensal deveria ser de 1 a ~5 vezes
--    o total de subsídios (razão). Aqui a razão direta é de centenas,
--    o que indica problema de escala ou de preenchimento na fonte.
--    Esperado: mediana_razao_direta ~ 278 | mediana_razao_se_centavos ~ 2,78
-- ---------------------------------------------------------------------
select count(*) as n,
       round((percentile_cont(0.5) within group (order by razao))::numeric, 1)       as mediana_razao_direta,
       round((percentile_cont(0.5) within group (order by razao / 100))::numeric, 2) as mediana_razao_se_centavos
from (
  select vl_custo_mensal / (vl_subsidio_mensal * nu_acolhidos_atual) as razao
  from sfa.fato_unidades
  where ds_modalidade ilike 'fam%'
    and vl_custo_mensal > 0
    and vl_subsidio_mensal > 0
    and nu_acolhidos_atual > 0
) t;

-- Subsídio mensal por família (para comparar: este campo está coerente).
-- Esperado: n = 642 | mediana = 1412 (salário mínimo de 2024)
select count(*) as n,
       min(vl_subsidio_mensal) as minimo,
       percentile_cont(0.5) within group (order by vl_subsidio_mensal) as mediana,
       max(vl_subsidio_mensal) as maximo
from sfa.fato_unidades
where vl_subsidio_mensal >= 0;


-- ---------------------------------------------------------------------
-- 9) Texto corrompido por erro de codificação  (reprodutibilidade do ETL)
--    Se o PDI ler o CSV sem UTF-8, "Região" vira "RegiÃ£o".
--    Procura "Ã" seguido de caractere estranho (o "Ã" de SÃO não conta).
--    Esperado: as DUAS consultas devem voltar VAZIAS.
-- ---------------------------------------------------------------------
-- a) tabelas do esquema sfa
select table_name, column_name, qtd
from (
  select table_name, column_name,
         (xpath('/row/c/text()',
            query_to_xml(format('select count(*) as c from %I.%I where %I::text ~ %L',
                                table_schema, table_name, column_name, 'Ã[\u0080-\u00BF]'),
                         false, true, '')))[1]::text::int as qtd
  from information_schema.columns
  where table_schema = 'sfa'
    and data_type in ('text', 'character varying', 'character')
) t
where qtd > 0;

-- b) definições das views materializadas
select matviewname
from pg_matviews
where schemaname = 'sfa' and definition ~ 'Ã[\u0080-\u00BF]';


-- ---------------------------------------------------------------------
-- 10) Desempenho das views materializadas  (Seção 4.4)
--     Compara ler a view pronta x refazer o unpivot a cada consulta.
--     Rode cada explain 5 vezes e use a MEDIANA do "Execution Time"
--     (a 1ª execução costuma ser mais lenta, por cache frio).
--     Esperado (varia conforme a máquina): view ~0,11 ms | sem view ~2,75 ms
--     (cerca de 25 vezes mais rápido com a view).
-- ---------------------------------------------------------------------
-- a) número de linhas da view (usar no texto da Seção 4.4)
select count(*) as linhas_da_view from sfa.vw_fato_acolhimento_idade;

-- b) cria uma view comum, temporária (só vale nesta sessão do pgAdmin),
--    com a MESMA consulta da view materializada
drop view if exists pg_temp.tmp_idade;
do $$
begin
  execute 'create temp view tmp_idade as '
       || (select definition from pg_matviews
           where schemaname = 'sfa' and matviewname = 'vw_fato_acolhimento_idade');
end $$;

-- c) COM a view materializada (lê o resultado já pronto)
explain (analyze, buffers) select * from sfa.vw_fato_acolhimento_idade;

-- d) SEM a view (refaz o unpivot e os joins a cada execução)
explain (analyze, buffers) select * from tmp_idade;