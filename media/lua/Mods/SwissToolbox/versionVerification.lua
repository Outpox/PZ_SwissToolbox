function versionVerificationAuto()
	getSpecificPlayer(0):Say("SwissToolbox version 0.4 loaded");
end

Events.OnGameStart.Add(versionVerificationAuto);
