SRMapVoting = {}

if SERVER then
  AddCSLuaFile("SRMapVoting/main/cl_srmapvoting.lua")
  AddCSLuaFile("SRMapVoting/main/net/cl_net.lua")
  include("SRMapVoting/main/database/sv_mapvotetable.lua")
  include("SRMapVoting/main/mapchange/sv_maprotation.lua")
  include("SRMapVoting/main/config/sv_minmaxconfig.lua")
  include("SRMapVoting/main/mapchange/sv_mapchange.lua")
  include("SRMapVoting/main/net/sv_net.lua")
  include("SRMapVoting/test/sv_testinit.lua")
end

if CLIENT then
  include("SRMapVoting/main/cl_srmapvoting.lua")
  include("SRMapVoting/main/net/cl_net.lua")
end
