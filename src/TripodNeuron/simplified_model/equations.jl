
@inline function NMDA_nonlinear(NMDA::ReceptorVoltage, v::Float64)
		 return (1+(Mg_mM/NMDA.b)*exp(NMDA.k*(v)))^-1 ##NMDA
 end

@inline function syn_current(v::Float64, g::SubArray{Float64,1}, syn::Synapse)
	return (syn.AMPA.gsyn * g[1]+
			syn.NMDA.gsyn * g[2]*NMDA_nonlinear(syn.NMDA, v))*(v)+
			syn.GABAa.gsyn *(v- syn.GABAa.E_rev)* g[3]	+
			syn.GABAb.gsyn *(v- syn.GABAb.E_rev)* g[4]
end
##

@inline function ΔvDend4(v::Float64, axial::Float64,g::SubArray{Float64,1},  pm::PassiveMembraneParameters)::Float64
	k1 = _ΔvDend(v, axial, g, pm)
	k2 = _ΔvDend(v + k1 * dt/2,axial, g, pm)
	k3 = _ΔvDend(v + k2 * dt/2,axial, g, pm)
	k4 = _ΔvDend(v + k3 * dt  ,axial, g, pm )
    return (1/6) * (k1 + 2*k2 + 2*k3 + k4)
end

@inline function ΔvDend2(v::Float64,axial::Float64, g::SubArray{Float64,1},  pm::PassiveMembraneParameters)::Float64
	k1 = _ΔvDend(v, axial, g, pm)
	k2 = _ΔvDend(v + k1 * dt  ,axial, g, pm )
    return (1/2) * (k1 + k2)
end

@inline function _ΔvDend(v::Float64,axial::Float64, g::SubArray{Float64,1}, pm::PassiveMembraneParameters)
	 i = syn_current(v, g,Esyn_dend)
	 return  pm.C⁻ *(-(v - pm.Er)/pm.Rm - min(abs(i), 2000)*sign(i)  -axial)
end


 ## Heun integration
# y' = f(y)
# γ = yₜ + dt f(y)
# y ₜ₊₁ = yₜ + dt/2 *(f(γ) + f(yₜ)
@inline function Δv(v::Float64, w::Float64, axial::Float64, θ::Float64, g::SubArray{Float64,1})
    γv = ΔvAdEx(v, w, axial, θ, g)
	γw = ΔwAdEx(v, w)
    return 0.5*( γv + ΔvAdEx(dt* γv+v, dt*γw + w, axial, θ, g))
end

@inline function ΔvNospike(v::Float64, axial::Float64, g::SubArray{Float64,1})
    γv = ΔvAdExNospike(v,axial,  g)
    return 0.5*( γv + ΔvAdExNospike(dt* γv+v, axial, g))
end

@inline function Δw(v::Float64, w::Float64, θ::Float64, g::SubArray{Float64,1})
	γw = ΔwAdEx(v, w)
	return  0.5*( γw + ΔwAdEx(v, dt*γw + w))
end

## Model equations
# AdEx model

ΔvAdEx(v::Float64, w::Float64, axial::Float64, θ::Float64, g::SubArray{Float64,1}) =  AdEx.C⁻ *( AdEx.gl *( -v +AdEx.Er +  AdEx.ΔT * exp(AdEx.ΔT⁻*(v-θ))) - w  -axial - syn_current(v, g, Esyn_soma)) ## external currents

ΔvAdExNospike(v::Float64, axial::Float64, g::SubArray{Float64,1}) =  AdEx.C⁻ *( AdEx.gl *( -v +AdEx.Er) - axial  - syn_current(v, g, Esyn_soma)) ## external currents

ΔwAdEx(v::Float64, w::Float64) =  AdEx.τw⁻* ( AdEx.a *(v - AdEx.Er) - w)
##


@inline function synapse_exp_h(h::Float64, τr::Float64)
			return (1-dt* τr+ 0.5*(dt*τr)^2)*h
end

@inline function synapse_exp_g(h::Float64, g::Float64, τd::Float64)
			return (1-dt*τd+ 0.5*(dt*τd)^2)*g + dt*h
end


@inline function update_synapse_soma!(syn_arr::SubArray{Float64,2}, inh_::Float64, exc_::Float64, syn::Synapse)
        syn_arr[1,1] += exc_*syn.AMPA.α
        syn_arr[3,1] += inh_*syn.GABAa.α
        syn_arr[1,2]= synapse_exp_g(syn_arr[1,1], syn_arr[1,2], syn.AMPA.τd⁻, )
        syn_arr[3,2]= synapse_exp_g(syn_arr[3,1], syn_arr[3,2], syn.GABAa.τd⁻,)
        syn_arr[1,1]= synapse_exp_h(syn_arr[1,1], syn.AMPA.τr⁻, )
        syn_arr[3,1]= synapse_exp_h(syn_arr[3,1], syn.GABAa.τr⁻,)
	return nothing
	end

@inline function update_synapse_dend!(syn_arr::SubArray{Float64,2}, inh_::Float64, exc_::Float64, syn::Synapse)
        syn_arr[1,1] += exc_*syn.AMPA.α
        syn_arr[2,1] += exc_*syn.NMDA.α
        syn_arr[3,1] += inh_*syn.GABAa.α
        syn_arr[4,1] += inh_*syn.GABAb.α
		# update g
        syn_arr[1,2]= synapse_exp_g(syn_arr[1,1], syn_arr[1,2], syn.AMPA.τd⁻, )
        syn_arr[2,2]= synapse_exp_g(syn_arr[2,1], syn_arr[2,2], syn.NMDA.τd⁻, )
        syn_arr[3,2]= synapse_exp_g(syn_arr[3,1], syn_arr[3,2], syn.GABAa.τd⁻,)
        syn_arr[4,2]= synapse_exp_g(syn_arr[4,1], syn_arr[4,2], syn.GABAb.τd⁻,)
		# # update h
        syn_arr[1,1]= synapse_exp_h(syn_arr[1,1], syn.AMPA.τr⁻, )
        syn_arr[2,1]= synapse_exp_h(syn_arr[2,1], syn.NMDA.τr⁻, )
        syn_arr[3,1]= synapse_exp_h(syn_arr[3,1], syn.GABAa.τr⁻,)
        syn_arr[4,1]= synapse_exp_h(syn_arr[4,1], syn.GABAb.τr⁻,)
	return nothing
	end

@inline function single_exp(h::Float64, τ::Float64)
			return h * (1-dt*τ+ 0.5*(dt*τ)^2)
		# return h * (1-dt*τ)
end

@inline function update_synapse_single!(syn_arr::SubArray{Float64,2}, inh_::Float64, exc_::Float64, syn::Synapse)
        syn_arr[1,1] += exc_*syn.AMPA.α
        # syn_arr[2,1] += exc_*syn.NMDA.α
        syn_arr[3,1] += inh_*syn.GABAa.α
        # syn_arr[4,1] += inh_*syn.GABAb.α
        syn_arr[1,1] = single_exp(syn_arr[1,1], syn.AMPA.τd⁻)
        # syn_arr[2,1] = single_exp(syn_arr[2,1], syn.NMDA.τd⁻)
        syn_arr[3,1] = single_exp(syn_arr[3,1], syn.GABAa.τd⁻)
        # syn_arr[4,1] = single_exp(syn_arr[4,1], syn.GABAb.τd⁻)
		syn_arr[:,2] = syn_arr[:,1]
	return nothing
    end

@inline function Δv_AdEx_somaonly(v::Float64, w::Float64,θ::Float64,
						g_soma::SubArray{Float64,1},g_dend::SubArray{Float64,1})
	return AdEx.C⁻ *( AdEx.gl *( -v +AdEx.Er +  AdEx.ΔT * exp(AdEx.ΔT⁻*(v-θ)))
				- w  - syn_current(v, g, Esyn_soma)- syn_current(v, g_dend, Esyn_dend)) ## external currents
end
