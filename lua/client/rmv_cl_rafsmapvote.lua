if CLIENT then

    RMV_ALL_PLAYERS = {}
    RMV_PLAYER_VOTES = {}
    RMV_MAPS = {}
    RMV_CLOSED = true
    RMV_NEXT_MAP = nil
    RMV_TIMER_SECONDS = nil
    RMV_TIMER_SECONDS_LEFT = nil

    net.Receive('START_MAPVOTE', function(len)
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
        InitGUI()
    end)


    -- Update avatars 
    net.Receive('REFRESH_VOTES', function(len)
        if RMV_CLOSED then
            return
        end
        
        local votes = net.ReadTable()
        for pl, vote in pairs(votes) do
            local prev_vote = RMV_PLAYER_VOTES[pl]
            if prev_vote ~= vote then
                RMV_PLAYER_VOTES[pl] = vote
                RefreshAvatar(pl)
            end
        end
    end)

    net.Receive('NEXT_MAP', function()
        if RMV_CLOSED then
            return
        end
        RMV_NEXT_MAP = net.ReadString()
        
        surface.PlaySound('garrysmod/content_downloaded.wav')
        TitleLabel:SetText('The winner is: ' .. RMV_NEXT_MAP)
        TitleLabel:SizeToContents()
        
        RefreshThumbnailBackgrounds()
    end)

end