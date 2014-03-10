--***********************************************************
--**                    ROBERT JOHNSON                     **
--**       Contextual menu for building when clicking somewhere on the ground       **
--***********************************************************

ISBuildMenu = {};
ISBuildMenu.planks = 0;
ISBuildMenu.nails = 0;
ISBuildMenu.hinge = 0;
ISBuildMenu.doorknob = 0;
ISBuildMenu.cheat = false;
ISBuildMenu.woodWorkXp = 0;


ISBuildMenu.doBuildMenu = function(player, context, worldobjects)

    if JoypadState.players[player+1] ~= nil or getCore():getGameMode()=="LastStand" then
        return;
    end

	ISBuildMenu.woodWorkXp = getSpecificPlayer(player):getPerkLevel(Perks.Woodwork);
	local thump = nil;

	local square = nil;

	-- we get the thumpable item (like wall/door/furniture etc.) if exist on the tile we right clicked
	for i,v in ipairs(worldobjects) do
		square = v:getSquare();
		if instanceof(v, "IsoThumpable") and not v:isDoor() then
			thump = v;
		end
    end

	-- dismantle stuff
	if thump and thump:isDismantable() and getSpecificPlayer(player):getInventory():contains("Saw") and getSpecificPlayer(player):getInventory():contains("Screwdriver") or getSpecificPlayer(player):getInventory():contains("SwissToolbox") then
		context:addOption(getText("ContextMenu_Dismantle"), worldobjects, ISBuildMenu.onDismantle, thump, getSpecificPlayer(player));
	end

	-- build menu
	-- if we have any thing to build in our inventory
	if ISBuildMenu.haveSomethingtoBuild(player) then
		local buildOption = context:addOption(getText("ContextMenu_Build"), worldobjects, nil);
		-- create a brand new context menu wich contain our different material (wood, stone etc.) to build
		local subMenu = ISContextMenu:getNew(context);
		-- We create the different option for this new menu (wood, stone etc.)
		-- check if we can build something in wood material
		if haveSomethingtoBuildWood(player) then
			-- we add the subMenu to our current option (Build)
			context:addSubMenu(buildOption, subMenu);
			------------------ WALL ------------------
			ISBuildMenu.buildWallMenu(subMenu, player);
			------------------ DOOR ------------------
			local doorOption = subMenu:addOption(getText("ContextMenu_Door"), worldobjects, nil);
			local subMenuDoor = subMenu:getNew(subMenu);
			-- we add our new menu to the option we want (here door)
			context:addSubMenu(doorOption, subMenuDoor);
			ISBuildMenu.buildDoorMenu(subMenuDoor, player);
			------------------ DOOR FRAME ------------------
			ISBuildMenu.buildDoorFrameMenu(subMenu, player);
--~ 			----------------- WINDOWS FRAME-----------------
			ISBuildMenu.buildWindowsFrameMenu(subMenu, player);
--~ 			------------------ STAIRS ------------------
			local stairsOption = subMenu:addOption(getText("ContextMenu_Stairs"), worldobjects, nil);
			local subMenuStairs = subMenu:getNew(subMenu);
			-- we add our new menu to the option we want (here wood)
			context:addSubMenu(stairsOption, subMenuStairs);
			ISBuildMenu.buildStairsMenu(subMenuStairs, player);
--~ 			------------------ FLOOR ------------------
			local floorOption = subMenu:addOption(getText("ContextMenu_Floor"), worldobjects, nil);
			local subMenuFloor = subMenu:getNew(subMenu);
			-- we add our new menu to the option we want (here build)
			context:addSubMenu(floorOption, subMenuFloor);
			ISBuildMenu.buildFloorMenu(subMenuFloor, player);
			------------------ WOODEN CRATE ------------------
			ISBuildMenu.buildContainerMenu(subMenu, player);
			------------------ BAR ------------------
			local barOption = subMenu:addOption(getText("ContextMenu_Bar"), worldobjects, nil);
			local subMenuBar = subMenu:getNew(subMenu);
			-- we add our new menu to the option we want (here wood)
			context:addSubMenu(barOption, subMenuBar);
			ISBuildMenu.buildBarMenu(subMenuBar, player);
			------------------ FURNITURE ------------------
			local furnitureOption = subMenu:addOption(getText("ContextMenu_Furniture"), worldobjects, nil);
			local subMenuFurniture = subMenu:getNew(subMenu);
			-- we add our new menu to the option we want (here build)
			context:addSubMenu(furnitureOption, subMenuFurniture);
			ISBuildMenu.buildFurnitureMenu(subMenuFurniture, context, player);
			------------------ FENCE ------------------
			local fenceOption = subMenu:addOption(getText("ContextMenu_Fence"), worldobjects, nil);
			local subMenuFence = subMenu:getNew(subMenu);
			-- we add our new menu to the option we want (here build)
			context:addSubMenu(fenceOption, subMenuFence);
			ISBuildMenu.buildFenceMenu(subMenuFence, player);
            ------------------ LIGHT SOURCES ------------------
            local lightOption = subMenu:addOption("Light source", worldobjects, nil);
            local subMenuLight = subMenu:getNew(subMenu);
            -- we add our new menu to the option we want (here build)
            context:addSubMenu(lightOption, subMenuLight);
            ISBuildMenu.buildLightMenu(subMenuLight, player);
		end
	end
end

function ISBuildMenu.haveSomethingtoBuild(player)
--~ 	return true;
	return haveSomethingtoBuildWood(player);
end

function haveSomethingtoBuildWood(player)
	if ISBuildMenu.cheat then
		return true;
	end
	ISBuildMenu.planks = 0;
	ISBuildMenu.nails = 0;
	ISBuildMenu.hinge = 0;
	ISBuildMenu.doorknob = 0;
	-- we must have a hammer and a saw for all the building
    local haveSandbags = false;
    if getSpecificPlayer(player):getInventory():getItemCount("Base.Sandbag") >= 3 then
        haveSandbags = true;
    end
    if getSpecificPlayer(player):getInventory():getItemCount("Base.Gravelbag") >= 3 then
        haveSandbags = true;
    end
	if not getSpecificPlayer(player):getInventory():contains("Hammer") or not getSpecificPlayer(player):getInventory():contains("SwissToolbox") and not haveSandbags then
		return false;
	end
	-- get the number of plank we got
	for i = 0, getSpecificPlayer(player):getInventory():getItems():size() - 1 do
		local item = getSpecificPlayer(player):getInventory():getItems():get(i);
		if item:getType() == "Plank" then
			ISBuildMenu.planks = ISBuildMenu.planks + 1;
		elseif item:getType() == "Nails" then
			ISBuildMenu.nails = ISBuildMenu.nails + 1;
		elseif item:getType() == "Doorknob" then
			ISBuildMenu.doorknob = ISBuildMenu.doorknob + 1;
		elseif item:getType() == "Hinge" then
			ISBuildMenu.hinge = ISBuildMenu.hinge + 1;
		end
	end
	-- we also check if there's any material on the ground, in a 3x3 square around the player
	local materialOnGround = buildUtil.checkMaterialOnGround(getSpecificPlayer(player):getCurrentSquare());
	for i,v in pairs(materialOnGround) do
		if i == "Plank" then
			ISBuildMenu.planks = ISBuildMenu.planks + v;
		elseif i == "Nails" then
			ISBuildMenu.nails = ISBuildMenu.nails + v;
		elseif i == "Doorknob" then
			ISBuildMenu.doorknob = ISBuildMenu.doorknob + v;
		elseif i == "Hinge" then
			ISBuildMenu.hinge = ISBuildMenu.hinge + v;
		end
	end
	return true;
end

-- **********************************************
-- **                   *BAR*                  **
-- **********************************************

ISBuildMenu.buildBarMenu = function(subMenu, player)
	local barElemSprite = ISBuildMenu.getBarElementSprites(player);
	local barElemOption = subMenu:addOption(getText("ContextMenu_Bar_Element"), worldobjects, ISBuildMenu.onBarElement, barElemSprite, player);
	local tooltip = ISBuildMenu.canBuild(4,4,0,0,0,3,barElemOption, player);
	tooltip:setName(getText("ContextMenu_Bar_Element"));
	tooltip.description = getText("Tooltip_craft_barElementDesc") .. tooltip.description;
	tooltip:setTexture(barElemSprite.sprite);

	local barCornerSprite = ISBuildMenu.getBarCornerSprites(player);
	local barCornerOption = subMenu:addOption(getText("ContextMenu_Bar_Corner"), worldobjects, ISBuildMenu.onBarElement, barCornerSprite, player);
	local tooltip2 = ISBuildMenu.canBuild(4,4,0,0,0,3,barCornerOption, player);
	tooltip2:setName(getText("ContextMenu_Bar_Corner"));
	tooltip2.description = getText("Tooltip_craft_barElementDesc") .. tooltip2.description;
	tooltip2:setTexture(barCornerSprite.sprite);
end

ISBuildMenu.onBarElement = function(worldobjects, sprite, player)
	-- sprite, northSprite
	local bar = ISWoodenContainer:new(sprite.sprite, sprite.northSprite);
	bar.name = "Bar";
	bar:setEastSprite(sprite.eastSprite);
	bar:setSouthSprite(sprite.southSprite);
	bar.modData["need:Base.Plank"] = "4";
	bar.modData["need:Base.Nails"] = "4";
	getCell():setDrag(bar);
end


-- **********************************************
-- **                  *FENCE*                 **
-- **********************************************

ISBuildMenu.buildFenceMenu = function(subMenu, player)
	local stakeOption = subMenu:addOption(getText("ContextMenu_Wooden_Stake"), worldobjects, ISBuildMenu.onWoodenFenceStake, square);
	local toolTip = ISBuildMenu.canBuild(1,2,0,0,0,2,stakeOption, player);
	toolTip:setName(getText("ContextMenu_Wooden_Stake"));
	toolTip.description = getText("Tooltip_craft_woodenStakeDesc") .. toolTip.description;
	toolTip:setTexture("fencing_01_19");

	local barbedOption = subMenu:addOption(getText("ContextMenu_Barbed_Fence"), worldobjects, ISBuildMenu.onBarbedFence, square);
	local tooltip2 = ISBuildMenu.canBuild(0,0,0,0,1,2,barbedOption, player);
	-- we add that we need a Barbed wire too
	if not getSpecificPlayer(player):getInventory():contains("BarbedWire") and not ISBuildMenu.cheat then
		tooltip2.description = tooltip2.description .. " <RGB:1,0,0>Barbed wire 0/1 ";
		barbedOption.onSelect = nil;
		barbedOption.notAvailable = true;
	else
		tooltip2.description = tooltip2.description .. " <RGB:1,1,1>Barbed wire 1 ";
	end
	tooltip2:setName(getText("ContextMenu_Barbed_Fence"));
	tooltip2.description = getText("Tooltip_craft_barbedFenceDesc") .. tooltip2.description;
	tooltip2:setTexture("fencing_01_20");

	local woodenFenceSprite = ISBuildMenu.getWoodenFenceSprites(player);
	local fenceOption = subMenu:addOption(getText("ContextMenu_Wooden_Fence"), worldobjects, ISBuildMenu.onWoodenFence, square, woodenFenceSprite);
	local tooltip3 = ISBuildMenu.canBuild(2,3,0,0,0,0,fenceOption, player);
	tooltip3:setName(getText("ContextMenu_Wooden_Fence"));
	tooltip3.description = getText("Tooltip_craft_woodenFenceDesc") .. tooltip3.description;
	tooltip3:setTexture(woodenFenceSprite.sprite);

	local sandBagOption = subMenu:addOption(getText("ContextMenu_Sang_Bag_Wall"), worldobjects, ISBuildMenu.onSangBagWall, square);
	local tooltip4 = ISBuildMenu.canBuild(0,0,0,0,0,0,sandBagOption, player);
	-- we add that we need 3 sand bag too
	if getSpecificPlayer(player):getInventory():getItemCount("Base.Sandbag") < 3 and not ISBuildMenu.cheat then
		tooltip4.description = tooltip4.description .. " <RGB:1,0,0>" .. getItemText("Sand bag") .. " " .. getSpecificPlayer(player):getInventory():getItemCount("Base.SandBag") .. "/3 ";
		sandBagOption.onSelect = nil;
		sandBagOption.notAvailable = true;
	else
		tooltip4.description = tooltip4.description .. " <RGB:1,1,1>" .. getItemText("Sand bag") .. " 3 ";
	end
	tooltip4:setName(getText("ContextMenu_Sang_Bag_Wall"));
	tooltip4.description = getText("Tooltip_craft_sandBagDesc") .. tooltip4.description;
	tooltip4:setTexture("carpentry_02_12");

    local gravelBagOption = subMenu:addOption(getText("ContextMenu_Gravel_Bag_Wall"), worldobjects, ISBuildMenu.onGravelBagWall, square);
    local tooltip5 = ISBuildMenu.canBuild(0,0,0,0,0,0,gravelBagOption, player);
    -- we add that we need 3 gravel bag too
    if getSpecificPlayer(player):getInventory():getItemCount("Base.Gravelbag") < 3 and not ISBuildMenu.cheat then
        tooltip5.description = tooltip5.description .. " <RGB:1,0,0>" .. getItemText("Gravel bag") .. " " .. getSpecificPlayer(player):getInventory():getItemCount("Base.GravelBag") .. "/3 ";
        gravelBagOption.onSelect = nil;
        gravelBagOption.notAvailable = true;
    else
        tooltip5.description = tooltip5.description .. " <RGB:1,1,1>" .. getItemText("Gravel bag") .. " 3 ";
    end
    tooltip5:setName(getText("ContextMenu_Gravel_Bag_Wall"));
    tooltip5.description = getText("Tooltip_craft_gravelBagDesc") .. tooltip5.description;
    tooltip5:setTexture("carpentry_02_12");
end

ISBuildMenu.onBarbedFence = function(worldobjects, square)
	-- sprite, northSprite, corner
	local fence = ISWoodenWall:new("fencing_01_20", "fencing_01_21", nil);
	-- we can place our fence every where
	fence.canBeAlwaysPlaced = true;
	fence.hoppable = true;
	fence.modData["need:Base.BarbedWire"] = "1";
	getCell():setDrag(fence);
end

ISBuildMenu.onWoodenFenceStake = function(worldobjects, square)
	-- sprite, northSprite, corner
	local fence = ISWoodenWall:new("fencing_01_19", "fencing_01_19", nil);
	-- you can pass hopp a fence
	fence.hoppable = true;
	-- we can place our fence every where
	fence.canBeAlwaysPlaced = true;
	fence.modData["need:Base.Plank"] = "1";
	fence.modData["need:Base.Nails"] = "2";
	getCell():setDrag(fence);
end

ISBuildMenu.onSangBagWall = function(worldobjects, square)
	-- sprite, northSprite, corner
	local fence = ISWoodenWall:new("carpentry_02_12", "carpentry_02_13", nil);
	fence:setEastSprite("carpentry_02_14");
	fence:setSouthSprite("carpentry_02_15");
    fence.hoppable = true;
	-- but it slow you
--	fence.crossSpeed = 0.3;
	fence.modData["need:Base.Sandbag"] = "3";
	getCell():setDrag(fence);
end

ISBuildMenu.onGravelBagWall = function(worldobjects, square)
-- sprite, northSprite, corner
    local fence = ISWoodenWall:new("carpentry_02_12", "carpentry_02_13", nil);
    fence:setEastSprite("carpentry_02_14");
    fence:setSouthSprite("carpentry_02_15");
    fence.hoppable = true;
    -- but it slow you
--    fence.crossSpeed = 0.3;
    fence.modData["need:Base.GravelBag"] = "3";
    getCell():setDrag(fence);
end

ISBuildMenu.onWoodenFence = function(worldobjects, square, sprite)
	-- sprite, northSprite, corner
	local fence = ISWoodenWall:new(sprite.sprite, sprite.northSprite, sprite.corner);
	-- you can hopp a fence
	fence.hoppable = true;
	fence.modData["need:Base.Plank"] = "2";
	fence.modData["need:Base.Nails"] = "3";
	getCell():setDrag(fence);
end

-- **********************************************
-- **          *LIGHT SOURCES*                 **
-- **********************************************
ISBuildMenu.buildLightMenu = function(subMenu, player)
    local sprite = ISBuildMenu.getPillarLampSprite(player);
    local lampOption = subMenu:addOption(getText("ContextMenu_Lamp_on_Pillar"), worldobjects, ISBuildMenu.onPillarLamp, square, sprite, getSpecificPlayer(player));
    local toolTip = ISBuildMenu.canBuild(2,4,0,0,0,1,lampOption, player);
    if not getSpecificPlayer(player):getInventory():contains("Torch") and not ISBuildMenu.cheat then
        toolTip.description = toolTip.description .. " <RGB:1,0,0>Torchlight 0/1 ";
        lampOption.onSelect = nil;
        lampOption.notAvailable = true;
    else
        toolTip.description = toolTip.description .. " <RGB:1,1,1>Torchlight 1 ";
    end
    if not getSpecificPlayer(player):getInventory():contains("Rope") and not ISBuildMenu.cheat then
        toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0>Rope 0/1 ";
        lampOption.onSelect = nil;
        lampOption.notAvailable = true;
    else
        toolTip.description = toolTip.description .. " <LINE> <RGB:1,1,1>Rope 1 ";
    end
    toolTip:setName(getText("ContextMenu_Lamp_on_Pillar"));
    toolTip.description = getText("ContextMenu_Lamp_on_Pillar") .. " " .. toolTip.description;
    toolTip:setTexture("carpentry_02_59");
end

ISBuildMenu.onPillarLamp = function(worldobjects, square, sprite, player)
-- sprite, northSprite
    local lamp = ISLightSource:new(sprite.sprite, sprite.northSprite, player);
    lamp.offsetX = 5;
    lamp.offsetY = 5;
    lamp.modData["need:Base.Plank"] = "2";
    lamp.modData["need:Base.Rope"] = "1";
    lamp.modData["need:Base.Nails"] = "4";
    lamp:setEastSprite(sprite.eastSprite);
    lamp:setSouthSprite(sprite.southSprite);
    lamp.fuel = "Base.Battery";
    lamp.baseItem = "Torch";
    lamp.radius = 10;
    getCell():setDrag(lamp);
end

-- **********************************************
-- **                  *WALL*                  **
-- **********************************************

ISBuildMenu.buildWallMenu = function(subMenu, player)
	local sprite = ISBuildMenu.getWoodenWallSprites(player);
	local wallOption = subMenu:addOption(getText("ContextMenu_Wooden_Wall"), worldobjects, ISBuildMenu.onWoodenWall, sprite, player);
	local tooltip = ISBuildMenu.canBuild(3, 3, 0, 0, 0, 0, wallOption, player);
	tooltip:setName(getText("ContextMenu_Wooden_Wall"));
	tooltip.description = getText("Tooltip_craft_woodenWallDesc") .. tooltip.description;
	tooltip:setTexture(sprite.sprite);

	local pillarOption = subMenu:addOption(getText("ContextMenu_Wooden_Pillar"), worldobjects, ISBuildMenu.onWoodenPillar);
	local tooltip = ISBuildMenu.canBuild(2, 3, 0, 0, 0, 0, pillarOption, player);
	tooltip:setName(getText("ContextMenu_Wooden_Pillar"));
	tooltip.description = getText("Tooltip_craft_woodenPillarDesc") .. tooltip.description;
	tooltip:setTexture("walls_exterior_wooden_01_27");
end

ISBuildMenu.onWoodenPillar = function(worldobjects, square)
	local wall = ISWoodenWall:new("walls_exterior_wooden_01_27", "walls_exterior_wooden_01_27", nil);
	wall.modData["need:Base.Plank"] = "2";
	wall.modData["need:Base.Nails"] = "3";
	wall.canPassThrough = true;
	getCell():setDrag(wall);
end

ISBuildMenu.onWoodenWall = function(worldobjects, sprite, player)
	-- sprite, northSprite, corner
	local wall = ISWoodenWall:new(sprite.sprite, sprite.northSprite, sprite.corner);
	wall.canBePlastered = true;
	wall.canBarricade = false
	-- set up the required material
    wall.modData["wallType"] = "wall";
	wall.modData["need:Base.Plank"] = "3";
	wall.modData["need:Base.Nails"] = "3";
    wall.player = player;
    getCell():setDrag(wall, player);
end

-- **********************************************
-- **              *WINDOWS FRAME*             **
-- **********************************************
ISBuildMenu.buildWindowsFrameMenu = function(subMenu, player)
	local sprite = ISBuildMenu.getWoodenWindowsFrameSprites(player);
	local wallOption = subMenu:addOption(getText("ContextMenu_Windows_Frame"), worldobjects, ISBuildMenu.onWoodenWindowsFrame, square, sprite);
	local tooltip = ISBuildMenu.canBuild(4, 4, 0, 0, 0, 0, wallOption, player);
	tooltip:setName(getText("ContextMenu_Windows_Frame"));
	tooltip.description = getText("Tooltip_craft_woodenFrameDesc") .. tooltip.description;
	tooltip:setTexture(sprite.sprite);
end

ISBuildMenu.onWoodenWindowsFrame = function(worldobjects, square, sprite)
	-- sprite, northSprite, corner
	local frame = ISWoodenWall:new(sprite.sprite, sprite.northSprite, sprite.corner);
	frame.canBePlastered = true;
	frame.hoppable = true;
	-- set up the required material
    frame.modData["wallType"] = "windowsframe";
	frame.modData["need:Base.Plank"] = "4";
	frame.modData["need:Base.Nails"] = "4";
	getCell():setDrag(frame);
end

-- **********************************************
-- **                  *FLOOR*                 **
-- **********************************************

ISBuildMenu.buildFloorMenu = function(subMenu, player)
	-- simple wooden floor
    local floorSprite = ISBuildMenu.getWoodenFloorSprites(player);
	local floorOption = subMenu:addOption(getText("ContextMenu_Wooden_Floor"), worldobjects, ISBuildMenu.onWoodenFloor, square, floorSprite);
	local tooltip = ISBuildMenu.canBuild(1,1,0,0,0,0,floorOption, player);
	tooltip:setName(getText("ContextMenu_Wooden_Floor"));
	tooltip.description = getText("Tooltip_craft_woodenFloorDesc") .. tooltip.description;
	tooltip:setTexture(floorSprite.sprite);
end

ISBuildMenu.onWoodenFloor = function(worldobjects, square, sprite)
	-- sprite, northSprite
	local foor = ISWoodenFloor:new(sprite.sprite, sprite.northSprite)
	foor.modData["need:Base.Plank"] = "1";
	foor.modData["need:Base.Nails"] = "1";
	getCell():setDrag(foor);
end

ISBuildMenu.onWoodenBrownFloor = function(worldobjects, square)
	-- sprite, northSprite
	local foor = ISWoodenFloor:new("TileFloorInt_24", "TileFloorInt_24")
	foor.modData["need:Base.Plank"] = "1";
	foor.modData["need:Base.Nails"] = "1";
	getCell():setDrag(foor);
end

ISBuildMenu.onWoodenLightBrownFloor = function(worldobjects, square)
	-- sprite, northSprite
	local foor = ISWoodenFloor:new("TileFloorInt_6", "TileFloorInt_6")
	foor.modData["need:Base.Plank"] = "1";
	foor.modData["need:Base.Nails"] = "1";
	getCell():setDrag(foor);
end

-- **********************************************
-- **               *CONTAINER*                **
-- **********************************************

ISBuildMenu.buildContainerMenu = function(subMenu, player)
    local crateSprite = ISBuildMenu.getWoodenCrateSprites(player);
	local crateOption = subMenu:addOption(getText("ContextMenu_Wooden_Crate"), worldobjects, ISBuildMenu.onWoodenCrate, square, crateSprite);
	local toolTip = ISBuildMenu.canBuild(2,2,0,0,0,1,crateOption, player);
	toolTip:setName(getText("ContextMenu_Wooden_Crate"));
	toolTip.description = getText("Tooltip_craft_woodenCrateDesc") .. toolTip.description;
	toolTip:setTexture(crateSprite.sprite);
end

ISBuildMenu.onWoodenCrate = function(worldobjects, square, crateSprite)
	-- sprite, northSprite
	local crate = ISWoodenContainer:new(crateSprite.sprite, crateSprite.northSprite);
	crate.renderFloorHelper = true
	crate.canBeAlwaysPlaced = true;
	crate.modData["need:Base.Plank"] = "2";
	crate.modData["need:Base.Nails"] = "2";
	crate:setEastSprite(crateSprite.eastSprite);
	getCell():setDrag(crate);
end

-- **********************************************
-- **              *FURNITURE*                 **
-- **********************************************

ISBuildMenu.buildFurnitureMenu = function(subMenu, context, player)
	-- add the table submenu
	local tableOption = subMenu:addOption(getText("ContextMenu_Table"), worldobjects, nil);
	local subMenuTable = subMenu:getNew(subMenu);
	context:addSubMenu(tableOption, subMenuTable);

	-- add all our table option
	local tableSprite = ISBuildMenu.getWoodenTableSprites(player);
	local smallTableOption = subMenuTable:addOption(getText("ContextMenu_Small_Table"), worldobjects, ISBuildMenu.onSmallWoodTable, square, tableSprite);
	local tooltip = ISBuildMenu.canBuild(5,4,0,0,0,0,smallTableOption, player);
	tooltip:setName(getText("ContextMenu_Small_Table"));
	tooltip.description = getText("Tooltip_craft_smallTableDesc") .. tooltip.description;
	tooltip:setTexture(tableSprite.sprite);

	local largeTableSprite = ISBuildMenu.getLargeWoodTableSprites(player);
	local largeTableOption = subMenuTable:addOption(getText("ContextMenu_Large_Table"), worldobjects, ISBuildMenu.onLargeWoodTable, square, largeTableSprite);
	local tooltip2 = ISBuildMenu.canBuild(6,4,0,0,0,0,largeTableOption, player);
	tooltip2:setName(getText("ContextMenu_Large_Table"));
	tooltip2.description = getText("Tooltip_craft_largeTableDesc") .. tooltip2.description;
	tooltip2:setTexture(largeTableSprite.sprite1);

	local drawerSprite = ISBuildMenu.getTableWithDrawerSprites(player);
	local drawerTableOption = subMenuTable:addOption(getText("ContextMenu_Table_with_Drawer"), worldobjects, ISBuildMenu.onSmallWoodTableWithDrawer, square, drawerSprite);
	local tooltip3 = ISBuildMenu.canBuild(5,4,0,0,0,1,drawerTableOption, player);
	-- we add that we need a Drawer too
	if not getSpecificPlayer(player):getInventory():contains("Drawer") and not ISBuildMenu.cheat then
		tooltip3.description = tooltip3.description .. " <RGB:1,0,0>" .. getItemText("Drawer") .. " 0/1 <LINE>";
		drawerTableOption.onSelect = nil;
		drawerTableOption.notAvailable = true;
	else
		tooltip3.description = tooltip3.description .. " <RGB:1,1,1>" .. getItemText("Drawer") .. " 1 <LINE>";
	end
	tooltip3:setName(getText("ContextMenu_Table_with_Drawer"));
	tooltip3.description = getText("Tooltip_craft_tableDrawerDesc") .. tooltip3.description;
	tooltip3:setTexture(drawerSprite.sprite);

	-- now the chair
	local chairSprite = ISBuildMenu.getWoodenChairSprites(player);
	local chairOption = subMenu:addOption(getText("ContextMenu_Wooden_Chair"), worldobjects, ISBuildMenu.onWoodChair, square, chairSprite);
	local tooltip4 = ISBuildMenu.canBuild(5,4,0,0,0,0,chairOption, player);
	tooltip4:setName(getText("ContextMenu_Wooden_Chair"));
	tooltip4.description = getText("Tooltip_craft_woodenChairDesc") .. tooltip4.description;
	tooltip4:setTexture(chairSprite.sprite);

	-- rain collector barrel
	local barrelOption = subMenu:addOption(getText("ContextMenu_Rain_Collector_Barrel"), worldobjects, ISBuildMenu.onCreateBarrel, player, "carpentry_02_54", 40);
	local tooltip = ISBuildMenu.canBuild(4,4,0,0,0,2,barrelOption, player);
    -- we add that we need 4 garbage bag too
    if getSpecificPlayer(player):getInventory():getItemCount("Base.Garbagebag") < 3 and not ISBuildMenu.cheat then
        tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. getItemText("Garbage Bag") .. " " .. getSpecificPlayer(player):getInventory():getItemCount("Base.Garbagebag") .. "/4 ";
        barrelOption.onSelect = nil;
        barrelOption.notAvailable = true;
    else
        tooltip.description = tooltip.description .. " <RGB:1,1,1>" .. getItemText("Garbage Bag") .. " 4 ";
    end
	tooltip:setName(getText("ContextMenu_Rain_Collector_Barrel"));
	tooltip.description = getText("Tooltip_craft_rainBarrelDesc") .. tooltip.description;
	tooltip:setTexture("carpentry_02_54");

    -- rain collector barrel
    local barrel2Option = subMenu:addOption(getText("ContextMenu_Rain_Collector_Barrel"), worldobjects, ISBuildMenu.onCreateBarrel, player, "carpentry_02_52", 100);
    local tooltip = ISBuildMenu.canBuild(4,4,0,0,0,4,barrel2Option, player);
    -- we add that we need 4 garbage bag too
    if getSpecificPlayer(player):getInventory():getItemCount("Base.Garbagebag") < 3 and not ISBuildMenu.cheat then
        tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. getItemText("Garbage Bag") .. " " .. getSpecificPlayer(player):getInventory():getItemCount("Base.Garbagebag") .. "/4 ";
        barrel2Option.onSelect = nil;
        barrel2Option.notAvailable = true;
    else
        tooltip.description = tooltip.description .. " <RGB:1,1,1>" .. getItemText("Garbage Bag") .. " 4 ";
    end
    tooltip:setName(getText("ContextMenu_Rain_Collector_Barrel"));
    tooltip.description = getText("Tooltip_craft_rainBarrelDesc") .. tooltip.description;
    tooltip:setTexture("carpentry_02_52");
end

-- create a new barrel to drag a ghost render of the barrel under the mouse
ISBuildMenu.onCreateBarrel = function(worldobjects, player, sprite, waterMax)
	local barrel = RainCollectorBarrel:new(player, sprite, waterMax);
	-- we now set his the mod data the needed material
	-- by doing this, all will be automatically consummed, drop on the ground if destoryed etc.
	barrel.modData["need:Base.Plank"] = "4";
	barrel.modData["need:Base.Nails"] = "4";
    barrel.modData["need:Base.Garbagebag"] = "4";
	-- and now allow the item to be dragged by mouse
	getCell():setDrag(barrel);
end

ISBuildMenu.onSmallWoodTable = function(worldobjects, square, sprite)
	-- name, sprite, northSprite
	local furniture = ISSimpleFurniture:new("Small table", sprite.sprite, sprite.sprite);
	furniture.modData["need:Base.Plank"] = "5";
	furniture.modData["need:Base.Nails"] = "4";
	getCell():setDrag(furniture);
end

ISBuildMenu.onSmallWoodTableWithDrawer = function(worldobjects, square, sprite)
	-- name, sprite, northSprite
	local furniture = ISSimpleFurniture:new("Small table with drawer", sprite.sprite, sprite.northSprite);
	furniture.modData["need:Base.Plank"] = "5";
	furniture.modData["need:Base.Nails"] = "4";
	furniture.modData["need:Base.Drawer"] = "1";
	furniture:setEastSprite(sprite.eastSprite);
	furniture:setSouthSprite(sprite.southSprite);
	furniture.isContainer = true;
	getCell():setDrag(furniture);
end

ISBuildMenu.onLargeWoodTable = function(worldobjects, square, sprite)
	-- name, sprite, northSprite
	local furniture = ISDoubleTileFurniture:new("Large simple table", sprite.sprite1, sprite.sprite2, sprite.northSprite1, sprite.northSprite2);
	furniture.modData["need:Base.Plank"] = "6";
	furniture.modData["need:Base.Nails"] = "4";
	getCell():setDrag(furniture);
end

ISBuildMenu.onWoodChair = function(worldobjects, square, sprite)
	-- name, sprite, northSprite
	local furniture = ISSimpleFurniture:new("Simple chair", sprite.sprite, sprite.northSprite);
	furniture.modData["need:Base.Plank"] = "5";
	furniture.modData["need:Base.Nails"] = "4";
	-- our chair have 4 tiles (north, east, south and west)
	-- then we define our east and south sprite
	furniture:setEastSprite(sprite.eastSprite);
	furniture:setSouthSprite(sprite.southSprite);
	furniture.canPassThrough = true;
	getCell():setDrag(furniture);
end

-- **********************************************
-- **                 *STAIRS*                 **
-- **********************************************

ISBuildMenu.buildStairsMenu = function(subMenu, player)
	local darkStairsOption = subMenu:addOption(getText("ContextMenu_Dark_Wooden_Stairs"), worldobjects, ISBuildMenu.onDarkWoodenStairs, square);
	local tooltip = ISBuildMenu.canBuild(8,8,0,0,0,3,darkStairsOption, player);
	tooltip:setName(getText("ContextMenu_Dark_Wooden_Stairs"));
	tooltip.description = getText("Tooltip_craft_stairsDesc") .. tooltip.description;
	tooltip:setTexture("fixtures_stairs_01_16");

	local stairsOption = subMenu:addOption(getText("ContextMenu_Brown_Wooden_Stairs"), worldobjects, ISBuildMenu.onBrownWoodenStairs, square);
	local tooltip2 = ISBuildMenu.canBuild(8,8,0,0,0,3,stairsOption, player);
	tooltip2:setName(getText("ContextMenu_Brown_Wooden_Stairs"));
	tooltip2.description = getText("Tooltip_craft_stairsDesc") .. tooltip2.description;
	tooltip2:setTexture("fixtures_stairs_01_19");

	local lightStairsOption = subMenu:addOption(getText("ContextMenu_Light_Brown_Wooden_Stairs"), worldobjects, ISBuildMenu.onLightBrownWoodenStairs, square);
	local tooltip3 = ISBuildMenu.canBuild(8,8,0,0,0,3,lightStairsOption, player);
	tooltip3:setName(getText("ContextMenu_Light_Brown_Wooden_Stairs"));
	tooltip3.description = getText("Tooltip_craft_stairsDesc") .. tooltip3.description;
	tooltip3:setTexture("fixtures_stairs_01_32");
end

ISBuildMenu.onDarkWoodenStairs = function(worldobjects, square)
	local stairs = ISWoodenStairs:new("fixtures_stairs_01_16", "fixtures_stairs_01_17", "fixtures_stairs_01_18", "fixtures_stairs_01_24", "fixtures_stairs_01_25", "fixtures_stairs_01_26", "fixtures_stairs_01_22", "fixtures_stairs_01_23");
	stairs.modData["need:Base.Plank"] = "8";
	stairs.modData["need:Base.Nails"] = "8";
    stairs.isThumpable = false;
	getCell():setDrag(stairs);
end

ISBuildMenu.onBrownWoodenStairs = function(worldobjects, square)
    local stairs = ISWoodenStairs:new("fixtures_stairs_01_19", "fixtures_stairs_01_20", "fixtures_stairs_01_21", "fixtures_stairs_01_27", "fixtures_stairs_01_28", "fixtures_stairs_01_29", "fixtures_stairs_01_30", "fixtures_stairs_01_31");
    stairs.modData["need:Base.Plank"] = "8";
    stairs.modData["need:Base.Nails"] = "8";
    getCell():setDrag(stairs);
end

ISBuildMenu.onLightBrownWoodenStairs = function(worldobjects, square)
    local stairs = ISWoodenStairs:new("fixtures_stairs_01_32", "fixtures_stairs_01_33", "fixtures_stairs_01_34", "fixtures_stairs_01_40", "fixtures_stairs_01_41", "fixtures_stairs_01_42", "fixtures_stairs_01_38", "fixtures_stairs_01_39");
    stairs.modData["need:Base.Plank"] = "8";
	stairs.modData["need:Base.Nails"] = "8";
	getCell():setDrag(stairs);
end

-- **********************************************
-- **                 *DOOR*                   **
-- **********************************************

ISBuildMenu.buildDoorMenu = function(subMenu, player)
	local sprite = ISBuildMenu.getWoodenDoorSprites(player);
	local doorsOption = subMenu:addOption(getText("ContextMenu_Wooden_Door"), worldobjects, ISBuildMenu.onWoodenDoor, square, sprite);
	local tooltip = ISBuildMenu.canBuild(4,4,2,1,0,0,doorsOption, player);
	tooltip:setName(getText("ContextMenu_Wooden_Door"));
	tooltip.description = getText("Tooltip_craft_woodenDoorDesc") .. tooltip.description;
	tooltip:setTexture(sprite.sprite);

--~ 	local farmdoorsOption = subMenu:addOption("Farm Door", worldobjects, ISBuildMenu.onFarmDoor, square);
--~ 	local tooltip2 = ISBuildMenu.canBuild(4,4,2,1,0,1,farmdoorsOption);
--~ 	tooltip2:setName("Farm Door");
--~ 	tooltip2.description = "A farm door, has to be placed in a door frame " .. tooltip2.description;
--~ 	tooltip2:setTexture("TileDoors_8");
end

ISBuildMenu.onWoodenDoor = function(worldobjects, square, sprite)
	-- sprite, northsprite, openSprite, openNorthSprite
	local door = ISWoodenDoor:new(sprite.sprite, sprite.northSprite, sprite.openSprite, sprite.openNorthSprite);
	door.modData["need:Base.Plank"] = "4";
	door.modData["need:Base.Nails"] = "4";
	door.modData["need:Base.Hinge"] = "2";
	door.modData["need:Base.Doorknob"] = "1";
	getCell():setDrag(door);
end

ISBuildMenu.onFarmDoor = function(worldobjects, square)
	-- sprite, northsprite, openSprite, openNorthSprite
	getCell():setDrag(ISWoodenDoor:new("TileDoors_8", "TileDoors_9", "TileDoors_10", "TileDoors_11"));
end

-- **********************************************
-- **              *DOOR FRAME*                **
-- **********************************************

ISBuildMenu.buildDoorFrameMenu = function(subMenu, player)
	local frameSprite = ISBuildMenu.getWoodenDoorFrameSprites(player);
	local doorFrameOption = subMenu:addOption(getText("ContextMenu_Door_Frame"), worldobjects, ISBuildMenu.onWoodenDoorFrame, square, frameSprite);
	local tooltip = ISBuildMenu.canBuild(4,4,0,0,0,0,doorFrameOption, player);
	tooltip:setName(getText("ContextMenu_Door_Frame"));
	tooltip.description = getText("Tooltip_craft_doorFrameDesc") .. tooltip.description;
	tooltip:setTexture(frameSprite.sprite);
end

ISBuildMenu.onWoodenDoorFrame = function(worldobjects, square, sprite)
	-- sprite, northSprite, corner
	local doorFrame = ISWoodenDoorFrame:new(sprite.sprite, sprite.northSprite, sprite.corner)
	doorFrame.canBePlastered = true;
    doorFrame.modData["wallType"] = "doorframe";
	doorFrame.modData["need:Base.Plank"] = "4";
	doorFrame.modData["need:Base.Nails"] = "4";
	getCell():setDrag(doorFrame);
end

-- **********************************************
-- **            SPRITE FUNCTIONS              **
-- **********************************************

ISBuildMenu.getLargeWoodTableSprites = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite1 = "carpentry_01_25";
		sprite.sprite2 = "carpentry_01_24";
		sprite.northSprite1 = "carpentry_01_26";
		sprite.northSprite2 = "carpentry_01_27";
	elseif spriteLvl == 2 then
		sprite.sprite1 = "carpentry_01_29";
		sprite.sprite2 = "carpentry_01_28";
		sprite.northSprite1 = "carpentry_01_30";
		sprite.northSprite2 = "carpentry_01_31";
	else
		sprite.sprite1 = "carpentry_01_33";
		sprite.sprite2 = "carpentry_01_32";
		sprite.northSprite1 = "carpentry_01_34";
		sprite.northSprite2 = "carpentry_01_35";
	end
	return sprite;
end

ISBuildMenu.getTableWithDrawerSprites = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "carpentry_02_0";
		sprite.northSprite = "carpentry_02_2";
		sprite.southSprite = "carpentry_02_1";
		sprite.eastSprite = "carpentry_02_3";
	elseif spriteLvl == 2 then
		sprite.sprite = "carpentry_02_4";
		sprite.northSprite = "carpentry_02_6";
		sprite.southSprite = "carpentry_02_5";
		sprite.eastSprite = "carpentry_02_7";
	else
		sprite.sprite = "carpentry_02_8";
		sprite.northSprite = "carpentry_02_10";
		sprite.southSprite = "carpentry_02_9";
		sprite.eastSprite = "carpentry_02_11";
	end
	return sprite;
end

ISBuildMenu.getWoodenFenceSprites = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "carpentry_02_40";
		sprite.northSprite = "carpentry_02_41";
		sprite.corner = "carpentry_02_43";
	elseif spriteLvl == 2 then
		sprite.sprite = "carpentry_02_44";
		sprite.northSprite = "carpentry_02_45";
		sprite.corner = "carpentry_02_47";
	else
		sprite.sprite = "carpentry_02_48";
		sprite.northSprite = "carpentry_02_49";
		sprite.corner = "carpentry_02_51";
	end
	return sprite;
end

ISBuildMenu.getWoodenFloorSprites = function(player)
    local spriteLvl = ISBuildMenu.getSpriteLvl(player);
    local sprite = {};
    if spriteLvl == 1 then
        sprite.sprite = "carpentry_02_58";
        sprite.northSprite = "carpentry_02_58";
    elseif spriteLvl == 2 then
        sprite.sprite = "carpentry_02_57";
        sprite.northSprite = "carpentry_02_57";
    else
        sprite.sprite = "carpentry_02_56";
        sprite.northSprite = "carpentry_02_56";
    end
    return sprite;
end

ISBuildMenu.getWoodenCrateSprites = function(player)
    local spriteLvl = ISBuildMenu.getSpriteLvl(player);
    local sprite = {};
    if spriteLvl <= 2 then
        sprite.sprite = "carpentry_01_19";
        sprite.northSprite = "carpentry_01_20";
        sprite.eastSprite = "carpentry_01_21";
    else
        sprite.sprite = "carpentry_01_16";
        sprite.northSprite = "carpentry_01_17";
        sprite.eastSprite = "carpentry_01_18";
    end
    return sprite;
end

ISBuildMenu.getWoodenChairSprites = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "carpentry_01_36";
		sprite.northSprite = "carpentry_01_38";
		sprite.southSprite = "carpentry_01_39";
		sprite.eastSprite = "carpentry_01_37";
	elseif spriteLvl == 2 then
		sprite.sprite = "carpentry_01_40";
		sprite.northSprite = "carpentry_01_42";
		sprite.southSprite = "carpentry_01_41";
		sprite.eastSprite = "carpentry_01_43";
	else
		sprite.sprite = "carpentry_01_45";
		sprite.northSprite = "carpentry_01_44";
		sprite.southSprite = "carpentry_01_46";
		sprite.eastSprite = "carpentry_01_47";
	end
	return sprite;
end

ISBuildMenu.getWoodenDoorSprites = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "carpentry_01_48";
		sprite.northSprite = "carpentry_01_49";
		sprite.openSprite = "carpentry_01_50";
		sprite.openNorthSprite = "carpentry_01_51";
	elseif spriteLvl == 2 then
		sprite.sprite = "carpentry_01_52";
		sprite.northSprite = "carpentry_01_53";
		sprite.openSprite = "carpentry_01_54";
		sprite.openNorthSprite = "carpentry_01_55";
	else
		sprite.sprite = "carpentry_01_56";
		sprite.northSprite = "carpentry_01_57";
		sprite.openSprite = "carpentry_01_58";
		sprite.openNorthSprite = "carpentry_01_59";
	end
	return sprite;
end

ISBuildMenu.getWoodenTableSprites = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "carpentry_01_60";
	elseif spriteLvl == 2 then
		sprite.sprite = "carpentry_01_61";
	else
		sprite.sprite = "carpentry_01_62";
	end
	return sprite;
end

ISBuildMenu.getPillarLampSprite = function(player)
    local sprite = {};
    sprite.sprite = "carpentry_02_61";
    sprite.northSprite = "carpentry_02_60";
    sprite.southSprite = "carpentry_02_59";
    sprite.eastSprite = "carpentry_02_62";
    return sprite;
end

ISBuildMenu.getWoodenWallSprites = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "walls_exterior_wooden_01_44";
		sprite.northSprite = "walls_exterior_wooden_01_45";
	elseif spriteLvl == 2 then
		sprite.sprite = "walls_exterior_wooden_01_40";
		sprite.northSprite = "walls_exterior_wooden_01_41";
	else
		sprite.sprite = "walls_exterior_wooden_01_24";
		sprite.northSprite = "walls_exterior_wooden_01_25";
	end
	sprite.corner = "walls_exterior_wooden_01_27";
	return sprite;
end

ISBuildMenu.getWoodenWindowsFrameSprites = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "walls_exterior_wooden_01_52";
		sprite.northSprite = "walls_exterior_wooden_01_53";
	elseif spriteLvl == 2 then
		sprite.sprite = "walls_exterior_wooden_01_48";
		sprite.northSprite = "walls_exterior_wooden_01_49";
	else
		sprite.sprite = "walls_exterior_wooden_01_32";
		sprite.northSprite = "walls_exterior_wooden_01_33";
	end
	sprite.corner = "walls_exterior_wooden_01_27";
	return sprite;
end

ISBuildMenu.getWoodenDoorFrameSprites = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "walls_exterior_wooden_01_54";
		sprite.northSprite = "walls_exterior_wooden_01_55";
	elseif spriteLvl == 2 then
		sprite.sprite = "walls_exterior_wooden_01_50";
		sprite.northSprite = "walls_exterior_wooden_01_51";
	else
		sprite.sprite = "walls_exterior_wooden_01_34";
		sprite.northSprite = "walls_exterior_wooden_01_35";
	end
	sprite.corner = "walls_exterior_wooden_01_27";
	return sprite;
end

ISBuildMenu.getBarCornerSprites = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "carpentry_02_32";
		sprite.northSprite = "carpentry_02_34";
		sprite.southSprite = "carpentry_02_36";
		sprite.eastSprite = "carpentry_02_38";
	elseif spriteLvl == 2 then
		sprite.sprite = "carpentry_02_24";
		sprite.northSprite = "carpentry_02_26";
		sprite.southSprite = "carpentry_02_28";
		sprite.eastSprite = "carpentry_02_30";
	else
		sprite.sprite = "carpentry_02_16";
		sprite.northSprite = "carpentry_02_18";
		sprite.southSprite = "carpentry_02_20";
		sprite.eastSprite = "carpentry_02_22";
	end
	return sprite;
end

ISBuildMenu.getBarElementSprites = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "carpentry_02_33";
		sprite.northSprite = "carpentry_02_35";
		sprite.southSprite = "carpentry_02_37";
		sprite.eastSprite = "carpentry_02_39";
	elseif spriteLvl == 2 then
		sprite.sprite = "carpentry_02_25";
		sprite.northSprite = "carpentry_02_27";
		sprite.southSprite = "carpentry_02_29";
		sprite.eastSprite = "carpentry_02_31";
	else
		sprite.sprite = "carpentry_02_17";
		sprite.northSprite = "carpentry_02_19";
		sprite.southSprite = "carpentry_02_21";
		sprite.eastSprite = "carpentry_02_23";
	end
	return sprite;
end

ISBuildMenu.getSpriteLvl = function(player)
	-- 0 to 1 wood work xp mean lvl 1 sprite
	if getSpecificPlayer(player):getPerkLevel(Perks.Woodwork) <= 1 then
		return 1;
	-- 2 to 3 wood work xp mean lvl 2 sprite
	elseif getSpecificPlayer(player):getPerkLevel(Perks.Woodwork) <= 3 then
		return 2;
	-- 4 to 5 wood work xp mean lvl 3 sprite
	else
		return 3;
	end
end

-- **********************************************
-- **                DISMANTLE                 **
-- **********************************************

ISBuildMenu.onDismantle = function(worldobjects, thumpable, player)
	ISBuildingObject.onDestroy(thumpable, player);
	ISBuildingObject.removeFromGround(thumpable:getSquare());
end

-- **********************************************
-- **                  OTHER                   **
-- **********************************************

-- Create our toolTip, depending on the required material
ISBuildMenu.canBuild = function(plankNb, nailsNb, hingeNb, doorknobNb, baredWireNb, carpentrySkill, option, player)
	-- create a new tooltip
	local tooltip = ISBuildMenu.addToolTip();
	-- add it to our current option
	option.toolTip = tooltip;
	local result = true;
	if ISBuildMenu.cheat then
		return tooltip;
	end
	tooltip.description = "<LINE> <LINE>" .. getText("Tooltip_craft_Needs") .. " : <LINE>";
	-- now we gonna test all the needed material, if we don't have it, they'll be in red into our toolip
	if ISBuildMenu.planks < plankNb then
		tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. getItemText("Plank") .. " " .. ISBuildMenu.planks .. "/" .. plankNb .. " <LINE>";
		result = false;
	elseif plankNb > 0 then
		tooltip.description = tooltip.description .. " <RGB:1,1,1>" .. getItemText("Plank") .. " " .. plankNb .. " <LINE>";
	end
	if ISBuildMenu.nails < nailsNb then
		tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. getItemText("Nails") .. " " .. ISBuildMenu.nails .. "/" .. nailsNb .. " <LINE>";
		result = false;
	elseif nailsNb > 0 then
		tooltip.description = tooltip.description .. " <RGB:1,1,1>" .. getItemText("Nails") .. " " .. nailsNb .. " <LINE>";
	end
	if ISBuildMenu.doorknob < doorknobNb then
		tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. getItemText("Doorknob") .. " " .. ISBuildMenu.doorknob .. "/" .. doorknobNb .. " <LINE>";
		result = false;
	elseif doorknobNb > 0 then
		tooltip.description = tooltip.description .. " <RGB:1,1,1>" .. getItemText("Doorknob") .. " " .. doorknobNb .. " <LINE>";
	end
	if ISBuildMenu.hinge < hingeNb then
		tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. getItemText("Door Hinge") .. " " .. ISBuildMenu.hinge .. "/" .. hingeNb .. " <LINE>";
		result = false;
	elseif hingeNb > 0 then
		tooltip.description = tooltip.description .. " <RGB:1,1,1>" .. getItemText("Door Hinge") .. " " .. hingeNb .. " <LINE>";
	end
	if getSpecificPlayer(player):getPerkLevel(Perks.Woodwork) < carpentrySkill then
		tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. getText("IGUI_perks_Carpentry") .. " " .. getSpecificPlayer(player):getPerkLevel(Perks.Woodwork) .. "/" .. carpentrySkill .. " <LINE>";
		result = false;
	elseif carpentrySkill > 0 then
		tooltip.description = tooltip.description .. " <RGB:1,1,1>" .. getText("IGUI_perks_Carpentry") .. " " .. carpentrySkill .. " <LINE>";
	end
	if not result then
		option.onSelect = nil;
		option.notAvailable = true;
	end
	return tooltip;
end

ISBuildMenu.addToolTip = function()
	local toolTip = ISToolTip:new();
	toolTip:initialise();
	toolTip:setVisible(false);
	return toolTip;
end


Events.OnFillWorldObjectContextMenu.Add(ISBuildMenu.doBuildMenu);
