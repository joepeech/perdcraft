
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


local function seekBlock()
    for i = 1,MAXSLOTS do
        local details = turtle.getItemDetail(i)
        if details and details.name == "minecraft:cobblestone" then
            turtle.select(i)
            return true
        end
    end
    return false
end


local shellArgs = {...}
if #shellArgs ~= 1 then
    local myName = arg[0] or fs.getName(shell.getRunningProgram())
    print("usage: " .. myName .. " <length>")
    return
end

local length = tonumber(shellArgs[1])

for i = 1,length do
    if not seekBlock() then
        print("no blocks to put")
        return
    end

    local function f() 
        refuel()
        turtle.forward()
        if seekBlock() then 
            turtle.placeDown()
        end
    end
    local function r()
        turtle.turnRight()
    end
    local function l()
        turtle.turnLeft()
    end

    f()
    r()
    f()
    f()
    l()

    f()
    l()
    f()
    f()
    r()
end

