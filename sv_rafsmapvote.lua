if SERVER then

    include('config_rafsmapvote.lua')
    include('sv_utils.lua')
    
    -- Read config file
    settings = RafsMapvoteConfig()

    -- Network strings
    util.AddNetworkString('MAP_CHOICE')
    util.AddNetworkString('START_MAPVOTE')
    util.AddNetworkString('REFRESH_VOTES')
    util.AddNetworkString('NEXT_MAP')

    print('Generating map list')
    GenerateMapList()

    print('Generating map history')
    GenerateMapHistory()

    -- Increase map's times played and add map to history
    local mapList = UpdateMapList()
    local mapHistory = UpdateMapHistory()
    local generatedMapList = nil
    local playerVotes = {}
    local nextMap = nil


    -- Initiate mapvote
    hook.Add('PlayerSay', 'MapVote', function(ply, text)
        if text == '!mapvote' then
            -- Generates map candidates
            candidates = GenerateCandidates(mapList, mapHistory, playerVotes)

            -- Create a table that will contain player votes
            local allPlayers = player:GetAll()

            for key, player in pairs(allPlayers) do
                playerVotes[player] = -1
            end
            
            -- Sends candidates to the players
            net.Start('START_MAPVOTE')
            net.WriteTable(candidates)
            net.Broadcast()

            -- Creates a voting period - timer
            timer.Create('serverTime', settings['TIMER'], 1, function()
                print('Vote time ended')

                nextMap = TallyVotes(playerVotes, candidates)
                net.Start('NEXT_MAP')
                net.WriteString(nextMap)
                net.Broadcast()
            end)

            -- local command = "changelevel " .. user_choice .. "\n"
            -- game.ConsoleCommand(command)
        end
    end)

    -- Executes when a user votes
    net.Receive('MAP_CHOICE', function(len, ply)

        local userChoice = net.ReadString()
        playerVotes[ply] = userChoice
        -- PrintTable(playerVotes)
        RefreshVotes(playerVotes)
    end)


end