
function average_firing_rate(E, start=0ms, stop=10ms) # in milliseconds
    num_bins = Int(length(E.records[:fire]) / bin_width)
    bin_edges = 1:bin_width:(num_bins * bin_width)
    # avg spikes at each time step
    E_neuron_spikes = map(sum, E.records[:fire]) ./ E.N
    I_neuron_spikes = map(sum, I.records[:fire]) ./ E.N
    # Count the number of spikes in each bin
    E_bin_count = [sum(E_neuron_spikes[i:i+bin_width-1]) for i in bin_edges]
    I_bin_count = [sum(I_neuron_spikes[i:i+bin_width-1]) for i in bin_edges]
    return mean(E_bin_count), mean(I_bin_count)
end

function evaluate(model)
    all_spiketimes = spiketimes(p)
    spiketimes_pop = all_spiketimes[pop] 
end