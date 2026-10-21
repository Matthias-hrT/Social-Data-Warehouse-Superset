create or replace view sfa.vw_fato_unidades as select
    -- 1. Identificação e Comparativo
    fu.nm_unidade,
    fu.ds_modalidade,
    fu.nu_capacidade,
    fu.nu_acolhidos_atual,
    fu.ds_endereco,

	-- 2. Atributos Institucionais e Financeiros
    fu.ds_natureza,
    fu.vl_custo_mensal,
    fu.fl_regionalizado,
    fu.nu_municipios_atendidos,
    fu.ano_implantacao,

	-- 3. Variáveis Exclusivas da Família Acolhedora
    fu.fl_regulamentado,
    fu.fl_subsidio,
    fu.vl_subsidio_mensal,
    fu.fl_perfil_delimitado,
    fu.fl_aceita_irmaos,
    fu.ds_faixa_implantacao,
    fu.ds_faixa_subsidio,
    fu.ds_faixa_custo,

	-- 4. Apoios Não Financeiros
    fu.fl_apoio_itens_basicos,
    fu.fl_apoio_mobiliario,
    fu.fl_apoio_isencao,
    fu.fl_apoio_outros,
    fu.fl_apoio_nenhum,

	-- 5. Estratégias de Divulgação
    fu.fl_divulg_outdoor,
    fu.fl_divulg_cartaz,
    fu.fl_divulg_midia,
    fu.fl_divulg_eventos,
    fu.fl_divulg_redes,
    fu.fl_divulg_liderancas,

	-- 6. Capacitação, Seleção e Formação
    fu.nu_ch_capacitacao,
    fu.fl_sel_reuniao,
    fu.fl_sel_documental,
    fu.fl_sel_entrevista,
    fu.fl_sel_visita,
    fu.fl_form_grupo,
    fu.fl_form_individual,
    fu.fl_form_rodas,
    fu.fl_acomp_visita,
    fu.fl_acomp_psicossocial,

    -- 7. Atributos da Dimensão Geografia
    g.cod_ibge,
    g.nm_uf,
    g.nm_municipio,
    g.sg_uf,
    g.nm_regiao,
    g.ds_porte_municipio,

    -- 8. Atributos da Dimensão Tempo
    t.dt_referencia,

    -- 9. Atributos da Dimensão Gestão
    ges.ds_tipo_gestao

from sfa.fato_unidades fu
inner join sfa.dim_geografia g on fu.sk_geografia = g.sk_geografia
inner join sfa.dim_tempo t on fu.sk_tempo = t.sk_tempo
inner join sfa.dim_gestao ges on fu.sk_gestao = ges.sk_gestao;