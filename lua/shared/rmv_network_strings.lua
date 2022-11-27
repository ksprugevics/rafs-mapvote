RMV_NETWORK_STRINGS   = {
    ["startVote"]     = "RMV_START_MAPVOTE",
    ["userChoice"]    = "RMV_MAP_CHOICE",
    ["refreshVotes"]  = "RMV_REFRESH_VOTES",
    ["nextMap"]       = "RMV_NEXT_MAP",
    ["info"]          = "RMV_SEND_INFO",
    ["allMaps"]       = "RMV_SEND_ALL_MAPS",
    ["requestMapVote"] = "RMV_REQUEST_MAP_VOTE"
}

local function checkIsValidNetworkString(networkString)
    if networkString == nil or not table.HasValue(RMV_NETWORK_STRINGS, networkString) then return false end
    return true
end

local function checkIsValidTable(tableToTest)
    if tableToTest == nil or table.IsEmpty(tableToTest) == true then return false end
    return true
end


if SERVER then
    for keyword, networkString in pairs(RMV_NETWORK_STRINGS) do
        util.AddNetworkString(networkString)
    end
    
    function rmvBroadcastString(networkString, stringToSend)
        if stringToSend == nil or not checkIsValidNetworkString(networkString) then return end
        net.Start(networkString)
        net.WriteString(stringToSend)
        net.Broadcast()
    end

    function rmvBroadcastTable(networkString, tableToSend)
        if not checkIsValidTable(tableToSend) or not checkIsValidNetworkString(networkString) then return end
        net.Start(networkString)
        net.WriteTable(tableToSend)
        net.Broadcast()
    end

    function rmvSendTableToClient(networkString, tableToSend, ply)
        if not checkIsValidTable(tableToSend) or not checkIsValidNetworkString(networkString) then return end
        net.Start(networkString)
        net.WriteTable(tableToSend)
        net.Send(ply)
    end

    function rmvBroadcastMapvote(networkString, candidateMaps, totalVoteTime, remainingVoteTime)
        if not checkIsValidNetworkString(networkString) then return end
        if not checkIsValidTable(candidateMaps) then return end
        if totalVoteTime == nil or remainingVoteTime == nil then return end
        net.Start(networkString)
        net.WriteTable(candidateMaps)
        net.WriteFloat(totalVoteTime)
        net.WriteFloat(remainingVoteTime)
        net.Broadcast()
    end

    function rmvSendVoteInfoToClient(networkString, candidateMaps, totalVoteTime, remainingVoteTime, ply)
        if not checkIsValidNetworkString(networkString) then return end
        if not checkIsValidTable(candidateMaps) then return end
        if totalVoteTime == nil or remainingVoteTime == nil then return end
        net.Start(networkString)
        net.WriteTable(candidateMaps)
        net.WriteFloat(totalVoteTime)
        net.WriteFloat(remainingVoteTime)
        net.Send(ply)
    end

    function rmvSendMapListAndHistory(networkString, maps, history, ply)
        if not checkIsValidNetworkString(networkString) then return end
        if not checkIsValidTable(maps) then return end
        if not checkIsValidTable(history) then return end
        net.Start(networkString)
        net.WriteTable(maps)
        net.WriteTable(history)
        net.Send(ply)
    end
end


if CLIENT then
    function rmvSendStringToServer(networkString, stringToSend)
        if stringToSend == nil or not checkIsValidNetworkString(networkString) then return end
        net.Start(networkString)
        net.WriteString(stringToSend)
        net.SendToServer()
    end
end
