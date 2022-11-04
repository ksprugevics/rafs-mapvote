if CLIENT then

    local bounceAvatars = {}
    local avatarSpeed = {}


    function InitAvatar(xmin, ymin, xmax, ymax, avatarSize, voter) 

        local PlayerAvatar = bounceAvatars[voter]
        if  PlayerAvatar == nil then
            PlayerAvatar = vgui.Create('AvatarImage', PANEL)
            PlayerAvatar:SetSize(avatarSize, avatarSize)
            PlayerAvatar:SetPlayer(voter, 64)
        end
        
        PlayerAvatar:SetPos(math.random(xmin, xmax), math.random(ymin, ymax))
        bounceAvatars[voter] = PlayerAvatar
        
        local xspeed = math.random(-4, 4)
        local yspeed = math.random(-4, 4)
        avatarSpeed[voter] = {xspeed, yspeed}
    end

    function UpdateAvatars(thumbnailCoords, avatarSize)
        for pl, av in pairs(bounceAvatars) do

            local xpos, ypos = av:GetPos()
            local xspeed = avatarSpeed[pl][1]
            local yspeed = avatarSpeed[pl][2]

            local xmin = thumbnailCoords[playerVotes[pl]][1]
            local ymin = thumbnailCoords[playerVotes[pl]][2]
            local xmax = thumbnailCoords[playerVotes[pl]][3] - avatarSize
            local ymax = thumbnailCoords[playerVotes[pl]][4] - avatarSize

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