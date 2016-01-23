function checkForVoteCommand(ply, text)
  if text:len()<7 or text:len()>9 then return false end
  if text=="!upvote" then
    net.Start("SR_UpVotes")
    net.SendToServer()
    return true
  elseif text=="!downvote" then
    net.Start("SR_DownVotes")
    net.SendToServer()
    return true
  end
  return false
end

function checkForVoteTotalCommand(ply, text)
    if text:len()==9 and text=="!mapvotes" then
      net.Start("SR_MapVotes")
      net.SendToServer()
      return true
    end
    return false
end

hook.Add("OnPlayerChat", "mapvotingcommandcheck", function(ply, text, team, isDead)
    if checkForVoteCommand(ply, text) or checkForVoteTotalCommand(ply, text) then return true end
  end)

local map=game.GetMap()
local tablename="SR_MapVotingTable"

function showMapRankings(ply, cmd, args, argstr)
local query1="SELECT DISTINCT mapname FROM SR_MapVotingTable"
  local result1 = sql.Query(query1)
local query2="SELECT mapname, COUNT(*) as upVoteCount FROM ".. tablename .." WHERE votetype == 1 GROUP BY mapname"
  local result2 = sql.Query(query2)
local query3="SELECT mapname, COUNT(*) as downVoteCount FROM ".. tablename .." WHERE votetype == 0 GROUP BY mapname"
  local result3 = sql.Query(query3)
local mapvotes = {}
for row, columns in pairs(result1) do
mapvotes[columns["mapname"]] = {
total = 0,
upvotes = 0,
downvotes = 0
}
end
--[ERROR] addons/srmapvoting/lua/upordownvoting/cl_upordownvoting.lua:39: bad argument #1 to 'pairs' (table expected, got boolean)
for row, mapname in pairs(result2) do 
mapvotes[mapname]["upvotes"] = result2["upVoteCount"]
mapvotes[mapname]["total"] = mapvotes[mapname]["total"] + result2["upVoteCount"]
end
for row, mapname in pairs(result3) do 
mapvotes[mapname]["downvotes"] = result3["downVoteCount"]
mapvotes[mapname]["total"] = mapvotes[mapname]["total"] - result3["downVoteCount"]
end

local Frame = vgui.Create( "DFrame" )
  Frame:SetPos( 5, 5 )
  Frame:SetSize( ScrW() * 0.500, ScrH() * 0.600 )
  Frame:SetTitle( "Map Rankings" )
  Frame:SetVisible( true )
  Frame:SetDraggable( true )
  Frame:ShowCloseButton( true )
  Frame:MakePopup()

local DPanel = vgui.Create( "DPanel", Frame )
  DPanel:SetPos( 10, 30 )
  DPanel:SetSize( ScrW() * 0.450, ScrH() * 0.550 )

local AppList = vgui.Create( "DListView", DPanel )
  DListView:SortByColumn( 2, false )
  DListView:SetSortable( true )
  AppList:SetMultiSelect( false )
  AppList:AddColumn( "Map Name" )
  AppList:AddColumn( "Rank" )
  AppList:AddColumn( "Total" )
  AppList:AddColumn( "Upvotes" )
  AppList:AddColumn( "Downvotes" )
for mapname, columns in pairs(mapvotes) do
  AppList:AddLine(mapname, mapvotes[mapname]["total"], mapvotes[mapname]["upVoteCount"], mapvotes[mapname]["downVoteCount"])
end
end
  
concommand.Add( "SR_ShowMapRankings", showMapRankings )