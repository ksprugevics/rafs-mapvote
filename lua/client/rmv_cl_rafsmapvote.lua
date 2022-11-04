if CLIENT then

    allPlayers = {}
    allAvatars = {}
    allPos = {}
    playerVotes = {}
    mapVotes = {}
    maps = {}
    closed = false

    
    net.Receive('START_MAPVOTE', function(len)
        closed = false
        allPlayers = player:GetAll()
        maps = net.ReadTable()
        InitGUI()
    end)

    -- Update avatars 
    net.Receive('REFRESH_VOTES', function(len)
        if closed then
            return
        end
        
        local votes = net.ReadTable()
        for pl, vote in pairs(votes) do
            local prev_vote = playerVotes[pl]
            if prev_vote ~= vote then
                playerVotes[pl] = vote
                RefreshAvatar(pl)
            end
        end
    end)

    net.Receive('NEXT_MAP', function()
        if closed then
            return
        end
        local nextMap = net.ReadString()
        
        TitleLabel:SetText('The winner is: ' .. nextMap)
        TitleLabel:SizeToContents()

        -- To do: Some flashy effect
    end)

end