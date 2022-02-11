struct SeqEncoding
    populations::Array{Vector{Int64},1}
    dendrites::Array{Array{Float32,2},1}
    sequence::Array{Int64,2}
	mapping::Dict
	lemmas::Dict
	null::Int
    # pops_to_symbol::Array{Int64,1}
    # symbol_to_pop::Array{Array{Int64,1},1}
end
