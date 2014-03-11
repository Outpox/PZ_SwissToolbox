function dismantleSwissToolbox(_recipe)

	if _recipe == "Dismantle SwissToolbox" then
		if getPlayer():getInventory():contains("SwissToolbox") then
			getPlayer():getInventory():AddItem("Base.Hammer");
			getPlayer():getInventory():AddItem("Base.Saw");
			getPlayer():getInventory():AddItem("Base.Screwdriver");
		end
	end
end