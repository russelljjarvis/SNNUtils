abstract type AbstractReceptor end


@with_kw struct Receptor <:AbstractReceptor
	E_rev::Float32
	τr::Float32=-1.f0
	τd::Float32=-1.f0
	g0::Float32= 0.f0
	gsyn::Float32 =  g0*norm_synapse(τr,τd)
	α::Float32 =  α_synapse(τr, τd)
	τr⁻::Float32=1/τr
	τd⁻::Float32=1/τd
end

Mg_mM     = 1f0
nmda_b   = 3.36       #(no unit) parameters for voltage dependence of nmda channels
nmda_k   = -0.062     #(1/V) source: http://dx.doi.org/10.1016/j.neucom.2011.04.018)

@with_kw struct ReceptorVoltage <: AbstractReceptor
	E_rev::Float32 = 0.f0
	τr::Float32=-1.f0
	τd::Float32=-1.f0
	g0::Float32= 0.f0
	gsyn::Float32 = g0*norm_synapse(τr, τd)
	α::Float32 = α_synapse(τr,τd)
	b::Float32 = nmda_b
	k::Float32 = nmda_k
	mg::Float32 = Mg_mM
	τr⁻::Float32=1/τr
	τd⁻::Float32=1/τd
end

struct Synapse
	AMPA::Receptor
	NMDA::ReceptorVoltage
	GABAa::Receptor
	GABAb::Receptor
end

export Receptor, Synapse, ReceptorVoltage

#=========================================
			Synaptic fit
=========================================#

function norm_synapse(synapse::Union{Receptor, ReceptorVoltage})
	norm_synapse(synapse.τr, synapse.τd)
end


function norm_synapse(τr,τd)
	p = [1, τr, τd]
    t_p  = p[2]*p[3]/(p[3] -p[2]) * log(p[3] / p[2])
	return 1/(-exp(-t_p/p[2]) + exp(-t_p/p[3]))
end

# α is the factor that has to be placed in-front of the differential equation as such the analytical integration corresponds to the double exponential function. Further details are discussed in the Julia notebook about synapses
function α_synapse(τr, τd)
	return (τd-τr)/(τd*τr)
end


export norm_synapse
