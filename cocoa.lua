--    *    
--   *#*<   
--    * ^   
--    ^>>     
MAXSLOTS = 16

if not turtle then
    printError("no turtle")
    return
end

local function refuel() -- from tunnel.lua
    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel == "unlimited" or fuelLevel > 0 then
        return
    end

    local function tryRefuel()
        for n = 1, 16 do
            if turtle.getItemCount(n) > 0 then
                turtle.select(n)
                if turtle.refuel(1) then
                    turtle.select(1)
                    return true
                end
            end
        end
        turtle.select(1)
        return false
    end

    if not tryRefuel() then
        print("Add more fuel to continue.")
        while not tryRefuel() do
            os.pullEvent("turtle_inventory")
        end
        print("Resuming Tunnel.")
    end
end

local function seekBy(key)
    for i = 1,MAXSLOTS do
        local details = turtle.getItemDetail(i)
        if details and key(details.name) then
            turtle.select(i)
            return true
        end
    end
    return false
end

local function seekFor(s) 
    return seekBy(function (nm) return nm == s end)
end




local shellArgs = {...}
if #shellArgs == 0 or #shellArgs > 2 then
    local myName = arg[0] or fs.getName(shell.getRunningProgram())
    print("usage: " .. myName .. " <height>")
    return
end

local height = tonumber(shellArgs[1])


local function go()
    refuel()
    turtle.forward()
end

local function updateCocoaFetus()
    local notVoid, info = turtle.inspect()
    if notVoid and info.state.age == 2 then
        turtle.dig()
    end
    if not turtle.detect() and seekFor("minecraft:cocoa_beans") then
        turtle.place()
    end
end

local function goToNextSide()
    turtle.turnRight()
    go() go()
    turtle.turnLeft()
    go() go()
    turtle.turnLeft()
end

local level, buf = turtle.up, turtle.down
while true do
    for i = 1,height - 1 do
        updateCocoaFetus()
        refuel()
        level()
    end
    updateCocoaFetus()
    goToNextSide()
    level, buf = buf, level
end


