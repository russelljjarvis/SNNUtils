
duarte_types = [0.8, 0.2*0.65, 0.2*.35]
pv_only      = [0.8, 0., 0.2]
sst_only     = [0.8, 0.2, 0.]

duartemorrison2017= FullConnections(
    ρe_s_e  = 0.168,
    # ρe_d_e  = 0.168,
    ρif_e = 0.575,
    ρis_e = 0.244,
    ρe_if = 0.60,
    ρe_is = 0.465,
    ρif_if = 0.55,
    ρis_if = 0.24,
    ρif_is = 0.379,
    ρis_is = 0.381,
    μe_e  = 0.45,
    μif_e = 1.65,
    μis_e = 0.638,
    μe_if = 5.148,
    μe_is = 4.85,
    μif_if =2.22,
    μis_if =1.4,
    μif_is =1.47,
    μis_is =0.83,
    σe_e  = 0.1,
    σif_e = 0.10,
    σis_e = 0.11,
    σe_if = 0.11,
    σe_is = 0.11,
    σif_if =0.14,
    σis_if =0.25,
    σif_is =0.10,
    σis_is =0.2
)


lkd2014 = FullConnections(
    ρe_s_e  = 0.2,
    μe_e  = 2.78,

    ρis_e = 0.2,
    ρif_e = 0.2,
    μif_e = 1.27,
    μis_e = 1.27,

    ρe_if = 0.2,
    ρe_is = 0.2,
    μe_if = 1.8,
    μe_is = 1.8,

    ρif_if = 0.2,
    ρis_is = 0.2,
    μif_if =4.2,
    μis_is =16.2,
)


no_connections = FullConnections(
    ## ρ = 0
)

export duarte_types, pv_only, sst_only, duartemorrison_2017, lkd_2014
