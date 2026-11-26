-- ============================================================
-- 1. Verificação de chaves estrangeiras e utilização do
--    Unknown Member (SK = 0) na tabela fato_unidades
-- ============================================================
SELECT
	COUNT(*) AS TOTAL_REGISTROS,
	COUNT(*) FILTER (
		WHERE
			SK_GEOGRAFIA IS NULL
			OR SK_TEMPO IS NULL
			OR SK_GESTAO IS NULL
	) AS FKS_NULAS,
	COUNT(*) FILTER (
		WHERE
			SK_GEOGRAFIA = 0
	) AS SK_GEO_ZERO,
	COUNT(*) FILTER (
		WHERE
			SK_GESTAO = 0
	) AS SK_GESTAO_ZERO
FROM
	SFA.FATO_UNIDADES;

-- ============================================================
-- 2. Apuração de indicadores representativos para conferência
--    dos resultados apresentados nos painéis do Apache Superset
-- ============================================================
SELECT
	COUNT(*) AS TOTAL_UNIDADES
FROM
	SFA.FATO_UNIDADES;

SELECT
	SUM(NU_ACOLHIDOS_ATUAL) AS TOTAL_ACOLHIDOS
FROM
	SFA.FATO_ACOLHIMENTO
WHERE
	NU_ACOLHIDOS_ATUAL >= 0;

SELECT
	COUNT(*) AS TOTAL_FAMILIAS
FROM
	SFA.FATO_FAMILIAS;

-- ============================================================
-- 3. Levantamento da quantidade de registros e diagnóstico
--    do preenchimento das chaves estrangeiras nas tabelas
--    dimensionais e de fatos do Data Warehouse
-- ============================================================
SELECT
	'dim_geografia' AS TABELA,
	COUNT(*) AS TOTAL,
	0 AS FKS_NULAS,
	0 AS SK_GEO_ZERO,
	0 AS SK_GESTAO_ZERO
FROM
	SFA.DIM_GEOGRAFIA
UNION ALL
SELECT
	'dim_gestao',
	COUNT(*),
	0,
	0,
	0
FROM
	SFA.DIM_GESTAO
UNION ALL
SELECT
	'dim_tempo',
	COUNT(*),
	0,
	0,
	0
FROM
	SFA.DIM_TEMPO
UNION ALL
SELECT
	'fato_unidades',
	COUNT(*),
	COUNT(*) FILTER (
		WHERE
			SK_GEOGRAFIA IS NULL
			OR SK_TEMPO IS NULL
			OR SK_GESTAO IS NULL
	),
	COUNT(*) FILTER (
		WHERE
			SK_GEOGRAFIA = 0
	),
	COUNT(*) FILTER (
		WHERE
			SK_GESTAO = 0
	)
FROM
	SFA.FATO_UNIDADES
UNION ALL
SELECT
	'fato_acolhimento',
	COUNT(*),
	COUNT(*) FILTER (
		WHERE
			SK_GEOGRAFIA IS NULL
			OR SK_TEMPO IS NULL
			OR SK_GESTAO IS NULL
	),
	COUNT(*) FILTER (
		WHERE
			SK_GEOGRAFIA = 0
	),
	COUNT(*) FILTER (
		WHERE
			SK_GESTAO = 0
	)
FROM
	SFA.FATO_ACOLHIMENTO
UNION ALL
SELECT
	'fato_equipe',
	COUNT(*),
	COUNT(*) FILTER (
		WHERE
			SK_GEOGRAFIA IS NULL
			OR SK_TEMPO IS NULL
			OR SK_GESTAO IS NULL
	),
	COUNT(*) FILTER (
		WHERE
			SK_GEOGRAFIA = 0
	),
	COUNT(*) FILTER (
		WHERE
			SK_GESTAO = 0
	)
FROM
	SFA.FATO_EQUIPE
UNION ALL
SELECT
	'fato_familias',
	COUNT(*),
	COUNT(*) FILTER (
		WHERE
			SK_GEOGRAFIA IS NULL
			OR SK_TEMPO IS NULL
			OR SK_GESTAO IS NULL
	),
	COUNT(*) FILTER (
		WHERE
			SK_GEOGRAFIA = 0
	),
	COUNT(*) FILTER (
		WHERE
			SK_GESTAO = 0
	)
FROM
	SFA.FATO_FAMILIAS;

-- ============================================================
-- 4. Auditoria do tratamento de valores ausentes (-1) nas
--    principais métricas numéricas da tabela fato_unidades
-- ============================================================
SELECT
	'vl_custo_mensal' AS ATRIBUTO,
	COUNT(*) FILTER (
		WHERE
			VL_CUSTO_MENSAL = -1
	) AS QTD_MENOS_UM,
	COUNT(*) FILTER (
		WHERE
			VL_CUSTO_MENSAL >= 0
	) AS QTD_VALIDOS
FROM
	SFA.FATO_UNIDADES
UNION ALL
SELECT
	'vl_subsidio_mensal',
	COUNT(*) FILTER (
		WHERE
			VL_SUBSIDIO_MENSAL = -1
	),
	COUNT(*) FILTER (
		WHERE
			VL_SUBSIDIO_MENSAL >= 0
	)
FROM
	SFA.FATO_UNIDADES
UNION ALL
SELECT
	'nu_capacidade',
	COUNT(*) FILTER (
		WHERE
			NU_CAPACIDADE = -1
	),
	COUNT(*) FILTER (
		WHERE
			NU_CAPACIDADE >= 0
	)
FROM
	SFA.FATO_UNIDADES
UNION ALL
SELECT
	'nu_acolhidos_atual (unidades)',
	COUNT(*) FILTER (
		WHERE
			NU_ACOLHIDOS_ATUAL = -1
	),
	COUNT(*) FILTER (
		WHERE
			NU_ACOLHIDOS_ATUAL >= 0
	)
FROM
	SFA.FATO_UNIDADES;

-- ============================================================
-- 5. Auditoria do tratamento de valores ausentes (-1) nas
--    principais métricas numéricas da tabela fato_acolhimento
-- ============================================================
SELECT
	'nu_acolhidos_atual (acolhimento)',
	COUNT(*) FILTER (
		WHERE
			NU_ACOLHIDOS_ATUAL = -1
	),
	COUNT(*) FILTER (
		WHERE
			NU_ACOLHIDOS_ATUAL >= 0
	)
FROM
	SFA.FATO_ACOLHIMENTO
UNION ALL
SELECT
	'nu_acolhidos_12m',
	COUNT(*) FILTER (
		WHERE
			NU_ACOLHIDOS_12M = -1
	),
	COUNT(*) FILTER (
		WHERE
			NU_ACOLHIDOS_12M >= 0
	)
FROM
	SFA.FATO_ACOLHIMENTO;

-- ============================================================
-- 6. Consolidação dos quantitativos e indicadores da tabela
--    fato_unidades para conferência dos resultados apresentados
--    nos Quadros 4, 5 e 6 e na Seção 4.6.1 do trabalho
-- ============================================================
SELECT
	COUNT(*) AS TOTAL_UNIDADES,
	COUNT(*) FILTER (
		WHERE
			VL_CUSTO_MENSAL = -1
	) AS CUSTO_MENOS1,
	COUNT(*) FILTER (
		WHERE
			VL_CUSTO_MENSAL >= 0
	) AS CUSTO_VALIDO,
	SUM(NULLIF(VL_CUSTO_MENSAL, -1)) AS CUSTO_MENSAL_TOTAL,
	COUNT(*) FILTER (
		WHERE
			NU_CAPACIDADE = -1
	) AS CAP_MENOS1,
	COUNT(*) FILTER (
		WHERE
			NU_CAPACIDADE >= 0
	) AS CAP_VALIDO,
	SUM(NULLIF(NU_CAPACIDADE, -1)) AS CAPACIDADE_TOTAL,
	SUM(
		CASE
			WHEN DS_MODALIDADE <> 'Família Acolhedora' THEN NULLIF(NU_ACOLHIDOS_ATUAL, -1)
			ELSE 0
		END
	) AS ACOLHIDOS_INSTITUCIONAL
FROM
	SFA.FATO_UNIDADES;

-- ============================================================
-- 7. Distribuição quantitativa dos registros da fato_unidades
--    de acordo com a modalidade de acolhimento
-- ============================================================
SELECT
	DS_MODALIDADE,
	COUNT(*) AS QTD
FROM
	SFA.FATO_UNIDADES
GROUP BY
	DS_MODALIDADE;

-- ============================================================
-- 8. Conferência do quantitativo de registros da dimensão
--    geográfica para atualização dos resultados apresentados
--    no Quadro 4
-- ============================================================
SELECT
	COUNT(*) AS TOTAL_GEOGRAFIA
FROM
	SFA.DIM_GEOGRAFIA;

-- ============================================================
-- 9. Apuração dos quantitativos de readmissões por modalidade
--    de encaminhamento, conforme os atributos disponíveis
--    na tabela fato_acolhimento
-- ============================================================
SELECT
	SUM(NULLIF(NU_READM_FAM_ORIGEM, -1)) AS FAM_ORIGEM,
	SUM(NULLIF(NU_READM_FAM_EXTENSA, -1)) AS FAM_EXTENSA,
	SUM(NULLIF(NU_READM_ADOCAO, -1)) AS ADOCAO
FROM
	SFA.FATO_ACOLHIMENTO;