local mapchangetest = GUnit.Test:new("mapchange")

local function nextmapspec()
  SRMapVoting.recalculate()
  local currentmap = game.GetMap()
  local nextmap = SRMapVoting.setRandomNextMapFromList()

  GUnit.assert(currentmap):shouldNotEqual(nextmap):shouldNotEqual(nil)
  print(currentmap)
  print(nextmap)
end

local function excludemapspec()
  print ("test2")
  local map = "gm_guccisserver"
  local mapvotestable = {}
  local probabilitytable = {}
  mapvotestable[map] = {}
  mapvotestable[map].upvotes = 1
  mapvotestable[map].downvotes = 100
  probabilitytable[map] = 0
  probabilitytable["gm_construct"] = 0
  SRMapVoting.excludeMaps(probabilitytable, mapvotestable)
  assert(probabilitytable[map] == nil)
end

mapchangetest:addSpec("Switched to the next map successfully", nextmapspec)
mapchangetest:addSpec("Should exclude maps with <50 votes", excludemapspec)
