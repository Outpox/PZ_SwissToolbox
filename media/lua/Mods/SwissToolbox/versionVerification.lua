function versionVerificationAuto()
	getPlayer:Say("SwissToolbox version 0.2 -- Test Barricade");
end

function versionVerificationMan(_keynum)
	local key = _keynum;
	print (key);

	if key == 38 then
		local player = getSpecificPlayer(0);
		
		player:Say("SwissToolbox version 0.2 -- Test Barricade");
		print("SwissToolbox version 0.2 -- Test Barricade");
	end
end

Events.OnGameStart.Add(versionVerificationAuto);
Events.OnKeyPressed.Add(versionVerificationMan);