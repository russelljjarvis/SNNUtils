using Distributions

function get_connections(W::Weights)
    d = Dict()
    d_inv = Dict()
    for name in fieldnames(W)
        push!(d    , name=> get_connections(getproperty(W,name)))
        push!(d_inv, name=>get_connections(getproperty(W,name), inverse=true))
    end
    return (;d...)
end

function get_connections(matrix::Matrix{Float32}; inverse = false)
    if length(size(matrix))>2
        @views matrix = sum(matrix,dims=3)[:,:,1]
    end
    posts, pres = size(matrix)
    ## get pre->post connections
    if !inverse
        connections=Vector{Vector{Int64}}()
        for pre in 1:pres
            this_neuron=Vector{Int64}()
            for post in 1:posts
                if matrix[post,pre]>0
                    push!(this_neuron,post)
                end
            end
            push!(connections,this_neuron)
        end
    end

    ## get post <- pre connections
    if inverse
        connections=Vector{Vector{Int64}}()
        for post in 1:posts
            this_neuron=Vector{Int64}()
            for pre in 1:pres
                if matrix[post,pre]>0
                    push!(this_neuron,pre)
                end
            end
            push!(connections,this_neuron)
        end
    end
    return connections
end

function sparser(matrix::Array,ρ::Real)
    ρ == 0. && return zeros(size(matrix))
    sparse = findall(x -> rand()>ρ, matrix)
    matrix[sparse] .=0
    return matrix
end


"""
recurrent_network
"""
function recurrent_network(;cells, connections)
	@unpack params, map = connections
	ws = Dict{Symbol, Matrix{Float32}}()
	for (out_, in_, _name, ρ, μ, σ) in map
		_in = getfield(cells,in_)
		_out = getfield(cells,out_)
		_μ  = getfield(params,μ)
		_σ  = getfield(params,σ)
		_ρ   = getfield(params,ρ)

		## set matrix to zero if one of population is empty
		(_in == 0 || _out == 0 ) && (_in = 0; _out =0; )
		if getfield(params,σ) == 0
			ww = sparser(_μ*ones(_out, _in), _ρ)
		else
			ww=  Float32.(sparser(rand(LogNormal(log(_μ) ,_σ), _out , _in), _ρ))
		end
    	ws = push!(ws, _name=>ww )
	end
	return Weights((;ws...))
end

export get_connections, recurrent_network

using Distributions
Float32.(rand(LogNormal(10),10,10))
