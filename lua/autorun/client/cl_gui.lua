AddCSLuaFile()

if CLIENT then

    include('autorun/client/cl_fonts.lua')
    include('autorun/client/cl_avatar_bounce.lua')

    -- Constants
    UI_WIDTH = ScrW() * 0.75
    UI_HEIGHT = ScrH() * 0.8
    THUMBNAIL_WIDTH = (UI_WIDTH - 20) / 3  
    THUMBNAIL_HEIGHT = (THUMBNAIL_WIDTH - 20) / 16 * 9 
    THUMBNAIL_COORDS = {}
    STARTING_X = 5
    STARTING_Y = 55
    AVATAR_INIT_SIZE = 32
    AVATAR_THUMBNAIL_SIZE = (THUMBNAIL_WIDTH - 65) / 12
    UPDATE_INTERVAL = 0.01

    PANEL = nil


    -- Main panel
    function CreateMainPanel()
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
        PANEL = Frame
    end

    -- Close button
    function CreateCloseButton()
        local CloseButton = vgui.Create('DButton', PANEL)
        CloseButton:SetText('X')
        CloseButton:SetPos(UI_WIDTH - 40, 0)
        CloseButton:SetTextColor(Color(255, 255, 255))
        CloseButton:SetFont('XFont')
        CloseButton:SetSize(40, 40)

        CloseButton.Paint = function(self, width, height)
            draw.RoundedBox(0, UI_WIDTH - 60, 5, 16, 16, Color(255, 255, 255, 0))
        end

        CloseButton.DoClick = function()
            ticker = CurTime()
            DeleteAvatars()
            PANEL:Clear()
            PANEL:Close()
            closed = true
        end
    end

    -- Title label
    function CreateTitleLabel(text)
        TitleLabel = vgui.Create('DLabel', PANEL)
        TitleLabel:SetText(text)
        TitleLabel:SetTextColor(Color(255, 255, 255))
        TitleLabel:SetFont('TitleFont')
        TitleLabel:SetPos(10, 0)
        TitleLabel:SizeToContents()
    end

    -- Button for random vote
    function CreateRandomButton()
        local RandomButton = vgui.Create('DButton', PANEL)
        RandomButton:SetText('Random map')
        RandomButton:SetPos((THUMBNAIL_WIDTH + 5) * 2 + 5, STARTING_Y + (THUMBNAIL_HEIGHT + 5) * 2 + 5)
        RandomButton:SetSize(THUMBNAIL_WIDTH + 15, THUMBNAIL_HEIGHT / 3)
        RandomButton:SetTextColor(Color(255, 255, 255))
        RandomButton:SetFont('ButtonFont')
        
        RandomButton.Paint = function(self, width, height)
            draw.RoundedBox(0, 0, 0, width, height, Color(50, 50, 50, 200))
        end

        RandomButton.DoClick = function ()
            PrintTable(playerVotes)
            net.Start('MAP_CHOICE')
            net.WriteString('random')
            net.SendToServer()
        end
    end

    -- Map thumbnails
    function CreateMapThumbnails()
        for k, mapName in pairs(maps) do
    
            local MapVoteImage = vgui.Create('DImageButton', PANEL)
            local MapLabel = vgui.Create('DLabel', PANEL)

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
        
            THUMBNAIL_COORDS[mapName] = {xpos, ypos,
                                         xpos + THUMBNAIL_WIDTH - AVATAR_THUMBNAIL_SIZE,
                                         ypos + THUMBNAIL_HEIGHT - AVATAR_THUMBNAIL_SIZE}
            MapVoteImage:SetSize(THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT)

            local fileName = settings['THUMBNAIL_DIR'] .. mapName .. '.jpg'
            if file.Exists(fileName, 'data') then
                MapVoteImage:SetImage('data/' .. fileName)
            else
                MapVoteImage:SetMaterial('models/rendertarget')
            end
            
            MapVoteImage.DoClick = function()
                net.Start('MAP_CHOICE')
                net.WriteString(mapName)
                net.SendToServer()
            end
        end
    end

    -- Populate avatar dock
    function CreateAvatarDock()
       -- Initial position of avatars
       local xposCounter, yposCounter = STARTING_X, STARTING_Y + (THUMBNAIL_HEIGHT + 5) * 2 + 10
       local counter = 1
       for key, p in pairs(allPlayers) do
           playerVotes[p] = -1
           local avatar = vgui.Create('AvatarImage', PANEL)
           avatar:SetSize(AVATAR_INIT_SIZE, AVATAR_INIT_SIZE)
           avatar:SetPos(xposCounter, yposCounter)
           avatar:SetPlayer(p, 32)
           avatar:SetTooltip(p:GetName())
           avatar:SetParent(PANEL)
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

    function InitGUI()
        CreateMainPanel()
        CreateCloseButton()
        CreateTitleLabel('Vote for the next map:')
        CreateRandomButton()
        CreateMapThumbnails()
        CreateAvatarDock()
    end
    
    function RefreshAvatar(ply)

        local xmin = THUMBNAIL_COORDS[playerVotes[ply]][1]
        local ymin = THUMBNAIL_COORDS[playerVotes[ply]][2]
        local xmax = THUMBNAIL_COORDS[playerVotes[ply]][3] 
        local ymax = THUMBNAIL_COORDS[playerVotes[ply]][4]
        if allAvatars[ply] ~= nil then
            allAvatars[ply]:Remove()
            allAvatars[ply] = nil
        end
        InitAvatar(xmin, ymin, xmax, ymax, ply)
    end

    local ticker = 0
    hook.Add('Think', 'CurTimeDelay', function()
        if CurTime() <= ticker then
            return
        end	

        if PANEL ~= nil then
            if not PANEL:IsValid() then
                ticker = CurTime() 
                return
            end
        end

        UpdateAvatars()
        ticker = CurTime() + UPDATE_INTERVAL
    end)
end