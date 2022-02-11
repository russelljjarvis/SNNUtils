using Unitful
using Distributions
using Plots
using JLD

#=====================================
            Import Parameters
=====================================#
include("base/tripod/synapses.jl");
include("base/tripod/tripod.jl");
include("parameters.jl");
include("base/tripod/equations.jl");
#=====================================
            Import Simulation
=====================================#
include("base/simulation/protocols.jl")
include("base/simulation/simulation.jl")
include("simplified_model/simulation.jl")

#=====================================
            Import analysis
=====================================#
include("base/analysis/spike_analysis.jl")
#=====================================
            Import plotting
=====================================#
include("base/inhibitory_neurons/neurons.jl");
include("base/inhibitory_neurons/equations.jl");

include("base/static_params.jl");
#=====================================
            Import plotting
=====================================#
include("base/io/plotting.jl")
include("base/io/print_parameters.jl")

using JLD
balance_models = load(joinpath(@__DIR__,"optimal_kies_rate.jld"),"len")
balance_rates = load(joinpath(@__DIR__,"optimal_kies_rate.jld"),"νs")
balance_kie_rate    = load(joinpath(@__DIR__,"optimal_kies_rate.jld"),"kie")
balance_kie_gsyn    = load(joinpath(@__DIR__,"optimal_kies_gsyn.jld"),"kie")'
balance_kie_soma    = load(joinpath(@__DIR__,"optimal_kies_soma.jld"),"kie")
