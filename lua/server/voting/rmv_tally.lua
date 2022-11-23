local VOTE_SCORES = {}


local function createVoteScoreArray(maps)
    for _, mapName in pairs(maps) do
        VOTE_SCORES[mapName] = 0
    end
    VOTE_SCORES[game.GetMap()] = 0
end

local function countVotes(playerVotes, allMaps, noVoteToRandom)
    for _, map in pairs(playerVotes) do
        if map == "random" or (noVoteToRandom and map == -1) then
            local randomVote = math.random(1, #allMaps)
            VOTE_SCORES[allMaps[randomVote]] = VOTE_SCORES[allMaps[randomVote]] + 1
        elseif type(VOTE_SCORES[map]) == "number" then
            VOTE_SCORES[map] = VOTE_SCORES[map] + 1
        elseif map == "extend" then
            VOTE_SCORES[game.GetMap()] = VOTE_SCORES[game.GetMap()] + 1
        end
    end
end

local function getVoteLeaders()
    local leaders = {}
    local leaderVoteCount = 0

    for map, votes in pairs(VOTE_SCORES) do
        if votes > leaderVoteCount then
            leaderVoteCount = votes
            leaders = {map}
        elseif votes == leaderVoteCount then
            leaders[#leaders + 1] = map 
        end
    end

    return leaders
end

local function selectLeader()
    local leaders = getVoteLeaders()
    local nextMap = leaders[1]
    if #leaders > 1 then
        nextMap = leaders[math.random(1, #leaders)]
    end
    return nextMap
end


function processVotes(playerVotes, allMaps, noVoteToRandom)
    createVoteScoreArray(allMaps)
    countVotes(playerVotes, allMaps, noVoteToRandom)
    if RMV_CONFIG["DEBUG_MODE"] then
        PrintDebugTable("VOTE RESULTS", VOTE_SCORES)
    end
    nextMap = selectLeader()
    return nextMap
end
