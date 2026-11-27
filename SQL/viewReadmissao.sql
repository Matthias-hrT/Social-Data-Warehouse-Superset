-- 1. Criação da View Materializada Temática 
create materialized view sfa.vw_fato_acolhimento_readmissao as select 
    -- 0. Chaves Estruturais
    fa.pk_acolhimento, 
    fa.sk_tempo,
    fa.sk_geografia,
    fa.sk_gestao,
    
    -- 1. Colunas Temáticas (Geradas pelo Unpivot)
    readmissao.motivo_readmissao,
    readmissao.quantidade,

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

from sfa.fato_acolhimento fa
inner join sfa.dim_tempo t on fa.sk_tempo = t.sk_tempo
inner join sfa.dim_geografia g on fa.sk_geografia = g.sk_geografia
inner join sfa.dim_gestao ges on fa.sk_gestao = ges.sk_gestao
-- Unpivot: Empilha as colunas numéricas de readmissão
cross join lateral (
    values 
        ('Família de origem', fa.nu_readm_fam_origem),
        ('Família extensa', fa.nu_readm_fam_extensa),
        ('Adoção', fa.nu_readm_adocao)
) as readmissao(motivo_readmissao, quantidade)
-- Filtro: mantém apenas os registros onde a quantidade é válida
where readmissao.quantidade > 0;

-- 2. Criação dos Índices Físicos
create unique index idx_vw_fa_readm_pk on sfa.vw_fato_acolhimento_readmissao (pk_acolhimento, motivo_readmissao);
create index idx_vw_fa_readm_motivo on sfa.vw_fato_acolhimento_readmissao (motivo_readmissao);
create index idx_vw_fa_readm_skt on sfa.vw_fato_acolhimento_readmissao (sk_tempo);
create index idx_vw_fa_readm_skg on sfa.vw_fato_acolhimento_readmissao (sk_geografia);
create index idx_vw_fa_readm_skges on sfa.vw_fato_acolhimento_readmissao (sk_gestao);