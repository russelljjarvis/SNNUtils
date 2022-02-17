function clustering_ee_history(ws, rd)
	for (tt, w) in ws
		w = readW(w,"e_s_e")
		nodes, cols = clustering_ee(w)
		p = heatmap(w[cols,cols,3])
		savefig(p,joinpath(rd,"graphs",string(tt)))
	end
end


function weights_animation(wd1,wd2, seq, filepath=joinpath("/tmp","connections_dendrites.gif"))
	_m = floor(minimum([wd1[:];wd2[:]]))
	_M = ceil(maximum([wd1[:];wd2[:]]))
	ww = length(get_words(seq))
	p = (wd1,wd2,t) ->
		begin
		layout = @layout [
					a{0.7w}
					b{0.4w} _ b{0.4w}
		]
		ticks = ([ww/2,ww+ww/2], ["words", "phonemes"])
		plot(
		heatmap((wd2[t,:,:] .+ wd1[t,:,:])./2, clims=(_m,_M), yticks=ticks, ylabel="post-synaptic", xlabel="pre-synaptic", title="Timeframe: $t" ),
		heatmap(wd1[t,:,:], ylabel="post-synaptic", xlabel="pre-synaptic", clims=(_m,_M), yticks=:none, cbar=false,   title="Dendrite 1"),
		heatmap(wd2[t,:,:], ylabel="", clims=(_m,_M), yticks=:none,cbar=false, title="Dendrite 2"),
		layout=layout,
		xticks=ticks,
		titlefontsize = 12,
		)
		vline!([ww+0.5], c=:white, ls=:dash, lw=2, label="")
		hline!([ww+0.5], c=:white, ls=:dash, lw=2, label="")
	end
	anim = @animate for t in 1:size(wd1,1)
		p(wd1,wd2,t)
	end
	cgif = joinpath(@__DIR__,filepath)
	gif(anim, cgif, fps = 1)
end
