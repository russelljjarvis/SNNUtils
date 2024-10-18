## Divide the input time in 5 blocks
N_POINTS = 5

# Classification
function make_set_index(y::Int64, ratio::Float32)
    train, test = Vector{Int64}(), Vector{Int64}()
    ratio_0 = length(train) / y
    for index = 1:y
        # if !(index ∈ train)
        if rand() < ratio - ratio_0
            push!(train, index)
        else
            push!(test, index)
        end
    end
    return train, test
end

"""
For each batch extract spike rate and coeff. of variation
Return a single-array with all the features

"""
function spikes_to_features(spikes, input_duration::Int64, batch_duration::Real)
    ## get a sample-size feature map from 1 batch
    _feat = _spike_to_features(spikes[1], input_duration, batch_duration)
    #
    ## Assume all batches are the same
    n_samples = size(_feat)[2]
    n_feat = size(_feat)[1]
    features = zeros(Float32, n_feat, length(spikes) * n_samples)
    for (n, batch) in enumerate(spikes)
        features[:, (1+(n-1)*n_samples):(n*n_samples)] .=
            _spike_to_features(batch, input_duration, batch_duration)
    end
    return features, ceil(Int, n_feat / 2)
end
#
"""
Average the activity of each neuron in the stim_interval
Return CV and FR for all neuron in the batch, with this strcuture:

features = [
        ν  exc.
        ν  inh.
        CV exc.
        CV inh.
     ]

"""
function _spike_to_features(
    spikes::Union{Vector,Tuple},
    interval_duration::Int64,
    batch_duration,
)
    # num of neurons
    ss = readS(spikes)
    x_exc = size(ss[1])[1]
    x_sst = size(ss[2])[1]
    x_pv = size(ss[3])[1]

    interval = ceil(Int, batch_duration / dt)
    inputs = ceil(Int, batch_duration / interval_duration)
    # inputs  = ceil(Int,/interval)
    features = zeros(Float32, 2 * x_exc + 2 * (x_sst + x_pv), inputs)
    n_cells = x_exc + x_pv + x_sst
    for i = 1:inputs
        _init_time = ss[4] - batch_duration
        _interval = _init_time .+ (interval_duration * (i - 1), interval_duration * i)
        features[1:x_exc, i] .= get_spike_rate(ss[1], interval = _interval)
        features[x_exc .+ (1:x_sst), i] .= get_spike_rate(ss[2], interval = _interval)
        features[x_exc+x_sst .+ (1:x_pv), i] .= get_spike_rate(ss[3], interval = _interval)
        features[n_cells .+ (1:x_exc), i] .= get_CV(ss[1], interval = _interval)
        features[n_cells .+ x_exc .+ (1:x_sst), i] .= get_CV(ss[2], interval = _interval)
        features[n_cells .+ x_exc .+ x_sst .+ (1:x_pv), i] .=
            get_CV(ss[3], interval = _interval)
    end
    return features

end


function states_to_features(states::Vector{NNStates}; average_points = true)
    _feat = _state_to_features(states[1].mem, states[1].cur; average = average_points)
    n_neurons = size(states[1].mem)[1]
    n_samples = size(_feat)[2]
    n_feat = size(_feat)[1]
    features = zeros(Float32, n_feat, length(states) * n_samples)
    for (n, state) in enumerate(states)
        pos = (1+(n-1)*n_samples):(n*n_samples)
        features[:, pos] .=
            _state_to_features(state.mem, state.cur; average = average_points)
    end
    return features, n_neurons
end

function _state_to_features(
    membranes::Matrix{Float32},
    currents::Matrix{Float32};
    average::Bool = false,
)
    """ Pile up into a single feature vector the 5 samples of each stimulus interval.
    if  'average' do the average of the features over the 5 points, otherwise keep
    as individual points"""

    x = size(membranes)[1] * N_POINTS
    n = ceil(Int, size(membranes)[2] / N_POINTS)
    x = size(membranes)[1]
    if average
        m = mean(reshape(membranes, (x, N_POINTS, n)), dims = 2)[:, 1, :]
        c = mean(reshape(currents, (x, N_POINTS, n)), dims = 2)[:, 1, :]
        return vcat(m, c)
    else
        return feature = vcat(
            reshape(membranes, (x * N_POINTS, n)),
            reshape(currents, (x * N_POINTS, n)),
        )
    end
end

function labels_to_y(labels)
    _labels = collect(Set(labels))
    z = zeros(Int, maximum(_labels))
    z[_labels] .= 1:length(_labels)
    ## TODO

    return z[labels]
end

function MultiLogReg(
    X::SubArray{Float32,2,Matrix{Float32}},
    labels::Array{Int64};
    λ = 0.5f0::Float32,
    test_ratio = 0.7f0,
)

    n_classes = length(Set(labels))
    while length(labels) > size(X, 2)
        pop!(labels)
    end
    y = labels_to_y(labels)
    n_features = size(X, 1)

    train, test = make_set_index(length(y), test_ratio)

    train_std = StatsBase.fit(ZScoreTransform, X[:, train], dims = 2)
    StatsBase.transform!(train_std, X)
    intercept = false

    # deploy MultinomialRegression from MLJLinearModels, λ being the strenght of the reguliser
    mnr = MultinomialRegression(Float64(λ); fit_intercept = intercept)
    # Fit the model
    θ = MLJLinearModels.fit(mnr, X[:, train]', y[train])
    # # The model parameters are organized such we can apply X⋅θ, the following is only to clarify
    # Get the predictions X⋅θ and map each vector to its maximal element
    # return θ, X
    preds = MLJLinearModels.softmax(MLJLinearModels.apply_X(X[:, test]', θ, n_classes))
    targets = map(x -> argmax(x), eachrow(preds))
    #and evaluate the model over the labels
    scores = mean(targets .== y[test])
    params = reshape(θ, n_features + Int(intercept), n_classes)
    return scores, params
end

## There are two ways of doing the classification:
# 1. I can look at the whole network, and let the classifier find the relevant class.
# 2. I can look the spike rate of the target word and see if it differs from non target words. This is easy to implement


function score_features(;
    features::Matrix{Float32},
    n_neurons::Int64,
    seq::Encoding,
    idxs::Vector{Int},
    save_path::String,
    feats_set::NamedTuple,
)
    #labels idx for tt0

    ## Prepare labels and neurons

    ## Labels
    word_labels = seq.sequence[1, idxs]
    ph_labels = seq.sequence[2, idxs]
    wn_labels = length(Set(word_labels))
    pn_labels = length(Set(ph_labels))

    ## These neurons receive signal from the features
    @views word_neurons =
        sort(collect(Set(vcat(seq.populations[sort(collect(Set(word_labels)))]...))))
    @views ph_neurons =
        sort(collect(Set(vcat(seq.populations[sort(collect(Set(ph_labels)))]...))))

    ## These are features that corresponds to words only, the n_exc reflects the feature array
    word_only = vcat(word_neurons, word_neurons .+ n_neurons)
    ph_only = vcat(ph_neurons, ph_neurons .+ n_neurons)


    println("Run classifiers")

    ## Score words:
    rand_w_labels = word_labels[randperm(length(word_labels))]
    rand_p_labels = ph_labels[randperm(length(ph_labels))]

    h5open(save_path, "cw") do file
        fid = create_group(file, "words") # create a group
        scores = Dict()
        for key in keys(feats_set)
            @views score, θ = MultiLogReg(features[feats_set[key], :], word_labels)
            fid[string(key)] = θ
            push!(scores, string(key) => score)
        end
        @views score, θ = MultiLogReg(features[:, :], rand_w_labels)
        fid["random"] = θ
        push!(scores, "random" => score)
        @views score, θ = MultiLogReg(features[word_neurons, :], word_labels)
        fid["word_only"] = θ
        push!(scores, "word_only" => score)
        @views score, θ = MultiLogReg(features[ph_neurons, :], word_labels)
        fid["phs_only"] = θ
        push!(scores, "phs_only" => score)

        fid["scores"] = collect(values(scores))
        fid["labels"] = collect(keys(scores))
    end

    h5open(save_path, "cw") do file
        fid = create_group(file, "phonemes") # create a group
        scores = Dict()
        for key in keys(feats_set)
            @views score, θ = MultiLogReg(features[feats_set[key], :], ph_labels)
            fid[string(key)] = θ
            push!(scores, string(key) => score)
        end
        @views score, θ = MultiLogReg(features[:, :], rand_p_labels)
        fid["random"] = θ
        push!(scores, "random" => score)
        @views score, θ = MultiLogReg(features[word_neurons, :], word_labels)
        fid["word_only"] = θ
        push!(scores, "word_only" => score)
        @views score, θ = MultiLogReg(features[ph_neurons, :], word_labels)
        fid["phs_only"] = θ
        push!(scores, "phs_only" => score)

        fid["scores"] = collect(values(scores))
        fid["labels"] = collect(keys(scores))
    end

    # @views _rate,   param_rate  = MultinomialLogisticRegression(features[1:n_neurons,:],ph_labels)
    # @views _cv,   param_cv      = MultinomialLogisticRegression(features[n_neurons+1:end,:],ph_labels)
    # @views _word,  param_word = MultinomialLogisticRegression(features[word_only,:],ph_labels)
    # @views _ph,  param_ph = MultinomialLogisticRegression(features[ph_only,:],ph_labels)
    # @views _cv_rate, param_cv_rate = MultinomialLogisticRegression(features[:,:],ph_labels)
    # @views _rnd, param_rnd      = MultinomialLogisticRegression(features[:,:], rand_p_labels)
    #
    # h5open(save_path, "cw") do file
    #     fid = create_group(file, "phonemes") # create a group
    #     fid["rate"] = param_rate
    #     fid["cv"] = param_cv
    #     fid["cv_rate"] = param_cv_rate
    #     fid["rnd"] = param_rnd
    #     fid["word"] = param_word
    #     fid["ph"] = param_ph
    #     fid["scores"] = [_rate, _cv,  _cv_rate, _word, _ph, _rnd ]
    #     fid["labels"] = ["rate", "cv","cv_rate", "word", "ph", "rnd"]
    # end
end
