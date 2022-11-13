RTV_SUCCESS = false
local RTV_VOTES = {}


local function canPlayerRTV(ply, text) 
    if CurTime() < RMV_CONFIG["RTV_TIME"] then 
        ply:ChatPrint("You must wait " .. math.Round(RMV_CONFIG["RTV_TIME"] - CurTime()) .. " more seconds to RTV.")
        return false
    end

    if #player.GetAll() < RMV_CONFIG["RTV_MIN"] then
        ply:ChatPrint("You need at least " .. RMV_CONFIG["RTV_MIN"] .." players on the server to RTV.")
        return false
    end

    if RTV_VOTES[ply] ~= nil then 
        ply:ChatPrint("You already voted to RTV!")
        return false
    end
    return true
end

local function processRTVVote(ply)
    RTV_VOTES[ply] = 1
    if table.Count(RTV_VOTES) / #player.GetAll() >= RMV_CONFIG["RTV_PERCENT"] then
        if GAMEMODE_NAME == "terrortown" then
            PrintMessage(HUD_PRINTTALK, "[RTV] " .. ply:Name() .. " voted to rock the vote! Mapvote will start after the end of the round!")
            Log("RTV vote count reached. Starting mapvote after this round.")
        else 
            PrintMessage(HUD_PRINTTALK, "[RTV] " .. ply:Name() .. " voted to rock the vote! Starting mapvote!")
            Log("RTV vote count reached. Starting mapvote.")
            StartRafsMapvote()
        end
        RTV_SUCCESS = true
    else
        local playersNeeded = math.ceil(RMV_CONFIG["RTV_PERCENT"] * #player.GetAll()) - table.Count(RTV_VOTES)
        PrintMessage(HUD_PRINTTALK, "[RTV] " .. ply:Name() .. " voted to rock the vote! " .. playersNeeded .. " more player(s) needed to start a mapvote.")
    end
    if RMV_CONFIG["DEBUG_MODE"] then
        PrintDebugTable("RTV VOTES", RTV_VOTES)
    end
end


hook.Add("PlayerSay", "RMVRTV", function(ply, text)
    if text ~= "rtv" and text ~= "!rtv" and text ~= "/rtv" then return end
    if not canPlayerRTV(ply, text) then return end
    processRTVVote(ply)
end)

hook.Add("PlayerDisconnected", "RMVRTVPLAYERLEAVE", function(ply)
    if RTV_VOTES[ply] ~= nil then 
        RTV_VOTES[ply] = nil
        Log(ply:Name() .. " left. Removing their RTV vote.")
        if RMV_CONFIG["DEBUG_MODE"] then
            PrintDebugTable("RTV VOTES", RTV_VOTES)
        end
    end
end)
