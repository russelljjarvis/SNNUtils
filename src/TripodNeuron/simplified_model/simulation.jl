include("equations.jl")

function run_tripod(model::Tuple{Int, Int}, inputs::Union{Matrix{Bool}, Matrix{Int}, Vector{Float64}}, simtime::Int;synapses=[5.,1.,1,5.,1.,1.], ext_currents=zeros(3),
	adapt=false,
	soma_only=false,
	do_spikes=true,
	current_up=false,
	idle_t= AdEx.up_dt + AdEx.idle_dt)

	pm1   = PassiveMembraneParameters("d1", "H", 4, model[1])
	pm2   = PassiveMembraneParameters("d2", "H", 4, model[2])
	## Define variables
	v_soma    = AdEx.Er
	w_soma =    0.

	c_soma  = zeros(Float64,2) # soma currents
	v_dend1 =    AdEx.Er
	v_dend2 =    AdEx.Er

	# Spike events
	idle_soma = 1 # time idle for soma
	soma_th = AdEx.θ  # threshold for spike

	## structured like:
	# (h,g) x (AMPA, NMDA, GABAa, GABAb)
	syn_soma =  zeros(Float64,4,2)
	syn_dend1 = zeros(Float64,4,2)
	syn_dend2 = zeros(Float64,4,2)

	## Inputs
	exc_soma =  0.
	exc_dend1 = 0.
	exc_dend2 = 0.
	inh_soma =  0.
	inh_dend1 = 0.
	inh_dend2 = 0.


	##

	#Set simulation
	total_steps = round(Int,(simtime)/dt)
	v = zeros(4,total_steps) # voltage trace
	# e = zeros(total_steps,3) # voltage trace
	##


	# for tt in iterations
	for tt in 1:total_steps
		# Get noise inpute



	    v_soma  += dt*AdEx.C⁻*ext_currents[1]
		v_dend1 += dt*pm1.C⁻* ext_currents[2]
		v_dend2 += dt*pm2.C⁻* ext_currents[3]

		if isa(inputs, Vector{Float64})
			exc_soma  = synapses[1] *rand(Poisson(inputs[1]*dt))
			exc_dend1 = synapses[2] *rand(Poisson(inputs[2]*dt))
			exc_dend2 = synapses[3] *rand(Poisson(inputs[3]*dt))
			inh_soma  = synapses[4] *rand(Poisson(inputs[4]*dt))
			inh_dend1 = synapses[5] *rand(Poisson(inputs[5]*dt))
			inh_dend2 = synapses[6] *rand(Poisson(inputs[6]*dt))
		end


		if isa(inputs, Matrix{Bool})
			exc_soma  =synapses[1] * inputs[1,tt]
			exc_dend1 =synapses[2] * inputs[2,tt]
			exc_dend2 =synapses[3] * inputs[3,tt]
			inh_soma  =synapses[4] * inputs[4,tt]
			inh_dend1 =synapses[5] * inputs[5,tt]
			inh_dend2 =synapses[6] * inputs[6,tt]
		end
		# Get prepared input

		if isa(inputs, Matrix{Int})
			exc_soma  =synapses[1] * inputs[1,tt]
			exc_dend1 =synapses[2] * inputs[2,tt]
			exc_dend2 =synapses[3] * inputs[3,tt]
			inh_soma  =synapses[4] * inputs[4,tt]
			inh_dend1 =synapses[5] * inputs[5,tt]
			inh_dend2 =synapses[6] * inputs[6,tt]
		end
		# e[tt,:] = [exc_soma, exc_dend1, exc_dend2]
		#
		@views update_synapse_soma!(syn_soma[:,:],   inh_soma, exc_soma, Esyn_soma)
		@views update_synapse_dend!( syn_dend1[:,:], inh_dend1, exc_dend1, Esyn_dend)
		@views update_synapse_dend!( syn_dend2[:,:], inh_dend2, exc_dend2, Esyn_dend)


		## Threshold adaptation decay
		soma_th -= dt*postspike.τA⁻*(soma_th-AdEx.θ)

		@assert(!isnan(v_soma))

        idle_soma -= 1

		if idle_soma < 0
		    if v_soma >= soma_th+5. && do_spikes
				spiked_exc = true
				## Increase spike thresshold and set the idle period
				idle_soma = idle_t
		        v_soma  = AdEx.AP_membrane
				soma_th += postspike.A
		        w_soma  += AdEx.b
			else
				## compute currents
				if !soma_only
					c_soma[1] = - (v_dend1 - v_soma)* pm1.g_ax
					c_soma[2] = - (v_dend2 - v_soma)* pm2.g_ax
				end
				## update dendritic compartments

				if current_up
					v_dend1 += dt*pm1.C⁻* c_soma[1]
					v_dend2 += dt*pm2.C⁻* c_soma[2]
				    v_soma  -= dt*AdEx.C⁻*(c_soma[1]+c_soma[2])
					fill!(c_soma,0.f0)
				end

				v_dend1 += dt*ΔvDend2(v_dend1, -c_soma[1],(@view syn_dend1[:,2]), pm1)
				v_dend2 += dt*ΔvDend2(v_dend2, -c_soma[2],(@view syn_dend2[:,2]), pm2)

				if do_spikes
					v_soma += dt*Δv(v_soma, w_soma, sum(c_soma), soma_th, (@view syn_soma[:,2]))
					w_soma += dt*Δw(v_soma, w_soma, soma_th, (@view syn_soma[:,2]))
				else
					v_soma += dt*ΔvNospike(v_soma, sum(c_soma), (@view syn_soma[:,2]))
				end
			end
		elseif idle_soma > AdEx.idle_dt
	        v_soma = AdEx.BAP

			if !soma_only
				c_soma[1] = - (v_dend1 - v_soma)* pm1.g_ax*BAP_gax
				c_soma[2] = - (v_dend2 - v_soma)* pm2.g_ax*BAP_gax
			end

			if current_up
				v_dend1 += dt*pm1.C⁻* c_soma[1]
				v_dend2 += dt*pm2.C⁻* c_soma[2]
			    v_soma  -= dt*AdEx.C⁻*(c_soma[1]+c_soma[2])
				fill!(c_soma,0.f0)
			end

			v_dend1 += dt*ΔvDend2(v_dend1, -c_soma[1],(@view syn_dend1[:,2]), pm1)
			v_dend2 += dt*ΔvDend2(v_dend2, -c_soma[2],(@view syn_dend2[:,2]), pm2)
		else
	        v_soma = AdEx.Er
		end
		v[1,tt] = v_soma
		v[2,tt] = v_dend1
		v[3,tt] = v_dend2
		v[4,tt] = w_soma
	end
	if adapt
		return v[1:3,:], v[4,:]
	else
		return v[1:3,:]
	end
end
