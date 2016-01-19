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
