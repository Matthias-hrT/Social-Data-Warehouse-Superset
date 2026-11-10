-- 1. Cria a View Materializada
CREATE MATERIALIZED VIEW sfa.vw_fato_unidades AS 
SELECT 
    -- 0. Chaves Estruturais
    fu.pk_unidade,
    fu.sk_geografia,
    fu.sk_tempo,
    fu.sk_gestao,

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
	g.latitude,
	g.longitude,

    -- 8. Atributos da Dimensão Tempo
    t.dt_referencia,

    -- 9. Atributos da Dimensão Gestão
    ges.ds_tipo_gestao

FROM sfa.fato_unidades fu
INNER JOIN sfa.dim_geografia g ON fu.sk_geografia = g.sk_geografia
INNER JOIN sfa.dim_tempo t ON fu.sk_tempo = t.sk_tempo
INNER JOIN sfa.dim_gestao ges ON fu.sk_gestao = ges.sk_gestao;

-- 3. Criação dos Índices (Crucial para a performance no BI)
CREATE UNIQUE INDEX idx_vw_fu_pk ON sfa.vw_fato_unidades (pk_unidade);
CREATE INDEX idx_vw_fu_sk_g ON sfa.vw_fato_unidades (sk_geografia);
CREATE INDEX idx_vw_fu_sk_t ON sfa.vw_fato_unidades (sk_tempo);
CREATE INDEX idx_vw_fu_sk_ges ON sfa.vw_fato_unidades (sk_gestao);