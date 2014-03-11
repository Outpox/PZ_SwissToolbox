function versionVerificationAuto()
	getPlayer:Say("SwissToolbox version 0.2 -- Test Barricade");
end

function versionVerificationMan(keynum)
	if keynum == 38 then
		getPlayer:Say("SwissToolbox version 0.2 -- Test Barricade");
		print("SwissToolbox version 0.2 -- Test Barricade");
	end
end

Events.OnGameStart.Add(versionVerification);