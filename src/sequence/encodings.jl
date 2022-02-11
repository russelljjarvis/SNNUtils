function seq_encoder(net::NetParams, stim::StimParams)
    """
    Create the sequence encoder for the network:
        1. Create target sub-populations of 'density*n_tripods' for each symbol.
        2. Connect the rate-based inputs to the 'input_cells' (stars cells)
        3. Create a sequence of inputs of length: 'sequence_length'
        The stimulus is mediated by the 'input cells', all cells
            and from the 'n_symbols' dictionary
    """
	dictionary = deserialize(joinpath(@__DIR__,"dictionaries",stim.dictionary*".dict"))
	words = []
	phonemes=[]
	seq_length = 0

	## create a random sequence of words and their
	## phones
	lemmas = Dict()
	while seq_length < stim.seq_length
		entry = rand(dictionary)
		word  = entry[1]
		phs  = entry[2]
		push!(lemmas, word=>phs)
		for ph in phs
			if seq_length +1 < stim.seq_length 
				push!(phonemes,ph)
				push!(words,word)
				seq_length +=1
			end

		end
	end

	## Count the number of words and their symbols
	all_words = Set(words)
	all_phonemes = Set(phonemes)
	stim.symbols = length(all_words) + length(all_phonemes)

	## create arbitrary mappings
	## between numbers and phonemes
	mapping = Dict()
	r_mapping = Dict()
	for (n,s) in enumerate(all_words)
		push!(mapping,n=>s)
		push!(r_mapping,s=>n)
	end
	for (n,s) in enumerate(all_phonemes)
		n = n +length(all_words)
		push!(mapping,n=>s)
		push!(r_mapping,s=>n)
	end

	## Add the null symbol
	stim.symbols += 1
	null = stim.symbols
	push!(r_mapping,"_"=>null )
	push!(mapping, null => "_" )
	push!(lemmas,"_"=>"")
	println(null)

	## create the populations
	## sequence from the initial word sequence
	sequence = zeros(Int64,2,seq_length)
	for (n,(w,p)) in enumerate(zip(words,phonemes))
		sequence[1, n]=r_mapping[w]
		sequence[2, n]=r_mapping[p]
	end

	## obtain the populations with the dendritic
	## characteristics
    if !(stim.input ∈ ["asymmetric", "symmetric"])
		error("stim.input must be 'symmetric' or 'asymmetric'")
	else
    connections, dendrites = dendritic_connections("asymmetric", net.tripod, stim)
	end

	## Set null connections to the null symbol
	connections[null] = []
    return SeqEncoding(connections, dendrites, sequence, mapping, lemmas, null)#, pop_to_symbol, symbol_to_pop)
end

function randomize_sequence(seq::SeqEncoding, stim::StimParams)
    """
	Get a sequence and produce a new random sequence with the same words and
	the length defined in the stimulus parameters
    """
	lemmas = seq.lemmas
	mapping = seq.mapping
	dendrites= seq.dendrites
	populations = seq.populations
	stim.seq_length


	if !("_" in keys(lemmas))
		println("add NULL input")
		null = length(mapping)+1
		push!(lemmas,"_"=>"")
		push!(mapping, null => "_" )
		push!(populations,[])
		push!(dendrites,zeros(2,1))
		@assert(length(populations)==null)

	else
		null = length(mapping)
		@assert(length(populations)==null)
		@assert(populations[null]==[])
	end


	seq_length = 0
	words = []
	phonemes=[]
	## draw a neww word from the set the network has seen

	while seq_length < stim.seq_length
		entry = rand(lemmas)
		word  = entry[1]
		phs  = entry[2]
		for ph in phs
			if seq_length < stim.seq_length
				push!(phonemes,ph)
				push!(words,word)
				seq_length +=1
			end
		end
	end

	r_mapping = reverse_dictionary(mapping)
	sequence = zeros(Int64,2,seq_length)
	for (n,(w,p)) in enumerate(zip(words,phonemes))
		sequence[1, n]=r_mapping[w]
		sequence[2, n]=r_mapping[p]
	end

    return SeqEncoding(populations, dendrites, sequence, mapping, lemmas, null)
end

function null_sequence(seq::SeqEncoding, stim::StimParams)
    """
	Get a sequence and produce a new random sequence with the same words and
	the length defined in the stimulus parameters
    """
	@assert(length(seq.populations)==seq.null)
	@assert(seq.populations[seq.null]==[])
	sequence = zeros(Int64,2,stim.seq_length)
	for n in 1:stim.seq_length
		sequence[1, n]= seq.null
		sequence[2, n]= seq.null
	end

    return SeqEncoding(seq.populations, seq.dendrites, sequence, seq.mapping, seq.lemmas, seq.null)
end


function reverse_dictionary(dictionary)
	reverse = Dict()
	for key in keys(dictionary)
		push!(reverse, dictionary[key]=>key)
	end
	return reverse
end


function get_phonemes(seq::SeqEncoding)
	sort!(collect(Set(seq.sequence[2,:])))
end

function get_words(seq::SeqEncoding)
	sort!(collect(Set(seq.sequence[1,:])))
end
