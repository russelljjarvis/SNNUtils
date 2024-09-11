
function file_path(seconds, n_elements, input_type, title)
    path = joinpath(
        pwd(),
        "sequence/exp_" *
        title *
        "_" *
        input_type *
        "_t_" *
        string(seconds) *
        "_s_" *
        string(n_elements),
    )
    return path
end

function get_connections(matrix; inverse = false)
    if length(size(matrix)) > 2
        @views matrix = sum(matrix, dims = 3)[:, :, 1]
    end
    posts, pres = size(matrix)
    ## get pre->post connections
    if !inverse
        connections = Vector()
        for pre = 1:pres
            this_neuron = Vector{}()
            for post = 1:posts
                if matrix[post, pre] > 0
                    push!(this_neuron, post)
                end
            end
            push!(connections, this_neuron)
        end
    end

    ## get post <- pre connections
    if inverse
        connections = Vector()
        for post = 1:posts
            this_neuron = Vector{}()
            for pre = 1:pres
                if matrix[post, pre] > 0
                    push!(this_neuron, pre)
                end
            end
            push!(connections, this_neuron)
        end
    end
    return connections
end


"""
Return a sparse matrix with ρ density of non-null entries.
"""
function sparser(matrix::Array{}, ρ::Real)
    ρ == 0.0 && return zeros(size(matrix))
    sparse = findall(x -> rand() > ρ, matrix)
    matrix[sparse] .= 0
    return matrix
end


function generate_cells(; tripod::Int64 = 0, pv::Int64 = 0, sst::Int64 = 0, star::Int64 = 0)
    return (tripod = tripod, pv = pv, sst = sst, star = star)
end
