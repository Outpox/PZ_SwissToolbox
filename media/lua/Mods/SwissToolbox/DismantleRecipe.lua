local function dismantleSwissToolbox(_crafttool, _result, _recipe)

	local player = getSpecificPlayer(0);

	if _recipe:getName() == "Dismantle SwissToolbox" then

			-- The hammer is given back through the .txt recipe
			-- getPlayer():getInventory():AddItem("Base.Hammer");
			getPlayer():getInventory():AddItem("Base.Saw");
			getPlayer():getInventory():AddItem("Base.Screwdriver");
	end
end


Events.OnMakeItem.Add(dismantleSwissToolbox)