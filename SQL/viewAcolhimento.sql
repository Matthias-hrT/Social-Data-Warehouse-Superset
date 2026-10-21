create or replace view sfa.vw_superset_fato_acolhimento as select 
    -- 1. Métricas Gerais de Acolhimento
    fa.nu_acolhidos_atual,
    fa.nu_acolhidos_12m,
    fa.nu_acolhidos_total,
    
    -- 2. Métricas de Faixa Etária e Sexo (Masculino)
    fa.nu_masc_0a2,
    fa.nu_masc_3a5,
    fa.nu_masc_6a11,
    fa.nu_masc_12a13,
    fa.nu_masc_14a15,
    fa.nu_masc_16a17,
    fa.nu_masc_18mais,
    fa.nu_masc_total,
    
    -- 3. Métricas de Faixa Etária e Sexo (Feminino)
    fa.nu_fem_0a2,
    fa.nu_fem_3a5,
    fa.nu_fem_6a11,
    fa.nu_fem_12a13,
    fa.nu_fem_14a15,
    fa.nu_fem_16a17,
    fa.nu_fem_18mais,
    fa.nu_fem_total,
    
    -- 4. Métricas de Origem e Tempo
    fa.nu_orig_outro_mun,
    fa.nu_orig_outro_est,
    fa.nu_orig_outro_pais,
    fa.nu_tempo_menos1m,
    fa.nu_tempo_1a3m,
    fa.nu_tempo_4a6m,
    fa.nu_tempo_7a12m,
    fa.nu_tempo_13a18m,
    fa.nu_tempo_19a24m,
    fa.nu_tempo_25a48m,
    fa.nu_tempo_49a72m,
    fa.nu_tempo_acima72m,
    fa.nu_tempo_total,
    
    -- 5. Métricas de Condições Específicas
    fa.nu_cond_deficiencia,
    fa.nu_cond_transtorno,
    fa.nu_cond_saude_espec,
    fa.nu_cond_socioeducativo,
    fa.nu_cond_traj_rua,
    fa.nu_cond_indigena,
    fa.nu_cond_com_trad,
    fa.nu_cond_dep_quimica,
    fa.nu_cond_gestante,
    
    -- 6. Métricas de Raça/Cor
    fa.nu_raca_preta,
    fa.nu_raca_parda,
    fa.nu_raca_branca,
    fa.nu_raca_amarela,
    fa.nu_raca_indigena,
    
    -- 7. Motivos de Acolhimento (Gatilhos e Violações)
    fa.nu_mot_entrega_vol,
    fa.nu_mot_orfandade,
    fa.nu_mot_abandono,
    fa.nu_mot_drogas_pais,
    fa.nu_mot_viol_fisica,
    fa.nu_mot_viol_psicol,
    fa.nu_mot_abuso_sexual,
    fa.nu_mot_expl_sexual,
    fa.nu_mot_conflito_fam,
    fa.nu_mot_expl_trabalho,
    fa.nu_mot_ameaca_morte,
    fa.nu_mot_sit_rua_jovem,
    fa.nu_mot_negligencia,
    fa.nu_mot_fam_rua,
    
    -- 8. Destinos, Reintegração e Vínculos
    fa.nu_dest_fam_origem,
    fa.nu_dest_fam_extensa,
    fa.nu_dest_adocao,
    fa.nu_dest_outra_unid,
    fa.nu_dest_deslig_18,
    fa.nu_readm_fam_origem,
    fa.nu_readm_fam_extensa,
    fa.nu_readm_adocao,
    fa.nu_aptos_adocao,
    fa.nu_apadrinhamento,
    fa.nu_sem_visitas_imped,
    fa.nu_sem_visitas_sem_imped,
    
    -- 9. Programas Sociais
    fa.nu_pbf,
    fa.nu_baixa_renda,

	 -- 10. Atributos da Dimensão Tempo
    t.dt_referencia,
    
    -- 11. Atributos da Dimensão Geografia
    g.nm_municipio,
    g.sg_uf,
    g.nm_regiao,
    g.ds_porte_municipio,
    
    -- 12. Atributos da Dimensão Gestão
    ges.ds_tipo_gestao

from sfa.fato_acolhimento fa
inner join sfa.dim_tempo t on fa.sk_tempo = t.sk_tempo
inner join sfa.dim_geografia g on fa.sk_geografia = g.sk_geografia
inner join sfa.dim_gestao ges on fa.sk_gestao = ges.sk_gestao;