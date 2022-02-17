module SNNUtils

	using Parameters

	include("unit.jl")
	include("util.jl")
	include("structs.jl")
	include("dendrites.jl")
	include("STDP_rules.jl")
	include("synapses.jl")
	include("weights.jl")
	include("protocols.jl")


	using Requires
	function __init__()
	    @require Plots="91a5bcdd-55d7-5caf-9e0b-520d859cae80" include("plots/base.jl")
	end


end # module
