#===========================
Get neuronal parameters
===========================#
PVDuarte = SNN.IFParameter(τm = 104.52pF / 9.75nS, El = -64.33mV, Vt = -38.97mV, Vr = -57.47mV, τabs = 0.5ms)

SSTDuarte = SNN.IFParameter(τm = 102.86pF / 4.61nS, El = -61mV, Vt = -34.4mV, Vr = -47.11mV, τabs = 1.3ms)

# AdExTripod = AdExParams(Er = -55, u_r = -60, θ_adapt = 0.0)

# AdExDuarte = AdExParams(Er = -76.43, C = 116.5, gl = 4.64, θ = -44.45, idle = 2.05)
# #@TODO
# # add θ_adapt=false

# AdExLKD = AdExParams(Er = -70, θ = -52.0, C = 300, gl = 15.0, u_r = -60.0f0)

# PVLKD = SNN.IFParameter()

# PVLKD = LIF(
#     Er = -62.0,
#     u_r = -57.47,   #(mV)
#     θ = -52.0,   #(mV)
#     C = 300.0,    #(pF)
#     gl = 15.0,       #(nS)
#     a = 0.0,       #(nS) 'sub-threshold' adaptation conductance
#     b = 0.0,       #(pA) 'sra' current increment
#     τw = 144,        #(s) adaptation time constant (~Ca-activated K current inactivation)
#     idle = 1,       #(ms)
# )

