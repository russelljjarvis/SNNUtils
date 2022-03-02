module SNNUtils

	using Parameters
	include("structs.jl")
	include("unit.jl")
	include("util.jl")
	include("params.jl")
	include("dendrites.jl")
	include("protocols.jl")
	include("synapses/base.jl")
	include("connections/base.jl")
	include("learning/base.jl")
	include("sequence/base.jl")
	include("IO/base.jl")



	using Requires
	function __init__()
	    @require Plots="91a5bcdd-55d7-5caf-9e0b-520d859cae80" include("plots/base.jl")
	end


end # module
