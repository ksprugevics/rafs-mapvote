function ulx.rmvstart(calling_ply, time, noVotesToRandom)
    StartRafsMapvote(time, noVotesToRandom)
end

local RMV_ULXCMD = ulx.command("Rafs MapVote", "ulx rmvstart", ulx.rmvstart, "!rmv")
RMV_ULXCMD:help("Starts Raf's mapvote with the given parameters")
RMV_ULXCMD:addParam{type=ULib.cmds.NumArg, min=5, default=40, max=120, hint="Vote time", ULib.cmds.optional, ULib.cmds.round}
RMV_ULXCMD:addParam{type=ULib.cmds.BoolArg, default=1, hint="Count 'No vote' as 'Random'?"}
RMV_ULXCMD:defaultAccess(ULib.ACCESS_ADMIN)
