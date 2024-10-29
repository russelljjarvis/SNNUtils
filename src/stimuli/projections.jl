using Distributions

function ExternalInput(
    population,
    connection_prob = 0.05;
    cells = nothing,
    rate = 1000Hz,
    strength = 10,
    inputs_nodes = 10,
)
    if isa(population, SNN.Tripod)
        return TripodExternalInput(
            population,
            connection_prob;
            cells = cells,
            rate = rate,
            strength = strength,
            inputs_nodes = inputs_nodes,
            n_dend = 2,
        )
    end

    input_pop = SNN.Poisson(N = inputs_nodes, param = SNN.PoissonParameter(rate = rate))
    synapses = Vector{SNN.AbstractSparseSynapse}()
    W = zeros(population.N, inputs_nodes)
    if isnothing(cells)
        for i in eachrow(W) #loop over all postsynaptic neurons
            if rand(Bernoulli(connection_prob)) # make connection with Bernoulli prob
                j = rand(1:inputs_nodes) # select 1 input node per neuron
                i[j] = strength
            end
        end
    elseif isa(cells, Vector{Int})
        for i in eachrow((@views W[cells, :])) #loop over all postsynaptic neurons
            j = rand(1:inputs_nodes) # select 1 input node per neuron
            i[j] = strength
        end
    end
    @show input_pop.N, population.N, size(W)
    synapses = SNN.SpikingSynapse(input_pop, population, :ge, w = W)
    return (syn = synapses, pop = input_pop)
end

function TripodExternalInput(
    population,
    connection_prob = 0.05;
    cells = nothing,
    rate = 1000Hz,
    strength = 10,
    inputs_nodes = 10,
    n_dend = 2,
)
    if isa(population, SNN.Tripod)
        @assert n_dend <= 2 "Tripod has maximum 2 dendrites"
    end
    input_pop = SNN.Poisson(N = inputs_nodes, param = SNN.PoissonParameter(rate = rate))
    synapses = Vector{SNN.AbstractSparseSynapse}()
    for n = 1:n_dend # loop over all dendrites
        W = zeros(population.N, inputs_nodes)
        if isnothing(cells)
            for i in eachrow(W) #loop over all postsynaptic neurons
                if rand(Bernoulli(connection_prob)) # make connection with Bernoulli prob
                    j = rand(1:inputs_nodes) # select 1 input node per neuron
                    i[j] = strength
                end
            end
        elseif isa(cells, Vector{Int})
            for i in eachrow(W[cells, :]) #loop over all postsynaptic neurons
                j = rand(1:inputs_nodes) # select 1 input node per neuron
                i[j] = strength
            end
        end
        s = SNN.CompartmentSynapse(input_pop, population, Symbol("d$n"), :he, w = W)
        push!(synapses, s)
    end
    return (syn = synapses, pop = input_pop)
end

"""
	TripodBackground(Tripod_pop; N_E = 1000, N_I = 250, ν_E = 50Hz, ν_I = 50Hz, r0 = 10Hz, v0_d1 = -50mV, v0_d2 = -50mV, μ_s = 0.5f0)

Create a background feed for a population of Tripod neurons.

# Arguments
- `Tripod_pop`: the population of Tripod neurons.

# Keyword Arguments
- `N_E`: Number of excitatory Poisson neurons (default: 1000).
- `N_I`: Number of inhibitory Poisson neurons (default: 250).
- `ν_E`: Firing rate of excitatory Poisson neurons (default: 50Hz).
- `ν_I`: Firing rate of inhibitory Poisson neurons (default: 50Hz).
- `r0`: Base rate for STDP (default: 10Hz).
- `v0_d1`: Reversal potential for inhibitory synaptic inputs on dendrite 1(default: -50mV).
- `v0_d2`: Reversal potential for inhibitory synaptic inputs on dendrite 2 (default: -50mV).
- `μ_s`: Standard deviation for the weight distribution of excitatory synapses onto the soma (default: 0.5).

# Returns
- A tuple of two dictionaries: 
	- `back_syn`: contains the synapses created.
	- `back_pop`: contains the populations created.

"""
function TripodBalancedNoise(
    Tripod_pop;
    N_E = 1000,
    N_I = 250,
    ν_E = 20Hz,
    ν_I = 50Hz,
    r0 = 3Hz,
    v0 = -50mV,
    μ_s = 0.5f0,
)
    I = SNN.Poisson(N = N_I, param = SNN.PoissonParameter(rate = ν_I))
    E = SNN.Poisson(N = N_E, param = SNN.PoissonParameter(rate = ν_E))
    inh_d1 = SNN.CompartmentSynapse(
        I,
        Tripod_pop,
        :d1,
        :hi,
        p = 0.2,
        μ = 1,
        param = SNN.iSTDPParameterPotential(v0 = v0),
    )
    inh_d2 = SNN.CompartmentSynapse(
        I,
        Tripod_pop,
        :d2,
        :hi,
        p = 0.2,
        μ = 1,
        param = SNN.iSTDPParameterPotential(v0 = v0),
    )
    inh_s = SNN.CompartmentSynapse(
        I,
        Tripod_pop,
        :s,
        :hi,
        p = 0.4,
        μ = 1,
        param = SNN.iSTDPParameterRate(r = r0),
    )
    exc_d1 = SNN.CompartmentSynapse(E, Tripod_pop, :d1, :he, p = 0.2, μ = 1.0)
    exc_d2 = SNN.CompartmentSynapse(E, Tripod_pop, :d2, :he, p = 0.2, μ = 1.0)
    exc_s = SNN.CompartmentSynapse(E, Tripod_pop, :s, :he, p = 0.2, μ = μ_s)

    synapses = dict2ntuple(@strdict inh_d1 inh_d2 inh_s exc_d1 exc_d2 exc_s)
    populations = dict2ntuple(@strdict I E)
    return (syn = synapses, pop = populations)
end

function TripodExcNoise(Tripod_pop; N_E = 1000, ν_s = 200Hz, ν_d = 200Hz, μ_s = 2.0f0)
    Ed = SNN.Poisson(N = N_E, param = SNN.PoissonParameter(rate = ν_d))
    Es = SNN.Poisson(N = N_E, param = SNN.PoissonParameter(rate = ν_s))
    exc_d1 = SNN.CompartmentSynapse(Ed, Tripod_pop, :d1, :he, p = 0.2, μ = 1.0)
    exc_d2 = SNN.CompartmentSynapse(Ed, Tripod_pop, :d2, :he, p = 0.2, μ = 1.0)
    exc_s = SNN.CompartmentSynapse(Es, Tripod_pop, :s, :he, p = 0.2, μ = μ_s)
    synapses = dict2ntuple(@strdict exc_d1 exc_d2 exc_s)
    populations = dict2ntuple(@strdict Ed Es)
    return (syn = synapses, pop = populations)
end


function CompartmentExcNoise(pop, targets, rates; N_E = 1000, p0 = 0.2)
    populations = Dict{String,Any}()
    synapses = Dict{String,Any}()
    for (target, rate) in zip(targets, rates)
        E = SNN.Poisson(N = N_E, param = SNN.PoissonParameter(rate = rate))
        exc = SNN.CompartmentSynapse(E, pop, target, :he, p = p0, μ = 1.0)
        push!(synapses, "E_to_$target" => exc)
        push!(populations, "E_$target" => E)
    end
    (pop = dict2ntuple(populations), syn = dict2ntuple(synapses))
end


function BalancedNoise(pop; N_E = 1000, N_I = 250, ν_E = 50Hz, ν_I = 50Hz, r0 = 10Hz)
    I = SNN.Poisson(N = N_I, param = SNN.PoissonParameter(rate = ν_I))
    E = SNN.Poisson(N = N_E, param = SNN.PoissonParameter(rate = ν_E))
    inh = SNN.SpikingSynapse(
        I,
        pop,
        :gi,
        p = 0.2,
        μ = 1,
        param = SNN.iSTDPParameterRate(r = r0),
    )
    exc = SNN.SpikingSynapse(E, pop, :ge, p = 0.2, μ = 1.0)

    synapses = dict2ntuple(@strdict exc inh)
    populations = dict2ntuple(@strdict I E)
    return (syn = synapses, pop = populations)
end

function ExcNoise(pop; N_E = 100, ν_E = 20Hz, μ = 1, name = "E")
    E = SNN.Poisson(N = N_E, param = SNN.PoissonParameter(rate = ν_E))
    exc = SNN.SpikingSynapse(E, pop, :ge, p = 0.2, μ = μ)
    synapses = dict2ntuple(Dict(Symbol("E_to_$name") => exc))
    populations = dict2ntuple(Dict(Symbol("E_$name") => E))
    return (syn = synapses, pop = populations)
end

export TripodBalancedNoise, BalancedNoise, ExcNoise, CompartmentExcNoise
