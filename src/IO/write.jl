function save(W::NamedTuple, T::Float32, rd::String)
    filename = abspath(joinpath(rd, "Weights_$T.h5"))
    fid = h5open(filename, "w")
    for name in fieldnames(typeof(W))
        fid[string(name)] = getproperty(W, name)
    end
    fid["tt"] = T
    close(fid)
    return nothing
end

# function save(tracker::Tracker, T::Float32, rd::String)
#     filename = abspath(joinpath(rd, "Tracker_$T.h5"))
#     fid = h5open(filename, "w")
#     for name in fieldnames(typeof(tracker))
#         fid[string(name)] = getfield(tracker, name)
#     end
#     fid["tt"] = T
#     close(fid)
#     return nothing
# end

# function save(datatype::DataType, T::Float32, rd::String; kwargs...)
#     name = string(datatype)
#     if datatype == Spikes
#         filename = abspath(joinpath(rd, "$(name)_$T.bson"))
#         bson(filename; kwargs...)
#     else
#         filename = abspath(joinpath(rd, "$(name)_$T.h5"))
#         fid = h5open(filename, "w")
#         for n in keys(kwargs)
#             fid[string(n)] = kwargs[n]
#         end
#         fid["tt"] = T
#         close(fid)
#     end
#     return nothing
# end


export save
# _network_weights, save_network_rates, save_network_spikes, save_network_states, save_network_trackers
# function save_network_spikes(datatype::Spikes, T::Float32,rd::String,compression = 1; kwargs...)
# 	name = string(datatype)
#     filename = abspath(joinpath(rd,"$name_$T.bson")
# 	bson(filename; tt=T, kwargs...)
#     return nothing
# end
#
# function save_network_rates(T::Float32,rd::String,compression = 1; kwargs...)
#     filename = abspath(rd*"/rate_$T.h5")
#     fid = h5open(filename,"w")
# 	for n in keys(kwargs)
# 		fid[n] = kwargs[n]
# 	end
# 	fid["tt"] = T
#     close(fid)
#     nothing
# end
