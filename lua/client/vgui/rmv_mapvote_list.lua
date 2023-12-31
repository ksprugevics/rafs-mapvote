local mapListPanel = nil
local RMVcloseButton = nil
local maps = nil
local history = nil

-- Maplist Panel
local STARTING_X = 10
local STARTING_Y = 15
local PANEL_WIDTH = ScrW() * 0.35
local PANEL_HEIGHT = ScrH() * 0.8
local _blurCounter = 0

-- Colors
local _lightMode = false
local COLOR_DARK_BG = Color(50, 50, 50, 200)
local COLOR_DARK_BG2 = Color(120, 120, 120, 200)
local COLOR_DARK_FG = Color(255, 255, 255, 255)
local COLOR_LIGHT_BG = Color(255, 255, 255, 255)
local COLOR_LIGHT_BG2 = Color(50, 50, 50, 200)
local COLOR_LIGHT_FG = Color(0, 0, 0)
local COLOR_BG = Color(50, 50, 50, 200)
local COLOR_BG2 = Color(120, 120, 120, 200)
local COLOR_FG = Color(255, 255, 255, 255)

-- Map list
local mapList = {}

local function createMaplistPanel()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:SetKeyboardInputEnabled(false)
    frame:SetSize(PANEL_WIDTH, PANEL_HEIGHT)
    frame:Center()
    frame.Paint = function(self, _w, _h) 
        Derma_DrawBackgroundBlur(self, SysTime() - math.Clamp(0, 1000, _blurCounter))
        _blurCounter = _blurCounter + 0.005         
        draw.RoundedBox(0, 0, 0, _w, _h, COLOR_BG)
    end
    frame:MakePopup()
    mapListPanel = frame
end

local function createTitleLabel()
    local titleLabel = mapListPanel:Add("DLabel")
    titleLabel:SetText("Server map pool")
    titleLabel:SetFont("RMVTitleFontList")
    titleLabel:SizeToContents()
    titleLabel:CenterHorizontal(0.5)
    titleLabel.Paint = function(self, _, _)
        titleLabel:SetTextColor(COLOR_FG)
    end
end

local function createHeader()
    local headerPanel = vgui.Create("DPanel", mapListPanel)
    headerPanel:SetSize(PANEL_WIDTH - 35, 40)
    headerPanel:SetPos(10, 80)

    headerPanel.Paint = function(self, _w, _h)
        draw.RoundedBox(0, 0, 0, _w, _h, COLOR_BG2)
    end

    local mapNameLabel = vgui.Create("DLabel", headerPanel) 
    mapNameLabel:SetText("Nr.          Map")
    mapNameLabel:SetPos(10, 5)
    mapNameLabel:SetFont("RMVTextOverImageFont")
    mapNameLabel:SetTextColor(Color(255, 255, 255, 255))
    mapNameLabel:SizeToContents()

    local timesPlayedLabel = vgui.Create("DLabel", headerPanel) 
    timesPlayedLabel:SetText("Times played")
    timesPlayedLabel:SetPos(PANEL_WIDTH - 200, 5)
    timesPlayedLabel:SetFont("RMVTextOverImageFont")
    timesPlayedLabel:SetTextColor(Color(255, 255, 255, 255))
    timesPlayedLabel:SizeToContents()

end

local function createCloseButton()
    local closeButton = vgui.Create("DImageButton", mapListPanel)
    if RMV_CONVARS["rmv_lightmode"]:GetBool() then
        closeButton:SetImage("cross_black.png")
    else
        closeButton:SetImage("cross_white.png")
    end

    closeButton:SetPos(PANEL_WIDTH - 35, STARTING_Y - 10)
    closeButton:SetSize(30, 30)
    closeButton.DoClick = function()
        surface.PlaySound("garrysmod/ui_hover.wav")
        _blurCounter = 0
        mapListPanel:Hide()
    end
    RMVcloseButton = closeButton
end

local function createMapPanel(name, count, index, cooldown)
    local mapPanel = vgui.Create("DPanel")
    mapPanel:SetHeight(110)
    mapPanel.Paint = function(self, _w, _h)
        if cooldown then
            draw.RoundedBox(0, 0, 0, _w, _h, Color(213, 90, 90))
        else
            draw.RoundedBox(0, 0, 0, _w, _h, COLOR_BG2)
        end
    end

    local mapThumbnail = vgui.Create("DImage", mapPanel)
    mapThumbnail:SetPos(10, 10)
    mapThumbnail:SetSize(90, 90)
    local fileName = "maps/thumb/" .. name .. ".png"

    -- Checks if user has a custom thumbnail under 'data', then checks maps directory for thumbnail
    -- if no thumbnails are found, default to blank thumbnail
    if file.Exists("rafsmapvote/thumbnails/" .. name .. ".png", "DATA") then
        mapThumbnail:SetImage("data/rafsmapvote/thumbnails/" .. name .. ".png")
    elseif file.Exists("rafsmapvote/thumbnails/" .. name .. ".jpg", "DATA") then
        mapThumbnail:SetImage("data/rafsmapvote/thumbnails/" .. name .. ".jpg")
    elseif file.Exists(fileName, "GAME") then
        mapThumbnail:SetImage(fileName)
    else
        mapThumbnail:SetImage("no_thumbnail.jpg")
    end
    
    local mapLabel = mapPanel:Add("DLabel")
    mapLabel:SetPos(13, 10)
    mapLabel:SetText(index .. ".")
    mapLabel:SetFont("RMVNumberFont")
    mapLabel:SetTextColor(Color(255, 255, 255, 255))
    mapLabel:SizeToContents()

    local mapLabel = mapPanel:Add("DLabel")
    
    if cooldown then
        mapLabel:SetPos(115, 20)
    else
        mapLabel:SetPos(115, 40)
    end

    mapLabel:SetText(name)
    if cooldown then
        mapLabel:SetFont("RMVTextOverImageFontStrikeout")
        mapLabel:SetTextColor(Color(129, 129, 129))
    else
        mapLabel:SetFont("RMVTextOverImageFont")
        mapLabel:SetTextColor(Color(255, 255, 255, 255))
    end
    mapLabel:SizeToContents()

    if cooldown then
        local cooldownTimer = mapPanel:Add("DImage")
        cooldownTimer:SetImage("clock.png")
        cooldownTimer:SetSize(25, 25)
        cooldownTimer:SetPos(115, 65)

        local cooldownTimerLabel = mapPanel:Add("DLabel")
        cooldownTimerLabel:SetPos(144, 65)
        cooldownTimerLabel:SetText("Map on cooldown")
        cooldownTimerLabel:SetFont("RMVNumberFont")
        cooldownTimerLabel:SetTextColor(Color(255, 255, 255, 255))
        cooldownTimerLabel:SizeToContents()

    end

    local mapCountLabel = mapPanel:Add("DLabel")
    mapCountLabel:SetPos(PANEL_WIDTH - 120, 40)
    -- Custom RightAlign (AlignRight() didnt work for me)
    mapCountLabel:SetText("" .. string.rep("  ", 5 - string.len(count)) .. count)
    mapCountLabel:SetFont("RMVTextOverImageFont")
    mapCountLabel:SetTextColor(Color(255, 255, 255, 255))
    mapCountLabel:SizeToContents()
    return mapPanel
end

local function createMapEntries(maps, history)
    local list = vgui.Create("DScrollPanel", mapListPanel)
    list:Dock(FILL)
    list:DockMargin(0, 95, 0, 0)

    for i, entry in pairs(maps) do
        local mapOnCooldown = false
        if history[entry.map] ~= nil then
            mapOnCooldown = true
        end
        local entryPanel = list:Add(createMapPanel(entry.map, entry.played, i, mapOnCooldown))
        
        entryPanel:Dock(TOP)
        entryPanel:DockMargin(5, 0, 5, 5)
    end

    local scrollBar = list:GetVBar()
    scrollBar:SetHideButtons(true)
    scrollBar.Paint = function(self, _w, _h)
        draw.RoundedBox(0, 0, 0, _w, _h, Color(0, 0, 0, 0))
    end
    scrollBar.btnGrip.Paint = function(self, _w, _h)
        draw.RoundedBox(0, 0, 0, _w, _h, COLOR_FG)
    end
end

local function slideLerp(fraction, from, to)
    return Lerp(math.ease.OutQuart(fraction), from, to)
end

local function colorChangeAnimation(seconds)
    local anim = Derma_Anim("RMVCOLORCHANGE", mapListPanel, function(pnl, anim, delta, data)
        if RMV_CONVARS["rmv_lightmode"]:GetBool() then
            COLOR_BG.a = slideLerp(delta, COLOR_DARK_BG.a, COLOR_LIGHT_BG.a)
            COLOR_BG.r = slideLerp(delta, COLOR_DARK_BG.r, COLOR_LIGHT_BG.r)
            COLOR_BG.g = slideLerp(delta, COLOR_DARK_BG.g, COLOR_LIGHT_BG.g)
            COLOR_BG.b = slideLerp(delta, COLOR_DARK_BG.b, COLOR_LIGHT_BG.b)
            COLOR_BG2.a = slideLerp(delta, COLOR_DARK_BG2.a, COLOR_LIGHT_BG2.a)
            COLOR_BG2.r = slideLerp(delta, COLOR_DARK_BG2.r, COLOR_LIGHT_BG2.r)
            COLOR_BG2.g = slideLerp(delta, COLOR_DARK_BG2.g, COLOR_LIGHT_BG2.g)
            COLOR_BG2.b = slideLerp(delta, COLOR_DARK_BG2.b, COLOR_LIGHT_BG2.b)
            COLOR_FG.a = slideLerp(delta, COLOR_DARK_FG.a, COLOR_LIGHT_FG.a)
            COLOR_FG.r = slideLerp(delta, COLOR_DARK_FG.r, COLOR_LIGHT_FG.r)
            COLOR_FG.g = slideLerp(delta, COLOR_DARK_FG.g, COLOR_LIGHT_FG.g)
            COLOR_FG.b = slideLerp(delta, COLOR_DARK_FG.b, COLOR_LIGHT_FG.b)
        else
            COLOR_BG.a = slideLerp(delta, COLOR_LIGHT_BG.a, COLOR_DARK_BG.a)
            COLOR_BG.r = slideLerp(delta, COLOR_LIGHT_BG.r, COLOR_DARK_BG.r)
            COLOR_BG.g = slideLerp(delta, COLOR_LIGHT_BG.g, COLOR_DARK_BG.g)
            COLOR_BG.b = slideLerp(delta, COLOR_LIGHT_BG.b, COLOR_DARK_BG.b)
            COLOR_BG2.a = slideLerp(delta, COLOR_LIGHT_BG2.a, COLOR_DARK_BG2.a)
            COLOR_BG2.r = slideLerp(delta, COLOR_LIGHT_BG2.r, COLOR_DARK_BG2.r)
            COLOR_BG2.g = slideLerp(delta, COLOR_LIGHT_BG2.g, COLOR_DARK_BG2.g)
            COLOR_BG2.b = slideLerp(delta, COLOR_LIGHT_BG2.b, COLOR_DARK_BG2.b)
            COLOR_FG.a = slideLerp(delta, COLOR_LIGHT_FG.a, COLOR_DARK_FG.a)
            COLOR_FG.r = slideLerp(delta, COLOR_LIGHT_FG.r, COLOR_DARK_FG.r)
            COLOR_FG.g = slideLerp(delta, COLOR_LIGHT_FG.g, COLOR_DARK_FG.g)
            COLOR_FG.b = slideLerp(delta, COLOR_LIGHT_FG.b, COLOR_DARK_FG.b)
        end
    end)

    anim:Start(seconds)
    mapListPanel.Think = function(self)
        if anim:Active() then
            anim:Run()
        end
    end
end

local function createColorModeButton()
    local colorButton = vgui.Create("DImageButton", mapListPanel)
    if RMV_CONVARS["rmv_lightmode"]:GetBool() then
        colorButton:SetImage("moon.png")
    else
        colorButton:SetImage("sun.png")
    end
    colorButton:SetPos(PANEL_WIDTH - 65, STARTING_Y - 9)
    colorButton:SetSize(28, 28)
    colorButton.m_bDepressImage = false
    colorButton.DoClick = function()
        RMV_CONVARS["rmv_lightmode"]:SetBool(not RMV_CONVARS["rmv_lightmode"]:GetBool())
        if RMV_CONVARS["rmv_lightmode"]:GetBool() then
            colorButton:SetImage("moon.png")
            RMVcloseButton:SetImage("cross_black.png")
        else
            colorButton:SetImage("sun.png")
            RMVcloseButton:SetImage("cross_white.png")
        end
        colorChangeAnimation(1)
    end
end

local function initializeColor()
    if RMV_CONVARS["rmv_lightmode"]:GetBool() then
        COLOR_BG = Color(255, 255, 255, 255)
        COLOR_BG2 = Color(50, 50, 50, 200)
        COLOR_FG = Color(0, 0, 0, 255)
    else
        COLOR_BG = Color(50, 50, 50, 200)
        COLOR_BG2 = Color(120, 120, 120, 200)
        COLOR_FG = Color(255, 255, 255, 255)
    end
end

local function initMapList()
    initializeColor()
    createMaplistPanel()
    createTitleLabel()
    createHeader()
    createCloseButton()
    createColorModeButton()
    createMapEntries(maps, history)
end

function rmvMapList()
    if RMV_MAPVOTE_INFO.RMV_MAPVOTE_STARTED then
        return
    end
    
    if maps == nil then
        net.Start(RMV_NETWORK_STRINGS["allMaps"])
        net.SendToServer()
    end

    if mapListPanel ~= nil then
        mapListPanel:Show()
    end
end

net.Receive(RMV_NETWORK_STRINGS["allMaps"], function()
    maps = net.ReadTable()
    history = net.ReadTable()
    initMapList()
end)

hook.Add("OnPlayerChat", "RMVOPENMAPLIST", function(ply, text, _, _)
    if text ~= "!rmvlist" and text ~= "!mappool" and text ~= "!rmvpool" then return end
    if LocalPlayer() ~= ply then return end
    rmvMapList()
end)
