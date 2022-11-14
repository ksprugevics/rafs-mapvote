if CLIENT then

    RMV_ALL_PLAYERS = {}
    RMV_PLAYER_VOTES = {}
    RMV_MAPS = {}
    RMV_CLOSED = true
    RMV_NEXT_MAP = nil
    RMV_TIMER_SECONDS = nil
    RMV_TIMER_SECONDS_LEFT = nil

    net.Receive(RMV_NETWORK_STRINGS["startVote"], function(len)
        if RMV_CLOSED == false then return end

        -- Dirty workaround to hide the TTT end-round panel, so it doesnt block the mapvote
        -- By overriding this function, you cannot make the panel reappear before the map resets
        if GAMEMODE_NAME == "terrortown" then
            function CLSCORE:ShowPanel() return end
        end
        
        RMV_CLOSED = false
        RMV_NEXT_MAP = nil
        RMV_ALL_PLAYERS = player:GetAll()
        RMV_MAPS = net.ReadTable()
        RMV_TIMER_SECONDS = net.ReadFloat()
        RMV_TIMER_SECONDS_LEFT = net.ReadFloat()
        
        if RMV_MAPVOTE_PANEL == nil then
            InitGUI()
        else 
            RMV_MAPVOTE_PANEL:Show()
        end
    end)

    
    hook.Add("OnPlayerChat", "RMVREOPEN", function(_, text, _, _)
        if text ~= "!rmvshow" then return end
        if RMV_MAPVOTE_PANEL ~= nil then
            RMV_MAPVOTE_PANEL:Show()
            RMV_CLOSED = false
        end
    end)


    -- Update avatars 
    net.Receive(RMV_NETWORK_STRINGS["refreshVotes"], function(len)
        if RMV_CLOSED then
            return
        end
        
        local votes = net.ReadTable()
        for pl, vote in pairs(votes) do
            local prev_vote = RMV_PLAYER_VOTES[pl]
            if prev_vote ~= vote then
                RMV_PLAYER_VOTES[pl] = vote
                refreshAvatar(pl)
            end
        end
    end)

    net.Receive(RMV_NETWORK_STRINGS["nextMap"], function()
        if RMV_CLOSED then
            return
        end
        RMV_NEXT_MAP = net.ReadString()
        
        surface.PlaySound("garrysmod/content_downloaded.wav")
        RMV_TITLE_LABEL:SetText("The winner is: " .. RMV_NEXT_MAP)
        RMV_TITLE_LABEL:SizeToContents()
        
        refreshThumbnailBackgrounds()
    end)

end