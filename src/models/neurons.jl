#===========================
Get neuronal parameters
===========================#
PVDuarte = SNN.IFParameterSingleExponential(τm = 104.52pF / 9.75nS, El = -64.33mV, Vt = -38.97mV, Vr = -57.47mV, τabs = 0.5ms)

SSTDuarte = SNN.IFParameterSingleExponential(τm = 102.86pF / 4.61nS, El = -61mV, Vt = -34.4mV, Vr = -47.11mV, τabs = 1.3ms, )


# const TripodSynapseSST = let
#     E_exc = 0.00       #(mV) Excitatory reversal potential
#     E_gabaA = -75       #(mV) GABA_A reversal potential
#     E_gabaB = -90      #(mV) GABA_B reversal potential

#     gsyn_ampa = 0.557470
#     τr_ampa = 0.180000
#     τd_ampa = 1.800000
#     gsyn_gabaA = 0.590834
#     τr_gabaA = 0.192308
#     τd_gabaA = 5.000000

#     AMPA = Receptor(E_rev = E_exc, τr = τr_ampa, τd = τd_ampa, g0 = gsyn_ampa)
#     NMDA = ReceptorVoltage()
#     GABAa = Receptor(E_rev = E_gabaA, τr = τr_gabaA, τd = τd_gabaA, g0 = gsyn_gabaA)
#     GABAb = Receptor()
#     Synapse(AMPA, NMDA, GABAa, GABAb)
# end

# const TripodSynapsePV = let
#     E_exc = 0.00       #(mV) Excitatory reversal potential
#     E_gabaB = -90      #(mV) GABA_B reversal potential
#     E_gabaA = -75       #(mV) GABA_A reversal potential

#     gsyn_ampa = 1.040196
#     # τr_ampa   = 0.087500
#     τr_ampa = 0.180000
#     τd_ampa = 0.700000

#     gsyn_gabaA = 0.844049
#     # τr_gabaA   = 0.096154
#     τr_gabaA = 0.192308
#     τd_gabaA = 2.500000

#     AMPA = Receptor(E_rev = E_exc, τr = τr_ampa, τd = τd_ampa, g0 = gsyn_ampa)
#     GABAa = Receptor(E_rev = E_gabaA, τr = τr_gabaA, τd = τd_gabaA, g0 = gsyn_gabaA)
#     NMDA = ReceptorVoltage()
#     GABAb = Receptor()
#     Synapse(AMPA, NMDA, GABAa, GABAb)
# end



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

