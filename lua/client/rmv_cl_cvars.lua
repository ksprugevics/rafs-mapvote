RMV_CONVARS = RMV_CONVARS or {
    ["rmv_lightmode"] = nil
}

local cvar = CreateClientConVar("rmv_lightmode", "0", true, false)
RMV_CONVARS["rmv_lightmode"] = cvar

concommand.Add("rmv_start", function(ply)
    rmvSendStringToServer(RMV_NETWORK_STRINGS["requestMapVote"], "")
end)
