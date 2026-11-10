-- 1. Criação da View Materializada Temática
create materialized view sfa.vw_fato_acolhimento_tempo as select
	-- 0. Chaves Estruturais
	fa.pk_acolhimento,
	fa.sk_tempo,
	fa.sk_geografia,
	fa.sk_gestao,

	-- 1. Colunas Temáticas (Geradas pelo Unpivot)
	tempo.tempo_acolhimento,
	tempo.quantidade,

	-- 2. Atributos da Dimensão Tempo
	t.dt_referencia,

	-- 3. Atributos da DImensão Geografia
	g.cod_ibge,
	g.nm_uf,
	g.nm_municipio,
	g.sg_uf,
	g.nm_regiao,
	g.ds_porte_municipio,
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
		('Menos de 1 Mês', fa.nu_tempo_menos1m),
		('01 a 03 Meses', fa.nu_tempo_1a3m),
		('04 a 06 Meses', fa.nu_tempo_4a6m),
		('07 a 12 Meses', fa.nu_tempo_7a12m),
		('13 a 18 Meses', fa.nu_tempo_13a18m),
		('19 a 24 Meses', fa.nu_tempo_19a24m),
		('25 a 48 Meses', fa.nu_tempo_25a48m),
		('49 a 72 Meses', fa.nu_tempo_49a72m),
		('Mais de 72 Meses', fa.nu_tempo_acima72m)
) as tempo(tempo_acolhimento, quantidade)
-- Filtro: mantém apenas os registros onde a quantidade é válida
where tempo.quantidade > 0;

-- 2. Criação dos Índices Físicos
create unique index idx_vw_fa_tempo_pk on sfa.vw_fato_acolhimento_tempo (pk_acolhimento, tempo_acolhimento);
create index idx_vw_fa_tempo_tempo on sfa.vw_fato_acolhimento_tempo (tempo_acolhimento);
create index idx_vw_fa_tempo_skt on sfa.vw_fato_acolhimento_tempo (sk_tempo);
create index idx_vw_fa_tempo_skg on sfa.vw_fato_acolhimento_tempo (sk_geografia);
create index idx_vw_fa_tempo_skges on sfa.vw_fato_acolhimento_tempo (sk_gestao);