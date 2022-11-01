if SERVER then

    -- Creates a default config file
    function GenerateConfigFile(fullPath)
        local settings = {}

        -- Directory for storing maplist, history and thubmnails
        -- !!! This is under the data/ directory!!!
        -- True path example: garrysmod/data/rafsmapvote/
        settings['DATA_DIR'] = 'rafsmapvote/'

        -- Which maps to include in the map pool. Must be under garrysmod/maps/
        -- (The map should actually be in the directory for it to show up)
        -- Adding/removing maps requires a restart of the server or a manual re-run of the server script
        settings['MAPS'] = {
            'de_dust2',
            'cs_office'
        }

        -- Place thumbnails here
        -- !!! This is under the data/ directory!!!
        -- True path example: garrysmod/data/rafsmapvote/thumbnails/
        settings['THUMBNAIL_DIR'] = settings['DATA_DIR'] .. 'thumbnails/'
    
        -- Number of maps before a map can show up on the mapvote again
        settings['MAP_COOLDOWN'] = 3
    
        -- Voting period in seconds
        settings['TIMER'] = 20 + 1
    
        file.Write(fullPath, util.TableToJSON(settings))
    end

    function SetupDataDir()

        local settings = {}
        local dataPath = 'rafsmapvote/'
        local configPath = dataPath .. 'config_rafsmapvote.json' 

        -- Creates data directory
        if not file.Exists(dataPath, 'DATA') then
            file.CreateDir(dataPath)
        end

        if not file.Exists(configPath, 'DATA') then
            print('[MAPVOTE] Config file not found, generating config..')
            GenerateConfigFile(configPath)
        end
        
        if not file.Exists(dataPath .. '/thumbnails', 'DATA') then
            file.CreateDir(dataPath .. '/thumbnails')
        end
        
        return util.JSONToTable(file.Read(configPath))
    end

    -- Creates a file that counts the times a map has been played
    function GenerateMapList()

        local oldMapList = {}
        if file.Exists(settings['DATA_DIR'] .. 'maplist.json', 'DATA') then
            oldMapList = util.JSONToTable(file.Read(settings['DATA_DIR'] .. 'maplist.json', 'DATA'))
        end

        local localMaps = {}
        for _, v in pairs(file.Find('maps/*.bsp', 'GAME')) do
            -- remove file extension
            local shortened = v:sub(1, -5)
            localMaps[shortened] = 0
        end

        local maps = {}
        for _, v in pairs(settings['MAPS']) do
            if localMaps[v] ~= nil then
                maps[v] = 0
                if oldMapList ~= nil then
                    if oldMapList[v] ~= nil then
                        maps[v] = oldMapList[v]                        
                    end
                end
            end
        end

        file.Write(settings['DATA_DIR'] .. 'maplist.json', util.TableToJSON(maps))
    end

    -- Creates a file that keeps track of recently played maps and their remaining cooldown
    function GenerateMapHistory()
        local mapHistory = {}
        mapHistory[game.GetMap()] = 0
        file.Write(settings['DATA_DIR'] .. 'maphistory.json', util.TableToJSON(mapHistory))
    end

    -- Updates the map times played file
    function UpdateMapList()
        -- Reads map list and updates times played for current map
        local mapList = util.JSONToTable(file.Read(settings['DATA_DIR'] .. 'maplist.json', 'DATA'))
        if mapList[game.GetMap()] ~= nil then
            mapList[game.GetMap()] = mapList[game.GetMap()] + 1
            file.Write(settings['DATA_DIR'] .. 'maplist.json', util.TableToJSON(mapList))
        end
        return mapList
    end

    -- Updates the map history file
    function UpdateMapHistory()
        local mapHistory = util.JSONToTable(file.Read(settings['DATA_DIR'] .. 'maphistory.json', 'DATA'))

        -- Increment times played by 1
        for k, v in pairs(mapHistory) do
            mapHistory[k] = v + 1

            -- If a map has not been played for the cooldown amount of times it gets deleted from map history
            if v == settings[''] then
                mapHistory[k] = nil
            end
        end

        mapHistory[game.GetMap()] = 0
        file.Write(settings['DATA_DIR'] .. 'maphistory.json', util.TableToJSON(mapHistory))
        return mapHistory
    end

    -- Creates a list of map candidates
    function GenerateCandidates(maps, history, playerVotes)

        local mapPool = table.Copy(maps)
        local popularMaps = {}
        local underdogMaps = {}

        -- Deletes maps that have been recently played from the map pool
        for k, v in pairs(mapPool) do
            for m,i in pairs(history) do
                if k == m then
                    mapPool[k] = nil
                    break
                end
            end
        end

        local mapCount = 0
        for k, v in pairs(mapPool) do
            mapCount = mapCount + 1
        end
        
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
            
            -- Generate a random map name
            local randomKey = keyList[math.random(4, #keyList)]
            local okFlag = true
            
            -- Checks if map has been previously chosen
            for map_name,_ in pairs(underdogMaps) do
                if map_name == randomKey then 
                    okFlag = false
                    break
                end
            end
            
            if okFlag then
                mapCounter = mapCounter + 1
                underdogMaps[randomKey] = mapPool[randomKey]
            end
        end

        local allMaps = {}
        local mapCounter = 1

        -- Creates a table with all maps
        for map, votes in pairs(popularMaps) do
            allMaps[mapCounter] = map
            mapCounter = mapCounter + 1
        end

        for map, vote in pairs(underdogMaps) do
            allMaps[mapCounter] = map
            mapCounter = mapCounter + 1
        end

        return allMaps
    end

    -- Refreshes current vote status
    function RefreshVotes(playerVotes)
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
            print(map, votes)
            if mapVotes[map] > mapVotes[leader] then
                leader = map
            end
        end

        return leader
    end

end