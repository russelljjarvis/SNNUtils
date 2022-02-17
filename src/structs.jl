Spiketimes = Vector{Vector{Float32}}
abstract type AbstractWeights end
abstract type AbstractTracker end

@with_kw mutable struct NNStates
	mem::Matrix{Float32}= zeros(Float32,1,1)
	cur::Matrix{Float32}= zeros(Float32,1,1)
	labels::Matrix{Any}
	tt::Float32=-1.f0
	file::String=""
	_read::Bool=false
end

@with_kw mutable struct NNWeights
	w::AbstractWeights
	tt::Float32=-1.f0
	file::String=""
	_read::Bool=false
end

@with_kw mutable struct NNTracker
	tracker::AbstractTracker
	tt::Float32=-1.f0
	file::String=""
	_read::Bool=false
end

@with_kw mutable struct NNSpikes
	exc::Spiketimes= Spiketimes()
	pv::Spiketimes=Spiketimes()
	sst::Spiketimes=Spiketimes()
	tt::Float32=-1.f0
	file::String=""
	_read::Bool=false
end

export AbstractWeights,AbstractTracker
export Spiketimes, NNStates, NNWeights, NNTracker, NNSpikes
