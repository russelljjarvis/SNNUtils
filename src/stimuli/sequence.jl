using StatsBase

function generate_sequence(config; seed = nothing )
    if seed !== nothing
        Random.seed!(seed)
    end 

    @unpack seq_length, ph_duration, dictionary = config

    silent_intervals = 1
    null_symbol = :_
    words, phonemes = get_words(
        seq_length,
        dictionary,
        null_symbol,
        silent_intervals = silent_intervals,
    )


    all_words = sort(collect(Set(filter(x -> x !== null_symbol, words)))) |> Vector{Symbol}
    all_phonemes = sort(collect(Set(filter(x -> x !== null_symbol, phonemes)))) |> Vector{Symbol}

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
    push!(mapping, null => :_)
    push!(r_mapping, :_ => null)

    ## create the populations
    ## sequence from the initial word sequence
    if haskey(config,:init_silence)
        sequence = fill(null, 3, seq_length+1)
        sequence[1, 1] = null
        sequence[2, 1] = null
        sequence[3, 1] = config.init_silence
        for (n, (w, p)) in enumerate(zip(words, phonemes))
            sequence[1, 1+n] = r_mapping[w]
            sequence[2, 1+n] = r_mapping[p]
            sequence[3, 1+n] = ph_duration[p]
        end
    else
        sequence = fill(null, 3, seq_length)
        for (n, (w, p)) in enumerate(zip(words, phonemes))
            sequence[1, n] = r_mapping[w]
            sequence[2, n] = r_mapping[p]
            sequence[3, n] = ph_duration[p]
        end
    end


    line_id = (phonemes=2, words=1, duration=3)


    return (sequence=sequence, 
            id2string = mapping, 
            string2id = r_mapping, 
            dict=dictionary, 
            symbols=(phonemes = all_phonemes, 
            words = all_words), 
            null = null,
            line_id = line_id)
end

function sign_intervals(sign_index::Int, sequence)
    @unpack dict, id2string, sequence, symbols, line_id = sequence
    sign_line_id = -1
    for k in keys(symbols)
        if id2string[sign_index] in getfield(symbols,k)
            sign_line_id = getfield(line_id,k)
            break
        end
    end
    if sign_line_id == -1
        throw(ErrorException("Sign index not found"))
    end

    intervals = Vector{Vector{Float32}}()
    cum_duration = cumsum(sequence[line_id.duration,:])
    _end = 1
    interval = [-1, -1]
    my_seq = sequence[sign_line_id, :]
    while !isnothing(_end)  || !isnothing(_start)
        _start = findfirst(x -> x == sign_index, my_seq[_end:end])
        if isnothing(_start)
            break
        else
            _start += _end-1
        end
        _end  = findfirst(x -> x != sign_index, my_seq[_start:end]) + _start - 1
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

## create a random sequence of words with respective phones
function get_words(
    seq_length::Int,
    dictionary::Dict{Symbol, Vector{Symbol}},
    null_symbol::Symbol;
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

export generate_sequence, get_words, sign_intervals, time_in_interval, sequence_end