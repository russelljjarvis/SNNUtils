## Set physiology

module MyUnits
	import Unitful
	import Unitful: μm,cm,m, Ω, GΩ, F,μF, pF
	import Unitful: @u_str, @unit, uconvert
	@unit Sim "Sim" Siemens 1u"1/Ω" true
	@unit nS "nSim" Siemens 1u"1/GΩ" true

	Unitful.register(MyUnits)

	struct Physiology
		Ri::typeof(1. *Ω*cm)
		Rd::typeof(1. *Ω*cm^2)
		Cd::typeof(1. *μF/cm^2)
	end

	function G_axial(;Ri=Ri,d=d,l=l)
	    l_ = uconvert(cm,d)
	    d_ = uconvert(cm,l)
	    R_ = Ri*l/(π*d*d/4)
	    return uconvert(nS, 1/R_)
	end

	function G_mem(;Rd=Rd,d=d,l=l)
	    d_ = uconvert(cm,l)
		l_ = uconvert(cm,d)
	    R_ = Rd/l_/d_/π
	    return uconvert(nS, 1/R_)
	end

	function C_mem(;Cd=Cd,d=d,l=l)
	    l_ = uconvert(cm,d)
	    d_ = uconvert(cm,l)
	    C_ = Cd*π*d*l
	    return uconvert(pF, C_)
	end

	HUMAN = Physiology(200*Ω*cm,38907*Ω*cm^2, 0.5μF/cm^2)
	MOUSE = Physiology(200*Ω*cm,1700Ω*cm^2,1μF/cm^2)

	function get_dendrite(;d::Real,l::Real, s="H")
		d = d*μm
		l = l*μm
		if s =="M"
			Ri,Rd,Cd = MOUSE.Ri,MOUSE.Rd,MOUSE.Cd
		elseif s =="H"
			Ri,Rd,Cd = HUMAN.Ri,HUMAN.Rd,HUMAN.Cd
		end
		return G_mem(Rd=Rd,d=d,l=l).val, G_axial(Ri=Ri,d=d,l=l).val, C_mem(Cd=Cd,d=d, l=l).val
		# units: nS, nS, pF
	end
end

Dendrite = NamedTuple{(:gm, :gax, :C, :l, :d), NTuple{5, Float32}}
Dendrites = Tuple{Vector{Dendrite}, Vector{Dendrite}}
export Dendrite, Dendrites

function create_dendrite(l::Real, d=4.f0::Float32, T=Float32)
	g_m, g_ax, _C = MyUnits.get_dendrite(l=l, d=d)
	return (gm=T(g_m), gax=T(g_ax), C=T(_C), l=T(l), d=T(d))
end

function create_dendrites(ls::Vector{Real}, d=4.f0, T=Float32)
	g_ms = Vector{Float32}()
	g_axs = Vector{Float32}()
	Cs = Vector{Float32}()
	ls = Vector{Float32}()
	ds = Vector{Float32}()
	for l in ls
		g_m, g_ax, C = MyUnits.get_dendrite(l=l, d=d)
		push!(g_ms,g_m)
		push!(g_axs,g_ax)
		push!(Cs,C)
		push!(ds,d)
	end
	return (gm=T.(g_ms), gax=T.(g_axs), C=T.(Cs), l=T.(ls), d=T.(ds))
end


function dend_parser(model::String)
	try
		l1, l2 = split(model,";")
		return parse(Int64,l1), parse(Int64,l2)
	catch
		l1 = parse(Int64,model)
		return l1, l1
	end
end


DendArray = Vector{Dendrite}
function get_dends(model::String, N::Int, range=150:1:400)::Dendrites
	if model == "random"
		pm1 = Array{Dendrite,1}(undef,N)
		pm2 = Array{Dendrite,1}(undef,N)
		for cc in 1:N
			pm1[cc]= create_dendrite(rand(range))
			pm2[cc]= create_dendrite(rand(range))
		end
	else
		l1, l2 = dend_parser(model)
		pm2 = Array{Dendrite,1}(undef,N)
		pm1 = Array{Dendrite,1}(undef,N)
		for cc in 1:N
			pm1[cc]= create_dendrite(l1)
			pm2[cc]= create_dendrite(l2)
		end
	end
	return (pm1,pm2)
end
export get_dends
