local map=game.GetMap()

local tablename="SR_MapVotingTable"

local function createMapVotingTable()
  local query="create table " .. tablename .. " (id INTEGER PRIMARY KEY, mapname string not null, steamid string not null, votetype integer not null)"
  sql.Query(query)
end

local function addVote(ply, votetype) 
  local query="insert into " .. tablename .. " (mapname,steamid,votetype) values (\"" .. map .. "\", \"" .. ply:SteamID() .. "\", " .. votetype .. ")"
  sql.Query(query)
end

local function voteCheck(ply)
  local query="select * from " .. tablename .. " where mapname==\"" .. map .. "\" and steamid==\"" .. ply:SteamID() .. "\""
  local result= sql.Query(query)
  if result==nil then return -1
  elseif result==false then
    print (sql.LastError()) return -2
  else return tonumber(result[1]["votetype"]) 
  end
end

local function updateVote(ply, votetype)
  local query ="update " .. tablename .. " set votetype= " .. votetype .. " where mapname==\"" .. map .. "\" and steamid==\"" .. ply:SteamID() .. "\""
  sql.Query(query)
  end

local function voteChange(ply, votetype)
  if voteCheck(ply)==-1 then
    addVote(ply, votetype)
  elseif voteCheck(ply)==-2 then return
  else updateVote(ply, votetype) 
  end
end

util.AddNetworkString("SR_UpVotes")
util.AddNetworkString("SR_DownVotes")

net.Receive( "SR_UpVotes", function( len, ply )
    print("Upvoting")
    voteChange(ply, 1)
     --net.Start("SR_UpVotes")
     --net.WriteTable(statTable)
     --net.Send(ply)
     --print("Stats sent")
end)

net.Receive( "SR_DownVotes", function( len, ply )
    print("Downvoting")
    voteChange(ply, 0)
     --net.Start("SR_DownVotes")
     --net.WriteTable(statTable)
     --net.Send(ply)
     --print("Stats sent")
end)

util.AddNetworkString("SR_MapVotes")

net.Receive( "SR_MapVotes", function( len, ply )
    local query1="SELECT COUNT (*) AS upVoteCount from " .. tablename .. " where mapname==\"" .. map .. "\" and votetype==1"
    local result1 = sql.Query(query1)
    local query2="SELECT COUNT (*) AS downVoteCount from " .. tablename .. " where mapname==\"" .. map .. "\" and votetype==0"
    local result2 = sql.Query(query2)
    print ("This map has ".. result1[1]["upVoteCount"] .. " upvotes and " .. result2[1]["downVoteCount"] .. " downvotes")
    PrintMessage(HUD_PRINTTALK, "This map has ".. result1[1]["upVoteCount"] .. " upvotes and " .. result2[1]["downVoteCount"] .. " downvotes")
  end)

createMapVotingTable()