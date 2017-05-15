util.AddNetworkString("SR_UpVote")
util.AddNetworkString("SR_DownVote")
util.AddNetworkString("SR_SideVote")
util.AddNetworkString("SR_MapVotes")
util.AddNetworkString("SR_MapVotesResponse")
util.AddNetworkString("SR_GetRankings")
util.AddNetworkString("SR_ReceiveRankings")
util.AddNetworkString("SRMapVoting_ConfirmUpVote")
util.AddNetworkString("SRMapVoting_ConfirmDownVote")
util.AddNetworkString("SRMapVoting_ConfirmSideVote")
util.AddNetworkString("SRMapVoting_RejectVote")

local mapName = game.GetMap()

local function playerHasValidGroup(ply)
  local allowedGroups = SRMapVoting.Config.allowedVotingGroups

  for k, v in pairs(allowedGroups) do
    if ply:IsUserGroup(v) then return true end
  end

  return false
end

local function rejectVote(ply)
  net.Start("SRMapVoting_RejectVote")
  net.Send(ply)
end

net.Receive("SR_UpVote", function( len, ply )
  if playerHasValidGroup(ply) then
    SRMapVoting.MapVotesTable:addVote(mapName, 1, ply:SteamID())
    net.Start("SRMapVoting_ConfirmUpVote")
    net.Send(ply)
  else
    rejectVote(ply)
  end
end)

net.Receive("SR_DownVote", function( len, ply )
  if playerHasValidGroup(ply) then
    SRMapVoting.MapVotesTable:addVote(mapName, 0, ply:SteamID())
    net.Start("SRMapVoting_ConfirmDownVote")
    net.Send(ply)
  else
    rejectVote(ply)
  end
end)

net.Receive("SR_SideVote", function( len, ply )
  if playerHasValidGroup(ply) then
    SRMapVoting.MapVotesTable:addVote(mapName, 2, ply:SteamID())
    net.Start("SRMapVoting_ConfirmSideVote")
    net.Send(ply)
  else
    rejectVote(ply)
  end
end)

net.Receive("SR_MapVotes", function( len, ply ) --Either pass in two parameters, giving it the "upVoteCount"/"downVoteCount" string and the votetype, or one parameter (preferably the votetype) and use an if statement inside the function to deduce what the other values should be.
    local count = SRMapVoting.MapVotesTable.mapCache[mapName]
    local upvotes = 0
    local downvotes = 0

    if count != nil then
      upvotes = count["upvotes"]
      downvotes = count["downvotes"]
    end

    net.Start("SR_MapVotesResponse")
    net.WriteUInt(upvotes, 16)
    net.WriteUInt(downvotes, 16)
    net.Send(ply)
end)

net.Receive("SR_GetRankings", function( len, ply )
    local rankings = gatherMapRankings()
    net.Start ("SR_ReceiveRankings")
    net.WriteTable(rankings)
    net.Send(ply)
end)
