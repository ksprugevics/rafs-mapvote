RMV_NETWORK_STRINGS   = {
    ["startVote"]     = "RMV_START_MAPVOTE",
    ["userChoice"]    = "RMV_MAP_CHOICE",
    ["refreshVotes"]  = "RMV_REFRESH_VOTES",
    ["nextMap"]       = "RMV_NEXT_MAP"
}

if SERVER then
    for keyword, networkString in pairs(RMV_NETWORK_STRINGS) do
        util.AddNetworkString(networkString)
    end
end