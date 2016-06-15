if GUnit then
  GUnit.load()
end

  hook.Add("GUnitReady", "DDDLoadTests", function()
    GUnit.load()
  end)