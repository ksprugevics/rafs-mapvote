if SERVER then

    -- Creates a default config file
    function GenerateConfigFile(fullPath)
        local settings = {}

        -- Directory for storing maplist, history and thubmnails
        -- !!! This is under the data/ directory!!!
        -- True path example: garrysmod/data/rafsmapvote/
        settings['DATA_DIR'] = 'rafsmapvote/'

        -- If non provided, use all maps
        settings['MAP_PREFIX'] = {
            'ttt_',
            'cs_',
            'de_'
        }

        -- If a player has not voted, their vote will go to a random map
        settings['NO_VOTE_TO_RANDOM'] = true

        -- Which maps to include in the map pool (prefix filter applies). Must be under garrysmod/maps/
        -- (The map should actually be in the directory for it to show up)
        -- Adding/removing maps requires a restart of the server or a manual re-run of the server script
        settings['MAPS'] = {
        }

        -- Place thumbnails here
        -- !!! This is under the data/ directory!!!
        -- True path example: garrysmod/data/rafsmapvote/thumbnails/
        settings['THUMBNAIL_DIR'] = settings['DATA_DIR'] .. 'thumbnails/'
    
        -- Number of maps before a map can show up on the mapvote again
        settings['MAP_COOLDOWN'] = 3
    
        -- Voting period in seconds
        settings['TIMER'] = 5 + 1

        -- Minimal players for rock the vote to be enabled
        settings['RTV_MIN'] = 3

        -- Threshold to rock the vote
        settings['RTV_PERCENT'] = 0.6

        -- Time in seconds before RTV is allowed
        settings['RTV_TIME'] = 300

        file.Write(fullPath, util.TableToJSON(settings))
    end

    -- Creates the DATA folder structure and config
    function SetupDataDir()

        local settings = {}
        local dataPath = 'rafsmapvote/'
        local configPath = dataPath .. 'config_rafs_mapvote.json' 
        local fullPathPrefix = 'garrysmod/data/'

        -- Creates data directory
        if not file.Exists(dataPath, 'DATA') then
            PrintTableRow('Data directory not found, generating..') 
            file.CreateDir(dataPath)
        end
        PrintTableRow('Data directory: ' .. fullPathPrefix .. dataPath) 
        PrintTableRow('') 


        if not file.Exists(dataPath .. '/thumbnails', 'DATA') then
            PrintTableRow('Thumbnail directory not found, generating..')
            file.CreateDir(dataPath .. '/thumbnails')
        end
        PrintTableRow('Thumbnail directory: ' .. fullPathPrefix .. dataPath .. 'thumbnails/')
        PrintTableRow('')

        if not file.Exists(configPath, 'DATA') then
            PrintTableRow('Config file not found, generating..')
            GenerateConfigFile(configPath)
        end
                
        PrintTableRow('Config file found: ' .. fullPathPrefix .. configPath)
        PrintTableRow('')
        return util.JSONToTable(file.Read(configPath))
    end

    local function FilterMapListByPrefixes(mapList, prefixes)
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

    local function RemoveMapSubfixes(mapList)
        local temp = {}
        for i, map in pairs(mapList) do
            temp[i] = map:sub(1, -5)
        end
        return temp
    end

    function GenerateMapList(configMaps, mapPrefixes)

        local localMaps = RemoveMapSubfixes(file.Find('maps/*.bsp', 'GAME'))

        -- Filter by prefixes
        if mapPrefixes ~= nil then
            localMaps = FilterMapListByPrefixes(localMaps, mapPrefixes)
        end
        
        return localMaps
    end

    function GenerateMapCount(fullPath, mapList)
        local oldMapCount = {}
        if file.Exists(fullPath, 'DATA') then
            oldMapCount = util.JSONToTable(file.Read(fullPath, 'DATA'))
        end

        for _, map in pairs(mapList) do
            if oldMapCount[map] == nil then
                oldMapCount[map] = 0
            end
        end

        local currentMap = game.GetMap()
        if oldMapCount[currentMap] ~= nil then
            oldMapCount[currentMap] = oldMapCount[currentMap] + 1
        end

        file.Write(fullPath, util.TableToJSON(oldMapCount))
        return oldMapCount
    end

    -- Creates or updates a JSON file that keeps track of recently played maps and their remaining cooldown
    function GenerateMapHistory(fullPath, cooldown)
        local mapHistory = {}
        if file.Exists(fullPath, 'DATA') then
            mapHistory = util.JSONToTable(file.Read(fullPath, 'DATA'))
        end
        
        mapHistory[game.GetMap()] = cooldown

        -- Increment times played by -1
        for map, timesPlayed in pairs(mapHistory) do
            mapHistory[map] = timesPlayed - 1
            
            -- If a map's cooldown expires, remove it from map history
            if timesPlayed == 0 then
                mapHistory[map] = nil
            end
        end

        file.Write(fullPath, util.TableToJSON(mapHistory))
        return mapHistory
    end
end