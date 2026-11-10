-- 1. Criação da View Materializada Temática
CREATE MATERIALIZED VIEW sfa.vw_fato_unidades_divulgacao AS SELECT 
    -- 0. Chaves Estruturais
    fu.pk_unidade,
    fu.sk_tempo,
    fu.sk_geografia,
    fu.sk_gestao,
    
    -- 1. Colunas Temáticas (Geradas pelo Unpivot)
    divulgacao.estrategia,
    divulgacao.indicador,

    -- 2. Atributos da Dimensão Tempo
    t.dt_referencia,
    
    -- 3. Atributos da Dimensão Geografia
    g.cod_ibge,
    g.nm_uf,
    g.nm_municipio,
    g.sg_uf,
    g.nm_regiao,
    g.ds_porte_municipio,
	g.latitude,
	g.longitude,
    
    -- 4. Atributos da Dimensão Gestão
    ges.ds_tipo_gestao

FROM sfa.fato_unidades fu
INNER JOIN sfa.dim_tempo t ON fu.sk_tempo = t.sk_tempo
INNER JOIN sfa.dim_geografia g ON fu.sk_geografia = g.sk_geografia
INNER JOIN sfa.dim_gestao ges ON fu.sk_gestao = ges.sk_gestao
-- O Motor do Unpivot: Empilha as colunas booleanas/numéricas de divulgação
CROSS JOIN LATERAL (
    VALUES 
        ('Outdoor/Busdoor', fu.fl_divulg_outdoor),
        ('Cartazes e Panfletos', fu.fl_divulg_cartaz),
        ('Mídia (Rádio, TV e Jornal)', fu.fl_divulg_midia),
        ('Eventos e Palestras', fu.fl_divulg_eventos),
        ('Redes Sociais e Internet', fu.fl_divulg_redes),
        ('Lideranças', fu.fl_divulg_liderancas)
) AS divulgacao(estrategia, indicador)
-- Filtro de otimização: mantém apenas as linhas onde a estratégia foi de fato utilizada
WHERE trim(divulgacao.indicador) = 'Sim';

-- 3. Criação dos Índices Físicos
CREATE UNIQUE INDEX idx_vw_fu_divulg_pk ON sfa.vw_fato_unidades_divulgacao (pk_unidade, estrategia);
CREATE INDEX idx_vw_fu_divulg_est ON sfa.vw_fato_unidades_divulgacao (estrategia);
CREATE INDEX idx_vw_fu_divulg_skt ON sfa.vw_fato_unidades_divulgacao (sk_tempo);
CREATE INDEX idx_vw_fu_divulg_skg ON sfa.vw_fato_unidades_divulgacao (sk_geografia);
CREATE INDEX idx_vw_fu_divulg_skges ON sfa.vw_fato_unidades_divulgacao (sk_gestao);