@with_kw struct TripodConnections <: AbstractConnections
    e_s_e::Array{Float32,2} = zeros(1, 1)  ## pre_syn, post_syn, compartment
    e_d1_e::Array{Float32,2} = zeros(1, 1)  ## pre_syn, post_syn, compartment
    e_d2_e::Array{Float32,2} = zeros(1, 1)  ## pre_syn, post_syn, compartment
    is_e::Array{Float32,2} = zeros(1, 1)
    if_e::Array{Float32,2} = zeros(1, 1)

    e_s_is::Array{Float32,2} = zeros(1, 1)
    e_d1_is::Array{Float32,2} = zeros(1, 1)
    e_d2_is::Array{Float32,2} = zeros(1, 1)
    is_is::Array{Float32,2} = zeros(1, 1)
    if_is::Array{Float32,2} = zeros(1, 1)

    e_if::Array{Float32,2} = zeros(1, 1)
    is_if::Array{Float32,2} = zeros(1, 1)
    if_if::Array{Float32,2} = zeros(1, 1)
end

@with_kw struct TripodConnMap <: AbstractConnMap
    ρe_s_e::Float32 = 0
    ρe_d_e::Float32 = 0
    ρif_e::Float32 = 0
    ρis_e::Float32 = 0
    ρe_if::Float32 = 0
    ρe_s_is::Float32 = 0
    ρe_d_is::Float32 = 0
    ρif_if::Float32 = 0
    ρis_if::Float32 = 0
    ρif_is::Float32 = 0
    ρis_is::Float32 = 0
    μe_e::Float32 = 0
    μif_e::Float32 = 0
    μis_e::Float32 = 0
    μe_if::Float32 = 0
    μe_is::Float32 = 0
    μif_if::Float32 = 0
    μis_if::Float32 = 0
    μif_is::Float32 = 0
    μis_is::Float32 = 0
    σe_e::Float32 = 0
    σif_e::Float32 = 0
    σis_e::Float32 = 0
    σe_if::Float32 = 0
    σe_is::Float32 = 0
    σif_if::Float32 = 0
    σis_if::Float32 = 0
    σif_is::Float32 = 0
    σis_is::Float32 = 0
end
