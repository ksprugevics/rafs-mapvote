local function chatTimers()
    timer.Create("RMVCHATMAPRTV", 300, 0, function()
        LocalPlayer():ChatPrint("[RMV] You can rock the vote by typing !rtv")
    end)
    timer.Create("RMVCHATMAPPOOL", 500, 3, function()
        LocalPlayer():ChatPrint("[RMV] You can view the server's map pool by typing !rmvlist")
    end)
end

hook.Add("Initialize", "RMVCHATTIMERS", chatTimers)