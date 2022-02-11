# using CSV
# words = "/home/cocconat/Documents/Research/phd_project/simulations/language/1.Language Generator/Words/wordfeatconstr.csv"
# words = "Words/wordfeatconstr.csv"
# using Serialization
# function get_dictionary()
#
#     dictionary=Dict()
#     for entry in CSV.File(words)
#         word = entry.word
#         phonology = entry.phonology
#         try
#             phonology = split(phonology)
#         catch
#             phonology = ""
#         end
#         push!(dictionary, word => phonology )
#     end
#     return dictionary
# end
#
# dictionary = get_dictionary()
#
#
# serialize("words.dict", dictionary)
