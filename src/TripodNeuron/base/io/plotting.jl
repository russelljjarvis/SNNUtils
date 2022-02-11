include("colors.jl")
using LaTeXStrings

default(legendfontsize=14, bglegend=:transparent, fglegend=:transparent,grid=false, guidefontsize = 18, tickfontsize=13, frame=:axes)

function raster_plot(spike_time, n_exc=nothing; alpha=0.5, colormap=nothing, my_plot=nothing, colors=nothing, n_pv=0, n_sst=0)
    neurons = length(spike_time)
    if n_exc==nothing
        n_exc = neurons
    end
    p =  my_plot == nothing ? plot() : my_plot
    for n in 1:n_exc
        if colormap != nothing
            for (i, list) in enumerate(colormap)
                if n in list
                    color = colors[i]
                    jitter = i*0.3
                    p = scatter!(p, spike_time[n], (jitter+n)*ones(length(spike_time[n])), markersize=4, alpha=alpha, color= color,markerstrokealpha=alpha, legend=false)
                end
            end
        else
            p = scatter!(p, spike_time[n], n*ones(length(spike_time[n])), alpha=alpha, color= :black,markerstrokewidth=0, legend=false)
        end
    end
    for n in 1+n_exc:n_exc+n_pv
        p = scatter!(p, spike_time[n], n*ones(length(spike_time[n])), alpha=alpha, color=RED, markerstrokecolor=RED,markerstrokealpha=alpha,markerstrokewidth=0, legend=false)
    end
    for n in 1+n_exc+n_pv:neurons
        p = scatter!(p, spike_time[n], n*ones(length(spike_time[n])), alpha=alpha, color=BLU, markerstrokecolor=BLU,markerstrokewidth=0, markerstrokealpha=alpha, legend=false)
    end
    return p
end




function plot_tripod(t::Tripod,voltage::Array{Float64,2},current::Array{Float64,2},synapses::Union{Array{Float64,3},Nothing})

    total_steps = size(voltage,2)
    ## Prepare plots
    compartments = ["soma" [d.pm.type for d in t.d]...]
    synapses_label = [ "AMPA" "NMDA" "GABAa" "GABAB"]
    tripod_currents = [[d.pm.type*"out"  for d in t.d]... "soma_in" "adaptation"]
    color_currents=[:red :red :black :yellow]
    if length(t.d)>2
        color_currents=[:red :red :green :black :yellow]
    end
    soma_currents = ["adapt" "AdEx" "tripod" "synap"]

    ## voltage
    p1 = Plots.plot(legend=:topleft, 1:total_steps,transpose(voltage), alpha=[1 0.3 0.3 0.4], color=[:black :red :red :green], labels=compartments, ylabel="Voltage (mV)", title="Tripod")
    #currents
    p2 = Plots.plot(ylim=(-1000,1000),legend=:topleft, 1:total_steps,transpose(current), alpha=[0.4 0.4 0.4 0.7 1], color=color_currents, linestyle=[:solid :solid :solid :solid :dash], labels=tripod_currents, ylabel="Current (pA)", xlabel = "Time (s)")
    my_plots = [p1,p2]
    secs = length(total_steps)/10000
    xticks!(p1, 1:10000:total_steps+1,string.(collect(0:1:secs+1)))
    xticks!(p2, 1:10000:total_steps+1,string.(collect(0:1:secs+1)))


    p = Plots.plot(p1,p2, layout=(2,1), reuse=true)

    # if plot_synapse
    #         PyPlot.display(Plots.plot(soma_current, layout=(1,1), reuse=false))
    # end
    my_plots = []
    if synapses != nothing
        for (n,d) in enumerate(t.d)
            push!(my_plots,Plots.plot(transpose(synapses[:,:,1+n]), labels=synapses_label, labeltitle="d"*string(n), title="Synaptic conductances", legend=false))
        end
        push!(my_plots,Plots.plot(transpose(synapses[:,:,1]),reuse= false, labels=synapses_label, labeltitle="soma", title="Synaptic conductances", legend=false))
        push!(my_plots, Plots.scatter([0 0 0 0], labels=synapses_label))
        s = plot(my_plots...,layout=(length(t.d)+2))
        # synapses = Plots.plot!(p1,p2,p3,p4,layout = (length(my_plots),1))
        # PyPlot.display(Plots.plot(s1,s2,s3,soma, layout=(4,1), reuse=false))
        return p, s
    else
        return p
    end

end


function plot_tripod(t::Tripod, voltage::Array{Float64,2})
    total_steps = size(voltage,2)
    ## Prepare plots
    compartments = ["soma" [d.pm.type for d in t.d]...]
    synapses_label = [ "AMPA" "NMDA" "GABAa" "GABAB"]

    ## voltage
    p1 = Plots.plot(legend=:topleft, 1:total_steps,transpose(voltage), alpha=[1 0.3 0.3 0.4], color=[:black RED BLU :green], labels=compartments, ylabel="Voltage (mV)", title="Tripod")
    return p1

end

function plot_tripod(t::Tripod,voltage::Array{Float64,2},current::Array{Float64,2},synapses::Union{Array{Float64,3},Nothing})

    total_steps = size(voltage,2)
    ## Prepare plots
    compartments = ["soma" [d.pm.type for d in t.d]...]
    synapses_label = [ "AMPA" "NMDA" "GABAa" "GABAB"]
    tripod_currents = [[d.pm.type*"out"  for d in t.d]... "soma_in" "adaptation"]
    color_currents=[:red :red :black :yellow]
    if length(t.d)>2
        color_currents=[:red :red :green :black :yellow]
    end
    soma_currents = ["adapt" "AdEx" "tripod" "synap"]

    ## voltage
    p1 = Plots.plot(legend=:topleft, 1:total_steps,transpose(voltage), alpha=[1 0.3 0.3 0.4], color=[:black :red :red :green], labels=compartments, ylabel="Voltage (mV)", title="Tripod")
    #currents
    p2 = Plots.plot(ylim=(-1000,1000),legend=:topleft, 1:total_steps,transpose(current), alpha=[0.4 0.4 0.4 0.7 1], color=color_currents, linestyle=[:solid :solid :solid :solid :dash], labels=tripod_currents, ylabel="Current (pA)", xlabel = "Time (s)")
    my_plots = [p1,p2]
    secs = length(total_steps)/10000
    xticks!(p1, 1:10000:total_steps+1,string.(collect(0:1:secs+1)))
    xticks!(p2, 1:10000:total_steps+1,string.(collect(0:1:secs+1)))


    p = Plots.plot(p1,p2, layout=(2,1), reuse=true)

    # if plot_synapse
    #         PyPlot.display(Plots.plot(soma_current, layout=(1,1), reuse=false))
    # end
    my_plots = []
    if synapses != nothing
        for (n,d) in enumerate(t.d)
            push!(my_plots,Plots.plot(transpose(synapses[:,:,1+n]), labels=synapses_label, labeltitle="d"*string(n), title="Synaptic conductances", legend=false))
        end
        push!(my_plots,Plots.plot(transpose(synapses[:,:,1]),reuse= false, labels=synapses_label, labeltitle="soma", title="Synaptic conductances", legend=false))
        push!(my_plots, Plots.scatter([0 0 0 0], labels=synapses_label))
        s = plot(my_plots...,layout=(length(t.d)+2))
        # synapses = Plots.plot!(p1,p2,p3,p4,layout = (length(my_plots),1))
        # PyPlot.display(Plots.plot(s1,s2,s3,soma, layout=(4,1), reuse=false))
        return p, s
    else
        return p
    end

end

function plot_tripod(voltage::Array{Float64,2},current::Array{Float64,2})
    t=Tripod(1)
    plot_tripod(t,voltage,current,nothing)
end


# function plot_tripod(voltage::Array{Float64,2},current::Array{Float64,2},synapses::Union{Array{Float64,3},Nothing})
#     return plot_tripod(Tripod(1),voltage,current,synapses)
# end|

# spikes_plot(SPIKE_TIMES)
function plot_spikes(spike_times)
    s = plot()
    for n in eachindex(spike_times)
        for times in spike_times[n]
            plot!(s,[times, times],[n+0.1,n+0.9], color=:black, label="")
        end
    end
    s = plot!(s, xaxis=false,yaxis=false)
    return s
end
