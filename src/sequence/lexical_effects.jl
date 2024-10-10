
"""
    mix_population(seq, pops::Vector{Int64}, length_pop::Int64=0)

Mixes the neurons from the populations in `pops` and returns a new population of length `length_pop`.
If `length_pop` is not specified, it will be the mean of the lengths of the populations in `pops`.
"""
function mix_population(seq, pops::Vector{Int64}, length_pop::Int64)
    dendrites = seq.dendrites[pops]
    pops = seq.populations[pops]
    if length_pop == 0
        length_pop = round(Int, mean([length(pop) for pop in pops]))
    end
    new_pop = Vector{Int64}(undef, length_pop)
    new_dendrites = Matrix{Float32}(undef, 3, length_pop)
    for i in eachindex(new_pop)
        ## Choose the origin population
        pop_id = rand(1:length(pops))
        ## Get the dendrites and neurons
        dendrite = dendrites[pop_id]
        pop = pops[pop_id]
        ## Choose a random neuron id
        n_id = rand(1:length(pop))
        ## Get the dendrites and neurons
        dends = dendrite[:, n_id]
        neuron = pop[n_id]
        ## Push the neuron and dendrites to the new population
        new_dendrites[:, i] = dends
        new_pop[i] = neuron
    end
    return new_pop, new_dendrites
end


"""
    phonemic_continuum(seq, pops::Vector{Int64}, continuum::AbstractVector)

    Mixes the neurons from the populations in `pops` and returns a new population.
    The neurons are mixed based on the values in `continuum`.
    Return a set of populations and dendrites, one for each value in `continuum`.
"""
function phonemic_continuum(seq, target_pops::Vector{Int64}, continuum::AbstractVector)
    dendrites = deepcopy(seq.dendrites[target_pops])
    pops = deepcopy(seq.populations[target_pops])
    pops_copy = deepcopy(pops)
    cont_pops = Vector{Vector{Int64}}(undef, length(continuum))
    cont_dends = Vector{Matrix{Float32}}(undef, length(continuum))
    length_pop = round(Int, mean([length(Set(pop)) for pop in pops]))
    for k in eachindex(continuum)
        c = continuum[k]
        new_pop = Vector{Int64}(undef, length_pop)
        new_dendrites = Matrix{Float32}(undef, 3, length_pop)
        pops = deepcopy(seq.populations[target_pops])
        for i in eachindex(new_pop)
            ## Choose the origin population
            pop_id = StatsBase.sample([1, 2], StatsBase.Weights([c, 1 - c]))
            ## Get the dendrites and neurons
            dendrite = dendrites[pop_id]
            pop = pops[pop_id]
            ## Choose a random neuron id
            n_id = rand(1:length(pop))
            ## Get the neurons
            neuron = popat!(pop, n_id)
            ## Remove it from the pool and select the correct dendrite
            n_id = indexin(neuron, pops_copy[pop_id])
            dends = dendrite[:, n_id]
            ## Push the neuron and dendrites to the new population
            new_dendrites[:, i] = dends
            new_pop[i] = neuron
        end
        cont_pops[k] = new_pop
        cont_dends[k] = new_dendrites
    end
    return cont_pops, cont_dends
end




"""
    ganong_effect_seq(seq, target)

    This function creates a new sequence with the ganong effect for the given target.
    The target is a tuple with the following fields:
        w1::String: First word
        w2::String: Second word
        pos::Int64: Position of the phoneme to be changed
        len::Int64: Length of the new population. If 0, the length is the average of the two populations.
"""
function warren_effect_seq(seq, target)
    new_seq = deepcopy(seq)
    @unpack w1, w2, pos, len = target
    ph1 = seq.lemmas[w1][pos]
    ph2 = seq.lemmas[w2][pos]
    new_pop, new_dendrite =
        mix_population(seq, [seq.rev_mapping[x] for x in [ph1, ph2]], len)
    new_phoneme = 'Ξ'
    new_w1 = copy(seq.lemmas[w1])
    new_w1[pos] = new_phoneme
    new_w2 = copy(seq.lemmas[w2])
    new_w2[pos] = new_phoneme
    new_seq.lemmas[w1] = new_w1
    new_seq.lemmas[w2] = new_w2

    push!(new_seq.populations, new_pop)
    push!(new_seq.dendrites, new_dendrite)
    new_id = length(new_seq.populations)
    push!(new_seq.mapping, new_id => new_phoneme)
    push!(new_seq.rev_mapping, new_phoneme => new_id)
    weights = Dict(k => 1.0 for k in keys(new_seq.lemmas))
    weights[w1] = 1.5
    weights[w2] = 1.5

    seq_length = length(new_seq.sequence[1, :])
    words, phonemes = get_word_sequence(
        seq_length,
        new_seq.lemmas,
        new_seq.mapping[new_seq.null],
        weights = weights,
    )
    for (n, (w, p)) in enumerate(zip(words, phonemes))
        new_seq.sequence[1, n] = new_seq.rev_mapping[w]
        new_seq.sequence[2, n] = new_seq.rev_mapping[p]
    end
    push!(new_seq.lemmas, "$ph1-$ph2" => new_phoneme)
    return new_seq
end


function ganong_effect_seq(seq, target; end_presentation = false)
    new_seq = deepcopy(seq)
    @unpack w1, w2, continuum = target
    ph1 = seq.lemmas[w1][1]
    ph2 = seq.lemmas[w2][1]

    new_pops, new_dendrites =
        phonemic_continuum(seq, [seq.rev_mapping[x] for x in [ph1, ph2]], continuum)

    center = round(Int, length(continuum))
    center_phoneme = Char("$center"[1])
    for i in eachindex(continuum)
        ## Create the phoneme with the continuum value
        new_id = length(new_seq.populations) + 1
        new_phoneme = Char("$i"[1])
        push!(new_seq.mapping, new_id => new_phoneme)
        push!(new_seq.rev_mapping, new_phoneme => new_id)
        push!(new_seq.populations, new_pops[i])
        push!(new_seq.dendrites, new_dendrites[i])

        ## Associate words to be called during the sequence generation
        w1_phonemes = copy(seq.lemmas[w1])
        w2_phonemes = copy(seq.lemmas[w2])
        w1_phonemes[1] = new_phoneme
        w2_phonemes[1] = new_phoneme
        if end_presentation
            my_null = Char(seq.mapping[seq.null][1])
            push!(w1_phonemes, my_null)
            push!(w1_phonemes, center_phoneme)
            push!(w1_phonemes, center_phoneme)
            push!(w2_phonemes, my_null)
            push!(w2_phonemes, center_phoneme)
            push!(w2_phonemes, center_phoneme)
            !haskey(new_seq.rev_mapping, my_null) &&
                push!(new_seq.rev_mapping, my_null => new_seq.null)
            w1_cont = string(w1, "_", i, i)
            w2_cont = string(w2, "_", i, i)
        else
            w1_cont = string(w1, i)
            w2_cont = string(w2, i)
        end
        push!(new_seq.lemmas, w1_cont => w1_phonemes)
        push!(new_seq.lemmas, w2_cont => w2_phonemes)
        ## Associate the words to an id and an id to a word
        new_id = length(new_seq.populations) + 1
        push!(new_seq.mapping, new_id => w1_cont)
        push!(new_seq.rev_mapping, w1_cont => new_id)
        push!(new_seq.populations, Vector{Int64}(undef, 0))
        push!(new_seq.dendrites, zeros(Float32, 3, 1))

        new_id = length(new_seq.populations) + 1
        push!(new_seq.mapping, new_id => w2_cont)
        push!(new_seq.rev_mapping, w2_cont => new_id)
        push!(new_seq.populations, Vector{Int64}(undef, 0))
        push!(new_seq.dendrites, zeros(Float32, 3, 1))

    end
    weights = Dict(k => 1.0 for k in keys(new_seq.lemmas))

    seq_length = length(new_seq.sequence[1, :])
    words, phonemes = get_word_sequence(
        seq_length,
        new_seq.lemmas,
        new_seq.mapping[new_seq.null],
        weights = weights,
    )
    for (n, (w, p)) in enumerate(zip(words, phonemes))
        new_seq.sequence[1, n] = new_seq.rev_mapping[w]
        new_seq.sequence[2, n] = new_seq.rev_mapping[p]
    end
    # push!(new_seq.lemmas,"$ph1-$ph2"=>new_phoneme)
    return new_seq
end
