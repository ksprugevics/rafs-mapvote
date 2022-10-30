AddCSLuaFile()

if CLIENT then

    include('autorun/client/cl_gui.lua')
    include('autorun/config_rafsmapvote.lua')

    settings = RafsMapvoteConfig()
        
    allPlayers = player:GetAll()
    maps = {}
    mapVotes = {}
    allAvatars = {}
    allPlayers = {}
    allPos = {}
    playerVotes = {}
    closed = false

    net.Receive('START_MAPVOTE', function(len)
        maps = net.ReadTable()
        InitGUI()
    end)

    -- Update avatars 
    net.Receive('REFRESH_VOTES', function(len)
        if closed then
            return
        end
        
        local votes = net.ReadTable()

        -- Update mapvotes
        for _pl, _vote in pairs(votes) do
            local prev_vote = playerVotes[_pl]

            if _prevVote ~= _vote then

                playerVotes[player] = _vote

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