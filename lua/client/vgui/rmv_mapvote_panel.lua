RMV_GUI_ELEMENTS = RMV_GUI_ELEMENTS or {}
RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL = nil
RMV_GUI_ELEMENTS.RMV_CLOSE_BUTTON = nil
RMV_GUI_ELEMENTS.RMV_TITLE_LABEL = nil

local selectedMap = nil

-- Main Panel
local STARTING_X = 55
local STARTING_Y = 55
local PANEL_WIDTH = ScrW() * 0.75
local PANEL_HEIGHT = ScrH() * 0.8
local _blurCounter = 0

-- Thumbnails
local THUMBNAIL_WIDTH = (PANEL_WIDTH - 20) / 3  
local THUMBNAIL_HEIGHT = (THUMBNAIL_WIDTH - 20) / 16 * 9
local THUMBNAIL_COORDS = {}
local thumbnails = {}
local mapLabels = {}
local thumbnailBackgrounds = {}
local _rainbowCounter = 0
local _flashCounter = 0
local _thumbnailSlide = {}

-- Timer 
local TIMER_BAR_WIDTH = 40
local TIMER_BAR_HEIGHT = STARTING_Y + (THUMBNAIL_HEIGHT + 5) * 2 + 5 + THUMBNAIL_HEIGHT / 3 + 13 - 10
local TIMER_BAR_ACTIVE_HEIGHT = TIMER_BAR_HEIGHT
local TIMER_PAD_WIDTH = TIMER_BAR_WIDTH + 10
local TIMER_PAD_HEIGHT = TIMER_BAR_HEIGHT + 10
local timerBar = nil

-- Avatars
local allAvatars = {}
local AVATAR_MAX_PER_ROW = 20
local AVATAR_INIT_SIZE = ((THUMBNAIL_WIDTH + 10) * 2 - (AVATAR_MAX_PER_ROW + 3) * 5) / AVATAR_MAX_PER_ROW
local AVATAR_THUMBNAIL_SIZE = (THUMBNAIL_WIDTH - 65) / 12
local bounceAvatars = {}
local _avatarSpeed = {}
local _bounceCounter = 0
local _updateInterval = 0.01

-- Colors
local _lightMode = false
local COLOR_DARK_BG = Color(50, 50, 50, 200)
local COLOR_DARK_FG = Color(255, 255, 255, 255)
local COLOR_LIGHT_BG = Color(255, 255, 255, 255)
local COLOR_LIGHT_FG = Color(0, 0, 0)
local COLOR_BG = Color(50, 50, 50, 200)
local COLOR_FG = Color(255, 255, 255, 255)


local function calculateThumbnailPositions()
    for k, mapName in pairs(RMV_MAPVOTE_INFO.RMV_CANDIDATES) do
        local xpos = 0
        local ypos = 0
        if k < 4 then
            xpos = STARTING_X + (THUMBNAIL_WIDTH + 5) * (k - 1) + 5
            ypos = STARTING_Y
        else
            xpos = STARTING_X + (THUMBNAIL_WIDTH + 5) * (k - 4) + 5
            ypos = STARTING_Y + THUMBNAIL_HEIGHT + 5
        end
        THUMBNAIL_COORDS[mapName] = {
        xpos,
        ypos,
        xpos + THUMBNAIL_WIDTH,
        ypos + THUMBNAIL_HEIGHT}
    end
end

local function createMainPanel()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:SetKeyboardInputEnabled(false)
    frame:SetSize(PANEL_WIDTH + 55, PANEL_HEIGHT)
    frame:Center()
    frame.Paint = function(self, _w, _h)          
        Derma_DrawBackgroundBlur(self, SysTime() - math.Clamp(0, 1000, _blurCounter))
        _blurCounter = _blurCounter + 0.005

        -- Header
        draw.RoundedBox(0, STARTING_X, 0, _w, 45, COLOR_BG)

        -- Thumbnail area
        draw.RoundedBox(0, STARTING_X, STARTING_Y - 5, _w + 15,
                        THUMBNAIL_HEIGHT * 2 + 15, COLOR_BG)
        
        -- Avatar pad
        draw.RoundedBox(0, STARTING_X, STARTING_Y + (THUMBNAIL_HEIGHT + 5) * 2 + 5,
                        (THUMBNAIL_WIDTH + 10) * 2 - 10, THUMBNAIL_HEIGHT / 3 + 13, COLOR_BG)

        -- Timer Pad
        draw.RoundedBox(0, 0, 0, TIMER_PAD_WIDTH, TIMER_PAD_HEIGHT, COLOR_BG)

        -- Random button
        draw.RoundedBox(0, (THUMBNAIL_WIDTH + 5) * 2 + 60, STARTING_Y + (THUMBNAIL_HEIGHT + 5) * 2 + 5,
                (THUMBNAIL_WIDTH / 2), THUMBNAIL_HEIGHT / 3 + 13, COLOR_BG)

        -- Extend button
        draw.RoundedBox(0, (THUMBNAIL_WIDTH + 5) * 2 + 60 + THUMBNAIL_WIDTH / 2 + 5, STARTING_Y + (THUMBNAIL_HEIGHT + 5) * 2 + 5,
                (THUMBNAIL_WIDTH / 2), THUMBNAIL_HEIGHT / 3 + 13, COLOR_BG)

    end       
    frame:MakePopup()
    RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL = frame
end

local function deleteAvatars()
    hook.Remove("Think", "RMVAVATARBOUNCEUPDATE")
    for _, avatar in pairs(bounceAvatars) do
        avatar:Remove()
    end
    bounceAvatars = {}
    _avatarSpeed = {}
end

local function cleanup()
    deleteAvatars()
    for k, mapName in pairs(RMV_MAPVOTE_INFO.RMV_CANDIDATES) do
        mapLabels[mapName]:Remove()
        thumbnailBackgrounds[mapName]:Hide()
    end
    RMV_MAPVOTE_INFO.RMV_PLAYER_VOTES = {}
end

local function createCloseButton()
    local closeButton = vgui.Create("DImageButton", RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL)
    if RMV_CONVARS["rmv_lightmode"]:GetBool() then
        closeButton:SetImage("cross_black.png")
    else
        closeButton:SetImage("cross_white.png")
    end

    closeButton:SetPos(PANEL_WIDTH + 15, 7)
    closeButton:SetSize(30, 30)
    closeButton.DoClick = function()
        surface.PlaySound("garrysmod/ui_hover.wav")
        LocalPlayer():ChatPrint("Type '!rmvshow' to re-open the vote window!")
        cleanup()
        RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL:Hide()
    end
    RMV_GUI_ELEMENTS.RMV_CLOSE_BUTTON = closeButton
end

local function slideLerp(fraction, from, to)
    return Lerp(math.ease.OutQuart(fraction), from, to)
end

local function colorChangeAnimation(seconds)
    local anim = Derma_Anim("RMVCOLORCHANGE", RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL, function(pnl, anim, delta, data)
        if RMV_CONVARS["rmv_lightmode"]:GetBool() then
            COLOR_BG.a = slideLerp(delta, COLOR_DARK_BG.a, COLOR_LIGHT_BG.a)
            COLOR_BG.r = slideLerp(delta, COLOR_DARK_BG.r, COLOR_LIGHT_BG.r)
            COLOR_BG.g = slideLerp(delta, COLOR_DARK_BG.g, COLOR_LIGHT_BG.g)
            COLOR_BG.b = slideLerp(delta, COLOR_DARK_BG.b, COLOR_LIGHT_BG.b)
            COLOR_FG.a = slideLerp(delta, COLOR_DARK_FG.a, COLOR_LIGHT_FG.a)
            COLOR_FG.r = slideLerp(delta, COLOR_DARK_FG.r, COLOR_LIGHT_FG.r)
            COLOR_FG.g = slideLerp(delta, COLOR_DARK_FG.g, COLOR_LIGHT_FG.g)
            COLOR_FG.b = slideLerp(delta, COLOR_DARK_FG.b, COLOR_LIGHT_FG.b)
        else
            COLOR_BG.a = slideLerp(delta, COLOR_LIGHT_BG.a, COLOR_DARK_BG.a)
            COLOR_BG.r = slideLerp(delta, COLOR_LIGHT_BG.r, COLOR_DARK_BG.r)
            COLOR_BG.g = slideLerp(delta, COLOR_LIGHT_BG.g, COLOR_DARK_BG.g)
            COLOR_BG.b = slideLerp(delta, COLOR_LIGHT_BG.b, COLOR_DARK_BG.b)
            COLOR_FG.a = slideLerp(delta, COLOR_LIGHT_FG.a, COLOR_DARK_FG.a)
            COLOR_FG.r = slideLerp(delta, COLOR_LIGHT_FG.r, COLOR_DARK_FG.r)
            COLOR_FG.g = slideLerp(delta, COLOR_LIGHT_FG.g, COLOR_DARK_FG.g)
            COLOR_FG.b = slideLerp(delta, COLOR_LIGHT_FG.b, COLOR_DARK_FG.b)
        end
    end)

    anim:Start(seconds)
    RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL.Think = function(self)
        if anim:Active() then
            anim:Run()
        end
    end
end

local function createColorModeButton()
    local colorButton = vgui.Create("DImageButton", RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL)
    if RMV_CONVARS["rmv_lightmode"]:GetBool() then
        colorButton:SetImage("moon.png")
    else
        colorButton:SetImage("sun.png")
    end
    colorButton:SetPos(PANEL_WIDTH - 20, 8)
    colorButton:SetSize(28, 28)
    colorButton.m_bDepressImage = false
    colorButton.DoClick = function()
        RMV_CONVARS["rmv_lightmode"]:SetBool(not RMV_CONVARS["rmv_lightmode"]:GetBool())
        if RMV_CONVARS["rmv_lightmode"]:GetBool() then
            colorButton:SetImage("moon.png")
            RMV_GUI_ELEMENTS.RMV_CLOSE_BUTTON:SetImage("cross_black.png")
        else
            colorButton:SetImage("sun.png")
            RMV_GUI_ELEMENTS.RMV_CLOSE_BUTTON:SetImage("cross_white.png")
        end
        colorChangeAnimation(1)
    end
end

local function createRandomButton()
    local randomButton = vgui.Create("DButton", RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL)
    local xpos = (THUMBNAIL_WIDTH + 5) * 2 + 60
    local ypos = STARTING_Y + (THUMBNAIL_HEIGHT + 5) * 2 + 5
    randomButton:SetText("Random map")
    randomButton:SetPos(xpos, ypos)
    randomButton:SetSize(THUMBNAIL_WIDTH / 2, THUMBNAIL_HEIGHT / 3 + 13)
    randomButton:SetZPos(5)
    randomButton:SetTextColor(COLOR_FG)
    randomButton:SetFont("RMVButtonFont")
    randomButton.Paint = function(self, _w, _h)
        randomButton:SetTextColor(COLOR_FG)
    end

    THUMBNAIL_COORDS["random"] = {
        xpos,
        ypos,
        xpos + THUMBNAIL_WIDTH / 2,
        ypos + THUMBNAIL_HEIGHT / 3 + 13
    }

    randomButton.DoClick = function()
        if selectedMap ~= "random" then
            surface.PlaySound("buttons/button24.wav")
            selectedMap = "random"
            RMVRefreshThumbnailBackgrounds()
            rmvSendStringToServer(RMV_NETWORK_STRINGS["userChoice"], "random")
        end
    end
end

local function createExtendButton()
    local extendButton = vgui.Create("DButton", RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL)
    local xpos = (THUMBNAIL_WIDTH + 5) * 2 + 60
    local ypos = STARTING_Y + (THUMBNAIL_HEIGHT + 5) * 2 + 5
    extendButton:SetText("Extend map")
    extendButton:SetPos(xpos + THUMBNAIL_WIDTH / 2 + 5, ypos)
    extendButton:SetSize(THUMBNAIL_WIDTH / 2, THUMBNAIL_HEIGHT / 3 + 13)
    extendButton:SetTextColor(COLOR_FG)
    extendButton:SetFont("RMVButtonFont")
    extendButton:SetZPos(5)
    extendButton.Paint = function(self, _w, _h)
        extendButton:SetTextColor(COLOR_FG)
    end

    THUMBNAIL_COORDS["extend"] = {
        xpos + THUMBNAIL_WIDTH / 2 + 5,
        ypos - 1,
        xpos + THUMBNAIL_WIDTH + 5,
        ypos + THUMBNAIL_HEIGHT / 3 + 13
    }

    extendButton.DoClick = function()
        if selectedMap ~= "extend" then
            surface.PlaySound("buttons/button24.wav")
            selectedMap = "extend"
            RMVRefreshThumbnailBackgrounds()
            rmvSendStringToServer(RMV_NETWORK_STRINGS["userChoice"], "extend")
        end
    end
end

local function createAvatarDock()
    local xposCounter, yposCounter = STARTING_X + 5, STARTING_Y + (THUMBNAIL_HEIGHT + 5) * 2 + 10
    local counter = 1
    
    for key, p in pairs(RMV_MAPVOTE_INFO.RMV_ALL_PLAYERS) do
        RMV_MAPVOTE_INFO.RMV_PLAYER_VOTES[p] = -1
        local avatar = vgui.Create("AvatarImage", RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL)
        avatar:SetSize(AVATAR_INIT_SIZE, AVATAR_INIT_SIZE)
        avatar:SetPos(xposCounter, yposCounter)
        avatar:SetPlayer(p, 32)
        avatar:SetTooltip(p:GetName())
        avatar:SetParent(RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL)
        allAvatars[p] = avatar

        if counter == AVATAR_MAX_PER_ROW then
            yposCounter = yposCounter + AVATAR_INIT_SIZE + 5
            xposCounter = STARTING_X + 5
        else
            xposCounter = xposCounter + AVATAR_INIT_SIZE + 5
        end
        counter = counter + 1
    end
end

local function createTitleLabel(text)
    local titleLabel = vgui.Create("DLabel", RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL)
    titleLabel:SetText(text)
    titleLabel:SetFont("RMVTitleFont")
    titleLabel:SetPos(STARTING_X + 10, 0)
    titleLabel:SizeToContents()
    titleLabel.Paint = function(self, _, _)
        titleLabel:SetTextColor(COLOR_FG)
    end   
    RMV_GUI_ELEMENTS.RMV_TITLE_LABEL = titleLabel
end

local function createVLabel()
    local versionLabel = vgui.Create("DLabel", RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL)
    versionLabel:SetText("R" .. "a" .."f" .. "'" .. "s" .. "M" .. "a" .. "p" .. "V" .. "o" .. "t" .. "e" .. " " .. "v" .."1" .."." .. "0")
    versionLabel:SetPos(PANEL_WIDTH - 50, THUMBNAIL_COORDS["extend"][4] + 5)
    versionLabel:SetFont("RMVVersionFont")
    versionLabel:SetTextColor(Color(255, 255, 255, 200))
    versionLabel:SizeToContents()
end

local function createThumbnailBackgrounds()
    for _, map in pairs(RMV_MAPVOTE_INFO.RMV_CANDIDATES) do
        local panel = vgui.Create("DPanel")
        
        panel:SetPos(THUMBNAIL_COORDS[map][1], THUMBNAIL_COORDS[map][2])
        panel:SetSize(THUMBNAIL_COORDS[map][3] - THUMBNAIL_COORDS[map][1],
                      THUMBNAIL_COORDS[map][4] - THUMBNAIL_COORDS[map][2])
        panel:SetParent(RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL)
        panel:SetBackgroundColor(Color(0, 0, 0, 0))
        
        panel.Paint = function(self, _w, _h)
            if _rainbowCounter >= 360 then
                _rainbowCounter = 0
            end
            draw.RoundedBox(0, 0, 0, _w, _h, HSVToColor(_rainbowCounter % 360, 0.8, 0.9))
            _rainbowCounter = _rainbowCounter + 0.1
        end
        thumbnailBackgrounds[map] = panel
    end
end

function RMVRefreshThumbnailBackgrounds()
    for map, background in pairs(thumbnailBackgrounds) do
        background:Hide()
        if map == RMV_MAPVOTE_INFO.RMV_NEXT_MAP then
            local isAlphaAscending = true
            background.Paint = function(self, _w, _h)
                if _flashCounter >= 255 then
                    _flashCounter = 255
                    isAlphaAscending = false
                elseif _flashCounter <= 0 then
                    _flashCounter = 0
                    isAlphaAscending = true
                end

                draw.RoundedBox(0, 0, 0, _w, _h, Color(21, 255, 0, _flashCounter))

                if isAlphaAscending then
                    _flashCounter = _flashCounter + 2
                else
                    _flashCounter = _flashCounter - 2
                end
            end
            background:Show()
        elseif map == selectedMap then
            background:Show()
        end
    end
end

local function createMapThumbnails()
    for k, mapName in pairs(RMV_MAPVOTE_INFO.RMV_CANDIDATES) do      
        local mapVoteImage = vgui.Create("DImageButton", RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL)
        mapVoteImage:SetPos(THUMBNAIL_COORDS[mapName][1] + 3, THUMBNAIL_COORDS[mapName][2] + 3)
        mapVoteImage:SetSize(THUMBNAIL_WIDTH - 6, THUMBNAIL_HEIGHT - 6)
        mapVoteImage.m_bDepressImage = false
        _thumbnailSlide[mapName] = (6 - k) * 0.05
        mapVoteImage.Paint = function(self, _w, _h)
            mapVoteImage:SetPos(THUMBNAIL_COORDS[mapName][1] + 3,
                                slideLerp(_thumbnailSlide[mapName], -200,THUMBNAIL_COORDS[mapName][2] + 3))
            _thumbnailSlide[mapName] = math.Clamp(0, 1, _thumbnailSlide[mapName] + 0.0025)
        end

        local fileName = "maps/thumb/" .. mapName .. ".png"

        -- Checks if user has a custom thumbnail under 'data', then checks maps directory for thumbnail
        -- if no thumbnails are found, default to blank thumbnail
        if file.Exists("rafsmapvote/thumbnails/" .. mapName .. ".png", "DATA") then
            mapVoteImage:SetImage("data/rafsmapvote/thumbnails/" .. mapName .. ".png")
        elseif file.Exists("rafsmapvote/thumbnails/" .. mapName .. ".jpg", "DATA") then
            mapVoteImage:SetImage("data/rafsmapvote/thumbnails/" .. mapName .. ".jpg")
        elseif file.Exists(fileName, "GAME") then
            mapVoteImage:SetImage(fileName)
        else
            mapVoteImage:SetImage("no_thumbnail.jpg")
        end
        
        thumbnails[mapName] = MapVoteImage
        mapVoteImage.DoClick = function()
            if selectedMap ~= mapName then
                surface.PlaySound("buttons/button24.wav")
                selectedMap = mapName
                RMVRefreshThumbnailBackgrounds()
                rmvSendStringToServer(RMV_NETWORK_STRINGS["userChoice"], mapName)
            end
        end
    end
end

local function createMapLabels()
    for k, mapName in pairs(RMV_MAPVOTE_INFO.RMV_CANDIDATES) do
        local mapLabel = vgui.Create("DLabel", RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL)
        mapLabel:SetText(" " .. mapName)
        mapLabel:SetTextColor(COLOR_DARK_FG)
        mapLabel:SetFont("RMVTextOverImageFont")
        mapLabel:SetSize(THUMBNAIL_WIDTH, 40)
        mapLabel:SetPos(THUMBNAIL_COORDS[mapName][1] + 3, THUMBNAIL_COORDS[mapName][2] + THUMBNAIL_HEIGHT - 39)
        mapLabel.Paint = function(sekf, _w, _h)
            draw.RoundedBox(0, 0, 5, _w - 6, 31, Color(50, 50, 50, 200))
        end
        mapLabel:SetAlpha(0)
        mapLabel:AlphaTo(255, 0.65, k * 0.45, function() end)
        mapLabel:SetZPos(5)
        mapLabels[mapName] = mapLabel
    end
end

local function createTimerBar(seconds, secondsLeft)
    local panel = vgui.Create("DPanel")
    panel:SetParent(RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL)

    local delta = secondsLeft / seconds

    if delta < 1 then
        TIMER_BAR_ACTIVE_HEIGHT = (TIMER_BAR_HEIGHT - (panel:GetY() + panel:GetTall())) * delta
    else
        TIMER_BAR_ACTIVE_HEIGHT = TIMER_BAR_HEIGHT
    end

    panel:SetSize(TIMER_BAR_WIDTH, TIMER_BAR_ACTIVE_HEIGHT)
    panel:SetPos(5, TIMER_BAR_HEIGHT - panel:GetTall() + 5)

    panel.Paint = function(self, _w, _h)
        draw.RoundedBox(0, 0, 0, _w, _h, COLOR_FG)
    end
    
    timerBar = panel
end

local function startTimer(seconds)
    local anim = Derma_Anim("RMVVOTECOUNTDOWN", timerBar, function(pnl, anim, delta, data)
        pnl:SetHeight(TIMER_BAR_ACTIVE_HEIGHT - (pnl:GetY() + pnl:GetTall()) * delta)
        pnl:SetY(TIMER_BAR_HEIGHT - pnl:GetTall() + 5)
    end)

    anim:Start(seconds)
    timerBar.Think = function(self)
        if anim:Active() then
            anim:Run()
        end
    end
end

local function nonZeroRandom(min, max)
    local temp = 0
    while temp == 0 do
        temp = math.random(min, max)
    end
    return temp
end

local function initAvatarBounce(thumbnailCoords, voter) 
    local xmin = thumbnailCoords[1] + 3
    local ymin = thumbnailCoords[2] + 3
    local xmax = thumbnailCoords[3] - AVATAR_THUMBNAIL_SIZE - 3
    local ymax = thumbnailCoords[4] - AVATAR_THUMBNAIL_SIZE - 3

    local playerAvatar = bounceAvatars[voter]
    if  playerAvatar == nil then
        playerAvatar = vgui.Create("AvatarImage", RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL)
        playerAvatar:SetSize(AVATAR_THUMBNAIL_SIZE, AVATAR_THUMBNAIL_SIZE)
        playerAvatar:SetPlayer(voter, 64)
    end
    playerAvatar:SetPos(math.random(xmin, xmax), math.random(ymin, ymax))
    bounceAvatars[voter] = playerAvatar
    
    local xspeed = nonZeroRandom(-3, 3)
    local yspeed = nonZeroRandom(-3, 3)
    _avatarSpeed[voter] = {xspeed, yspeed}
end

local function updateAvatars()
    for pl, av in pairs(bounceAvatars) do
        local xpos, ypos = av:GetPos()
        local xspeed = _avatarSpeed[pl][1]
        local yspeed = _avatarSpeed[pl][2]

        local xmin = THUMBNAIL_COORDS[RMV_MAPVOTE_INFO.RMV_PLAYER_VOTES[pl]][1] + 3
        local ymin = THUMBNAIL_COORDS[RMV_MAPVOTE_INFO.RMV_PLAYER_VOTES[pl]][2] + 3
        local xmax = THUMBNAIL_COORDS[RMV_MAPVOTE_INFO.RMV_PLAYER_VOTES[pl]][3] - AVATAR_THUMBNAIL_SIZE - 3
        local ymax = THUMBNAIL_COORDS[RMV_MAPVOTE_INFO.RMV_PLAYER_VOTES[pl]][4] - AVATAR_THUMBNAIL_SIZE - 3

        if xpos>= xmax + 1 or xpos <= xmin - 1 then
            xspeed = xspeed * -1;
        end

        if ypos >= ymax + 1 or ypos <= ymin - 1 then
            yspeed = yspeed * -1;
        end
        _avatarSpeed[pl][1] = xspeed
        _avatarSpeed[pl][2] = yspeed
        av:SetPos(xpos + xspeed, ypos + yspeed)
    end
end

function RMVRefreshAvatars(ply)
    if allAvatars[ply] ~= nil then
        allAvatars[ply]:Remove()
        allAvatars[ply] = nil
    end
    initAvatarBounce(THUMBNAIL_COORDS[RMV_MAPVOTE_INFO.RMV_PLAYER_VOTES[ply]], ply)
end

local function initializeColor()
    if RMV_CONVARS["rmv_lightmode"]:GetBool() then
        COLOR_BG = Color(255, 255, 255, 255)
        COLOR_FG = Color(0, 0, 0, 255)
    else
        COLOR_BG = Color(50, 50, 50, 200)
        COLOR_FG = Color(255, 255, 255, 255)
    end
end

local function reinstantiatePanel()
    _blurCounter = 0
    for k, mapName in pairs(RMV_MAPVOTE_INFO.RMV_CANDIDATES) do
        _thumbnailSlide[mapName] = (6 - k) * 0.05
    end
    createAvatarDock()
    RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL:Show()
    timer.Simple(2.7, function()
        RMVRefreshThumbnailBackgrounds()
    end)
end


function RMVShowMapvote()
    if RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL == nil then
        calculateThumbnailPositions()
        createMainPanel()
        createCloseButton()
        createColorModeButton()
        createRandomButton()
        createExtendButton()
        createTitleLabel("Vote for the next map:")
        createVLabel()
        createThumbnailBackgrounds()
        createAvatarDock()
        createMapThumbnails()
        RMVRefreshThumbnailBackgrounds()
    else
        reinstantiatePanel()
    end
    
    createTimerBar(RMV_MAPVOTE_INFO.RMV_TIMER_SECONDS, RMV_MAPVOTE_INFO.RMV_TIMER_SECONDS_LEFT)
    startTimer(RMV_MAPVOTE_INFO.RMV_TIMER_SECONDS)
    createMapLabels()
    
    _bounceCounter = 0
    hook.Add("Think", "RMVAVATARBOUNCEUPDATE", function()
        if CurTime() < _bounceCounter or RMV_GUI_ELEMENTS.RMV_MAPVOTE_PANEL == nil then
            return
        end
        updateAvatars()
        _bounceCounter = CurTime() + _updateInterval
    end)
    
    initializeColor()
end
