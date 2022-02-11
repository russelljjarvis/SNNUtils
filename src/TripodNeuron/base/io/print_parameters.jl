

function print_parameters(method::Function, args...)
    parameters = method(args...)
    println("==================================================")
    println("Params: "*string(typeof(parameters)))
    println("--------------------------------------------------")
    for name in fieldnames(typeof(parameters))
        println(string(name)*": "*string(getfield(parameters,name)))
    end
    println("==================================================")
end

function print_parameters()
    print_parameters(get_dendrite_params,"distal")
    print_parameters(get_dendrite_params, "proximal")
    print_parameters(get_lif_inh_params)
    print_parameters(get_AdEx_params)
    print_parameters(get_synapses_params_exc,dt,"dendrite")
    print_parameters(get_tripod_circuit)
end

function write_parameters(fp, method::Function, args...)
    parameters = method(args...)
    write(fp,"\n\n")
    write(fp,"Params: "*string(typeof(parameters))*"\n")
    write(fp, "--------------------------------------------------\n")
    for name in fieldnames(typeof(parameters))
        write(fp,string(name)*": "*string(getfield(parameters,name))*"\n")
    end
end

function write_parameters(filepath::String)
    fp = open(filepath*"parameters.txt","w")
        write(fp,"==================================================\n")
        write_parameters(fp,get_dendrite_params,"distal")
        write_parameters(fp,get_dendrite_params, "proximal")
        write_parameters(fp,get_lif_inh_params)
        write_parameters(fp,get_AdEx_params)
        write_parameters(fp,get_synapses_params_exc,dt,"dendrite")
        write_parameters(fp,get_tripod_circuit)
    write(fp,"==================================================\n")
    close(fp)
end



function get_circuit_properties(comp::Union{Dendrite,Soma})
	if isa(comp,Soma)
		return AdEx.gl, AdEx.C
	end
	if isa(comp,Dendrite)
		return dend_parameters(comp)
	end
end


function get_circuit_properties(model)
	tripod = Tripod(model)
	x =""
	soma = get_circuit_properties(tripod.s)
	x *= @sprintf "Soma: G leak: %.2f nS; C %.2f pF \n" soma[1] soma[2]
	for (n,d) in enumerate(tripod.d)
		dend = get_circuit_properties(d)
		len    = d.pm.l
		diam    = d.pm.d
		x*= @sprintf "Dendrite %d, diameter: %d μm, length %d μm; G leak: %.2f nS; G axial %.2f nS, C %.2f pF \n" n diam len dend[1] dend[2] dend[3]
	end
	return x
end

function get_memory_time(p)
	return p[3]/(p[1]+p[2])
end
