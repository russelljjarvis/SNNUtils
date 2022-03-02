function load(datatype::DataType, rd::String, tt0::Real=-1)
	data  = Vector{SNNData{datatype}}()
	name  = string(datatype)
	@show name
	for file_ in readdir(rd)
		if startswith(file_,name) && endswith(file_,"h5")
		    filename = joinpath(rd,file_)
			h5open(filename,"r") do fid
				tt=read(fid,"tt")
				if tt > tt0
					push!(data,SNNData{datatype}(tt=tt,file=filename))
				end
			end
		end
		sort!(data,by=x->x.tt)
	end
	return data
end

import Base.read
function read(data::SNNData)
	if !data._read
		if endswith(data.file,"h5")
			fid = read(h5open(data.file,"r"))
		elseif endswith(data.file, "bson")
			fid = BSON.load(data.file)
		end
		d = Dict{Symbol,Any}()
		for name in keys(fid)
			(name !== "tt") && (push!(d, Symbol(name)=>fid[name]))
		end
		data.data = (;d...)
		data._read=true
	end
	return data.data
end

function read!(data::SNNData)
	if !data._read
		if endswith(data.file,"h5")
			fid = read(h5open(data.file,"r"))
		elseif endswith(data.file, "bson")
			fid = BSON.load(data.file)
		end
		d = Dict{Symbol,Any}()
		for name in keys(fid)
			(name !== "tt") && (push!(d, Symbol(name)=>fid[name]))
		end
		data.data = (;d...)
		data._read=true
	end
	return data
end


export load, read, read!
