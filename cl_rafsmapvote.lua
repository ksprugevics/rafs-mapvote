if CLIENT then

    include('cl_gui.lua')

    local mapVotes = {}
    local allAvatars = {}
    local allPlayers = {}
    local allPos = {}
    local playerVotes = {}
    local closed = false

    -- local maps = net.ReadTable()
    local maps = {}
    allPlayers = player:GetAll()

end