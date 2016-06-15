-- This section is intended to create a table of maps that are on the server, using the sv_minmaxconfig.lua.

-- These are the initial values for this set of variables.

local map = game.GetMap()
local mapMinMaxTable = UpOrDownVoting.mapMinMaxTable
local nextmap = ""
local switchmap = false

local playercount = #player.GetAll()
local currentplayercount = #player.GetAll()


local time_left = math.max(0, (GetConVar("ttt_time_limit_minutes"):GetInt() * 60) - CurTime())
local rounds_left = math.max(0, GetGlobalInt("ttt_rounds_left", 6) - 1)

SetGlobalInt("ttt_rounds_left", rounds_left)

------------------------------------------------------------------------------------

hook.Add("TTTPrepareRound", function()
  mapChangeCheckAndSet()
end)

local function mapChangeCheckAndSet() -- A central function that should probably be based on returned true, false, or nil values in the following functions.
  currentplayercount = playercount
  checkForMinMaxTable()
end

local function checkForMinMaxTable()
  if mapMinMaxTable == nil then
    print ("ERROR, server admin should ensure that the addon is installed correctly. sv_minmaxconfig.lua cannot be found in addons/SRMapVoting/lua/config/.") 
  else
    createViableMapsTable()
  end
end
  -- SAY NAME OF NEXT MAP IN CHAT AND AT TOP RIGHT IF IT'S NOT ALREADY DONE GLOBALLY, CHECK THE FILES. -- Checked, does not appear so, not confirmed.
local function createViableMapsTable()
  maplist[columns["mapname"]] = {
    total = 0
    }
  for mapname, minmax in pairs(mapMinMaxTable) do -- Add to own function?
    if minmax["minplayers"] >= playercount and minmax["maxplayers"] <= playercount then
      table.insert(maplist, #list+1, mapname)
    else
      changeNextMapDueToPlayerCount()
    end
  end
  setRandomNextMapFromList()
end

local function changeNextMapDueToPlayerCount()
  if playercount ~= currentplayercount and 
  (mapMinMaxTable[nextmap]["minplayers"] <= playercount or mapMinMaxTable[nextmap]["maxplayers"] >= playercount) then
    createViableMapsTable()
  end
-- ANNOUNCE CHANGE IN CHAT/TOP RIGHT -- Automatic?
end

function excludeMaps(probabilitytable, mapvotesref)
  for mapname, v in pairs(mapvotesref) do
    local netvotes = v.upvotes - v.downvotes -- Gets the net vote count to apply to its probability
    if netvotes <= -50 then
      probabilitytable[mapname] = nil
    else
      probabilitytable[mapname] = netvotes
    end
  end
end

function setRandomNextMapFromList() -- Sets the next map based on a modified probability
  local nextmap = ""
  if mapMinMaxTable ~= nil then
    local probabilitytable = {}
    local selectiontable = {}
    for mapname, v in pairs(maplist) do
      probabilitytable[mapname] = 0
    end
    excludeMaps(probabilitytable, mapvotesref)
    local previousmax = 0
    for mapname, modifier in pairs(probabilitytable) do
      local min = previousmax
      local max = min+100+modifier
      previousmax = max+1
      selectiontable[mapname]["min"] = min
      selectiontable[mapname]["max"] = max
    end
    local nextmapnumber = math.random() %previousmax -- Sets probability
    for mapname, range in pairs(selectiontable) do
      if nextmapnumber >= range.min and nextmapnumber <= range.max then
        nextmap = mapname
        break
      end
    end
    if nextmap == map then
      return setRandomNextMapFromList() else
      return nextmap
    end
  end
end

-- FIND OUT IF THIS WILL OVERRIDE ANY OTHER GLOBAL FUNCTIONS THAT THESE WERE MODELED AFTER.
local function checkForLastRound() -- FIND OUT IF CHECKFORLASTROUND AND SWITCHMAP ARE GLOBAL OR LOCAL FUNCTIONS -- ShouldMapSwitch() is local and set to always true. CheckForMapSwitch is global.
  if rounds_left <= 0 then
    LANG.Msg("limit_round", {mapname = nextmap})
    switchmap = true
  elseif time_left <= 0 then
    LANG.Msg("limit_time", {mapname = nextmap})
    switchmap = true
  end
end

local function switchMap()
  if switchmap then
    timer.Stop("end2prep")
    timer.Simple(15, RunConsoleCommand ("changelevel", nextmap))
  else
  LANG.Msg("limit_left", {num = rounds_left,
                          time = math.ceil(time_left / 60),
                          mapname = nextmap})
  end
end

--[[Get the viable maps from the array each round 
Change the next map set on the server based on playercount, ranking, and overall probability -> SQL Queries
Reshuffle and announce a new map if the playercount has changed out of minmax -> Chat/TopRightCorner Announcements
Display the next map before each round even if not changed -> Chat/TopRightCorner Announcements
Change the map at the end of the last round
]]--