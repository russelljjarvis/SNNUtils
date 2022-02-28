
abstract type ConnMap end
"""
Return a sparse matrix with ρ density of non-null entries.
"""

function sparser(matrix::Array{},ρ::Real)
    ρ == 0. && return zeros(size(matrix))
    sparse = findall(x -> rand()>ρ, matrix)
    matrix[sparse] .=0
    return matrix
end


export ConnMap, sparser

@with_kw struct FullConnections <: ConnMap
    ρe_s_e  ::Float32=0
    ρe_d_e  ::Float32=0
    ρif_e ::Float32=0
    ρis_e ::Float32=0
    ρe_if ::Float32=0
    ρe_is ::Float32=0
    ρif_if::Float32=0
    ρis_if::Float32=0
    ρif_is::Float32=0
    ρis_is::Float32=0
    μe_e  ::Float32=0
    μif_e ::Float32=0
    μis_e ::Float32=0
    μe_if ::Float32=0
    μe_is ::Float32=0
    μif_if::Float32=0
    μis_if::Float32=0
    μif_is::Float32=0
    μis_is::Float32=0
    σe_e  ::Float32=0
    σif_e ::Float32=0
    σis_e ::Float32=0
    σe_if ::Float32=0
    σe_is ::Float32=0
    σif_if::Float32=0
    σis_if::Float32=0
    σif_is::Float32=0
    σis_is::Float32=0
end
