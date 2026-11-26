-- 1. Criação da View Materializada Temática
CREATE MATERIALIZED VIEW sfa.vw_fato_acolhimento_idade AS SELECT 
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

FROM sfa.fato_acolhimento fa
INNER JOIN sfa.dim_tempo t ON fa.sk_tempo = t.sk_tempo
INNER JOIN sfa.dim_geografia g ON fa.sk_geografia = g.sk_geografia
INNER JOIN sfa.dim_gestao ges ON fa.sk_gestao = ges.sk_gestao
-- O Motor do Unpivot: Multiplica as linhas e categoriza por sexo e faixa etária
CROSS JOIN LATERAL (
    VALUES 
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
) AS idade(sexo, faixa_etaria, quantidade)
-- Filtro de otimização
WHERE idade.quantidade > 0;

-- 3. Criação dos Índices Físicos
-- A chave única agora exige três colunas para garantir a exclusividade da linha física
CREATE UNIQUE INDEX idx_vw_fa_idade_pk ON sfa.vw_fato_acolhimento_idade (pk_acolhimento, sexo, faixa_etaria);
CREATE INDEX idx_vw_fa_idade_sexo ON sfa.vw_fato_acolhimento_idade (sexo);
CREATE INDEX idx_vw_fa_idade_faixa ON sfa.vw_fato_acolhimento_idade (faixa_etaria);
CREATE INDEX idx_vw_fa_idade_sk_t ON sfa.vw_fato_acolhimento_idade (sk_tempo);
CREATE INDEX idx_vw_fa_idade_sk_g ON sfa.vw_fato_acolhimento_idade (sk_geografia);
CREATE INDEX idx_vw_fa_idade_sk_ges ON sfa.vw_fato_acolhimento_idade (sk_gestao);