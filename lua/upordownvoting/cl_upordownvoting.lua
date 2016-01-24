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
  
local function getRankingsFromServer()
  net.Start("SR_GetRankings")
  net.SendToServer()

  net.Receive("SR_ReceiveRankings", function(len)
    local mapvotes = net.ReadTable()
    local Frame = vgui.Create( "DFrame" )
    Frame:SetPos( 5, 5 )
    Frame:SetSize( 1000, 500)
    Frame:SetTitle( "Map Rankings" )
    Frame:SetVisible( true )
    Frame:SetDraggable( true )
    Frame:ShowCloseButton( true )
    Frame:MakePopup()

  local DPanel = vgui.Create( "DPanel", Frame )
    DPanel:SetPos( 10, 30 )
    DPanel:SetSize( 990, 490 )
-- GET THE VALUES IN THE TABLE TO CENTER
  local AppList = vgui.Create( "DListView", DPanel )
    AppList:SetPos( 10, 10 )
    AppList:SetSize( 950, 450)
    --AppList:SortByColumn( 2, false )
    AppList:SetSortable( true )
    AppList:SetMultiSelect( false )
    AppList:AddColumn( "Map Name" )
    AppList:AddColumn( "Rank" )
    AppList:AddColumn( "Total" )
    AppList:AddColumn( "Upvotes" )
    AppList:AddColumn( "Downvotes" )
    for mapname, columns in pairs(mapvotes) do
    AppList:AddLine(mapname, 0, tonumber(mapvotes[mapname]["total"]), tonumber(mapvotes[mapname]["upvotes"]), tonumber(mapvotes[mapname]["downvotes"]))
    end
  end)
end

concommand.Add( "SR_ShowMapRankings", getRankingsFromServer )