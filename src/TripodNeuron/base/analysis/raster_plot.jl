using Plots
import Plots.Plot, Plots.Subplot, Plots.Series
using ColorSchemes

function get_spike_times(spikes::Matrix{Bool})
    spiketimes=[]
    for neuron in eachrow(spikes)
        push!(spiketimes,findall(neuron))
    end
    return spiketimes
end


struct TracePlot{I,T}
    indices::I
    plt::Plot{T}
    sp::Subplot{T}
    series::Vector{Series}
end

function TracePlot(n::Int = 1; maxn::Int = typemax(Int), sp = nothing, kw...)
    clist= get(ColorSchemes.colorschemes[:linear_ternary_blue_0_44_c57_n256],range(0,1,length=n))
    blue = palette(:tab10)[1]
    red = palette(:tab10)[4]
    indices = if n > maxn
        shuffle(1:n)[1:maxn]
    else
        1:n
    end
    if sp == nothing
        plt = scatter(length(indices),markersize=1.5;kw...)
        sp = plt[1]
    else
        plt = scatter!(sp, length(indices); kw...)
    end
    for n in indices
        c = n < 2001 ? blue : red
        c=blue
        sp.series_list[n].plotattributes[:markercolor]= c #clist[n]
        sp.series_list[n].plotattributes[:markerstrokecolor]= c# clist[n]
    end
    TracePlot(indices, plt, sp, sp.series_list)
end

function Base.push!(tp::TracePlot, x::Number, y::AbstractVector)
    push!(tp.series[x], y, x .*ones(length(y)))
end
Base.push!(tp::TracePlot, x::Number, y::Number) = push!(tp, [y], x)

function raster_plot(spikes; alpha=0.5, populations=nothing, kw...)
    if !isnothing(populations)
        cells = length(vcat(populations...))
        s = TracePlot(cells, legend=false)
        n = 0
        for pop in populations
            for neuron in pop
                n+=1
                if length(spikes[neuron]) >0
                     push!(s,n,spikes[neuron])
                end
            end
        end
    else
        s = TracePlot(length(spikes), legend=false, alpha=alpha, kw...)
        for (n,z) in enumerate(spikes)
            if length(z)>0
                push!(s,n,z[:])
            end
        end
    end
    return s
end
