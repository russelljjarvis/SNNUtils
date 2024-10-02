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
