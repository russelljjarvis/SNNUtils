# Update synaptic conductance after spike
#====================================#
function dospike(d::Union{Dendrite,Soma}, g::Float64)
    if g> 0
        exc_spike!(d,eff=g)
    else
        inh_spike!(d,eff=-g)
    end
	return nothing
end

@inline function exc_spike_plastic!(d::Union{Dendrite,Soma}; AMPA_eff::Real=2., NMDA_eff::Real=1. )
    d.h_AMPA += AMPA_eff*d.syn.AMPA.α
    d.h_NMDA += NMDA_eff*d.syn.NMDA.α
	return nothing
end

@inline function exc_spike!(d::Union{Dendrite,Soma}; eff::Real=1.)
    d.h_AMPA += eff*d.syn.AMPA.α
    d.h_NMDA += eff*d.syn.NMDA.α
	return nothing
end
@inline function inh_spike!(d::Union{Dendrite,Soma}; eff::Real=1.)
    d.h_GABAa += eff* d.syn.GABAa.α
    d.h_GABAb += eff* d.syn.GABAb.α
	return nothing
end

#====================================#
# Compute synaptic current
#====================================#
@inline function NMDA_nonlinear(NMDA::ReceptorVoltage, v::Float64)
		 return (1+(Mg_mM/NMDA.b)*exp(NMDA.k*(v)))^-1 ##NMDA
 end
# NMDA_nonlinear(v::Float64) = NMDA_nonlinear(s.syn.NMDA, v)

# nS * mV = pA
@inline function syn_current(d::Union{Dendrite,Soma}, syn::Synapse)::Float64
      return  (syn.AMPA.gsyn*d.g_AMPA+syn.NMDA.gsyn*d.g_NMDA*NMDA_nonlinear(syn.NMDA, d.v))*(d.v)	   + syn.GABAa.gsyn*(d.v- syn.GABAa.E_rev)* d.g_GABAa 	   + syn.GABAb.gsyn*(d.v-syn.GABAb.E_rev)* d.g_GABAb
  end

#====================================#
# Update synaptic decay
#====================================#
# Not used
@inline function synapse_euler(h::Float64, g::Float64, τr::Float64, τd::Float64)
			h  = h+ dt*( -h*τr )
			g  = g+ dt*( -g*τd +h)
		return h, g
	end

# Not used
@inline function synapse_heun(h::Float64, g::Float64, τr::Float64, τd::Float64)
			hγ = h+ dt*(-h * τr)
			h  = h+ dt*( -0.5h*τr + 0.5(-hγ*τr))
			gγ = g+ dt*(-g * τd + h)
			g  = g+ dt*( -0.5g*τd + 0.5(-gγ*τr) +2h)
		return h, g
	end

#Used
@inline function synapse_exp(h::Float64, g::Float64, τr::Float64, τd::Float64)
			return (1-dt* τr+ 0.5*(dt*τr)^2)*h, (1-dt*τd+ 0.5*(dt*τd)^2)*g + dt*h
	end

@inline function single_exp(h::Float64, τ::Float64)
			return h * (1-dt*τ+ 0.5*(dt*τ)^2)
	end

synapse_method=synapse_exp
@inline function update_synapses!(d::Union{Dendrite,Soma}, syn::Synapse)
		if d.syn.single_exp
			update_synapses_single!(d, syn)
		else
			update_synapses_double!(d, syn)
		end
	return nothing
end

@inline function update_synapses_double!(d::Union{Dendrite,Soma}, syn::Synapse)
	    # println("AMPA ", d.h_AMPA," g ", d.g_AMPA)
	    # println("NMDA ", d.h_NMDA," g ", d.g_NMDA)
        d.h_AMPA, d.g_AMPA   = synapse_exp(d.h_AMPA, d.g_AMPA, syn.AMPA.τr⁻, syn.AMPA.τd⁻)
        d.h_NMDA, d.g_NMDA   = synapse_exp(d.h_NMDA, d.g_NMDA, syn.NMDA.τr⁻, syn.NMDA.τd⁻)
        d.h_GABAa, d.g_GABAa = synapse_exp(d.h_GABAa, d.g_GABAa, syn.GABAa.τr⁻, d.syn.GABAa.τd⁻)
        d.h_GABAb, d.g_GABAb = synapse_exp(d.h_GABAb, d.g_GABAb, syn.GABAb.τr⁻, syn.GABAb.τd⁻)
		@assert(!isnan(d.g_AMPA))
		@assert(!isnan(d.g_NMDA))
		@assert(!isnan(d.g_GABAa))
		@assert(!isnan(d.g_GABAb))
		# @debug "Synapses" d.g_AMPA d.g_NMDA d.g_GABAa d.g_GABAb
	return nothing
	end

@inline function update_synapses_single!(d::Union{Dendrite,Soma}, syn::Synapse)
        d.h_AMPA   = single_exp(d.h_AMPA, syn.AMPA.τd⁻)
        d.h_NMDA   = single_exp(d.h_NMDA, syn.NMDA.τd⁻)
        d.h_GABAa =  single_exp( d.h_GABAa, syn.GABAa.τd⁻)
        d.h_GABAb =  single_exp( d.h_GABAb, syn.GABAb.τd⁻)
		d.g_AMPA  = d.h_AMPA
		d.g_NMDA  = d.h_NMDA
		d.g_GABAa  = d.h_GABAa
		d.g_GABAb  = d.h_GABAb
		# @debug "Synapses" d.g_AMPA d.g_NMDA d.g_GABAa d.g_GABAb
		@assert(!isnan(d.g_AMPA))
		@assert(!isnan(d.h_AMPA))
	return nothing
    end

#=====================================
		    Update rules
=====================================#
@inline function Δv_AdEx(v::Float64, w::Float64, s::Soma)
	return AdEx.C⁻ *( AdEx.gl *( -v +AdEx.Er +  AdEx.ΔT * exp(AdEx.ΔT⁻*(v-s.θ))) - w  - syn_current(s, s.syn)) ## external currents
end

@inline function Δw_AdEx(v::Float64, w::Float64,)
	return AdEx.τw⁻* ( AdEx.a *(v - AdEx.Er) - w)
end
@inline function Δv_AdEx_nospike(v::Float64, w::Float64, s::Soma)
	return AdEx.C⁻ *( AdEx.gl *( -v +AdEx.Er )
				- w  - syn_current(s, s.syn)) ## external currents
end

@inline ΔvDend(v::Float64, d::Dendrite)  = d.pm.τm⁻ *(-(v - d.pm.Er) - d.pm.Rm*syn_current(d, d.syn))


#====================================
  			Neuron update
====================================#
# use Heun method for numerical integration:
# y' = f(y)
# γ = yₜ + dt f(y)
# y ₜ₊₁ = yₜ + dt/2 *(f(γ) + f(yₜ)

function update_AdEx!(s::Soma, spiked::Bool=false)

	## After spike fix the membrane to 20 mV for 1ms and then to Er for 2ms
    if spiked
		s.v = AdEx.u_r
	end

	@assert(!isnan(s.w))

    if s.v >= s.θ +10
		## Increase the spike value to augment the
		## backpropagation effect
        s.v = AdEx.AP_membrane
        s.w += AdEx.b
        return true
    else
	    ## Update soma with AdEx model
	    γv = Δv_AdEx(s.v, s.w, s)
		γw = Δw_AdEx(s.v, s.w)
	    s.v += dt/2*( γv + Δv_AdEx(dt*γv+s.v, dt*γw + s.w,s))
	    s.w += dt/2*( γw + Δw_AdEx(dt*γv+s.v, dt*γw + s.w))

    return false
end
end



function update_dendrite!(d::Dendrite)
    ## Update dendrite compartment
    γd = ΔvDend(d.v,d)
	d.v += d.v > 0. ? 0. : dt*γd
	# d.v += 0.5*dt*(γd + ΔvDend(d.v + 0.5*dt*γd,d))
	return nothing
end


#================================================================#
#			Compute currents in the circuit
#================================================================#

## Function for multiple dendrites
# @inline function compute_current(origin_node::Float64,target_node::Float64,conductance::Array{Float64,2}, no::Int64, nt::Int64)
# 	if origin_node > target_node
# 		return  - (origin_node - target_node) *conductance[no,nt]
# 	else
# 		return  - (origin_node - target_node) *conductance[nt,no]
# 	end
# 	return nothing
# end

# function compute_currents(tr::Tripod, currents::Array{Float64,1})
# 	currents[:] .= 0
# 	for (o,t) in eachcol(tr.c.links)
# 		if t < length(currents)
# 			currents[o] += compute_current(tr.d[o].v,tr.d[t].v,tr.c.conductance,o,t)
# 			currents[t] -= compute_current(tr.d[o].v,tr.d[t].v,tr.c.conductance,o,t)
# 		else
# 			currents[o] += compute_current(tr.d[o].v,tr.s.v,tr.c.conductance,o,t)
# 			currents[t] -= compute_current(tr.d[o].v,tr.s.v,tr.c.conductance,o,t)
# 		end
# 	end
# 	return nothing
# end

function compute_currents(t::Tripod, currents::Array{Float64,1})
	currents[:] .= 0
	currents[1] = (t.d[1].v > t.s.v ? t.c.conductance[1,3] : t.c.conductance[3,1]) * (t.s.v - t.d[1].v)
	currents[2] = (t.d[2].v > t.s.v ? t.c.conductance[2,3] : t.c.conductance[3,2]) * (t.s.v - t.d[2].v)
	currents[3] = - sum(currents)
	return nothing
end


function update_tripod!(t::Tripod, currents::Array{Float64,1}, spiked::Bool)

	## Update synapses
	for n in 1:length(t.d)
	    update_synapses_double!(t.d[n], t.d[n].syn)
	end
    update_synapses_double!(t.s, t.s.syn)

	## Threshold adaptation decay
	t.s.θ -= dt*postspike.τA⁻*(t.s.θ-AdEx.θ)

	## if neuron spike set membrane potential and non-linear decay
	# if no spike, update membrane potential
    t.s.as_dt -= 1
	if t.s.as_dt < 0
		compute_currents(t, currents)
		## Update soma with dendritic currents
	    t.s.v  += dt*AdEx.C⁻*currents[end]
		for n in 1:length(t.d)
			t.d[n].v += dt*t.d[n].pm.C⁻*currents[n]
		    update_dendrite!(t.d[n])
		end
		if update_AdEx!(t.s)
	        t.s.as_dt = AdEx.up_dt + AdEx.idle_dt
			t.s.θ += postspike.A
			return true
		else
			return false
		end


	elseif t.s.as_dt > AdEx.idle_dt
        t.s.v = AdEx.BAP
		compute_currents(t, currents)
		## Update soma with dendritic currents
	    t.s.v  += dt*AdEx.C⁻*currents[end]
		for n in 1:length(t.d)
			t.d[n].v += dt*t.d[n].pm.C⁻*currents[n]
		    update_dendrite!(t.d[n])
		end
		# if action potential interval (1ms)
		return false
	else
		# if depolarization interval (2ms)
        t.s.v = AdEx.u_r
		return false
	end
end


#======================================
		Free membrane evolution
======================================#

function update_AdEx_soma_nospike!(s::Soma)
    ## Update soma with AdEx model
    γv = Δv_AdEx_nospike(s.v, s.w, s)
	γw = Δw_AdEx(s.v, s.w)
    s.v += dt/2*( γv + Δv_AdEx_nospike(dt*γv+s.v,dt*γw + s.w,s))
    s.w += dt/2*( γw + Δw_AdEx( dt*γv+s.v, dt*γw + s.w))
    update_synapses_double!(s, s.syn)
end

function update_nospike!(t::Tripod, currents::Array{Float64,1})
    """
    update the tripod circuit:
        1. get tripod-circuit current
        2. update AdEx soma
        3. update passive membrane compartments
    """
	compute_currents(t, currents)
	for (n,d) in enumerate(t.d)
	    update_dendrite!(d)# AdEx.syn_dend)
    	d.v += dt*d.pm.C⁻*currents[n]
	end
    t.s.v  += dt*AdEx.C⁻*currents[end]
 	update_AdEx_soma_nospike!(t.s)
end

####

#
