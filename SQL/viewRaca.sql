-- 1. Criação da View Materializada Temática
create materialized view sfa.vw_fato_acolhimento_raca as select 
    -- 0. Chaves Estruturais
    fa.pk_acolhimento,
    fa.sk_tempo,
    fa.sk_geografia,
    fa.sk_gestao,
    
    -- 1. Colunas Temáticas (Geradas pelo Unpivot)
    raca.raca_cor,
    raca.quantidade,

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
-- O Motor do Unpivot: Multiplica as linhas e empilha os dados
cross join lateral (
    values 
        ('Preta', fa.nu_raca_preta),
        ('Parda', fa.nu_raca_parda),
        ('Branca', fa.nu_raca_branca),
        ('Amarela', fa.nu_raca_amarela),
        ('Indígena', fa.nu_raca_indigena)
) as raca(raca_cor, quantidade)
-- Filtro de otimização: remove linhas zeradas para poupar espaço e processamento
where raca.quantidade > 0;

-- 3. Criação dos Índices Físicos
-- A chave única agora é composta (PK + Raça), pois o unpivot gera múltiplas linhas por PK original
create unique index idx_vw_fa_raca_pk on sfa.vw_fato_acolhimento_raca (pk_acolhimento, raca_cor);
create index idx_vw_fa_raca_cor on sfa.vw_fato_acolhimento_raca (raca_cor);
create index idx_vw_fa_raca_sk_t on sfa.vw_fato_acolhimento_raca (sk_tempo);
create index idx_vw_fa_raca_sk_g on sfa.vw_fato_acolhimento_raca (sk_geografia);
create index idx_vw_fa_raca_sk_ges on sfa.vw_fato_acolhimento_raca (sk_gestao);