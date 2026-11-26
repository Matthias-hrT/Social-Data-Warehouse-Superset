-- 1. Criação da View Materializada Temática
create materialized view sfa.vw_fato_acolhimento_idade as select 
    -- 0. Chaves Estruturais
    fa.pk_acolhimento,
    fa.sk_tempo,
    fa.sk_geografia,
    fa.sk_gestao,
    
    -- 1. Colunas Temáticas (Geradas pelo Unpivot duplo: Sexo e Idade)
    idade.sexo,
    idade.faixa_etaria,
    idade.quantidade,

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
-- O Motor do Unpivot: Multiplica as linhas e categoriza por sexo e faixa etária
cross join lateral (
    values 
        -- Bloco Masculino
        ('Masculino', '0 a 2 anos', fa.nu_masc_0a2),
        ('Masculino', '3 a 5 anos', fa.nu_masc_3a5),
        ('Masculino', '6 a 11 anos', fa.nu_masc_6a11),
        ('Masculino', '12 a 13 anos', fa.nu_masc_12a13),
        ('Masculino', '14 a 15 anos', fa.nu_masc_14a15),
        ('Masculino', '16 a 17 anos', fa.nu_masc_16a17),
        ('Masculino', '18 anos ou mais', fa.nu_masc_18mais),
        
        -- Bloco Feminino
        ('Feminino', '0 a 2 anos', fa.nu_fem_0a2),
        ('Feminino', '3 a 5 anos', fa.nu_fem_3a5),
        ('Feminino', '6 a 11 anos', fa.nu_fem_6a11),
        ('Feminino', '12 a 13 anos', fa.nu_fem_12a13),
        ('Feminino', '14 a 15 anos', fa.nu_fem_14a15),
        ('Feminino', '16 a 17 anos', fa.nu_fem_16a17),
        ('Feminino', '18 anos ou mais', fa.nu_fem_18mais)
) as idade(sexo, faixa_etaria, quantidade)
-- Filtro de otimização
where idade.quantidade > 0;

-- 3. Criação dos Índices Físicos
-- A chave única agora exige três colunas para garantir a exclusividade da linha física
create unique index idx_vw_fa_idade_pk on sfa.vw_fato_acolhimento_idade (pk_acolhimento, sexo, faixa_etaria);
create index idx_vw_fa_idade_sexo on sfa.vw_fato_acolhimento_idade (sexo);
create index idx_vw_fa_idade_faixa on sfa.vw_fato_acolhimento_idade (faixa_etaria);
create index idx_vw_fa_idade_sk_t on sfa.vw_fato_acolhimento_idade (sk_tempo);
create index idx_vw_fa_idade_sk_g on sfa.vw_fato_acolhimento_idade (sk_geografia);
create index idx_vw_fa_idade_sk_ges on sfa.vw_fato_acolhimento_idade (sk_gestao);