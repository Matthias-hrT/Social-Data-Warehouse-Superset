-- 1. Criação da View Materializada Temática
create materialized view sfa.vw_fato_unidades_divulgacao as select 
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
	g.latitude,
	g.longitude,
    
    -- 4. Atributos da Dimensão Gestão
    ges.ds_tipo_gestao

from sfa.fato_unidades fu
inner join sfa.dim_tempo t on fu.sk_tempo = t.sk_tempo
inner join sfa.dim_geografia g on fu.sk_geografia = g.sk_geografia
inner join sfa.dim_gestao ges on fu.sk_gestao = ges.sk_gestao
-- O Motor do Unpivot: Empilha as colunas booleanas/numéricas de divulgação
cross join lateral (
    values 
        ('Outdoor/Busdoor', fu.fl_divulg_outdoor),
        ('Cartazes e Panfletos', fu.fl_divulg_cartaz),
        ('Mídia (Rádio, TV e Jornal)', fu.fl_divulg_midia),
        ('Eventos e Palestras', fu.fl_divulg_eventos),
        ('Redes Sociais e Internet', fu.fl_divulg_redes),
        ('Lideranças', fu.fl_divulg_liderancas)
) as divulgacao(estrategia, indicador)
-- Filtro de otimização: mantém apenas as linhas onde a estratégia foi de fato utilizada
where trim(divulgacao.indicador) = 'Sim';

-- 3. Criação dos Índices Físicos
create unique index idx_vw_fu_divulg_pk on sfa.vw_fato_unidades_divulgacao (pk_unidade, estrategia);
create index idx_vw_fu_divulg_est on sfa.vw_fato_unidades_divulgacao (estrategia);
create index idx_vw_fu_divulg_skt on sfa.vw_fato_unidades_divulgacao (sk_tempo);
create index idx_vw_fu_divulg_skg on sfa.vw_fato_unidades_divulgacao (sk_geografia);
create index idx_vw_fu_divulg_skges on sfa.vw_fato_unidades_divulgacao (sk_gestao);