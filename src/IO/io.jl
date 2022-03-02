@with_kw mutable struct SNNData{T}
	data = NamedTuple()
	type::DataType = T
	tt::Float32=-1.f0
	file::String=""
	_read::Bool=false
end

export SNNData, States, Spikes, Rates, Weights, Spiketimes
export SNNDataTypes, AbstractTracker



##

#
# import Base.typeof
#
# typeof(NNDat)
#
# @with_kw mutable struct NNWeights
# 	w::AbstractWeights = AbstractWeigths()
# 	tt::Float32=-1.f0
# 	file::String=""
# 	_read::Bool=false
# end
#
# @with_kw mutable struct NNTracker
# 	tracker::AbstractTracker = T()
# 	tt::Float32=-1.f0
# 	file::String=""
# 	_read::Bool=false
# end
#
# @with_kw mutable struct NNSpikes
# 	spikes = NamedTuple()
# 	# exc::Spiketimes= Spiketimes()
# 	# pv::Spiketimes =Spiketimes()
# 	# sst::Spiketimes=Spiketimes()
# 	tt::Float32=-1.f0
# 	file::String=""
# 	_read::Bool=false
# end
#
# export AbstractWeights,AbstractTracker
# export Spiketimes, NNStates, NNWeights, NNTracker, NNSpikes
#
#
# A <: Tuple
#
# B = Tuple
#
# a = A(1=>3)
# b = B(2=>1)
#
# getmine(t::A) = print(t[1])
# getmine(t::B) = print(t[2])
#
# struct Z<:AbstractWeights end
# getmine(b)
#
# struct TEST<:NamedTuple end
