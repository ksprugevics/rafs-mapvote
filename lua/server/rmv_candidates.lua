local MAP_POOL = {}


local function deleteRecentMapsFromMapPool(recentMaps)
    for recentMap, _ in pairs(recentMaps) do
        local indice = table.KeyFromValue(MAP_POOL, recentMap)
        if indice ~= nil then 
            MAP_POOL[indice] = nil
        end
    end
end

local function sortMapPoolByTimesPlayed(timesPlayed)
    local function _sortByValue(a, b)
        return timesPlayed[a] > timesPlayed[b]
    end
            
    local mapIndicesSorted = table.GetKeys(timesPlayed)
    table.sort(mapIndicesSorted, _sortByValue)
    return mapIndicesSorted
end

local function selectPopularMapsFromMapPool(sortedMapIndices, timesPlayed)
    local popularMaps = {}
    local mapLimit = 3
    for _, map in pairs(sortedMapIndices) do
        if not table.HasValue(MAP_POOL, map) then continue end
        popularMaps[#popularMaps + 1] = map
        if #popularMaps == mapLimit then break end
    end
    return popularMaps
end

local function selectRandomMapsFromMapPool(sortedMapIndices, currentCandidates)
    local randomMaps = {}
    local mapLimit = 3
    while #randomMaps < 3 do
        local randomMap = sortedMapIndices[math.random(mapLimit + 1, #sortedMapIndices)]
        if not table.HasValue(MAP_POOL, randomMap) then continue end
        if table.HasValue(currentCandidates, randomMap) then continue end
        if table.HasValue(randomMaps, randomMap) then continue end
        randomMaps[#randomMaps + 1] = randomMap
    end
    return randomMaps
end


function GenerateVoteCandidates(maps, history, stats)
    MAP_POOL = table.Copy(maps)
    if #MAP_POOL < 6 then return maps end
    deleteRecentMapsFromMapPool(history)
    if #MAP_POOL < 6  then return maps end

    local mapIndicesSorted = sortMapPoolByTimesPlayed(stats)
    local popularMaps = selectPopularMapsFromMapPool(mapIndicesSorted, stats)
    local randomMaps = selectRandomMapsFromMapPool(mapIndicesSorted, popularMaps)
    return table.Copy(table.Add(popularMaps, randomMaps))
end