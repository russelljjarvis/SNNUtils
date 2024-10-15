"""
Create the sequence encoder for the network:
	1. Create target sub-populations of 'density*n_tripods' for each symbol.
	2. Connect the rate-based inputs to the 'input_cells' (stars cells)
	3. Create a sequence of inputs of length: 'sequence_length'
	The stimulus is mediated by the 'input cells', all cells
		and from the 'n_symbols' dictionary
"""
function random_seq_encoder(net::NetParams, stim::StimParams)
    dictionary = deserialize(joinpath(@__DIR__, "dictionaries", stim.dictionary * ".dict"))
    seq_length = stim.seq_length
    null_symbol = "_"
    words, phonemes = get_word_sequence(seq_length, dictionary, null_symbol)

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

    duration = cumsum(Float32.((1 .+ 0.2 * randn(seq_length)) .* stim.duration))


    ## obtain the populations with the dendritic
    ## characteristics
    projections, dendrites = get_projections(net.tripod, stim)
    ## Set null connections to the null symbol
    projections[null] = Vector{Int}()
    return Encoding(
        populations = projections,
        dendrites = dendrites,
        sequence = sequence,
        mapping = mapping,
        lemmas = dictionary,
        duration = duration,
        null = null,
    )#, pop_to_symbol, symbol_to_pop)
end
