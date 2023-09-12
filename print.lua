local shellArgs = {...}
if #shellArgs == 0 then
    local myName = arg[0] or fs.getName(shell.getRunningProgram())
    print("Usage: " .. myName .. " [fileName] [Printer interface side (not necessary, if only one printer)]")
    return
end

local fileName = arg[1]
local side = arg[2] or ""
local printer = peripheral.wrap(side) or peripheral.find("printer")

local function newline()
    local col, raw = printer.getCursorPos()
    printer.setCursorPos(1, raw + 1)
end

local function readFileArray(fn) 
    local f = fs.open(fn, "r")
    if f == nil then
        printError("Unknown error or file '" .. fn .. "' does not exist")
        return nil
    end

    local allLines = {}
    while true do
        local line = f.readLine()
        if line == nil then
            f.close()
            return allLines
        end
        table.insert(allLines, line)
    end
end

local lines = readFileArray(fileName)
if not lines then return end

local curLine = 1
local curPage = 1
local completed = false

while not completed do
    while not printer.newPage() or printer.getPaperLevel() == 0 do
        printError("Insert a paper into the printer! When done press a key.")
        os.pullEvent("key")
    end

    printer.setPageTitle(fileName .. " P. " .. curPage)

    local width, height = printer.getPageSize()
    
    for i = 1, height do
        local s = lines[curLine]
        if s:len() <= width then
            printer.write(s)
        else
            local ok = s:sub(1, width)
            local rest = s:sub(width + 1)
            table.insert(lines, curLine + 1, rest)
            printer.write(ok)
        end

        curLine = curLine + 1

        if curLine > #lines then
            completed = true
            break
        end

        newline()
    end

    printer.endPage()
    curPage = curPage + 1
end

