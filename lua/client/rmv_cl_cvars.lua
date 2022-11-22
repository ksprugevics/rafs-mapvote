RMV_CONVARS = RMV_CONVARS or {
    ["rmv_lightmode"] = nil
}

local cvar = CreateClientConVar("rmv_lightmode", "0", true, false)
RMV_CONVARS["rmv_lightmode"] = cvar
