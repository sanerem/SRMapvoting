local PreviousMapTable = {}
PreviousMapTable.__index = PreviousMapTable
PreviousMapTable.tableName = "srmapvoting_previousmap"

local mapName = game.GetMap()

function PreviousMapTable:create()
  local query = "CREATE TABLE IF NOT EXISTS " .. self.tableName
  return sql.Query(query)
end

function PreviousMapTable:addThisMap()
  local query = "INSERT INTO " .. mapName
end
