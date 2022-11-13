local function removeMapSubfixes(mapList)
    local temp = {}
    for i, map in pairs(mapList) do
        temp[i] = map:sub(1, -5)
    end
    return temp
end

local function filterMapListByPrefixes(mapList, prefixes)
    local temp = {}
    local counter = 0
    for _, prefix in pairs(prefixes) do
        for i, map in pairs(mapList) do
            if string.StartWith(map, prefix) then
                counter = counter + 1
                temp[counter] = map
            end
        end
    end
    return temp
end

local function importLocalMapStats(fullPath)
    local mapStats = {}
    if file.Exists(fullPath, "DATA") then
        mapStats = util.JSONToTable(file.Read(fullPath, "DATA"))
    else 
        PrintTableRow("Local map stats file not found. Generating..")
    end
    return mapStats
end

local function populateMapStats(mapStats, mapList)
    for _, map in pairs(mapList) do
        if mapStats[map] == nil then
            mapStats[map] = 0
        end
    end
end

local function incrementCurrentMapStats(mapStats)
    local currentMap = game.GetMap()
    if mapStats[currentMap] ~= nil then
        mapStats[currentMap] = mapStats[currentMap] + 1
    end
end

local function importLocalHistory(fullPath)
    local mapHistory = {}
    if file.Exists(fullPath, 'DATA') then
        mapHistory = util.JSONToTable(file.Read(fullPath, 'DATA'))
    else 
        PrintTableRow("Local history file not found. Generating..")
    end
    return mapHistory
end

local function reduceCooldown(mapHistory)
    for map, cooldown in pairs(mapHistory) do
        mapHistory[map] = cooldown - 1
        if cooldown == 0 then
            mapHistory[map] = nil
        end
    end
end


function generateLocalMapList(configMaps, mapPrefixes)
    local localMaps = removeMapSubfixes(file.Find('maps/*.bsp', 'GAME'))
    if mapPrefixes ~= nil then
        localMaps = filterMapListByPrefixes(localMaps, mapPrefixes)
    end
    return localMaps
end

function generateMapStats(fullPath, mapList)
    local mapStats = importLocalMapStats(fullPath)
    populateMapStats(mapStats, mapList)
    incrementCurrentMapStats(mapStats)
    file.Write(fullPath, util.TableToJSON(mapStats))
    return mapStats
end

function generateMapHistory(fullPath, cooldown)
    local mapHistory = importLocalHistory(fullPath)
    mapHistory[game.GetMap()] = cooldown
    reduceCooldown(mapHistory)
    file.Write(fullPath, util.TableToJSON(mapHistory))
    return mapHistory
end
