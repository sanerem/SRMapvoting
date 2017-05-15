local mapRotation = SRMapVoting.MapRotation

SRMapVoting.Config = {}

--[[
How many negative votes can a map have before it is removed from rotation?
Weighted votes count.
]]
SRMapVoting.Config.downVoteCutoff = -20

--[[
How many maps ago did you play on a certain map?
If it's less than this number, the addon won't rotate to it,
EVEN IF the addon itself did not select it.
]]
SRMapVoting.Config.numOfRecentMapsToBlock = 5

--[[
The user groups of people who are allowed to vote.
]]
SRMapVoting.Config.allowedVotingGroups = {"regular", "trusted", "veteran", "pveteran", "bronzedonator", "silverdonator", "golddonator", "superadmin", "admin", "moderator", "trialmod"}



--Format: mapFileName, minPlayers, maxPlayers
--Example: You want to play on ttt_dolls.bsp with no minimum and 32 players max.
--mapRotation:addMap("ttt_dolls", 0, 32)

mapRotation:addMap("ttt_dolls", 0, 32)
