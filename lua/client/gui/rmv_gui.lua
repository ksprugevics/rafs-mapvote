RMV_MAPVOTE_PANEL = nil
RMV_CLOSE_BUTTON = nil

-- Positions
local GUI_STARTING_X = 55
local GUI_STARTING_Y = 55
local GUI_UI_WIDTH = ScrW() * 0.75
local GUI_UI_HEIGHT = ScrH() * 0.8
local GUI_THUMBNAIL_COORDS = {}

-- Sizes
local GUI_THUMBNAIL_WIDTH = (GUI_UI_WIDTH - 20) / 3  
local GUI_THUMBNAIL_HEIGHT = (GUI_THUMBNAIL_WIDTH - 20) / 16 * 9 
local GUI_AVATAR_THUMBNAIL_SIZE = (GUI_THUMBNAIL_WIDTH - 65) / 12
local GUI_AVATAR_MAX_PER_ROW = 20
local GUI_AVATAR_INIT_SIZE = ((GUI_THUMBNAIL_WIDTH + 10) * 2 - (GUI_AVATAR_MAX_PER_ROW + 3) * 5) / GUI_AVATAR_MAX_PER_ROW
local GUI_TIMER_BAR_WIDTH = 40
local GUI_TIMER_BAR_HEIGHT = GUI_STARTING_Y + (GUI_THUMBNAIL_HEIGHT + 5) * 2 + 5 + GUI_THUMBNAIL_HEIGHT / 3 + 13 - 10
local GUI_TIMER_BAR_ACTIVE_HEIGHT = GUI_TIMER_BAR_HEIGHT
local GUI_TIMER_PAD_WIDTH = GUI_TIMER_BAR_WIDTH + 10
local GUI_TIMER_PAD_HEIGHT = GUI_TIMER_BAR_HEIGHT + 10

local LIGHT_MODE = false

-- Colors
local GUI_COLOR_DARK_BG = Color(50, 50, 50, 200)
local GUI_COLOR_DARK_FG = Color(255, 255, 255, 255)
local GUI_COLOR_LIGHT_BG = Color(255, 255, 255,180)
local GUI_COLOR_LIGHT_FG = Color(0, 0, 0, 255)
local GUI_BASE_PANEL_COLOR = GUI_COLOR_DARK_BG
local GUI_BASE_TEXT_COLOR = GUI_COLOR_DARK_FG

-- Animations
local GUI_UPDATE_INTERVAL = 0.01
local GUI_FADE = 0

-- Variables
local thumbnails = {}
local timerBar = nil
local thumbnailBackgrounds = {}
local allAvatars = {}
local selectedMap = nil
local rainbowCounter = 0
local flashCounter = 0


local function createMainPanel()

    local frame = vgui.Create("DFrame")
    frame:SetTitle("")
    frame:SetSize(GUI_UI_WIDTH + 55, GUI_UI_HEIGHT)
    frame:Center()
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    frame:SetKeyboardInputEnabled(false)
    frame.Paint = function(self, _w, _h)          
        Derma_DrawBackgroundBlur(self, SysTime() - math.Clamp(0, 1000, GUI_FADE))
        GUI_FADE = GUI_FADE + 0.01
        draw.RoundedBox(0, GUI_STARTING_X, 0, _w, 45, GUI_BASE_PANEL_COLOR)
        draw.RoundedBox(0, GUI_STARTING_X, GUI_STARTING_Y - 5, _w + 15, GUI_THUMBNAIL_HEIGHT * 2 + 15, GUI_BASE_PANEL_COLOR)
        draw.RoundedBox(0, GUI_STARTING_X, GUI_STARTING_Y + (GUI_THUMBNAIL_HEIGHT + 5) * 2 + 5, (GUI_THUMBNAIL_WIDTH + 10) * 2 - 10, GUI_THUMBNAIL_HEIGHT / 3 + 13, GUI_BASE_PANEL_COLOR)
        draw.RoundedBox(0, 0, 0, GUI_TIMER_PAD_WIDTH, GUI_TIMER_PAD_HEIGHT, GUI_BASE_PANEL_COLOR)
    end       
    RMV_MAPVOTE_PANEL = frame
end

local function createCloseButton()
    local closeButton = vgui.Create("DImageButton", RMV_MAPVOTE_PANEL)
    if LIGHT_MODE then
        closeButton:SetImage("cross_black.png")
    else
        closeButton:SetImage("cross_white.png")
    end

    closeButton:SetPos(GUI_UI_WIDTH + 15, 7)
    closeButton:SetSize(30, 30)
    closeButton.DoClick = function()
        surface.PlaySound("garrysmod/ui_hover.wav")
        LocalPlayer():ChatPrint("Type '!rmvshow' to re-open the vote window!")
        RMV_MAPVOTE_PANEL:Hide()
        RMV_CLOSED = true
    end
    RMV_CLOSE_BUTTON = closeButton
end

local function changeColor()
    if LIGHT_MODE then
        GUI_BASE_PANEL_COLOR = GUI_COLOR_LIGHT_BG
        GUI_BASE_TEXT_COLOR = GUI_COLOR_LIGHT_FG
        RMV_CLOSE_BUTTON:SetImage("cross_black.png")
    else
        GUI_BASE_PANEL_COLOR = GUI_COLOR_DARK_BG
        GUI_BASE_TEXT_COLOR = GUI_COLOR_DARK_FG
        RMV_CLOSE_BUTTON:SetImage("cross_white.png")
    end
end

local function createColorModeButton()
    local colorButton = vgui.Create("DImageButton", RMV_MAPVOTE_PANEL)
    if LIGHT_MODE then
        colorButton:SetImage("moon.png")
    else
        colorButton:SetImage("sun.png")
    end
    colorButton:SetPos(GUI_UI_WIDTH - 20, 7)
    colorButton:SetSize(30, 30)
    colorButton.DoClick = function()
        LIGHT_MODE = not LIGHT_MODE
        if LIGHT_MODE then
            colorButton:SetImage("moon.png")
        else
            colorButton:SetImage("sun.png")
        end
        changeColor()
    end
end


local function createVLabel()
    local versionLabel = vgui.Create("DLabel", RMV_MAPVOTE_PANEL)
    versionLabel:SetText("R" .. "a" .."f" .. "'" .. "s" .. "M" .. "a" .. "p" .. "V" .. "o" .. "t" .. "e" .. " " .. "v" .."1" .."." .. "0")
    versionLabel:SetPos(GUI_THUMBNAIL_COORDS["random"][3] - 110, GUI_THUMBNAIL_COORDS["random"][4] + 5)
    versionLabel:SetFont("Version font")
    versionLabel:SetTextColor(Color(255, 255, 255, 200))
    versionLabel:SizeToContents()
end

local function createTitleLabel(text)
    local titleLabel = vgui.Create("DLabel", RMV_MAPVOTE_PANEL)
    titleLabel:SetText(text)
    titleLabel:SetFont("TitleFont")
    titleLabel:SetPos(GUI_STARTING_X + 10, 0)
    titleLabel:SizeToContents()
    titleLabel.Paint = function(self, _, _)
        titleLabel:SetTextColor(GUI_BASE_TEXT_COLOR)
    end   
end

local function createRandomButton()
    local randomButton = vgui.Create("DButton", RMV_MAPVOTE_PANEL)
    local xpos = (GUI_THUMBNAIL_WIDTH + 5) * 2 + 60
    local ypos = GUI_STARTING_Y + (GUI_THUMBNAIL_HEIGHT + 5) * 2 + 5
    randomButton:SetText("Random map")
    randomButton:SetPos(xpos, ypos)
    randomButton:SetSize(GUI_THUMBNAIL_WIDTH + 15, GUI_THUMBNAIL_HEIGHT / 3 + 13)
    randomButton:SetTextColor(GUI_BASE_TEXT_COLOR)
    randomButton:SetFont("ButtonFont")
    randomButton.Paint = function(self, _w, _h)
        randomButton:SetTextColor(GUI_BASE_TEXT_COLOR)
        draw.RoundedBox(0, 0, 0, _w, _h, GUI_BASE_PANEL_COLOR)
    end

    GUI_THUMBNAIL_COORDS["random"] = {
        xpos,
        ypos,
        xpos + GUI_THUMBNAIL_WIDTH,
        ypos + GUI_THUMBNAIL_HEIGHT / 3 + 13
    }

    randomButton.DoClick = function()
        surface.PlaySound("buttons/button24.wav")
        selectedMap = "random"
        refreshThumbnailBackgrounds()
        rmvSendStringToServer(RMV_NETWORK_STRINGS["userChoice"], "random")
    end
end

local function createMapThumbnails()
    for k, mapName in pairs(RMV_MAPS) do

        local MapVoteImage = vgui.Create("DImageButton", RMV_MAPVOTE_PANEL)
        local MapLabel = vgui.Create("DLabel", RMV_MAPVOTE_PANEL)

        MapLabel:SetText(mapName)
        MapLabel:SetTextColor(GUI_BASE_TEXT_COLOR)
        MapLabel:SetFont("TextOverImageFont")
        MapLabel:SetSize(GUI_THUMBNAIL_WIDTH, 40)

        MapVoteImage:SetPos(GUI_THUMBNAIL_COORDS[mapName][1] + 3, GUI_THUMBNAIL_COORDS[mapName][2] + 3)
        MapLabel:SetPos(GUI_THUMBNAIL_COORDS[mapName][1] + 7, GUI_THUMBNAIL_COORDS[mapName][2] + GUI_THUMBNAIL_HEIGHT - 40)
        MapVoteImage:SetSize(GUI_THUMBNAIL_WIDTH - 6, GUI_THUMBNAIL_HEIGHT - 6)
        

        local fileName = "maps/thumb/" .. mapName .. ".png"

        -- Checks if user has a custom thumbnail under 'data', then checks maps directory for thumbnail
        -- if no thumbnails are found, default to blank thumbnail
        if file.Exists("rafsmapvote/thumbnails/" .. mapName .. ".png", "DATA") then
            MapVoteImage:SetImage("data/rafsmapvote/thumbnails/" .. mapName .. ".png")
        elseif file.Exists("rafsmapvote/thumbnails/" .. mapName .. ".jpg", "DATA") then
            MapVoteImage:SetImage("data/rafsmapvote/thumbnails/" .. mapName .. ".jpg")
        elseif file.Exists(fileName, "GAME") then
            MapVoteImage:SetImage(fileName)
        else
            MapVoteImage:SetImage("no_thumbnail.jpg")
        end
        
        thumbnails[mapName] = MapVoteImage
        MapVoteImage.DoClick = function()
            surface.PlaySound("buttons/button24.wav")
            selectedMap = mapName
            refreshThumbnailBackgrounds()
            rmvSendStringToServer(RMV_NETWORK_STRINGS["userChoice"], mapName)
        end
    end
end

local function createThumbnailBackgrounds()
    for _, map in pairs(RMV_MAPS) do
        local panel = vgui.Create("DPanel")
        
        panel:SetPos(GUI_THUMBNAIL_COORDS[map][1], GUI_THUMBNAIL_COORDS[map][2])
        panel:SetSize(GUI_THUMBNAIL_COORDS[map][3] - GUI_THUMBNAIL_COORDS[map][1], GUI_THUMBNAIL_COORDS[map][4] - GUI_THUMBNAIL_COORDS[map][2])
        panel:SetParent(RMV_MAPVOTE_PANEL)
        panel:SetBackgroundColor(Color(0, 255, 255, 0))
        
        panel.Paint = function(self, _w, _h)
            if rainbowCounter >= 360 then
                rainbowCounter = 0
            end
            draw.RoundedBox(0, 0, 0, _w, _h, HSVToColor(rainbowCounter % 360, 0.8, 0.9))
            rainbowCounter = rainbowCounter + 0.1
        end
        thumbnailBackgrounds[map] = panel
    end
end

local function createAvatarDock()
    -- Initial position of avatars
    local xposCounter, yposCounter = GUI_STARTING_X + 5, GUI_STARTING_Y + (GUI_THUMBNAIL_HEIGHT + 5) * 2 + 10
    local counter = 1
    
    for key, p in pairs(RMV_ALL_PLAYERS) do
        RMV_PLAYER_VOTES[p] = -1
        local avatar = vgui.Create("AvatarImage", RMV_MAPVOTE_PANEL)
        avatar:SetSize(GUI_AVATAR_INIT_SIZE, GUI_AVATAR_INIT_SIZE)
        avatar:SetPos(xposCounter, yposCounter)
        avatar:SetPlayer(p, 32)
        avatar:SetTooltip(p:GetName())
        avatar:SetParent(RMV_MAPVOTE_PANEL)
        allAvatars[p] = avatar

        if counter == GUI_AVATAR_MAX_PER_ROW then
            yposCounter = yposCounter + GUI_AVATAR_INIT_SIZE + 5
            xposCounter = GUI_STARTING_X + 5
        else
            xposCounter = xposCounter + GUI_AVATAR_INIT_SIZE + 5
        end
        counter = counter + 1
    end
end

local function calculateThumbnailPositions()
    for k, mapName in pairs(RMV_MAPS) do
        local xpos = 0
        local ypos = 0
        if k < 4 then
            xpos = GUI_STARTING_X + (GUI_THUMBNAIL_WIDTH + 5) * (k - 1) + 5
            ypos = GUI_STARTING_Y
        else
            xpos = GUI_STARTING_X + (GUI_THUMBNAIL_WIDTH + 5) * (k - 4) + 5
            ypos = GUI_STARTING_Y + GUI_THUMBNAIL_HEIGHT + 5
        end
        
        GUI_THUMBNAIL_COORDS[mapName] = {xpos,
        ypos,
        xpos + GUI_THUMBNAIL_WIDTH,
        ypos + GUI_THUMBNAIL_HEIGHT}

    end
end


local function createTimerBar(seconds, secondsLeft)
    local panel = vgui.Create("DPanel")
    panel:SetParent(RMV_MAPVOTE_PANEL)

    local delta = secondsLeft / seconds

    if delta < 1 then
        GUI_TIMER_BAR_ACTIVE_HEIGHT = (GUI_TIMER_BAR_HEIGHT - (panel:GetY() + panel:GetTall())) * delta
    else
        GUI_TIMER_BAR_ACTIVE_HEIGHT = GUI_TIMER_BAR_HEIGHT
    end

    panel:SetSize(GUI_TIMER_BAR_WIDTH, GUI_TIMER_BAR_ACTIVE_HEIGHT)
    panel:SetPos(5, GUI_TIMER_BAR_HEIGHT - panel:GetTall() + 5)

    panel.Paint = function(self, _w, _h)
        draw.RoundedBox(0, 0, 0, _w, _h, GUI_BASE_TEXT_COLOR)
    end
    
    timerBar = panel
end

local function startTimer(seconds)

    local anim = Derma_Anim("CountdownTimer", timerBar, function(pnl, anim, delta, data)
        pnl:SetHeight(GUI_TIMER_BAR_ACTIVE_HEIGHT - (pnl:GetY() + pnl:GetTall()) * delta)
        pnl:SetY(GUI_TIMER_BAR_HEIGHT - pnl:GetTall() + 5)
    end)

    anim:Start(seconds)
    timerBar.Think = function(self)
        if anim:Active() then
            anim:Run()
        end
    end
end


function refreshThumbnailBackgrounds() 
    for map, background in pairs(thumbnailBackgrounds) do
        background:Hide()
        if map == RMV_NEXT_MAP then
            local isAlphaAscending = true
            background.Paint = function(self, _w, _h)
                if flashCounter >= 255 then
                    flashCounter = 255
                    isAlphaAscending = false
                elseif flashCounter <= 0 then
                    flashCounter = 0
                    isAlphaAscending = true
                end

                draw.RoundedBox(0, 0, 0, _w, _h, Color(21, 255, 0, flashCounter))

                if isAlphaAscending then
                    flashCounter = flashCounter + 2
                else
                    flashCounter = flashCounter - 2
                end
            end
            background:Show()
        elseif map == selectedMap then
            background:Show()
        end
    end
end

function RefreshAvatar(ply)
    if allAvatars[ply] ~= nil then
        allAvatars[ply]:Remove()
        allAvatars[ply] = nil
    end
    InitAvatar(GUI_THUMBNAIL_COORDS[RMV_PLAYER_VOTES[ply]], GUI_AVATAR_THUMBNAIL_SIZE, ply)
end


function InitGUI()
    if RMV_TIMER_SECONDS_LEFT == RMV_TIMER_SECONDS then
        selectedMap = nil
    end
    
    createMainPanel()
    createCloseButton()
    createTitleLabel("Vote for the next map:")
    createRandomButton()
    calculateThumbnailPositions()
    createThumbnailBackgrounds()
    createMapThumbnails()
    createAvatarDock()
    createVLabel()
    createColorModeButton()
    createTimerBar(RMV_TIMER_SECONDS, RMV_TIMER_SECONDS_LEFT)
    startTimer(RMV_TIMER_SECONDS)
    refreshThumbnailBackgrounds()
end


local ticker = 0
hook.Add("Think", "CurTimeDelay", function()
    if CurTime() <= ticker then
        return
    end	
    if RMV_MAPVOTE_PANEL ~= nil then
        if not RMV_MAPVOTE_PANEL:IsValid() then
            ticker = CurTime() 
            return
        end
    end
    UpdateAvatars(GUI_THUMBNAIL_COORDS, GUI_AVATAR_THUMBNAIL_SIZE)
    ticker = CurTime() + GUI_UPDATE_INTERVAL
end)
