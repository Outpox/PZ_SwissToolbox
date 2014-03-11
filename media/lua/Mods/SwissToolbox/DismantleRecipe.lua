function dismantleSwissToolbox(_crafttool, _result, _recipe)

	local player = getSpecificPlayer(0)

	player:Say("Dismantle function called");
	print("Dismantle function called");

	if _recipe == "Dismantle SwissToolbox" then

		player:Say("Recipe detected");
		print("Recipe detected");

		if getPlayer():getInventory():contains("SwissToolbox") then
			player:Say("SwissToolbox detected, adding items");
			print("SwissToolbox detected, adding items");

			getPlayer():getInventory():AddItem("Base.Hammer");
			getPlayer():getInventory():AddItem("Base.Saw");
			getPlayer():getInventory():AddItem("Base.Screwdriver");
		end
	end
end

Events.onMakeItem.Add(dismantleSwissToolbox)