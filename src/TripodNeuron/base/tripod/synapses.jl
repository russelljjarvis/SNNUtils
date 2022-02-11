
abstract type AbstractReceptor end

mutable struct Receptor <:AbstractReceptor

	E_rev::Float64
	τr⁻::Float64
	τd⁻::Float64
	gsyn::Float64
	α::Float64
	function Receptor(E_rev, τr, τd, gsyn)
		new(E_rev, 1/τr, 1/τd, gsyn*norm_synapse(τr,τd), α_synapse(τr, τd))
	end
	function Receptor(E_rev, τd, gsyn)
		new(E_rev, -1, 1/τd, gsyn,1)
	end
end

mutable struct ReceptorVoltage <: AbstractReceptor
	E_rev::Float64
	τr⁻::Float64
	τd⁻::Float64
	gsyn::Float64
	α::Float64
	b::Float64
	k::Float64
	v::Float64
	function ReceptorVoltage(E_rev, τr, τd, gsyn, b, k, v)
		new(E_rev, 1/τr, 1/τd, gsyn*norm_synapse(τr,τd), α_synapse(τr, τd), b, k, v)
	end
	function ReceptorVoltage(E_rev, τd, gsyn, b, k, v)
		new(E_rev, -1, 1/τd, gsyn, 1, b, k, v)
	end
end

mutable struct Synapse
	AMPA::Receptor
	NMDA::ReceptorVoltage
	GABAa::Receptor
	GABAb::Receptor
	single_exp::Bool
end

#=========================================
			Synaptic fit
=========================================#

function norm_synapse(synapse::Union{Receptor, ReceptorVoltage})
	norm_synapse(1/synapse.τr⁻, 1/synapse.τd⁻)
end

function norm_synapse(τr,τd)
	p = [1, τr, τd]
    t_p  = p[2]*p[3]/(p[3] -p[2]) * log(p[3] / p[2])
	return 1/(-exp(-t_p/p[2]) + exp(-t_p/p[3]))
end

# α is the factor that has to be placed in-front of the differential equation such that the analytical integration corresponds to the double exponential function. Further details are discussed in the Julia notebook about synapses
function α_synapse(τr, τd)
	return (τd-τr)/(τd*τr)
end

function get_gsyn(synapse::Union{Receptor, ReceptorVoltage})
	synapse.gsyn/norm_synapse(synapse)
end
function set_gsyn(synapse::Union{Receptor, ReceptorVoltage}, value)
	synapse.gsyn = value * norm_synapse(synapse)
end

#==========================================
			Synaptic Parameters
==========================================#

function exc_inh_synapses(exc::Function, inh::Function, compartment::String)
	AMPA, NMDA = exc(compartment)
	GABAa, GABAb = inh(compartment)
    return Synapse(AMPA, NMDA, GABAa, GABAb, false)
end
