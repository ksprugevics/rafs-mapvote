if SERVER then

    local rtvVotes = {}

    hook.Add('PlayerSay', 'RMVRTV', function(ply, text)

        if text == 'rtv' or text == '!rtv' or text == '/rtv' then

            if CurTime() < RMV_CONFIG['RTV_TIME'] then 
                ply:ChatPrint('You must wait ' .. math.Round(RMV_CONFIG['RTV_TIME'] - CurTime()) .. ' more seconds to RTV.')
                return
            end

            if #player.GetAll() < RMV_CONFIG['RTV_MIN'] then
                ply:ChatPrint('You need at least ' .. RMV_CONFIG['RTV_MIN'] ..' players on the server to RTV.')
                return
            end

            if rtvVotes[ply] ~= nil then 
                ply:ChatPrint('You already voted to RTV!')
                return
            end

            rtvVotes[ply] = 1

            if table.Count(rtvVotes) / #player.GetAll() > RMV_CONFIG['RTV_PERCENT'] then
                Log('RTV vote count reached. Starting mapvote.')
                StartRafsMapvote()
            else
                local playersNeeded = math.ceil(RMV_CONFIG['RTV_PERCENT'] * #player.GetAll()) - table.Count(rtvVotes)
                PrintMessage(HUD_PRINTTALK, '[RTV] ' .. ply:Name() .. ' voted to rock the vote!')
                PrintMessage(HUD_PRINTTALK, '[RTV] ' .. playersNeeded .. ' more player(s) needed to RTV.')
            end
        end
    end)

    hook.Add('PlayerDisconnected', 'RMVRTVPLAYERLEAVE', function(ply)
        if rtvVotes[ply] ~= nil then 
            rtvVotes[ply] = nil
            Log(ply:Name() .. ' left. Removing their RTV vote.')
        end
    end)
end