"""
    al;pha_function(t::T; t0::T, τ::T) where T <: AbstractFloat

    Alpha function for convolution of spiketimes. Evaluate the alpha function at time t, with time of peak t0 and time constant τ.
"""
function alpha_function(t::T; t0::T, τ::T) where {T<:Float32}
    return @fastmath 1 / τ * SNN.exp32(1 - (t - t0) / τ) * Θ(1.0 * (t - t0))
end
"""
    Θ(x::Float64)

    Heaviside function
"""
Θ(x::Float64) = x > 0.0 ? x : 0.0

"""
    convolve(spiketime::Vector{Float32}; interval::AbstractRange, τ = 100)

    Convolve one neuron spiketimes with alpha function to have an approximate rate.

    Parameters
    ----------
    spiketime: Vector{Float32}
        Vector of spiketimes in milliseconds
    interval: AbstractRange
        Time interval to evaluate the rate
    τ: Float32
        Time constant of the alpha function
    Return
    ------
    rate: Vector{Float32}
        Vector of rates in Hz
"""
function convolve(spiketime::Vector{Float32}; interval::AbstractRange, τ = 100.0f0)
    rate = zeros(Float32, length(interval))
    @inbounds for i in eachindex(interval)
        v = 0
        t = Float32(interval[i])
        τ = Float32(τ)
        @simd for t0 in spiketime
            @fastmath if (t > t0 && ((t - t0) / τ) < 10)
                v += alpha_function(t, t0 = t0, τ = τ)
            end
        end
        rate[i] = v
    end
    return rate ## Hz
end

"""
    merge_spiketimes(spikes::Vector{NNSpikes}; type=:exc, pop=nothing, cache=false, kwargs...)

    Merge the spiketimes of a vector of NNSpikes into a single vector of spiketimes. The spiketimes are sorted by neuron id.

    Parameters
    ----------
    spikes::Vector{NNSpikes}
        Vector of NNSpikes
    type::Symbol
        Type of spiketimes to merge, :exc or :inh
    pop::Union{Nothing, Symbol, AbstractVector}
        Population of neurons to merge, :ALL for the entire network
    cache::Bool
        If true, the spiketimes are read from the file and cached in memory
    kwargs
        Keyword arguments passed to read
    Return
    ------
    neurons::Vector{Vector{Float32}}
        Vector of spiketimes, one vector for each neuron
"""
function merge_spiketimes(spikes::Vector{NNSpikes}; type = :exc, kwargs...)
    if isa(type, Symbol)
        return _merge_spiketimes(spikes; type = type, kwargs...)
    elseif isa(type, AbstractVector)
        vcat(collect(_merge_spiketimes(spikes; type = t, kwargs...) for t in type)...)
    else
        throw(DomainError("Unknown type $type"))
    end
end

function _merge_spiketimes(
    spikes::Vector{NNSpikes};
    type = :exc,
    pop = nothing,
    cache = true,
    kwargs...,
)
    if cache
        for spiketimes in spikes
            read!(spiketimes)
        end
    end
    @assert !isnothing(pop) "Assign a population to merge spikes, use :ALL for the entire network"
    if pop == :ALL
        neuron_ids = Vector{Int}(collect(1:length(read(spikes[1], type))))
    elseif typeof(pop) <: AbstractVector
        neuron_ids = Vector{Int}(sort!(pop))
    else
        throw(DomainError("Unknown population $pop"))
    end
    ## divide the neurons in contiguous sublists
    sub_indices = k_fold(neuron_ids, Threads.nthreads())
    ## for each sublist, create a vector to store the spiketimes
    sub_neurons = [
        [Vector{Float32}() for _ in eachindex(sub_indices[x])] for
        x in eachindex(sub_indices)
    ]
    # return sub_neurons, sub_indices

    for spiketimes in spikes
        spiketimes = read(spiketimes, type)
        Threads.@threads for p in eachindex(sub_indices)
            working_group = sub_indices[p]
            @simd for sub_i in eachindex(working_group)
                n::Int = neuron_ids[working_group[sub_i]]
                append!(sub_neurons[p][sub_i], spiketimes[n])
            end
        end
    end
    return vcat(sub_neurons...)
end




"""
    merge_spiketimes(spikes::Vector{Spiketimes}; )

    Merge spiketimes from different simulations. 
    This function is not thread safe, it is not recommended to use it in parallel.
    Parameters
    ----------
    spikes: Vector{Spiketimes}
        Vector of spiketimes from different simulations
    Return
    ------
    neurons: Spiketimes
        Single vector of spiketimes 
"""
function merge_spiketimes(spikes::Vector{Spiketimes};)
    neurons = [Vector{Float32}() for _ = 1:length(spikes[1])]
    neuron_ids = collect(1:length(spikes[1]))
    sub_indices = k_fold(neuron_ids, Threads.nthreads())
    sub_neurons = [neuron_ids[x] for x in sub_indices]
    Threads.@threads for p in eachindex(sub_indices)
        for spiketimes in spikes
            for (n, id) in zip(sub_indices[p], sub_neurons[p])
                push!(neurons[n], spiketimes[id]...)
            end
        end
    end
    return sort!.(neurons)
end


"""
    spikes_to_rates(spikes::Union{Vector{NNSpikes}, Spiketimes}, network::Params; interval::AbstractVector=[], sampling = 25, τ=25,ttf=-1, tt0= -1, cache=true, pop::Union{Nothing,Vector{Int}}=nothing,kwargs...)

    Convert spiketimes to rates.
    Use the alpha function to convolve the spiketimes with a time constant τ.

    Parameters
    ----------
    spikes: Union{Vector{NNSpikes}, Spiketimes}
        Vector of spiketimes or NNSpikes
    network: Params
        Network parameters
    interval: AbstractVector
        Time interval to evaluate the rate
    sampling: Int
        Sampling rate in milliseconds
    τ: Int
        Time constant of the alpha function
    ttf: Int
        Final time of the simulation
    tt0: Int
        Initial time of the simulation
    cache: Bool
        If true, read the spiketimes from the file
    pop: Union{Nothing,Vector{Int}}
        Population to evaluate the rate
    kwargs: Dict
        Keyword arguments
    Return
    ------
    rate: Vector{Float32}
        Vector of rates in Hz
"""
function spikes_to_rates(
    spikes::Union{Vector{NNSpikes},Spiketimes},
    network::Params;
    interval::AbstractVector = [],
    sampling = 25,
    τ = 25,
    ttf = -1,
    tt0 = -1,
    cache = true,
    pop::Union{Symbol,Vector{Int}},
    kwargs...,
)
    @unpack stim, net = network
    if isempty(interval)
        tt0 = tt0 > 0 ? tt0 : sampling
        ttf = ttf > 0 ? ttf : stim.simtime
        interval = tt0:sampling:ttf
    end

    if isa(spikes, Vector{NNSpikes})
        populations = cumsum([0, network.net.tripod, network.net.sst])
        labels = [:exc, :sst, :pv]
        ss = Vector{Spiketimes}()
        for i in eachindex(populations)
            @debug "merge population: $(labels[i])"
            push!(ss, merge_spiketimes(spikes; type = labels[i], cache = cache, pop = pop))
        end
        spiketimes = vcat(ss...)
    else
        spiketimes = spikes
    end
    spiketimes = pop == :ALL ? spiketimes : spiketimes[pop]
    # return spiketimes
    @debug "Spikes to interval"
    @debug "convolve to rate"
    rates = tmap(
        n -> convolve(spiketimes[n], interval = interval, τ = τ),
        eachindex(spiketimes),
    )
    # rates = vcat(rates'...)
    return rates, interval
end

function spikes_to_rates(
    spiketimes::Spiketimes;
    interval::AbstractVector = [],
    sampling = 25,
    τ = 25,
    ttf,
    tt0,
    pop::Union{Symbol,Vector{Int}},
    kwargs...,
)
    if isempty(interval)
        tt0 = tt0 > 0 ? tt0 : sampling
        ttf = ttf > 0 ? ttf : stim.simtime
        interval = tt0:sampling:ttf
    end
    spiketimes = pop == :ALL ? spiketimes : spiketimes[pop]
    # return spiketimes
    @debug "Spikes to interval"
    @debug "convolve to rate"
    rates = tmap(
        n -> convolve(spiketimes[n], interval = interval, τ = τ),
        eachindex(spiketimes),
    )
    # rates = vcat(rates'...)
    return rates, interval
end


"""
    spikes_to_features(spikes::Union{Vector{NNSpikes}, Spiketimes}, network::Params; timeshift=50, kwargs...)
    
    Convert spiketimes to features and signs. Used for the classification task.
    The spike features corresponds to the instantaneous firing rate of the neurons, sampled at the time defined in the kwargs.
    Parameters
    ----------
    spikes: Union{Vector{NNSpikes}, Spiketimes}
        Vector of spiketimes or NNSpikes
    network: Params
        Network parameters
    timeshift: Int
        Time shift to evaluate the sign
    kwargs: Dict
        Keyword arguments
        kwargs are passed to spikes_to_rates; see spikes_to_rates for more details
    Return
    ------
    feats: Vector{Float32}
        Vector of features
    signs: Vector{Float32}
        Vector of signs
    interval: AbstractVector
        Time interval to evaluate the rate 
"""
function spikes_to_features(
    spikes::Union{Vector{NNSpikes},Spiketimes},
    network::Params;
    timeshift = 50,
    kwargs...,
)
    feats, interval = spikes_to_rates(spikes, network; kwargs...)
    signs = tmap(x -> get_signs_at_time(x - timeshift, network.seq), interval)
    signs = copy(hcat(signs...))
    return feats, signs, interval
end

## Old stuff, can be usefull

function get_isi(spiketimes::Spiketimes)
    return diff.(spiketimes)
end

get_isi(spiketimes::NNSpikes, pop::Symbol) = read(spiketimes, pop) |> x -> diff.(x)

function get_CV(spikes::Spiketimes)
    intervals = get_isi(spikes;)
    cvs = sqrt.(var.(intervals) ./ (mean.(intervals) .^ 2))
    cvs[isnan.(cvs)] .= -0.0
    return cvs
end

"""
get_spikes_in_interval(spiketimes::Spiketimes, interval::AbstractRange)

Return the spiketimes in the selected interval

# Arguments
spiketimes::Spiketimes: Vector with each neuron spiketime
interval: 2 dimensional array with the start and end of the interval

"""
# function get_spikes_in_interval(spiketimes::Spiketimes, interval, margin=0; collapse::Bool=false)
#     if collapse
#         neurons = Vector{Float32}()
#         @inbounds @fastmath for n in eachindex(spiketimes)
#             @simd for st in spiketimes[n]
#                 if st >= interval[1] && st <=interval[2] + margin
#                     push!(neurons, (st))
#                 end
#             end
#         end
#         return [neurons]
#     else
#         neurons = [Vector{Float32}() for x in 1:length(spiketimes)]
#         @inbounds @fastmath for n in eachindex(neurons)
#             @simd for st in spiketimes[n]
#                 if st >= interval[1] && st <=interval[2] + margin
#                     push!(neurons[n], (st))
#                 end
#             end
#         end
#         return neurons
#     end
# end
function get_spikes_in_interval(
    spiketimes::Spiketimes,
    interval,
    margin = 0;
    collapse::Bool = false,
)
    neurons = [Vector{Float32}() for x = 1:length(spiketimes)]
    @inbounds @fastmath for n in eachindex(neurons)
        ff = findfirst(x -> x > interval[1], spiketimes[n])
        ll = findlast(x -> x <= interval[2] + margin, spiketimes[n])
        if !isnothing(ff) && !isnothing(ll)
            @views append!(neurons[n], spiketimes[n][ff:ll])
        end
    end
    return neurons
end

function get_spikes_in_intervals(
    spiketimes::Spiketimes,
    intervals::Vector{Vector{Float32}};
    margin = 0,
    floor = true,
)
    st = tmap(intervals) do interval
        get_spikes_in_interval(spiketimes, interval, margin)
    end
    (floor) && (interval_standard_spikes!(st, intervals))
    return st
end

function find_interval_indices(
    intervals::AbstractVector{T},
    interval::Vector{T},
) where {T<:Real}
    x1 = findfirst(intervals .>= interval[1])
    x2 = findfirst(intervals .>= interval[2])
    return x1:x2
end


"""
    interval_standard_spikes(spiketimes, interval)

Standardize the spiketimes to the interval [0, interval_duration].
Return a copy of the 'Spiketimes' vector. 
"""
function interval_standard_spikes(spiketimes, interval)
    zerod_spiketimes = deepcopy(spiketimes)
    for i in eachindex(spiketimes)
        zerod_spiketimes[i] .-= interval[1]
    end
    return Spiketimes(zerod_spiketimes)
end

function interval_standard_spikes!(
    spiketimes::Vector{Spiketimes},
    intervals::Vector{Vector{Float32}},
)
    @assert length(spiketimes) == length(intervals)
    for i in eachindex(spiketimes)
        interval_standard_spikes!(spiketimes[i], intervals[i])
    end
end

function interval_standard_spikes!(spiketimes, interval::Vector{Float32})
    for i in eachindex(spiketimes)
        spiketimes[i] .-= interval[1]
    end
    return spiketimes
end




"""    
   get_spike_statistics(spiketimes, intervals)

Return the average statistics of the spiketimes in the selected intervals

Parameters:
    spiketimes::Spiketimes Vector with each neuron spiketime
    intervals: 2 dimensional array with the start and end of the interval
Return:
    first_spike: The time of the first spike in the interval
    spiketime: The mean time of the spikes in the interval
    spikerate: The mean spikerate in the interval
    spikecv: The mean coefficient of variation of the spikes in the interval

"""
function get_spike_statistics(spiketimes, intervals; nan_pos = :begin)
    first_spike = zeros(length(spiketimes))
    spiketime = zeros(length(spiketimes))
    spikerate = zeros(length(spiketimes))
    spikecv = zeros(length(spiketimes))
    for interval in intervals
        nan_st = nan_pos == :middle ? diff(interval) / 2 : 0
        selected = get_spikes_in_interval(spiketimes, interval)
        spiketime .+= mean.(selected) .- interval[1] |> x -> begin
            x[isnan.(x)] .= nan_st
            x
        end
        first_spike .+= [!isempty(x) ? x[1] : interval[2] for x in selected] .- interval[1]
        spikerate .+= length.(selected) / diff(interval) * 1000
        spikecv .+= get_CV(selected)
    end
    first_spike ./= length(intervals)
    spiketime ./= length(intervals)
    spikerate ./= length(intervals)
    spikecv ./= length(intervals)
    # return first_spike, spiketime, spikerate, spikecv
    return (
        first_spike = first_spike,
        spiketime = spiketime,
        spikerate = spikerate,
        spikecv = spikecv,
    )
end


```
Get spike rate in interval
Number of spike times divided by the interval length.
```
function get_fr(spiketimes::Spiketimes, interval)
    return length.(spiketimes) / diff(interval)[1] * second
end

```
Get spike rate in interval
Number of spike times divided by the interval length.
```
function get_fr(spiketimes::Vector{Float32}, interval)
    return length(spiketimes) / diff(interval)[1] * second
end

function get_mean_fr(spiketimes::Spiketimes, interval)
    return mean(length.(spiketimes) / diff(interval)[1] * second) / length(spiketimes)
end

function firing_rates(spikes::Vector{NNSpikes}; kwargs...)
    spiketimes = merge_spiketimes(spikes; kwargs...)
    @unpack tt = spikes[end]
    return length.(spiketimes) ./ tt * 1000
end



function mean_firing_time(x; value = nothing)
    if length(x) > 0
        return float(mean(x))
    elseif !isnothing(value)
        return value
    else
        return -1
    end
end

function get_mean_ft(
    spiketimes::Spiketimes,
    interval::Vector{T};
    value = nothing,
) where {T<:AbstractFloat}
    spiketimes_in_interval = get_spikes_in_interval(spiketimes, interval)
    interval_standard_spikes(spiketimes, interval)
    return mean_firing_time.(spiketimes_in_interval, value = value)
end

function get_fr_highest(spiketimes::Spiketimes, interval; n = 50)
    return mean(
        sort(length.(spiketimes) / diff(interval) * 1000, rev = true, dims = 1)[1:n],
    )
end

"""
    CV_isi2(intervals::Vector{Float32})

    Return the local coefficient of variation of the interspike intervals
    Holt, G. R., Softky, W. R., Koch, C., & Douglas, R. J. (1996). Comparison of discharge variability in vitro and in vivo in cat visual cortex neurons. Journal of Neurophysiology, 75(5), 1806–1814. https://doi.org/10.1152/jn.1996.75.5.1806
"""
function CV_isi2(intervals::Vector{Float32})
    ISI = diff(intervals)
    CV2 = Float32[]
    for i in eachindex(ISI)
        i == 1 && continue
        x = 2(abs(ISI[i] - ISI[i-1]) / (ISI[i] + ISI[i-1]))
        push!(CV2, x)
    end
    _cv = mean(CV2)

    # _cv = sqrt(var(intervals)/mean(intervals)^2)
    return isnan(_cv) ? 0.0 : _cv
end

function isi_cv(spikes::Vector{NNSpikes}; kwargs...)
    spiketimes = merge_spiketimes(spikes; kwargs...)
    @unpack tt = spikes[end]
    return CV_isi2.(spiketimes)
end

get_isi_cv(x::Spiketimes) = CV_isi2.(x)




"""
    get_st_order(spiketimes::Spiketimes)
"""
function get_st_order(spiketimes::T) where {T<:Vector{}}
    ii = sort(eachindex(1:length(spiketimes)), by = x -> spiketimes[x])
    return ii
end

function get_st_order(spiketimes::Spiketimes, pop::Vector{Int}, intervals)
    @unpack spiketime = get_spike_statistics(spiketimes[pop], intervals)
    ii = sort(eachindex(pop), by = x -> spiketime[x])
    return pop[ii]
end

function get_st_order(
    spiketimes::Spiketimes,
    populations::Vector{Vector{Int}},
    intervals::Vector{Vector{T}},
    unique_pop::Bool = false,
) where {T<:Real}
    return [get_st_order(spiketimes, population, intervals) for population in populations]
end

"""
    relative_time(spiketimes::Spiketimes, start_time)

Return the spiketimes relative to the start_time of the interval
"""
function relative_time!(spiketimes::Spiketimes, start_time)
    neurons = 1:length(spiketimes)
    for n in neurons
        spiketimes[n] = spiketimes[n] .- start_time
    end
    return spiketimes
end

get_spike_count(x::Spiketimes) = length.(x)
