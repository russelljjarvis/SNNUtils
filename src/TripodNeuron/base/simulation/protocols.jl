"""
Inject current in the compartment

current (pA)
compartment (Soma, Dendrite)
"""
function inject_current!(compartment::Union{Dendrite,Soma},current::Real )
	if isa(compartment, Soma)
		compartment.v += current*AdEx.C⁻*dt
	elseif isa(compartment, Dendrite)
		compartment.v += current*compartment.pm.C⁻*dt
	end
end

"""
Set the external input rate for a neural compartment.

efficacy multiplies the synaptic conductance.
compartment is the target compartment.
rate is the incoming rate in KHz.
dt is the time resolution of the simulation in ms.
"""

set_rate!(compartment, rate; eff=1.) = set_rate!(eff, compartment, rate)

function set_rate!(AMPA_eff::Real, NMDA_eff::Real, compartment::Union{Dendrite,Soma}, rate::Float64, dt::Real=dt)
    ### rate in Hz, transform to milliHertz
    λ = rate*dt
	@assert(!isnan(λ))
	if λ != 0.
	    spikes = rand(Poisson(abs(λ)))
	    if λ < 0
			for _ in 1:spikes
			    inh_spike!(compartment, eff=efficacy)
			end
		else
			for _ in 1:spikes
			    exc_spike_plastic!(compartment, AMPA_eff=AMPA_eff, NMDA_eff=NMDA_eff)
		    end
		end
	end
end

function set_rate!( efficacy::Real, compartment::Union{Dendrite,Soma}, rate::Float64, dt::Real=dt)
    ### rate in Hz, transform to milliHertz
    λ = rate*dt
	@assert(!isnan(λ))
	if λ != 0.
	    spikes = rand(Poisson(abs(λ)))
	    if λ < 0
			for _ in 1:spikes
			    inh_spike!(compartment, eff=efficacy)
			end
		else
			for _ in 1:spikes
			    exc_spike!(compartment, eff=efficacy)
		    end
		end
	end
end


function get_EPSP(v::Array{Float64,2}; spiketime=-1, rest=0, inh=false, compartment=1)
	spiketime = spiketime < 0 ? EXCSPIKETIME : spiketime
	if inh == false
	    return maximum(v[compartment,spiketime:end]) - rest
	else
	    return minimum(v[compartment,spiketime:end]) - rest
	end
end

function _PoissonInput(Hz_rate::Real, interval::Int64, dt::Float64)
    λ = 1000/Hz_rate
	spikes = falses(round(Int,interval/dt))
	t = 1
	while t < interval/dt
		Δ = rand(Exponential(λ/dt))
		t += Δ
		if t < interval/dt
			spikes[round(Int,t)] = true
		end
	end
	return spikes
end

function PoissonInput(Hz_rate::Real, interval::Int64, dt::Float64; neurons::Int64=1)
	spikes = falses(neurons, round(Int,interval/dt))
	for n in 1:neurons
		spikes[n,:] .= _PoissonInput(Hz_rate::Real, interval::Int64, dt::Float64)
	end
	return spikes
end

function get_balance_conditions(d1,d2,rate)
	_rate = balance_rates[rate]
	if d1+d2==0
		kie_rate = [balance_kie_soma[rate],0.,0.]
		kie_gsyn = [0.,0.,0.]
		l1 = 0
		l2 = 0
		soma_only = true
	else
		l1 = balance_models[d1]
		l2 = balance_models[d2]
		kie_rate = [0,balance_kie_rate[rate,d1], balance_kie_rate[rate,d2]]
		kie_gsyn = [0,balance_kie_gsyn[rate,d1], balance_kie_gsyn[rate,d2]]
		soma_only = false
	end

	return (model=(l1,l2), rate=_rate*1000, ieratio=kie_rate, ie_gsyn=kie_gsyn, soma=soma_only)
end


function make_rates(simtime::Int,β, dt=0.1; rate::Real=1000., kwargs...)
	"""
	Produce inpute rates, dimension is kHz⁻¹
	Resolution is ms.
	"""
	remove_second = true
	noise = 0.
	inputs = zeros(round(Int, simtime))
	for t in 1:round(Int,simtime)
		re = rand() -0.5
		noise = re - (re - noise) * exp(-dt/50)
		inputs[t] = 1 + maximum([0, noise])*β
	end
		return inputs/(sum(inputs)/simtime)*rate
end

function make_spikes(simtime, β, ;soma=false,dends=true, rate=1000., eiratio=ones(3), gsyn=1., ieratio=ones(3), kwargs...)
	r_inh = zeros(3,simtime)
	r_exc = zeros(3,simtime)
	for i in 1:3
		r_inh[i,:] = make_rates(simtime,β,rate=rate)
		r_exc[i,:] = make_rates(simtime,β,rate=rate)
	end
	exc_spikes = zeros(Int,3,round(Int,simtime/dt))
	inh_spikes = zeros(Int,3,round(Int,simtime/dt))
	for x in 1:simtime
		for y in 1:round(Int,1/dt)
			z = (x-1)*10+y
			for i in 1:3
				(i==1 && !soma) && continue
				(i>1 && !dends) && continue
				exc_spikes[i,z] = gsyn*rand(Poisson(eiratio[i]*r_exc[i,x]*dt/1000))
				inh_spikes[i,z] = gsyn*rand(Poisson(ieratio[i]*r_exc[i,x]*dt/1000))
			end
		end
	end
	return  vcat(exc_spikes, inh_spikes)
end

logrange(x1, x2, n) = [10^y for y in range(log10(x1), log10(x2), length=n)]

function null_input(;kwargs...)
end

function active_neuron(;
                  step::Int64,
                  dt::Float64,
				  tripod=nothing,
                  soma=nothing,
				  somaspike=false)
		set_rate(50., tripod.s, 0.1)
end

function test_synapse(;
                  step::Int64,
                  dt::Float64,
				  tripod=nothing,
                  soma=nothing,
				  somaspike=false)

    if step == 1
        if tripod != nothing
            if somaspike
                exc_spike(tripod.s, 1.)
				inh_spike(tripod.s, 1.)
            else
                exc_spike(tripod.d[1], 1.)
				inh_spike(tripod.d[1], 1.)
            end
        end
        if soma != nothing
            exc_spike(soma,1.)
			inh_spike(soma, 1.)
        end
    end
end

function get_efficacies(rate_range, effective_range)
    efficacy = Array{Float64,2}(undef, length(rate_range),length(effective_range))
    for n in eachindex(effective_range)
        for i in eachindex(rate_range)
            efficacy[i,n] = effective_range[n]/rate_range[i]
        end
    end
    return efficacy
end

function set_synapses(neurons, receptor::String, value::Float64)
    if isa(neurons,Array{Tripod,1})
        for neuron in neurons
            for d in neuron.d
                set_gsyn(getfield(d.syn,Symbol(receptor)),value)
            end
        end
    elseif isa(neurons,Tripod)
        for d in neurons.d
            set_gsyn(getfield(d.syn,Symbol(receptor)),value)
        end
    end
end
