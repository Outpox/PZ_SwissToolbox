function versionVerificationAuto()
	getSpecificPlayer(0):Say("SwissToolbox version 0.2 -- Test Barricade");
end

local function versionVerificationMan(_keynum)
	local key = _keynum;
	local player = getSpecificPlayer(0);
	local inv = player:getInventory();

	print (key);

	-- Letter "L"
	if key == 38 then
		
		
		player:Say("SwissToolbox version 0.2 -- Test Barricade");
		print("SwissToolbox version 0.2 -- Test Barricade");
	end

	-- Letter "P"
	if key == 25 then
		player:Say("SwissToolbox version 0.2 -- Test Barricade");
		print("SwissToolbox version 0.2 -- Test Barricade");

		inv:AddItem("Base.Hammer");
		inv:AddItem("Base.Saw");
		inv:AddItem("Base.Screwdriver");
	end
end

Events.OnGameStart.Add(versionVerificationAuto);
Events.OnKeyPressed.Add(versionVerificationMan);