## Back
include("units.jl")

#===================================================
		Backpropagation spike
===================================================#

            # threshold rise, idle-time duration, threshold decay

struct PostSpike
      A::Float64 # threshold rise
      ttabs::Int64 # spike time duration (tt)
      τA⁻::Float64 # decay timescale ⁻1

	  Ips::Float64 # Introduced in Clopath for vSTDP
	  τz⁻::Float64
	  function PostSpike(A, ttabs, τA)
		  return new(A, ttabs, 1/τA, 0.,1.)
	  end
	  function PostSpike(a,b,c,d,e)
		  return new(a,b,c,d,e)
	  end
end



#===================================================
		Neuron and dendrites structs
===================================================#

abstract type NeuronParams end

struct AdExParams <: NeuronParams
    #Membrane parameters
    C::Float64                  # (pF) membrane timescale
    gl::Float64                 # (nS) gl is the leaking conductance,opposite of Rm
    Rm::Float64                 # (GΩ) total membrane resistance
    τm::Float64                 # (ms) C / gl
    Er::Float64                 # (mV) resting potential

    # AdEx model
    u_r::Float64            # (mV) Reset potential of membrane
    θ::Float64              # (mv) Rheobase threshold
    ΔT::Float64             # (mV) Threshold sharpness

    # Adaptation parameters
    τw::Float64             #ms adaptation current relaxing time
    a::Float64              #nS adaptation current to membrane
    b::Float64              #pA adaptation current increase due to spike

    # Inverse value for simulation speedup
    C⁻::Float64             # (pF) inverse membrane timescale
    τw⁻::Float64            #ms inverse adaptation current relaxing time
    τm⁻::Float64            #ms inverse adaptation current relaxing time
    ΔT⁻::Float64             # (mV) inverse Threshold sharpness

	# After spike timescales and membrane
	AP_membrane::Float64
	BAP::Float64
	up_dt::Int64
	idle_dt::Int64


    function AdExParams(τm, gl, Er, u_r, θ, τw, a, b, up, idle)
        ### Biological values
        Rm = 1/gl    #GΩ
        C  = τm * gl #pF
        ΔT = 2 #ms

        ## These parameters are inverse, to speedup the computation
        C⁻ = 1/C
        τw⁻ = 1/τw
        ΔT⁻ = 1/ΔT

		## Parameters for spike-backpropagation
		global AP_membrane
		AP_membrane = AP_membrane
		## AP duration
		up_dt = round(Int,up/dt) #ms
		## hyperpolarization duration
		idle_dt = round(Int,idle/dt) #ms
        return new(C, gl, Rm, τm, Er,
		 			u_r, θ, ΔT,
					 τw, a, b,
					 C⁻,τw⁻,1/τm,ΔT⁻,
					 AP_membrane, BAP, up_dt, idle_dt)
    end
end

mutable struct Soma
    ### circuit element
    v::Float64         #(mV) membrane potential of axosomatic compartment
    w::Float64         #(pA) adaptive current
	as_dt::Int64 		   # after spike time-step counter

    ### Synapse
    g_GABAa::Float64       #(nS) decay_var of dendrite compartment
    g_GABAb::Float64       #(nS) decay_var of dendrite compartment
    g_AMPA::Float64        #(nS) decay_var of dendrite compartment
    h_GABAa::Float64       #(nS) rise_variable of soma compartment
    h_GABAb::Float64       #(nS) rise_variable of soma compartment
    h_AMPA::Float64        #(nS) rise_variable of soma compartment
    h_NMDA::Float64        #(nS) rise_variable of dend compartment
    g_NMDA::Float64        #(nS) decay_var of dendrite compartment

	θ::Float64  			# rheobase variable threshold for STDP

	id::Int64
	syn::Synapse
	model::String
    function Soma(syn, model)
	    id=1
        w = 0. #AdEx.b
        v = AdEx.Er#rand(-70.:-60.)
        return new(v,w,-1,zeros(8)...,AdEx.θ,  id,syn, model)
    end
    function Soma(id, syn, model)
        w = 0. #AdEx.b
        v = AdEx.Er#rand(-70.:-60.)
        return new(v,w,-1,zeros(8)..., AdEx.θ, id,syn, model)
    end
end


struct PassiveMembraneParameters
    type::String
    Rm::Float64                 # (GΩ) total membrane resistance
    τm⁻::Float64                # (s) 1/RC
    Er::Float64                # (mV) resting potential
    C⁻::Float64                 #(ms) membrane timescale
	g_ax::Float64				# (nS) axial conductance
	s::String                   # Dend specie (M or H)
	d::Float64					# μm dendrite diameter
	l::Float64					# μm distance from next compartment
    function  PassiveMembraneParameters(
                                type::String,
								s,
								d,
								l)
					gL, g_ax, Cm, = create_dendrites(s=s,d=d, l=l);
				    τm⁻    = gL/Cm    #(1/s) inverse of membrane τ = RC time
				    Rm  = 1/gL
				    Er    = AdEx.Er  #(mV) leak reversal potential
            return new(type,Rm, τm⁻, Er,1/Cm, g_ax,s, d, l)
        end
end


mutable struct Dendrite
    id::Int16        # Dendrite id number
    v::Float64       # (mV) membrane potential of dendritic compartment
    ### Synapse
    g_GABAa::Float64       #(nS) decay_var of dendrite compartment
    g_GABAb::Float64       #(nS) decay_var of dendrite compartment
    g_NMDA::Float64        #(nS) decay_var of dendrite compartment
    g_AMPA::Float64        #(nS) decay_var of dendrite compartment
    h_GABAa::Float64       #(nS) rise_variable of dend compartment
    h_GABAb::Float64       #(nS) rise_variable of dend compartment
    h_NMDA::Float64        #(nS) rise_variable of dend compartment
    h_AMPA::Float64        #(nS) rise_variable of dend compartment
	syn::Synapse
    pm::PassiveMembraneParameters
    function Dendrite(n, pm::PassiveMembraneParameters)
        return new(n, pm.Er,zeros(8)..., Esyn_dend, pm)
    end
    function Dendrite(n, s, d, l)
		type= l > 150 ? "distal" : "proximal"
		pm = PassiveMembraneParameters(type,s,d,l)
        return new(n, pm.Er,zeros(8)..., Esyn_dend, pm)
    end
end



Compartment = Union{Soma, Dendrite}

#===================================================
				Tripod Circuit
===================================================#

struct TripodCircuit
    """
    This struct contains the circuital parameters of the tripod model
    The circuit is defined by 6 conductance values.
    The conductances between two compartments are not symmetric

    When the neuron has 2 compartments instead than 3 the number of
    parameters is the same.
    """
	links::Array{Int64,2}
	conductance::Array{Float64,2}
end

function model_parser(model::String)
	if occursin("->",model)
		function get_link(link, n_soma)
			o,t = split(link,"->")
			o = parse(Int,o)
			t = try
			    parse(Int,t)
			  catch
			    n_soma
			end
			return [o,t]
		end
		species, model = split(model,".")
		compartments = split(model,";")
		n_soma = length(compartments)+1
		links = Vector()
		params = Vector()
		for comp in compartments
			link, l, d = split(strip(comp),",")
			push!(links, get_link(link,n_soma))
			push!(params,Dict("s"=>species, "l"=>parse(Float64,l), "d"=>parse(Float64,d)))
		end
		links = hcat(links...)
		return links, params
	else
		return [[] []], []
	end
end



struct TripodModel
	links::Array{Int,2}
	params::Array{Any,1}
	function TripodModel(model::String)
		links, params = model_parser(model)
		new(links, params)
	end
end

struct Tripod
    """
    """
    s::Soma
    d::Array{Dendrite,1}
    c::TripodCircuit
	model::TripodModel
    function Tripod(;id=1, model::TripodModel=default_model)
        ### TODO AdEx and Esyn are constant but may change
        dendrites = get_dendrites(model)
        soma = Soma(id, Esyn_soma, "AdEx")
        circuit = get_tripod_circuit(model, dendrites)
        return new(soma, dendrites, circuit, model)
    end
    function Tripod(stringparams::String)
		model = TripodModel(stringparams)
		Tripod(id=1, model=model)
	end
    function Tripod(model::TripodModel)
		model = TripodModel(stringparams)
		Tripod(id=1, model=model)
	end
	# end
    function Tripod(id::Int64)
		Tripod(id=id,model=TripodModel(default_model))
	end
    function Tripod()
		Tripod(id=1,model=TripodModel(default_model))
	end
    function Tripod(model::TripodModel)
		Tripod(id=1,model=model)
	end
end

function get_dendrites(model::TripodModel)
    d = Array{Dendrite,1}(undef,0)
	for (n,params) in enumerate(model.params)
		push!(d,Dendrite(n,params["s"], params["d"],params["l"]))
	end
	return d
end

function get_tripod_circuit(model::TripodModel,dendrites::Array{Dendrite})
	n_dend = length(dendrites)
	conductance = zeros(n_dend+1, n_dend+1)
	if n_dend >0
		for (origin, target) in eachcol(model.links)
			conductance[origin,target] = dendrites[origin].pm.g_ax
			conductance[target,origin] = dendrites[origin].pm.g_ax *BAP_gax
		end
	end
    return TripodCircuit(model.links, conductance)
end

function create_dendrites(;d,l,s)
    d = d*μm
    l = l*μm
	if s =="M"
		Ri,Rd,Cd = MOUSE.Ri,MOUSE.Rd,MOUSE.Cd
	elseif s =="H"
		Ri,Rd,Cd = HUMAN.Ri,HUMAN.Rd,HUMAN.Cd
	end
	if s=="M" && l.val>400
	    return G_mem(Rd=Rd,d=d,l=l).val, G_axial(Ri=Ri,d=d,l=l).val, C_mem(Cd=Cd,d=d, l=l).val
	else
	    return G_mem(Rd=Rd,d=d,l=l).val, G_axial(Ri=Ri,d=d,l=l).val, C_mem(Cd=Cd,d=d, l=l).val
	end
end

function create_dendrites(dendrite::Dendrite)
    d = dendrite.pm.d
    l = dendrite.pm.l
	s = dendrite.pm.s
	create_dendrites(d=d,l=l,s=s)
end
