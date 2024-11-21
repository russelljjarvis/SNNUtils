function evaluate(population, intervals::Vector{Vector{Float32}}, target::Symbol, cells::Dict{Symbol,Any} = Dict())
    count = 0
    for time_interval in intervals
        interval_range = range(first(time_interval), stop=last(time_interval), length=length(time_interval))
        firing_rates = Dict(w => mean(SNN.average_firing_rate(population; interval=interval_range, pop=cells[w])) for w in keys(cells))

        if all(firing_rates[target] > firing_rates[w] for w in keys(cells) if w != target)
            count += 1
        end
    end
    return count / length(intervals)
end

export evaluate