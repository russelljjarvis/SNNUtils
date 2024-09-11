function simple_words()
    words = Dict()
    rules = Dict()
    word_length = 5
    _words = ["dog", "goal", "poll", "lop", "log", "doll"]
    for word in _words
        phs = [p for p in word]
        push!(words, lowercase(word) => phs)
    end
    return words, rules
end

function lkd2014_generator(n)
    words = Dict()
    rules = Dict()
    for n = 1:n
        word = "w_$n"
        phs = [n]
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
            word1 = [root; input[randperm(max_length)[1:max_length-n]]...]
            word2 = [root; input[randperm(max_length)[1:max_length-n]]...]
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
end

using Serialization

##

function create_lexicon(; name::String, words, rules)
    serialize(joinpath(dic_path, "$name.dict"), words)
    serialize(joinpath(dic_path, "$name.rules"), rules)
end
function create_lexicons()
    data = dic_path
    words, rules = lkd2014_generator()
    serialize(joinpath(data, "lkd.dict"), words)
    serialize(joinpath(data, "lkd.rules"), rules)

    words, rules = simple_words()
    serialize(joinpath(data, "simple.dict"), words)
    serialize(joinpath(data, "simple.rules"), rules)

    words, rules = unique_words(string.(collect("A"[1]:"Z"[1])))
    serialize(joinpath(data, "unique.dict"), words)
    serialize(joinpath(data, "unique.rules"), rules)

    words, rules = non_unique_words(string.(collect("A"[1]:"Z"[1])))
    serialize(joinpath(data, "non_unique.dict"), words)
    serialize(joinpath(data, "non_unique.rules"), rules)

    words, rules = palyndromes(string.(collect("A"[1]:"Z"[1])))
    serialize(joinpath(data, "palyndromes.dict"), words)
    serialize(joinpath(data, "palyndromes.rules"), rules)

    words = random_dict()
    serialize(joinpath(data, "random.dict"), words)
end
