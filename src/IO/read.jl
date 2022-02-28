

function read_network_rates(rd::String)
	rates  = Vector()
	for file_ in readdir(rd)
		if startswith(file_,"Rate") && endswith(file_,"h5")
		    filename = joinpath(rd,file_)
			file_ = h5open(filename,"r")
		    fid = read(file_)
		    exc= fid["exc"]
			sst= fid["sst"]
			pv = fid["pv" ]
	    	tt = fid["tt"]
			close(file_)
			push!(rates,[tt, exc, sst, pv])
		end
	end
	return sort(rates, by=x->x[1])
end

function read_network_states(rd::String; tt0=0.)
	states  = Vector{NNStates}()
	for file_ in readdir(rd)
		if startswith(file_,"State") && endswith(file_,"h5")
		    filename = joinpath(rd,file_)
			h5open(filename,"r") do fid
				tt=read(fid,"tt")
				if tt > tt0
					push!(states,NNStates(tt=tt,file=filename))
				end
			end
		end
		sort!(states,by=x->x.tt)
	end
	return states
end


function read_network_spikes(rd::String; tt0=-1)
	spikes  = Vector{NNSpikes}()
	for file_ in readdir(rd)
		if startswith(file_,"Spikes_") && endswith(file_,"jld")
		    filename = joinpath(rd,file_)
			tt = replace(file_,"Spikes_"=>"") |> x->replace(x,".jld"=>"") |> x-> parse(Float32,x)
			# tt=load(filename,"tt")
			if tt > tt0
				push!(spikes,NNSpikes(tt=tt,file=filename))
			end
		end
		sort!(spikes,by=x->x.tt)
	end
	return spikes
end


function read_network_weights(rd::String;tt0 = -1)
	weights  = Vector{NNWeights}()
	for file_ in readdir(rd)
		if startswith(file_,"Weights") && endswith(file_,"h5")
		    filename = joinpath(rd,file_)
			tt = replace(file_,"Weights_"=>"") |> x->replace(x,".h5"=>"") |> x-> parse(Float32,x)
			# tt=load(filename,"tt")
			if tt > tt0
				push!(weights,NNWeights(tt=tt,file=filename))
			end
		end
		sort!(weights,by=x->x.tt)
	end
	return weights
end


function read_network_trackers(rd::String;tt0 = -1)
	trackers  = Vector{NNTracker}()
	for file_ in readdir(rd)
		if startswith(file_,"tracker") && endswith(file_,"h5")
		    filename = joinpath(rd,file_)
			tt = replace(file_,"tracker_"=>"") |> x->replace(x,".h5"=>"") |> x-> parse(Float32,x)
			# tt=load(filename,"tt")
			if tt > tt0
				push!(trackers,NNTracker(tt=tt,file=filename))
			end
		end
		sort!(trackers,by=x->x.tt)
	end
	return trackers
end

function read_connections( w::NNWeights, conn::String)
	if w._read
		return getfield(w.w,Symbol(conn))
	else
		h5open(w.file,"r") do file_
		    return read(file_, conn)
		end
	end
end

export read_network_weights, read_network_rates, read_network_spikes, read_network_states, read_network_trackers, read_connections


#
# function read_network_weight(rd::String;  T)
# 	weights  = Vector{NNWeights}()
# 	for file_ in readdir(rd)
# 		if startswith(file_,"Weights") && endswith(file_,"h5")
# 		    filename = joinpath(rd,file_)
# 			tt = replace(file_,"Weights_"=>"") |> x->replace(x,".h5"=>"") |> x-> parse(Float32,x)
# 			# tt=load(filename,"tt")
# 			if tt == T
# 				return read(NNWeights(tt=tt,file=filename))
# 			end
# 		end
# 	end
# 	throw("Weight matrix not found")
# end




# function read_last_network_weights(rd::String; mytt=nothing)
# 	ws  = Vector()
# 	last_tt = 0
# 	for file_ in readdir(rd)
# 		if startswith(file_,"Weights") && endswith(file_,"h5")
# 		    filename = joinpath(rd,file_)
# 			h5open(filename,"r") do fid
# 		    	tt=read(fid["tt"])
# 				(tt > last_tt ) && (last_tt = tt)
# 			end
# 		end
# 	end
# 	if last_tt == 0
# 		throw("Weights files not found in "*rd)
# 	end
# 	if !isnothing(mytt)
# 		filename = joinpath(rd,"Weights_$mytt.h5")
# 		println("importing weights from time: ",mytt/10)
# 	else
# 	    filename = joinpath(rd,"Weights_$last_tt.h5")
# 		println("importing weights from time: ",last_tt/10)
# 	end
# 	h5open(filename,"r") do file_
# 	    fid = read(file_)
# 		w = Weights(;(Symbol(k[2:end])=>fid[k[1:end]] for k in keys(fid) if k != "tt")...)
# 		tt    = fid["tt"]
# 	end
#     return tt, w
# end
#
# ## This function is a util to be used to fix broken dataset
# function add_time(rd::String)
# 	for file_ in readdir(rd)
# 		if endswith(file_,"h5")
# 			tt = replace(replace(file_,"Weights_T"=>""),".h5"=>"")
# 			tt = parse(Int, tt)
# 			fid = h5open(joinpath(rd, file_),"cw")
# 			fid["tt"] = tt
# 			close(fid)
# 		end
# 	end
# end
# function rescale_with_tt0_ratio(rd::String, stim::StimParams, tt0::Int=-1)
# 	tts  = Vector()
# 	for file_ in readdir(rd)
# 		if startswith(file_,"Spikes_") && endswith(file_,"jld")
# 			tt = replace(file_,"Spikes_"=>"") |> x->replace(x,".jld"=>"") |> x-> parse(Float32,x)
# 			# tt=load(filename,"tt")
# 			if tt > tt0
# 				push!(tts,tt)
# 			end
# 		end
# 	end
# 	tts = sort(tts)
# 	## Get first value
# 	tt_initial = tts[1] - (tts[2]-tts[1])
# 	tt_final = maximum(tts)
# 	tt_per_input = round(Int,(tts[2]-tts[1])/stim.duration*dt)
# 	tt0_input = round(Int,tt_per_input*length(tts[1:findfirst(tt->tt>tt0, tts)]))
# 	all_inputs = round(Int,tt_per_input*length(tts))
# 	# @show tt_per_input, tt_initial, tts, tt_final, all_inputs
# 	values = collect(1:stim.seq_length)
# 	if tt0 < tt_initial
# 		return values[1:all_inputs]
# 	end
# 	return values[tt0_input+1:all_inputs]
# end
#
# function get_interval_length(rd::String, stim::StimParams, intervals::Vector{Int})
# 	tts  = Vector()
# 	for file_ in readdir(rd)
# 		if startswith(file_,"State") && endswith(file_,"h5")
# 		    filename = joinpath(rd,file_)
# 			h5open(filename,"r") do fid
# 				tt = read(fid["tt"])
# 		    	push!(tts, tt)
# 			end
# 		end
# 	end
# 	sort!(tts)
# 	## Get first value
# 	tt_initial = tts[1] - (tts[2]-tts[1])
# 	push!(tts, tt_initial)
# 	sort!(tts)
# 	tt_final = maximum(tts)
# 	tt_per_input = round(Int,(tts[2]-tts[1])/stim.duration*dt)
# 	@show tts[2]-tts[1], tt_per_input
#
# 	tt_input = round(Int,tt_per_input*length(tts[intervals]))
# 	timezero = tts[intervals[1]]
# 	tt0_input = round(Int,tt_per_input*length(tts[intervals[1]]))
# 	@show all_inputs, length(tts)
#
# 	values = 1:stim.seq_length
# 	return values[tt0_input+1:all_inputs]
# end
