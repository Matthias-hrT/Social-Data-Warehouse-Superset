-- 1. Criação da View Materializada Temática
CREATE MATERIALIZED VIEW sfa.vw_fato_acolhimento_saida AS SELECT 
    -- 0. Chaves Estruturais
    fa.pk_acolhimento, -- Ajuste para a PK real da sua tabela fato
    fa.sk_tempo,
    fa.sk_geografia,
    fa.sk_gestao,
    
    -- 1. Colunas Temáticas (Geradas pelo Unpivot)
    saida.destino_institucional,
    saida.quantidade,

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
-- O Motor do Unpivot: Empilha as colunas numéricas de saída
CROSS JOIN LATERAL (
    VALUES 
        ('Reintegração à família de origem', fa.nu_dest_fam_origem),
        ('Família extensa', fa.nu_dest_fam_extensa),
        ('Adoção', fa.nu_dest_adocao),
        ('Maioridade', fa.nu_dest_deslig_18),
        ('Transferência para outra unidade', fa.nu_dest_outra_unid)
) AS saida(destino_institucional, quantidade)
-- Filtro de otimização: mantém apenas os registros onde a quantidade é válida (maior que zero)
WHERE saida.quantidade > 0;

-- 2. Criação dos Índices Físicos
CREATE UNIQUE INDEX idx_vw_fa_saida_pk ON sfa.vw_fato_acolhimento_saida (pk_acolhimento, destino_institucional);
CREATE INDEX idx_vw_fa_saida_dest ON sfa.vw_fato_acolhimento_saida (destino_institucional);
CREATE INDEX idx_vw_fa_saida_skt ON sfa.vw_fato_acolhimento_saida (sk_tempo);
CREATE INDEX idx_vw_fa_saida_skg ON sfa.vw_fato_acolhimento_saida (sk_geografia);
create index idx_vw_fa_saida_skges on sfa.vw_fato_acolhimento_saida (sk_gestao);