local function sendClientScripts()
    AddCSLuaFile("autorun/rmv_load.lua")
    AddCSLuaFile("shared/rmv_network_strings.lua")
    AddCSLuaFile("client/gui/rmv_mapvote_panel_gui.lua")
    AddCSLuaFile("client/gui/rmv_fonts.lua")
    AddCSLuaFile("client/gui/rmv_avatar_bounce.lua")
    AddCSLuaFile("client/rmv_cl_rafsmapvote.lua")
end

local function loadServerScripts()
    include("shared/rmv_network_strings.lua")
    include("server/utils/rmv_logging.lua")
    include("server/config/rmv_config.lua")
    include("server/config/rmv_map_info.lua")
    include("server/voting/rmv_tally.lua")
    include("server/voting/rmv_candidates.lua")
    include("server/voting/rmv_rtv.lua")
    include("server/rmv_sv_rafsmapvote.lua")
end

local function loadClientScripts()
    include("shared/rmv_network_strings.lua")
    include("client/gui/rmv_fonts.lua")
    include("client/gui/rmv_mapvote_panel_gui.lua")
    include("client/gui/rmv_avatar_bounce.lua")
    include("client/rmv_cl_rafsmapvote.lua")
end


if SERVER then
    sendClientScripts()
    loadServerScripts()
end

if CLIENT then
    loadClientScripts()
end
