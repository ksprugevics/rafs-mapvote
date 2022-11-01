if SERVER then

    include('autorun/server/sv_utils.lua')
    
    -- Network strings
    util.AddNetworkString('MAP_CHOICE')
    util.AddNetworkString('START_MAPVOTE')
    util.AddNetworkString('REFRESH_VOTES')
    util.AddNetworkString('NEXT_MAP')

    print('[MAPVOTE] Importing config..')
    settings = SetupDataDir()

    print('[MAPVOTE] Generating map list..')
    GenerateMapList()

    print('[MAPVOTE] Generating map history..')
    GenerateMapHistory()

    -- Increase map's times played and add map to history
    local mapList = UpdateMapList()
    local mapHistory = UpdateMapHistory()
    local generatedMapList = nil
    local playerVotes = {}
    local nextMap = nil
    local started = false

    print('[MAPVOTE] Fully loaded!')

    -- Initiate mapvote
    hook.Add('PlayerSay', 'MapVote', function(ply, text)
        if text == '!mapvote' then
            if started == false then
                -- Generates map candidates
                candidates = GenerateCandidates(mapList, mapHistory, playerVotes)

                -- Create a table that will contain player votes
                local allPlayers = player:GetAll()

                for key, player in pairs(allPlayers) do
                    playerVotes[player] = -1
                end
                
                -- Sends the client a copy of the config
                net.Start('START_MAPVOTE')
                net.WriteTable(candidates)
                net.Broadcast()

                -- Sends candidates to the players
                net.Start('START_MAPVOTE')
                net.WriteTable(candidates)
                net.Broadcast()
                started = true

                -- Creates a voting period - timer
                timer.Create('serverTime', settings['TIMER'], 1, function()
                    print('[MAPVOTE] Vote time ended')

                    nextMap = TallyVotes(playerVotes, candidates)
                    net.Start('NEXT_MAP')
                    net.WriteString(nextMap)
                    net.Broadcast()
                    started = false
                end)
            else
                net.Start('START_MAPVOTE')
                net.WriteTable(candidates)
                net.Broadcast()
                RefreshVotes(playerVotes)
            end

            -- local command = "changelevel " .. user_choice .. "\n"
            -- game.ConsoleCommand(command)
        end
    end)

    -- Executes when a user votes
    net.Receive('MAP_CHOICE', function(len, ply)

        local userChoice = net.ReadString()
        playerVotes[ply] = userChoice
        PrintTable(playerVotes)
        RefreshVotes(playerVotes)
    end)
end