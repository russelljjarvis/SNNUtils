using MLDataUtils
using MLJLinearModels

function make_set_index(y::Int64, ratio::Float64)
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

function labels_to_y(labels)
    _labels = collect(Set(labels))
    z = zeros(Int, maximum(_labels))
    z[_labels] .= 1:length(_labels)
    return z[labels]
end

function MultinomialLogisticRegression(
    X::Matrix{Float64},
    labels::Array{Int64};
    λ = 0.5::Float64,
    test_ratio = 0.5,
)
    n_classes = length(Set(labels))
    y = labels_to_y(labels)
    n_features = size(X, 1)

    train, test = make_set_index(length(y), test_ratio)
    @show length(test) + length(train)
    @show length(train)

    train_std = StatsBase.fit(ZScoreTransform, X[:, train], dims = 2)
    StatsBase.transform!(train_std, X)
    intercept = false
    X[isnan.(X)] .= 0

    # deploy MultinomialRegression from MLJLinearModels, λ being the strenght of the reguliser
    mnr = MultinomialRegression(λ; fit_intercept = intercept)
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
