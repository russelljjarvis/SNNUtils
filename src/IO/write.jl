function save_network_weights(W::AbstractWeights, T::Float32, rd::String, filename::String="Weights_" )
	compression =1
    filename = abspath(joinpath(rd,filename*"$T.h5")) #absolute path #somehow the location gets weird for this one..
    fid = h5open(filename,"w")
	for name in fieldnames(typeof(W))
	    fid[string(name)] = getfield(W, name)
	end
    close(fid)
    nothing
end

function save_tracker(tracker::AbstractTracker, T::Float32, rd::String)
	compression =1
    filename = abspath(joinpath(rd,"tracker_$T.h5")) #absolute path #somehow the location gets weird for this one..
    fid = h5open(filename,"w")
	for name in fieldnames(typeof(tracker))
	    fid[string(name)] = getfield(tracker, name)
	end
	close(fid)
end


function save_network_states(currents::Array{Float32,2},membranes::Array{Float32,2},labels::Array{Int64,2}, T::Float32,rd::String,compression = 1)
    filename = abspath(rd*"/State_$T.h5") #absolute path #somehow the location gets weird for this one..
    fid = h5open(filename,"w")
    fid["membranes"] = membranes
	fid["currents"] = currents
	fid["labels"] = labels
	fid["tt"] = T
    close(fid)
    nothing
end

function save_network_rates(rates::Matrix{Float32}, T::Float32,rd::String,compression = 1)
    filename = abspath(rd*"/Rate_$T.h5")
    fid = h5open(filename,"w")
    fid["exc"] = rates[1,:]
	fid["sst"] = rates[2,:]
	fid["pv"] =  rates[3,:]
	fid["tt"] = T
    close(fid)
    nothing
end

function save_network_spikes(exc::Spiketimes, sst::Spiketimes, pv::Spiketimes, T::Float32,rd::String,compression = 1)
    filename = abspath(rd*"/Spikes_$T.jld")
	bson(filename, exc=exc, sst=sst, pv=pv, tt=T)
    nothing
end


export save_network_weights, save_network_rates, save_network_spikes, save_network_states, save_network_trackers
