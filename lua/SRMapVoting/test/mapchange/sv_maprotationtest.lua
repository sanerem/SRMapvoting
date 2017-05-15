local mapRotationTest = GUnit.Test:new("MapRotation")
local copiedTable

local function beforeEach()
  copiedTable = table.Copy(SRMapVoting.MapRotation)
end

local function addMapSpec()
  copiedTable:addMap("ttt_testmap", 0, 12)

  local mapEntry = copiedTable.maps["ttt_testmap"]
  GUnit.assert(mapEntry):isNotNil()
  GUnit.assert(mapEntry["minPlayers"]):shouldEqual(0)
  GUnit.assert(mapEntry["maxPlayers"]):shouldEqual(12)
end

local function lengthSpec()
  copiedTable:addMap("ttt_testmap", 0, 12)

  GUnit.assert(copiedTable:length()):shouldEqual(1)
end

local function minPlayersConstraintsSpec()
  GUnit.pending()
end

local function noVoteSpec()
  GUnit.pending()
  copiedTable:addMap("ttt_testmap", 0, 12)
  copiedTable:addMap("ttt_othermap", 0, 15)
end

local function onlyPlayedAvailableSpec()
  GUnit.pending()
end

local function onlyThisMapAvaiableSpec()
  GUnit.pending()
end

mapRotationTest:beforeEach(beforeEach)

mapRotationTest:addSpec("add maps", addMapSpec)
mapRotationTest:addSpec("get the right number of maps in the table", lengthSpec)
mapRotationTest:addSpec("not let you add a map where minplayers exceeds maxplayers", minPlayersConstraintsSpec)
mapRotationTest:addSpec("not break when you try to rotate to a map that has no votes", noVoteSpec)
mapRotationTest:addSpec("work when all of the valid next maps have already been played", onlyPlayedAvailableSpec)
mapRotationTest:addSpec("return the current map if it is the only map available", onlyThisMapAvailableSpec)
