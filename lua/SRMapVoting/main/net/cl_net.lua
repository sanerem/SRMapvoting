local red = Color(255, 0, 0, 255)
local yellow = Color(255, 255, 0, 255)
local green = Color(0, 255, 0, 255)

net.Receive( "SR_MapVotesResponse", function(len)
  local upvotes = net.ReadUInt(16)
  local downvotes = net.ReadUInt(16)
  chat.AddText("This map has " .. upvotes .. " upvotes and " .. downvotes .. " downvotes.")
  chat.AddText("Net Votes: " .. upvotes - downvotes)
end)

net.Receive( "SRMapVoting_ConfirmUpVote", function(len)
  chat.AddText(green, "Your vote for this map has been set as an upvote.")
end)

net.Receive( "SRMapVoting_ConfirmDownVote", function(len)
  chat.AddText(red, "Your vote for this map has been set as a downvote.")
end)

net.Receive( "SRMapVoting_ConfirmSideVote", function(len)
  chat.AddText(yellow, "You have neutralized your vote for this map.")
end)

net.Receive( "SRMapVoting_RejectVote", function(len)
  chat.AddText("Your rank is not allowed to vote. Attain a higher rank first.")
end)
