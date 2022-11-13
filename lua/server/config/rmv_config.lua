local function generateDefaultConfig(fullPath)
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
    settings['NO_VOTE_TO_RANDOM'] = false

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
    settings['TIMER'] = 35 + 1

    -- Minimal players for rock the vote to be enabled
    settings['RTV_MIN'] = 3

    -- Threshold to rock the vote
    settings['RTV_PERCENT'] = 0.6

    -- Time in seconds before RTV is allowed
    settings['RTV_TIME'] = 300

    file.Write(fullPath, util.TableToJSON(settings))
end


function setupDataDir()

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

    -- Creates thumbnail directory
    if not file.Exists(dataPath .. '/thumbnails', 'DATA') then
        PrintTableRow('Thumbnail directory not found, generating..')
        file.CreateDir(dataPath .. '/thumbnails')
    end
    PrintTableRow('Thumbnail directory: ' .. fullPathPrefix .. dataPath .. 'thumbnails/')
    PrintTableRow('')

    -- Creates config file
    if not file.Exists(configPath, 'DATA') then
        PrintTableRow('Config file not found, generating..')
        generateDefaultConfig(configPath)
    end
            
    PrintTableRow('Config file found: ' .. fullPathPrefix .. configPath)
    PrintTableRow('')
    return util.JSONToTable(file.Read(configPath))
end