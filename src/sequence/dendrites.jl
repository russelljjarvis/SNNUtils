
"""
	dendritic_connections(type::String, n_tripods::Int64, stim::StimParams)

Connect stimuli to the dendrites and return handles

# Arguments:
type : _symmetric_ or _asymmetric_

n_tripods : number of tripods

stim : stimulus properties
"""

function dendritic_connections(type::String, n_tripods::Int64, stim::AbstractStimParams)
    connections = Vector{Vector{Int64}}()
    dendrites = Vector{Array{Float32,2}}()
    for sym = 1:stim.symbols
        ## For each input cell get a target population of tripods
        target_neurons = rand(1:n_tripods, round(Int, stim.density * n_tripods))
        ## each input cell act asymettrically/simmetrically on each of the target cell
        if type == "asymmetric"
            INPUT = ([0, stim.strength], [stim.strength, 0])
        elseif type == "symmetric"
            INPUT = (
                [stim.strength / 2, stim.strength / 2.0],
                [stim.strength / 2.0, stim.strength / 2],
            )
        end
        target_dendrites = hcat(rand(INPUT, length(target_neurons))...)
        ## and to the soma
        push!(connections, target_neurons)
        push!(dendrites, target_dendrites)
    end
    return connections, dendrites
end
