local modem = peripheral.find("modem")
local listAll = modem.getNamesRemote()
local speakers = {}
for i = 1, #listAll do 
   if modem.getTypeRemote(listAll[i]) == "speaker" then
      table.insert(speakers, listAll[i])
   end
end

local function stopAll()
   for _, s in pairs(speakers) do
      modem.callRemote(s, "stop")
   end
end

local function playAll(chunk)
   local r = true
   for _, s in pairs(speakers) do
      r = r and modem.callRemote(s, "playAudio", chunk)
   end
   return r
end

local function getUrl(url)
   local ok, err = http.checkURL(url)
   if not ok then
      printError(err or "Invalid URL.")
      return
   end
   local response = http.get(url, nil, true)
   if not response then
      print("Failed.")
      return nil
   end

   local s = response.readAll()
   response.close()
   return s or ""
end


local shellArgs = {...}
if #shellArgs == 0 then
   local myName = arg[0] or fs.getName(shell.getRunningProgram())
   print("usage: " .. myName .. " play <file>")
   print("       " .. myName .. " stream <url>")
   print("       " .. myName .. " stop")
end

local cmd = shellArgs[1]
if cmd == "stop" then
   stopAll()
elseif cmd == "play" then
   local fName = shellArgs[2]
   local dfpwm = require "cc.audio.dfpwm"
   local decoder = dfpwm.make_decoder()
   local handle, err = fs.open(fName, "rb")
   local size = 16 * 1024

   while true do
      local chunk = handle.read(size)
      if not chunk then break end
      local buffer = decoder(chunk)
      while not playAll(buffer) do
         os.pullEvent("speaker_audio_empty")
      end
   end
elseif cmd == "stream" then
   local dfpwm = require "cc.audio.dfpwm"
   local decoder = dfpwm.make_decoder()
   local allBytes = getUrl(shellArgs[2])
   local block = 16 * 1024
   for i = 1, math.ceil(#allBytes / block) do
      local chunk = allBytes:sub(1 + (i - 1) * block, i * block)
      local buffer = decoder(chunk)
      while not playAll(buffer) do
         os.pullEvent("speaker_audio_empty")
      end
   end
else
   printError("Invalid option")
end

--[[
local speaker = peripheral.find("speaker") 
local decoder = require("cc.audio.dfpwm").make_decoder() 
for chunk in io.lines("rap", 16 * 1024) do 
    local decoded = decoder(chunk) 
    while not speaker.playAudio(decoded) do 
        os.pullEvent("speaker_audio_empty") 
    end 
end
]]--

-- chat paint  player