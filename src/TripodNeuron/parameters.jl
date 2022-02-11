#=====================================
#  		Neuron and Dendrite params
=====================================#

function get_AdEx_params(;initburst=false, noadapt=false)
	## Parameters from BretteGerstner2005
    ## membrane params
    C     = 281        #(pF)
    gL    = 40         #(nS) leak conductance #BretteGerstner2005 says 30 nS
    τm    = C/gL       #(ms) membrane RC time

	# thresholds
    u_reset = -70.6      #(mV)
	Erest  = -70.6
	θ    = -44.4

    ## adaptation
    τw    = 144        #(ms) adaptation time constant (~Ca-activated K current inactivation)

    a     = 4.0        #(nS) 'sub-threshold' adaptation conductance
    b     = 80.5       #(pA) 'sra' current increment

	if noadapt
		a=0
		b=0
	end

	up = 1.
	idle=2.

    # I0    = 0.65e-9  #(A) applied current in test example
    initburst =false
    if initburst
        τm= 5e-3
        gL  = 2e-9     # leak conductance
        Cm  = τm*gL
        a   = 0.5e-9   # 'sub-threshold' adaptation conductance
        b   = 7e-12    # 'sra' current increment
        τw= 0.200    # adaptation time constant (~Ca-activated K current inactivation)
        I0  = 0.065e-9 # applied current
    end
	# syn_soma = get_synapses_params_exc(dt,"soma")
	# syn_dend = get_synapses_params_exc(dt,"dend")
    return AdExParams(τm, gL, Erest, u_reset, θ, τw, a, b, up, idle)
end

function get_lif_params(type::String)
	if type=="PV"
	    a     = .0        #(nS) 'sub-threshold' adaptation conductance
	    b     = 10.       #(pA) 'sra' current increment
	    τw    = 144        #(s) adaptation time constant (~Ca-activated K current inactivation)
		Erest  = -64.33
	    u_reset = -57.47   #(mV)
	    θ  = -38.97   #(mV)
	    C     = 104.52     #(pF)
	    gL    = 9.75       #(nS)
	    t_ref  = 0.52       #(ms)
	    τm    = C/gL       #(ms) membrane RC time
	    return LIF(τm, gL, Erest, u_reset, θ, t_ref, a,b,τw)

	elseif type =="SST"
	    a     = 4.0        #(nS) 'sub-threshold' adaptation conductance
	    b     = 80.5       #(pA) 'sra' current increment
	    τw    = 144        #(s) adaptation time constant (~Ca-activated K current inactivation)
		Erest  = -61
	    u_reset = -47.11   #(mV)
		θ    = -34.4
	    C       = 102.87     #(pF)
	    gL      = 4.61       #(nS)
	    t_ref    = 1.34       #(ms)
	    τm      = C/gL       #(ms) membrane RC time
	    return LIF(τm, gL, Erest, u_reset, θ, t_ref, a,b,τw)
	end
     #(s) adaptation time constant (~Ca-activated K current inactivation)
end

#=====================================
#  			Synapses params
=====================================#

"""
	koch_parameters()

Parameters from:
Christof Koch. Biophysics of Computation: Information Processing in Single Neurons, by.Trends in Neurosciences, 22842(7):328–329, July 1999. ISSN 0166-2236, 1878-108X. doi: 10.1016/S0166-2236(99)01403-4.
"""
function koch_exc_synapse(compartment::String)
    E_exc    =  0.00       #(mV) Excitatory reversal potential
    gsyn_ampa  = 0.73   #(nS) from Renato heterogeneity paper
    τr_ampa = 0.2        #(ms) ampa conductance decay time
    τd_ampa = 25.0         #(ms) ampa conductance rise time

    gsyn_nmda  = 0.   #(nS)
    # gsyn_nmda  = 0.1269   #(nS)
    τd_nmda = 100.0       #(ms) nmda conductance rise time
    τr_nmda = 0.99        #(ms) nmda conductance decay time

	if compartment == "soma"
		## no NMDA
	    gsyn_nmda  = 0.   #(nS)
	end

    nmda_b   = 3.36       #(no unit) parameters for voltage dependence of nmda channels
    nmda_k   = -0.062     #(1/V) source: http://dx.doi.org/10.1016/j.neucom.2011.04.018)
    nmda_v   = 0.0        #(1/V)    source: http://dx.doi.org/10.1016/j.neucom.2011.04.018)

	AMPA  = Receptor(E_exc, τr_ampa, τd_ampa, gsyn_ampa)
	NMDA  = ReceptorVoltage(E_exc, τr_nmda, τd_nmda, gsyn_nmda, nmda_b, nmda_k, nmda_v)

	return AMPA, NMDA
end

function NAR_exc_synapse(compartment::String, nar, timescale)
    E_exc    =  0.00       #(mV) Excitatory reversal potential
    gsyn_ampa  = 0.73   #(nS) from Renato heterogeneity paper
    τr_ampa = 0.26        #(ms) ampa conductance decay time
    τd_ampa = 2.0         #(ms) ampa conductance rise time

    gsyn_nmda  = gsyn_ampa*nar   #(nS)
    # gsyn_nmda  = 0.1269   #(nS)
	if timescale =="human"
	    τd_nmda = 34.99       #(ms) nmda conductance decay time
	    τr_nmda = 8.          #(ms) nmda conductance rise time
	else
	    τd_nmda = 100.0       #(ms) nmda conductance rise time
	    τr_nmda = 0.99        #(ms) nmda conductance decay time
	end

	if compartment == "soma"
		## no NMDA
	    gsyn_nmda  = 0.   #(nS)
	end

    nmda_b   = 3.36       #(no unit) parameters for voltage dependence of nmda channels
    nmda_k   = -0.062     #(1/V) source: http://dx.doi.org/10.1016/j.neucom.2011.04.018)
    nmda_v   = 0.0        #(1/V)    source: http://dx.doi.org/10.1016/j.neucom.2011.04.018)

	AMPA  = Receptor(E_exc, τr_ampa, τd_ampa, gsyn_ampa)
	NMDA  = ReceptorVoltage(E_exc, τr_nmda, τd_nmda, gsyn_nmda, nmda_b, nmda_k, nmda_v)

	return AMPA, NMDA
end


"""
	duarte_parameters()

Parameters from:
Renato Duarte and Abigail Morrison. Leveraging heterogeneity for neural computation with fading memory in layer 2/3808cortical microcircuits.bioRxiv, December 2017. doi: 10.1101/230821.
"""
function duarte_exc_synapse(compartment::String)
    E_exc    =  0.00       #(mV) Excitatory reversal potential

    gsyn_ampa  = 0.73   #(nS) from Renato heterogeneity paper
    τr_ampa = 0.26        #(ms) ampa conductance decay time
    τd_ampa = 2.0         #(ms) ampa conductance rise time

    gsyn_nmda  = 0.1595   #(nS)
    # gsyn_nmda  = 0.1269   #(nS)
    τd_nmda = 100.0       #(ms) nmda conductance rise time
    τr_nmda = 0.99        #(ms) nmda conductance decay time

	if compartment == "soma"
		## no NMDA
	    gsyn_nmda  = 0.   #(nS)
	end

    nmda_b   = 3.36       #(no unit) parameters for voltage dependence of nmda channels
    nmda_k   = -0.062     #(1/V) source: http://dx.doi.org/10.1016/j.neucom.2011.04.018)
    nmda_v   = 0.0        #(1/V)    source: http://dx.doi.org/10.1016/j.neucom.2011.04.018)

	AMPA  = Receptor(E_exc, τr_ampa, τd_ampa, gsyn_ampa)
	NMDA  = ReceptorVoltage(E_exc, τr_nmda, τd_nmda, gsyn_nmda, nmda_b, nmda_k, nmda_v)

	return AMPA, NMDA

end


"""
	eyal_parameters()

Parameters from:
Guy Eyal, Matthijs B. Verhoog, Guilherme Testa-Silva, Yair Deitcher, Ruth Benavides-Piccione, Javier DeFelipe, Chris-832tiaan P. J. de Kock, Huibert D. Mansvelder, and Idan Segev. Human Cortical Pyramidal Neurons: From Spines to833Spikes via Models.Frontiers in Cellular Neuroscience, 12, 2018. ISSN 1662-5102. doi: 10.3389/fncel.2018.00181.
"""
function eyal_exc_synapse(compartment::String)
    E_exc    =  0.00       #(mV) Excitatory reversal potential

    gsyn_ampa  = 0.73     #(nS) from Renato heterogeneity paper
    τr_ampa = 0.26        #(ms) ampa conductance decay time
    τd_ampa = 2.0         #(ms) ampa conductance rise time

    gsyn_nmda  = 1.31     #(nS)
    τd_nmda = 34.99       #(ms) nmda conductance decay time
    τr_nmda = 8.          #(ms) nmda conductance rise time

	if compartment == "soma"
		## no NMDA
	    gsyn_nmda  = 0.   #(nS)
	end

    nmda_b   = 3.36       #(no unit) parameters for voltage dependence of nmda channels
    nmda_k   = -0.062     #(1/V) source: http://dx.doi.org/10.1016/j.neucom.2011.04.018)
    nmda_v   = 0.0        #(1/V)    source: http://dx.doi.org/10.1016/j.neucom.2011.04.018)

	# ## To be implemented in equations:
	# τD  = 500 			  # Synaptic vescicles depression from Wang 1999
	# pv  = 0.35

	AMPA  = Receptor(E_exc, τr_ampa, τd_ampa, gsyn_ampa)
	NMDA  = ReceptorVoltage(E_exc, τr_nmda, τd_nmda, gsyn_nmda, nmda_b, nmda_k, nmda_v)

	return AMPA, NMDA
end

"""
	miles_parameters()

Parameters from:
Richard Miles, Katalin Tóth, Attila I Gulyás, Norbert Hájos, and Tamas F Freund.  Differences between Somatic923and Dendritic Inhibition in the Hippocampus.Neuron, 16(4):815–823, April 1996. ISSN 0896-6273. doi: 10.1016/924S0896-6273(00)80101-4.
"""
function miles_inh_synapse(compartment::String)
    E_gabaA   = -75       #(mV) GABA_A reversal potential
    gsyn_gabaA = 0.1259   #(nS)
    τr_gabaA= 4.8        #(ms) GABA_A decay time
    τd_gabaA= 29.0         #(ms) GABA_A decay time

    E_gabaB   = -90      #(mV) GABA_B reversal potential
	gsyn_gabaB = .006     #(nS)
    τr_gabaB= 30       #(ms) GABA_B conductance decay time
    τd_gabaB= 400        #(ms) GABA_B conductance decay time

	if compartment == "soma"
		## no GabaB no NMDA
	    gsyn_gabaB = 0.0  #(nS)

		## fit from Miller
	    gsyn_gabaA = .265   #(nS)
	    τr_gabaA= 0.1     #(ms) GABA_A decay time
	    τd_gabaA= 18.0    #(ms) GABA_A decay time
	end

	GABAa = Receptor(E_gabaA, τr_gabaA, τd_gabaA, gsyn_gabaA)
	GABAb = Receptor(E_gabaB, τr_gabaB, τd_gabaB, gsyn_gabaB)

    return GABAa, GABAb
end

function get_synapses_pv()
    E_exc    =  0.00       #(mV) Excitatory reversal potential
	E_gabaB   = -90      #(mV) GABA_B reversal potential
    E_gabaA   = -75       #(mV) GABA_A reversal potential

	gsyn_ampa   = 1.040196
	# τr_ampa   = 0.087500
	τd_ampa   = 0.700000

	gsyn_nmda   = 0.002836
	τr_nmda   = 0.990099
	τd_nmda   = 100.000000

	gsyn_gabaA   = 0.844049
	# τr_gabaA   = 0.096154
	τd_gabaA   = 2.500000

	gsyn_gabaB   = 0.009419
	τr_gabaB   = 12.725924
	τd_gabaB   = 118.866124


    nmda_b   = 3.36       #(no unit) parameters for voltage dependence of nmda channels
    nmda_k   = -0.062     #(1/V) source: http://dx.doi.org/10.1016/j.neucom.2011.04.018)
    nmda_v   = 0.0        #(1/V)    source: http://dx.doi.org/10.1016/j.neucom.2011.04.018)
	nar = 1.
	## To be implemented in equations:
	τD  = 500 			  # Synaptic vescicles depression from Wang 1999
	pv  = 0.35

	# fast synapses have not rise time
	AMPA  = Receptor(E_exc  , τd_ampa,  gsyn_ampa)
	GABAa = Receptor(E_gabaA, τd_gabaA, gsyn_gabaA)

	NMDA  = ReceptorVoltage(E_exc,τr_nmda, τd_nmda, gsyn_nmda, nmda_b, nmda_k, nmda_v)
	GABAb = Receptor(E_gabaB,τr_gabaB, τd_gabaB, gsyn_gabaB)

    return Synapse(AMPA, NMDA, GABAa, GABAb, true)

end

function get_synapses_sst()
    E_exc    =  0.00       #(mV) Excitatory reversal potential
    E_gabaA   = -75       #(mV) GABA_A reversal potential
    E_gabaB   = -90      #(mV) GABA_B reversal potential

	gsyn_ampa   = 0.557470
	τr_ampa   = 0.180000
	τd_ampa   = 1.800000

	gsyn_nmda   = 0.011345
	τr_nmda   = 0.990099
	τd_nmda   = 100.000000

	gsyn_gabaA   = 0.590834
	τr_gabaA   = 0.192308
	τd_gabaA   = 5.000000

	gsyn_gabaB   = 0.016290
	τr_gabaB   = 21.198947
	τd_gabaB   = 193.990036


    nmda_b   = 3.36       #(no unit) parameters for voltage dependence of nmda channels
    nmda_k   = -0.062     #(1/V) source: http://dx.doi.org/10.1016/j.neucom.2011.04.018)
    nmda_v   = 0.0        #(1/V)    source: http://dx.doi.org/10.1016/j.neucom.2011.04.018)
	nar = 1.
	## To be implemented in equations:
	τD  = 500 			  # Synaptic vescicles depression from Wang 1999
	pv  = 0.35

	AMPA  = Receptor(E_exc, τr_ampa, τd_ampa, gsyn_ampa)
	NMDA  = ReceptorVoltage(E_exc, τr_nmda, τd_nmda, gsyn_nmda, nmda_b, nmda_k, nmda_v)
	GABAa = Receptor(E_gabaA, τr_gabaA, τd_gabaA, gsyn_gabaA)
	GABAb = Receptor(E_gabaB, τr_gabaB, τd_gabaB, gsyn_gabaB)


    return Synapse(AMPA, NMDA, GABAa, GABAb, false)

end


get_synapses_pv()
