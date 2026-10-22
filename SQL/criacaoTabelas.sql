
-- criar o esquema
create schema if not exists sfa;

-- Dimensoes com Versionamento (SCD Tipo 2)
create table sfa.dim_geografia (
    sk_geografia serial primary key,
    cod_ibge varchar(7),
    nm_uf varchar(25),
    nm_municipio varchar(150),
    sg_uf varchar(2),
    nm_regiao varchar(20),
    ds_porte_municipio varchar(50),
    -- Campos de controle gerados pelo Pentaho
    version int,
    date_from timestamp,
    date_to timestamp
);

create table sfa.dim_gestao (
    sk_gestao serial primary key,
    ds_tipo_gestao varchar(30),
    -- Campos de controle gerados pelo Pentaho
    version int,
    date_from timestamp,
    date_to timestamp
);

-- Dimensao Tempo (Chave inteligente, sem versionamento)
create table sfa.dim_tempo (
    sk_tempo int primary key,
    dt_referencia date
);
    -- TABELAS FATO --

create table sfa.fato_unidades (
	pk_unidade serial primary key,
    sk_geografia int references sfa.dim_geografia(sk_geografia),
    sk_tempo int references sfa.dim_tempo(sk_tempo),
    sk_gestao int references sfa.dim_gestao(sk_gestao),
    
    -- Identificacao e Comparativo
    nm_unidade varchar(255),
    ds_modalidade varchar(100), 
    nu_capacidade int, 
    nu_acolhidos_atual int, 
	ds_endereco varchar(300),

    -- Atributos Institucionais e Financeiros
    ds_natureza varchar(100),
    vl_custo_mensal numeric(12,2),
    fl_regionalizado varchar(100),
    nu_municipios_atendidos int,
    ano_implantacao int,
    
    -- Variaveis Exclusivas da Familia Acolhedora
    fl_regulamentado varchar(50),
    fl_subsidio varchar(10),
    vl_subsidio_mensal numeric(12,2),
    fl_perfil_delimitado varchar(100),
    fl_aceita_irmaos varchar(50),
    ds_faixa_implantacao varchar(50),
    ds_faixa_subsidio varchar(50),
    ds_faixa_custo varchar(50),
    
    -- Apoios Nao Financeiros
    fl_apoio_itens_basicos varchar(10),
    fl_apoio_mobiliario varchar(10),
    fl_apoio_isencao varchar(10),
    fl_apoio_outros varchar(10),
    fl_apoio_nenhum varchar(10),
    
    -- Estrategias de Divulgacao
    fl_divulg_outdoor varchar(10),
    fl_divulg_cartaz varchar(10),
    fl_divulg_midia varchar(10),
    fl_divulg_eventos varchar(10),
    fl_divulg_redes varchar(10),
    fl_divulg_liderancas varchar(10),
    
    -- Capacitacao, Selecao e Formacao
    nu_ch_capacitacao int,
    fl_sel_reuniao varchar(10),
    fl_sel_documental varchar(10),
    fl_sel_entrevista varchar(10),
    fl_sel_visita varchar(10),
    fl_form_grupo varchar(10),
    fl_form_individual varchar(10),
    fl_form_rodas varchar(10),
    fl_acomp_visita varchar(10),
    fl_acomp_psicossocial varchar(10)
);

create table sfa.fato_acolhimento (
	pk_acolhimento serial primary key,
	sk_geografia int references sfa.dim_geografia(sk_geografia),
	sk_tempo int references sfa.dim_tempo(sk_tempo),
	sk_gestao int references sfa.dim_gestao(sk_gestao),
	nu_acolhidos_atual int,
	nu_acolhidos_12m int,
	nu_masc_0a2 int,
	nu_masc_3a5 int,
	nu_masc_6a11 int,
	nu_masc_12a13 int,
	nu_masc_14a15 int,
	nu_masc_16a17 int,
	nu_masc_18mais int,
	nu_masc_total int,
	nu_fem_0a2 int,
    nu_fem_3a5 int,
    nu_fem_6a11 int,
    nu_fem_12a13 int,
    nu_fem_14a15 int,
    nu_fem_16a17 int,
	nu_fem_18mais int,
    nu_fem_total int,
	nu_orig_outro_mun int,
    nu_orig_outro_est int,
    nu_orig_outro_pais int,
    nu_tempo_menos1m int,
    nu_tempo_1a3m int,
    nu_tempo_4a6m int,
    nu_tempo_7a12m int,
    nu_tempo_13a18m int,
    nu_tempo_19a24m int,
    nu_tempo_25a48m int,
    nu_tempo_49a72m int,
    nu_tempo_acima72m int,
    nu_tempo_total int,
	nu_cond_deficiencia int,
    nu_cond_transtorno int,
    nu_cond_saude_espec int,
    nu_cond_socioeducativo int,
    nu_cond_traj_rua int,
    nu_cond_indigena int,
    nu_cond_com_trad int,
    nu_cond_dep_quimica int,
    nu_cond_gestante int,
	nu_raca_preta int,
    nu_raca_parda int,
    nu_raca_branca int,
    nu_raca_amarela int,
    nu_raca_indigena int,
    nu_mot_entrega_vol int,
    nu_mot_orfandade int,
    nu_mot_abandono int,
    nu_mot_drogas_pais int,
    nu_mot_viol_fisica int,
    nu_mot_viol_psicol int,
    nu_mot_abuso_sexual int,
    nu_mot_expl_sexual int,
    nu_mot_conflito_fam int,
	nu_mot_expl_trabalho int,
	nu_mot_ameaca_morte int,
	nu_mot_sit_rua_jovem int,
    nu_mot_negligencia int,
    nu_mot_fam_rua int,
	nu_dest_fam_origem int,
    nu_dest_fam_extensa int,
    nu_dest_adocao int,
    nu_dest_outra_unid int,
    nu_dest_deslig_18 int,
    nu_readm_fam_origem int,
    nu_readm_fam_extensa int,
    nu_readm_adocao int,
    nu_aptos_adocao int,
    nu_apadrinhamento int,
	nu_sem_visitas_imped int,
	nu_sem_visitas_sem_imped int,
    nu_pbf int,
    nu_baixa_renda int
);

create table sfa.fato_equipe (
	pk_equipe serial primary key,
	sk_geografia int references sfa.dim_geografia(sk_geografia),
	sk_tempo int references sfa.dim_tempo(sk_tempo),
	sk_gestao int references sfa.dim_gestao(sk_gestao),
	ds_sexo varchar(50),
	ds_faixa_etaria varchar(50),
	ds_nivel_escolaridade varchar(50),
	ds_profissao varchar(150),
	ds_tipo_vinculo varchar(100),
	ds_funcao varchar(150),
	dt_inicio_exercicio date
);

create table sfa.fato_familias (
	pk_familia serial primary key,
	sk_geografia int references sfa.dim_geografia(sk_geografia),
	sk_tempo int references sfa.dim_tempo(sk_tempo),
	sk_gestao int references sfa.dim_gestao(sk_gestao),
	ds_sexo varchar(50),
	ds_faixa_etaria varchar(50),
	ds_nivel_escolaridade varchar(50),
	ds_profissao varchar(150),
	ds_tipo_vinculo varchar(100),
	ds_funcao varchar(150),
	dt_inicio_exercicio date
);