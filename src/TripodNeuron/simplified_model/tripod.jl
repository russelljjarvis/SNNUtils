#===================================================
		Backpropagation spike
===================================================#

struct PostSpike
      A::Float64
      ttabs::Int64
      τA⁻::Float64
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
