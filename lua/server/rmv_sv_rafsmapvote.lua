local candidates = {}
local playerVotes = {}
local nextMap = nil
local voteStarted = false
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
        -- timer.Simple(5, function()
        --     RunConsoleCommand("changelevel", nextMap)
        -- end)
    end)
    Log("Vote started.")
    voteStarted = true
end


function StartRafsMapvote(customTimer, votesRandom)
    local voteTime, noVotesAsRandom = processCustomMapVoteParams(customTimer, votesRandom)

    if voteStarted == true then
        rmvBroadcastMapvote(RMV_NETWORK_STRINGS["startVote"], candidates, voteTime, timer.TimeLeft("RMV_VOTE_TIMER"))
        rmvBroadcastTable(RMV_NETWORK_STRINGS["refreshVotes"], playerVotes)
    else
        createPlayerVotesArray()
        createVoteTimer(voteTime, true)
        rmvBroadcastMapvote(RMV_NETWORK_STRINGS["startVote"], candidates, voteTime, timer.TimeLeft("RMV_VOTE_TIMER"))
    end
end

net.Receive(RMV_NETWORK_STRINGS["userChoice"], function(len, ply)
    local newChoice = net.ReadString()
    local oldChoice = playerVotes[ply]
    playerVotes[ply] = newChoice
    if RMV_CONFIG["DEBUG_MODE"] then
        LogDebug(ply:GetName() .. " changed their vote from: " .. oldChoice .. " to: " .. newChoice)
    end
    rmvBroadcastTable(RMV_NETWORK_STRINGS["refreshVotes"], playerVotes)
end)

