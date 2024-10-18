## Clustering analysis with hierarchical clustering algorithm
using Clustering
function clustering_ee(matrix::Array{Float32,2})
    hclu = hclust(1 ./ (matrix[:, :] .+ 0.001), :average, :U)
    nodes = cutree(hclu, k = 16)
    cols = sort!([1:size(matrix, 2);], by = i -> (nodes))
    return nodes, cols
end


## Get total val

function global_weights(ws::Array, weights_name::Vector{String})
    w_t = NamedTuple(
        Symbol(name) => Array{Float32,1}(undef, length(ws)) for name in weights_name
    )
    for (n, w) in enumerate(ws)
        for name in weights_name
            getfield(w_t, Symbol(name))[n] = mean(read(w, name))
        end
    end
    return w_t
end


## Clustering of excitatory populations

function epop_cluster_history(seq::Encoding, ws::Array, conn::String)
    n_pop = length(filter(!isempty, seq.populations))
    w_t = zeros(length(ws), n_pop, n_pop)
    iterations = ProgressBar(eachindex(ws))
    for n in iterations
        w_t[n, :, :] .= epop_cluster(seq, read(ws[n], conn))
    end
    return w_t
end


function epop_cluster(seq::Encoding, ee::Array{Float32,2})
    populations = filter(x -> !isempty(x), seq.populations)
    _weights = zeros(length(populations), length(populations))
    for (n, pop1) in enumerate(populations)
        for (m, pop2) in enumerate(populations)
            _weights[n, m] = mean(ee[pop1, pop2][ee[pop1, pop2] .> 0])
        end
    end
    return _weights
end


## Clustering between phonemes and words

function epop_cross_history(seq::Encoding, ws::Array, conn::String)
    w_t = zeros(length(ws), length(get_words(seq)), 2)
    for (n, w) in enumerate(ws)
        dictionary = epop_cross(seq, read(w, conn))
        dictionary_rev = epop_cross(seq, read(w, conn), adjoin = true)
        for k in keys(dictionary)
            w_t[n, k, 1] = mean(dictionary[k])
            w_t[n, k, 2] = mean(dictionary_rev[k])
        end
    end
    return w_t
end

function epop_cross(seq::Encoding, ee::Matrix{Float32}; adjoin::Bool = false)
    dictionary = Dict()
    adjoin && (ee = ee')
    couples = word_phonemes_couples(seq)
    for (w, phs) in couples
        targets = zeros(size(phs))
        for (n, ph) in enumerate(phs)
            z = mean(ee[seq.populations[w], seq.populations[ph]])
            targets[n] = z / mean(ee[:, seq.populations[ph]])
        end
        push!(dictionary, w => targets)
    end
    return dictionary
end

# function ipop_cluster(seq::Encoding,  W::Array)
# 	ave_weights = Vector{Float32}()
# 	for pop in seq.populations
# 		z = 0.
# 		for pre in pop
# 			for post in pop
# 				z += W[post,pre,3]
# 			end
# 		end
# 		push!(ave_weights,z/sum(W.e_e[pop,:,3]))
# 	end
# 	return ave_weights
# end


function word_phonemes_couples(seq::Encoding)
    couples = []
    reverse = reverse_dictionary(seq.mapping)
    for key in keys(seq.lemmas)
        phonemes = []
        for ph in seq.lemmas[key]
            push!(phonemes, reverse[ph])
        end
        if !isempty(phonemes)
            push!(couples, [reverse[key], phonemes])
        end
    end
    return couples
end

function check_seq_consistency(seq::Encoding)
    n = 1
    N = length(seq.sequence[1, :])
    while n < N
        phonemes = Vector{SubString{String}}()
        w = seq.sequence[1, n]
        L = length(seq.lemmas[seq.mapping[w]])
        l = 0
        while seq.sequence[1, n] == w && n < N && l < L
            push!(phonemes, seq.mapping[seq.sequence[2, n]])
            n += 1
            l += 1
        end
        if n < N
            @assert(cmp(seq.lemmas[seq.mapping[w]], phonemes) == 0)
        end
    end
end
