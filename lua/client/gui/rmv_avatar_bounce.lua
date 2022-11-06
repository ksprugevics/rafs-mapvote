if CLIENT then

    local bounceAvatars = {}
    local avatarSpeed = {}


    function InitAvatar(thumbnailCoords, avatarSize, voter) 
        local xmin = thumbnailCoords[1] + 3
        local ymin = thumbnailCoords[2] + 3
        local xmax = thumbnailCoords[3] - avatarSize - 3
        local ymax = thumbnailCoords[4] - avatarSize - 3

        local PlayerAvatar = bounceAvatars[voter]
        if  PlayerAvatar == nil then
            PlayerAvatar = vgui.Create('AvatarImage', RMV_MAPVOTE_PANEL)
            PlayerAvatar:SetSize(avatarSize, avatarSize)
            PlayerAvatar:SetPlayer(voter, 64)
        end
        
        PlayerAvatar:SetPos(math.random(xmin, xmax), math.random(ymin, ymax))
        bounceAvatars[voter] = PlayerAvatar
        
        local xspeed = NonZeroRandom(-3, 3)
        local yspeed = NonZeroRandom(-3, 3)
        avatarSpeed[voter] = {xspeed, yspeed}
    end

    function NonZeroRandom(min, max)
        local temp = 0
        while temp == 0 do
            temp = math.random(min, max)
        end
        return temp
    end

    function UpdateAvatars(thumbnailCoords, avatarSize)
        for pl, av in pairs(bounceAvatars) do
            local xpos, ypos = av:GetPos()
            local xspeed = avatarSpeed[pl][1]
            local yspeed = avatarSpeed[pl][2]

            local xmin = thumbnailCoords[RMV_PLAYER_VOTES[pl]][1] + 3
            local ymin = thumbnailCoords[RMV_PLAYER_VOTES[pl]][2] + 3
            local xmax = thumbnailCoords[RMV_PLAYER_VOTES[pl]][3] - avatarSize - 3
            local ymax = thumbnailCoords[RMV_PLAYER_VOTES[pl]][4] - avatarSize - 3

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