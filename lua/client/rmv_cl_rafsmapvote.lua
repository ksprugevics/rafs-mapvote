RMV_MAPVOTE_INFO = RMV_MAPVOTE_INFO or {}
RMV_MAPVOTE_INFO.RMV_ALL_PLAYERS = {}
RMV_MAPVOTE_INFO.RMV_PLAYER_VOTES = {}
RMV_MAPVOTE_INFO.RMV_CANDIDATES = {}
RMV_MAPVOTE_INFO.RMV_TIMER_SECONDS = nil
RMV_MAPVOTE_INFO.RMV_TIMER_SECONDS_LEFT = nil
RMV_MAPVOTE_INFO.RMV_NEXT_MAP = nil
RMV_MAPVOTE_INFO.RMV_MAPVOTE_STARTED = false



net.Receive(RMV_NETWORK_STRINGS["startVote"], function(len)
    RMV_MAPVOTE_INFO.RMV_NEXT_MAP = nil
    RMV_MAPVOTE_INFO.RMV_MAPVOTE_STARTED = true
    RMV_MAPVOTE_INFO.RMV_ALL_PLAYERS = player:GetAll()
    RMV_MAPVOTE_INFO.RMV_CANDIDATES = net.ReadTable()
    RMV_MAPVOTE_INFO.RMV_TIMER_SECONDS = net.ReadFloat()
    RMV_MAPVOTE_INFO.RMV_TIMER_SECONDS_LEFT = net.ReadFloat()
    RMVShowMapvote()

    -- Dirty workaround to hide the TTT end-round panel, so it doesnt block the mapvote
    -- By overriding this function, you cannot make the panel reappear before the map resets
    if GAMEMODE_NAME == "terrortown" then
        function CLSCORE:ShowPanel() return end
    end
end)


hook.Add("OnPlayerChat", "RMVREOPEN", function(_, text, _, _)
    if text ~= "!rmvshow" then return end
    if RMV_MAPVOTE_INFO.RMV_MAPVOTE_STARTED and not RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL:IsVisible() then
        rmvSendStringToServer(RMV_NETWORK_STRINGS["info"], "info")
    end
end)


-- Update avatars 
net.Receive(RMV_NETWORK_STRINGS["refreshVotes"], function(len)
    if not RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL:IsVisible() then
        return
    end
    local votes = net.ReadTable()
    for pl, vote in pairs(votes) do
        local prev_vote = RMV_MAPVOTE_INFO.RMV_PLAYER_VOTES[pl]
        if prev_vote ~= vote then
            RMV_MAPVOTE_INFO.RMV_PLAYER_VOTES[pl] = vote
            RMVRefreshAvatars(pl)
        end
    end
end)

net.Receive(RMV_NETWORK_STRINGS["nextMap"], function()
    if not RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL:IsVisible() then
        return
    end
    RMV_MAPVOTE_INFO.RMV_NEXT_MAP = net.ReadString()
    surface.PlaySound("garrysmod/content_downloaded.wav")
    RMV_GUI_ELEMENTS.RMV_TITLE_LABEL:SetText("The winner is: " .. RMV_MAPVOTE_INFO.RMV_NEXT_MAP)
    RMV_GUI_ELEMENTS.RMV_TITLE_LABEL:SizeToContents()
    RMVRefreshThumbnailBackgrounds()
end)
