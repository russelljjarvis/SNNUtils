module SNNUtils
	
using Parameters
using SpikingNeuralNetworks
SNN = SpikingNeuralNetworks

@SNN.load_units

include("base/structs.jl")
include("base/dendrites.jl")
# include("base/tripod.jl")

end # module
