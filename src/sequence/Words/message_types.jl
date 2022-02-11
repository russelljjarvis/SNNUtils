"""
define your messages here using
wt  word_type_dict   (items are Word arrays)
"""
function make_messages_dict(wt::Dict{Symbol,Vector{Word}})
    md = Dict{Symbol,Message}(
    :agent_chase_chasable  => Message(wt[:agent],wt[:chase],wt[:chasable]),
    :agent_eat_edible     => Message(wt[:animate],wt[:eat],wt[:edible]),
    :human_kick_kickable   => Message(wt[:human],wt[:kick],wt[:kickable]),
    :human_pet_pettable    => Message(wt[:human],wt[:pet],wt[:pettable]),
    :agent_drink_drinkable => Message(wt[:agent],wt[:drink],wt[:drinkable]),
    )
end
