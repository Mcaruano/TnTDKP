local TAG = "TnTDKPTestRunner.lua"

-- This function gets wired up in Button.lua and executes whatever logic it is that I wish to test
function TnTDKP_execute_current_test_suite()
	local value = 8.9756354
	local valAsString = string.format("%2.2f", value)
	local valAsNumber = tonumber(valAsString)
	print(valAsNumber)
	-- Test_D_simulate_item_sorting_after_consolidation()
end

-- Simulates 3 items dropping and prints a short summary
function Test_A_print_loot()
	local items = {}
	items = buildItemsList()

	print(format("[%s] Printing items AFTER sorting", TAG))
	local itemsSorted = CEPGP_tSort(items, 8)
	for i = 1, CEPGP_ntgetn(itemsSorted) do
		local itemName = itemsSorted[i][2]
		local link = itemsSorted[i][4]
		local itemID = itemsSorted[i][8]
		local dkp = itemsSorted[i][9]
		print(format("   ItemName: %s, ItemID: %s, DKP: %s, Link: %s", itemName, itemID, dkp, link))
	end
end

-- Simulates 3 items dropping and invokes the LootFrame
function Test_B_surface_loot_table()
	local items = {}
	items = buildItemsList()
	local itemsSorted = CEPGP_tSort(items, 8)
	local numItemsToDistribute = CEPGP_ntgetn(itemsSorted)

	if numItemsToDistribute > 0 then
		CEPGP_frame:Show();
		CEPGP_mode = "loot";
		CEPGP_toggleFrame("CEPGP_loot");
	end

	CEPGP_populateFrame(_, itemsSorted, numItemsToDistribute);
end

function Test_C_surface_loot_table_and_simulate_MLing_slot_1()
	local items = {}
	items = buildItemsList()
	local itemsSorted = CEPGP_tSort(items, 8)
	local numItemsToDistribute = CEPGP_ntgetn(itemsSorted)

	if numItemsToDistribute > 0 then
		CEPGP_frame:Show();
		CEPGP_mode = "loot";
		CEPGP_toggleFrame("CEPGP_loot");
	end

	CEPGP_populateFrame(_, itemsSorted, numItemsToDistribute);

	-- Execute the Determine Winner logic for this item first
	local link = itemsSorted[2][4];
	local slot = itemsSorted[2][6]; -- This is actually the "slot" that the item is in on the boss' loot table
	local itemID = itemsSorted[2][8];
	local distMethod = itemsSorted[2][10]
	TnTDKP_execute_winner_determination_logic_and_announce(itemID, distMethod, link, slot)

	-- Simulate looting this item
	simulateMLingItemInALootSlot(1) -- "Band of Accuria"


	-- simulateMLingItemInALootSlot(2) -- "Onslaught Girdle"
	-- simulateMLingItemInALootSlot(3) -- "Belt of Might"
end

-- A bug was introduced recently which broke item sorting. This is
-- my attempt to get to the bottom of that
function Test_D_simulate_item_sorting_after_consolidation()
	local items = {}
	items = buildItemsList()
	local itemsSorted = CEPGP_tSort(items, 8)
	print("Printing basic item set AFTER sorting")
	for i = 1, CEPGP_ntgetn(itemsSorted) do
		local itemName = itemsSorted[i][2]
		local itemID = itemsSorted[i][8]
		print(format("   ItemName: %s, ItemID: %s", itemName, itemID))
	end

	local consolidatedItems = {}
	local numItemsToFind = CEPGP_ntgetn(itemsSorted)
	local itemsFound = 0
	local index = 1
	while (itemsFound < numItemsToFind) do
		if itemsSorted[index] ~= nil then
			print(format("Item at index %s was not nil", index))
			itemsFound = itemsFound + 1
			consolidatedItems[itemsFound] = itemsSorted[index]
		end
		index = index + 1
	end

	print(format("Printing CONSOLIDATED items BEFORE sorting. Size of consolidated items: %s", CEPGP_ntgetn(itemsSorted)))
	for i = 1, CEPGP_ntgetn(consolidatedItems) do
		local itemName = consolidatedItems[i][2]
		local itemID = consolidatedItems[i][8]
		print(format("   ItemName: %s, ItemID: %s", itemName, itemID))
	end

	local sortedItems = CEPGP_tSort(consolidatedItems, 8)
	print("Printing CONSOLIDATED items AFTER sorting")
	for i = 1, CEPGP_ntgetn(sortedItems) do
		local itemName = sortedItems[i][2]
		local itemID = sortedItems[i][8]
		print(format("   ItemName: %s, ItemID: %s", itemName, itemID))
	end
end


function simulateMLingItemInALootSlot(lootSlot)
	if CEPGP_distributing and lootSlot == CEPGP_lootSlot then
		if CEPGP_distPlayer ~= "" then
			CEPGP_distributing = false;
			local distItemID = CEPGP_DistID
			local dkpCost = TnTDKP_determineDKPCostOfItem(distItemID)
			if TnTDKP_lootDistMode == "Priority" then
				SendChatMessage("Awarded " .. CEPGP_distItemLink .. " to ".. CEPGP_distPlayer .. " for " .. dkpCost .. " Priority DKP", GUILD, CEPGP_LANGUAGE);
				TnTDKP_addOrRemovePriorityDKP(CEPGP_distPlayer, dkpCost, distItemID, CEPGP_distItemLink);
			elseif TnTDKP_lootDistMode == "Lottery" then
				SendChatMessage("Awarded " .. CEPGP_distItemLink .. " to ".. CEPGP_distPlayer .. " for " .. dkpCost .. " Lottery DKP", GUILD, CEPGP_LANGUAGE);
				TnTDKP_addOrRemoveLotteryDKP(CEPGP_distPlayer, dkpCost, distItemID, CEPGP_distItemLink);
			else
				-- TODO: This distPlayer will have to be set as a result of the Open Roll item being distributed
				SendChatMessage("Awarded " .. CEPGP_distItemLink .. " to ".. CEPGP_distPlayer .. " for free (Open Roll)", GUILD, CEPGP_LANGUAGE);
				TnTDKP_logOpenTransaction(CEPGP_distPlayer, CEPGP_DistID)
			end
			CEPGP_distPlayer = "";
			CEPGP_distribute_popup:Hide();
			CEPGP_distribute:Hide();
			_G["distributing"]:Hide();
			CEPGP_loot:Show();
		-- else
		-- 	-- If CEPGP_distPlayer was not set, that means an item was MLed to someone without going through EPGPs functions
		-- 	-- CEPGP_distPlayer being set implies that the decision has been made via EPGP rules
		-- 	CEPGP_distributing = false;
		-- 	SendChatMessage(_G["CEPGP_distribute_item_name"]:GetText() .. " has been distributed without EPGP", GUILD, CEPGP_LANGUAGE);
		-- 	CEPGP_distribute_popup:Hide();
		-- 	CEPGP_distribute:Hide();
		-- 	_G["distributing"]:Hide();
		-- 	CEPGP_loot:Show();
		end
	end
	CEPGP_LootFrame_Update(true);
end

-- Simply saturates a list of items the same as they'd be from the ML loot frame
function buildItemsList()
	local items = {}

	local item = "Band of Accuria"
	local name, link, _, _, _, _, _, _, equipSlot, tex = GetItemInfo(17063)
	local itemString = string.find(link, "item[%-?%d:]+");
	itemString = strsub(link, itemString, string.len(link)-string.len(item)-6);
	items[1] = {}
	items[1][1] = tex; -- Texture
	items[1][2] = "Band of Accuria"; -- Name
	items[1][3] = 4; -- Quality
	items[1][4] = link; -- Link
	items[1][5] = itemString; -- ItemString
	items[1][6] = 1; -- "slot" - as in, the slot in the ML pane
	items[1][7] = 1; -- Quantity
	items[1][8] = 17063; -- ItemID
	items[1][9] = TnTDKP_determineDKPCostOfItem(17063); -- DKP Cost
	if CEPGP_tContains(PLAYER_PRIORITY_REGISTRY, 17063, true) then
		items[1][10] = "Priority"
	elseif CEPGP_tContains(PLAYER_LOTTERY_REGISTRY, 17063, true) then
		items[1][10] = "Lottery"
	else
		items[1][10] = "Open Roll"
	end

	item = "Onslaught Girdle"
	name, link, _, _, _, _, _, _, equipSlot, tex = GetItemInfo(19137)
	itemString = string.find(link, "item[%-?%d:]+");
	itemString = strsub(link, itemString, string.len(link)-string.len(item)-6);
	items[2] = {}
	items[2][1] = tex; -- Texture
	items[2][2] = "Onslaught Girdle"; -- Name
	items[2][3] = 4; -- Quality
	items[2][4] = link; -- Link
	items[2][5] = itemString; -- ItemString
	items[2][6] = 2; -- "slot" - as in, the slot in the ML pane
	items[2][7] = 1; -- Quantity
	items[2][8] = 19137; -- ItemID
	items[2][9] = TnTDKP_determineDKPCostOfItem(19137); -- DKP Cost
	if CEPGP_tContains(PLAYER_PRIORITY_REGISTRY, 19137, true) then
		items[2][10] = "Priority"
	elseif CEPGP_tContains(PLAYER_LOTTERY_REGISTRY, 19137, true) then
		items[2][10] = "Lottery"
	else
		items[2][10] = "Open Roll"
	end

	item = "Belt of Might"
	name, link, _, _, _, _, _, _, equipSlot, tex = GetItemInfo(16864)
	itemString = string.find(link, "item[%-?%d:]+");
	itemString = strsub(link, itemString, string.len(link)-string.len(item)-6);
	items[3] = {}
	items[3][1] = tex; -- Texture
	items[3][2] = "Belt of Might"; -- Name
	items[3][3] = 4; -- Quality
	items[3][4] = link; -- Link
	items[3][5] = itemString; -- ItemString
	items[3][6] = 3; -- "slot" - as in, the slot in the ML pane
	items[3][7] = 1; -- Quantity
	items[3][8] = 16864; -- ItemID
	items[3][9] = TnTDKP_determineDKPCostOfItem(16864); -- DKP Cost
	if CEPGP_tContains(PLAYER_PRIORITY_REGISTRY, 16864, true) then
		items[3][10] = "Priority"
	elseif CEPGP_tContains(PLAYER_LOTTERY_REGISTRY, 16864, true) then
		items[3][10] = "Lottery"
	else
		items[3][10] = "Open Roll"
	end

	return items
end