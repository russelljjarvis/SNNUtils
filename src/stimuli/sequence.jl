using StatsBase

function generate_sequence(config; seed = nothing )
    if seed !== nothing
        Random.seed!(seed)
    end 

    @unpack seq_length, ph_duration, dictionary  = config

    silent_intervals = 1
    null_symbol = "_"
    words, phonemes = get_words(
        seq_length,
        dictionary,
        null_symbol,
        silent_intervals = silent_intervals,
    )


    all_words = Set(filter(x -> x !== null_symbol, words))
    all_phonemes = Set(filter(x -> x !== null_symbol, phonemes))

    symbols = collect(union(all_words,all_phonemes))

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
    null = length(symbols) + 1
    push!(mapping, null => "_")
    push!(r_mapping, "_" => null)

    ## create the populations
    ## sequence from the initial word sequence
    sequence = fill(null, 3, seq_length)
    intervals = []
    for (n, (w, p)) in enumerate(zip(words, phonemes))
        sequence[1, n] = r_mapping[w]
        sequence[2, n] = r_mapping[p]
        sequence[3, n] = ph_duration[p]
    end


    return (sequence=sequence, id2string = mapping, string2id = r_mapping, dict=dictionary, intervals = intervals)
end

##
# Return all intervals that contain a certain word
function word_intervals(word_index::Int, sequence)
    @unpack dict, id2string, sequence = sequence
    # n_phonemes = length(dict[seq.id2string[word_index]])
    intervals = Vector{Vector{Float32}}()
    cum_duration = cumsum(sequence[3,:])
    _end = 1
    interval = [-1, -1]
    while !isnothing(_end)  || !isnothing(_start)
        _start = findfirst(x -> x == word_index, sequence[1, _end:end])
        if isnothing(_start)
            break
        else
            _start += _end-1
        end
        _end  = findfirst(x -> x != word_index, sequence[1, _start:end]) + _start - 1
        interval[1] = cum_duration[_start] - sequence[3,_start]
        interval[2] = cum_duration[_end-1]
        push!(intervals, interval)
    end
    return intervals

end

##
    # _start = findfirst(x -> x == word_index, sequence[_end, :])
    # _end  = findfirst(x -> x != word_index, sequence[1, _start:end])

    # _word_indices = Vector{Int}()
    # word_indices = Vector{Vector{Int}}()
    # interval = [-1, -1]
    # for ww in eachindex(sequence[1, :])
    #     w = sequence[1, ww]
    #     if w == word_index
    #         if c == 0
    #             empty!(_word_indices)
    #             interval[1] = (ww - 1) * seq.duration
    #         end
    #         push!(_word_indices, ww)
    #         c += 1
    #         if c == n_phonemes
    #             interval[2] = ww *(duration)
    #             push!(word_indices, copy(_word_indices))
    #             push!(word_collect, copy(interval))
    #             z = Vector{Int}
    #             c = 0
    #         end
    #     end
    # end
    # return word_collect, word_indices



# function randomize_sequence(seq::Encoding, stim::StimParams)
#     """
#  Get a sequence and produce a new random sequence with the same words and
#  the length defined in the stimulus parameters
#     """
#     @unpack sequence, populations, dendrites, mapping, lemmas, null = seq
#     r_mapping = reverse_dictionary(mapping)
#     words, phonemes = get_word_sequence(
#         stim.seq_length,
#         lemmas,
#         mapping[null],
#         silent_intervals = stim.silence,
#     )

#     sequence = zeros(Int64, 2, stim.seq_length)
#     for (n, (w, p)) in enumerate(zip(words, phonemes))
#         sequence[1, n] = r_mapping[w]
#         sequence[2, n] = r_mapping[p]
#     end

#     return Encoding(
#         populations = populations,
#         dendrites = dendrites,
#         sequence = sequence,
#         mapping = mapping,
#         lemmas = lemmas,
#         duration = stim.duration,
#         null = null,
#     )#, pop_to_symbol, symbol_to_pop)
# end

# function pseudoword_sequence(seq::Encoding, stim::StimParams)
#     """
#  Get a sequence and produce a new random sequence with the same words and
#  the length defined in the stimulus parameters
#     """
#     @unpack sequence, populations, dendrites, mapping, lemmas, null = seq
#     r_mapping = reverse_dictionary(mapping)

#     pseudos =
#         map(collect(eachindex(lemmas))) do x
#             ll = [sample(collect(vcat(values(lemmas)...))) for x = 1:length(lemmas[x])]
#             string("pseudo_", x) => ll
#         end |> Dict

#     words, phonemes = get_word_sequence(
#         stim.seq_length,
#         pseudos,
#         mapping[null],
#         silent_intervals = stim.silence,
#     )

#     clean_string = length("pseudo_")
#     sequence = zeros(Int64, 2, stim.seq_length)
#     for (n, (w, p)) in enumerate(zip(words, phonemes))
#         if w !== mapping[null]
#             w = w[(clean_string+1):end]
#         end
#         sequence[1, n] = r_mapping[w]
#         sequence[2, n] = r_mapping[p]
#     end

#     return Encoding(
#         populations = populations,
#         dendrites = dendrites,
#         sequence = sequence,
#         mapping = mapping,
#         lemmas = pseudos,
#         duration = stim.duration,
#         null = null,
#     )#, pop_to_symbol, symbol_to_pop)
# end




# function randomize_sequence!(seq::Encoding)
#     """
#  Get a sequence and produce a new random sequence with the same words and
#  the length defined in the stimulus parameters
#     """
#     @unpack sequence, populations, dendrites, mapping, lemmas, null = seq
#     r_mapping = reverse_dictionary(mapping)
#     seq_length = size(sequence, 2)
#     words, phonemes = get_word_sequence(seq_length, lemmas, mapping[null])
#     for (n, (w, p)) in enumerate(zip(words, phonemes))
#         sequence[1, n] = r_mapping[w]
#         sequence[2, n] = r_mapping[p]
#     end
# end

# function get_bioseq_dictionary_info(dictionary, key = "test")
#     unique_elements = Set()
#     epochs = []
#     for epoch in keys(dictionary[key])
#         push!(epochs, dictionary[key][epoch])
#         for element in dictionary[key][epoch]
#             push!(unique_elements, element)
#         end
#     end
#     return collect(unique_elements), epochs
# end

# function make_unique_sequence(epochs)
#     @assert all(length(epoch) == length(epochs[1]) for epoch in epochs)
#     interval_length = maximum(length.(epochs)) + 1
#     sequence = Vector{String}()
#     for epoch in epochs
#         epoch_length = length(epoch)
#         add_silence = interval_length - epoch_length
#         append!(sequence, epoch)
#         for _ = 1:add_silence
#             append!(sequence, ["#"])
#         end
#     end
#     @assert(all(length(collection) == length(epochs[1]) for collection in epochs))
#     return sequence
# end

# function seq_from_bioseqlearn(
#     net::NetParams,
#     stim::StimParams,
#     dictionary::Dict,
#     stage = "test",
# )
#     phonemes, epochs = get_bioseq_dictionary_info(dictionary, stage)
#     @show phonemes
#     words = []
#     null_symbol = "#"

#     all_words = Set(filter(x -> x !== null_symbol, words))
#     all_phonemes = Set(filter(x -> x !== null_symbol, phonemes))
#     stim.symbols = length(all_words) + length(all_phonemes)

#     ## create mapping between numbers and phonemes
#     mapping = Dict()
#     r_mapping = Dict()
#     for (n, s) in enumerate(all_phonemes)
#         n = n + length(all_words)
#         push!(mapping, n => s)
#         push!(r_mapping, s => n)
#     end

#     ## Add the null symbol
#     stim.symbols += 1
#     null = stim.symbols
#     push!(mapping, null => "#")
#     push!(r_mapping, "#" => null)

#     ## Create the sequence
#     sequence_phonemes = make_unique_sequence(epochs)
#     seq_length = length(sequence_phonemes)
#     ## sequence from the initial word sequence
#     sequence = fill(null, 2, seq_length)
#     for (n, p) in enumerate(sequence_phonemes)
#         sequence[2, n] = r_mapping[p]
#     end
#     stim.seq_length = seq_length
#     stim.simtime = seq_length * stim.duration
#     store_interval = (1 + length(epochs[1])) * stim.duration
#     @show store_interval * length(epochs), stim.simtime

#     ## create the populations
#     ## obtain the populations with the dendritic
#     ## characteristics
#     projections, dendrites = get_projections(net.tripod, stim)
#     ## Set null connections to the null symbol
#     projections[null] = Vector{Int}()
#     @info "stimuli:", stim.duration, stim.silence, stim.seq_length
#     return Encoding(
#         populations = projections,
#         dendrites = dendrites,
#         sequence = sequence,
#         mapping = mapping,
#         lemmas = dictionary,
#         duration = Float32(stim.duration),
#         null = null,
#     ),
#     store_interval
# end

## create a random sequence of words with respective phones
function get_words(
    seq_length::Int,
    dictionary::Dict,
    null_symbol::String;
    silent_intervals = 1,
    weights = nothing,
)

    dict_words = Vector{String}(collect(keys(dictionary)))
    if isnothing(weights)
        weights = ones(length(dictionary))
        weights = StatsBase.Weights(weights)
    else
        @assert length(weights) == length(dictionary)
        weights = StatsBase.Weights([weights[k] for k in dict_words])
    end
    word_count = Dict{String,Int}()
    words = []
    phonemes = []
    _seq_length = 0

    initial_words = copy(dict_words)
    # @info initial_words, dict_words
    #@TODO 
    make_equal = true
    while _seq_length < seq_length
        if make_equal
            word =
                !isempty(initial_words) ? pop!(initial_words) :
                StatsBase.sample(
                    dict_words,
                    StatsBase.Weights([exp(-word_count[x]) for x in dict_words]),
                )
        else
            word = StatsBase.sample(dict_words, weights)
        end
        phs = dictionary[word]
        if haskey(word_count, word)
            word_count[word] += 1
        else
            word_count[word] = 1
        end
        if length(phs) + silent_intervals > seq_length - _seq_length
            while _seq_length < seq_length
                _seq_length += 1
                push!(words, null_symbol)
                push!(phonemes, null_symbol)
            end
            continue
        end
        for ph in phs
            push!(phonemes, ph)
            push!(words, word)
            _seq_length += 1
        end
        for _ = 1:silent_intervals
            push!(words, null_symbol)
            push!(phonemes, null_symbol)
            _seq_length += 1
        end
    end
    return words, phonemes
end

# function null_sequence!(seq::Encoding)
#     @assert(length(seq.populations) == seq.null)
#     @assert(seq.populations[seq.null] == [])
#     fill!(seq.sequence, seq.null)
# end

# function null_sequence(seq::Encoding)
#     new_seq = deepcopy(seq)
#     null_sequence!(new_seq)
#     return new_seq
# end

export generate_sequence, get_words, word_intervals