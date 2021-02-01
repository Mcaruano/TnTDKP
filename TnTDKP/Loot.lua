local TAG = "Loot.lua"

-- This function actually gets all of the items from the Blizz LootFrame and aggregates
-- the info into a table, which it passes down to populateFrame to saturate the LootFrame
-- shouldPrintLootToRaid - True if a loot summary message should be printed to the Raid group on this update
function CEPGP_LootFrame_Update(shouldPrintLootToRaid)
	if CEPGP_debugMode then print(format("[%s] CEPGP_LootFrame_Update() called", TAG)) end
	local items = {};
	local count = 0;
	local numLootItemsFromMob = LootFrame.numLootItems;
	local numItemsToDistribute = 0
	local texture, item, quantity, quality;
	for index = 1, numLootItemsFromMob do
		local slot = index;
		if ( slot <= numLootItemsFromMob ) then	
			if (LootSlotHasItem(slot)) then
				texture, item, quantity, _, quality = GetLootSlotInfo(slot);

				-- This is the singular place where we enforce a minimum quality.
				-- The item qualities are as follows:
					-- 0 - Poor
					-- 1 - Common
					-- 2 - Uncommon
					-- 3 - Rare
					-- 4 - Epic
					-- 5 - Legendary
				if tostring(GetLootSlotLink(slot)) ~= "nil" and (quality > 3 or CEPGP_debugMode or TnTDKP_nonEpicItemShouldUseDKPForDistribution(slot, item)) then
					local link = GetLootSlotLink(slot);
					local itemString = string.find(link, "item[%-?%d:]+");
					itemString = strsub(link, itemString, string.len(link)-string.len(item)-6);
					local itemID = tonumber(CEPGP_getItemID(itemString))
					items[index-count] = {};
					items[index-count][1] = texture;
					items[index-count][2] = item;
					items[index-count][3] = quality;
					items[index-count][4] = link;
					items[index-count][5] = itemString;
					items[index-count][6] = slot;
					items[index-count][7] = quantity;
					items[index-count][8] = itemID;

					-- Determine the DKP cost of the item
					items[index-count][9] = TnTDKP_determineDKPCostOfItem(itemID);

					-- This logic won't be necessary once I saturate the rows with the winners via TnTDKP_determineLootWinners()
					if CEPGP_tContains(PLAYER_PRIORITY_REGISTRY, itemID, true)
						and TnTDKP_eligiblePriorityRecipientIsInRaid(itemID)
						and not TnTDKP_determineIfPriorityWinnerCantAffordAndShouldRunLotteryInstead(itemID) then
							items[index-count][10] = "Priority"
					elseif CEPGP_tContains(PLAYER_LOTTERY_REGISTRY, itemID, true) and TnTDKP_eligibleLotteryRecipientIsInRaid(itemID) then
						items[index-count][10] = "Lottery"
					else
						items[index-count][10] = "Open Roll"
					end

					numItemsToDistribute = numItemsToDistribute + 1
				else
					count = count + 1;
				end
			end
		end
	end

	-- When money is cleared from the lootslot, the frame disappears due to items[1] becoming nil. We account for this misbehavior generally
	-- by iterating over the items table until all valid items are found, and copying their records over to a new, consolidated table
	local consolidatedItems = {}
	local numItemsToFind = CEPGP_ntgetn(items)
	local itemsFound = 0
	local index = 1
	while (itemsFound < numItemsToFind) do
		if items[index] ~= nil then
			itemsFound = itemsFound + 1
			consolidatedItems[itemsFound] = items[index]
		end
		index = index + 1
	end
	local sortedItems = CEPGP_tSort(consolidatedItems, 8)

	-- Iterate over the items and determine winners as best we can
	-- TODO: This is a huge stretch goal
	-- items = TnTDKP_determineLootWinners(items, numItemsToDistribute)

	-- After exporting the quality check to the above loop, this check should just be one to make sure
	-- that the number of entries in the "items" table is > 0 && UnitInRaid("player")
	if numItemsToDistribute > 0 and (UnitInRaid("player") or CEPGP_debugMode) then
		CEPGP_frame:Show();
		CEPGP_mode = "loot";
		CEPGP_toggleFrame("CEPGP_loot");
	end

	CEPGP_populateFrame(_, sortedItems, numItemsToDistribute, shouldPrintLootToRaid);
end

-- The loot system is designed to only support determination logic being executed for items of Epic
-- quality (or higher). When loot drops, only items of Epic quality or higher are even considered.
-- This method allows us to specify any non-epic items which we still want to distribute using our
-- DKP logic. The first example of this is Onyxia Hide Backpack. These items are defined in the
-- NonEpicItemCostConfig.lua
function TnTDKP_nonEpicItemShouldUseDKPForDistribution(slot, itemName)
	local link = GetLootSlotLink(slot);
	local itemString = string.find(link, "item[%-?%d:]+");
	itemString = strsub(link, itemString, string.len(link)-string.len(itemName)-6);
	local itemID = tonumber(CEPGP_getItemID(itemString))

	if CEPGP_tContains(nonEpicItemCostConfig, tonumber(itemID), true) then
		return true
	end
end

-- -- Given a list of the loot to be distributed, iterate over it and determine the winners.
-- -- lootSortedAscending - The loot to be distributed, sorted by ItemID Ascending
-- -- numItemsToDistribute - The number of items. Having this number in advance makes the iteration easier
-- function TnTDKP_determineLootWinners(lootSortedAscending, numItemsToDistribute)
-- 	-- Store a local copy of the DKP lists for use when determining subsequent winners
-- 	local PRIORITY_DKP_SNAPSHOT = PRIORITY_DKP_TABLE
-- 	local LOTTERY_DKP_SNAPSHOT = LOTTERY_DKP_TABLE
	
-- 	local TnTDKP_priority_winning_players = {}
-- 	local TnTDKP_lottery_winning_players = {}
-- 	local TnTDKP_priority_tie_break_players = {}

-- 	-- IF itemID has more than one person registering for it in PLAYER_PRIORITY_REGISTRY
-- 	-- AND the would-be Winner of this item is already in the TnTDKP_priority_tie_break_players Table for one or more items
-- 	-- AND the would-be Winner receiving ALL of the items they are currently in contention for in the TnTDKP_priority_tie_break_players
-- 		-- table PLUS whatever items they already won in the TnTDKP_priority_winning_players Table would leave them BELOW or TIED with
-- 		-- the runner-up(s) in Priority DKP
-- 	-- THEN itemID gets added to the TnTDKP_priority_tie_break_players Table and the would-be Winner plus the runner-up(s)
-- 		-- get added to it

-- 	-- IF itemID has more than one person registering for it in PLAYER_PRIORITY_REGISTRY
-- 	-- AND the would-be Winner of this item is already in the TnTDKP_priority_tie_break_players Table for one or more items
-- 	-- AND the would-be Winner receiving ALL of the items they are currently in contention for in the TnTDKP_priority_tie_break_players
-- 		-- table PLUS whatever items they already won in the TnTDKP_priority_winning_players Table would still leave them with
-- 		-- MORE Priority DKP than the runner-up(s)
-- 	-- THEN would-be Winner wins this item, and it gets recorded in the TnTDKP_priority_winning_players Table

-- 	-- IF itemID has more than one person registering for it in PLAYER_PRIORITY_REGISTRY
-- 	-- AND several players are tied for it
-- 	-- THEN itemID gets added to the TnTDKP_priority_tie_break_players Table and all of the tied players get added to it

-- 	for i = 1, numItemsToDistribute do
-- 		local itemID = lootSortedAscending[i][8]
-- 		local dkpCost = lootSortedAscending[i][9]
-- 		-- After determining a priorityWinner, I need to check the TnTDKP_priority_tie_break_players and
-- 		-- TnTDKP_priority_winning_players tables to see if this player

-- 		if CEPGP_tContains(PLAYER_PRIORITY_REGISTRY, itemID, true) then
-- 			local priorityWinner = TnTDKP_determinePriorityWinner(itemID)
-- 			if CEPGP_ntgetn(PLAYER_PRIORITY_REGISTRY[itemID]) > 1 then
-- 				if string.find(priorityWinner, "+") then
-- 					-- Add all of these players to the TnTDKP_priority_tie_break_players Table
-- 					-- Separate out all of the winners from the "+"-separated string
-- 					local _, numWinners = string.gsub(priorityWinner, "+", "")
-- 					local tiedPriorityWinners = {}
-- 					tiedPriorityWinners = CEPGP_split(priorityWinner, "+", numWinners)

-- 					-- Add these potential Priority winners to our local table for consideration during the next loop
-- 					for index,playerName in pairs(tiedPriorityWinners) do
-- 						-- The "value" here doesn't matter, we're just adding this playerName to the table. It doesn't matter if it exists already
-- 						TnTDKP_priority_tie_break_players[itemID][playerName] = 1
-- 					end
-- 				else
-- 					local totalPotentialPriorityDKPSpentByWinnerThusFar = 0
-- 					-- Iterate over the Tie-break table and tally up all possible expenditures
-- 					for item_id,playerPayload in pairs(TnTDKP_priority_tie_break_players) do
-- 						for player_name,quantity in TnTDKP_priority_tie_break_players[item_id] do
-- 							if player_name == priorityWinner then
-- 								-- Pull the DKP cost of this item. It's easiest just to pull it from the lootSortedAscending Table
-- 								for i = 1, numItemsToDistribute do
-- 									if lootSortedAscending[i][8] == item_id then
-- 										totalPotentialPriorityDKPSpentByWinnerThusFar = totalPotentialPriorityDKPSpentByWinnerThusFar + lootSortedAscending[i][9]
-- 									end
-- 								end
-- 							end
-- 						end
-- 					end
-- 					-- Iterate over the actual Priority winnings table and tally up all confirmed expenditures
-- 					for item_id,playerPayload in pairs(TnTDKP_priority_winning_players) do
-- 						for player_name,quantity in TnTDKP_priority_winning_players[item_id] do
-- 							if player_name == priorityWinner then
-- 								-- Pull the DKP cost of this item. It's easiest just to pull it from the lootSortedAscending Table
-- 								for i = 1, numItemsToDistribute do
-- 									if lootSortedAscending[i][8] == item_id then
-- 										totalPotentialPriorityDKPSpentByWinnerThusFar = totalPotentialPriorityDKPSpentByWinnerThusFar + lootSortedAscending[i][9]
-- 									end
-- 								end
-- 							end
-- 						end
-- 					end

-- 					-- If the would-be winner of this item could potentially win one of the previous items via tie-breaker
-- 					-- we need to know how much DKP they'd have left over to see if the runner-up could still get it. We also
-- 					-- account for the DKP spent thus far on items that the priorityWinner has definitively won already thus far.
-- 					if totalPotentialPriorityDKPSpentByWinnerThusFar > 0 then
-- 						-- TODO: Determine runner-up(s) and how much DKP they have. I can do this by removing this item from the
-- 							-- priorityWinner's Priority list, running the determinePriorityWinner() algorithm, and then re-adding it back
-- 						-- local runnerUpDKP = TODO
-- 							-- I also need to account for the possibilities that one or more of the runner-ups could also be on the
-- 							-- TnTDKP_priority_winning_players or TnTDKP_priority_tie_break_players lists....

-- 						if PRIORITY_DKP_TABLE[priorityWinner] - totalPotentialPriorityDKPSpentByWinnerThusFar <= runnerUpDKP then
-- 							TnTDKP_priority_tie_break_players[itemID] = {}
-- 							TnTDKP_priority_tie_break_players[itemID][priorityWinner] = 1
-- 							-- TODO: Add the runner-up(s)
-- 						else
-- 							-- The would-be Winner actually wins this item
-- 							TnTDKP_priority_winning_players[itemID] = {}
-- 							TnTDKP_priority_winning_players[itemID][priorityWinner] = 1
-- 						end
-- 					end
-- 				end
-- 			end

-- 		elseif CEPGP_tContains(PLAYER_LOTTERY_REGISTRY, itemID, true) then
-- 			if CEPGP_ntgetn(PLAYER_LOTTERY_REGISTRY[itemID]) == 1 then
-- 				lootSortedAscending[i][10] = "Lottery Single"
-- 				-- This loop only has one iteration in this case. We're simply fetching the player name
-- 				for name, v in pairs(PLAYER_LOTTERY_REGISTRY[itemID]) do
-- 					lootSortedAscending[i][11] = name
-- 				end
-- 			else
-- 				lootSortedAscending[i][10] = "Lottery"
-- 				lootSortedAscending[i][11] = ""
-- 			end
-- 		end

		

-- 		-- Determine if there is a winner or potential winner in the Priority or Lottery systems. If so, populate
-- 		-- the [10] and [11] fields with the System and Winners respectively. This information will then be processed
-- 		-- in the "loot" logic fork of the CEPGP_populateFrame() method to either saturate the item row with the winner,
-- 		-- present the button for a Priority tie-breaker roll-off, or present a button to initiate the Lottery.
-- 		-- The various states that an itemID can be placed into are as follows:
-- 			-- "Priority Single" - A single Priority winner has been found for this item
-- 			-- "Priority Tie" - There is a tie amongst the top players in the Priority table for this item
-- 			-- "Priority Pending" - A single winner was determined, but it actually depends on the outcome of the "Priority Tie" roll
-- 			-- "Lottery Single" - A single Lottery winner has been found for this item
-- 			-- "Lottery" - Multiple players have this on their Lottery list, so we need to run the Lottery
-- 		local priorityWinner = TnTDKP_determinePriorityWinner(itemID)
-- 		local itemIsOnLotteryList = CEPGP_tcontains(PLAYER_LOTTERY_REGISTRY, itemID, true)
-- 		if priorityWinner ~= "No One" then
-- 			-- If the Priority winner came back as a string such as "Akaran+Anarra+Thejudge", then a Priority tie-breaker roll is required
-- 			if string.find(priorityWinner, "+") then
-- 				lootSortedAscending[i][10] = "Priority Tie"

-- 				-- If the priorityWinner will require a tie-break, I need to add these players to the TnTDKP_priority_tie_break_players
-- 				-- table such that subsequent priority determinations can know whether or not they are unable to make a determination yet.
-- 				if not CEPGP_tContains(TnTDKP_priority_tie_break_players, itemID) then
-- 					TnTDKP_priority_tie_break_players[itemID] = {}
-- 				end
-- 				-- Separate out all of the winners from the "+"-separated string
-- 				local _, numWinners = string.gsub(priorityWinner, "+", "")
-- 				local tiedPriorityWinners = {}
-- 				tiedPriorityWinners = CEPGP_split(priorityWinner, "+", numWinners)

-- 				-- Add these potential Priority winners to our local table for consideration during the next loop
-- 				for index,playerName in pairs(tiedPriorityWinners) do
-- 					-- The "value" here doesn't matter, we're just adding this playerName to the table. It doesn't matter if it exists already
-- 					TnTDKP_priority_tie_break_players[itemID][playerName] = 1
-- 				end
-- 			else
-- 				-- This is the fork of the flow that represents that a single Priority winner was established.
-- 				-- The edge-case here is whether or not the "winner" who was determined is involved in any pending "Priority Tie" rolls.
-- 				-- If so, the state of this item becomes "Priority Pending"
-- 				lootSortedAscending[i][10] = "Priority Single"
-- 			end
-- 			lootSortedAscending[i][11] = priorityWinner
-- 		else if CEPGP_tContains(PLAYER_LOTTERY_REGISTRY, itemID, true) then
-- 			if CEPGP_ntgetn(PLAYER_LOTTERY_REGISTRY[itemID]) == 1 then
-- 				lootSortedAscending[i][10] = "Lottery Single"
-- 				-- This loop only has one iteration in this case. We're simply fetching the player name
-- 				for name, v in pairs(PLAYER_LOTTERY_REGISTRY[itemID]) do
-- 					lootSortedAscending[i][11] = name
-- 				end
-- 			else
-- 				lootSortedAscending[i][10] = "Lottery"
-- 				lootSortedAscending[i][11] = ""
-- 			end
-- 		else
-- 			lootSortedAscending[i][10] = "Open Roll"
-- 			lootSortedAscending[i][11] = ""
-- 		end
-- 	end

-- 	-- Restore the DKP lists
-- 	PRIORITY_DKP_TABLE = PRIORITY_DKP_SNAPSHOT
-- 	LOTTERY_DKP_TABLE = LOTTERY_DKP_SNAPSHOT
-- end

-- 
function TnTDKP_execute_winner_determination_logic_and_announce(itemID, distMode, link, slotNum)
	TnTDKP_updateRaidRosterTable()
	local iString = CEPGP_getItemString(link);
	local name, _, _, _, _, _, _, _, slot, tex = GetItemInfo(iString);

	-- slotNum == 99 signifies a manual loot distribution has been initiated
	if slotNum ~= 99 then
		CEPGP_distributing = true;
	else
		CEPGP_distributing = false;
	end
	CEPGP_distItemLink = link;
	CEPGP_DistID = itemID;
	CEPGP_distSlot = slot;
	CEPGP_lootSlot = slotNum;
	TnTDKP_lootDistMode = distMode

	SendChatMessage("----------------------------------------------------", RAID, CEPGP_LANGUAGE);
	SendChatMessage("NOW DISTRIBUTING: " .. link, "RAID_WARNING", CEPGP_LANGUAGE);
	SendChatMessage("----------------------------------------------------", RAID, CEPGP_LANGUAGE);
	if distMode == "Priority" then
		local winner = TnTDKP_determinePriorityWinner(itemID)
		if string.find(winner, "+") then
			local formattedString, numWinners = string.gsub(winner, "+", ", ")
			SendChatMessage("The following players are TIED in Priority DKP for " .. link .. ": " .. formattedString, RAID, CEPGP_LANGUAGE);
			TnTDKP_initTableAndSolicitPriorityTiebreakerRolls(winner)
		else
			-- Announce the winner
			CEPGP_distPlayer = winner
			SendChatMessage(winner .. " wins " .. link .. " with Priority DKP", RAID, CEPGP_LANGUAGE);
		end
	elseif distMode == "Lottery" then
		TnTDKP_executeLotteryLogicAndDetermineWinner()
	else
		SendChatMessage("NO ONE has " .. link .. " on Priority or Lottery, so this item will go to OPEN ROLL", RAID, CEPGP_LANGUAGE);
		SendChatMessage("There are no spec restrictions for Open Roll, but YOU MUST PLAN ON USING IT AT SOME POINT", RAID, CEPGP_LANGUAGE);
		SendChatMessage("ROLL NOW if you plan on using " .. link, "RAID_WARNING", CEPGP_LANGUAGE);
	end
end

function TnTDKP_initTableAndSolicitPriorityTiebreakerRolls(winnerString)
	-- Initialize the globale TnTDKP_tied_priority_players Table for tracking their rolls
	TnTDKP_tied_priority_players = {}
	local _, num = string.gsub(winnerString, "+", "")
	TnTDKP_tied_priority_players = CEPGP_split(winnerString, "+", num)

	-- Do a slight transform of this data into a slightly simpler format
	local transformed_priority_players = {}
	for index,playerName in pairs(TnTDKP_tied_priority_players) do
		transformed_priority_players[index] = {}
		transformed_priority_players[index]["playerName"] = playerName
		transformed_priority_players[index]["rollResult"] = 0
	end
	TnTDKP_tied_priority_players = transformed_priority_players

	-- Separate out all of the winners from the "+"-separated string
	local formattedString, numWinners = string.gsub(winnerString, "+", ", ")
	SendChatMessage(formattedString .. " ROLL NOW", RAID, CEPGP_LANGUAGE);
end

function TnTDKP_checkIfAllPriorityTieBreakerRollsAreInAndDetermineWinner()
	local numRollsWeAreWaitingFor = CEPGP_ntgetn(TnTDKP_tied_priority_players)
	local numRollsReceived = 0
	for index, playerRecord in pairs(TnTDKP_tied_priority_players) do
		if playerRecord["rollResult"] > 0 then
			numRollsReceived = numRollsReceived + 1

			-- All rolls are in for the current item. Determine winner.
			if numRollsReceived == numRollsWeAreWaitingFor then
				local highRoll = 0
				local winner = "No One"
				for index, playerRecord in pairs(TnTDKP_tied_priority_players) do
					if playerRecord["rollResult"] > highRoll then
						highRoll = playerRecord["rollResult"]
						winner = playerRecord["playerName"]
					elseif playerRecord["rollResult"] == highRoll then
						winner = winner .. "+" .. playerRecord["playerName"]
					end
				end

				-- Determine the actual winner, and re-initiate the roll if necessary
				if string.find(winner, "+") then
					TnTDKP_initTableAndSolicitPriorityTiebreakerRolls(winner)
				else
					-- A winner has been determined!
					TnTDKP_tied_priority_players = {}
					CEPGP_distPlayer = winner
					SendChatMessage(winner .. " wins the Priority Tie-Breaker Rolloff!", RAID, CEPGP_LANGUAGE);
					return
				end
			end
		end
	end
end

-- For a given ItemID, test that the following Criteria are met:
-- 1. The item exists on a Priority Registry
-- 2. There is at least one Main or Reserve raider in this raid
--    with this item on their Priority registry
function TnTDKP_eligiblePriorityRecipientIsInRaid(itemID)
	local eligibleRecipientInRaid = false
	if not CEPGP_tContains(PLAYER_PRIORITY_REGISTRY, itemID, true) then
		return eligibleRecipientInRaid
	end
	-- Iterate over all potential recipients and make sure at least one is present
	for player,quantity in pairs(PLAYER_PRIORITY_REGISTRY[itemID]) do
		if CEPGP_tContains(CEPGP_raidRosterAndRelatedMetadata, player, true) then
			if not CEPGP_tContains(mainRaiders, player) and not CEPGP_tContains(reserveRaiders, player) then
				CEPGP_print(format("Player: \"%s\" has itemID: %s on their Priority list, but they aren't a Core or Reserve raider. Disregarding.", player, itemID), true)
			else
				-- As long as there's one match, it's good enough
				return true
			end
		end
	end
	return eligibleRecipientInRaid
end

-- For a given ItemID, test that the following Criteria are met:
-- 1. The item exists on a Lottery Registry
-- 2. There is at least one Main or Reserve raider in this raid
--    with this item on their Lottery registry
function TnTDKP_eligibleLotteryRecipientIsInRaid(itemID)
	local eligibleRecipientInRaid = false
	if not CEPGP_tContains(PLAYER_LOTTERY_REGISTRY, itemID, true) then
		return eligibleRecipientInRaid
	end
	-- Iterate over all potential recipients and make sure at least one is present
	for player,quantity in pairs(PLAYER_LOTTERY_REGISTRY[itemID]) do
		if CEPGP_tContains(CEPGP_raidRosterAndRelatedMetadata, player, true) then
			if not CEPGP_tContains(mainRaiders, player) and not CEPGP_tContains(reserveRaiders, player) then
				CEPGP_print(format("Player: \"%s\" has itemID: %s on their Lottery list, but they aren't a Core or Reserve raider. Disregarding.", player, itemID), true)
			else
				-- As long as there's one match, it's good enough
				return true
			end
		end
	end
	return eligibleRecipientInRaid
end

function TnTDKP_manuallyDetermineWinnerForItem(itemID)
	TnTDKP_updateRaidRosterTable()

	-- This value doesn't matter, as it's only used as a key in the "LOOT_SLOT_CLEARED"
	-- branch of CEPGP_handleLoot(), which will only be fired if an item is MLed from a corpse.
	-- This flow represents manually determining a winner for an item we might have mistakenly
	-- looted to someone else, or a BoE we picked up from trash and didn't ML at that time
	local slot = 99 

	local name, link, _, _, _, _, _, _, equipSlot, tex = GetItemInfo(itemID)

	-- I will be replacing this entire block of code with a call to similar logic in TnTDKP_determineLootWinners() once that is ready
	local distMethod = "Open Roll"
	if CEPGP_tContains(PLAYER_PRIORITY_REGISTRY, itemID, true)
		and TnTDKP_eligiblePriorityRecipientIsInRaid(itemID)
		and not TnTDKP_determineIfPriorityWinnerCantAffordAndShouldRunLotteryInstead(itemID) then
		distMethod = "Priority"
	elseif CEPGP_tContains(PLAYER_LOTTERY_REGISTRY, itemID, true) and TnTDKP_eligibleLotteryRecipientIsInRaid(itemID) then
		distMethod = "Lottery"
	else
		distMethod = "Open Roll"
	end
	TnTDKP_execute_winner_determination_logic_and_announce(itemID, distMethod, link, 99)
end