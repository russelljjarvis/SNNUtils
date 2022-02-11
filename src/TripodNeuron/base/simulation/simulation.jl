
## Define timestep for simulation

"""
Basic tool to test stimulation protocols
"""
function run_simulation(protocol; synapses=false, sim_time=5000, tripod=nothing, fast=false, kwargs...)
        if tripod != nothing
            t = Tripod(tripod)
        else
            t = Tripod(default_model)
        end

        if fast
            voltage = simulate_fast(t, sim_time, protocol; kwargs...)
            spikes = get_spikes(voltage[1,:])
            rate   = get_spike_rate(voltage)
            return voltage, spikes
        else
            voltage, currents, synapses = simulate_tripod(t, sim_time, protocol; record_synapses=synapses, kwargs...)
            inh_voltage = nothing
        end
        spikes = get_spikes(voltage[1,:])
        rate   = get_spike_rate(voltage)
    return voltage,currents,spikes, synapses, inh_voltage
end

function simulate_model(model::String, sim_time::Int, protocol::Function; kwargs...)
	""" Simulate voltage dynamics with Tripod or TripodSoma model"""
		t = Tripod(model)
    if model == H_ss
	 	_ = simulate_tripod_soma(t,1000, protocol; kwargs...)
	 	return simulate_tripod_soma(t,sim_time, protocol; kwargs...)
	else
        _ = simulate_fast(t, 1000, protocol; kwargs...)
        return simulate_fast(t, sim_time, protocol; kwargs...)
	end
end

function simulate_neuron(neuron, protocol, sim_time=1000; synapses=false, kwargs...)
	""" Simulate tripod or inhibitory neurons """
        if isa(neuron, Tripod)
            voltage, currents, synapses = simulate_tripod(neuron, sim_time, protocol; record_synapses=synapses, kwargs...)
            spikes = get_spikes(voltage)
            rate   = get_spike_rate(voltage)
            return voltage,currents,spikes, rate, synapses
        elseif neuron.model in ["SST", "PV"]
            voltage, synapses = simulate_lif(neuron, sim_time, protocol; record_synapses=synapses, kwargs...)
            spikes = get_spikes(voltage)
            rate   = get_spike_rate(voltage)
            return voltage, spikes, rate, synapses
        elseif neuron.model in ["AdEx"]
            voltage, synapses = simulate_adex(neuron, sim_time, protocol; record_synapses=synapses, kwargs...)
            spikes = get_spikes(voltage)
            rate   = get_spike_rate(voltage)
            return voltage, spikes, rate, synapses
        else
            @assert(1==0)
        end
end


"""
Run basic simulation of a single cell.

Parameters
----------
t -> an instance of Tripod neuron.

stimulation_protocol -> function to be run during the simulation, the function has 3 variables: 'tripod','time_step','resolution'

record_synapse -> store the values of synaptic conductance through out the simulation, it slows down the simulation

kwargs -> parameters of the stimulation protocol

Return
------
voltage 4xNsteps array. Soma, d1, d2, d3
current 5xNsteps array. Soma, d1, d2, d3, w_adapt_soma
synapses

"""
function simulate_tripod(t::Tripod,simTime::Int64,
                            stimulation_protocol::Union{Function, Array{Int64}};
                            record_synapses=false, record_currents=true, kwargs...)
    total_steps = round(Int,simTime/dt)
    n_dend = length(t.d)
    ## store currents --> to be removed lateron
    ## Recordings
    voltage = Array{Float64,2}(undef,n_dend+1,total_steps)
    current = Array{Float64,2}(undef,n_dend+2,total_steps)
    if record_synapses
        synapses = Array{Float64,3}(undef,4,total_steps,n_dend+1)
    else
        synapses  = nothing
    end

    spiked = (t.s.v > AdEx.θ)
	last_spike = -100.
    currents = Array{Float64,1}(undef,n_dend+1)

    @fastmath @inbounds for tt in 1:total_steps
        stimulation_protocol(;tripod=t,step=tt,dt=dt, kwargs...)
        if update_tripod!(t,currents,spiked)
			spiked = true
			last_spike = tt
		else
			spiked = false
		end
        voltage[1,tt] = t.s.v
        for n in 1:n_dend
            voltage[1+n,tt] = t.d[n].v
        end

        ### soma incoming current
        # This is a bit cumbersome, what I do here is to
        # get the current from the simulation and dispose in this order
        # current = [s_in, d1_out, d2_out, d3_in-out, w_adapt]
        current[1,tt] = currents[end]
        current[2:end-1,tt] = - currents[1:end-1]
        current[end,tt] = t.s.w
        if record_synapses
            store_synapses(synapses,t,tt)
        end
    end
    ## Current and Voltage plot
    return voltage, current, synapses
end

function store_synapses(synapses::Array{Float64,3}, t::Tripod, tt::Int64)
    # synapses = Array{Float64,3}(undef,4,total_steps,n_dend+1)
	comp = size(synapses)[end]
	for c in 1:comp
		if c==1
			synapses[1,tt,c] =  t.s.syn.AMPA.gsyn* t.s.g_AMPA
			synapses[2,tt,c] =  t.s.syn.NMDA.gsyn* t.s.g_NMDA
			synapses[3,tt,c] =  t.s.syn.GABAa.gsyn*t.s.g_GABAa
			synapses[4,tt,c] =  t.s.syn.GABAb.gsyn*t.s.g_GABAb
		else
			synapses[1,tt,c] =  t.d[c-1].syn.AMPA.gsyn*  t.d[c-1].g_AMPA
			synapses[2,tt,c] =  t.d[c-1].syn.NMDA.gsyn*  t.d[c-1].g_NMDA
			synapses[3,tt,c] =  t.d[c-1].syn.GABAa.gsyn* t.d[c-1].g_GABAa
			synapses[4,tt,c] =  t.d[c-1].syn.GABAb.gsyn* t.d[c-1].g_GABAb
		end
	end
end

function store_synapses(synapses::Array{Float64,3}, s::Soma, tt::Int64)
    # synapses = Array{Float64,3}(undef,4,total_steps,n_dend+1)
	comp = size(synapses)[end]
	for c in 1:comp
		synapses[1,tt,c] =  s.syn.AMPA.gsyn* s.g_AMPA
		synapses[2,tt,c] =  s.syn.NMDA.gsyn* s.g_NMDA
		synapses[3,tt,c] = s.syn.GABAa.gsyn* s.g_GABAa
		synapses[4,tt,c] = s.syn.GABAb.gsyn* s.g_GABAb
	end
end




function simulate_fast(t::Tripod,simTime::Int64,
                            stimulation_protocol::Union{Function, Array{Int64}}; kwargs...)
    total_steps = round(Int,simTime/dt)
    n_dend = length(t.d)
    ## Recordings
    currents = Array{Float64,1}(undef,n_dend+1)
    voltage = Array{Float64,2}(undef,n_dend+1,total_steps)
    spiked=false
	last_spike = -100.
    spiked = (t.s.v > AdEx.θ)

    @fastmath @inbounds for tt in 1:total_steps
        voltage[1,tt] = t.s.v
        for n in 1:n_dend
            voltage[1+n,tt] = t.d[n].v
        end
        stimulation_protocol(;tripod=t,step=tt,dt=dt, kwargs...)
        if update_tripod!(t,currents,spiked)
			spiked = true
			last_spike = tt
		else
			spiked = false
		end
    end
    ## Current and Voltage plot
    return voltage
end

simulate_fast(t::Tripod, stimulation_protocol::Union{Function, Array{Int64}}, simTime::Int64; kwargs...) = simulate_fast(t::Tripod,simTime::Int64, stimulation_protocol::Union{Function, Array{Int64}}; kwargs...)

function simulate_nospike(t::Tripod,simTime::Int64,
                            stimulation_protocol::Union{Function, Array{Int64}}; kwargs...)
    total_steps = round(Int,simTime/dt)
    n_dend = length(t.d)
    ## Recordings
    currents = Array{Float64,1}(undef,n_dend+1)
    voltage = Array{Float64,2}(undef,n_dend+1,total_steps)
	last_spike = -100.

    @fastmath @inbounds for tt in 1:total_steps
        stimulation_protocol(;tripod=t,step=tt,dt=dt, kwargs...)
        update_nospike!(t,currents)
        voltage[1,tt] = t.s.v
        for n in 1:n_dend
            voltage[1+n,tt] = t.d[n].v
        end
    end
    ## Current and Voltage plot
    return voltage
end

function simulate_tripod_soma(t::Tripod,simTime::Int64,
                            stimulation_protocol::Union{Function, Array{Int64}}; record_currents=false, kwargs...)
    total_steps = round(Int,simTime/dt)
    n_dend = length(t.d)
    ## Recordings
    voltage = Array{Float64,2}(undef,n_dend+1,total_steps)
    currents = Array{Float64,1}(undef,total_steps)
    spiked=false
	last_spike = -100.
    spiked = (t.s.v > AdEx.θ)

    @fastmath @inbounds for tt in 1:total_steps
        stimulation_protocol(;tripod=t,step=tt,dt=dt, kwargs...)

		# update dendrites
        soma_v = t.s.v
    	for (n,d) in enumerate(t.d)
            d.v = soma_v
            update_synapses_double!(d, Esyn_dend)
            t.s.v -= dt*AdEx.C⁻ *(syn_current(d, Esyn_dend))
    	end
        if update_AdEx!(t.s, spiked)
			spiked = true
			last_spike = tt
		else
			spiked = false
		end
        voltage[:,tt] .= t.s.v
		currents[tt] = t.s.w
    end
	if record_currents
	    return voltage, currents
	else
	    return voltage
	end
end

function simulate_adex(soma::Soma,simTime::Int64,
                            stimulation_protocol::Union{Function, Array{Int64}};
                            record_synapses=false, kwargs...)
    total_steps = round(Int,simTime/dt)
    ## Recordings
    voltage = Array{Float64,1}(undef,total_steps)
    if record_synapses
        synapses = Array{Float64,3}(undef,4,total_steps,1)
    else
        synapses  = nothing
    end
    spiked = false

    @fastmath @inbounds for n in 1:total_steps
        spiked = update_AdEx!(soma,spiked)
        stimulation_protocol(;soma=soma, step=n,dt=dt, kwargs...)
        voltage[n] = soma.v
        if record_synapses
            store_synapses(synapses,lif,n)
        end
    end
    ## Current and Voltage plot
    return voltage, synapses
end


function simulate_lif(lif::Soma,simTime::Int64,
                            stimulation_protocol::Union{Function, Array{Int64}};
                            record_synapses=false, kwargs...)
    total_steps = round(Int,simTime/dt)
    ## Recordings
    voltage = Array{Float64,1}(undef,total_steps)
    if record_synapses
        synapses = Array{Float64,3}(undef,4,total_steps,1)
    else
        synapses  = nothing
    end
    spiked = false

    @fastmath @inbounds for n in 1:total_steps
        spiked = update_lif!(lif,spiked)
        stimulation_protocol(;soma=lif, step=n,dt=dt, kwargs...)
        voltage[n] = lif.v
        if record_synapses
            store_synapses(synapses,lif,n)
        end
    end
    ## Current and Voltage plot
    return voltage, synapses
end
