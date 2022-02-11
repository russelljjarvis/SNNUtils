#=================================
		 	Equations
=================================#

@inline function Δv_lif(v::Float64, w::Float64, s::Soma, LIF::NeuronParams, syn::Synapse)
    return  LIF.C⁻ *( LIF.gl *( -v +LIF.Er ) - w - syn_current(s, syn)) ## external currents
end
@inline function Δw_lif(v::Float64, w::Float64,LIF::NeuronParams)
    return  LIF.τw⁻*( LIF.a *(v - LIF.Er) - w)
end
@inline ΔvSST(v,w,s)=Δv_lif(v,w,s,LIF_sst, Isyn_sst)
@inline	ΔwSST(v,w)=Δw_lif(v,w, LIF_sst)
@inline ΔvPV(v,w,s)=Δv_lif(v,w,s,LIF_pv, Isyn_pv)
@inline	ΔwPV(v,w)=Δw_lif(v,w,  LIF_pv)


function update_lif_sst!(s::Soma, spiked::Bool=false)
    ## Update soma with LIF model
    if spiked
		s.v = LIF_sst.u_r
	end

    γv = s.v + dt*ΔvSST(s.v, s.w,s)
    s.v +=  dt/2*(ΔvSST(s.v, s.w,s)+ΔvSST(γv,s.w,s))
    γw = s.w + dt*ΔwSST(s.v, s.w)
    s.w +=  dt/2*(ΔwSST(s.v, s.w)+ΔwSST(s.v,γw))

    update_synapses_double!(s, Isyn_sst)

    ## spike behavior
    if s.v > LIF_sst.θ || isnan(s.v)
        s.v = LIF_sst.u_r
        s.w += LIF_sst.b
        return true
    else
    return false
end
end

function update_lif_pv!(s::Soma, spiked::Bool=false)
	## Get differential equation for inhibitory type
	# @assert(!isnan(s.v))
    # use Heun method for numerical integration:
    # y' = f(y)
    # γ = yₜ + dt f(y)
    # y ₜ₊₁ = yₜ + dt/2 *(f(γ) + f(yₜ)
    if spiked
		s.v = LIF_pv.u_r
	end

    ## Update soma with LIF model
    γv = s.v + dt*ΔvPV(s.v, s.w, s)
    s.v += dt/2*( ΔvPV(s.v, s.w, s )+ΔvPV(γv,s.w, s))
    γw = s.w + dt*ΔwPV(s.v, s.w)
    s.w += dt/2*( ΔwPV(s.v, s.w)+ΔwPV(s.v,γw))

    update_synapses_single!(s, Isyn_pv)

    ## spike behavior
    if s.v > LIF_pv.θ || isnan(s.v)
		s.w += LIF_pv.b
        return true
    else
    return false
end
end

function update_lif!(s::Soma, spiked::Bool=false)
	if s.model =="PV"
		return update_lif_pv!(s)
	elseif s.model =="SST"
		return update_lif_sst!(s)
	else
		@assert(1==0)
	end
end
