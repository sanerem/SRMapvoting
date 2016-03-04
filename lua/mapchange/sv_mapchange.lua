-- This section is intended to create a table of maps that are on the server, using the sv_minmaxconfig.lua.

-- These are the initial values for this set of variables.

local map=game.GetMap()

local mapMinMaxTable = UpOrDownVoting.mapMinMaxTable
  
local playercount = #player.GetAll()

local currentplayercount = #player.GetAll()

local nextmap = ""

local time_left = math.max(0, (GetConVar("ttt_time_limit_minutes"):GetInt() * 60) - CurTime())

local switchmap = false

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
  local maplist[columns["mapname"] = {
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
-- ANNOUNCE CHANGE IN CHAT/TOP RIGHT
end

local function setRandomNextMapFromList() -- CURRENTLY BEING WORKED ON
  if mapMinMaxTable ~= nil then
    for mapname in mapvotes do
      -- CHANGE CHANGES BASED ON VOTES
    end
    if maptable[mapname["total"]] <= -50 then -- NEEDS TO BE FIXED
      table.remove(maplist, mapname) -- Disable map if it has a total of -50 or lower
    end
    nextmap = maplist[ (math.random() % #maplist)+1 ]
    for mapname, v in recentmaplist do -- MAKE THIS ABLE TO BE DISABLED THROUGH A CONVAR
      if nextmap == recentmaplist["mapname"] or nextmap == map then -- Do not switch to the currently played map, or the last 10 maps. CHANGE TO BE REDUCED CHANCE INSTEAD
        setRandomNextMapFromList() -- THIS MAY BE ABLE TO LOOP INFINITELY IF THERE ARE NOT SUFFICIENT MAPS
      end
    end
    -- ANNOUNCE CHANGE IN CHAT/TOP RIGHT
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
    local recentmaplist["mapname"] = {}
    table.insert(recentmaplist, 1, nextmap) -- Creates a table of the most recently played 9 maps, not including the one currently being played/switched from
    table.remove(recentmaplist, 9) -- CHANGE THIS TO BE A MAX OF 9, OR A MIN OF THE NUMBER OF MAPS IN THE TABLE - 1
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