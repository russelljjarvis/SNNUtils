module SNNUtils

using SpikingNeuralNetworks
SNN.@load_units
using DrWatson
using Parameters
using Random
using Distributions
using Printf
using JLD
using HDF5
using Serialization
using Dates
using BSON
using ThreadTools

include("structs.jl")
include("IO/base.jl")
include("analysis/base.jl")
include("stimuli/base.jl")

# include("sequence/base.jl")

# include("synapses/base.jl")
# include("neurons/base.jl")
# include("plots/base.jl")

# using Requires
# function __init__()
#     @require Plots="91a5bcdd-55d7-5caf-9e0b-520d859cae80"
# end
#


end # module
