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

	AMPA  = Receptor(E_rev=E_exc, τr= τr_ampa, τd= τd_ampa,g0= gsyn_ampa)
	NMDA  = ReceptorVoltage()
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
    τd_nmda = 100.0       #(ms) nmda conductance rise time
    τr_nmda = 0.99        #(ms) nmda conductance decay time

	if compartment == "soma"
		## no NMDA
	    gsyn_nmda  = 0.   #(nS)
	end
	AMPA  = Receptor(E_rev=E_exc, τr= τr_ampa, τd= τd_ampa,g0= gsyn_ampa)
	NMDA  = ReceptorVoltage(E_rev= E_exc, τr= τr_nmda, τd= τd_nmda, g0=gsyn_nmda)

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

	AMPA  = Receptor(E_rev=E_exc, τr= τr_ampa, τd= τd_ampa,g0= gsyn_ampa)
	NMDA  = ReceptorVoltage(E_rev= E_exc, τr= τr_nmda, τd= τd_nmda, g0=gsyn_nmda)

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
    τd_gabaA= 29.0         #(ms) GABA_A decay time from fit on Tripod paper

    E_gabaB   = -90      #(mV) GABA_B reversal potential
	gsyn_gabaB = .006     #(nS)
    τr_gabaB= 30       #(ms) GABA_B conductance decay time
    τd_gabaB= 100 ##Why       #(ms) GABA_B conductance decay time

	if compartment == "soma"
		## no GabaB
	    gsyn_gabaB = 0.0  #(nS)

		## fit from Miles
	    gsyn_gabaA = .265   #(nS)
	    τr_gabaA= 5.1     #(ms) GABA_A decay time
	    τd_gabaA= 18.0    #(ms) GABA_A decay time
	end

	GABAa = Receptor(E_rev = E_gabaA,τr= τr_gabaA, τd= τd_gabaA, g0= gsyn_gabaA)
	GABAb = Receptor(E_rev = E_gabaB,τr= τr_gabaB, τd= τd_gabaB, g0= gsyn_gabaB)

    return GABAa, GABAb
end



function duarte_pv_synapses()
    E_exc    =  0.00       #(mV) Excitatory reversal potential
	E_gabaB   = -90      #(mV) GABA_B reversal potential
    E_gabaA   = -75       #(mV) GABA_A reversal potential

	gsyn_ampa   = 1.040196
	# τr_ampa   = 0.087500
	τr_ampa   = 0.180000
	τd_ampa   = 0.700000

	gsyn_nmda   = 0.002836
	τr_nmda   = 0.990099
	τd_nmda   = 100.000000

	gsyn_gabaA   = 0.844049
	# τr_gabaA   = 0.096154
	τr_gabaA   = 0.192308
	τd_gabaA   = 2.500000

	gsyn_gabaB   = 0.009419
	τr_gabaB   = 12.725924
	τd_gabaB   = 118.866124

	AMPA  = Receptor(E_rev=E_exc, τr= τr_ampa, τd= τd_ampa,g0= gsyn_ampa)
	NMDA  = ReceptorVoltage(E_rev= E_exc, τr= τr_nmda, τd=τd_nmda, g0=gsyn_nmda)
	GABAa = Receptor(E_rev = E_gabaA,τr= τr_gabaA, τd= τd_gabaA, g0= gsyn_gabaA)
	GABAb = Receptor(E_rev = E_gabaB,τr= τr_gabaB, τd= τd_gabaB, g0= gsyn_gabaB)

    return Synapse(AMPA, NMDA, GABAa, GABAb)

end

function duart_sst_synapses()
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

	AMPA  = Receptor(E_rev=E_exc, τr= τr_ampa, τd= τd_ampa,g0= gsyn_ampa)
	NMDA  = ReceptorVoltage(E_rev= E_exc, τr= τr_nmda, τd= τd_nmda, g0=gsyn_nmda)
	GABAa = Receptor(E_rev = E_gabaA,τr= τr_gabaA, τd= τd_gabaA, g0= gsyn_gabaA)
	GABAb = Receptor(E_rev = E_gabaB,τr= τr_gabaB, τd= τd_gabaB, g0= gsyn_gabaB)
    return Synapse(AMPA, NMDA, GABAa, GABAb)
end


#==========================================
			Synaptic Parameters
==========================================#

function exc_inh_synapses(exc::Function, inh::Function, compartment::String)
	AMPA, NMDA = exc(compartment)
	GABAa, GABAb = inh(compartment)
    return Synapse(AMPA, NMDA, GABAa, GABAb)
end

export miles_inh_synapses, duarte_exc_synapses, koch_exc_synapses, eyal_exc_synapses, duarte_sst_synapses, duarte_pv_synapses
