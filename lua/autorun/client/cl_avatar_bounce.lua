AddCSLuaFile()

if CLIENT then

    local bounceAvatars = {}
    local avatarSpeed = {}


    function InitAvatar(xmin, ymin, xmax, ymax, voter) 

        local PlayerAvatar = bounceAvatars[voter]
        if  PlayerAvatar == nil then
            PlayerAvatar = vgui.Create('AvatarImage', PANEL)
            PlayerAvatar:SetSize(AVATAR_THUMBNAIL_SIZE, AVATAR_THUMBNAIL_SIZE)
            PlayerAvatar:SetPlayer(voter, 64)
        end
        
        PlayerAvatar:SetPos(math.random(xmin, xmax), math.random(ymin, ymax))
        bounceAvatars[voter] = PlayerAvatar
        
        local xspeed = math.random(-4, 4)
        local yspeed = math.random(-4, 4)
        avatarSpeed[voter] = {xspeed, yspeed}
    end

    function UpdateAvatars()
        for pl, av in pairs(bounceAvatars) do

            local xpos, ypos = av:GetPos()
            local xspeed = avatarSpeed[pl][1]
            local yspeed = avatarSpeed[pl][2]

            local xmin = THUMBNAIL_COORDS[playerVotes[pl]][1]
            local ymin = THUMBNAIL_COORDS[playerVotes[pl]][2]
            local xmax = THUMBNAIL_COORDS[playerVotes[pl]][3]
            local ymax = THUMBNAIL_COORDS[playerVotes[pl]][4]

            if xpos>= xmax + 1 or xpos <= xmin - 1 then
                xspeed = xspeed * -1;
            end

            if ypos >= ymax + 1 or ypos <= ymin - 1 then
                yspeed = yspeed * -1;
            end
            avatarSpeed[pl][1] = xspeed
            avatarSpeed[pl][2] = yspeed
            av:SetPos(xpos + xspeed, ypos + yspeed)
        end
    end

    function DeleteAvatars()
        bounceAvatars = {}
        avatarSpeed = {}
    end

end