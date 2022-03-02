
"""
Return a sparse matrix with ρ density of non-null entries.
"""


@with_kw struct Connections
    params::NamedTuple
    map::Vector{Vector{Symbol}}
end


export sparser, Connections
