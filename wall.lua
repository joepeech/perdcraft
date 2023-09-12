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


--- dummy for now
---      X     X
---   -> # -> #  -> #
--- X    #    #     #X

local shellArgs = {...}
if #shellArgs == 0 or #shellArgs > 2 then
    local myName = arg[0] or fs.getName(shell.getRunningProgram())
    print("usage: " .. myName .. " <length> [height]")
    return
end

local length = tonumber(shellArgs[1])
local height = tonumber(shellArgs[2]) or 2

local function moveDownUntil()
    refuel()
    -- while not turtle.detectDown() do
    --     turtle.down()
    -- end
    while turtle.down() do
    end
end

local function buildColumn(h) 
    local res = 0
    refuel()
    for i = 1,h do
        turtle.up()
        if turtle.placeDown() then
            res = res + 1
        end
    end
    return res
end


local function seekBlock()
    for i = 1,MAXSLOTS do
        local details = turtle.getItemDetail(i)
        if details and details.name == "minecraft:stone_bricks" then
            -- cobblestone
            turtle.select(i)
            return true
        end
    end
    return false
end


for i = 1,length do
    moveDownUntil()
    print("Grounded")
    if not seekBlock() then
        print("no blocks to put")
        return
    end
    local built = buildColumn(height)
    print(built .. " blocks set")
    turtle.forward()
end