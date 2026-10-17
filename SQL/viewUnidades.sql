create or replace view sfa.vw_fato_unidades as select
	f.nm_unidade,
    f.ds_modalidade,
    f.nu_capacidade,
    f.nu_acolhidos_atual,
    f.ds_endereco,
    f.ds_natureza,
    f.vl_custo_mensal,
    f.fl_regionalizado,
    f.nu_municipios_atendidos,
    f.ano_implantacao,
    f.fl_regulamentado,
    f.fl_subsidio,
    f.vl_subsidio_mensal,
    f.fl_perfil_delimitado,
    f.fl_aceita_irmaos,
    f.ds_faixa_implantacao,
    f.ds_faixa_subsidio,
    f.ds_faixa_custo,
    f.fl_apoio_itens_basicos,
    f.fl_apoio_mobiliario,
    f.fl_apoio_isencao,
    f.fl_apoio_outros,
    f.fl_apoio_nenhum,
    f.fl_divulg_outdoor,
    f.fl_divulg_cartaz,
    f.fl_divulg_midia,
    f.fl_divulg_eventos,
    f.fl_divulg_redes,
    f.fl_divulg_liderancas,
    f.nu_ch_capacitacao,
    f.fl_sel_reuniao,
    f.fl_sel_documental,
    f.fl_sel_entrevista,
    f.fl_sel_visita,
    f.fl_form_grupo,
    f.fl_form_individual,
    f.fl_form_rodas,
    f.fl_acomp_visita,
    f.fl_acomp_psicossocial,
    f.nu_capacidade_vagas,

	g.cod_ibge,
	g.nm_uf,
	g.nm_municipio,
	g.sg_uf,
	g.nm_regiao,
	g.ds_porte_municipio,

	t.dt_referencia,

	ges.ds_tipo_gestao
from
	sfa.fato_unidades f
left join
	sfa.dim_geografia g on f.sk_geografia = g.sk_geografia
left join sfa.dim_tempo t on f.sk_tempo = g.sk_tempo
left join sfa.dim_gestao ges on f.sk_g