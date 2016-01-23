UpOrDownVoting = {}

if SERVER then
  AddCSLuaFile("upordownvoting/cl_upordownvoting.lua")
  include("upordownvoting/sv_upordownvoting.lua")
  end

if CLIENT then 
  include("upordownvoting/cl_upordownvoting.lua") 
  end