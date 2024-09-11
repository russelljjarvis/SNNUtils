
function make_special_word_dict(allwords)
    swd = Dict{Symbol,Word}(
        :s => allwords[findfirst(w -> getfield(w, :word) == "-s", allwords)],
        :ed => allwords[findfirst(w -> getfield(w, :word) == "-ed", allwords)],
        #:on => allwords[findfirst(w->getfield(w,:word)=="on", allwords)],
        :by => allwords[findfirst(w -> getfield(w, :word) == "by", allwords)],
        :is => allwords[findfirst(w -> getfield(w, :word) == "is", allwords)],
        :EOS => allwords[findfirst(w -> getfield(w, :word) == ".", allwords)],
        :the => allwords[findfirst(w -> getfield(w, :word) == "the", allwords)],
        :a => allwords[findfirst(w -> getfield(w, :word) == "a", allwords)],
    )
end

"""
define your word types and collect the words
"""
function make_word_type_dict(allwords)
    wt = Dict{Symbol,Vector{Word}}(
        #:det      => collect_words_of_type( allwords, Word("",[],["determiner"],[]) ),
        :nouns => collect_words_of_type(allwords, Word("", [], ["noun"], [], [])),
        :animate =>
            collect_words_of_type(allwords, Word("", [], ["noun"], ["animate"], [])),
        :human =>
            collect_words_of_type(allwords, Word("", [], ["noun"], ["human"], [])),
        :agent =>
            collect_words_of_type(allwords, Word("", [], ["noun"], [], ["agent"])),
        :chase => collect_words_of_type(allwords, Word("chase", [], ["verb"], [], [])),
        :eat => collect_words_of_type(allwords, Word("eat", [], ["verb"], [], [])),
        :kick => collect_words_of_type(allwords, Word("kick", [], ["verb"], [], [])),
        :pet => collect_words_of_type(allwords, Word("pet", [], ["verb"], [], [])),
        :drink => collect_words_of_type(allwords, Word("drink", [], ["verb"], [], [])),
        :drinkable =>
            collect_words_of_type(allwords, Word("", [], ["noun"], [], ["drinkable"])),
        :chasable =>
            collect_words_of_type(allwords, Word("", [], ["noun"], [], ["chasable"])),
        :pettable =>
            collect_words_of_type(allwords, Word("", [], ["noun"], [], ["pettable"])),
        :kickable =>
            collect_words_of_type(allwords, Word("", [], ["noun"], [], ["kickable"])),
        :edible =>
            collect_words_of_type(allwords, Word("", [], ["noun"], [], ["edible"])),
    )
end
