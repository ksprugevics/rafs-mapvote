if SERVER then

    AddCSLuaFile('autorun/rmv_load.lua')

    AddCSLuaFile('client/gui/rmv_gui.lua')
    AddCSLuaFile('client/gui/rmv_fonts.lua')
    AddCSLuaFile('client/gui/rmv_avatar_bounce.lua')
    AddCSLuaFile('client/rmv_cl_rafsmapvote.lua')
end

if SERVER then

    include('server/rmv_network_strings.lua')
    include('server/rmv_logging.lua')
    include('server/rmv_file_gen.lua')
    include('server/rmv_sv_utils.lua')
    include('server/rmv_sv_rafsmapvote.lua')
end

if CLIENT then

    include('client/gui/rmv_fonts.lua')
    include('client/gui/rmv_gui.lua')
    include('client/gui/rmv_avatar_bounce.lua')
    include('client/rmv_cl_rafsmapvote.lua')
end