AddCSLuaFile()

if CLIENT then

    include('cl_fonts.lua')

    -- Constants
    local UI_WIDTH = ScrW() * 0.75
    local UI_HEIGHT = ScrH() * 0.8
    local THUMBNAIL_WIDTH = (UI_WIDTH - 20) / 3  
    local THUMBNAIL_HEIGHT = (THUMBNAIL_WIDTH - 20) / 16 * 9 
    local STARTING_X = 5
    local STARTING_Y = 55
    local AVATAR_INIT_SIZE = 32
    local AVTAR_ACTUAL_SIZE = (THUMBNAIL_WIDTH - 65) / 12


    function InitGUI()
        local Frame = vgui.Create('DFrame')
        Frame:SetTitle('')
        Frame:SetSize(UI_WIDTH, UI_HEIGHT)
        Frame:Center()
        Frame:SetDraggable(false)
        Frame:ShowCloseButton(false)
        Frame:MakePopup()

        Frame.Paint = function(self, width, height)
            draw.RoundedBox(0, 0, 0, width, height, Color(125, 125, 125, 0))
            Derma_DrawBackgroundBlur(self, SysTime())
            draw.RoundedBox(0, 0, 0, width, 45, Color(50, 50, 50, 200))
            draw.RoundedBox(0, STARTING_X - 15, STARTING_Y - 5, width + 15, THUMBNAIL_HEIGHT * 2 + 15, Color(50, 50, 50, 200))
            draw.RoundedBox(0, STARTING_X - 15, STARTING_Y + (THUMBNAIL_HEIGHT + 5) * 2 + 5, (THUMBNAIL_WIDTH + 10) * 2, THUMBNAIL_HEIGHT / 3, Color(50, 50, 50, 200))
        end

        local CloseButton = vgui.Create('DButton', Frame)
        CloseButton:SetText('X')
        CloseButton:SetPos(UI_WIDTH - 40, 0)
        CloseButton:SetTextColor(Color(255, 255, 255))
        CloseButton:SetFont('XFont')
        CloseButton:SetSize(40, 40)

        CloseButton.Paint = function(self, width, height)
            draw.RoundedBox(0, UI_WIDTH - 60, 5, 16, 16, Color(255, 255, 255, 0))
        end

        CloseButton.DoClick = function()
            Frame:Close()
            closed = true
        end

        TitleLabel = vgui.Create('DLabel', Frame)
        TitleLabel:SetText('Vote for the next map:')
        TitleLabel:SetTextColor(Color(255, 255, 255))
        TitleLabel:SetFont('TitleFont')
        TitleLabel:SetPos(10, 0)
        TitleLabel:SizeToContents()

        local RandomButton = vgui.Create('DButton', Frame)
        RandomButton:SetText('Random map')
        RandomButton:SetPos((THUMBNAIL_WIDTH + 5) * 2 + 5, STARTING_Y + (THUMBNAIL_HEIGHT + 5) * 2 + 5)
        RandomButton:SetSize(THUMBNAIL_WIDTH + 15, THUMBNAIL_HEIGHT / 3)
        RandomButton:SetTextColor(Color(255, 255, 255))
        RandomButton:SetFont('ButtonFont')
        
        RandomButton.Paint = function(self, width, height)
            draw.RoundedBox(0, 0, 0, width, height, Color(50, 50, 50, 200))
        end

        for k, v in pairs(maps) do
    
            local mapName = v
            
            local MapVoteImage = vgui.Create('DImageButton', Frame)
            local MapLabel = vgui.Create('DLabel', Frame)
            MapLabel:SetText(mapName)
            MapLabel:SetTextColor(Color(255, 255, 255))
            MapLabel:SetFont('TextOverImageFont')
            MapLabel:SetSize(THUMBNAIL_WIDTH, 40)
            
            if k < 4 then
                xpos = STARTING_X + (THUMBNAIL_WIDTH + 5) * (k - 1)
                ypos = STARTING_Y
                MapVoteImage:SetPos(xpos, ypos)
                MapLabel:SetPos(xpos + 5, ypos + THUMBNAIL_HEIGHT - 40)
            else
                xpos = STARTING_X + (THUMBNAIL_WIDTH + 5) * (k - 4)
                ypos = STARTING_Y + THUMBNAIL_HEIGHT + 5
                MapVoteImage:SetPos(xpos, ypos)
                MapLabel:SetPos(xpos + 5, ypos + THUMBNAIL_HEIGHT - 40)
            end
        
            MapVoteImage:SetSize(THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT)

            fileName = settings['THUMBNAIL_DIR'] .. mapName .. '.jpg'
            if file.Exists(fileName, 'data') then
                MapVoteImage:SetImage('data/' .. fileName)
            else
                MapVoteImage:SetMaterial('models/rendertarget')
            end
            
            allPos[v] = {xpos, ypos}

            MapVoteImage.DoClick = function()
                net.Start('MAP_CHOICE')
                net.WriteString(mapName)
                net.SendToServer()
            end

        end

        -- Initial position of avatars
        local xposCounter, yposCounter = STARTING_X, STARTING_Y + (THUMBNAIL_HEIGHT + 5) * 2 + 10
        local counter = 1
        for key, p in pairs(allPlayers) do
            playerVotes[p] = -1
            local avatar = vgui.Create('AvatarImage', Frame)
            avatar:SetSize(AVATAR_INIT_SIZE, AVATAR_INIT_SIZE)
            avatar:SetPos(xposCounter, yposCounter)
            avatar:SetPlayer(p, 32)
            avatar:SetTooltip(p:GetName())
            avatar:SetParent(Frame)
            allAvatars[p] = avatar
            if counter == 18 then
                yposCounter = yposCounter + AVATAR_INIT_SIZE + 5
                xposCounter = STARTING_X
            else
                xposCounter = xposCounter + AVATAR_INIT_SIZE + 5
            end
            counter = counter + 1
        end

    end
end