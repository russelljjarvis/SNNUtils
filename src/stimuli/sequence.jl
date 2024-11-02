using StatsBase

function generate_lexicon(config)
    @unpack ph_duration, dictionary = config

    all_words = collect(keys(dictionary)) |> Set |> collect |> sort |> Vector{Symbol}
    # sort(collect(Set(filter(x -> x !== silence_symbol, words)))) |> Vector{Symbol}
    all_phonemes = collect(values(dictionary)) |> Iterators.flatten |> Set |> collect |> sort |> Vector{Symbol}
    # sort(collect(Set(filter(x -> x !== silence_symbol, phonemes)))) |> Vector{Symbol}
    symbols = collect(union(all_words,all_phonemes))

    ## create mapping between numbers and phonemes
    mapping = Dict{Int, Symbol}()
    r_mapping = Dict{Symbol, Int}()
    for (n, s) in enumerate(all_words)
        push!(mapping, n => s)
        push!(r_mapping, s => n)
    end
    for (n, s) in enumerate(all_phonemes)
        n = n + length(all_words)
        push!(mapping, n => s)
        push!(r_mapping, s => n)
    end

    ## Add the silence symbol
    silence_symbol = :_
    silence = length(symbols) + 1
    push!(mapping, silence => silence_symbol)
    push!(r_mapping, silence_symbol => silence)

    return (id2string = mapping, 
            string2id = r_mapping, 
            dict=dictionary, 
            symbols=(phonemes = all_phonemes, 
            words = all_words), 
            ph_duration = ph_duration, 
            silence_symbol = silence_symbol)
end

function generate_sequence(lexicon, config, seed=nothing)

    if seed !== nothing
        Random.seed!(seed)
    end 

    @unpack seq_length = config
    @unpack dict, id2string, string2id, symbols, silence_symbol, ph_duration = lexicon
    silent_intervals = 1
    words, phonemes = get_words(
        seq_length,
        dict,
        silence_symbol,
        silent_intervals = silent_intervals,
    )

    ## create the populations
    ## sequence from the initial word sequence
    silence = string2id[silence_symbol]
    if haskey(config,:init_silence)
        sequence = fill(silence, 3, seq_length+1)
        sequence[1, 1] = silence
        sequence[2, 1] = silence
        sequence[3, 1] = config.init_silence
        for (n, (w, p)) in enumerate(zip(words, phonemes))
            sequence[1, 1+n] = string2id[w]
            sequence[2, 1+n] = string2id[p]
            sequence[3, 1+n] = ph_duration[p]
        end
    else
        sequence = fill(silence, 3, seq_length)
        for (n, (w, p)) in enumerate(zip(words, phonemes))
            sequence[1, n] = string2id[w]
            sequence[2, n] = string2id[p]
            sequence[3, n] = ph_duration[p]
        end
    end

    line_id = (phonemes=2, words=1, duration=3)
    sequence = (;lexicon...,
                sequence=sequence,
                line_id = line_id)

end

function generate_sequence(lexicon, config, seed=nothing)

    if seed !== nothing
        Random.seed!(seed)
    end 

    @unpack seq_length = config
    @unpack dict, id2string, string2id, symbols, silence_symbol, ph_duration, ph_space_duration = lexicon
    silent_intervals = 1
    words, phonemes = get_words(
        seq_length,
        dict,
        silence_symbol,
        silent_intervals = silent_intervals,
    )

    ## create the populations
    ## sequence from the initial word sequence
    silence = string2id[silence_symbol]
    if haskey(config,:init_silence)
        sequence = fill(silence, 3, seq_length+1)
        sequence[1, 1] = silence
        sequence[2, 1] = silence
        sequence[3, 1] = config.init_silence
        for (n, (w, p)) in enumerate(zip(words, phonemes))
            sequence[1, 1+n] = string2id[w]
            sequence[2, 1+n] = string2id[p]
            if p in keys(ph_space_duration)
                min, max = ph_space_duration[p]
                space_duration = rand(min:max)
                sequence[3, 1+n] = space_duration
            else
                sequence[3, 1+n] = ph_duration[p]
            end
        end
    else
        sequence = fill(silence, 3, seq_length)
        for (n, (w, p)) in enumerate(zip(words, phonemes))
            sequence[1, n] = string2id[w]
            sequence[2, n] = string2id[p]
            if p in keys(ph_space_duration)
                min, max = ph_space_duration[p]
                space_duration = rand(min:max)
                sequence[3, n] = space_duration
            else
                sequence[3, n] = ph_duration[p]
            end
        end
    end

    line_id = (phonemes=2, words=1, duration=3)
    sequence = (;lexicon...,
                sequence=sequence,
                line_id = line_id)

end

function sign_intervals(sign::Symbol, sequence)
    @unpack dict, id2string, string2id, sequence, symbols, line_id = sequence
    ## Identify the line of the sequence that contains the sign
    sign_line_id = -1
    for k in keys(symbols)
        if sign in getfield(symbols,k)
            sign_line_id = getfield(line_id,k)
            break
        end
    end
    if sign_line_id == -1
        throw(ErrorException("Sign index not found"))
    end

    ## Find the intervals where the sign is present
    intervals = Vector{Vector{Float32}}()
    cum_duration = cumsum(sequence[line_id.duration,:])
    _end = 1
    interval = [-1, -1]
    my_seq = sequence[sign_line_id, :]
    while !isnothing(_end)  || !isnothing(_start)
        _start = findfirst(x -> x == string2id[sign], my_seq[_end:end])
        if isnothing(_start)
            break
        else
            _start += _end-1
        end
        _end  = findfirst(x -> x != string2id[sign], my_seq[_start:end]) + _start - 1
        interval[1] = cum_duration[_start] - sequence[line_id.duration,_start]
        interval[2] = cum_duration[_end-1]
        push!(intervals, interval)
    end
    return intervals
end

function sequence_end(seq)
    """
    Return the end of the sequence
    """
    @unpack line_id, sequence = seq
    return sum(sequence[line_id.duration, :])
end

""""
    Return true if the time `x` is in any of the intervals
"""
function time_in_interval(x::Float32, intervals::Vector{Vector{Float32}})
    for interval in intervals
        if x >= interval[1] && x <= interval[2]
            return true
        end
    end
    return false
end

function start_interval(x::Float32, intervals::Vector{Vector{Float32}})
    for interval in intervals
        if x >= interval[1] && x <= interval[2]
            return interval[1]
        end
    end
    return -1
end

## create a random sequence of words with respective phones
function get_words(
    seq_length::Int,
    dictionary::Dict{Symbol, Vector{Symbol}},
    silence_symbol::Symbol;
    silent_intervals = 1,
    weights = nothing,
)

    dict_words = Vector{Symbol}(collect(keys(dictionary)))
    if isnothing(weights)
        weights = ones(length(dictionary))
        weights = StatsBase.Weights(weights)
    else
        @assert length(weights) == length(dictionary)
        weights = StatsBase.Weights([weights[k] for k in dict_words])
    end
    word_count = Dict{Symbol,Int}()
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
                push!(words, silence_symbol)
                push!(phonemes, silence_symbol)
            end
            continue
        end
        for (i, ph) in enumerate(phs)
            push!(phonemes, ph)
            push!(words, word)
            _seq_length += 1

            # Add the phoneme spacing symbol after each phoneme, except the last
            if i < length(phs)
                ph_space_symbol = Symbol("_" * string(word))  # Get the matching symbol for ph
                push!(phonemes, ph_space_symbol)  # Add space symbol
                push!(words, word)  # Null for spacing
                _seq_length += 1
            end
        end
        for _ = 1:silent_intervals
            push!(words, silence_symbol)
            push!(phonemes, silence_symbol)
            _seq_length += 1
        end
    end
    return words, phonemes
end

# function silence_sequence!(seq::Encoding)
#     @assert(length(seq.populations) == seq.silence)
#     @assert(seq.populations[seq.silence] == [])
#     fill!(seq.sequence, seq.silence)
# end

# function silence_sequence(seq::Encoding)
#     new_seq = deepcopy(seq)
#     silence_sequence!(new_seq)
#     return new_seq
# end

export generate_sequence, get_words, sign_intervals, time_in_interval, sequence_end, generate_lexicon, start_interval