local candidates = {}
local playerVotes = {}
local nextMap = nil
local voteStarted = false
local totalVoteTime = nil
local delay = false
local mapVoteTimer = nil


candidates = RMV_INIT()


local function processCustomMapVoteParams(customTimer, votesRandom)
    local voteTime = RMV_CONFIG["TIMER"]
    if customTimer ~= nil then
        voteTime = customTimer
    end
    local noVotesAsRandom = RMV_CONFIG["NO_VOTE_TO_RANDOM"]
    if votesRandom ~= nil then
        noVotesAsRandom = votesRandom
    end

    return voteTime, noVotesAsRandom
end

local function createPlayerVotesArray()
    local allPlayers = player:GetAll()
    for key, player in pairs(allPlayers) do
        playerVotes[player] = -1
    end
end

local function createVoteTimer(voteTime, debug)
    mapVoteTimer = timer.Create("RMV_VOTE_TIMER", voteTime, 1, function()
        Log("Vote time ended.")

        nextMap = processVotes(playerVotes, candidates, noVotesAsRandom)
        rmvBroadcastString(RMV_NETWORK_STRINGS["nextMap"], nextMap)
        voteStarted = false
        Log("Changing map to: " .. nextMap)
        if RMV_CONFIG["DEBUG_MODE"] then
            PrintDebugTable("Player votes", playerVotes)
        end
        timer.Simple(5, function()
            RunConsoleCommand("changelevel", nextMap)
        end)
    end)
    Log("Vote started.")
    voteStarted = true
end

local function sendVoteInfoToPlayer(ply)
    rmvSendVoteInfoToClient(RMV_NETWORK_STRINGS["startVote"], candidates, totalVoteTime, timer.TimeLeft("RMV_VOTE_TIMER"), ply)
    timer.Simple(2.7, function()
        rmvSendTableToClient(RMV_NETWORK_STRINGS["refreshVotes"], playerVotes, ply)
    end)
end


function StartRafsMapvote(customTimer, votesRandom)
    totalVoteTime, noVotesAsRandom = processCustomMapVoteParams(customTimer, votesRandom)

    if voteStarted ~= true then
        createPlayerVotesArray()
        createVoteTimer(totalVoteTime, true)
        rmvBroadcastMapvote(RMV_NETWORK_STRINGS["startVote"], candidates, totalVoteTime, timer.TimeLeft("RMV_VOTE_TIMER"))
    end
end


net.Receive(RMV_NETWORK_STRINGS["info"], function(len, ply)
    sendVoteInfoToPlayer(ply)
end)

net.Receive(RMV_NETWORK_STRINGS["allMaps"], function(len, ply)
    rmvSendMapListAndHistory(RMV_NETWORK_STRINGS["allMaps"], RMV_TOTAL_MAPLIST.MAPS, RMV_TOTAL_MAPLIST.HISTORY, ply)
end)

net.Receive(RMV_NETWORK_STRINGS["userChoice"], function(len, ply)
    local newChoice = net.ReadString()
    local oldChoice = playerVotes[ply]
    playerVotes[ply] = newChoice
    if RMV_CONFIG["DEBUG_MODE"] then
        LogDebug(ply:GetName() .. " changed their vote from: " .. oldChoice .. " to: " .. newChoice)
    end
    rmvBroadcastTable(RMV_NETWORK_STRINGS["refreshVotes"], playerVotes)
end)

net.Receive(RMV_NETWORK_STRINGS["requestMapVote"], function(len, ply)
    if not table.HasValue(RMV_CONFIG["FORCE_VOTE_USER_GROUPS"], ply:GetUserGroup()) or voteStarted then
        return
    end
    Log(ply:GetName() .. " started a mapvote from the console.")
    StartRafsMapvote()
end)

concommand.Add("rmv_start", function()
    StartRafsMapvote()
end)
