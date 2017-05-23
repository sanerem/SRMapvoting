local MapRotation = {}
MapRotation.maps = {}
MapRotation.__index = MapRotation
MapRotation.mapVotesTable = SRMapVoting.MapVotesTable

local function mapInRange(playerCount, mapSettings)
  return mapSettings["minPlayers"] <= playerCount and mapSettings["maxPlayers"] >= playerCount
end

local function probabilityMatch(diceRoll, range)
  return range.min <= diceRoll and range.max >= diceRoll
end

local function mapNotExcluded(mapName, mapVotes)
  if !mapvotes[mapName] then return false end
  local netVotes = mapVotes.upvotes - mapVotes.downvotes -- Gets the net vote count to apply to its probability
  return netvotes <= SRMapVoting.Config.voteCutoff
end

local function excludeMapsByVote(viableMaps, mapVotes)
  local newViableMaps = {}
  local v = mapVotes[mapName]
  for mapName, mapSettings in pairs(viableMaps) do
    if v then
      local netvotes = v.upvotes - v.downvotes -- Gets the net vote count to apply to its probability
      if netvotes > SRMapVoting.Config.voteCutoff then
        newViableMaps[mapName] = mapSettings
      end
    else
      newViableMaps[mapName] = mapSettings
    end
  end

  return newViableMaps
end

--[[
Creates a table of ranges that determines how probable it is for a map to be chosen.
If a randomly generated integer falls within the range of a map's min and max range,
that map is selected.
Returns the table and the maximum range value a map could possibly have.
]]
local function makeProbabilityTable(filteredViableMaps, mapVotes)
  local probabilityTable = {}
  local previousMax = 0

  for mapName, v in pairs(filteredViableMaps) do
    local modifier = 0

    if mapVotes[mapName] != nil then
      modifier = mapVotes[mapName]["upvotes"] - mapVotes[mapName]["downvotes"]
    end

    local min = previousMax
    local max = min + 20 + modifier

    if (max <= 0) then
      max = min + 1
    end

    previousMax = max + 1
    probabilityTable[mapName] = {}
    probabilityTable[mapName]["min"] = min
    probabilityTable[mapName]["max"] = max
  end

  return probabilityTable, previousMax
end

function MapRotation:addMap(mapName, minPlayers, maxPlayers)
  minPlayers = minPlayers or 0
  maxPlayers = maxPlayers or 0

  assert(maxPlayers >= minPlayers, "MapRotation:addMap - minPlayers may not exceed maxPlayers.")

  self.maps[mapName] = {
    minPlayers = minPlayers,
    maxPlayers = maxPlayers
  }
end

function MapRotation:removeMap(mapName)
  self.maps[mapName] = nil
end

function MapRotation:length()
  local count = 0

  for k, v in pairs(self.maps) do
    count = count + 1
  end

  return count
end

function MapRotation:determineNextMap()
  assert(self:length() > 0, "MapRotation:determineNextMap - There are no maps configured!")
  local players = player.GetAll()
  local viableMaps = self:createViableMapsTable(#players)
  local mapVotes = self.mapVotesTable:getWeightedMapVotes(players)
  local filteredViableMaps = excludeMapsByVote(viableMaps, mapVotes)
  local probabilityTable, maximumValue = makeProbabilityTable(filteredViableMaps, mapVotes)
  local nextMap = self:chooseRandomMap(probabilityTable, maximumValue, #players)

  return nextMap
end

function MapRotation:createViableMapsTable(playerCount)
  local viableMaps = {}
  for mapName, mapSettings in pairs(self.maps) do -- Add to own function?
    if mapInRange(playerCount, mapSettings) then
      viableMaps[mapName] = 0
    end
  end

  return viableMaps
end

function MapRotation:chooseRandomMap(probabilityTable, maximumValue, playerCount) -- Sets the next map based on a modified probability
  local nextMap = ""
  local currentMap = game.GetMap()
  local probabilityTableLength = 0

  for k, v in pairs(probabilityTable) do
    probabilityTableLength = probabilityTableLength + 1
  end

  if (probabilityTableLength == 1 and probabilityTable[currentMap] != nil) then
    return currentMap
  end

  if self:length() != 0 then
    local int32max = 21474836
    local diceRoll = math.random(0, int32max) % maximumValue -- Sets probability

    for mapName, range in pairs(probabilityTable) do
      --print("Diceroll is " .. diceRoll .. ". Checking for match in " .. mapName .. " with min " .. range.min .. " and max " .. range.max)
      if probabilityMatch(diceRoll, range) then
        nextMap = mapName
        break
      end
    end

    if nextMap == game.GetMap() and probabilityTableLength > 1 then
      return self:chooseRandomMap(probabilityTable, maximumValue, playerCount)
    else
      return nextMap
    end

  end
end

SRMapVoting.MapRotation = MapRotation
