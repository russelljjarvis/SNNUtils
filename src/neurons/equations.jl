@inline function exp32(x::Float32)::Float32
    x = ifelse(x < -10f0, -32f0, x)
    x = 1f0 + x / 32f0
    x *= x; x *= x; x *= x; x *= x; x *= x
    return x
end

@inline function exp256(x::Float32)::Float32
    x = ifelse(x < -10f0, -256f0, x)
    x = 1.0f0 + x / 256.0f0
    x *= x; x *= x; x *= x; x *= x
    x *= x; x *= x; x *= x; x *= x
    return x
end


@inline function NMDA_nonlinear(NMDA::ReceptorVoltage, v::Float32)::Float32
		Mg_mM = 1.
		 return (1+(Mg_mM/NMDA.b)*exp32(NMDA.k*(v)))^-1 ##NMDA
 end

@inline function syn_current(v::Float32, g::AbstractVector{Float32}, syn::Synapse)::Float32
	return (syn.AMPA.gsyn * g[1]+ syn.NMDA.gsyn * g[2]*NMDA_nonlinear(syn.NMDA, v))*(v) +			syn.GABAa.gsyn *(v- syn.GABAa.E_rev)* g[3]+ 	syn.GABAb.gsyn *(v- syn.GABAb.E_rev)* g[4]
end

@inline function syn_exc_curr(v::Float32, g::AbstractVector{Float32}, syn::Synapse, C⁻::Float32)::Float32
	return  -C⁻ * ((syn.AMPA.gsyn * g[1]+
			syn.NMDA.gsyn * g[2]*NMDA_nonlinear(syn.NMDA, v))*(v))
end

@inline function syn_inh_curr(v::Float32, g::AbstractVector{Float32}, syn::Synapse, C⁻::Float32)::Float32
			- C⁻*(syn.GABAa.gsyn *(v- syn.GABAa.E_rev)* g[3]+ 	syn.GABAb.gsyn *(v- syn.GABAb.E_rev)* g[4])
		end


##  Integration methods
#Heun integration
# y' = f(y)
# γ = yₜ + dt f(y)
# y ₜ₊₁ = yₜ + dt/2 *(f(γ) + f(yₜ)
@inline function Δv2(v::Float32, w::Float32, θ::Float32, g::AbstractVector{Float32}, Neuron::NeuronParams)::Float32
    γv = Δv_soma(v, w, θ, g, Neuron::NeuronParams)
	γw = Δw_soma(v, w, Neuron::NeuronParams)
    return 0.5f0*( γv + Δv_soma(dt* γv+v, dt*γw + w, θ, g, Neuron::NeuronParams))
end

@inline function Δw2(v::Float32, w::Float32, θ::Float32, g::AbstractVector{Float32}, Neuron::NeuronParams)::Float32
    γv = Δv_soma(v, w, θ, g, Neuron::NeuronParams)
	γw = Δw_soma(v, w, Neuron::NeuronParams)
	return  0.5f0*( γw + Δw_soma(dt*γv +v, dt*γw + w, Neuron::NeuronParams))
end

# Runge Kutta4 integration
@inline function ΔvDend4(v::Float32,axial::Float32, g::AbstractVector{Float32},  pm::PassiveMembraneParameters)::Float32
	k1 = _ΔvDend(v, axial, g, pm)
	k2 = _ΔvDend(v + k1 * dt/2,axial, g, pm)
	k3 = _ΔvDend(v + k2 * dt/2,axial, g, pm)
	k4 = _ΔvDend(v + k3 * dt  ,axial, g, pm )
    return (1/6) * (k1 + 2*k2 + 2*k3 + k4)
end

# Runge Kutta -2 integration
@inline function ΔvDend2(v::Float32,axial::Float32, g::AbstractVector{Float32},  pm::PassiveMembraneParameters, syn::Synapse)::Float32
	k1 = _ΔvDend(v, axial, g, pm, syn)
	k2 = _ΔvDend(v + k1 * dt  ,axial, g, pm ,syn)
    return (1/2) * (k1 + k2)
end

## Model single step equations
@inline function _ΔvDend(v::Float32, axial::Float32,g::AbstractVector{Float32}, pm::PassiveMembraneParameters, syn::Synapse)::Float32
	 i = syn_current(v, g,syn)
	 return  pm.C⁻ *(-(v - pm.Er)/pm.Rm - min(abs(i), 1500)*sign(i)  -axial)
end

# @inline function _ΔvDend(v::Float32,pm::PassiveMembraneParameters)::Float32
# 	 return  pm.C⁻ *(-(v - pm.Er)/pm.Rm)
# end

@inline function Δv_soma(v::Float32, w::Float32,axial::Float32, θ::Float32, g::AbstractVector{Float32}, Neuron::NeuronParams, syn::Synapse)::Float32
	@unpack gl, C⁻, Er, ΔT, ΔT⁻= Neuron
	return C⁻ *( gl *( -v +Er +  ΔT * exp32(ΔT⁻*(v-θ))) - w  - syn_current(v, g, syn) - axial) ## external currents
end

@inline function Δw_soma(v::Float32, w::Float32, Neuron::NeuronParams)::Float32
	@unpack Er, a, τw⁻= Neuron
	return  τw⁻* ( a *(v - Er) - w)
end
##

@inline function double_exp_h(h::Float32, τr::Float32)::Float32
			return (-dt* τr)*h
			# return (1f0-dt* τr+ 0.5f0*(dt*τr)^2)*h
end
@inline function double_exp_g(h::Float32, g::Float32, τd::Float32)
			return (-dt*τd)*g + dt*h
			# return (1f0-dt*τd+ 0.5f0*(dt*τd)^2)*g + dt*h
end

function double_exp(syn_arr::AbstractVector{Float32},syn,dt)
	syn_arr[2] = exp32(-dt*syn.τd⁻)*(syn_arr[2] + dt*syn_arr[1])#),13500)
	syn_arr[1] = exp32(-dt*syn.τr⁻)*(syn_arr[1])
end


@inline function single_exp(h::Float32, τ::Float32)
			# return h * (1f0-dt*τ+ 0.5f0*(dt*τ)^2)
			return -dt*τ * h
end

MyT = Vector{Float32}
MyPM = Vector{PassiveMembraneParameters}
function compute_currents(vs::MyT,vd1::MyT,vd2::MyT,pm1::MyPM,pm2::MyPM,Cs⁻::Float32,cc::Int)
	## first order delta
	d1 = dt*pm1[cc].C⁻*(- vd1[cc] + vs[cc])* pm1[cc].g_ax
	d2 = dt*pm2[cc].C⁻*(- vd2[cc] + vs[cc])* pm2[cc].g_ax
	ds = dt*Cs⁻*(pm1[cc].g_ax*vd1[cc]+pm2[cc].g_ax*vd2[cc] - (pm1[cc].g_ax + pm2[cc].g_ax) *vs[cc])
	# second order delta and apply
	vd1[cc] += 0.5f0*(d1 + dt*pm1[cc].C⁻*(-d1 - vd1[cc] + vs[cc]+ds)* pm1[cc].g_ax )
	vd2[cc] += 0.5f0*(d2 + dt*pm2[cc].C⁻*(-d1 - vd2[cc] + vs[cc]+ds)* pm2[cc].g_ax )
	vs[cc]  +=  0.5f0*(ds + dt*Cs⁻*(pm1[cc].g_ax*(vd1[cc]+d1) +pm2[cc].g_ax*(vd2[cc]+d2) - (pm1[cc].g_ax + pm2[cc].g_ax) *(vs[cc]+ds)))
end



function update_synapse_soma!(syn_arr::AbstractMatrix{Float32}, inh_::Float32, exc_::Float32, syn::Synapse, dt)
        syn_arr[1,1] += exc_*syn.AMPA.α
        syn_arr[3,1] += inh_*syn.GABAa.α
        @views double_exp(syn_arr[1,:], syn.AMPA, dt)
        # @views double_exp_g(syn_arr[2,:], syn.NMDA)
        @views double_exp(syn_arr[3,:], syn.GABAa, dt)
        # @views double_exp_g(syn_arr[4,:], syn.GABAb)
	return nothing
	end

function update_synapse_dend!(syn_arr::AbstractMatrix{Float32}, inh_::Float32, exc_::Float32, syn::Synapse)
        syn_arr[1,1] += exc_ * syn.AMPA.α
        syn_arr[2,1] += exc_ * syn.NMDA.α
        syn_arr[3,1] += inh_*syn.GABAa.α
        syn_arr[4,1] += inh_*syn.GABAb.α
        @views double_exp(syn_arr[1,:], syn.AMPA)
        @views double_exp(syn_arr[2,:], syn.NMDA)
        @views double_exp(syn_arr[3,:], syn.GABAa)
        @views double_exp(syn_arr[4,:], syn.GABAb)
	return nothing
	end


function update_synapse_single!(syn_arr::AbstractMatrix{Float32}, inh_::Float32, exc_::Float32, syn::Synapse)
        syn_arr[1,1] += exc_*syn.AMPA.α
        syn_arr[2,1] +=  syn.NMDA.α
        syn_arr[3,1] += inh_*syn.GABAa.α
        syn_arr[4,1] +=  syn.GABAb.α

		## fast synapses have not rise time
        syn_arr[1,1]  += single_exp(syn_arr[1,1], syn.AMPA.τd⁻)
		syn_arr[1,2] = syn_arr[1,1]
        syn_arr[2,1]  += single_exp(syn_arr[2,1], syn.AMPA.τd⁻)
		syn_arr[2,2] = syn_arr[2,1]
		syn_arr[3,1]  += single_exp(syn_arr[3,1], syn.GABAa.τd⁻)
		syn_arr[3,2] = syn_arr[3,1]
		syn_arr[4,1]  += single_exp(syn_arr[4,1], syn.GABAb.τd⁻)
		syn_arr[4,2] = syn_arr[4,1]
        @views double_exp(syn_arr[2,:], syn.NMDA)
        @views double_exp(syn_arr[4,:], syn.GABAb)
	return nothing
    end

## Lifs
@inline function Δv_lif(v::Float32, w::Float32, g::AbstractVector{Float32}, LIF::NeuronParams, syn::Synapse)
	 	i = syn_current(v, g, syn)
    return  LIF.C⁻ *( LIF.gl *( -v +LIF.Er ) - w - min(abs(i), 2000)*sign(i) ) ## external currents
end
@inline function Δw_lif(v::Float32, w::Float32,LIF::NeuronParams)
    return  LIF.τw⁻*( LIF.a *(v - LIF.Er) - w)
end
