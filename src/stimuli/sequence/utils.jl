## Get specifics of the encoding

"""
    get_phonemes(seq::Encoding)

    Return the phonemes of the sequence.
    Parameters
    ----------
    seq: Encoding
        The sequence encoding
    Returns
    -------
    phonemes: Vector{Int}
        The phonemes of the sequence.
"""
function get_phonemes(seq::Encoding)
    # all_phonemes = sort(vcat(values(seq.lemmas)...))
    all_phonemes = collect(Set(vcat(values(seq.lemmas)...)))
    ph_indices = Vector{Int}()
    for k in keys(seq.rev_mapping)
        if k ∈ all_phonemes
            push!(ph_indices, seq.rev_mapping[k])
        end
    end
    return sort(ph_indices)
end

"""
        phonemes_populations(seq, word=nothing)

    Return the populations of the phonemes of a word or all the phonemes of the sequence.
    Parameters
    ----------
    seq: Encoding
        The sequence encoding
    word: String
        The word to get the phonemes from. If nothing, return all the phonemes of the sequence.
    Returns
    -------
    populations: Vector{Int}
        The populations of the phonemes of the word or the sequence.
"""
function phonemes_populations(seq, word = nothing; unique = false)
    if isnothing(word)
        phs = [x for x in TNN.get_phonemes(seq)]
    else
        phs = [seq.rev_mapping[x] for x in TNN.get_contained_phonemes(word, seq)]
    end
    return populations(phs, seq, unique)
end

function words_populations(seq, ; unique = false)
    words = [x for x in TNN.get_words(seq)]
    return populations(words, seq, unique)
end

"""
    is_phoneme(seq::Encoding)
    
    Return true if the index is a phoneme.
"""
function is_phoneme(index::Int, seq::Encoding)
    if index ∈ get_phonemes(seq)
        return true
    else
        return false
    end
end


"""
    is_word(seq::Encoding)
    
    Return true if the index is a word.
"""
function is_word(index::Int, seq::Encoding)
    if index ∈ get_words(seq)
        return true
    else
        return false
    end
end

"""
    get_contained_signs(index::Int, seq::Encoding)
    
    Return
    ------
    Vector{Int} with the signs contained in a phoneme or the phonemes contained in a word.
"""
function get_contained_signs(index::Union{Int,String,Char}, seq::Encoding)
    index = isa(index, Int) ? index : seq.rev_mapping[index]
    rev = reverse_dictionary(seq.mapping)
    if is_phoneme(index, seq)
        phoneme = seq.mapping[index]
        return [rev[x] for x in get_containing_words(phoneme, seq)]
    elseif is_word(index, seq)
        word = seq.mapping[index]
        return [rev[x] for x in get_contained_phonemes(word, seq)]
    else
        @error "Index is not a phoneme or a word"
    end
end

"""
    get_containing_words(phoneme::Union{String,Char}, seq::Encoding)
    
    Return all the words containing a phoneme.
"""
function get_containing_words(phoneme::Union{String,Char}, seq::Encoding)
    words = Vector{String}()
    for (word, phonemes) in seq.lemmas
        if phoneme ∈ phonemes
            push!(words, word)
        end
    end
    return words
end

"""
    get_contained_phonemes(word::String, seq::Encoding)
    
    Return all the phonemes contained in a word.
"""
function get_contained_phonemes(word::String, seq::Encoding)
    return seq.lemmas[word]
end


"""
    get_words(seq::Encoding)

    Return the words of the sequence.
    Parameters
    ----------
    seq: Encoding
        The sequence encoding
    Returns
    -------
    words: Vector{Int}
        All the words of the sequence.
"""
function get_words(seq::Encoding)
    all_words = collect(Set(vcat(keys(seq.lemmas)...)))
    w_indices = Vector{Int}()
    for k in keys(seq.rev_mapping)
        if k ∈ all_words
            push!(w_indices, seq.rev_mapping[k])
        end
    end
    return sort(w_indices)
end

word_indices(seq::Encoding) = get_words(seq::Encoding)

"""
    load_dictionary(file)
    
    Load a dictionary from a file.
"""
function load_dictionary(file)
    dictionary = DrWatson.load(datadir("dictionaries", file)) |> dict2ntuple
    @unpack name, words = dictionary
    return name, words
end

"""
    dict_name(file)
    
    Return the name of the dictionary
"""
function dict_name(file)
    dictionary = DrWatson.load(datadir("dictionaries", file)) |> dict2ntuple
    @unpack name, words = dictionary
    return name
end

## Analysis of the results and plots encoding

"""
    get_ticks(seq::Encoding)

    Return the ticks of the sequence.
    Parameters
    ----------
    seq: Encoding
        The sequence encoding
    Returns
    -------
    ticks: Tuple{Vector{Int}, Vector{Int}}
        The ticks of the sequence.
"""
function get_ticks(seq::Encoding)
    _words = sort(get_words(seq), by = x -> seq.mapping[x])
    _phonemes = sort(get_phonemes(seq), by = x -> seq.mapping[x])
    indices = sorted_indices(seq)
    (
        ph = (1:length(get_phonemes(seq)), string.([seq.mapping[x] for x in _phonemes])),
        w = (get_words(seq), string.([seq.mapping[x] for x in _words])),
        all = (1:length(indices), string.([seq.mapping[x] for x in indices])),
    )
end

ticks(seq::Encoding) = get_ticks(seq)

""""
    get__labels(seq::Encoding)

    Return the labels of the sequence.
    Return
    ------
    labels: NamedTuple{(:phonemes, :words), Tuple{Vector{String}, Vector{String}}}
        The labels of the sequence.
"""
function labels(seq::Encoding, iis = nothing)
    _words = sort(get_words(seq), by = x -> seq.mapping[x])
    _phonemes = sort(get_phonemes(seq), by = x -> seq.mapping[x])
    # get_words(seq)]...
    if isnothing(iis)
        return (
            ph = string.(hcat([seq.mapping[x] for x in _phonemes]...))[1, :],
            w = string.(hcat([seq.mapping[x] for x in _words]...))[1, :],
        )
    else
        return [seq.mapping[i] for i in iis]
    end
end

function input(seq::Encoding)
    return [seq.mapping[x] for x in seq.sequence]
end

# function words(seq::Encoding)
# 	[x >0 ? x : seq.null for x in seq.sequence[1,:]]
# end
# function phonemes(seq::Encoding)
# 	[x >0 ? x : seq.null for x in seq.sequence[1,:]]
# end

# Return word and phoneme signs at the defined point in time
function get_signs_at_time(time::Real, seq::Encoding)
    @unpack duration, sequence = seq
    element = round(Int, ceil(time / duration))
    if element > 0 && element < size(sequence, 2)
        return sequence[:, element]
    else
        return [seq.null, seq.null]
    end
end

function get_sign_at_time(time::Real; seq::Encoding, dim::Int)
    return get_signs_at_time(time, seq)[dim]
end



#Return all the indices in the sequence where the words end
function word_offsets(seq)
    all_words = Vector{Vector{Int64}}()
    for w in TNN.words(seq, indices = true)
        all_n = seq.sequence[1, :] .== w
        final = Vector{Int}()
        for i in eachindex(all_n[1:(end-1)])
            # @show all_n[i] all_n[i+1] 
            (all_n[i] && !all_n[i+1]) && (push!(final, i))
        end
        push!(all_words, final)
    end
    return all_words
end

function word_offsets(seq, sampling::Int)
    offsets = word_offsets(seq)
    n = seq.duration / sampling
    return [round.(Int, x .* n) for x in offsets]
end

seq_length(seq) = size(seq.sequence, 2)

# Return all intervals that contain a certain phoneme
function get_phoneme_intervals(phone_index::Int, seq::Encoding)
    phone_collect = Vector{Vector{Float32}}()
    phone_indices = Vector{Int64}()
    interval = [-1, -1]
    for pp in eachindex(seq.sequence[2, :])
        p = seq.sequence[2, pp]
        if p == phone_index
            interval[1] = (pp - 1) * seq.duration
            interval[2] = pp * seq.duration
            push!(phone_collect, copy(interval))
            push!(phone_indices, copy(pp))
        end
    end
    return phone_collect, phone_indices
end


function get_intervals(index::Int, seq::Encoding)
    if index in get_phonemes(seq)
        return get_phoneme_intervals(index, seq)
    elseif index in get_words(seq)
        return get_word_intervals(index, seq)
    else
        throw(ErrorException("The index $index is not a phoneme nor a word"))
    end
end

function get_intervals(sign::Union{String,Char}, seq::Encoding)
    get_intervals(seq.rev_mapping[sign], seq)
end

#return sequence indices that correspond to a certain time-interval
function seq_in_interval(seq, interval)
    x0 = findfirst(x -> (x - 1) * seq.duration >= interval[1], 1:length(seq.sequence[1, :]))
    xl = findlast(x -> x * seq.duration < interval[2], 1:length(seq.sequence[1, :]))
    return x0:xl
end

function get_phoneme_order(seq)
    words_phonemes = Vector{Vector{Int}}(undef, length(seq.lemmas))
    for (k, v) in seq.lemmas
        words_phonemes[seq.rev_mapping[k]] = [seq.rev_mapping[x] for x in v]
    end
    return words_phonemes
end

## find the first phoneme that make the word unique in the dictionary
function get_recognition_points(words::Vector, phonemes::Vector)
    recognition_point = []
    for x in eachindex(words)
        word_phs = phonemes[x]
        other_words = deepcopy(phonemes)
        popat!(other_words, x)
        # word = words[x]
        # @info words[x]
        for ord = 1:length(word_phs)
            sub_string = join(word_phs[1:ord])
            overlap = map(other_words) do x
                if length(x) >= ord
                    word = join(x[1:ord])
                    word == sub_string
                else
                    false
                end
            end |> any
            if overlap
                if ord == length(word_phs)
                    push!(recognition_point, length(word_phs) + 1)
                    # @info ord+1, sub_string, overlap
                    break
                end
                continue
            else
                push!(recognition_point, ord)
                # @info ord, sub_string, overlap
                break
            end
        end
    end
    return recognition_point
end

function get_recognition_points(seq::Encoding; sorted = false)
    words = TNN.words(seq, sorted = sorted)
    phonemes = [seq.lemmas[x] for x in words]
    return get_recognition_points(words, phonemes)
end

function get_recognition_points(dictionary::Dict{String,Any})
    words = dictionary["words"]
    return get_recognition_points(collect(keys(words)), collect(values(words)))
end


function get_recognition_points(seq::Encoding, sign::String; sorted = true)
    if sign == "phonemes"
        indices = phonemes(seq, sorted = sorted, indices = true)
        recognition_points = ones(length(indices))
    elseif sign == "words"
        indices = words(seq, sorted = sorted, indices = true)
        recognition_points = get_recognition_points(seq, sorted = sorted)
    else
        throw(ErrorException("Set 'words' or 'phonemes' as target sign"))
    end
    # @debug "up", recognition_points
    # @debug "words:", [seq.mapping[i] for i in indices]
    return recognition_points
end


function get_sign_indices(sign::String, seq::Encoding; sorted = false)
    if sign == "phonemes"
        indices = phonemes(seq, sorted = false, indices = true)
    elseif sign == "words"
        indices = words(seq, sorted = false, indices = true)
    else
        throw(ErrorException("Set 'words' or 'phonemes' as target sign"))
    end
    return indices
end

function get_indices(seq::Encoding)
    vcat(get_phonemes(seq)..., get_words(seq))
end

function get_index(id::Union{String,Char}, seq::Encoding; sorted = false)
    return indexin(seq.rev_mapping[id], TNN.indices(seq, sorted = sorted))[1]
end

function get_index(ids::Vector, seq::Encoding; sorted = false)
    return indexin([seq.rev_mapping[id] for id in ids], TNN.indices(seq, sorted = sorted))
end

function words(seq::Encoding; sorted = false, indices = false)
    if sorted
        w_ = sorted_words(seq)
    else
        w_ = get_words(seq)
    end
    if indices
        return w_
    else
        return [seq.mapping[x] for x in w_]
    end
end

function phonemes(seq::Encoding; sorted = false, indices = false)
    if sorted
        p_ = sorted_phonemes(seq)
    else
        p_ = get_phonemes(seq)
    end
    if indices
        return p_
    else
        return [seq.mapping[x] for x in p_]
    end
end

function sorted_words(seq)
    return sort(get_words(seq), by = x -> seq.mapping[x])
end
function sorted_phonemes(seq)
    return sort(get_phonemes(seq), by = x -> seq.mapping[x])
end

function indices(seq::Encoding; sorted = false)
    if !sorted
        return sort(collect(filter(x -> seq.mapping[x] !== "_", keys(seq.mapping))))
    else
        sorted_indices(seq)
    end
end

function sorted_indices(seq)
    words = sort(get_words(seq), by = x -> seq.mapping[x])
    phonemes = sort(get_phonemes(seq), by = x -> seq.mapping[x])
    return vcat(words, phonemes)
end

function get_sign(id, seq; sorted = false)
    i = nothing
    if sorted
        i = findfirst(id .== indices(seq; sorted = true))
    else
        i = findfirst(id .== indices(seq))
    end
    return seq.mapping[i]
end

function get_signs(seq; sorted = false)
    signs = []
    for x in indices(seq, sorted = sorted)
        push!(signs, get_sign(x, seq, sorted = sorted))
    end
    return signs
end

function print_words(seq)
    phs = [seq.mapping[x] for x in seq.sequence[2, :]]
    words = [seq.mapping[x] for x in seq.sequence[1, :]]
    for (x, y) in zip(phs, words)
        print(y, " ", x, "\n")
    end
end
