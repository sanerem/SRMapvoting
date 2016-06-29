-- To insert new maps, use the template below, deleting each -- at the start of each line. ttt_dolls is used as a functional example.

--mapMinMaxTable[columns["maps"]] = {
-- gm_construct = {
-- minplayers = #
-- maxplayers = #
-- }
-- gm_flatgrass = {
-- minplayers = #
-- maxplayers = #
-- }
-- }

--[[function createmapListTable(maps) -- This is intended to populate the table automatically. Not currently working.
for filename in io.popen([dir "C:\Program Files\" /b /ad]):lines() do 
i = i + 1
t[i] = filename 
end

function createmapMinMaxTable(mapcycle.txt)
end

local file = "sv_minmaxconfig.lua"

local maps = linesfrom(sv_minmaxconfig.lua)

function checkForMapMinMaxTable(sv_minmaxconfig.lua)
  local check = io.open(sv_minmaxconfig.lua, "rb")
  if not sv_minmaxconfig.lua then return false end
    if check then check.close() return true end
    elseif check ~= nil return false
  else return false
end

function createMapListTable()
  
  maps = {}
 
  for line in io.lines("sv_minmaxconfig.lua") do
    if line = "ttt_*" or "cs_*" or "dm_*" or "gm_*"
      maps[#maps+1] = line
    end
  end
  return maps
  
  for line do
    print(line)
 end
end
]]--

UpOrDownVoting.mapMinMaxTable = mapMinMaxTable

mapMinMaxTable = {
ttt_dolls = {
minplayers = 0,
maxplayers = 32
}
}