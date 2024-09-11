#===========================
Get neuronal parameters
===========================#

PVDuarte = LIF(
    Er = -64.33,
    u_r = -57.47,   #(mV)
    θ = -38.97,   #(mV)
    C = 104.52,    #(pF)
    gl = 9.75,       #(nS)
    a = 0.0,       #(nS) 'sub-threshold' adaptation conductance
    b = 10.0,       #(pA) 'sra' current increment
    τw = 144,        #(s) adaptation time constant (~Ca-activated K current inactivation)
    idle = 0.52,       #(ms)
)

SSTDuarte = LIF(
    Er = -61,
    u_r = -47.11,
    θ = -34.4,
    C = 102.87,     #(pF)
    gl = 4.61,       #(nS)
    a = 4.0,        #(nS) 'sub-threshold' adaptation conductance
    b = 80.5,       #(pA) 'sra' current increment
    τw = 144,        #(s) adaptation time constant (~Ca-activated K current inactivation)
    idle = 1.34,       #(ms)
)

AdExTripod = AdExParams(Er = -55, u_r = -60, θ_adapt = 0.0)

AdExDuarte = AdExParams(Er = -76.43, C = 116.5, gl = 4.64, θ = -44.45, idle = 2.05)
#@TODO
# add θ_adapt=false

AdExLKD = AdExParams(Er = -70, θ = -52.0, C = 300, gl = 15.0, u_r = -60.0f0)

PVLKD = LIF(
    Er = -62.0,
    u_r = -57.47,   #(mV)
    θ = -52.0,   #(mV)
    C = 300.0,    #(pF)
    gl = 15.0,       #(nS)
    a = 0.0,       #(nS) 'sub-threshold' adaptation conductance
    b = 0.0,       #(pA) 'sra' current increment
    τw = 144,        #(s) adaptation time constant (~Ca-activated K current inactivation)
    idle = 1,       #(ms)
)

### Network models

DuarteNeurons = NeuronModels(AdEx = AdExDuarte, LIF_sst = SSTDuarte, LIF_pv = PVDuarte)

LKDNeurons = NeuronModels(AdEx = AdExLKD, LIF_sst = SSTDuarte, LIF_pv = PVLKD)

TripodNeurons = NeuronModels(AdEx = AdExTripod, LIF_sst = SSTDuarte, LIF_pv = PVDuarte)


postspike = PostSpike(A = 10, τA = 30)
