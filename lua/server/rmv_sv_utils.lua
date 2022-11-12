if SERVER then

    -- Tallies the votes
    function TallyVotes(playerVotes, allMaps, noVoteToRandom)

        local mapVotes = {}

        -- Generate map-votes table
        for i, mapName in pairs(allMaps) do
            mapVotes[mapName] = 0
        end

        -- Tallies up votes
        for _, map in pairs(playerVotes) do
            if map == 'random' then
                local randomVote = math.random(1, #allMaps)
                mapVotes[allMaps[randomVote]] = mapVotes[allMaps[randomVote]] + 1
            elseif type(mapVotes[map]) == 'number' then
                mapVotes[map] = mapVotes[map] + 1
            elseif noVoteToRandom and map == -1 then
                local randomVote = math.random(1, #allMaps)
                mapVotes[allMaps[randomVote]] = mapVotes[allMaps[randomVote]] + 1
            end
        end

        -- Calculate leaders
        local winners = {}
        local leaderVoteCount = 0

        for map, votes in pairs(mapVotes) do
            if votes > leaderVoteCount then
                leaderVoteCount = votes
                winners = {map}
            elseif votes == leaderVoteCount then
                winners[#winners + 1] = map 
            end
        end

        local nextMap = winners[1]

        -- Handle ties
        if #winners > 1 then
            nextMap = winners[math.random(1, #winners)]
        end
        
        PrintTable(mapVotes)
        Log('Vote winner: ' .. nextMap)
        return nextMap
    end
end