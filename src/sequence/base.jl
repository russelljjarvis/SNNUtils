dic_path = joinpath(dirname(dirname(@__DIR__)), "data", "dictionaries")
include("structs.jl")
include("dendrites.jl")
include("encodings.jl")
include("lexicons.jl")


function get_track_neurons(seq)
    track_neurons = Vector{Int64}()
    for i in get_phonemes(seq)
        push!(track_neurons, seq.populations[i][1])
    end
    push!(track_neurons, 1) # first sst / pv
    push!(track_neurons, 2) # second sst / pv
end

function seq_in_interval(seq, interval)
    x0 = findfirst(x -> (x - 1) * seq.duration >= interval[1], 1:length(seq.sequence[1, :]))
    xl = findlast(x -> x * seq.duration < interval[2], 1:length(seq.sequence[1, :]))
    return x0:xl
end

export get_track_neurons, seq_in_interval
