if SERVER then

   -- Creates a list of map vote candidates
   function GenerateVoteCandidates(maps, history, stats)

        local mapPool = table.Copy(maps)
        local candidates = {}

        if #mapPool <= 6 then
            return mapPool
        end

        -- Deletes maps that have been recently played from the map pool (cooldown)
        for i, map in pairs(mapPool) do
            for map_history, _ in pairs(history) do
                if map == map_history then
                    mapPool[i] = nil
                    break
                end
            end
        end

        if #mapPool <= 6 then
            return mapPool
        end

        local mapIndicesSorted = {}
        local counter = 1
        for name, _ in pairs(stats) do
            mapIndicesSorted[counter] = name
            counter = counter + 1
        end

        -- Comparison function, that compares map times played in stats
        local function sortByValue(a, b)
            return stats[a] > stats[b]
        end
                
        -- Sort key list with our comparison function
        table.sort(mapIndicesSorted, sortByValue)
        
        -- Take 3 most popular maps
        local counter = 1
        for i, map in pairs(mapIndicesSorted) do
            if not table.HasValue(mapPool, map) then continue end
            candidates[counter] = map
            counter = counter + 1
            if counter == 4 then break end
        end

        -- Take 3 random maps afterwards
        local counter = 4
        while counter <= 6 do
            local randomMap = mapIndicesSorted[math.random(4, #mapIndicesSorted)]
            if not table.HasValue(mapPool, randomMap) then continue end
            if table.HasValue(candidates, randomMap) then continue end
            candidates[counter] = randomMap
            counter = counter + 1

        end
        return candidates
    end

    -- Sends the newest votes to the client
    function SendVotesToClient(playerVotes)
        net.Start(RMV_NETWORK_STRINGS["refreshVotes"])
        net.WriteTable(playerVotes)
        net.Broadcast()
    end

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