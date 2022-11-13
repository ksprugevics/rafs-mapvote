RMV_CONFIG = {}


function RMV_INIT()
    SetTableRowSize(80)
    PrintLogo()
    PrintTableHeader()
    RMV_CONFIG = setupDataDir()
    PrintTableRow("Config loaded.")

    PrintTableRow("Generating map list..")
    local mapList = generateLocalMapList(RMV_CONFIG["MAPS"], RMV_CONFIG["MAP_PREFIX"])
    PrintTableRow("Found " .. #mapList .. " maps in total.")
    if #mapList < 6 then
        PrintTableRow("WARNING: Very small map pool! Things might break..")
    end

    PrintTableRow("Loading map statistics..")
    local mapStats = generateMapStats(RMV_CONFIG["DATA_DIR"] .. "map_stats.json", mapList)
    
    PrintTableRow("Loading map history..")
    local mapHistory = generateMapHistory(RMV_CONFIG["DATA_DIR"] .. "map_history.json", RMV_CONFIG["MAP_COOLDOWN"])

    PrintTableRow("Generating mapvote candidtes..")
    candidates = generateVoteCandidates(mapList, mapHistory, mapStats)

    if RMV_CONFIG["DEBUG_MODE"] then
        PrintTableRow("DEBUG MODE ACTIVE! YOU WILL SEE EXTRA INFORMATION IN THE CONSOLE.")
    end

    PrintTableRow("Fully loaded!")
    PrintTableFooter()
    if RMV_CONFIG["DEBUG_MODE"] then
        PrintDebugTable("CONFIG", RMV_CONFIG)
        PrintDebugTable("MAP LIST", mapList)
        PrintDebugTable("MAP STATS", mapStats)
        PrintDebugTable("MAP HISTORY", mapHistory)
        PrintDebugTable("CANDIDATES", candidates)
    end
    return candidates
end
