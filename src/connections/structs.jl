
"""
Return a sparse matrix with ρ density of non-null entries.
"""


function sparser(matrix::Array,ρ::Real)
    ρ == 0. && return zeros(size(matrix))
    sparse = findall(x -> rand()>ρ, matrix)
    matrix[sparse] .=0
    return matrix
end

@with_kw struct Connections
    params::NamedTuple
    map::Vector{Vector{Symbol}}
end


export sparser, Connections
