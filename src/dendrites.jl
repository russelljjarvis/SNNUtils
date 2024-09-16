## Set physiology
SNN.@load_units
struct Physiology
    Ri::Float32 ## in Ω*cm
    Rd::Float32 ## in Ω*cm^2
    Cd::Float32 ## in pF/cm^2
end

HUMAN = Physiology(200 * Ω * cm, 38907 * Ω * cm^2, 0.5μF / cm^2)
MOUSE = Physiology(200 * Ω * cm, 1700Ω * cm^2, 1μF / cm^2)

"""
    G_axial(;Ri=Ri,d=d,l=l)
    Axial conductance of a cylinder of length l and diameter d
    return Conductance in nS
"""
function G_axial(; Ri = Ri, d = d, l = l)
    ((π * d * d) / (Ri * l * 4))
end

"""
    G_mem(;Rd=Rd,d=d,l=l)
    Membrane conductance of a cylinder of length l and diameter d
    return Conductance in nS
"""
function G_mem(; Rd = Rd, d = d, l = l)
    ((l * d * π) / Rd)
end

"""
    C_mem(;Cd=Cd,d=d,l=l)
    Capacitance of a cylinder of length l and diameter d
    return Capacitance in pF
"""
function C_mem(; Cd = Cd, d = d, l = l)
    (Cd * π * d * l)
end

function create_dendrite(; d::Real = 4um, l::Real, s = "H")
    @unpack Ri, Rd, Cd = s == "M" ? MOUSE : HUMAN
    if l <= 0
        return (gm = 1.0f0, gax = 0.0f0, C = 1.0f0, l = -1, d = d)
    else
        return (
            gm = G_mem(Rd = Rd, d = d, l = l),
            gax = G_axial(Ri = Ri, d = d, l = l),
            C = C_mem(Cd = Cd, d = d, l = l),
            l = l,
            d = d,
        )
    end
end

export create_dendrite


# function get_dends(net::NetParams; seed = nothing)
#     if seed !== nothing
#         Random.seed!(seed)
#     end
#     function dend_parser(model::String)
#         try
#             l1, l2 = split(model, ";")
#             return parse(Int64, l1), parse(Int64, l2)
#         catch
#             l1 = parse(Int64, model)
#             return l1, l1
#         end
#     end
#     @info "Dendrite model: $(net.model)"
#     if net.model == "random_symm"
#         pm1 = Array{PassiveMembraneParameters,1}(undef, net.tripod)
#         pm2 = Array{PassiveMembraneParameters,1}(undef, net.tripod)
#         for cc = 1:net.tripod
#             d = rand(150:1:400)
#             pm1[cc] = PassiveMembraneParameters("rnd_symm", "H", 4, d)
#             pm2[cc] = PassiveMembraneParameters("rnd_symm", "H", 4, d)
#         end
#     elseif net.model == "random"
#         pm1 = Array{PassiveMembraneParameters,1}(undef, net.tripod)
#         pm2 = Array{PassiveMembraneParameters,1}(undef, net.tripod)
#         for cc = 1:net.tripod
#             pm1[cc] = PassiveMembraneParameters("rnd", "H", 4, rand(150:1:400))
#             pm2[cc] = PassiveMembraneParameters("rnd", "H", 4, rand(150:1:400))
#         end
#     elseif net.model == "single"
#         pm1 = Array{PassiveMembraneParameters,1}(undef, net.tripod)
#         pm2 = Array{PassiveMembraneParameters,1}(undef, net.tripod)
#         for cc = 1:net.tripod
#             pm1[cc] = PassiveMembraneParameters("fix", "H", 4, rand(150:1:400))
#             pm2[cc] = PassiveMembraneParameters("fix", "H", 4, 0.0)
#         end
#     elseif net.model == "soma"
#         pm1 = Array{PassiveMembraneParameters,1}(undef, net.tripod)
#         pm2 = Array{PassiveMembraneParameters,1}(undef, net.tripod)
#         for cc = 1:net.tripod
#             pm1[cc] = PassiveMembraneParameters("soma", "H", 4, 0.0)
#             pm2[cc] = PassiveMembraneParameters("soma", "H", 4, 0.0)
#         end
#     else
#         l1, l2 = dend_parser(net.model)
#         pm1 = Array{PassiveMembraneParameters,1}(undef, net.tripod)
#         pm2 = Array{PassiveMembraneParameters,1}(undef, net.tripod)
#         for cc = 1:net.tripod
#             pm1[cc] = PassiveMembraneParameters("fix", "H", 4, l1)
#             pm2[cc] = PassiveMembraneParameters("fix", "H", 4, l2)
#         end
#     end
#     return DendParams(pm1 = pm1, pm2 = pm2)
# end
