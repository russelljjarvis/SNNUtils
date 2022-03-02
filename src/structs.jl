Spiketimes = Vector{Vector{Float32}}

abstract type SNNDataTypes end
abstract type AbstractTracker end

struct Weights <:SNNDataTypes
	data::NamedTuple
end
struct States<:SNNDataTypes end
struct Spikes<:SNNDataTypes end
struct Rates <:SNNDataTypes end

function Base.getproperty(mnt::Weights, sym::Symbol)
   return getfield(getfield(mnt,:data), sym)
end
function Base.fieldnames(mnt::Weights)
	return fieldnames(typeof(getfield(mnt,:data)))
end
# function Base.fieldnames(Weights)
# 	return fieldnames(typeof(getfield(mnt,:data)))
# end

function Base.getproperty(mnt::SNNData, sym::Symbol)
	if (sym in fieldnames(SNNData))
		return getfield(mnt, sym)
    else
       return getfield(getfield(mnt,:data), sym)
   end
end

# c =Weights((a=2,b=4))
# fieldnames(Weights)
#
# using UnPack
# # @unpack a, b =c
