-- 1. Criação da View Materializada Temática
create materialized view sfa.vw_fato_acolhimento_saida as select 
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

from sfa.fato_acolhimento fa
inner join sfa.dim_tempo t on fa.sk_tempo = t.sk_tempo
inner join sfa.dim_geografia g on fa.sk_geografia = g.sk_geografia
inner join sfa.dim_gestao ges on fa.sk_gestao = ges.sk_gestao
-- O Motor do Unpivot: Empilha as colunas numéricas de saída
cross join lateral (
    values 
        ('Reintegração à família de origem', fa.nu_dest_fam_origem),
        ('Família extensa', fa.nu_dest_fam_extensa),
        ('Adoção', fa.nu_dest_adocao),
        ('Maioridade', fa.nu_dest_deslig_18),
        ('Transferência para outra unidade', fa.nu_dest_outra_unid)
) as saida(destino_institucional, quantidade)
-- Filtro de otimização: mantém apenas os registros onde a quantidade é válida (maior que zero)
where saida.quantidade > 0;

-- 2. Criação dos Índices Físicos
create unique index idx_vw_fa_saida_pk on sfa.vw_fato_acolhimento_saida (pk_acolhimento, destino_institucional);
create index idx_vw_fa_saida_dest on sfa.vw_fato_acolhimento_saida (destino_institucional);
create index idx_vw_fa_saida_skt on sfa.vw_fato_acolhimento_saida (sk_tempo);
create index idx_vw_fa_saida_skg on sfa.vw_fato_acolhimento_saida (sk_geografia);
create index idx_vw_fa_saida_skges on sfa.vw_fato_acolhimento_saida (sk_gestao);