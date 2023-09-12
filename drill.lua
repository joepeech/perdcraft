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
if #shellArgs ~= 1 then
    local myName = arg[0] or fs.getName(shell.getRunningProgram())
    print("usage: " .. myName .. " <depth>")
    return
end

local depth = tonumber(shellArgs[1])


local function r()
    turtle.turnRight()
end
local function l()
    turtle.turnLeft()
end

for i = 1,depth do
    local function f() 
        refuel()
        turtle.digDown()
        turtle.forward()
    end

    f()
    f()
    r()
    f()
    r()
    f()
    f()
    l()
    f()
    l()
    f()
    f()
    l()

    turtle.digDown()
    refuel()
    turtle.down() 
    l, r = r, l
end
