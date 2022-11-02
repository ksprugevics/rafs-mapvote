if SERVER then

   -- Creates a list of map vote candidates
   function GenerateVoteCandidates(maps, history)

    local mapPool = table.Copy(maps)
    local popularMaps = {}
    local underdogMaps = {}

    -- Deletes maps that have been recently played from the map pool (cooldown)
    for map, _ in pairs(mapPool) do
        for map_history, _ in pairs(history) do
            if map == map_history then
                mapPool[map] = nil
                break
            end
        end
    end

    local mapCount = table.Count(mapPool)

    if mapCount < 6 then
        local allMaps = {}
        local mapCounter = 1

        -- Creates a table with all maps
        for map, votes in pairs(maps) do
            allMaps[mapCounter] = map
            mapCounter = mapCounter + 1
        end
        return allMaps
    end

    -- Select the 3 most popular maps
    -- Creates a list of keys(map names)
    local keyList = {}
    for name, _ in pairs(mapPool) do
        keyList[#keyList + 1] = name
    end

    -- Comparison function, that compares values of keys
    local function sortByValue(a, b)
        return mapPool[a] > mapPool[b]
    end
    
    -- Sort key list with our comparison function
    table.sort(keyList, sortByValue)

    -- The 3 most played maps are added to the popular map pool
    for k = 1, 3 do
        popularMaps[keyList[k]] = mapPool[keyList[k]]
    end

    -- Selects 3 "underdog" maps on random
    local mapCounter = 0
    while mapCounter < 3 do
        
        -- Generate a random map
        local randomMap = keyList[math.random(4, #keyList)]
        local isMapUsed = false
        
        -- Checks if map has been previously chosen
        for map, _ in pairs(underdogMaps) do
            if map == randomMap then 
                isMapUsed = true
                break
            end
        end
        
        if not isMapUsed then
            mapCounter = mapCounter + 1
            underdogMaps[randomMap] = mapPool[randomMap]
        end
    end

    local allMaps = {}
    local mapCounter = 1

    -- Creates a table with all maps
    for map, _ in pairs(popularMaps) do
        allMaps[mapCounter] = map
        mapCounter = mapCounter + 1
    end

    for map, _ in pairs(underdogMaps) do
        allMaps[mapCounter] = map
        mapCounter = mapCounter + 1
    end

    return allMaps
    end

    -- Sends the newest votes to the client
    function SendVotesToClient(playerVotes)
        net.Start('REFRESH_VOTES')
        net.WriteTable(playerVotes)
        net.Broadcast()
    end

    -- Tallies the votes
    function TallyVotes(playerVotes, allMaps)

        local mapVotes = {}
        local leader = allMaps[1]

        -- Generate map-votes table
        for _, mapName in pairs(allMaps) do
            mapVotes[mapName] = 0
        end

        -- Tallies up votes
        for _, map in pairs(playerVotes) do
            if map == 'random' then
                local randomVote = math.random(1, #allMaps)
                mapVotes[allMaps[randomVote]] = mapVotes[allMaps[randomVote]] + 1
            elseif type(mapVotes[map]) == 'number' then
                mapVotes[map] = mapVotes[map] + 1
            end
        end

        -- Declares a winner
        for map, votes in pairs(mapVotes) do
            if mapVotes[map] > mapVotes[leader] then
                leader = map
            end
        end

        Log('Vote winner: ' .. leader)
        return leader
    end
end