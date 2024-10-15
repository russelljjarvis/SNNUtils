@with_kw struct Encoding
    populations::Array{Vector{Int64},1} # each symbol target population
    dendrites::Array{Array{Float32,2},1} # the dendrite of the target population
    sequence::Array{Int64,2} #the sequence of symbols
    mapping::Dict
    rev_mapping = Dict(x[2] => x[1] for x in mapping)
    lemmas::Dict
    null::Int
    duration::Union{Int64,Float32,Vector{Float32}}
end
