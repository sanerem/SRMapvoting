local mapVotesTableTest = GUnit.Test:new("MapVotesTable")
local mapVotesTableCopy

local function beforeEach()
  mapVotesTableCopy = table.Copy(SRMapVoting.MapVotesTable)
  mapVotesTableCopy.tableName = "test_" .. os.time() .. "_" .. mapVotesTableCopy.tableName
  mapVotesTableCopy.playerCache = {}
  mapVotesTableCopy.mapCache = {}

  mapVotesTableCopy:create()
end

local function afterEach()
  sql.Query("DROP TABLE IF EXISTS " .. mapVotesTableCopy.tableName)
end

local function insertSpec()
  for i = 1, 100 do
    local mapName = GUnit.Generators.StringGen.generateAlphaNum()
    local steamId = GUnit.Generators.StringGen.generateAlphaNum()
    local voteType = math.random(0, 2)
    mapVotesTableCopy:insertVoteIntoSqlTable(mapName, voteType, steamId)

    local row = sql.Query("SELECT * FROM " .. mapVotesTableCopy.tableName .. " WHERE id == " .. i)
    GUnit.assert(row[1]["mapname"]):shouldEqual(mapName)
    GUnit.assert(row[1]["steamid"]):shouldEqual(steamId)
    GUnit.assert(row[1]["votetype"]):shouldEqual(tostring(voteType))
  end
end

local function updateSpec()
  for i = 1, 100 do
    local mapName = GUnit.Generators.StringGen.generateAlphaNum()
    local steamId = GUnit.Generators.StringGen.generateAlphaNum()
    local voteType1 = math.random(0, 2)
    local voteType2 = math.random(0, 2)
    mapVotesTableCopy:insertVoteIntoSqlTable(mapName, voteType1, steamId)
    mapVotesTableCopy:updateVoteInSqlTable(mapName, voteType2, steamId)

    local row = sql.Query("SELECT * FROM " .. mapVotesTableCopy.tableName .. " WHERE id == " .. i)
    GUnit.assert(row[1]["mapname"]):shouldEqual(mapName)
    GUnit.assert(row[1]["steamid"]):shouldEqual(steamId)
    GUnit.assert(row[1]["votetype"]):shouldEqual(tostring(voteType2))
  end
end

local function mapCacheSpec()
  local mapName = GUnit.Generators.StringGen.generateAlphaNum()
  local downvotes = 0
  local upvotes = 0

  for i = 1, 100 do
    local steamId = GUnit.Generators.StringGen.generateAlphaNum()
    local voteType = math.random(0, 2)

    if voteType == 0 then
      downvotes = downvotes + 1
    elseif voteType == 1 then
      upvotes = upvotes + 1
    end

    mapVotesTableCopy:insertVoteIntoSqlTable(mapName, voteType, steamId)
  end

  mapVotesTableCopy:populateCache()
  GUnit.assert(mapVotesTableCopy.mapCache[mapName]["upvotes"]):shouldEqual(upvotes)
  GUnit.assert(mapVotesTableCopy.mapCache[mapName]["downvotes"]):shouldEqual(downvotes)
end

local function playerCacheSpec()
  local mapName = GUnit.Generators.StringGen.generateAlphaNum()
  local playerVotes = {}

  for i = 1, 100 do
    local steamId = GUnit.Generators.StringGen.generateAlphaNum()
    local voteType = math.random(0, 2)
    playerVotes[steamId] = {}
    playerVotes[steamId][mapName] = voteType
    mapVotesTableCopy:insertVoteIntoSqlTable(mapName, voteType, steamId)
  end

  mapVotesTableCopy:populateCache()

  for steamId, mapEntries in pairs(playerVotes) do
    local cachedVoteType = mapVotesTableCopy.playerCache[steamId][mapName]
    local savedVoteType = mapEntries[mapName]
    GUnit.assert(cachedVoteType):shouldEqual(savedVoteType)
  end
end

local function cacheSummationSpec()
  local mapName = GUnit.Generators.StringGen.generateAlphaNum()
  local playerVotes = {}
  local downvotes = 0
  local upvotes = 0

  for i = 1, 100 do
    local steamId = GUnit.Generators.StringGen.generateAlphaNum()
    local voteType = math.random(0, 2)
    playerVotes[steamId] = {}
    playerVotes[steamId][mapName] = voteType
    mapVotesTableCopy:insertVoteIntoSqlTable(mapName, voteType, steamId)
  end

  mapVotesTableCopy:populateCache()

  for playerId, maps in pairs(mapVotesTableCopy.playerCache) do
    local voteType = maps[mapName]

    if voteType == 0 then
      downvotes = downvotes + 1
    elseif voteType == 1 then
      upvotes = upvotes + 1
    end

  end

  GUnit.assert(mapVotesTableCopy.mapCache[mapName]["downvotes"]):shouldEqual(downvotes)
  GUnit.assert(mapVotesTableCopy.mapCache[mapName]["upvotes"]):shouldEqual(upvotes)
end

local function mapWeightingSpec()
  local mapName = GUnit.Generators.StringGen.generateAlphaNum()
  local playerVotes = {}
  local onlinePlayers = {}
  local downvotes = 0
  local upvotes = 0

  for i = 1, 100 do
    local fakePlayer = GUnit.Generators.FakePlayer:new()
    local steamId = fakePlayer:SteamID()
    local voteType = math.random(0, 2)
    local shouldInsert = math.random(0, 1)

    if shouldInsert then
      table.insert(onlinePlayers, fakePlayer)
    end

    playerVotes[steamId] = {}
    playerVotes[steamId][mapName] = voteType
    mapVotesTableCopy:insertVoteIntoSqlTable(mapName, voteType, steamId)
  end

  mapVotesTableCopy:populateCache()
  local weightedMapCache = mapVotesTableCopy:getWeightedMapVotes(onlinePlayers)

  for index, ply in pairs(onlinePlayers) do
    local steamId = ply:SteamID()
    local voteType = mapVotesTableCopy.playerCache[steamId][mapName]

    if voteType == 0 then
      downvotes = downvotes + 1
    elseif voteType == 1 then
      upvotes = upvotes + 1
    end

  end

  GUnit.assert(weightedMapCache[mapName]["downvotes"]):shouldEqual(mapVotesTableCopy.mapCache[mapName]["downvotes"] + downvotes)
  GUnit.assert(weightedMapCache[mapName]["upvotes"]):shouldEqual(mapVotesTableCopy.mapCache[mapName]["upvotes"] + upvotes)
end

local function adjustVotesSpec()
  local mapName = GUnit.Generators.StringGen.generateAlphaNum()

  for i = 1, 100 do
    local fakePlayer = GUnit.Generators.FakePlayer:new()
    local steamId = fakePlayer:SteamID()
    local voteType = math.random(0, 2)

    mapVotesTableCopy:insertVoteIntoSqlTable(mapName, voteType, steamId)
  end

  mapVotesTableCopy:populateCache()

  for steamId, maps in pairs(mapVotesTableCopy.playerCache) do
    local voteType = mapVotesTableCopy.playerCache[steamId][mapName]
    local oldUpvotes = mapVotesTableCopy.mapCache[mapName]["upvotes"]
    local oldDownvotes = mapVotesTableCopy.mapCache[mapName]["downvotes"]
    local oldTotal = oldUpvotes - oldDownvotes
    local newVoteType = math.random(0, 2)
    local expectedDifference = 0

    if voteType == 0 and newVoteType == 1 then
      expectedDifference = 2
    elseif (voteType == 0 and newVoteType == 2) or (voteType == 2 and newVoteType == 1) then
      expectedDifference = 1
    elseif voteType == 1 && newVoteType == 0 then
      expectedDifference = -2
    elseif (voteType == 1 and newVoteType == 2) or (voteType == 2 and newVoteType == 0) then
      expectedDifference = -1
    end

    mapVotesTableCopy:addVote(mapName, newVoteType, steamId)
    local newUpvotes = mapVotesTableCopy.mapCache[mapName]["upvotes"]
    local newDownvotes = mapVotesTableCopy.mapCache[mapName]["downvotes"]
    local newTotal = newUpvotes - newDownvotes

    GUnit.assert(oldTotal + expectedDifference):shouldEqual(newTotal)
  end
end

mapVotesTableTest:beforeEach(beforeEach)
mapVotesTableTest:afterEach(afterEach)

mapVotesTableTest:addSpec("add values to the SQL table", insertSpec)
mapVotesTableTest:addSpec("update values in the SQL table", updateSpec)
mapVotesTableTest:addSpec("cache mapvotes", mapCacheSpec)
mapVotesTableTest:addSpec("cache player-specific votes", playerCacheSpec)
mapVotesTableTest:addSpec("have the mapCache votes be equal to the sum of votes in the playerCache for any given map", cacheSummationSpec)
mapVotesTableTest:addSpec("increase the strength of votes for online players", mapWeightingSpec)
mapVotesTableTest:addSpec("adjust votes in a consistent manner", adjustVotesSpec)
