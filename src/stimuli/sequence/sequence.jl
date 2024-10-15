"""
Create the sequence encoder for the network:
	1. Create target sub-populations of 'density*n_tripods' for each symbol.
	2. Connect the rate-based inputs to the 'input_cells' (stars cells)
	3. Create a sequence of inputs of length: 'sequence_length'
	The stimulus is mediated by the 'input cells', all cells
		and from the 'n_symbols' dictionary
"""
function seq_encoder(net::NetParams, stim::StimParams, dictionary::Dict; seed = nothing)
    if seed !== nothing
        Random.seed!(seed)
    end
    seq_length = stim.seq_length
    null_symbol = "_"
    words, phonemes = get_word_sequence(
        seq_length,
        dictionary,
        null_symbol,
        silence_duration = stim.silence,
    )

    all_words = Set(filter(x -> x !== null_symbol, words))
    all_phonemes = Set(filter(x -> x !== null_symbol, phonemes))
    stim.symbols = length(all_words) + length(all_phonemes)

    ## create mapping between numbers and phonemes
    mapping = Dict()
    r_mapping = Dict()
    for (n, s) in enumerate(all_words)
        push!(mapping, n => s)
        push!(r_mapping, s => n)
    end
    for (n, s) in enumerate(all_phonemes)
        n = n + length(all_words)
        push!(mapping, n => s)
        push!(r_mapping, s => n)
    end

    ## Add the null symbol
    stim.symbols += 1
    null = stim.symbols
    push!(mapping, null => "_")
    push!(r_mapping, "_" => null)

    ## create the populations
    ## sequence from the initial word sequence
    sequence = fill(stim.symbols, 2, seq_length)
    for (n, (w, p)) in enumerate(zip(words, phonemes))
        sequence[1, n] = r_mapping[w]
        sequence[2, n] = r_mapping[p]
    end

    ## obtain the populations with the dendritic
    ## characteristics
    projections, dendrites = get_projections(net.tripod, stim)
    ## Set null connections to the null symbol
    projections[null] = Vector{Int}()
    @info "stimuli:", stim.duration, stim.silence, stim.seq_length
    return Encoding(
        populations = projections,
        dendrites = dendrites,
        sequence = sequence,
        mapping = mapping,
        lemmas = dictionary,
        duration = Float32(stim.duration),
        null = null,
    )#, pop_to_symbol, symbol_to_pop)
end




function randomize_sequence(seq::Encoding, stim::StimParams)
    """
 Get a sequence and produce a new random sequence with the same words and
 the length defined in the stimulus parameters
    """
    @unpack sequence, populations, dendrites, mapping, lemmas, null = seq
    r_mapping = reverse_dictionary(mapping)
    words, phonemes = get_word_sequence(
        stim.seq_length,
        lemmas,
        mapping[null],
        silence_duration = stim.silence,
    )

    sequence = zeros(Int64, 2, stim.seq_length)
    for (n, (w, p)) in enumerate(zip(words, phonemes))
        sequence[1, n] = r_mapping[w]
        sequence[2, n] = r_mapping[p]
    end

    return Encoding(
        populations = populations,
        dendrites = dendrites,
        sequence = sequence,
        mapping = mapping,
        lemmas = lemmas,
        duration = stim.duration,
        null = null,
    )#, pop_to_symbol, symbol_to_pop)
end

function pseudoword_sequence(seq::Encoding, stim::StimParams)
    """
 Get a sequence and produce a new random sequence with the same words and
 the length defined in the stimulus parameters
    """
    @unpack sequence, populations, dendrites, mapping, lemmas, null = seq
    r_mapping = reverse_dictionary(mapping)

    pseudos =
        map(collect(eachindex(lemmas))) do x
            ll = [sample(collect(vcat(values(lemmas)...))) for x = 1:length(lemmas[x])]
            string("pseudo_", x) => ll
        end |> Dict

    words, phonemes = get_word_sequence(
        stim.seq_length,
        pseudos,
        mapping[null],
        silence_duration = stim.silence,
    )

    clean_string = length("pseudo_")
    sequence = zeros(Int64, 2, stim.seq_length)
    for (n, (w, p)) in enumerate(zip(words, phonemes))
        if w !== mapping[null]
            w = w[clean_string+1:end]
        end
        sequence[1, n] = r_mapping[w]
        sequence[2, n] = r_mapping[p]
    end

    return Encoding(
        populations = populations,
        dendrites = dendrites,
        sequence = sequence,
        mapping = mapping,
        lemmas = pseudos,
        duration = stim.duration,
        null = null,
    )#, pop_to_symbol, symbol_to_pop)
end




function randomize_sequence!(seq::Encoding)
    """
 Get a sequence and produce a new random sequence with the same words and
 the length defined in the stimulus parameters
    """
    @unpack sequence, populations, dendrites, mapping, lemmas, null = seq
    r_mapping = reverse_dictionary(mapping)
    seq_length = size(sequence, 2)
    words, phonemes = get_word_sequence(seq_length, lemmas, mapping[null])
    for (n, (w, p)) in enumerate(zip(words, phonemes))
        sequence[1, n] = r_mapping[w]
        sequence[2, n] = r_mapping[p]
    end
end

function get_bioseq_dictionary_info(dictionary, key="test")
    unique_elements = Set()
    epochs = []
    for epoch in keys(dictionary[key])
        push!(epochs, dictionary[key][epoch])
        for element in dictionary[key][epoch]
            push!(unique_elements, element)
        end
    end
    return collect(unique_elements), epochs
end

function make_unique_sequence(epochs)
    @assert all(length(epoch) == length(epochs[1]) for epoch in epochs )
    interval_length = maximum(length.(epochs)) +1
    sequence = Vector{String}()
    for epoch in epochs
        epoch_length = length(epoch)
        add_silence = interval_length - epoch_length
        append!(sequence, epoch)
        for _ in 1:add_silence
            append!(sequence, ["#"])
        end
    end
    @assert(all(length(collection) == length(epochs[1]) for collection in epochs))
    return sequence
end

function seq_from_bioseqlearn(net::NetParams, stim::StimParams, dictionary::Dict, stage="test")
    phonemes, epochs=  get_bioseq_dictionary_info(dictionary, stage)
    @show phonemes
    words = []
    null_symbol = "#"

    all_words = Set(filter(x -> x !== null_symbol, words))
    all_phonemes = Set(filter(x -> x !== null_symbol, phonemes))
    stim.symbols = length(all_words) + length(all_phonemes)

    ## create mapping between numbers and phonemes
    mapping = Dict()
    r_mapping = Dict()
    for (n, s) in enumerate(all_phonemes)
        n = n + length(all_words)
        push!(mapping, n => s)
        push!(r_mapping, s => n)
    end

    ## Add the null symbol
    stim.symbols+=1
    null = stim.symbols
    push!(mapping, null => "#")
    push!(r_mapping, "#" => null)

    ## Create the sequence
    sequence_phonemes = make_unique_sequence(epochs)
    seq_length = length(sequence_phonemes)
    ## sequence from the initial word sequence
    sequence = fill(null, 2, seq_length)
    for (n, p) in enumerate(sequence_phonemes)
        sequence[2, n] = r_mapping[p]
    end
    stim.seq_length = seq_length
    stim.simtime = seq_length * stim.duration
    store_interval = (1+length(epochs[1]))*stim.duration
    @show store_interval * length(epochs), stim.simtime

    ## create the populations
    ## obtain the populations with the dendritic
    ## characteristics
    projections, dendrites = get_projections(net.tripod, stim)
    ## Set null connections to the null symbol
    projections[null] = Vector{Int}()
    @info "stimuli:", stim.duration, stim.silence, stim.seq_length
    return Encoding(
        populations = projections,
        dendrites = dendrites,
        sequence = sequence,
        mapping = mapping,
        lemmas = dictionary,
        duration = Float32(stim.duration),
        null = null,
    ), 
    store_interval 
end

