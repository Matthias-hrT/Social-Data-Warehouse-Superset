-- 1. Criação da View Materializada Temática
CREATE MATERIALIZED VIEW sfa.vw_fato_acolhimento_raca AS SELECT 
    -- 0. Chaves Estruturais
    fa.pk_acolhimento,
    fa.sk_tempo,
    fa.sk_geografia,
    fa.sk_gestao,
    
    -- 1. Colunas Temáticas (Geradas pelo Unpivot)
    raca.raca_cor,
    raca.quantidade,

    -- 2. Atributos da Dimensão Tempo
    t.dt_referencia,
    
    -- 3. Atributos da Dimensão Geografia
    g.cod_ibge,
    g.nm_uf,
    g.nm_municipio,
    g.sg_uf,
    g.nm_regiao,
	g.latitude,
	g.longitude,
    
    -- 4. Atributos da Dimensão Gestão
    ges.ds_tipo_gestao

FROM sfa.fato_acolhimento fa
INNER JOIN sfa.dim_tempo t ON fa.sk_tempo = t.sk_tempo
INNER JOIN sfa.dim_geografia g ON fa.sk_geografia = g.sk_geografia
INNER JOIN sfa.dim_gestao ges ON fa.sk_gestao = ges.sk_gestao
-- O Motor do Unpivot: Multiplica as linhas e empilha os dados
CROSS JOIN LATERAL (
    VALUES 
        ('Preta', fa.nu_raca_preta),
        ('Parda', fa.nu_raca_parda),
        ('Branca', fa.nu_raca_branca),
        ('Amarela', fa.nu_raca_amarela),
        ('Indígena', fa.nu_raca_indigena)
) AS raca(raca_cor, quantidade)
-- Filtro de otimização: remove linhas zeradas para poupar espaço e processamento
WHERE raca.quantidade > 0;

-- 3. Criação dos Índices Físicos
-- A chave única agora é composta (PK + Raça), pois o unpivot gera múltiplas linhas por PK original
CREATE UNIQUE INDEX idx_vw_fa_raca_pk ON sfa.vw_fato_acolhimento_raca (pk_acolhimento, raca_cor);
CREATE INDEX idx_vw_fa_raca_cor ON sfa.vw_fato_acolhimento_raca (raca_cor);
CREATE INDEX idx_vw_fa_raca_sk_t ON sfa.vw_fato_acolhimento_raca (sk_tempo);
CREATE INDEX idx_vw_fa_raca_sk_g ON sfa.vw_fato_acolhimento_raca (sk_geografia);
CREATE INDEX idx_vw_fa_raca_sk_ges ON sfa.vw_fato_acolhimento_raca (sk_gestao);