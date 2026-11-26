create materialized view sfa.vw_fato_acolhimento_condicao as select
	-- 0. Chaves Estruturais
	fa.pk_acolhimento,
	fa.sk_tempo,
	fa.sk_geografia,
	fa.sk_gestao,

	-- 1. Colunas Temáticas (Geradas pelo Unpivot)
	condicao.condicao_acolhido,
	condicao.quantidade,

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

	-- 4. Atributos da Dimensão Gestao
	ges.ds_tipo_gestao

from sfa.fato_acolhimento fa
inner join sfa.dim_tempo t on fa.sk_tempo = t.sk_tempo
inner join sfa.dim_geografia g on fa.sk_geografia = g.sk_geografia
inner join sfa.dim_gestao ges on fa.sk_gestao = ges.sk_gestao
-- Unpivot: Empilha as colunas numéricas de condição
cross join lateral(
	values
		('Deficiência', fa.nu_cond_deficiencia),
		('Transtorno', fa.nu_cond_transtorno),
		('Condição de Saúde Específica', fa.nu_cond_saude_espec),
		('Socioeducativo', fa.nu_cond_socioeducativo),
		('Trajetória de Rua', fa.nu_cond_traj_rua),
		('Indigena', fa.nu_cond_indigena),
		('Povos/Comunidades Tradicionais', fa.nu_cond_com_trad),
		('Dependência Quimica', fa.nu_cond_dep_quimica),
		('Gestante', fa.nu_cond_gestante)
) as condicao(condicao_acolhido, quantidade)
-- Filtro: mantém apenas os registros onde a quantidade é valida
where condicao.quantidade > 0;

-- 2. Criação dos Índices:
create unique index idx_vw_fato_cond_pk on sfa.vw_fato_acolhimento_condicao (pk_acolhimento, condicao_acolhido);
create index idx_vw_fa_cond_condicao on sfa.vw_fato_acolhimento_condicao (condicao_acolhido);
create index idx_vw_fa_cond_skt on sfa.vw_fato_acolhimento_condicao (sk_tempo);
create index idx_vw_fa_cond_skg on sfa.vw_fato_acolhimento_condicao (sk_geografia);
create index idx_vw_fa_cond_skges on sfa.vw_fato_acolhimento_condicao (sk_gestao);