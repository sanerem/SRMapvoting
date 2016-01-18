UpOrDownVoting = {}

if SERVER then
  AddCSLuaFile("upordownvoting/cl_upordownvoting.lua")
  include("mapvoting/sv_mapvoting.lua")
  end

if CLIENT then include("upordownvoting/cl_upordownvoting.lua") end