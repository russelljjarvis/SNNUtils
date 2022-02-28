abstract type Encoding end

struct SeqEncoding <: Encoding
    populations::Array{Vector{Int64},1}
    dendrites::Array{Array{Float32,2},1}
    sequence::Array{Int64,2}
	mapping::Dict
	lemmas::Dict
	null::Int
end

export Encoding, SeqEncoding
