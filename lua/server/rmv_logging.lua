local MAX_TABLE_ROW_LENGTH = 80

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

function SetTableRowSize(tableRowMaxLength)
    MAX_TABLE_ROW_LENGTH = tableRowMaxLength
end

function PrintTableHeader()
    local row1 = " " .. string.rep("_", MAX_TABLE_ROW_LENGTH + 4) .. " "
    local row2 = "|  " .. string.rep("_", MAX_TABLE_ROW_LENGTH) .. "  |"
    local row3 = "| |" .. string.rep(" ", MAX_TABLE_ROW_LENGTH) .. "| |"
    print(row1)
    print(row2)
    print(row3)
end

function PrintTableFooter()
    local row1 = "| |" .. string.rep("_", MAX_TABLE_ROW_LENGTH) .. "| |"    
    local row2 = "|" .. string.rep("_", MAX_TABLE_ROW_LENGTH + 4) .. "|"
    print(row1)
    print(row2)
end

function PrintTableRow(text)
    local startingColumn = (MAX_TABLE_ROW_LENGTH - string.len(text)) / 2
    local row = "| |"
    row = row .. string.rep(" ", startingColumn)
    row = row .. text
    row = row .. string.rep(" ", startingColumn - 1)
    row = row .. " | |"
    print(row)
end

function PrintCustomTable(rows)
    PrintTableHeader(MAX_TABLE_ROW_LENGTH)
    for _, row in pairs(rows) do
        PrintTableRow(row, MAX_TABLE_ROW_LENGTH)
    end
    PrintTableFooter(MAX_TABLE_ROW_LENGTH)
end