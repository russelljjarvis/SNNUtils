function analysis_path(path)
    println("worker: $(getpid())")
    stim, seq, net, dends, learn, store = read_network_params(path)
    network = read_network_weights(store.data, cache = false)
    spikes = read_network_spikes(store.data, cache = false)
    analysis_path = get_path(store, "analysis")


    # Weight analysis
    wd1 = epop_cluster_history(seq, network, "e_d1_e")
    wd2 = epop_cluster_history(seq, network, "e_d2_e")
    wd3 = epop_cluster_history(seq, network, "e_s_e")
    joinpath(analysis_path, "pop_weights.jld") |>
    x -> save(x, "d1", wd1, "d2", wd2, "s", wd3)

    ## Rate analysis
    population_activity(path = store.path)
    score_membrane(path = store.path)
    score_spikes(path = store.path)
end
