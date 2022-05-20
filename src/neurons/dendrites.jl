struct PassiveMembraneParameters
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
				    Er    = -70.4f0  #(mV) leak reversal potential
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
