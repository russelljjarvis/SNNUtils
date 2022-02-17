using Plots
#=======================
	 Raster Plot
=======================#
import Plots: Series, Plot, Subplot

function raster_both_populations(spikes::Vector{NNSpikes}, seq::SeqEncoding, timeframe::Int, store::StoreParams, interval=1)
	p = let

		_start = spikes[timeframe].tt-spikes[1].tt
		_end = spikes[timeframe].tt
		p1 = raster_populations(spikes, seq, timeframe=timeframe, target="phs")
		# vline!(p1,_start:0.05:_end, c=:red, ls=:dash);
		p2 = raster_populations(spikes, seq, timeframe=timeframe, target="words")
		# vline!(p2,_start:0.05:_end, c=:red, ls=:dash);
		plot!(p1, xticks=:none)
		plot!(p1, xaxis="")
		plot(p1,p2, layout=(2,1) ,  xlims = (10e-4(spikes[timeframe].tt-store.interval),
		(spikes[timeframe].tt-store.interval*(1-interval))*10e-4))
	end
	return p
end

rectangle(w, h, x, y) = Shape(x .+ [0,w,w,0], y .+ [0,0,h,h])

function raster_populations(spikes::Vector{NNSpikes}, seq::SeqEncoding; target, timeframe::Int64)
	if target == "words"
		_target = 1
	elseif target == "phs"
		_target = 2
	else
		throw(DomainError("Set target to 'words' or 'phs'"))
	end
	active_pops = sort(collect(Set(seq.sequence[_target,:])))
	labels = string.([seq.mapping[x] for x in active_pops])
	lengths = [length(seq.populations[x]) for x in active_pops]

	neurons = []
	for pop in active_pops
		push!(neurons,seq.populations[pop]...)
	end

	ax = plot()
	for (n,pop) in enumerate(seq.sequence[_target,:])
		_y = findfirst(x-> x==pop, active_pops)-1
		y, h = length(seq.populations[pop]) .* (_y, 1)
		plot!(ax, rectangle(0.05,h,(n-1)*0.05,y), alpha=0.6, c=:red)
	end


	_start = spikes[timeframe].tt-spikes[1].tt
	_end = spikes[timeframe].tt
	raster_plot(read(spikes[timeframe]).exc[neurons], ax=ax)
	plot!(yticks=(cumsum(lengths) .- mean(lengths)/2, labels))
	plot!(xlims=(_start/1000,_end/1000), ylabel=target*" pops")
end

# # spikes_plot(SPIKE_TIMES)
# function plot_spikes(spike_times)
#     s = plot()
#     for n in eachindex(spike_times)
#         for times in spike_times[n]
#             plot!(s,[times, times],[n+0.1,n+0.9], color=:black, label="")
#         end
#     end
#     s = plot!(s, xaxis=false,yaxis=false)
#     return s
# end



function raster_plot(spikes::Vector{NNSpikes}, timeframe::Int, store::StoreParams)
	spikes = read(spikes[timeframe])
	xlims = (10e-4(spikes.tt-store.interval),(spikes.tt)*10e-4)
	return raster_plot(spikes, xlims=xlims)
end

function raster_plot(spikes::NNSpikes; ax=plot(), kwargs...)
	npop = [0, length(spikes.exc), length(spikes.sst), length(spikes.pv)]
	_x, _y = Float32[], Float32[]
    y0 = Int32[0]
	for (_n, pop) in enumerate([spikes.exc, spikes.sst, spikes.pv])
	    for n in eachindex(pop)
			for ft in pop[n]
				push!(_x,ft*1e-3)
				push!(_y,n+cumsum(npop)[_n])
			end
		end
		push!(y0,npop[_n])
	end
    plt = scatter!(ax, _x, _y, m = (1, :black), leg = :none,
                  xaxis=("Time (s)", (0, Inf)), yaxis = ("neuron",))
    _y0 = y0[2:end]
	plot!(;kwargs...)
	plot!(yticks=(cumsum(_y0) .+ npop[2:end]./2, ["exc", "sst", "pv"]))
    !isempty(_y0) && hline!(plt, cumsum(_y0), linecolor = :red)
end

function raster_plot(pop::Spiketimes; ax=plot(), kwargs...)
	_x, _y = Float32[], Float32[]
    y0 = Int32[0]
    for n in eachindex(pop)
		for ft in pop[n]
			push!(_x,ft*1e-3)
			push!(_y,n)
		end
	end
    plt = scatter!(ax, _x , _y, m = (1, :black), leg = :none,
                  xaxis=("Time (s)" ), yaxis = ("neuron",))
end
