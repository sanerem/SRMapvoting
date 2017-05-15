local MapVotesTable = {}
MapVotesTable.__index = MapVotesTable
MapVotesTable.tableName = "SR_MapVotingTable"
MapVotesTable.mapCache = {}
MapVotesTable.playerCache = {}

local voteTable = {
  DOWNVOTE = 0,
  UPVOTE = 1,
  SIDEVOTE = 2 --Someone who voted previously removed their vote
}

function MapVotesTable:create()
  local query = "CREATE TABLE IF NOT EXISTS " .. self.tableName ..
                " (id INTEGER PRIMARY KEY, mapname STRING NOT NULL, steamid STRING NOT NULL, votetype INTEGER NOT NULL)"
  return sql.Query(query)
end

function MapVotesTable:insertVoteIntoSqlTable(mapName, voteType, steamId)
  local query = "INSERT INTO " .. self.tableName .. " (mapname, steamid, votetype) values ('" .. mapName .. "', '" .. steamId .. "', " .. voteType .. ")"
  local result = sql.Query(query)
  return result
end

function MapVotesTable:addToMapCache(mapName, voteType)
  if (self.mapCache[mapName] == nil) then
    self.mapCache[mapName] = {
      upvotes = 0,
      downvotes = 0
    }
  end

  if (voteType == voteTable.UPVOTE) then
    self.mapCache[mapName]["upvotes"] = self.mapCache[mapName]["upvotes"] + 1
  elseif (voteType == voteTable.DOWNVOTE) then
    self.mapCache[mapName]["downvotes"] = self.mapCache[mapName]["downvotes"] + 1
  end
end

function MapVotesTable:addPlayerToCache(steamId)
  if (self.playerCache[steamId] == nil) then
    self.playerCache[steamId] = {}
  end
end

function MapVotesTable:addVoteToPlayerCache(mapName, voteType, steamId)
  self.playerCache[steamId][mapName] = voteType
end

function MapVotesTable:populateCache()
  local query = "SELECT * FROM " .. self.tableName
  local result = sql.Query(query)

  if (result) then
    self.mapCache = {}
    self.playerCache = {}

    for row, columns in pairs(result) do
      local mapName = columns["mapname"]
      local steamId = columns["steamid"]
      local voteType = tonumber(columns["votetype"])

      self:addToMapCache(mapName, voteType)
      self:addPlayerToCache(steamId)
      self:addVoteToPlayerCache(mapName, voteType, steamId)
    end
  end
end

function MapVotesTable:undoVote(mapName, steamId)
  local voteType = self.playerCache[steamId][mapName]

  if voteType == voteTable.UPVOTE then
    self.mapCache[mapName]["upvotes"] = self.mapCache[mapName]["upvotes"] - 1
  elseif voteType == voteTable.DOWNVOTE then
    self.mapCache[mapName]["downvotes"] = self.mapCache[mapName]["downvotes"] - 1
  end

end

function MapVotesTable:updateVoteInSqlTable(mapName, voteType, steamId)
  local query = "UPDATE " .. self.tableName .. " SET votetype = " .. voteType .. " where mapname == '" .. mapName .. "' and steamid == '" .. steamId .. "'"
  return sql.Query(query)
end

function MapVotesTable:addVote(mapName, voteType, steamId)
  self:addPlayerToCache(steamId)

  if self.playerCache[steamId][mapName] == nil then
    self:insertVoteIntoSqlTable(mapName, voteType, steamId)
    self:addToMapCache(mapName, voteType)
  elseif self.playerCache[steamId][mapName] != voteType then
    self:updateVoteInSqlTable(mapName, voteType, steamId)
    self:undoVote(mapName, steamId)
    self:addToMapCache(mapName, voteType)
  end

  self:addVoteToPlayerCache(mapName, voteType, steamId)
end

--[[
Returns a maplist with the additional weighting from online players.
Given a playerlist instead of checking for online players automatically
to facilitate testing.
]]
function MapVotesTable:getWeightedMapVotes(playerList)
  local weightedMapCache = table.Copy(self.mapCache)

  for index, ply in pairs(playerList) do
    local steamId = ply:SteamID()

    if self.playerCache[steamId] then
      for mapName, voteType in pairs(self.playerCache[steamId]) do
        --Double the strength of online player votes.
        if (voteType == voteTable.UPVOTE) then
          weightedMapCache[mapName]["upvotes"] = weightedMapCache[mapName]["upvotes"] + 1
        elseif (voteType == voteTable.DOWNVOTE) then
          weightedMapCache[mapName]["downvotes"] = weightedMapCache[mapName]["downvotes"] + 1
        end

      end
    end

  end

  return weightedMapCache
end

MapVotesTable:create()
SRMapVoting.MapVotesTable = MapVotesTable
