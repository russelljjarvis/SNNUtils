using Random
using Distributions
using Logging
using Printf


module TripodNeuron
    import ..Logging, ..Printf, ..Distributions
    using BenchmarkTools
    using Logging, Printf, Distributions
    # include("TripodNeuron/base/structs/dendrites.jl")
    include("TripodNeuron/base.jl")
end
TN = TripodNeuron
##
function TripodTest(TN)
    TN.Tripod()

    # mini tests
    v = TN.run_simulation(TN.null_input)
    @assert(abs(mean(v[1][1,:])- TN.AdEx.Er) <1)

    v = TN.simulate_neuron(TN.SST(),  TN.null_input)
    @assert(abs(mean(v[1][:])- TN.LIF_sst.Er) <1)

    v = TN.simulate_neuron(TN.PV(), TN.null_input)
    @assert(abs(mean(v[1][:])- TN.LIF_pv.Er) <1)

    print("Tripod model loaded successfully")

    function constant_firing()
        tripod = TN.Tripod()
        spiked = false
        currents = [0., 0., 0.]
        v = Vector()
        for i in 1:1000
            TN.exc_spike!(tripod.s)
            spiked = TN.update_tripod!(tripod, currents, spiked)
            push!(v,tripod.s.v)
        end
        tripod = TN.SST()
        spiked = false
        v = Vector()
        for i in 1:1000
            TN.exc_spike!(tripod)
            spiked = TN.update_lif_sst!(tripod, spiked)
            push!(v,tripod.v)
        end
    end
    constant_firing()

end

TripodTest(TN)
##
