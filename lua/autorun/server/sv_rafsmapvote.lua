if SERVER then

    include('autorun/server/sv_utils.lua')
    include('rmv_network_strings.lua')
    include('rmv_logging.lua')
    include('rmv_file_gen.lua')
    include('rmv_sv_utils.lua')

    -- Global constants
    CONFIG = {}

    SetTableRowSize(80)
    PrintLogo()
    PrintTableHeader()
    CONFIG = SetupDataDir()
    PrintTableRow('Config loaded')

    PrintTableRow("Generating map list..")
    local mapList = GenerateMapList(CONFIG['DATA_DIR'] .. 'map_list.json', CONFIG['MAPS'])
    
    PrintTableRow("Generating map history..")
    local mapHistory = GenerateMapHistory(CONFIG['DATA_DIR'] .. 'map_history.json', CONFIG['MAP_COOLDOWN'])
    local candidates = GenerateVoteCandidates(mapList, mapHistory)
    local generatedMapList = nil
    local playerVotes = {}
    local nextMap = nil
    local started = false

    PrintTableRow("Fully loaded!")
    PrintTableFooter()

    -- Initiate mapvote
    hook.Add('PlayerSay', 'MapVote', function(ply, text)
        if text == '!mapvote' then
            if started == false then

                -- Create a table that will contain player votes
                local allPlayers = player:GetAll()

                for key, player in pairs(allPlayers) do
                    playerVotes[player] = -1
                end
                
                -- Sends candidates to the players
                net.Start('START_MAPVOTE')
                net.WriteTable(candidates)
                net.Broadcast()
                started = true

                -- Creates a voting period - timer
                timer.Create('serverTime', CONFIG['TIMER'], 1, function()
                    print('[Rafs Map Vote] Vote time ended')

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
        SendVotesToClient(playerVotes)
    end)
end