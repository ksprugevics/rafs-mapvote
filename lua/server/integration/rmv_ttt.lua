hook.Add("TTTEndRound", "CheckMapvote", function()
    if RTV_SUCCESS then
        StartRafsMapvote()
    end

    -- Overrides CheckForMapSwitch() so that after the last round, the map doesn't switch instantly
    function CheckForMapSwitch()
        -- Check for mapswitch
        local rounds_left = math.max(0, GetGlobalInt("ttt_rounds_left", 6) - 1)
        SetGlobalInt("ttt_rounds_left", rounds_left)

        local time_left = math.max(0, (GetConVar("ttt_time_limit_minutes"):GetInt() * 60) - CurTime())
        local switchmap = false

        if rounds_left <= 0 then
            switchmap = true
            Log("Round limit reached. Starting mapvote..")
        elseif time_left <= 0 then
            switchmap = true
            Log("Time limit reached. Starting mapvote..")
        end

        if switchmap then
            timer.Stop("end2prep")
            StartRafsMapvote()
        else
            LANG.Msg("limit_left", {num = rounds_left,
                            time = math.ceil(time_left / 60),
                            mapname = nextmap})
        end
    end
end)
