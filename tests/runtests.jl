using SpikingNeuralNetworks
using Test
SNN.@load_units

##
if VERSION > v"1.1"
    include("ctors.jl")
end
include("Duarte2019.jl")
include("LKD.jl")
