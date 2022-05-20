#===================================================
		Backpropagation spike
===================================================#

# Set AP_membrane for backpropagation
@with_kw struct PostSpike
		# After spike adaptive threshold
		A::Float32
		τA::Float32
		Ips::Float32=0. # Introduced in Clopath for vSTDP
		# After spike timescales and membrane
		AP_membrane::Float32=1f0
		BAP::Float32=1f0
		τA⁻::Float32 = 1/τA
		τz⁻::Float32=1.
end



#===================================================
		Neuron and dendrites structs
===================================================#

abstract type NeuronParams end

@with_kw struct AdExParams <: NeuronParams
    #Membrane parameters
    C::Float32=281 # (pF) membrane timescale
    gl::Float32=40 # (nS) gl is the leaking conductance,opposite of Rm
    Rm::Float32=1/gl                 # (GΩ) total membrane resistance
    τm::Float32=C/gl                 # (ms) C / gl
    Er::Float32=-70.4                 # (mV) resting potential

    # AdEx model
    u_r::Float32=-70.4            # (mV) Reset potential of membrane
    θ::Float32=-50.4              # (mv) Rheobase threshold
    ΔT::Float32=2             # (mV) Threshold sharpness

    # Adaptation parameters
    τw::Float32=144             #ms adaptation current relaxing time
    a::Float32=4              #nS adaptation current to membrane
    b::Float32=80.5              #pA adaptation current increase due to spike

	up::Float32=1 #ms
	idle::Float32=2 #ms

    # Inverse value for simulation speedup
    C⁻::Float32=1/C             # (pF) inverse membrane timescale
    τw⁻::Float32=1/τw            #ms inverse adaptation current relaxing time
    τm⁻::Float32=1/τm            #ms inverse adaptation current relaxing time
    ΔT⁻::Float32=1/ΔT            # (mV) inverse Threshold sharpness
end
@with_kw struct PassiveMembraneParameters
    type::String
    Rm::Float32                 # (GΩ) total membrane resistance
    τm⁻::Float32                # (ms) RC
    Er::Float32                 # (mV) resting potential
    C⁻::Float32                 # (1/pF) membrane timescale
	g_ax::Float32				# (nS) axial conductance
	s::String                   # Dend specie (M or H)
	d::Float32					# μm dendrite diameter
	l::Float32					# μm distance from next compartment
    function  PassiveMembraneParameters(
                                type::String,
								s,
								d,
								l)
					gL, g_ax, Cm, = create_dendrites(s=s,d=d, l=l);
				    τm⁻    = gL/Cm    #(1/s) inverse of membrane τ = RC time
				    Rm  = 1/gL
				    Er    = -70.6  #(mV) leak reversal potential
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
	if l.val ==0
		return 0., 0., 1.
	else
	    return G_mem(Rd=Rd,d=d,l=l).val, G_axial(Ri=Ri,d=d,l=l).val, C_mem(Cd=Cd,d=d, l=l).val
	end
end

@with_kw struct LIF <:NeuronParams
    #Membrane parameters
    C::Float32                  # (pF) membrane timescale
    gl::Float32                 # (nS) gl is the leaking conductance
    τm::Float32 = C/gl
    Er::Float32                # (mV) resting potential

    # LIF model
    u_r::Float32            # (mV) Reset potential of membrane
    θ::Float32           # (mV) Spiking Threshold

    # Adaptation parameters
    τw::Float32             #ms adaptation current relaxing time
    a::Float32              #nS
    b::Float32              #pA adaptation increase due to spike

	idle::Float32=1 #ms

    # Inverse value for simulation speedup
    Rm::Float32 = 1/gl             # (GΩ) total membrane resistance
    C⁻::Float32 = 1/C             # (pF) inverse membrane timescale
    τw⁻::Float32 = 1/τw            #ms inverse adaptation current relaxing time
    τm⁻::Float32  = 1/τm           #ms inverse adaptation current relaxing time

end
