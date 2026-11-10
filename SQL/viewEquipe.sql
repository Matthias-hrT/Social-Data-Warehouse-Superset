-- 1. Cria a View Materializada
CREATE MATERIALIZED VIEW sfa.vw_fato_equipe AS SELECT 
    -- 0. Chaves Estruturais
    fe.pk_equipe,
    fe.sk_geografia,
    fe.sk_tempo,
    fe.sk_gestao,

    -- 1. Perfil Sociodemográfico e Profissional
    fe.ds_sexo,
    fe.ds_faixa_etaria,
    fe.ds_nivel_escolaridade,
    fe.ds_profissao,
    fe.ds_tipo_vinculo,
    fe.ds_funcao,
    fe.dt_inicio_exercicio,

    -- 2. Atributos da Dimensão Geografia
    g.cod_ibge,
    g.nm_uf,
    g.nm_municipio,
    g.sg_uf,
    g.nm_regiao,
    g.ds_porte_municipio,
	g.latitude,
	g.longitude,

    -- 3. Atributos da Dimensão Tempo
    t.dt_referencia,

    -- 4. Atributos da Dimensão Gestão
    ges.ds_tipo_gestao

FROM sfa.fato_equipe fe
INNER JOIN sfa.dim_geografia g ON fe.sk_geografia = g.sk_geografia
INNER JOIN sfa.dim_tempo t ON fe.sk_tempo = t.sk_tempo
INNER JOIN sfa.dim_gestao ges ON fe.sk_gestao = ges.sk_gestao;

-- 3. Criação dos Índices Físicos
CREATE UNIQUE INDEX idx_vw_feq_pk ON sfa.vw_fato_equipe (pk_equipe);
CREATE INDEX idx_vw_feq_sk_g ON sfa.vw_fato_equipe (sk_geografia);
CREATE INDEX idx_vw_feq_sk_t ON sfa.vw_fato_equipe (sk_tempo);
CREATE INDEX idx_vw_feq_sk_ges ON sfa.vw_fato_equipe (sk_gestao);