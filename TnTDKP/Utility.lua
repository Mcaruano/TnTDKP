local TAG = "Utility.lua"

function CEPGP_initialise()
	if CEPGP_debugMode then print(format("[%s]: CEPGP_initialise() called", TAG)) end	

	-- Set the global boolean to True if we are running ElvUI. This is used
	-- when determining the anchor point for one of the buttons
	_, _, _, CEPGP_ElvUI = GetAddOnInfo("ElvUI");

	if not STANDBYEP then
		STANDBYEP = true
	end
	if not STANDBYOFFLINE then
		STANDBYOFFLINE = true
	end
	if not CEPGP_standby_whisper_msg or CEPGP_standby_whisper_msg == "" then
		CEPGP_standby_whisper_msg = "!standby"
	end
	if STANDBYPERCENT ==  nil then
		STANDBYPERCENT = 100;
	end
	if TnTDKP_priority_recipients == nil then
		TnTDKP_priority_recipients = {}
	end
	if TnTDKP_lottery_participants == nil then
		TnTDKP_lottery_participants = {}
	end
	if PLAYER_PRIORITY_REGISTRY == nil then
		PLAYER_PRIORITY_REGISTRY = {}
	end
	if PLAYER_LOTTERY_REGISTRY == nil then
		PLAYER_LOTTERY_REGISTRY = {}
	end
	if T6PT5_PRIORITY_DKP_TABLE == nil then
		T6PT5_PRIORITY_DKP_TABLE = {}
	end
	if T6PT5_LOTTERY_DKP_TABLE == nil then
		T6PT5_LOTTERY_DKP_TABLE = {}
	end
	if T6_PRIORITY_DKP_TABLE == nil then
		T6_PRIORITY_DKP_TABLE = {}
	end
	if T6_LOTTERY_DKP_TABLE == nil then
		T6_LOTTERY_DKP_TABLE = {}
	end
	if T5_PRIORITY_DKP_TABLE == nil then
		T5_PRIORITY_DKP_TABLE = {}
	end
	if T5_LOTTERY_DKP_TABLE == nil then
		T5_LOTTERY_DKP_TABLE = {}
	end
	if T4_PRIORITY_DKP_TABLE == nil then
		T4_PRIORITY_DKP_TABLE = {}
	end
	if T4_LOTTERY_DKP_TABLE == nil then
		T4_LOTTERY_DKP_TABLE = {}
	end
	if T6PT5_PRIORITY_TRANSACTIONS == nil then
		T6PT5_PRIORITY_TRANSACTIONS = {}
	end
	if T6PT5_LOTTERY_TRANSACTIONS == nil then
		T6PT5_LOTTERY_TRANSACTIONS = {}
	end
	if T6_PRIORITY_TRANSACTIONS == nil then
		T6_PRIORITY_TRANSACTIONS = {}
	end
	if T6_LOTTERY_TRANSACTIONS == nil then
		T6_LOTTERY_TRANSACTIONS = {}
	end
	if T5_PRIORITY_TRANSACTIONS == nil then
		T5_PRIORITY_TRANSACTIONS = {}
	end
	if T5_LOTTERY_TRANSACTIONS == nil then
		T5_LOTTERY_TRANSACTIONS = {}
	end
	if T4_PRIORITY_TRANSACTIONS == nil then
		T4_PRIORITY_TRANSACTIONS = {}
	end
	if T4_LOTTERY_TRANSACTIONS == nil then
		T4_LOTTERY_TRANSACTIONS = {}
	end
	if T6PT5_OPEN_TRANSACTIONS == nil then
		T6PT5_OPEN_TRANSACTIONS = {}
	end
	if T6_OPEN_TRANSACTIONS == nil then
		T6_OPEN_TRANSACTIONS = {}
	end
	if T5_OPEN_TRANSACTIONS == nil then
		T5_OPEN_TRANSACTIONS = {}
	end
	if T4_OPEN_TRANSACTIONS == nil then
		T4_OPEN_TRANSACTIONS = {}
	end
	if PLAYER_ROLE_CONFIG == nil then
		PLAYER_ROLE_CONFIG = {}
	end
	if STANDBY_ROSTER == nil then
		STANDBY_ROSTER = {}
	end

	-- If we're in a raid group, initialize the CEPGP_raidRosterAndRelatedMetadata table
	if UnitInRaid("player") then
		CEPGP_UpdateRaidScrollBar()
	end
	
	tinsert(UISpecialFrames, "CEPGP_frame");
	tinsert(UISpecialFrames, "CEPGP_context_popup");
	tinsert(UISpecialFrames, "CEPGP_traffic");
end

-- This logic populates whichever frame in accordance with CEPGP_mode. This is the kick-off logic that
-- saturates either the Guild frame, Raid frame, or LootFrame.
-- In the case of CEPGP_mode = "loot", the "items" table that gets passed in here comes from CEPGP_LootFrame_Update()
-- and has all of the item data from the blizzard LootFrame as well as some extra metadata.
-- The variables here are only passed in via the CEPGP_LootFrame_Update() flow, and are as follows:
-- CEPGP_criteria - Which field to sort the frame by before saturating it. This is currently unused, but can be easily leveraged if desired
-- items - The Table of items to display in the loot frame, together with a huge payload of metadata about each one
-- lootNum - The number of items to display. I believe in my refactor this is always the same as CEPGP_ntgetn(items)
-- shouldPrintLootToRaid - True if we should print the loot drops to the Raid. This is necessary because this method gets spammed
--                         many times during the distribution of loot, so without this control the loot would just get constantly
--                         spammed to the raid during distribution.
function CEPGP_populateFrame(CEPGP_criteria, items, lootNum, shouldPrintLootToRaid)
	local sorting = nil;
	local subframe = nil;
	if CEPGP_criteria == "name" or CEPGP_criteria == "rank" then
		SortGuildRoster(CEPGP_criteria);
	elseif CEPGP_criteria == "group" or CEPGP_criteria == "EP" or CEPGP_criteria == "GP" or CEPGP_criteria == "PR" then
		sorting = CEPGP_criteria;
	else
		sorting = "group";
	end

	-- If we're calling populateFrame in Loot Distribution mode, we need to clear the table first
	if CEPGP_mode == "loot" then
		CEPGP_cleanTable();
	elseif CEPGP_mode ~= "loot" then
		CEPGP_cleanTable();
	end
	local tempItems = {};
	local total;
	if CEPGP_mode == "guild" then
		CEPGP_UpdateAllMembersScrollBar();
	elseif CEPGP_mode == "raid" then
		CEPGP_UpdateRaidScrollBar();
	elseif CEPGP_mode == "loot" then
		subframe = CEPGP_loot;
		local count = 0;
		if not items then
			total = 0;
		else
			local i = 1;
			local nils = 0;
			for index,value in pairs(items) do 
				tempItems[i] = value;
				i = i + 1;
				count = count + 1;
			end
			local critReverse_snapshot = CEPGP_critReverse
			CEPGP_critReverse = true
			tempItems = CEPGP_tSort(tempItems, 8)
			CEPGP_critReverse = critReverse_snapshot
		end
		total = count;
	end

	if CEPGP_mode == "loot" then 
		TnTDKP_updateRaidRosterTable()
		if shouldPrintLootToRaid and total ~= 0 then
			-- Do an initial "quick" iteration over the items to print the statement of what dropped
			SendChatMessage("==============================", "RAID", CEPGP_LANGUAGE);
			SendChatMessage("LOOT: ", "RAID", CEPGP_LANGUAGE);
			for i = 1, total do
				-- TODO: If the "tempItems = CEPGP_tSort(tempItems, 8)" line above fixes the issue with loot being out of order, then I can delete this entire block
				--
				-- local timeDelay = 0.3 + (i * 0.2) -- A race condition can occur if we try to print everything out instantly. We need to force a delay to prevent that
				-- local delayedFrame = CreateFrame("Frame")
				-- delayedFrame:Hide()
				-- delayedFrame:SetScript("OnShow", function(self)
				-- 	self.time = timeDelay
				-- end)
				-- delayedFrame:SetScript("OnUpdate", function(self, elapsed)
				-- 	self.time = self.time - elapsed
				-- 	if self.time <= 0 then
				-- 		self:Hide()
				-- 		SendChatMessage(format("  %d.) " .. tempItems[i][4] .. " (itemID: %s)", i, tempItems[i][8]), "RAID", CEPGP_LANGUAGE);
				-- 	end
				-- end)
				-- delayedFrame:Show()
				SendChatMessage(format("  %d.) " .. tempItems[i][4] .. " (itemID: %s)", i, tempItems[i][8]), "RAID", CEPGP_LANGUAGE);
			end
		end
		

		for i = 1, total do
			local texture, name, quality, dkp, colour, iString, link, slot, x, quantity, itemID, distMethod;
			x = i;
			texture = tempItems[i][1];
			name = tempItems[i][2];
			colour = ITEM_QUALITY_COLORS[tempItems[i][3]];
			link = tempItems[i][4];
			iString = tempItems[i][5];
			slot = tempItems[i][6]; -- This is actually the "slot" that the item is in on the boss' loot table
			quantity = tempItems[i][7];
			itemID = tempItems[i][8];
			dkp = tempItems[i][9];
			distMethod = tempItems[i][10]

			-- If an object already exists, we just repurpose it by inserting the new values
			if _G[CEPGP_mode..'item'..i] ~= nil then
				_G[CEPGP_mode..'announce'..i]:Show();
				_G[CEPGP_mode..'announce'..i]:SetWidth(70);
				_G[CEPGP_mode..'announce'..i]:SetText(distMethod);
				_G[CEPGP_mode..'announce'..i]:SetScript('OnClick', function() 
					TnTDKP_execute_winner_determination_logic_and_announce(itemID, distMethod, link, slot)
				end);
				_G[CEPGP_mode..'announce'..i]:SetID(slot);
				
				_G[CEPGP_mode..'icon'..i]:Show();
				_G[CEPGP_mode..'icon'..i]:SetScript('OnEnter', function() GameTooltip:SetOwner(_G[CEPGP_mode..'icon'..i], "ANCHOR_BOTTOMLEFT") GameTooltip:SetHyperlink(iString) GameTooltip:Show() end);
				_G[CEPGP_mode..'icon'..i]:SetScript('OnLeave', function() GameTooltip:Hide() end);
				
				_G[CEPGP_mode..'texture'..i]:Show();
				_G[CEPGP_mode..'texture'..i]:SetTexture(texture);
				
				_G[CEPGP_mode..'item'..i]:Show();
				_G[CEPGP_mode..'item'..i].text:SetText(link);
				_G[CEPGP_mode..'item'..i].text:SetTextColor(colour.r, colour.g, colour.b);
				_G[CEPGP_mode..'item'..i].text:SetPoint('CENTER',_G[CEPGP_mode..'item'..i]);
				_G[CEPGP_mode..'item'..i]:SetWidth(_G[CEPGP_mode..'item'..i].text:GetStringWidth());
				_G[CEPGP_mode..'item'..i]:SetScript('OnClick', function() SetItemRef(link, iString) end);

				_G[CEPGP_mode..'slotNumber'..i]:Show();
				_G[CEPGP_mode..'slotNumber'..i].text:SetText(slot);
				_G[CEPGP_mode..'slotNumber'..i].text:SetTextColor(colour.r, colour.g, colour.b);
				_G[CEPGP_mode..'slotNumber'..i].text:SetPoint('CENTER',_G[CEPGP_mode..'slotNumber'..i]);
				_G[CEPGP_mode..'slotNumber'..i]:SetWidth(_G[CEPGP_mode..'slotNumber'..i].text:GetStringWidth());
			else
				-- This branch of logic instantiates a new row from scratch. All elements of the row are built out manually
				subframe.announce = CreateFrame('Button', CEPGP_mode..'announce'..i, subframe, 'UIPanelButtonTemplate');
				subframe.announce:SetHeight(20);
				subframe.announce:SetWidth(70);
				subframe.announce:SetText(distMethod);
				subframe.announce:SetScript('OnClick', function() 
					TnTDKP_execute_winner_determination_logic_and_announce(itemID, distMethod, link, slot)
				 end);
				subframe.announce:SetID(slot);
	
				subframe.icon = CreateFrame('Button', CEPGP_mode..'icon'..i, subframe);
				subframe.icon:SetHeight(20);
				subframe.icon:SetWidth(20);
				subframe.icon:SetScript('OnEnter', function() GameTooltip:SetOwner(_G[CEPGP_mode..'icon'..i], "ANCHOR_BOTTOMLEFT") GameTooltip:SetHyperlink(link) GameTooltip:Show() end);
				subframe.icon:SetScript('OnLeave', function() GameTooltip:Hide() end);
				
				local tex = subframe.icon:CreateTexture(CEPGP_mode..'texture'..i, "BACKGROUND");
				tex:SetAllPoints();
				tex:SetTexture(texture);
				
				subframe.itemName = CreateFrame('Button', CEPGP_mode..'item'..i, subframe);
				subframe.itemName:SetHeight(20);

				subframe.slotNumber = CreateFrame('Button', CEPGP_mode..'slotNumber'..i, subframe);
				subframe.slotNumber:SetHeight(20);
				
				if i == 1 then
					subframe.announce:SetPoint('CENTER', _G['CEPGP_'..CEPGP_mode..'_announce'], 'BOTTOM', 0, -20);
					subframe.icon:SetPoint('LEFT', _G[CEPGP_mode..'announce'..i], 'RIGHT', 10, 0);
					tex:SetPoint('LEFT', _G[CEPGP_mode..'announce'..i], 'RIGHT', 10, 0);
					subframe.itemName:SetPoint('LEFT', _G[CEPGP_mode..'icon'..i], 'RIGHT', 10, 0);
					subframe.slotNumber:SetPoint('CENTER', _G['CEPGP_'..CEPGP_mode..'_SlotNum'], 'BOTTOM', 0, -20);
				else
					subframe.announce:SetPoint('CENTER', _G[CEPGP_mode..'announce'..(i-1)], 'BOTTOM', 0, -20);
					subframe.icon:SetPoint('LEFT', _G[CEPGP_mode..'announce'..i], 'RIGHT', 10, 0);
					tex:SetPoint('LEFT', _G[CEPGP_mode..'announce'..i], 'RIGHT', 10, 0);
					subframe.itemName:SetPoint('LEFT', _G[CEPGP_mode..'icon'..i], 'RIGHT', 10, 0);
					subframe.slotNumber:SetPoint('CENTER', _G[CEPGP_mode..'slotNumber'..(i-1)], 'BOTTOM', 0, -20);
				end
				
				subframe.icon:SetScript('OnClick', function() SetItemRef(link, iString) end);
				
				subframe.itemName.text = subframe.itemName:CreateFontString(CEPGP_mode..'EPGP_i'..name..'text', 'OVERLAY', 'GameFontNormal');
				subframe.itemName.text:SetPoint('CENTER', _G[CEPGP_mode..'item'..i]);
				subframe.itemName.text:SetText(link);
				subframe.itemName.text:SetTextColor(colour.r, colour.g, colour.b);
				subframe.itemName:SetWidth(subframe.itemName.text:GetStringWidth());
				subframe.itemName:SetScript('OnClick', function() SetItemRef(link, iString) end);

				subframe.slotNumber.text = subframe.slotNumber:CreateFontString(CEPGP_mode..'SlotNum_i'..name..'text', 'OVERLAY', 'GameFontNormal');
				subframe.slotNumber.text:SetPoint('CENTER', _G[CEPGP_mode..'slotNumber'..i]);
				subframe.slotNumber.text:SetText(slot);
				subframe.slotNumber.text:SetTextColor(colour.r, colour.g, colour.b);
				subframe.slotNumber:SetWidth(subframe.slotNumber.text:GetStringWidth());
			end
		end
	end
end

-- If the given player is on an "alt" as defined in our AltMapConfig, then
-- this method will resolve that player's name to their "main" instead
function TnTDKP_getMainCharacterName(player)
	if CEPGP_tContains(altMapConfig, player, true) then
		return altMapConfig[player]
	end
	return player
end

function CEPGP_strSplit(msgStr, c)
	if not msgStr then
		return nil;
	end
	local table_str = {};
	local capture = string.format("(.-)%s", c);
	
	for v in string.gmatch(msgStr, capture) do
		table.insert(table_str, v);
	end
	
	return unpack(table_str);
end

function CEPGP_print(str, err)
	if not str then return; end;
	if err == nil then
		DEFAULT_CHAT_FRAME:AddMessage("|c006969FFTnTDKP: " .. tostring(str) .. "|r");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|c006969FFTnTDKP:|r " .. "|c00FF0000Error|r|c006969FF - " .. tostring(str) .. "|r");
	end
end

-- Here we determine the DKP cost of an item by referencing the corresponding Tier<X>BossConfig table
-- itemID - The itemID of the item. This is only necessary if the item isn't equippable so we can cross-reference in in against
--          our list of unequippable items to see if we should charge DKP for it.
function TnTDKP_determineDKPCostOfItem(itemID)

	-- If the item is in the customCostOverride, use that value. Else, check to see if it's in
	-- one of the Tier<N>Loot config files, and use the default value for items from that tier instead
	if CEPGP_tContains(customItemCostConfig, tonumber(itemID), true) then
		return -1 * customItemCostConfig[tonumber(itemID)]
	end

	-- Another up-front check we do is to see if this item is a "special" Non-Epic item which we
	-- carved out an explicit cost for in the NonEpicItemCostConfig.lua
	if CEPGP_tContains(nonEpicItemCostConfig, tonumber(itemID), true) then
		return -1 * nonEpicItemCostConfig[tonumber(itemID)]
	end

	-- Simply check to see which Loot Table the item is in to determine the cost
	if CEPGP_tContains(tierFourLoot, tonumber(itemID), false) then
		return -1000
	elseif CEPGP_tContains(tierFiveLoot, tonumber(itemID), false) then
		return -2000
	elseif CEPGP_tContains(tierSixLoot, tonumber(itemID), false) then
		return -3000
	elseif CEPGP_tContains(tierSixPointFiveLoot, tonumber(itemID), false) then
		return -4000
	else
		CEPGP_print(format("ItemID: %s not found on any of the Loot LUA config files for any tier", itemID), true)
		return 0
	end
end

-- Adds the designated item to a player's Priority registry.
-- TODO: This logic needs to respect the rules we've laid out regarding Priority lists, such as player role and one item for each slot, etc
--
-- player - The player whose record we want to modify
-- itemID - The itemID to be added to player's Priority list
function TnTDKP_addItemToPriorityList(player, itemID)
	-- Simply fetch the DKP for this player from any table to be sure a record
	-- gets generated for this player if one doesn't yet exist
	local DKP = TnTDKP_getPriorityDKP(player, "T4")

	-- Make sure the itemID is a valid itemID
	if not TnTDKP_isItemID(itemID) then
		CEPGP_print(format("ItemID: %s is not a valid itemID. If you're sure the ItemID is correct, make sure you mouse-over the item link in your WoW Client before trying again.", itemID), true)
		return
	end

	-- V2 TODO: If we are modifying this player's Priority list, run the rules to make sure this item is allowed to be added

	-- Add this item to the list. If the item already exists in the list, simply increment the count
	if CEPGP_tContains(PLAYER_PRIORITY_REGISTRY, itemID, true) then
		-- Check to see if this specific player has this item already on their registry
		if CEPGP_tContains(PLAYER_PRIORITY_REGISTRY[itemID], player, true) then
			local currentQuantity = PLAYER_PRIORITY_REGISTRY[itemID][player]
			PLAYER_PRIORITY_REGISTRY[itemID][player] = currentQuantity + 1
			CEPGP_print(format("Player %s already had %d of itemID: %s on their Priority list. Incrementing this count to: %d", player, currentQuantity, itemID, currentQuantity + 1))
			return
		else
			PLAYER_PRIORITY_REGISTRY[itemID][player] = 1
			CEPGP_print(format("Added itemID: %s to player: %s's Priority list", itemID, player))
			return
		end
	else
		PLAYER_PRIORITY_REGISTRY[itemID] = {}
		PLAYER_PRIORITY_REGISTRY[itemID][player] = 1
		CEPGP_print(format("Added itemID: %s to player: %s's Priority list", itemID, player))
		return
	end
end

-- Adds the designated item to a player's Lottery registry.
--
-- player - The player whose record we want to modify
-- itemID - The itemID to be added to player's Lottery list
function TnTDKP_addItemToLotteryList(player, itemID)
	-- Simply fetch the DKP for this player from any table to be sure a record
	-- gets generated for this player if one doesn't yet exist
	local DKP = TnTDKP_getLotteryDKP(player, "T4")

	-- Make sure the itemID is a valid itemID
	if not TnTDKP_isItemID(itemID) then
		CEPGP_print(format("ItemID: %s is not a valid itemID. If you're sure the ItemID is correct, make sure you mouse-over the item link in your WoW Client before trying again.", itemID), true)
		return
	end

	-- Add this item to the list. If the item already exists in the list, simply increment the count
	if CEPGP_tContains(PLAYER_LOTTERY_REGISTRY, itemID, true) then
		-- Check to see if this specific player has this item already on their registry
		if CEPGP_tContains(PLAYER_LOTTERY_REGISTRY[itemID], player, true) then
			local currentQuantity = PLAYER_LOTTERY_REGISTRY[itemID][player]
			PLAYER_LOTTERY_REGISTRY[itemID][player] = currentQuantity + 1
			CEPGP_print(format("Player %s already had %d of itemID: %s on their Lottery list. Incrementing this count to: %d", player, currentQuantity, itemID, currentQuantity + 1))
			return
		else
			PLAYER_LOTTERY_REGISTRY[itemID][player] = 1
			CEPGP_print(format("Added itemID: %s to player: %s's Lottery list", itemID, player))
			return
		end
	else
		PLAYER_LOTTERY_REGISTRY[itemID] = {}
		PLAYER_LOTTERY_REGISTRY[itemID][player] = 1
		CEPGP_print(format("Added itemID: %s to player: %s's Lottery list", itemID, player))
		return
	end
end

-- Removes the designated item from the designated player's Priority list, if present.
function TnTDKP_removeItemFromPriorityList(player, itemID)
	-- Simply fetch the DKP for this player from any table to be sure a record
	-- gets generated for this player if one doesn't yet exist
	local DKP = TnTDKP_getPriorityDKP(player, "T4")

	-- Make sure the itemID is a valid itemID
	if not TnTDKP_isItemID(itemID) then
		CEPGP_print(format("ItemID: %s is not a valid itemID. If you're sure the ItemID is correct, make sure you mouse-over the item link in your WoW Client before trying again.", itemID), true)
		return
	end

	if CEPGP_tContains(PLAYER_PRIORITY_REGISTRY, itemID, true) then
		-- Verify that this specific player has this item already on their registry
		if CEPGP_tContains(PLAYER_PRIORITY_REGISTRY[itemID], player, true) then
			-- If this player has more than one of this item on their registry, simply decrement the count
			local currentQuantity = PLAYER_PRIORITY_REGISTRY[itemID][player]
			if currentQuantity > 1 then
				PLAYER_PRIORITY_REGISTRY[itemID][player] = currentQuantity - 1
				CEPGP_print(format("Player: %s had %d of ItemID: %s on their Priority list. Decremented this count to: %d", player, currentQuantity, itemID, currentQuantity - 1))
				return
			else
				-- Check to see if this player is the ONLY person with an entry for this itemID, if so, remove the top-level record
				if CEPGP_ntgetn(PLAYER_PRIORITY_REGISTRY[itemID]) == 1 then
					PLAYER_PRIORITY_REGISTRY[itemID] = nil
				else
					PLAYER_PRIORITY_REGISTRY[itemID][player] = nil
				end
				CEPGP_print(format("Removed itemID: %s from player: %s's Priority list", itemID, player))
				return
			end
		else
			CEPGP_print(format("Player %s did not have ItemID: %s on their Priority list", player, itemID))
			return
		end
	else
		CEPGP_print(format("ItemID: %s wasn't present on anyone's Priority list. Doing nothing.", itemID), true)
		return
	end
end

-- Removes the designated item from the designated player's Lottery list, if present.
function TnTDKP_removeItemFromLotteryList(player, itemID)
	-- Simply fetch the DKP for this player from any table to be sure a record
	-- gets generated for this player if one doesn't yet exist
	local DKP = TnTDKP_getLotteryDKP(player, "T4")

	-- Make sure the itemID is a valid itemID
	if not TnTDKP_isItemID(itemID) then
		CEPGP_print(format("ItemID: %s is not a valid itemID. If you're sure the ItemID is correct, make sure you mouse-over the item link in your WoW Client before trying again.", itemID), true)
		return
	end

	if CEPGP_tContains(PLAYER_LOTTERY_REGISTRY, itemID, true) then
		-- Verify that this specific player has this item already on their registry
		if CEPGP_tContains(PLAYER_LOTTERY_REGISTRY[itemID], player, true) then
			-- If this player has more than one of this item on their registry, simply decrement the count
			local currentQuantity = PLAYER_LOTTERY_REGISTRY[itemID][player]
			if currentQuantity > 1 then
				PLAYER_LOTTERY_REGISTRY[itemID][player] = currentQuantity - 1
				CEPGP_print(format("Player: %s had %d of ItemID: %s on their Lottery list. Decremented this count to: %d", player, currentQuantity, itemID, currentQuantity - 1))
				return
			else
				-- Check to see if this player is the ONLY person with an entry for this itemID, if so, remove the top-level record
				if CEPGP_ntgetn(PLAYER_LOTTERY_REGISTRY[itemID]) == 1 then
					PLAYER_LOTTERY_REGISTRY[itemID] = nil
				else
					PLAYER_LOTTERY_REGISTRY[itemID][player] = nil
				end
				CEPGP_print(format("Removed itemID: %s from player: %s's Lottery list", itemID, player))
				return
			end
		else
			CEPGP_print(format("Player %s did not have ItemID: %s on their Lottery list", player, itemID))
			return
		end
	else
		CEPGP_print(format("ItemID: %s wasn't present on anyone's Lottery list. Doing nothing.", itemID), true)
		return
	end
end

-- Given what should be an itemID, verify that it is, in fact, an itemID
function TnTDKP_isItemID(itemIDToVerify)
	if CEPGP_isNumber(itemIDToVerify) then
		local name, _, rarity = GetItemInfo(tonumber(itemIDToVerify))
		if name then
			return true
		else
			return false
		end
	else
		return false
	end
end

-- This method simply clears the frames for the given mode, where the
-- specific mode is determined by CEPGP_mode, which is "guild", "raid", or "loot"
function CEPGP_cleanTable()
	-- CEPGP_mode is either "guild", "raid", or "loot", so these loops resolve to
	-- frame names of the format: "raidmember_name1", "raidmember_group1", etc...
	if CEPGP_debugMode then print(format("[%s]: CEPGP_cleanTable() called", TAG)) end
	local i = 1;
	while _G[CEPGP_mode..'member_name'..i] ~= nil do
		_G[CEPGP_mode..'member_group'..i].text:SetText("");
		_G[CEPGP_mode..'member_name'..i].text:SetText("");
		_G[CEPGP_mode..'member_rank'..i].text:SetText("");
		_G[CEPGP_mode..'member_EP'..i].text:SetText("");
		_G[CEPGP_mode..'member_GP'..i].text:SetText("");
		_G[CEPGP_mode..'member_PR'..i].text:SetText("");
		i = i + 1;
	end
	
	i = 1;
	while _G[CEPGP_mode..'item'..i] ~= nil do
		_G[CEPGP_mode..'announce'..i]:Hide();
		_G[CEPGP_mode..'icon'..i]:Hide();
		_G[CEPGP_mode..'texture'..i]:Hide();
		_G[CEPGP_mode..'item'..i].text:SetText("");
		_G[CEPGP_mode..'slotNumber'..i].text:SetText("");
		i = i + 1;
	end
end

function CEPGP_toggleFrame(frame)
	for i = 1, table.getn(CEPGP_frames) do
		if CEPGP_frames[i]:GetName() == frame then
			CEPGP_frames[i]:Show();
		else
			CEPGP_frames[i]:Hide();
		end
	end
end

-- Handles either the GUILD_ROSTER_UPDATE or GROUP_ROSTER_UPDATE events, updating the corresponding table
function CEPGP_rosterUpdate(event)
	-- This event gets fired whenever a call to GuildRoster() is made. When this event comes back, we
	-- completely re-build our CEPGP_guildRosterAndRelatedMetadata table with the new data.
	if event == "GUILD_ROSTER_UPDATE" then
		CEPGP_guildRosterAndRelatedMetadata = {};
		for i = 1, GetNumGuildMembers() do
			local name, rank, rankIndex, _, class, _, _, _ = GetGuildRosterInfo(i);
			if name then
				-- The GuildRoster API returns names with -Whitemane after them. We want to strip this off
				if string.find(name, "-") then
					name = string.sub(name, 0, string.find(name, "-")-1);
				end
				CEPGP_guildRosterAndRelatedMetadata[name] = {
					[1] = i, -- The index of the player in the guild roster
					[2] = class -- The player's class
				};
			end
		end
		if CEPGP_mode == "guild" then
			CEPGP_UpdateAllMembersScrollBar();
		elseif CEPGP_mode == "raid" then
			CEPGP_UpdateRaidScrollBar();
		end
		CEPGP_UpdateStandbyScrollBar();
	end

	-- It seems we don't bother checking to see what mode we're in here, we
	-- simply update both the Raid and the Standby ScrollBars. If we're no
	-- longer in a raid, however, we do flip the CEPGP_mode back to "guild"
	if event == "GROUP_ROSTER_UPDATE" then
		CEPGP_updateGuild();
		TnTDKP_updateRaidRosterTable();
		if UnitInRaid("player") then
			ShowUIPanel(CEPGP_button_raid);
		else --[[ Hides the raid and loot distribution buttons if the player is not in a raid group ]]--
			HideUIPanel(CEPGP_raid);
			HideUIPanel(CEPGP_loot);
			HideUIPanel(CEPGP_button_raid);
			HideUIPanel(CEPGP_button_loot_dist);
			HideUIPanel(CEPGP_distribute_popup);
			HideUIPanel(CEPGP_context_popup);
			CEPGP_mode = "guild";
			ShowUIPanel(CEPGP_guild);
			-- TODO: Print a "CheckList" to remind the Admin to upload the necessary files
		end
		CEPGP_UpdateRaidScrollBar();
	end
end

-- Does as the name implies. Also clears out any players that may have been
-- still on the STANDBY_ROSTER who are now, in fact, in the raid. This
-- does NOT call CEPGP_UpdateRaidScrollBar(), as this method is invoked in
-- CEPGP_UpdateRaidScrollBar() and I don't want to create a cycle
function TnTDKP_updateRaidRosterTable()
	CEPGP_raidRosterAndRelatedMetadata = {};
	if not UnitInRaid("player") then
		return
	end
	for i = 1, GetNumGroupMembers() do
		local name, _, group, _, class = GetRaidRosterInfo(i);
		if not name then break; end

		-- If this player was on the standby roster and has now been brought into
		-- the raid, remove them from the Standby roster. The Standby roster only
		-- contains names of mains, so we need to convert the character name first
		local nameOfMain = TnTDKP_getMainCharacterName(name)
		if CEPGP_tContains(STANDBY_ROSTER, nameOfMain) then
			for k, v in pairs(STANDBY_ROSTER) do
				if v == nameOfMain then
					table.remove(STANDBY_ROSTER, k);
				end
			end
			CEPGP_UpdateStandbyScrollBar();
		end
		
		CEPGP_raidRosterAndRelatedMetadata[name] = {
			[1] = class, -- The player's class
			[2] = group -- The raid group the player is in
		};
	end
end

-- In order for a player to be added to standby, the following criteria must be met:
-- 1. They must be in the guild
-- 2. They must not already be on the standby list
-- 3. They must not be part of the raid
-- Players who try to add themselves to standby from KNOWN alts (alts present in the AltMapConfig)
-- will first be resolved to their main, and have their main added to the standby list. This handling
-- solves a plethora of strange edge-case behavior regarding dual-awarding players DKP (such as Dertysam
-- on the 3/31 raid night)
function CEPGP_addToStandby(player)
	if not player then return; end
	player = CEPGP_standardiseString(player);
	local nameOfMain = TnTDKP_getMainCharacterName(player) -- Convert any known alts to their respective Mains before adding them to Standby
	if not CEPGP_tContains(CEPGP_guildRosterAndRelatedMetadata, nameOfMain, true) then
		CEPGP_print(nameOfMain .. " is not a guild member", true);
		return;
	elseif CEPGP_tContains(STANDBY_ROSTER, nameOfMain) then
		SendChatMessage("Character \"" .. nameOfMain .. "\" already exists on the Standby Award list", WHISPER, CEPGP_LANGUAGE, player);
		CEPGP_print(nameOfMain .. " is already in the standby roster", true);
		return;
	elseif CEPGP_tContains(CEPGP_raidRosterAndRelatedMetadata, nameOfMain, true) then
		CEPGP_print(nameOfMain .. " tried to add themselves to standby but they are already in the raid", true);
		return;
	else
		SendChatMessage("Character \"" .. nameOfMain .. "\" has been successfully added to the Standby Award list.", WHISPER, CEPGP_LANGUAGE, player);
		SendChatMessage("If \"" .. nameOfMain .. "\" is NOT your main character, then the AddOn does not recognize this alt, and you will need to log over to your main and add them instead in order to properly receive DKP", WHISPER, CEPGP_LANGUAGE, player);
		table.insert(STANDBY_ROSTER, nameOfMain);
		CEPGP_UpdateStandbyScrollBar();
	end
end

function CEPGP_standardiseString(str)
	--Returns the string with proper nouns capitalised
	if not str then return; end
	local result = "";
	local _, delims = string.gsub(str, " ", ""); --accommodates for spaces
	local values = CEPGP_split(str, " ", delims);
	for k, v in pairs(values) do
		if string.find(v, "%-") then
			_, delims2 = string.gsub(v, "%-", ""); --accommodates for hyphens
			values2 = CEPGP_split(v, "%-", delims2);
			for index, value in pairs(values2) do
				local first = string.upper(string.sub(value, 1, 1));
				if index <= delims2 then
					result = result .. first .. string.sub(value, 2, string.len(value)) .. "-";
				else
					result = result .. first .. string.lower(string.sub(value, 2, string.len(value)));
				end
			end
		else
			if v == "of" or (v == "the" and k > 1) then
				result = result .. v .. " ";
			else
				local first = string.upper(string.sub(v, 1, 1));
				if k <= delims then
					result = result .. first .. string.lower(string.sub(v, 2, string.len(v))) .. " ";
				else
					result = result .. first .. string.lower(string.sub(v, 2, string.len(v)));
				end
			end
		end
	end
	
	return result;

end

function CEPGP_split(str, delim, iters) --String to be split, delimiter, number of iterations
	local frags = {};
	local remainder = str;
	local count = 1;
	for i = 1, iters+1 do
		if string.find(remainder, delim) then
			frags[count] = string.sub(remainder, 1, string.find(remainder, delim)-1);
			remainder = string.sub(remainder, string.find(remainder, delim)+1, string.len(remainder));
		else
			frags[count] = string.sub(remainder, 1, string.len(remainder));
		end
		count = count + 1;
	end
	return frags;
end

-- Return the dataset for a player's record in the CEPGP_guildRosterAndRelatedMetadata table as follows:
-- [1] = playerIndexInGuild,
-- [2] = player class
function CEPGP_getPlayerInfoFromGuildRosterTable(name)
	if CEPGP_tContains(CEPGP_guildRosterAndRelatedMetadata, name, true) then
		return CEPGP_guildRosterAndRelatedMetadata[name][1], CEPGP_guildRosterAndRelatedMetadata[name][2];
	else
		return nil;
	end
end

-- Return the dataset for a player's record in the CEPGP_raidRosterAndRelatedMetadata table as follows:
-- [1] = player class,
-- [2] = the Raid Group the player is in
function TnTDKP_getPlayerInfoFromRaidRosterTable(name)
	if not CEPGP_raidRosterAndRelatedMetadata then
		return nil;
	elseif CEPGP_tContains(CEPGP_raidRosterAndRelatedMetadata, name, true) then
		return CEPGP_raidRosterAndRelatedMetadata[name][1], CEPGP_raidRosterAndRelatedMetadata[name][2];
	else
		return nil;
	end
end

-- Used when parsing slash commands that have parameters. Simply splits the string on the first space
function CEPGP_getVal(str)
	local val = nil;
	val = strsub(str, strfind(str, " ")+1, string.len(str));
	return val;
end

-- Index is the index of the player in the guild. Iterate over our Guild
-- table and search the "index" field of each player's entry until we find
-- the record that corresponds, then return that player's name
function CEPGP_guildIndexToPlayerName(index)
	for name,value in pairs(CEPGP_guildRosterAndRelatedMetadata) do
		if value[1] == index then
			return name;
		end
	end
end

-- Similar to the above, but instead we match on the player's name and
-- return the index
function CEPGP_playerNameToGuildIndex(name)
	for key,index in pairs(CEPGP_guildRosterAndRelatedMetadata) do
		if key == name then
			return index[1];
		end
	end
end

-- Determine the winner of the item with itemID in the Priority DKP system.
-- If there is a tie, all tied players are returned as a string concatenated with "+"s
-- NOTE: This logic assumes that TnTDKP_determineIfPriorityWinnerCantAffordAndShouldRunLotteryInstead() has
-- already been executed in order to determine if this item should be distributed via Lottery. If this method
-- is called without calling TnTDKP_determineIfPriorityWinnerCantAffordAndShouldRunLotteryInstead() first, then
-- the "winner" determined here could be a player with negative DKP
-- This method needs to know what was previously looted so it can take that into account when
-- determing the winner of subsequent items. This can be tracked via a global table: TnTDKP_priority_recipients
function TnTDKP_determinePriorityWinner(itemID)
	-- This case should never be hit because this check is supposed to be made up-front in the calling method
	if not PLAYER_PRIORITY_REGISTRY[itemID] then
		return "No One"
	end
	local tier = determineRaidTierFromItemID(itemID)
	local dkpCostOfItem = tonumber(TnTDKP_determineDKPCostOfItem(itemID)) * -1
	local highestDKP = -100000
	local winner = "No One"
	for player,quantity in pairs(PLAYER_PRIORITY_REGISTRY[itemID]) do
		-- Only process players who are actually in the raid group AND who are also listed as Main Raiders
		if CEPGP_tContains(CEPGP_raidRosterAndRelatedMetadata, player, true) and CEPGP_tContains(mainRaiders, player) then
			local priorityDKP = TnTDKP_getPriorityDKP(player, tier)

			-- We only allow players to take this item at Priority if they aren't at negative Priority DKP
			if priorityDKP >= 0 then
				-- We only consider players who can actually afford the item
				if priorityDKP >= dkpCostOfItem then
					if priorityDKP > highestDKP then
						winner = player
						highestDKP = priorityDKP
					elseif priorityDKP == highestDKP then
						winner = winner .. "+" .. player
					end
				end
			end
		end
	end
	-- If the winner is "No One", we do a second pass in order to allow Reserve Raiders a shot at this item at Priority
	if winner == "No One" then
		for player,quantity in pairs(PLAYER_PRIORITY_REGISTRY[itemID]) do
			-- Only process players who are actually in the raid group AND who are also listed as Reserve Raiders
			if CEPGP_tContains(CEPGP_raidRosterAndRelatedMetadata, player, true) and CEPGP_tContains(reserveRaiders, player) then
				local priorityDKP = TnTDKP_getPriorityDKP(player, tier)

				-- We only allow players to take this item at Priority if they aren't at negative Priority DKP
				if priorityDKP >= 0 then
					-- We only consider players who can actually afford the item
					if priorityDKP >= dkpCostOfItem then
						if priorityDKP > highestDKP then
							winner = player
							highestDKP = priorityDKP
						elseif priorityDKP == highestDKP then
							winner = winner .. "+" .. player
						end
					end
				end
			end
		end
	end
	return winner
end

-- As the name implies, for a given itemID we see if the "winner" doesn't actually have enough Priority
-- DKP for this item. This method returns True if this is the case, but not before adding this item
-- to the Lottery list for ALL players who had this on thier Priority list but could not afford it.
-- We do this to give them a chance at the item in the Lottery, as we are about to kick off the Lottery for this itemID.
function TnTDKP_determineIfPriorityWinnerCantAffordAndShouldRunLotteryInstead(itemID)
	if not PLAYER_PRIORITY_REGISTRY[itemID] then
		return true
	end

	-- Fetch the tier from the ItemID
	local tier = determineRaidTierFromItemID(itemID)

	-- Keep track of all players who have this ItemID on their Priority list but who cannot afford it
	local priorityPlayersWhoCantAfford = {}
	local dkpCostOfItem = tonumber(TnTDKP_determineDKPCostOfItem(itemID)) * -1
	local highestDKP = -100000
	local winner = "No One"
	for player,quantity in pairs(PLAYER_PRIORITY_REGISTRY[itemID]) do
		-- For the first pass, we only process players who are actually in the raid group AND who are also listed as MAIN Raiders
		if CEPGP_tContains(CEPGP_raidRosterAndRelatedMetadata, player, true) and CEPGP_tContains(mainRaiders, player) then
			local priorityDKP = TnTDKP_getPriorityDKP(player, tier)

			-- If the player doesn't have enough Priority DKP for this item, this player will not be able to receive this item at Priority
			if priorityDKP < dkpCostOfItem then
				priorityPlayersWhoCantAfford[player] = quantity
			elseif priorityDKP > highestDKP then
				winner = player
				highestDKP = priorityDKP
			elseif priorityDKP == highestDKP then
				winner = winner .. "+" .. player
			end
		end
	end
	-- If the winner is "No One", we do a second pass in order to allow Reserve Raiders a shot at this item at Priority
	if winner == "No One" then
		for player,quantity in pairs(PLAYER_PRIORITY_REGISTRY[itemID]) do
			-- Only process players who are actually in the raid group AND who are also listed as Reserve Raiders
			if CEPGP_tContains(CEPGP_raidRosterAndRelatedMetadata, player, true) and CEPGP_tContains(reserveRaiders, player) then
				local priorityDKP = TnTDKP_getPriorityDKP(player, tier)

				-- If the player doesn't have enough Priority DKP for this item, this player will not be able to receive this item at Priority
				if priorityDKP < dkpCostOfItem then
					priorityPlayersWhoCantAfford[player] = quantity
				elseif priorityDKP > highestDKP then
					winner = player
					highestDKP = priorityDKP
				elseif priorityDKP == highestDKP then
					winner = winner .. "+" .. player
				end
			end
		end
	end

	-- If there is no other Priority winner found, then this will end up going down to Lottery. Before
	-- that occurs, we need to check if there were players who wanted this but who couldn't afford it.
	-- For each such player, we want to add this item to their Lottery list so that they at least have an
	-- opportunity to get it at Lottery.
	if winner == "No One" and CEPGP_ntgetn(priorityPlayersWhoCantAfford) > 0 then
		CEPGP_print(format("The following players had ItemID: %s on their Priority list but could not afford it:", itemID))
		for player,quantity in pairs(priorityPlayersWhoCantAfford) do
			CEPGP_print(format("  - %s", player))
			if PLAYER_LOTTERY_REGISTRY[itemID] ~= nil then
				-- If the item is already on this player's Lottery list, do nothing
				if not CEPGP_tContains(PLAYER_LOTTERY_REGISTRY[itemID], player, true) then
					PLAYER_LOTTERY_REGISTRY[itemID][player] = quantity
				end
			else
				PLAYER_LOTTERY_REGISTRY[itemID] = {}
				PLAYER_LOTTERY_REGISTRY[itemID][player] = quantity
			end
		end
		CEPGP_print(format("The above players have had this item added to their Lottery lists. Beginning Lottery distribution for ItemID: %s", itemID))
		return true
	end
	return false
end

-- Initiate the lottery to determine the winner of the Lottery weighted random roll
-- The actual result of this gets captured and processed in CEPGP_OnEvent()
function TnTDKP_executeLotteryLogicAndDetermineWinner()
	-- This case should never be hit because this check is supposed to be made up-front in the calling method
	if not PLAYER_LOTTERY_REGISTRY[CEPGP_DistID] then
		SendChatMessage("Lottery initiated but no one has this item on thier Lottery list. Proceed to Open Roll", "RAID", CEPGP_LANGUAGE);
		return
	end

	local tier = determineRaidTierFromItemID(CEPGP_DistID)

	-- "Prep" the Lottery data into a useful table for iteration. This step is necessary to be able to sort (and therefore print)
	-- the lottery participants in DKP descending order
	local lotteryParticipantData = {}
	local index = 1
	for player,quantity in pairs(PLAYER_LOTTERY_REGISTRY[CEPGP_DistID]) do
		-- Only process players who are actually in the raid group
		if CEPGP_tContains(CEPGP_raidRosterAndRelatedMetadata, player, true) then
			if not CEPGP_tContains(mainRaiders, player) and not CEPGP_tContains(reserveRaiders, player) then
				CEPGP_print(format("Player: \"%s\" has itemID: %s on their Lottery list, but they aren't a Core or Reserve raider. Disregarding.", player, CEPGP_DistID), true)
			else
				lotteryParticipantData[index] = {
					[1] = player,
					[2] = tonumber(TnTDKP_getLotteryDKP(player, tier)),
				}
				index = index + 1
			end
		end
	end

	-- Sort the list in order of DKP ASCENDING first, to assign the lottery range rolls starting from 1
	-- with the lowest DKP member (these will be printed out in DKP order DESCENDING, so it'll make sense)
	local lotteryParticipantDataSortedAscending = {}
	lotteryParticipantDataSortedAscending = CEPGP_tSort(lotteryParticipantData, 2)

	-- Iterate over the sorted Lottery entrants and saturate the global TnTDKP_lottery_participants table
	local totalTicketsInLottery = 0
	TnTDKP_lottery_participants = {}
	for index,entry in pairs(lotteryParticipantDataSortedAscending) do
		local lotteryTickets = entry[2]

		-- We go down to a minimum of 1 Lottery ticket
		if lotteryTickets < 1 then
			lotteryTickets = 1
		end
		lotteryTickets = math.floor(lotteryTickets)
		TnTDKP_lottery_participants[entry[1]] = {}
		TnTDKP_lottery_participants[entry[1]]["Tickets"] = lotteryTickets
		TnTDKP_lottery_participants[entry[1]]["RangeMin"] = totalTicketsInLottery + 1
		TnTDKP_lottery_participants[entry[1]]["RangeMax"] = totalTicketsInLottery + lotteryTickets
		totalTicketsInLottery = totalTicketsInLottery + lotteryTickets
	end

	if CEPGP_ntgetn(lotteryParticipantDataSortedAscending) == 1 then
		-- Pull the first record, since it's the only record
		CEPGP_distPlayer = lotteryParticipantDataSortedAscending[1][1]
		SendChatMessage(CEPGP_distPlayer .. " is the sole entrant in the lottery, so he/she wins " .. CEPGP_distItemLink .. "!", "RAID_WARNING", CEPGP_LANGUAGE);
	else

		-- Now take the same LotteryParticipantData but sort it Descending for the final printout
		local critReverseSnapshot = CEPGP_critReverse
		CEPGP_critReverse = true
		local lotteryParticipantDataSortedDescending = {}
		lotteryParticipantDataSortedDescending = CEPGP_tSort(lotteryParticipantDataSortedAscending, 2)
		CEPGP_critReverse = critReverseSnapshot

		-- Print the ranges for each player
		SendChatMessage("Lottery Contestants:", "RAID", CEPGP_LANGUAGE);
		for index,entry in pairs(lotteryParticipantDataSortedDescending) do
			local player = entry[1]
			local lotteryDKP = entry[2]
			local numTickets = TnTDKP_lottery_participants[player]["Tickets"]
			local rangeMin = TnTDKP_lottery_participants[player]["RangeMin"]
			local rangeMax = TnTDKP_lottery_participants[player]["RangeMax"]
			local lotteryOddsNum = (tonumber(numTickets) / totalTicketsInLottery) * 100
			local lotteryOdds = format("%2.2f", lotteryOddsNum)
			SendChatMessage(format("- %s // %s Lottery DKP = %s Lottery Tickets // Winning Range [%d-%d] (%s%% Odds)", player, lotteryDKP, numTickets, rangeMin, rangeMax, lotteryOdds), "RAID", CEPGP_LANGUAGE);
		end

		-- Frame which simply performs the random lottery roll after a one-second delay
		local delayedRandomRollFrame = CreateFrame("Frame")
		delayedRandomRollFrame:Hide()
		delayedRandomRollFrame:SetScript("OnShow", function(self)
			self.time = 1.0
		end)
		delayedRandomRollFrame:SetScript("OnUpdate", function(self, elapsed)
			self.time = self.time - elapsed
			if self.time <= 0 then
				self:Hide()

				-- Initiate Random Roll and listen for the result in the event handler in CEPGP_OnEvent()
				RandomRoll(1, totalTicketsInLottery)
			end
		end)
		delayedRandomRollFrame:Show()
	end
end

-- It can be very difficult state-wise to determine which raid tier/zone we are in. Classic prevents
-- AddOns from easily telling which zone you zone into, so it's easy enough for me to simply maintain
-- a list of itemIDs for each raid tier
function determineRaidTierFromItemID(itemID)
	if CEPGP_tContains(tierFourLoot, tonumber(itemID), false) then
		return "T4"
	elseif CEPGP_tContains(tierFiveLoot, tonumber(itemID), false) then
		return "T5"
	elseif CEPGP_tContains(tierSixLoot, tonumber(itemID), false) then
		return "T6"
	elseif CEPGP_tContains(tierSixPointFiveLoot, tonumber(itemID), false) then
		return "T6.5"
	end
end

-- Does as it says: returns the player's record from the "Priority" DKP
-- table, initializing it if one doesn't exist yet
function TnTDKP_getPlayerDKPFromPriorityTableAndInitIfNotFound(name, dkpTable)
	local priorityDKPTable = {}
	local lotteryDKPTable = {}
	if dkpTable == "T6.5" then
		priorityDKPTable = T6PT5_PRIORITY_DKP_TABLE
		lotteryDKPTable = T6PT5_LOTTERY_DKP_TABLE
	elseif dkpTable == "T6" then
		priorityDKPTable = T6_PRIORITY_DKP_TABLE
		lotteryDKPTable = T6_LOTTERY_DKP_TABLE
	elseif dkpTable == "T5" then
		priorityDKPTable = T5_PRIORITY_DKP_TABLE
		lotteryDKPTable = T5_LOTTERY_DKP_TABLE
	elseif dkpTable == "T4" then
		priorityDKPTable = T4_PRIORITY_DKP_TABLE
		lotteryDKPTable = T4_LOTTERY_DKP_TABLE
	end

	if priorityDKPTable[name] == nil then
		priorityDKPTable[name] = 0

		-- If we're initializing a new player, it would make 0 sense to do so
		-- in JUST the Need table without also initializing them in the Greed table
		if lotteryDKPTable[name] == nil then
			lotteryDKPTable[name] = 0
		end
	end

	return priorityDKPTable[name]
end

-- Does as it says: returns the player's record from the "Lottery" DKP
-- table, initializing it if one doesn't exist yet
function TnTDKP_getPlayerDKPFromLotteryTableAndInitIfNotFound(name, dkpTable)
	local priorityDKPTable = {}
	local lotteryDKPTable = {}
	if dkpTable == "T6.5" then
		priorityDKPTable = T6PT5_PRIORITY_DKP_TABLE
		lotteryDKPTable = T6PT5_LOTTERY_DKP_TABLE
	elseif dkpTable == "T6" then
		priorityDKPTable = T6_PRIORITY_DKP_TABLE
		lotteryDKPTable = T6_LOTTERY_DKP_TABLE
	elseif dkpTable == "T5" then
		priorityDKPTable = T5_PRIORITY_DKP_TABLE
		lotteryDKPTable = T5_LOTTERY_DKP_TABLE
	elseif dkpTable == "T4" then
		priorityDKPTable = T4_PRIORITY_DKP_TABLE
		lotteryDKPTable = T4_LOTTERY_DKP_TABLE
	end

	if lotteryDKPTable[name] == nil then
		
		lotteryDKPTable[name] = 0

		-- If we're initializing a new player, it would make 0 sense to do so
		-- in JUST the Greed table without also initializing them in the Need table
		if priorityDKPTable[name] == nil then
			priorityDKPTable[name] = 0
		end
	end

	return lotteryDKPTable[name]
end

-- Returns a player's DKP from the Lottery table. Returns the Lottery DKP of the main if the player is an Alt
function TnTDKP_getLotteryDKP(name, dkpTable)
	local resolvedName = TnTDKP_getMainCharacterName(name)
	return TnTDKP_getPlayerDKPFromLotteryTableAndInitIfNotFound(resolvedName, dkpTable)
end

-- Returns a player's DKP from the Priority table. Returns the Priority DKP of the main if the player is an Alt
function TnTDKP_getPriorityDKP(name, dkpTable)
	local resolvedName = TnTDKP_getMainCharacterName(name)
	return TnTDKP_getPlayerDKPFromPriorityTableAndInitIfNotFound(resolvedName, dkpTable)
end

function CEPGP_getItemString(link)
	if not link then
		return nil;
	end
	local itemString = string.find(link, "item[%-?%d:]+");
	itemString = strsub(link, itemString, string.len(link)-(string.len(link)-2)-6);
	return itemString;
end

function CEPGP_getItemID(iString)
	if not iString then
		return nil;
	end
	local itemString = string.sub(iString, 6, string.len(iString)-1)--"^[%-?%d:]+");
	return string.sub(itemString, 1, string.find(itemString, ":")-1);
end

function CEPGP_getItemLink(id)
	local name, _, rarity = GetItemInfo(id);
	if rarity == 0 then -- Poor
		return "\124cff9d9d9d\124Hitem:" .. id .. "::::::::110:::::\124h[" .. name .. "]\124h\124r";
	elseif rarity == 1 then -- Common
		return "\124cffffffff\124Hitem:" .. id .. "::::::::110:::::\124h[" .. name .. "]\124h\124r";
	elseif rarity == 2 then -- Uncommon
		return "\124cff1eff00\124Hitem:" .. id .. "::::::::110:::::\124h[" .. name .. "]\124h\124r";
	elseif rarity == 3 then -- Rare
		return "\124cff0070dd\124Hitem:" .. id .. "::::::::110:::::\124h[" .. name .. "]\124h\124r";
	elseif rarity == 4 then -- Epic
		return "\124cffa335ee\124Hitem:" .. id .. "::::::::110:::::\124h[" .. name .. "]\124h\124r";
	elseif rarity == 5 then -- Legendary
		return "\124cffff8000\124Hitem:" .. id .. "::::::::110:::::\124h[" .. name .. "]\124h\124r";
	end
end

-- Checks whether or not the given table "t" contains VALUE "val"
-- If checkKeyInsteadOfVal is true then CEPGP_tContains() returns
-- true if the table contains a KEY with the name "val"
function CEPGP_tContains(t, val, checkKeyInsteadOfVal)
	if not t then return; end
	if checkKeyInsteadOfVal == nil or checkKeyInsteadOfVal == false then
		for _,value in pairs(t) do
			if value == val then
				return true;
			end
		end
	elseif checkKeyInsteadOfVal == true then
		for index,_ in pairs(t) do 
			if index == val then
				return true;
			end
		end
	end
	return false;
end

function CEPGP_isNumber(num)
	return not (string.find(tostring(num), '[^-0-9.]+') or string.find(tostring(num), '[^-0-9.]+$'));
end

-- Returns 0 if the AddOn Administrator is the Master Looter
-- http://wowprogramming.com/docs/api/GetLootMethod.html
function CEPGP_isML()
	local _, isML = GetLootMethod();
	return isML;
end

-- This method simply makes a call to GuildRoster() to refresh
-- the Guild Roster (get's intercepted in CEPGP_rosterUpdate())
function CEPGP_updateGuild()
	ShowUIPanel(CEPGP_button_guild);
	-- Requests updated guild roster information from the server. If the client recieves
	-- a response, GUILD_ROSTER_UPDATE event is raised regardless of whether any information has changed.
	GuildRoster();
end

-- Checks for the presence of the player in the PLAYER_ROLE_CONFIG and, if
-- not found, initializes a record for the player, like so:
--   - The Warlock, Mage, Rogue and Hunter classes all have just one Role,
--     so they simply get initialized as that 
--   - Each other class will be initialized with a Role of "NOT SET"
-- The player's Role is then returned (after initialization, if required).
-- playerName - The name of the player whose Role to fetch
function TnTDKP_getRoleForPlayerAndCreateRecordIfNotFound(playerName)

	-- If not found, initialize this player's Role as per the algorithm above
	if not PLAYER_ROLE_CONFIG[playerName] then

		-- Check to see if the player is one of the four classes called out above, so we first fetch
		-- this player's class. This data can be found in either the CEPGP_guildRosterAndRelatedMetadata
		-- Table or the CEPGP_raidRosterAndRelatedMetadata Table - the player should be present in at
		-- least one of these.
		local _, class = CEPGP_getPlayerInfoFromGuildRosterTable(playerName);

		-- If the class information wasn't found in the CEPGP_guildRosterAndRelatedMetadata, check the CEPGP_raidRosterAndRelatedMetadata
		if not class then
			class, _ = TnTDKP_getPlayerInfoFromRaidRosterTable(playerName);
		end

		-- If class wasn't found in the CEPGP_raidRosterAndRelatedMetadata either,
		-- then we just set the player's role to "NOT SET" and return with that.
		if not class then
			PLAYER_ROLE_CONFIG[playerName] = "NOT SET"
			return PLAYER_ROLE_CONFIG[playerName]
		end

		-- If we hit this block, the player's Class was successfully fetched, so
		-- we check it against the four classes which just have 1 Role.
		if class == "Warlock" or class == "Mage" or class == "Rogue" or class == "Hunter" then
			PLAYER_ROLE_CONFIG[playerName] = class
		else
			PLAYER_ROLE_CONFIG[playerName] = "NOT SET"
		end
	end
	return PLAYER_ROLE_CONFIG[playerName]
end

-- Sorts a given table "t" by the specified column "index"
function CEPGP_tSort(t, index)
	if not t then return; end
	local t2 = {};
	table.insert(t2, t[1]);
	table.remove(t, 1);
	local tSize = table.getn(t);
	if tSize > 0 then
		for x = 1, tSize do
			local t2Size = table.getn(t2);
			for y = 1, t2Size do
				if y < t2Size and t[1][index] ~= nil then
					if CEPGP_critReverse then
						if (t[1][index] >= t2[y][index]) then
							table.insert(t2, y, t[1]);
							table.remove(t, 1);
							break;
						elseif (t[1][index] < t2[y][index]) and (t[1][index] >= t2[(y + 1)][index]) then
							table.insert(t2, (y + 1), t[1]);
							table.remove(t, 1);
							break;
						end
					else
						if (t[1][index] <= t2[y][index]) then
							table.insert(t2, y, t[1]);
							table.remove(t, 1);
							break;
						elseif (t[1][index] > t2[y][index]) and (t[1][index] <= t2[(y + 1)][index]) then
							table.insert(t2, (y + 1), t[1]);
							table.remove(t, 1);
							break;
						end
					end
				elseif y == t2Size and t[1][index] ~= nil then
					if CEPGP_critReverse then
						if t[1][index] > t2[y][index] then
							table.insert(t2, y, t[1]);
							table.remove(t, 1);
						else
							table.insert(t2, t[1]);
							table.remove(t, 1);
						end
					else
						if t[1][index] < t2[y][index] then
							table.insert(t2, y, t[1]);
							table.remove(t, 1);
						else
							table.insert(t2, t[1]);
							table.remove(t, 1);
						end
					end
				end
			end
		end
	end
	return t2;
end

-- Returns the number of records in the given table
function CEPGP_ntgetn(tbl)
	if tbl == nil then
		return 0;
	end
	local n = 0;
	for _,_ in pairs(tbl) do
		n = n + 1;
	end
	return n;
end

-- Sets the criteria and then triggers a refresh on the appropriate frame
-- The criteria "x" is simply the column number to sort the records in the
-- given Scrollview by. This is mapped to by each of the column headers in
-- Frame.xml
-- scrollBarToModify - The particular scrollbar to refresh after setting the
-- criteria. I actually don't know why this can't just read from CEPGP_mode
function CEPGP_setCriteria(x, scrollBarToModify)
	if CEPGP_criteria == x then
		CEPGP_critReverse = not CEPGP_critReverse
	end
	CEPGP_criteria = x;
	if scrollBarToModify == "Raid" then
		CEPGP_UpdateRaidScrollBar();
	elseif scrollBarToModify == "All" then
		CEPGP_UpdateAllMembersScrollBar();
	elseif scrollBarToModify == "Loot" then
		CEPGP_UpdateLootScrollBar();
	elseif scrollBarToModify == "Standby" then
		CEPGP_UpdateStandbyScrollBar();
	end
end

 -- Initializes the "Options" view.
function CEPGP_button_options_OnClick()
	CEPGP_updateGuild();
	PlaySound(799);

	-- TODO: Figure out what actually shows/hides during this toggle call (reference the XML)
	-- After knowing this, I'll know where I need to set my logic to hide the NEED/GREED CheckBoxes
	-- Either I can do it in OnShow or I can do it here. I think I should try OnShow first
	CEPGP_toggleFrame("CEPGP_options");
	CEPGP_mode = "options";

	if STANDBYEP then
		CEPGP_options_standby_ep_check:SetChecked(true);
	else
		CEPGP_options_standby_ep_check:SetChecked(false);
	end

	CEPGP_options_standby_ep_val:SetText(tostring(STANDBYPERCENT));
	
	if STANDBYEP then
		_G["CEPGP_options_standby_ep_check"]:SetChecked(true);
	else
		_G["CEPGP_options_standby_ep_check"]:SetChecked(false);
	end
	
	if STANDBYOFFLINE then
		_G["CEPGP_options_standby_ep_offline_check"]:SetChecked(true);
	else
		_G["CEPGP_options_standby_ep_offline_check"]:SetChecked(false);
	end
	
	CEPGP_options_standby_ep_val:SetText(tostring(STANDBYPERCENT));
	
	CEPGP_options_standby_ep_message_val:Show();
	CEPGP_options_standby_ep_whisper_message:Show();
	if CEPGP_options_standby_ep_check:GetChecked() then
		CEPGP_options_standby_ep_options:Show();
	else
		CEPGP_options_standby_ep_options:Hide();
	end

	CEPGP_populateFrame();
end

-- This method is a remnant of the Import Settings logic from CEPGP. I truly don't understand
-- most of the magic going on in here, but I do leverage this magical method to initialize my
-- RoleDropDown in the "CEPGP_context_role_dropdown" Button Frame
function CEPGP_UIDropDownMenu_Initialize(frame, initFunction, displayMode, level, menuList, search)
	if ( not frame ) then
		frame = self;
	end

	frame.menuList = menuList;

	if ( frame:GetName() ~= UIDROPDOWNMENU_OPEN_MENU ) then
		UIDROPDOWNMENU_MENU_LEVEL = 1;
	end

	-- Set the frame that's being intialized
	UIDROPDOWNMENU_INIT_MENU = frame:GetName();

	-- Hide all the buttons
	local button, dropDownList;
	for i = 1, UIDROPDOWNMENU_MAXLEVELS, 1 do
		dropDownList = _G["DropDownList"..i];
		if ( i >= UIDROPDOWNMENU_MENU_LEVEL or frame:GetName() ~= UIDROPDOWNMENU_OPEN_MENU ) then
			dropDownList.numButtons = 0;
			dropDownList.maxWidth = 0;
			for j=1, UIDROPDOWNMENU_MAXBUTTONS, 1 do
				button = _G["DropDownList"..i.."Button"..j];
				button:Hide();
			end
			dropDownList:Hide();
		end
	end
	frame:SetHeight(UIDROPDOWNMENU_BUTTON_HEIGHT * 2);
	
	-- Set the initialize function and call it.  The initFunction populates the dropdown list.
	if ( initFunction ) then
		frame.initialize = initFunction;
		initFunction(level, frame.menuList, search);
	end

	-- Change appearance based on the displayMode
	if ( displayMode == "MENU" ) then
		_G[frame:GetName().."Left"]:Hide();
		_G[frame:GetName().."Middle"]:Hide();
		_G[frame:GetName().."Right"]:Hide();
		_G[frame:GetName().."ButtonNormalTexture"]:SetTexture("");
		_G[frame:GetName().."ButtonDisabledTexture"]:SetTexture("");
		_G[frame:GetName().."ButtonPushedTexture"]:SetTexture("");
		_G[frame:GetName().."ButtonHighlightTexture"]:SetTexture("");
		_G[frame:GetName().."Button"]:ClearAllPoints();
		_G[frame:GetName().."Button"]:SetPoint("LEFT", frame:GetName().."Text", "LEFT", -9, 0);
		_G[frame:GetName().."Button"]:SetPoint("RIGHT", frame:GetName().."Text", "RIGHT", 6, 0);
		frame.displayMode = "MENU";
	end

end

function CEPGP_getDebugInfo()
	local info = "<details><summary>Debug Info</summary><br />";
	if STANDBYEP then
		info = info .. "Standby EP: True<br /><br />";
	else
		info = info .. "Standby EP: False<br /><br />";
	end
	if STANDBYOFFLINE then
		info = info .. "Standby Offline: True<br /><br />";
	else
		info = info .. "Standby Offline: False<br /><br />";
	end
	info = info .. "Standby Percent: " .. STANDBYPERCENT .. "<br /><br />";
	info = info .. "Standby EP Whisper Keyphrase: " .. CEPGP_standby_whisper_msg .. "<br /><br />";
	info = info .. "<details><summary>Auto EP</summary><br />";
	info = info .. "</details><br />";
	info = info .. "</details>";
	return info;
end

-- Returns the player's class and class-color
-- Leverages the Guild Roster to find the player's class
function CEPGP_getPlayerClass(name, index)
	if not index and not name then return; end
	local class;
	if name == "Guild" then
		return _, {r=0, g=1, b=0};
	end
	if name == "Raid" then
		return _, {r=1, g=0.10, b=0.10};
	end
	if index then
		_, _, _, _, class = GetGuildRosterInfo(index);
		return class, RAID_CLASS_COLORS[string.upper(class)];
	else
		local id = CEPGP_playerNameToGuildIndex(name);
		if not id then
			return nil;
		else
			_, _, _, _, class = GetGuildRosterInfo(id);
			return class, RAID_CLASS_COLORS[string.upper(class)];
		end
	end
end