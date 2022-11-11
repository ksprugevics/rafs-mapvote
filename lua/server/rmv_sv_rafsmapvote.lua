if SERVER then
    
    RMV_CONFIG = {}
    local candidates = {}
    local playerVotes = {}
    local nextMap = nil
    local started = false
    local delay = false
    local mapVoteTimer = nil

    local function Initialize()
        SetTableRowSize(80)
        PrintLogo()
        PrintTableHeader()
        RMV_CONFIG = SetupDataDir()
        PrintTableRow('Config loaded.')

        PrintTableRow('Generating map list..')
        local mapList = GenerateMapList(RMV_CONFIG['MAPS'], RMV_CONFIG['MAP_PREFIX'])
        PrintTableRow('Found ' .. #mapList .. ' maps in total.')
        
        if #mapList < 6 then
            PrintTableRow('WARNING: Very small map pool! Things might break..')
        end


        PrintTableRow('Loading map statistics..')
        local mapStats = GenerateMapCount(RMV_CONFIG['DATA_DIR'] .. 'map_stats.json', mapList)

        PrintTableRow('Loading map history..')
        local mapHistory = GenerateMapHistory(RMV_CONFIG['DATA_DIR'] .. 'map_history.json', RMV_CONFIG['MAP_COOLDOWN'])

        PrintTableRow('Generating mapvote candidtes..')
        candidates = GenerateVoteCandidates(mapList, mapHistory, mapStats)
        PrintTableRow("Fully loaded!")
        PrintTableFooter()
    end

    function StartRafsMapvote(customTimer, noVotesAsRandom)
        local voteTime = customTimer or RMV_CONFIG['TIMER']
        local noVotesAsRandom = noVotesAsRandom or RMV_CONFIG['NO_VOTE_TO_RANDOM']
        if started == false then

            -- Create a table that will contain player votes
            local allPlayers = player:GetAll()

            for key, player in pairs(allPlayers) do
                playerVotes[player] = -1
            end
            


            -- Creates a voting period - timer
            mapVoteTimer = timer.Create('serverTime', voteTime, 1, function()
                Log('Vote time ended.')
                PrintTable(playerVotes)
                nextMap = TallyVotes(playerVotes, candidates, noVotesAsRandom)
                rmvBroadcastString(RMV_NETWORK_STRINGS["nextMap"], nextMap)
                started = false
                Log('Changing map to: ' .. nextMap)
                -- timer.Simple(5, function()
                --     RunConsoleCommand('changelevel', nextMap)
                -- end)
            end)

            Log('Vote started.')
            started = true
            rmvBroadcastMapvote(RMV_NETWORK_STRINGS["startVote"], candidates, voteTime, timer.TimeLeft('serverTime'))
        else
            rmvBroadcastMapvote(RMV_NETWORK_STRINGS["startVote"], candidates, voteTime, timer.TimeLeft('serverTime'))
            rmvBroadcastTable(RMV_NETWORK_STRINGS["refreshVotes"], playerVotes)
        end
    end

    hook.Add('TTTEndRound', 'CheckMapvote', function()
        -- Overrides CheckForMapSwitch() so that after the last round, the map doesn't switch instantly
        function CheckForMapSwitch()
            -- Check for mapswitch
            local rounds_left = math.max(0, GetGlobalInt('ttt_rounds_left', 6) - 1)
            SetGlobalInt('ttt_rounds_left', rounds_left)

            local time_left = math.max(0, (GetConVar('ttt_time_limit_minutes'):GetInt() * 60) - CurTime())
            local switchmap = false

            if rounds_left <= 0 then
                switchmap = true
                Log('Round limit reached. Starting mapvote..')
            elseif time_left <= 0 then
                switchmap = true
                Log('Time limit reached. Starting mapvote..')
            end

            if switchmap then
                timer.Stop('end2prep')
                StartRafsMapvote()
            else
                LANG.Msg('limit_left', {num = rounds_left,
                                time = math.ceil(time_left / 60),
                                mapname = nextmap})
            end
        end
    end)


    
    -- Executes when a user votes
    net.Receive(RMV_NETWORK_STRINGS["userChoice"], function(len, ply)
        local userChoice = net.ReadString()
        playerVotes[ply] = userChoice
        PrintTable(playerVotes)
        rmvBroadcastTable(RMV_NETWORK_STRINGS["refreshVotes"], playerVotes)
    end)

    Initialize()
end