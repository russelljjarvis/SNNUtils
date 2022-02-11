const dt = 0.1
const do_plot = true

## Set tripod params
const AP_membrane = 20.
const BAP_gax = 1.
const BAP = 1.
const postspike = PostSpike(10., round(Int,1/dt), 30)
const Mg_mM     = 1.
const AdEx = get_AdEx_params()

## Set synaptic parameters
syn_exc= eyal_exc_synapse
syn_inh= miles_inh_synapse

Esyn_dend = exc_inh_synapses(syn_exc, syn_inh, "dend")
Esyn_soma = exc_inh_synapses(syn_exc, syn_inh, "soma")


## Set physiology
const HUMAN = Physiology(200Ω*cm,38907Ω*cm^2, 0.5μF/cm^2)
const MOUSE = Physiology(200Ω*cm,1700Ω*cm^2,1μF/cm^2)

## Set dendritic geometry
const H_distal_distal    = "H. 1->s, 400,4; 2->s, 400, 4"
const H_proximal_proximal= "H. 1->s, 150,4; 2->s, 150, 4"
const H_medial_proximal  = "H. 1->s, 314,4; 2->s, 150, 4"
const H_distal_proximal  = "H. 1->s, 400,4; 2->s, 150, 4"
const H_ball_stick       = "H. 1->s, 400,4"

const H_proximal_thin    = "H. 1->s, 150,2.5; 2->s, 150, 4"
const H_medial           = "H. 1->s, 314,4; 2->s, 314, 4"
const H_distal           = "H. 1->s, 400,4; 2->s, 400, 4"
const H_proximal         = "H. 1->s, 150,4; 2->s, 150, 4"
const H_ss               = "H. 1->1, 100,4; 2->2,100,4"

const M_distal_distal    = "M. 1->s, 400,4; 2->s, 400, 4"
const M_proximal_proximal= "M. 1->s, 150,4; 2->s, 150, 4"
const M_distal_proximal  = "M. 1->s, 400,4; 2->s, 150, 4"
const M_ball_stick       = "M. 1->s, 400,4"
const M_proximal_thin    = "M. 1->s, 150,2; 2->s, 150, 4"
const M_medial           = "M. 1->s, 314,4; 2->s, 314, 4"

const default_model  = M_distal_proximal

const models = [H_distal, H_medial, H_proximal, H_distal_proximal, H_medial_proximal, H_ss]
const labels = ["distal-distal", "sh.distal-sh.distal", "proximal-proximal", "distal-proximal", "sh.distal-proximal", "soma only"]
# With the set parameter this is the maximal dendritic length for somatic spikes
const distal_th = 314

## Set non-tripod neurons
AdEx_Soma(id::Int64)  = Soma(id, Esyn_soma, "AdEx")
AdEx_Soma(;) =  Soma( Esyn_soma, "AdEx")

## Inhibitory cells
LIF_pv  = get_lif_params("PV")
LIF_sst  = get_lif_params("SST")
Isyn_sst  = get_synapses_sst()
Isyn_pv   = get_synapses_pv()

SST(;) = Soma(Isyn_sst, "SST")
SST(id::Int64) =  Soma(id, Isyn_sst, "SST")
PV(;) = Soma(Isyn_pv, "PV")
PV(id::Int64) = Soma(id, Isyn_pv, "PV")
