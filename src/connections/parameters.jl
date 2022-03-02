
duarte_types = (e=0.8, pv=0.2*0.65, sst=0.2*.35)
pv_only      = (e=0.8, pv=0., sst=0.2)
sst_only     = (e=0.8, pv=0.2, sst=0.)

soma_connections = [
    [:e,  :e,  :e_s_e,   :ρe_s_e, :μe_e, :σe_e],
    [:s,  :e,  :is_e,    :ρis_e ,:μis_e,  :σis_e ],
    [:f,  :e,  :if_e,    :ρif_e ,:μif_e,  :σif_e ],

    [:e,  :s,  :e_s_is,  :ρe_is ,:μe_is,  :σe_is ],
    [:s, :s,   :is_is,   :ρis_is, :μis_is, :σis_is],
    [:f,  :s,  :if_is,   :ρif_is, :μif_is, :σif_is],

    [:e,  :f,  :e_if,    :ρe_if ,:μe_if,  :σe_if ],
    [:s,  :f,  :is_if,   :ρis_if, :μis_if, :σis_if],
    [:f,  :f,  :if_if,   :ρif_if, :μif_if, :σif_if],
]

no_connections = Connections(
    map = soma_connections,
    params= (
    ρe_s_e=0,
    ρe_d_e=0,
    ρif_e =0,
    ρis_e =0,
    ρe_if =0,
    ρe_is =0,
    ρif_if=0,
    ρis_if=0,
    ρif_is=0,
    ρis_is=0,
    μe_e  =0,
    μif_e =0,
    μis_e =0,
    μe_if =0,
    μe_is =0,
    μif_if=0,
    μis_if=0,
    μif_is=0,
    μis_is=0,
    σe_e  =0,
    σif_e =0,
    σis_e =0,
    σe_if =0,
    σe_is =0,
    σif_if=0,
    σis_if=0,
    σif_is=0,
    σis_is=0
    )
)

duartemorrison2017 =  Connections(
    map = soma_connections,
    params= (
    ρe_s_e  = 0.168,
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
)

lkd2014 =
Connections(
    map = soma_connections,
    params= (
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
)
