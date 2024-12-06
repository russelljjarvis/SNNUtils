using JSON

function import_bioseq_tasks(generator_path, task_path)
    task_list = []
    generators_list = []
    json_files = filter(x -> occursin(".json", x), readdir(generator_path))
    for json_file in json_files
        file_path = joinpath(task_path, json_file)
        file = open(file_path)
        dict_data = JSON.parse(file)
        close(file)
        push!(task_list, dict_data)
    end

    json_files = filter(x -> occursin(".json", x), readdir(task_path))
    for json_file in json_files
        file_path = joinpath(generator_path, json_file)
        file = open(file_path)
        dict_data = JSON.parse(file)
        close(file)
        push!(generators_list, dict_data)
    end

    experiment = []
    for (g, t) in zip(generators_list, task_list)
        push!(experiment, (task=t,info=g))
    end
    return experiment
end

function bioseq_epochs(experiment, stage)
    epochs = []
    for epoch in keys(experiment.task[stage])
        push!(epochs, experiment.task[stage][epoch])
    end
    return  epochs
end

function make_unique_sequence(epochs)
    @assert all(length(epoch) == length(epochs[1]) for epoch in epochs )
    interval_length = maximum(length.(epochs)) +1
    sequence = Vector{String}()
    for epoch in epochs
        epoch_length = length(epoch)
        add_silence = interval_length - epoch_length
        append!(sequence, epoch)
        for _ in 1:add_silence
            append!(sequence, ["_"])
        end
    end
    @assert(all(length(collection) == length(epochs[1]) for collection in epochs))
    return sequence
end


function bioseq_lexicon(;experiment, duration::Float32=50.f0, kwargs...)
    dictionary = Dict{Symbol, Vector{Symbol}}()
    for w in experiment.info["task"]["test_string_set"]
        push!(dictionary, Symbol(join(w))=>[Symbol(p) for p in w])
    end
    words = keys(dictionary) |> collect |> sort
    phonemes = unique(Symbol.(experiments[1].info["task"]["g_strings"][1])) |> collect |> sort
    silence = :_

    @assert unique(phonemes) ==  union(vcat(values(dictionary)...)) "Phonemes do not match the dictionary"
    return (dict=dictionary, 
            symbols=(phonemes = phonemes, 
            words = words), 
            ph_duration = duration, 
            silence = silence)
end

function seq_bioseq(;experiment, stage::String, kwargs...) 
    lexicon = bioseq_lexicon(experiment=experiment; kwargs...)
    @unpack phonemes, words = lexicon.symbols
    @unpack ph_duration, silence = lexicon

    ## Get the stage sequence
    epochs = bioseq_epochs(experiment, stage)
    sequence_phonemes = make_unique_sequence(epochs)
    seq_length = length(sequence_phonemes)
    
    sequence = Matrix{Any}(fill(silence, 3, seq_length))
    sequence[2, :] = Symbol.(sequence_phonemes)
    for (n, p) in enumerate(sequence_phonemes)
        for  w in words
            _w = string(w)
            _p = string(p)
            !startswith(_w, _p) && continue
            (n + length(_w) > seq_length) && continue
            my_w = join(sequence_phonemes[n:n+length(_w)-1])
            if  my_w== _w
                sequence[1, n:n+length(_w)-1] .= w
                break
            end
        end
    end
    sequence[3, :] .= ph_duration
    line_id = (phonemes=2, words=1, duration=3)
    sequence = (;lexicon...,
                sequence=sequence,
                line_id = line_id)

end

