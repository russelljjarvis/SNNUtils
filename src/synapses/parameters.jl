#=====================================
#  			Synapses params
=====================================#

"""
	koch_parameters()

Parameters from:
Christof Koch. Biophysics of Computation: Information Processing in Single Neurons, by.Trends in Neurosciences, 22842(7):328–329, July 1999. ISSN 0166-2236, 1878-108X. doi: 10.1016/S0166-2236(99)01403-4.
"""
KochGlu = Glutamatergic(
		Receptor(E_rev=0.00, τr= 0.2, τd=25.0,g0=0.73),
		ReceptorVoltage()
		)


"""
Renato Duarte and Abigail Morrison. Leveraging heterogeneity for neural computation with fading memory in layer 2/3808cortical microcircuits.bioRxiv, December 2017. doi: 10.1101/230821.
"""

GluSoma = Glutamatergic(
		 Receptor(E_rev=0.0, τr=0.25, τd=2.0,g0=0.73),
		 ReceptorVoltage())

DuarteGluDend = Glutamatergic(
		 Receptor(E_rev=0.0, τr=0.25, τd=2.0,g0=0.73),
		 ReceptorVoltage(E_rev=0.0, τr = 0.99, τd=100., g0 = 0.159)
)

"""
	eyal_parameters()

Parameters from:
Guy Eyal, Matthijs B. Verhoog, Guilherme Testa-Silva, Yair Deitcher, Ruth Benavides-Piccione, Javier DeFelipe, Chris-832tiaan P. J. de Kock, Huibert D. Mansvelder, and Idan Segev. Human Cortical Pyramidal Neurons: From Spines to833Spikes via Models.Frontiers in Cellular Neuroscience, 12, 2018. ISSN 1662-5102. doi: 10.3389/fncel.2018.00181.
"""

EyalGluDend = Glutamatergic(
		 Receptor(E_rev=0.0, τr=0.25, τd=2.0,g0=0.73),
		 ReceptorVoltage(E_rev=0.0, τr = 1.31, τd=35., g0 = 1.31)
)


"""
	miles_parameters()

Parameters from:
Richard Miles, Katalin Tóth, Attila I Gulyás, Norbert Hájos, and Tamas F Freund.  Differences between Somatic923and Dendritic Inhibition in the Hippocampus.Neuron, 16(4):815–823, April 1996. ISSN 0896-6273. doi: 10.1016/924S0896-6273(00)80101-4.
"""
MilesGabaDend = GABAergic(
 Receptor(E_rev = -75.,τr= 4.8, τd= 29., g0= 0.126),
 Receptor(E_rev = -90.,τr= 30, τd= 100., g0=0.006)
)

MilesGabaSoma = GABAergic(
 Receptor(E_rev = -75.,τr= 5.1, τd= 18., g0= 0.265),
 Receptor()
)



DuarteSynapsePV =
	let
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

		Synapse(AMPA, NMDA, GABAa, GABAb)
	end

DuarteSynapseSST= let
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
    Synapse(AMPA, NMDA, GABAa, GABAb)
end


export KochGlu, DuarteGluDend, DuarteSynapseSST, DuarteSynapsePV, GluSoma, MilesGabaSoma, MilesGabaDend, EyalGluDend
