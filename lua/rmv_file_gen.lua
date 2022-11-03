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
            'cs_office',
            'cs_assault',
            'ttt_67thway_v3',
            'gm_construct',
            'ttt_67th_way',
            'de_nuke'
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

    -- Creates or updates a JSON file that keeps track of played maps count
    function GenerateMapList(fullPath, configMaps)
        local oldMapList = {}
        if file.Exists(fullPath, 'DATA') then
            oldMapList = util.JSONToTable(file.Read(fullPath, 'DATA'))
        end

        local localMaps = {}
        for _, map in pairs(file.Find('maps/*.bsp', 'GAME')) do
            -- remove file extension
            localMaps[map:sub(1, -5)] = 0
        end

        local maps = {}
        for _, map in pairs(configMaps) do
            -- Set map 'played' counter to 0. If map exists in the oldMapList, use its 'played' counter instead.
            if localMaps[map] ~= nil then
                maps[map] = 0
                if oldMapList ~= nil then
                    if oldMapList[map] ~= nil then
                        maps[map] = oldMapList[map]                        
                    end
                end
            end
        end

        -- Increments the times played by 1
        if maps[game.GetMap()] ~= nil then
            maps[game.GetMap()] = maps[game.GetMap()] + 1
        end

        file.Write(fullPath, util.TableToJSON(maps))
        return maps
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