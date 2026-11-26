-- 1. Verificar FKs nulas e uso do Unknown Member (SK = 0) em fato_unidades
SELECT
    COUNT(*) AS total_registros,
    COUNT(*) FILTER (WHERE sk_geografia IS NULL OR sk_tempo IS NULL OR sk_gestao IS NULL) AS fks_nulas,
    COUNT(*) FILTER (WHERE sk_geografia = 0) AS sk_geo_zero,
    COUNT(*) FILTER (WHERE sk_gestao = 0) AS sk_gestao_zero
FROM sfa.fato_unidades;

-- 2. Indicadores representativos para comparar com o Superset
SELECT COUNT(*) AS total_unidades FROM sfa.fato_unidades;
SELECT SUM(nu_acolhidos_atual) AS total_acolhidos FROM sfa.fato_acolhimento WHERE nu_acolhidos_atual >= 0;
SELECT COUNT(*) AS total_familias FROM sfa.fato_familias;

-- 3. Contagem geral e integridade referencial de todas as tabelas do DW
SELECT 'dim_geografia' AS tabela, COUNT(*) AS total, 0 AS fks_nulas, 0 AS sk_geo_zero, 0 AS sk_gestao_zero FROM sfa.dim_geografia
UNION ALL
SELECT 'dim_gestao', COUNT(*), 0, 0, 0 FROM sfa.dim_gestao
UNION ALL
SELECT 'dim_tempo', COUNT(*), 0, 0, 0 FROM sfa.dim_tempo
UNION ALL
SELECT 'fato_unidades', COUNT(*),
       COUNT(*) FILTER (WHERE sk_geografia IS NULL OR sk_tempo IS NULL OR sk_gestao IS NULL),
       COUNT(*) FILTER (WHERE sk_geografia = 0),
       COUNT(*) FILTER (WHERE sk_gestao = 0)
FROM sfa.fato_unidades
UNION ALL
SELECT 'fato_acolhimento', COUNT(*),
       COUNT(*) FILTER (WHERE sk_geografia IS NULL OR sk_tempo IS NULL OR sk_gestao IS NULL),
       COUNT(*) FILTER (WHERE sk_geografia = 0),
       COUNT(*) FILTER (WHERE sk_gestao = 0)
FROM sfa.fato_acolhimento
UNION ALL
SELECT 'fato_equipe', COUNT(*),
       COUNT(*) FILTER (WHERE sk_geografia IS NULL OR sk_tempo IS NULL OR sk_gestao IS NULL),
       COUNT(*) FILTER (WHERE sk_geografia = 0),
       COUNT(*) FILTER (WHERE sk_gestao = 0)
FROM sfa.fato_equipe
UNION ALL
SELECT 'fato_familias', COUNT(*),
       COUNT(*) FILTER (WHERE sk_geografia IS NULL OR sk_tempo IS NULL OR sk_gestao IS NULL),
       COUNT(*) FILTER (WHERE sk_geografia = 0),
       COUNT(*) FILTER (WHERE sk_gestao = 0)
FROM sfa.fato_familias;

-- 4. Auditoria de ausências (-1) nas principais métricas numéricas de fato_unidades
SELECT
    'vl_custo_mensal' AS atributo,
    COUNT(*) FILTER (WHERE vl_custo_mensal = -1) AS qtd_menos_um,
    COUNT(*) FILTER (WHERE vl_custo_mensal >= 0) AS qtd_validos
FROM sfa.fato_unidades
UNION ALL
SELECT
    'vl_subsidio_mensal',
    COUNT(*) FILTER (WHERE vl_subsidio_mensal = -1),
    COUNT(*) FILTER (WHERE vl_subsidio_mensal >= 0)
FROM sfa.fato_unidades
UNION ALL
SELECT
    'nu_capacidade',
    COUNT(*) FILTER (WHERE nu_capacidade = -1),
    COUNT(*) FILTER (WHERE nu_capacidade >= 0)
FROM sfa.fato_unidades
UNION ALL
SELECT
    'nu_acolhidos_atual (unidades)',
    COUNT(*) FILTER (WHERE nu_acolhidos_atual = -1),
    COUNT(*) FILTER (WHERE nu_acolhidos_atual >= 0)
FROM sfa.fato_unidades
UNION ALL
-- 5. Auditoria de ausências (-1) nas principais métricas de fato_acolhimento
SELECT
    'nu_acolhidos_atual (acolhimento)',
    COUNT(*) FILTER (WHERE nu_acolhidos_atual = -1),
    COUNT(*) FILTER (WHERE nu_acolhidos_atual >= 0)
FROM sfa.fato_acolhimento
UNION ALL
SELECT
    'nu_acolhidos_12m',
    COUNT(*) FILTER (WHERE nu_acolhidos_12m = -1),
    COUNT(*) FILTER (WHERE nu_acolhidos_12m >= 0)
FROM sfa.fato_acolhimento;

-- 6. Totais e auditoria da fato_unidades (Quadros 4, 5, 6 e Seção 4.6.1)
SELECT
    COUNT(*) AS total_unidades,
    COUNT(*) FILTER (WHERE vl_custo_mensal = -1) AS custo_menos1,
    COUNT(*) FILTER (WHERE vl_custo_mensal >= 0) AS custo_valido,
    SUM(NULLIF(vl_custo_mensal, -1)) AS custo_mensal_total,
    COUNT(*) FILTER (WHERE nu_capacidade = -1) AS cap_menos1,
    COUNT(*) FILTER (WHERE nu_capacidade >= 0) AS cap_valido,
    SUM(NULLIF(nu_capacidade, -1)) AS capacidade_total,
    SUM(CASE WHEN ds_modalidade <> 'Família Acolhedora' THEN NULLIF(nu_acolhidos_atual, -1) ELSE 0 END) AS acolhidos_institucional
FROM sfa.fato_unidades;

-- 7. Distribuição por modalidade (Seção 4.6.1)
SELECT ds_modalidade, COUNT(*) AS qtd
FROM sfa.fato_unidades
GROUP BY ds_modalidade;

-- 8. Novo total da dim_geografia (Quadro 4)
SELECT COUNT(*) AS total_geografia FROM sfa.dim_geografia;

SELECT
    SUM(NULLIF(nu_readm_fam_origem, -1))  AS fam_origem,
    SUM(NULLIF(nu_readm_fam_extensa, -1)) AS fam_extensa,
    SUM(NULLIF(nu_readm_adocao, -1))      AS adocao
FROM sfa.fato_acolhimento;