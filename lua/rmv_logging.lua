function Log(text)
    local timestamp = os.date("%H:%M:%S: " , os.time())
    print("[Raf's Map Vote] " .. timestamp .. text)
end

function PrintLogo()
    -- https://manytools.org/hacker-tools/ascii-banner/ (small, squeezed)
    print(" ___       __      __  __                   _       ")
    print("| _ \\__ _ / _|___ |  \\/  |__ _ _ ____ _____| |_ ___ ")
    print("|   / _` |  _(_-< | |\\/| / _` | '_ \\ V / _ |  _/ -_)")
    print("|_|_\\__,_|_| /__/ |_|  |_\\__,_| .__/\\_/\\___/\\__\\___|")
    print("                              |_|                   ")
end

function PrintTableHeader(tableRowMaxLength)
    local row1 = " " .. string.rep("_", tableRowMaxLength + 4) .. " "
    local row2 = "|  " .. string.rep("_", tableRowMaxLength) .. "  |"
    local row3 = "| |" .. string.rep(" ", tableRowMaxLength) .. "| |"
    print(row1)
    print(row2)
    print(row3)
end

function PrintTableFooter(tableRowMaxLength)
    local row1 = "| |" .. string.rep("_", tableRowMaxLength) .. "| |"    
    local row2 = "|" .. string.rep("_", tableRowMaxLength + 4) .. "|"
    print(row1)
    print(row2)
end

function PrintTableRow(text, tableRowMaxLength)
    local startingColumn = (tableRowMaxLength - string.len(text)) / 2
    local row = "| |"
    row = row .. string.rep(" ", startingColumn)
    row = row .. text
    row = row .. string.rep(" ", startingColumn - 1)
    row = row .. " | |"
    print(row)
end

function PrintTable(rows, tableRowMaxLength)
    PrintTableHeader(tableRowMaxLength)
    for _, row in pairs(rows) do
        PrintTableRow(row, tableRowMaxLength)
    end
    PrintTableFooter(tableRowMaxLength)
end