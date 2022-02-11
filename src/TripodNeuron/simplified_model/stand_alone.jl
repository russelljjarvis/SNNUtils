using ProgressBars
using Distributions
include("tripod.jl")
include("synapses.jl")
include("units.jl")
include("../parameters.jl")
dt = 0.1
AP_membrane = 20. ## Spike potential
BAP_gax = 1.
BAP =1.
AdEx = get_AdEx_params()

syn_exc= eyal_exc_synapse
syn_inh= miles_inh_synapse
Esyn_dend = exc_inh_synapses(syn_exc, syn_inh, "dend")
Esyn_soma = exc_inh_synapses(syn_exc, syn_inh, "soma")
postspike = PostSpike(AP_membrane, round(Int,1/dt), 30)
Mg_mM     = 1.
HUMAN = Physiology(200Ω*cm,38907Ω*cm^2, 0.5μF/cm^2)

include("simulation.jl")
