## Set physiology

struct Physiology
	Ri::Float32 #GΩ*cm
	Rd::Float32 #GΩ*cm²
	Cd::Float32 #pF /cm²
end

function G_axial(;Ri=Ri,d=d,l=l)
	R= Ri*l/(π*d*d/4)
	return 1/R
end

function G_mem(;Rd=Rd,d=d,l=l)
	R = Rd/l/d/π
	return 1/R
end

function C_mem(;Cd=Cd,d=d,l=l)
	return Cd*π*d*l*uF
end

SNN.@load_units

HUMAN = Physiology(200*Ω*cm,38907*Ω*cm^2, 0.5uF/cm^2)
MOUSE = Physiology(200*Ω*cm,1700Ω*cm^2,1uF/cm^2)


function get_dendrite(;d::Real,l::Real, s="H")
	d = d*um
	l = l*um
	if s =="M"
		Ri,Rd,Cd = MOUSE.Ri,MOUSE.Rd,MOUSE.Cd
	elseif s =="H"
		Ri,Rd,Cd = HUMAN.Ri,HUMAN.Rd,HUMAN.Cd
	end
	return G_mem(Rd=Rd,d=d,l=l), G_axial(Ri=Ri,d=d,l=l), C_mem(Cd=Cd,d=d, l=l)
end



get_dendrite(l=300.,d=4., s="H")



function create_dendrite(l::Real, d=4.f0::Float32)
	T = Float32
	g_m, g_ax, C = UnitDendrites.get_dendrite(l=l, d=d)
	return (g_m=T(g_m), g_ax=T(g_ax), C=T(C), l=T(l), d=T(d))
end

function create_dendrites(ls::Vector{Int64}, d=4.f0::Float32)
	T = Float32
	g_ms = Vector{Float32}()
	g_axs = Vector{Float32}()
	Cs = Vector{Float32}()
	ls = Vector{Float32}()
	ds = Vector{Float32}()
	for l in ls
		g_m, g_ax, C = UnitDendrites.get_dendrite(l=l, d=d)
		push!(g_ms,g_m)
		push!(g_axs,g_ax)
		push!(Cs,C)
		push!(ds,d)
	end
	return (g_m=T.(g_ms), g_ax=T.(g_axs), C=T.(Cs), l=T.(ls), d=T.(ds))
end
