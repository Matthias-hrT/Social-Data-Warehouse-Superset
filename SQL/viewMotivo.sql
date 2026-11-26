-- 1. Criação da View Materializada Temática
create materialized view sfa.vw_fato_acolhimento_motivo as select
	-- 0. Chaves Estruturais
	fa.pk_acolhimento,
	fa.sk_tempo,
	fa.sk_geografia,
	fa.sk_gestao,

	-- 1. Colunas Temáticas (Geradas pelo Unpivot)
	motivo.motivo_acolhimento,
	motivo.quantidade,

	-- 2. Atributos da Dimensão Tempo
	t.dt_referencia,

	-- 3. Atributos da DImensão Geografia
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
inner join sfa.dim_tempo t on  fa.sk_tempo = t.sk_tempo
inner join sfa.dim_geografia g on fa.sk_geografia = g.sk_geografia
inner join sfa.dim_gestao ges on fa.sk_gestao = ges.sk_gestao
-- Unpivot: Empilha as colunas numéricas de motivos
cross join lateral (
	values
		('Entrega Voluntária', fa.nu_mot_entrega_vol),
		('Orfandade', fa.nu_mot_orfandade),
		('Abandono', fa.nu_mot_abandono),
		('Drogas (Pais/Responsáveis)', fa.nu_mot_drogas_pais),
		('Violência Física', fa.nu_mot_viol_fisica),
		('Violência Psicológica', fa.nu_mot_viol_psicol),
		('Abuso Sexual', fa.nu_mot_abuso_sexual),
		('Exploração Sexual', fa.nu_mot_expl_sexual),
		('Conflito Familiar', fa.nu_mot_conflito_fam),
		('Exploração de Trabalho', fa.nu_mot_expl_trabalho),
		('Ameaça de Morte', fa.nu_mot_ameaca_morte),
		('Situação de Rua', fa.nu_mot_sit_rua_jovem),
		('Negligência', fa.nu_mot_negligencia),
		('Família em Situação de Rua', fa.nu_mot_fam_rua)
) as motivo(motivo_acolhimento, quantidade)
-- Filtro: mantém apenas os registros onde a quantidade é válida
where motivo.quantidade > 0;

-- 2. Criação dos Índices Físicos
create unique index idx_vw_fa_mot_pk on sfa.vw_fato_acolhimento_motivo (pk_acolhimento, motivo_acolhimento);
create index idx_vw_fa_mot_motivo on sfa.vw_fato_acolhimento_motivo (motivo_acolhimento);
create index idx_vw_fa_mot_skt on sfa.vw_fato_acolhimento_motivo (sk_tempo);
create index idx_vw_fa_mot_skg on sfa.vw_fato_acolhimento_motivo (sk_geografia);
create index idx_vw_fa_mot_skges on sfa.vw_fato_acolhimento_motivo (sk_gestao);