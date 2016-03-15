UpOrDownVoting = {}

if SERVER then
  AddCSLuaFile("upordownvoting/cl_upordownvoting.lua")
  include("upordownvoting/sv_upordownvoting.lua")
  include("config/sv_minmaxconfig.lua")
  include("mapchange/sv_mapchange.lua")
  include("test/sv_testinit.lua")
  end

if CLIENT then 
  include("upordownvoting/cl_upordownvoting.lua") 
end 