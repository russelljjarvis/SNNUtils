
Spiketimes = Vector{Vector{Float32}}

function get_spikes(voltage::Array{Float32,3})
    """
    Voltage: (cells,  time, compartments)
    """
    spikes = falses(size(voltage, 1), size(voltage, 3))
    for n = 1:size(voltage, 1)
        spikes[n, :] .= [v > -30 for v in voltage[n, 1, :]]
    end
    return spikes
end

function get_spikes(voltage::Array{Float32,2})
    spikes = falses(size(voltage, 1), size(voltage, 2))
    for n = 1:size(voltage, 1)
        spikes[n, :] .= [v == AP_membrane for v in voltage[n, :]]
    end
    return spikes
end

function get_spike_times(voltage::Array{Float32,2})
    times = Vector{Vector{Int64}}()
    spikes = falses(size(voltage)...)
    for (n, n_voltage) in enumerate(eachrow(voltage))
        spikes[n, :] .= [v == AdEx.AP_membrane for v in n_voltage]
        push!(times, findall(x -> x > 0, spikes[n, :]))
    end
    return Spiketimes(times)
end

function get_spike_times(spikes::Union{BitArray{2},Array{Bool,2}})
    times = Vector{Vector{Int64}}()
    for neuron in eachrow(spikes)
        push!(times ./ 1000 * dt, findall(x -> x > 0, neuron))
    end
    return Spiketimes(times ./ 1000 / dt)
end

get_spike_times(spikes::BitArray{1}) = findall(x -> x > 0, spikes)
get_spike_times(voltage::Array{Float32,1}) = findall(x -> x > 0, get_spikes(voltage))
get_spike_times(spikes::Union{BitArray{2},Array{Bool,2}}) =
    map(x -> get_spike_times(x), eachrow(spikes))
get_spike_times(spikes::Array{Bool,2}) = map(x -> get_spike_times(x), eachrow(spikes))
get_spike_times(spikes::SubArray{Bool,2}) = map(x -> get_spike_times(x), eachrow(spikes))

get_spikes(voltage::Array{Float32,1})::Array{Bool,1} = [v > -30 for v in voltage[:]]

get_spike_rate(v::Array{Float32,2})::Float32 =
    float(sum(v[1, :] .> -30) / length(v[1, :]) * 10000)
get_spike_rate(v::Array{Float32,1}) = sum(v .> -30) / length(v) * 10000
get_spike_rate(v::Array{Float32,3}) =
    [sum(v[i, 1, :] .> -30) / length(v[i, 1, :]) * 10000 for i = 1:size(v, 1)]
get_spike_rate(spikes::Union{BitArray{1},Array{Bool,1}}) =
    sum(spikes) / length(spikes) * 10000

function get_spike_rate(
    spike_times::Spiketimes;
    interval::Tuple{Float32,Float32} = (0.0f0, 0.0f0),
)
    rate = Vector{Float32}()
    for neuron in eachindex(spike_times)
        push!(rate, 0)
        for spike in spike_times[neuron]
            if interval[1] == interval[2]
                rate[neuron] += 1.0f0
            elseif spike > interval[1] && spike < interval[2]
                rate[neuron] += 1.0f0
            end
        end
    end
    if !(interval[1] == interval[2])
        rate ./= (interval[2] - interval[1])
        rate .*= 1000
    end
    return rate
end

function get_spike_rate(
    spike_times::Spiketimes;
    interval::Tuple{Float32,Float32} = (0.0f0, 0.0f0),
)
    rate = Vector{Float32}()
    for neuron in eachindex(spike_times)
        push!(rate, 0)
        for spike in spike_times[neuron]
            if interval[1] == interval[2]
                rate[neuron] += 1.0f0
            elseif spike > interval[1] && spike < interval[2]
                rate[neuron] += 1.0f0
            end
        end
    end
    if !(interval[1] == interval[2])
        rate ./= (interval[2] - interval[1])
        rate .*= 1000
    end
    return rate
end

function get_isi(spike_times::Spiketimes; interval)
    _spike_times = Spiketimes()
    for neuron in eachindex(spike_times)
        push!(_spike_times, Vector{Float32}())
        last_spike = interval[1]
        for spike in spike_times[neuron]
            if (spike > interval[1] && spike < interval[2])
                isempty(_spike_times[neuron]) && (push!(_spike_times[neuron], last_spike))
                push!(_spike_times[neuron], spike)
            else
                last_spike = spike
            end
        end
        push!(_spike_times[neuron], interval[2])
    end
    # return _spike_times
    return diff.(_spike_times)
end

get_isi(spike_times::Spiketimes) = diff.(spike_times)
get_isi(voltage::Array{Float32,2}) = diff(get_spike_times(voltage[1, :]))
get_isi(voltage::Array{Float32,1}) = diff(get_spike_times(voltage))
get_isi(spikes::Matrix{Bool}) = diff.(map(x -> findall(y -> y, x), eachrow(spikes))) .* dt

function get_CV(spikes::Spiketimes; interval)
    intervals = get_isi(spikes; interval = interval)
    cvs = var.(intervals) ./ (mean.(intervals) .^ 2)
    cvs[isnan.(cvs)] .= -0.0
    return cvs
end

function CV(spikes)
    intervals = get_isi(spikes)
    cvs = var.(intervals) ./ (mean.(intervals) .^ 2)
    cvs[isnan.(cvs)] .= -0.0
    return cvs
end
"""
Function to estimate the istantaneuous firing rate of a neuron.
Calculate the number of spikes every millisecond and make bins, then scale up to the firing rate in second

Parameters
==========

"""
function firing_rate(spikes::BitArray{2}; time_step = dt, window = 10)
    cells, duration = size(spikes)
    scale = 1000 / window / time_step
    window = round(Int, window / time_step)
    Δt = window
    rate = zeros(cells, round(Int, duration / Δt))
    gaussian(x::Real) = exp(-(x - window / 2)^2 / 2window)
    weights = gaussian.(0:9)
    # weights[1:round(Int, Δt/2)].=0
    weights /= sum(weights)
    for (n, cell) in enumerate(eachrow(spikes))
        for x = 1:size(rate)[2]-1
            # rate[n, x]= mean(running(sum, spikes[n,:],window, weights)[1+Δt*(x-1):Δt*x])
            rate[n, x] = sum(spikes[n, 1+Δt*(x-1):Δt*x])
        end
        rate[n, :] .= runmean(rate[n, :], round(Int, 1 / time_step), weights)
    end
    return rate * scale
end
function firing_rate(spikes::BitArray{1}; time_step = dt, window = 10)
    my = falses(1, size(spikes)[1])
    my[1, :] .= spikes
    return firing_rate(spikes; time_step = time_step, window = window)[1, :]
end



"""
Average membrane potential

Parameters
==========

`voltage`: [neurons, time] matrix with membrane voltage
`window`: length of the averaging window, in ms
`slide_offset`: shift the window of ms for each new point
"""

function average_potential(
    membrane::Array{Float32,2},
    time_step::Float32;
    slide_offset::Float32 = 20,
    window::Float32 = 50,
)
    ### the time of each bin is 0.1 ms.
    cells, duration = size(membrane)
    max_duration(x::Int) = x > duration ? duration : x
    ## make integer values
    slide_offset = ceil(Int, slide_offset / time_step)
    window = round(Int, window / time_step)
    time_points = floor(Int, duration / slide_offset)
    average = zeros(time_points, cells)
    for n = 1:time_points
        x = 1 + (n - 1) * slide_offset
        # slide*(slide_offset+1):slide:slide*time_points)
        average[n, :] =
            mean(membrane[:, max_duration.(x:round(Int, window / 10):x+window)], dims = 2)
    end
    return average
end
