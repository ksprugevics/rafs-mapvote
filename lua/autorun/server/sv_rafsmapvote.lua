if SERVER then

    include('autorun/server/sv_utils.lua')
    include('rmv_network_strings.lua')
    include('rmv_logging.lua')

    -- Global constants
    CONFIG = {}

    -- Local constants
    local TABLE_LENGTH = 47


    PrintLogo()
    PrintTableHeader(TABLE_LENGTH)
    PrintTableRow("Importing config..", TABLE_LENGTH)
    CONFIG = SetupDataDir()

    PrintTableRow("Generating map list..", TABLE_LENGTH)
    GenerateMapList()
    
    PrintTableRow("Generating map history..", TABLE_LENGTH)
    GenerateMapHistory()

    -- Increase map's times played and add map to history
    local mapList = UpdateMapList()
    local mapHistory = UpdateMapHistory()
    local generatedMapList = nil
    local playerVotes = {}
    local nextMap = nil
    local started = false

    PrintTableRow("Fully loaded!", TABLE_LENGTH)
    PrintTableFooter(TABLE_LENGTH)

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
        RefreshVotes(playerVotes)
    end)
end