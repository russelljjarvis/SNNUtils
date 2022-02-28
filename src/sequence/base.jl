dic_path = joinpath(dirname(dirname(@__DIR__)),"data","dictionaries")
include("structs.jl")
include("dendrites.jl")
include("encodings.jl")
include("lexicons.jl")


function get_track_neurons(seq)
	track_neurons = Vector{Int64}()
	for i in get_phonemes(seq)
		push!(track_neurons,seq.populations[i][1])
	end
	push!(track_neurons,1) # first sst / pv
	push!(track_neurons,2) # second sst / pv
end

export get_track_neurons
