-- view from above:
--    
--##|   |##
--##| ^ |##
--##|   |##
--##|*  |##
--##|   |##
--##|*  |##

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

local shellArgs = {...}
if #shellArgs ~= 2 then
    local myName = arg[0] or fs.getName(shell.getRunningProgram())
    print("usage: " .. myName .. " <period> <length>")
    return
end

local period = tonumber(shellArgs[1])
local length = tonumber(shellArgs[2])

local function seekTorch()
    for i = 1,MAXSLOTS do
        local details = turtle.getItemDetail(i)
        if details and details.name == "minecraft:torch" then
            -- cobblestone
            turtle.select(i)
            return true
        end
    end
    return false
end


for i = 1,length do
    refuel()
    if not seekTorch() then
        print("no torches to put")
        return
    end
    if i % period == 1 then
        turtle.turnLeft()
        turtle.place()
        turtle.turnRight()
    end
    turtle.forward()
end

