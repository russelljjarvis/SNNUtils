@with_kw mutable struct NNStates
	mem::Matrix{Float32}= zeros(Float32,1,1)
	cur::Matrix{Float32}= zeros(Float32,1,1)
	labels::Matrix{Int64}= zeros(Int,1,1)
	tt::Float32=-1.f0
	file::String=""
	_read::Bool=false
end

@with_kw mutable struct NNWeights{T_Weights}
	w::T_Weights
	tt::Float32=0.f0
	file::String=""
	_read::Bool=false
end

@with_kw mutable struct NNTracker{T_Tracker}
	tracker::T_Tracker
	tt::Float32=0.f0
	file::String=""
	_read::Bool=false
end
