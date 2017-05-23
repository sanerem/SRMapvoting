-- This section is intended to create a table of maps that are on the server, using the sv_minmaxconfig.lua.

-- These are the initial values for this set of variables.

local nextmap = ""
local switchmap = false
local lastKnownPlayerCount = 0
local time_left = math.max(0, (GetConVar("ttt_time_limit_minutes"):GetInt() * 60) - CurTime())
local rounds_left = math.max(0, GetGlobalInt("ttt_rounds_left", 6) - 1)

SetGlobalInt("ttt_rounds_left", rounds_left)

------------------------------------------------------------------------------------

local function playerCountChanged(playerCount)
  return lastKnownPlayerCount != playerCount
end

local function playerCountOutOfRange(playerCount, nextmap)
  if (nextmap == "") then return true end

  return playerCount <= SRMapVoting.MapVotesTable.mapCache[nextmap]["minPlayers"] or
         playerCount >= SRMapVoting.MapVotesTable.mapCache[nextmap]["maxPlayers"]
end

local function checkForLastRound()
  if rounds_left <= 0 then
    LANG.Msg("limit_round", {mapname = nextmap})
    switchmap = true
  elseif time_left <= 0 then
    LANG.Msg("limit_time", {mapname = nextmap})
    switchmap = true
  end
end

local function retrySwitchMap()
  print("SRMapVoting: Map switch to " .. nextmap .. " failed! Trying a different map.")
  SRMapVoting.MapRotation:removeMap(nextmap)
  nextmap = SRMapVoting.MapRotation:determineNextMap()
  print("SRMapVoting: Now attempting to switch to " .. nextmap)
  RunConsoleCommand("changelevel", nextmap)
  timer.Simple(2, retrySwitchMap)
end

local function switchMap()
  if switchmap then
    timer.Stop("end2prep")
    timer.Simple(15, function()
      RunConsoleCommand("changelevel", nextmap)
    end)
    timer.Simple(18, retrySwitchMap)
  else
    LANG.Msg("limit_left", {num = rounds_left,
                            time = math.ceil(time_left / 60),
                            mapname = nextmap})
  end
end

local function forceSwitchMap(ply)
  if !IsValid(ply) then
    nextmap = SRMapVoting.MapRotation:determineNextMap()
    print("Forcing map switch to " .. nextmap .. ". This will take the same amount of time as a normal map switch.")
    switchmap = true
    switchMap()
  else
    print("This command can only be used by the server console.")
  end
end

function SRMapVoting.recalculateIfNeeded()
  local playerCount = #player.GetAll()
  if playerCountChanged(playerCount) then
    lastKnownPlayerCount = playerCount
    nextmap = SRMapVoting.MapRotation:determineNextMap()
  end
end

hook.Add("Initialize", "SRMapVoting_Initialize", function()
  SRMapVoting.MapVotesTable:populateCache()
  nextmap = SRMapVoting.MapRotation:determineNextMap()

  --Override normal TTT behavior.
  function CheckForMapSwitch()
    rounds_left = math.max(0, GetGlobalInt("ttt_rounds_left", 6) - 1)
    SetGlobalInt("ttt_rounds_left", rounds_left)
    time_left = math.max(0, (GetConVar("ttt_time_limit_minutes"):GetInt() * 60) - CurTime())

    SRMapVoting.recalculateIfNeeded()
    checkForLastRound()
    switchMap()
  end
end)

concommand.Add("SRMapVoting_forceSwitchMap", forceSwitchMap)
