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
        s = SNN.CompartmentSynapse(input_pop, population, Symbol("d$n"), :exc, w = W)
        push!(synapses, s)
    end
    return (syn = synapses, pop = input_pop)
end
