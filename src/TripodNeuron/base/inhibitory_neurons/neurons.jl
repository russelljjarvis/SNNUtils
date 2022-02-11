#=================================
		 	Structs
=================================#
struct LIF <:NeuronParams
    #Membrane parameters
    C::Float64                  # (pF) membrane timescale
    gl::Float64                 # (nS) gl is the leaking conductance,opposite of Rm
    Rm::Float64                 # (GΩ) total membrane resistance
    τm::Float64                 # (s) C / gl
    Er::Float64                # (mV) resting potential

    # LIF model
    u_r::Float64            # (mV) Reset potential of membrane
    θ::Float64           # (mV) Spiking Threshold
    t_ref::Float64          # (ms) absolute refractory time

    # Adaptation parameters
    τw::Float64             #ms adaptation current relaxing time
    a::Float64              #nS
    b::Float64              #pA adaptation increase due to spike

    # Inverse value for simulation speedup
    C⁻::Float64             # (pF) inverse membrane timescale
    τw⁻::Float64            #ms inverse adaptation current relaxing time
    τm⁻::Float64            #ms inverse adaptation current relaxing time

	AP_membrane::Float64

    function LIF(τm, gl, Er, u_r, θ, t_ref, a,b,τw)
        """
        Parameters for LIF neuron:
        """
        ## These parameters are inverse, to speedup the computation
        C  = τm * gl #pF
        Rm = 1/gl    #GΩ
        C⁻ = 1/C
        τw⁻ = 1/τw
		global AP_membrane
        return new(C, gl, Rm, τm, Er,
		 		   u_r, θ, t_ref,
				   τw, a, b,
				   C⁻,τw⁻,1/τm,
				    AP_membrane)
    end
end
