local MAX_TABLE_ROW_LENGTH = 80


function Log(text)
    local timestamp = os.date("%H:%M:%S: " , os.time())
    print("[Raf's Map Vote] " .. timestamp .. text)
end

function LogDebug(text)
    local timestamp = os.date("%H:%M:%S: " , os.time())
    print("[DEBUG] " .. timestamp .. text)
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

function PrintDebugTable(title, table)
    print("")
    print(string.rep("-", 30) .. title .. string.rep("-", 30))
    PrintTable(table)
    print(string.rep("-", 60 + #title))
    print("")
end
