using DrWatson
@quickactivate "Tripod"
using CSV, DataFrames, DataFramesMeta

##
function create_lexicon(filename;)
    for letters in [true, false]
        config = letters
        produce_or_load(
            datadir("dictionaries"),
            filename = letters ? filename * "_lett" : filename,
            config,
            force = true,
        ) do config
            lexemes_path = datadir("lexicon")
            lexicon = CSV.read(
                open(joinpath(lexemes_path, filename * ".tsv")),
                DataFrame,
                header = false,
            )
            for (c, name) in zip(names(lexicon), ["words", "phonemes"])
                rename!(lexicon, c => name)
            end
            if config
                @rtransform! lexicon :phonemes = [string(p) for p in :words]
            else
                @rtransform! lexicon :phonemes =
                    [string(p) for p in split(:phonemes) if p !== ' ']
            end
            words = Dict(
                lowercase.(word) => phoneme for
                (word, phoneme) in zip(lexicon.words, lexicon.phonemes)
            )
            phonemes = lexicon.phonemes
            @show lexicon.phonemes
            return @strdict words = words phonemes = phonemes name = filename
        end
    end
end

function load_lexicon(filename; letters = false)
    filename = (letters ? filename * "_lett" : filename) |> x -> string(x, ".jld2")
    filename = datadir("dictionaries", filename)
    JLD2.load(filename)["words"]
end

##
# config = false
empty =
    @strdict words = Dict{String,Vector{String}}("_" => ["_"]) phonemes = [] name = "empty"
save(datadir("dictionaries", "empty.jld2"), empty)
save(datadir("dictionaries", "empty_lett.jld2"), empty)
##
create_lexicon("ganong_ve")
create_lexicon("ganong_la")
create_lexicon("simple")
create_lexicon("long")
create_lexicon("digits")
create_lexicon("TISK")
create_lexicon("TIMIT")
create_lexicon("identity")
create_lexicon("no_overlap")

for dic in ["abba", "abc", "empty", "AB"]
    try
        create_lexicon(dic)
    catch
        @error "Lexicon $dic not found"
    end
end

##
function word_generator(n = 20)
    s = Vector{Char}(collect('A':'M'))
    words = Dict()
    rules = Dict()
    for n = 1:n
        _w = randstring(s, 6)
        word = lowercase(_w)
        phs = collect(_w)
        push!(words, word => phs)
    end
    return words, rules
end

function lkd2014_generator(n = 20)
    words = Dict()
    rules = Dict()
    for n = 1:n
        word = "w_$n"
        phs = ["p_$n"]
        push!(words, word => phs)
    end
    return words, rules
end

function unique_words(input::Array{String}, max_length = 5)
    words = Dict()
    rules = Dict()
    word_length = 5
    for n = 1:5
        word = repeat(input[n], word_length)
        phs = [input[n] * string(p) for p = 1:word_length]
        push!(words, lowercase(word) => phs)
    end
    return words, rules
end

function non_unique_words(input::Array{String}, max_length = 5)
    words = Dict()
    rules = Dict()
    for n = 2:max_length
        for _ = 1:2
            root = shuffle(input)[1:n]
            word1 = [root; input[randperm(max_length)[1:(max_length-n)]]...]
            word2 = [root; input[randperm(max_length)[1:(max_length-n)]]...]
            push!(words, lowercase(join(word1)) => [word1...])
            push!(words, lowercase(join(word2)) => [word2...])
            push!(rules, lowercase(join(word1)) => lowercase(join(word2)))
        end
    end
    return words, rules
end

function palyndromes(input::Array{String}, max_length = 5)
    words = Dict()
    rules = Dict()
    for n = 2:max_length
        for _ = 1:2
            word1 = shuffle(input)[1:n]
            word2 = reverse(word1)
            push!(words, lowercase(join(word1)) => [word1...])
            push!(words, lowercase(join(word2)) => [word2...])
            push!(rules, lowercase(join(word1)) => lowercase(join(word2)))
        end
    end
    return words, rules
end

function random_dict(dict_length = 20)
    words = Dict()
    for n = 1:dict_length
        push!(words, string(n) => [string(n)])
    end
    return words
    return words
end


function get_dictionary_path(dictionary_name)
    dict_path = datadir("dictionaries")
    dictionary = joinpath(dict_path, "$(dictionary_name).jld2")
    @assert isfile(dictionary) "Dictionary $(dictionary_name) not found"
    # words = join(collect(keys(load(dictionary)["words"])), ", ")
    # @info "Running with dictionary: $(dictionary_name)\nWords: $(words...)"
    return dictionary, dictionary_name
end
