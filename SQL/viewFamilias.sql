-- 1. Cria a View Materializada
CREATE MATERIALIZED VIEW sfa.vw_fato_familias AS SELECT 
    -- 0. Chaves Estruturais
    ff.pk_familia,
    ff.sk_geografia,
    ff.sk_tempo,
    ff.sk_gestao,

    -- 1. Perfil Sociodemográfico e Profissional
    ff.ds_sexo,
    ff.ds_faixa_etaria,
    ff.ds_nivel_escolaridade,
    ff.ds_profissao,
    ff.ds_tipo_vinculo,
    ff.ds_funcao,
    ff.dt_inicio_exercicio,

    -- 2. Atributos da Dimensão Geografia
    g.cod_ibge,
    g.nm_uf,
    g.nm_municipio,
    g.sg_uf,
    g.nm_regiao,
	g.latitude,
	g.longitude,

    -- 3. Atributos da Dimensão Tempo
    t.dt_referencia,

    -- 4. Atributos da Dimensão Gestão
    ges.ds_tipo_gestao

FROM sfa.fato_familias ff
INNER JOIN sfa.dim_geografia g ON ff.sk_geografia = g.sk_geografia
INNER JOIN sfa.dim_tempo t ON ff.sk_tempo = t.sk_tempo
INNER JOIN sfa.dim_gestao ges ON ff.sk_gestao = ges.sk_gestao;

-- 3. Criação dos Índices Físicos (Performance no Superset)
CREATE UNIQUE INDEX idx_vw_ff_pk ON sfa.vw_fato_familias (pk_familia);
CREATE INDEX idx_vw_ff_sk_g ON sfa.vw_fato_familias (sk_geografia);
CREATE INDEX idx_vw_ff_sk_t ON sfa.vw_fato_familias (sk_tempo);
CREATE INDEX idx_vw_ff_sk_ges ON sfa.vw_fato_familias (sk_gestao);