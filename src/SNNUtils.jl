module SNNUtils

using SpikingNeuralNetworks
SNN.@load_units
using DrWatson
using Parameters
using Random
using Distributions
using Printf
using JLD
using Serialization
using Dates
using BSON
using JSON
using ThreadTools
using RollingFunctions
using StatsBase
using Statistics


include("structs.jl")
include("IO/base.jl")
include("stimuli/base.jl")
include("models/models.jl")
include("analysis/performance.jl")
include("analysis/classifiers.jl")


end # module
