function get_relative_path(path::String)
    dirs = split(path, "/")
    N = -1
    for (n, dir) in enumerate(dirs)
        if dir == "data"
            N = n
        end
    end
    return joinpath(dirs[(N+1):end]...)
end

function clean_store_data(store)
    if isdir(store.data)
        rm(store.data, recursive = true, force = true)
        mkdir(store.data)
    end
end

function make_dirs(store)
    mkpath(store.path)
    mkpath(store.params)
    mkpath(store.data)
    return store
end

export make_dirs, clean_stored_data
#
# function correct_store_id(path::String)
#     store = deserialize(joinpath(path, "params/store.so"))
# 	id = get_relative_path(path)
# 	println("was: ", store.id )
# 	new_store = StoreParams(id=id, interval = store.interval)
# 	println("becomes: ", id )
# 	serialize(joinpath(new_store.params, "store.so"), new_store)
# end
#
# function correct_strore_in(path="data")
# 	for (root, dirs,files) in walkdir(path)
# 		for file_ in files
# 			if file_ == "store.so"
# 				correct_store_id(splitdir(root)[1])
# 			end
# 		end
# 	end
# end
#
# function copy_params(path="data/recall")
# 	for (root, dirs,files) in walkdir(path)
# 		for file_ in files
# 			if file_ == "store.so"
# 				copy_exp_params(splitdir(root)[1])
# 			end
# 		end
# 	end
# end
#
# function copy_exp_params(src::String, dst::String )
# 	src_params = joinpath(src, "params/params.so")
# 	dst_params = joinpath(dst, "params/params.so")
# 	cp(src_params,dst_params, force=true)
# end
#
# function populate_idle_folder(path="data/recall")
# 	for (root, dirs,files) in walkdir(path)
# 		for file_ in files
# 			if file_ == "seq.so"
# 				id = move_data_to_idle(splitdir(root)[1])
# 			end
# 		end
# 	end
# end
#
#
# function get_time(name)
# 	@assert(endswith(name, ".h5"))
# 	return parse(Int,replace(name,".h5"=>"") |> name-> replace(split(name,"_")[end],"T"=>""))
# end
# IDLE_T= get_time("Spikes_12000000.h5")
# function move_data_to_idle(recall_path)
# 	idle_id = replace(get_relative_path(recall_path), "recall"=>"idle")
#     stim, seq, net, dends, recall_store = read_network_params(recall_path)
# 	idle_store=StoreParams(id=idle_id)
# 	for (root, dirs,files) in walkdir(recall_store.data)
# 		for file_ in files
# 			T = get_time(file_)
# 			if (T < IDLE_T+1)
# 				src_file =joinpath(root,file_)
# 				dst_file = joinpath(idle_store.data, file_)
# 				@assert(isfile(src_file))
# 				# @assert(isfile(dst_file))
# 				mv(src_file, dst_file)
# 				println("from: ", src_file , " to: ", dst_file)
# 			end
# 		end
# 	end
#     idle_seq = null_sequence(seq,stim)
# 	copy_exp_params(idle_store.path, "idle")
# 	store_network_params(stim, seq, net, dends, learn, idel_store)
# end
#
#
# # populate_idle_folder()
#
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
