create or replace view sfa.vw_fato_familias as select
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
    g.ds_porte_municipio,

    -- 3. Atributos da Dimensão Tempo
    t.dt_referencia,

    -- 4. Atributos da Dimensão Gestão
    ges.ds_tipo_gestao

from sfa.fato_familias ff
inner join sfa.dim_geografia g on ff.sk_geografia = g.sk_geografia
inner join sfa.dim_tempo t on ff.sk_tempo = t.sk_tempo
inner join sfa.dim_gestao ges on ff.sk_gestao = ges.sk_gestao;