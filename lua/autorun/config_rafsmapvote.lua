AddCSLuaFile()

function RafsMapvoteConfig() 
    local settings = {}

    -- Which maps to include in the map pool. Must be under garrysmod/maps/
    -- (The map should actually be in the directory for it to show up)
    -- Adding/removing maps requires a restart of the server or a manual re-run of the server script
    settings['MAPS'] = {
        'ttt_67thway_v3',
        'ttt_bb_teenroom_b2',
        'ttt_forest_final',
        'ttt_plaza_b6',
        'ttt_richland_fix',
        'ttt_rooftops_a1_f3',
        'zm_roy_the_ship_64',
        'cs_office',
        'de_dust2',
    }

    -- Directory for storing maplist, history and thubmnails
    -- !!! This is under the data/ directory!!!
    -- True path example: garrysmod/data/rafsmapvote/
    settings['DATA_DIR'] = 'rafsmapvote/'

    -- Place thumbnails here
    -- !!! This is under the data/ directory!!!
    -- True path example: garrysmod/data/rafsmapvote/thumbnails/
    settings['THUMBNAIL_DIR'] = 'rafsmapvote/thumbnails/'

    -- Creates data directory
    if not file.Exists(settings['DATA_DIR'], 'DATA') then
        file.CreateDir(settings['DATA_DIR'])
    end

    if not file.Exists(settings['DATA_DIR'] .. '/thumbnails', 'DATA') then
        file.CreateDir(settings['DATA_DIR'] .. '/thumbnails')
    end

    -- Number of maps before a map can show up on the mapvote again
    settings['MAP_COOLDOWN'] = 3

    -- Voting period in seconds
    settings['TIMER'] = 20 + 1

    return settings
end    