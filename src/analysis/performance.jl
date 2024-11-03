function evaluate(population, intervals::Vector{Vector{Float32}}, cells::Dict{Symbol,Any} = Dict())
    firing_rates_intervals = Dict{Symbol,Any}()
    for time_interval in intervals
        for w in keys(cells)
            interval_range = range(first(time_interval), stop=last(time_interval), length=length(time_interval))
            firing_rates_intervals[w] = mean(SNN.average_firing_rate(population; interval=interval_range, pop=cells[w]))
        end
    end
    return firing_rates_intervals
end

export evaluate
