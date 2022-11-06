if SERVER then
    
    local config = {}
    local candidates = {}
    local playerVotes = {}
    local nextMap = nil
    local started = false
    local mapVoteTimer = nil

    local function Initialize()
        SetTableRowSize(80)
        PrintLogo()
        PrintTableHeader()
        config = SetupDataDir()
        PrintTableRow('Config loaded.')

        PrintTableRow('Generating map list..')
        local mapList = GenerateMapList(config['DATA_DIR'] .. 'map_list.json', config['MAPS'])

        PrintTableRow('Generating map history..')
        local mapHistory = GenerateMapHistory(config['DATA_DIR'] .. 'map_history.json', config['MAP_COOLDOWN'])

        PrintTableRow('Generating mapvote candidtes..')
        candidates = GenerateVoteCandidates(mapList, mapHistory)

        PrintTableRow("Fully loaded!")
        PrintTableFooter()
    end

    -- Initiate mapvote//
    hook.Add('PlayerSay', 'MapVote', function(ply, text)
        if text == '!mapvote' then
            if started == false then

                -- Create a table that will contain player votes
                local allPlayers = player:GetAll()

                for key, player in pairs(allPlayers) do
                    playerVotes[player] = -1
                end
                
                net.Start('START_MAPVOTE')
                net.WriteTable(candidates)
                net.WriteFloat(config['TIMER'])


                -- Creates a voting period - timer
                mapVoteTimer = timer.Create('serverTime', config['TIMER'], 1, function()
                    Log('Vote time ended.')
                    PrintTable(playerVotes)
                    nextMap = TallyVotes(playerVotes, candidates)
                    net.Start('NEXT_MAP')
                    net.WriteString(nextMap)
                    net.Broadcast()
                    started = false
                    Log('Changing map to: ' .. nextMap)
                end)
                started = true
                Log('Vote started.')
                net.WriteFloat(timer.TimeLeft('serverTime'))
                net.Broadcast()
            else
                net.Start('START_MAPVOTE')
                net.WriteTable(candidates)
                net.WriteFloat(config['TIMER'])
                net.WriteFloat(timer.TimeLeft('serverTime'))
                net.Broadcast()
                SendVotesToClient(playerVotes)
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
        SendVotesToClient(playerVotes)
    end)

    Initialize()
end