#=====================================
#  			Synapses params
=====================================#

"""
Christof Koch. Biophysics of Computation: Information Processing in Single Neurons, by.Trends in Neurosciences, 22842(7):328–329, July 1999. ISSN 0166-2236, 1878-108X. doi: 10.1016/S0166-2236(99)01403-4.
"""
const KochGlu =
    Glutamatergic(Receptor(E_rev = 0.00, τr = 0.2, τd = 25.0, g0 = 0.73), ReceptorVoltage())


"""
Guy Eyal, Matthijs B. Verhoog, Guilherme Testa-Silva, Yair Deitcher, Ruth Benavides-Piccione, Javier DeFelipe, Chris-832tiaan P. J. de Kock, Huibert D. Mansvelder, and Idan Segev. Human Cortical Pyramidal Neurons: From Spines to833Spikes via Models.Frontiers in Cellular Neuroscience, 12, 2018. ISSN 1662-5102. doi: 10.3389/fncel.2018.00181.
"""

const EyalGluDend = Glutamatergic(
    Receptor(E_rev = 0.0, τr = 0.25, τd = 2.0, g0 = 0.73),
    ReceptorVoltage(E_rev = 0.0, τr = 8, τd = 35.0, g0 = 1.31),
)

const EyalGluDend_AMPA =
    Glutamatergic(Receptor(E_rev = 0.0, τr = 0.26, τd = 2.0, g0 = 2.0), ReceptorVoltage())

EyalGluDend_NMDA_short(τd) = Glutamatergic(
    Receptor(E_rev = 0.0, τr = 0.25, τd = 2.0, g0 = 0.73),
    ReceptorVoltage(E_rev = 0.0, τr = 8, τd = τd, g0 = 1.31),
)


# Receptor(E_rev=0.0, τr=0.26, τd=2.0,g0=0.73 -(0.73*NAR- 1.3)),
NARGluDend(; NAR, τd) = Glutamatergic(
    Receptor(E_rev = 0.0, τr = 0.26, τd = 2.0, g0 = 0.73),
    ReceptorVoltage(E_rev = 0.0, τr = 8, τd = τd, g0 = 0.73 * NAR),
)

"""
Richard Miles, Katalin Tóth, Attila I Gulyás, Norbert Hájos, and Tamas F Freund.  Differences between Somatic923and Dendritic Inhibition in the Hippocampus.Neuron, 16(4):815–823, April 1996. ISSN 0896-6273. doi: 10.1016/924S0896-6273(00)80101-4.
"""
const MilesGabaDend = GABAergic(
    Receptor(E_rev = -75.0, τr = 4.8, τd = 29.0, g0 = 0.126),
    Receptor(E_rev = -90.0, τr = 30, τd = 100.0, g0 = 0.006),
)

const MilesGabaSoma =
    GABAergic(Receptor(E_rev = -75.0, τr = 0.5, τd = 6.0, g0 = 0.265), Receptor())

const EmptyGluSynapse = Glutamatergic(Receptor(), ReceptorVoltage())
const EmptyGABASynapse = GABAergic(Receptor(), Receptor())



"""
Renato Duarte and Abigail Morrison. Leveraging heterogeneity for neural computation with fading memory in layer 2/3808cortical microcircuits.bioRxiv, December 2017. doi: 10.1101/230821.
"""

const DuarteGluAMPA = Glutamatergic(
    Receptor(E_rev = 0.0, τr = 0.25, τd = 2.0, g0 = 0.73),
    ReceptorVoltage(E_rev = 0.0),
)

const DuarteGluNMDA = Glutamatergic(
    Receptor(E_rev = 0.0, τr = 0.25, τd = 2.0, g0 = 0.73),
    ReceptorVoltage(E_rev = 0.0, τr = 0.99, τd = 100.0, g0 = 0.159),
)
function DuarteGluNAR(NAR)
    return Glutamatergic(
        Receptor(E_rev = 0.0, τr = 0.25, τd = 2.0, g0 = 0.73),
        ReceptorVoltage(E_rev = 0.0, τr = 0.99, τd = 100.0, g0 = 0.73 * NAR),
    )
end

const DuarteGabaSoma = GABAergic(
    Receptor(E_rev = -75.0, τr = 0.5, τd = 6.0, g0 = 0.265),
    Receptor(E_rev = -90.0, τr = 30, τd = 100.0, g0 = 0.006),
)

const TripodSynapseSST = let
    E_exc = 0.00       #(mV) Excitatory reversal potential
    E_gabaA = -75       #(mV) GABA_A reversal potential
    E_gabaB = -90      #(mV) GABA_B reversal potential

    gsyn_ampa = 0.557470
    τr_ampa = 0.180000
    τd_ampa = 1.800000
    gsyn_gabaA = 0.590834
    τr_gabaA = 0.192308
    τd_gabaA = 5.000000

    AMPA = Receptor(E_rev = E_exc, τr = τr_ampa, τd = τd_ampa, g0 = gsyn_ampa)
    NMDA = ReceptorVoltage()
    GABAa = Receptor(E_rev = E_gabaA, τr = τr_gabaA, τd = τd_gabaA, g0 = gsyn_gabaA)
    GABAb = Receptor()
    Synapse(AMPA, NMDA, GABAa, GABAb)
end

const TripodSynapsePV = let
    E_exc = 0.00       #(mV) Excitatory reversal potential
    E_gabaB = -90      #(mV) GABA_B reversal potential
    E_gabaA = -75       #(mV) GABA_A reversal potential

    gsyn_ampa = 1.040196
    # τr_ampa   = 0.087500
    τr_ampa = 0.180000
    τd_ampa = 0.700000

    gsyn_gabaA = 0.844049
    # τr_gabaA   = 0.096154
    τr_gabaA = 0.192308
    τd_gabaA = 2.500000

    AMPA = Receptor(E_rev = E_exc, τr = τr_ampa, τd = τd_ampa, g0 = gsyn_ampa)
    GABAa = Receptor(E_rev = E_gabaA, τr = τr_gabaA, τd = τd_gabaA, g0 = gsyn_gabaA)
    NMDA = ReceptorVoltage()
    GABAb = Receptor()
    Synapse(AMPA, NMDA, GABAa, GABAb)
end



const DuarteSynapsePV = let
    E_exc = 0.00       #(mV) Excitatory reversal potential
    E_gabaB = -90      #(mV) GABA_B reversal potential
    E_gabaA = -75       #(mV) GABA_A reversal potential

    gsyn_ampa = 1.6
    # τr_ampa   = 0.087500
    τr_ampa = 0.1#80000
    τd_ampa = 0.7#00000

    gsyn_nmda = 0.003#2836
    τr_nmda = 1.0#0.990099
    τd_nmda = 100.000000

    gsyn_gabaA = 1.0#0.844049
    # τr_gabaA   = 0.096154
    τr_gabaA = 0.1#92308
    τd_gabaA = 2.5#00000

    gsyn_gabaB = 0.022#09419
    τr_gabaB = 25#12.725924
    τd_gabaB = 400#.866124

    AMPA = Receptor(E_rev = E_exc, τr = τr_ampa, τd = τd_ampa, g0 = gsyn_ampa)
    NMDA = ReceptorVoltage(E_rev = E_exc, τr = τr_nmda, τd = τd_nmda, g0 = gsyn_nmda)
    GABAa = Receptor(E_rev = E_gabaA, τr = τr_gabaA, τd = τd_gabaA, g0 = gsyn_gabaA)
    GABAb = Receptor(E_rev = E_gabaB, τr = τr_gabaB, τd = τd_gabaB, g0 = gsyn_gabaB)
    # NMDA  = ReceptorVoltage()
    # GABAb = Receptor()

    Synapse(AMPA, NMDA, GABAa, GABAb)
end

const DuarteSynapseSST = let
    E_exc = 0.00       #(mV) Excitatory reversal potential
    E_gabaA = -75       #(mV) GABA_A reversal potential
    E_gabaB = -90      #(mV) GABA_B reversal potential

    gsyn_ampa = 0.8
    τr_ampa = 0.2
    τd_ampa = 1.8

    gsyn_nmda = 0.012
    τr_nmda = 1.0
    τd_nmda = 100.0

    gsyn_gabaA = 0.7
    τr_gabaA = 0.2
    τd_gabaA = 5.0

    gsyn_gabaB = 0.025
    τr_gabaB = 25.0 #198947
    τd_gabaB = 500.0 #990036

    AMPA = Receptor(E_rev = E_exc, τr = τr_ampa, τd = τd_ampa, g0 = gsyn_ampa)
    NMDA = ReceptorVoltage(E_rev = E_exc, τr = τr_nmda, τd = τd_nmda, g0 = gsyn_nmda)
    GABAa = Receptor(E_rev = E_gabaA, τr = τr_gabaA, τd = τd_gabaA, g0 = gsyn_gabaA)
    GABAb = Receptor(E_rev = E_gabaB, τr = τr_gabaB, τd = τd_gabaB, g0 = gsyn_gabaB)
    Synapse(AMPA, NMDA, GABAa, GABAb)
end

"""
Litwin-Kumar, A., & Doiron, B. (2014). Formation and maintenance of neuronal assemblies through synaptic plasticity. Nature Communications, 5(1). https://doi.org/10.1038/ncomms6319
"""

const LKDGluSoma = Glutamatergic(
    Receptor(E_rev = 0.0, τr = 1.0, τd = 6.0, g0 = 1.0),
    ReceptorVoltage(E_rev = 0.0),
)

const LKDGabaSoma =
    GABAergic(Receptor(E_rev = -75.0, τr = 0.5, τd = 2.0, g0 = 1.0), Receptor())

##
const LKDSynapses = SynapseModels(
    Esyn_soma = Synapse(LKDGluSoma, LKDGabaSoma),
    Esyn_dend = Synapse(EmptyGluSynapse, EmptyGABASynapse),
    Isyn_sst = DuarteSynapseSST,
    Isyn_pv = Synapse(LKDGluSoma, LKDGabaSoma),
)


const DuarteSynapses = SynapseModels(
    Esyn_soma = Synapse(DuarteGluNMDA, DuarteGabaSoma),
    Esyn_dend = Synapse(EmptyGluSynapse, EmptyGABASynapse),
    Isyn_sst = DuarteSynapseSST,
    Isyn_pv = DuarteSynapsePV,
)

function DuarteSynapsesNAR(NAR)
    return SynapseModels(
        Esyn_soma = Synapse(DuarteGluNAR(NAR), DuarteGabaSoma),
        Esyn_dend = Synapse(EmptyGluSynapse, EmptyGABASynapse),
        Isyn_sst = DuarteSynapseSST,
        Isyn_pv = DuarteSynapsePV,
    )
end

function TripodSynapses_NMDA_short(τd)
    return SynapseModels(
        Esyn_soma = Synapse(DuarteGluAMPA, MilesGabaSoma),
        Esyn_dend = Synapse(EyalGluDend_NMDA_short(τd), MilesGabaDend),
        Isyn_sst = TripodSynapseSST,
        Isyn_pv = TripodSynapsePV,
    )
end

const TripodSynapses_AMPA = SynapseModels(
    Esyn_soma = Synapse(DuarteGluAMPA, MilesGabaSoma),
    Esyn_dend = Synapse(EyalGluDend_AMPA, MilesGabaDend),
    Isyn_sst = TripodSynapseSST,
    Isyn_pv = TripodSynapsePV,
)


const TripodSynapses = SynapseModels(
    Esyn_soma = Synapse(DuarteGluAMPA, MilesGabaSoma),
    Esyn_dend = Synapse(EyalGluDend, MilesGabaDend),
    Isyn_sst = TripodSynapseSST,
    Isyn_pv = TripodSynapsePV,
)

function TripodSynapses_NAR(; NAR::Float32 = 1.8f0, τd::Float32 = 35.0f0)
    return SynapseModels(
        Esyn_soma = Synapse(DuarteGluAMPA, MilesGabaSoma),
        Esyn_dend = Synapse(NARGluDend(NAR = NAR, τd = τd), MilesGabaDend),
        Isyn_sst = TripodSynapseSST,
        Isyn_pv = TripodSynapsePV,
    )
end
