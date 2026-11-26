-- 1. Cria a View Materializada
create materialized view sfa.vw_fato_equipe as select
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
	g.latitude,
	g.longitude,

    -- 3. Atributos da Dimensão Tempo
    t.dt_referencia,

    -- 4. Atributos da Dimensão Gestão
    ges.ds_tipo_gestao

from sfa.fato_equipe fe
inner join sfa.dim_geografia g on fe.sk_geografia = g.sk_geografia
inner join sfa.dim_tempo t on fe.sk_tempo = t.sk_tempo
inner join sfa.dim_gestao ges on fe.sk_gestao = ges.sk_gestao;

-- 3. Criação dos Índices Físicos
create unique index idx_vw_feq_pk on sfa.vw_fato_equipe (pk_equipe);
create index idx_vw_feq_sk_g on sfa.vw_fato_equipe (sk_geografia);
create index idx_vw_feq_sk_t on sfa.vw_fato_equipe (sk_tempo);
create index idx_vw_feq_sk_ges on sfa.vw_fato_equipe (sk_gestao);