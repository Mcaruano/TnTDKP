local TAG = "Handlers.lua"

-- Handles "CHAT_MSG_WHISPER" events.
function CEPGP_handleComms(event, arg1, arg2)
	-- Trim the "-Whitemane" from the player name
	local fullyQualifiedName = arg2
	local nameWithoutServer = arg2
	if string.find(arg2, "-") then
		nameWithoutServer = string.sub(arg2, 0, string.find(arg2, "-")-1);
	end
	if event == "CHAT_MSG_WHISPER" and string.lower(arg1) == "!me" then
		local DKP = TnTDKP_getLotteryDKP(nameWithoutServer, "T1")
		SendChatMessage(format("[Report for %s] Lottery DKP = " .. DKP, nameWithoutServer), WHISPER, CEPGP_LANGUAGE, fullyQualifiedName);
	end
end

-- Awards DKP only if the boss encounter was actually defeated
function CEPGP_handleCombat(bossEncounter, except)
	if bossEncounter == "The Prophet Skeram" and not except then
		return;
	end
	local DKP = 0;

	-- Determine the Raid "rank" of the AddOn Administrator
	-- 0 = Raid Member, 1 == Raid Assist, 2 = Raid leader (http://wowprogramming.com/docs/api/GetRaidRosterInfo.html)
	local rank;
	for i = 1, GetNumGroupMembers() do
		if UnitName("player") == GetRaidRosterInfo(i) then
			_, rank = GetRaidRosterInfo(i);
		end
	end
	if ((GetLootMethod() == "master" and CEPGP_isML() == 0) or (GetLootMethod() == "group" and rank == 2)) or CEPGP_debugMode then
		local wasDefeated = CEPGP_confirmBossEncounterDefeated(bossEncounter);
		-- We don't do anything unless the boss was killed
		if not wasDefeated then
			return;
		end
		local tier = "T1"
		if CEPGP_tContains(tierOneBossConfig, bossEncounter, true) then
			DKP = tierOneBossConfig[bossEncounter]["KillDKPAward"]
			tier = "T1"
		elseif CEPGP_tContains(tierTwoBossConfig, bossEncounter, true) then
			DKP = tierTwoBossConfig[bossEncounter]["KillDKPAward"]
			tier = "T2"
		elseif CEPGP_tContains(tierTwoPointFiveBossConfig, bossEncounter, true) then
			DKP = tierTwoPointFiveBossConfig[bossEncounter]["KillDKPAward"]
			tier = "T2.5"
		elseif CEPGP_tContains(tierThreeBossConfig, bossEncounter, true) then
			DKP = tierThreeBossConfig[bossEncounter]["KillDKPAward"]
			tier = "T3"
		end
		if DKP > 0 then
			-- For Raidwide DKP Awards, we use the same Timestamp for each transaction record
			local timestamp = date("%c", time())

			-- If a T1 boss is killed, we award DKP for the T1, T2, T2.5, and T3 DKP tables
			-- if tier == "T1" then
			-- 	-- Announce the boss kill to Raid and Gchat
			-- 	SendChatMessage(bossEncounter .. " has been defeated! " .. DKP .. " T1, T2, T2.5, and T3 DKP has been awarded to the Raid & Standby", RAID, CEPGP_LANGUAGE);
			-- 	SendChatMessage(bossEncounter .. " has been defeated! " .. DKP .. " T1, T2, T2.5, and T3 DKP has been awarded to the Raid & Standby", GUILD, CEPGP_LANGUAGE);
			-- 	CEPGP_AddRaidDKP(timestamp, DKP, nil, bossEncounter, "T1");
			-- 	CEPGP_AddRaidDKP(timestamp, DKP, nil, bossEncounter, "T2");
			-- 	CEPGP_AddRaidDKP(timestamp, DKP, nil, bossEncounter, "T2.5");
			-- 	CEPGP_AddRaidDKP(timestamp, DKP, nil, bossEncounter, "T3");
				
			-- -- If a T2 boss is killed, we only award DKP for the T2, T2.5, and T3 DKP tables
			-- elseif tier == "T2" then
			-- 	-- Announce the boss kill to Raid and Gchat
			-- 	SendChatMessage(bossEncounter .. " has been defeated! " .. DKP .. " T2, T2.5, and T3 DKP has been awarded to the Raid & Standby", RAID, CEPGP_LANGUAGE);
			-- 	SendChatMessage(bossEncounter .. " has been defeated! " .. DKP .. " T2, T2.5, and T3 DKP has been awarded to the Raid & Standby", GUILD, CEPGP_LANGUAGE);
			-- 	CEPGP_AddRaidDKP(timestamp, DKP, nil, bossEncounter, "T2");
			-- 	CEPGP_AddRaidDKP(timestamp, DKP, nil, bossEncounter, "T2.5");
			-- 	CEPGP_AddRaidDKP(timestamp, DKP, nil, bossEncounter, "T3");

			-- -- If a T2.5 boss is killed, we only award DKP for the T2.5 and T3 DKP tables
			-- elseif tier == "T2.5" then
			-- 	-- Announce the boss kill to Raid and Gchat
			-- 	SendChatMessage(bossEncounter .. " has been defeated! " .. DKP .. " T2.5 and T3 DKP has been awarded to the Raid & Standby", RAID, CEPGP_LANGUAGE);
			-- 	SendChatMessage(bossEncounter .. " has been defeated! " .. DKP .. " T2.5 and T3 DKP has been awarded to the Raid & Standby", GUILD, CEPGP_LANGUAGE);
			-- 	CEPGP_AddRaidDKP(timestamp, DKP, nil, bossEncounter, "T2.5");
			-- 	CEPGP_AddRaidDKP(timestamp, DKP, nil, bossEncounter, "T3");
			-- If a T3 boss is killed, we only award DKP for the T3 DKP table
			if tier == "T3" then
				-- Announce the boss kill to Raid and Gchat
				SendChatMessage(bossEncounter .. " has been defeated! " .. DKP .. " T3 DKP has been awarded to the Raid & Standby, as well as a proportional amount of T1, T2, and T2.5 DKP.", RAID, CEPGP_LANGUAGE);
				SendChatMessage(bossEncounter .. " has been defeated! " .. DKP .. " T3 DKP has been awarded to the Raid & Standby,  as well as a proportional amount of T1, T2, and T2.5 DKP.", GUILD, CEPGP_LANGUAGE);
				CEPGP_AddRaidDKP(timestamp, DKP, nil, bossEncounter, "T3");
				CEPGP_AddRaidDKP(timestamp, ceil(DKP*0.75), nil, bossEncounter, "T2.5");
				CEPGP_AddRaidDKP(timestamp, ceil(DKP*0.5), nil, bossEncounter, "T2");
				CEPGP_AddRaidDKP(timestamp, ceil(DKP*0.25), nil, bossEncounter, "T1");
			end
			-- Award standby members
			if STANDBYEP then
				for i = 1, table.getn(STANDBY_ROSTER) do
					-- We only award Standby DKP to players in the guild.
					local standbyMember = STANDBY_ROSTER[i]
					if CEPGP_tContains(CEPGP_guildRosterAndRelatedMetadata, standbyMember, true) then
						local _, _, _, _, _, _, _, _, online = GetGuildRosterInfo(CEPGP_guildRosterAndRelatedMetadata[standbyMember][1]);
		
						-- Enforce the Online requirement if STANDBYOFFLINE override not enabled
						if online == 1 or STANDBYOFFLINE then
							-- if tier == "T1" then
							-- 	CEPGP_addStandbyDKP(timestamp, standbyMember, DKP*(STANDBYPERCENT/100), "[T1 DKP " .. DKP .. "]: " .. bossEncounter .. " (Standby)", "T1");
							-- 	CEPGP_addStandbyDKP(timestamp, standbyMember, DKP*(STANDBYPERCENT/100), "[T2 DKP " .. DKP .. "]: " .. bossEncounter .. " (Standby)", "T2");
							-- 	CEPGP_addStandbyDKP(timestamp, standbyMember, DKP*(STANDBYPERCENT/100), "[T2.5 DKP " .. DKP .. "]: " .. bossEncounter .. " (Standby)", "T2.5");
							-- 	CEPGP_addStandbyDKP(timestamp, standbyMember, DKP*(STANDBYPERCENT/100), "[T3 DKP " .. DKP .. "]: " .. bossEncounter .. " (Standby)", "T3");
							-- elseif tier == "T2" then
							-- 	CEPGP_addStandbyDKP(timestamp, standbyMember, DKP*(STANDBYPERCENT/100), "[T2 DKP " .. DKP .. "]: " .. bossEncounter .. " (Standby)", "T2");
							-- 	CEPGP_addStandbyDKP(timestamp, standbyMember, DKP*(STANDBYPERCENT/100), "[T2.5 DKP " .. DKP .. "]: " .. bossEncounter .. " (Standby)", "T2.5");
							-- 	CEPGP_addStandbyDKP(timestamp, standbyMember, DKP*(STANDBYPERCENT/100), "[T3 DKP " .. DKP .. "]: " .. bossEncounter .. " (Standby)", "T3");
							-- elseif tier == "T2.5" then
							-- 	CEPGP_addStandbyDKP(timestamp, standbyMember, DKP*(STANDBYPERCENT/100), "[T2.5 DKP " .. DKP .. "]: " .. bossEncounter .. " (Standby)", "T2.5");
							-- 	CEPGP_addStandbyDKP(timestamp, standbyMember, DKP*(STANDBYPERCENT/100), "[T3 DKP " .. DKP .. "]: " .. bossEncounter .. " (Standby)", "T3");
							if tier == "T3" then
								CEPGP_addStandbyDKP(timestamp, standbyMember, DKP*(STANDBYPERCENT/100), "[T3 DKP " .. DKP .. "]: " .. bossEncounter .. " (Standby)", "T3");
								CEPGP_addStandbyDKP(timestamp, standbyMember, ceil(DKP*0.75)*(STANDBYPERCENT/100), "[T2.5 DKP " .. ceil(DKP*0.75) .. "]: " .. bossEncounter .. " (Standby)", "T2.5");
								CEPGP_addStandbyDKP(timestamp, standbyMember, ceil(DKP*0.5)*(STANDBYPERCENT/100), "[T2 DKP " .. ceil(DKP*0.5) .. "]: " .. bossEncounter .. " (Standby)", "T2");
								CEPGP_addStandbyDKP(timestamp, standbyMember, ceil(DKP*0.25)*(STANDBYPERCENT/100), "[T1 DKP " .. ceil(DKP*0.25) .. "]: " .. bossEncounter .. " (Standby)", "T1");
							end
						end
					end
				end
				-- if tier == "T1" then
				-- 	SendChatMessage("Standby members have been awarded " .. DKP*(STANDBYPERCENT/100) .. " T1, T2, T2.5, and T3 DKP for Encounter: " .. bossEncounter, GUILD, CEPGP_LANGUAGE);
				-- elseif tier == "T2" then
				-- 	SendChatMessage("Standby members have been awarded " .. DKP*(STANDBYPERCENT/100) .. " T2, T2.5, and T3 DKP for Encounter: " .. bossEncounter, GUILD, CEPGP_LANGUAGE);
				-- elseif tier == "T2.5" then
				-- 	SendChatMessage("Standby members have been awarded " .. DKP*(STANDBYPERCENT/100) .. " T2.5 and T3 DKP for Encounter: " .. bossEncounter, GUILD, CEPGP_LANGUAGE);
				if tier == "T3" then
					SendChatMessage("Standby members have been awarded " .. DKP*(STANDBYPERCENT/100) .. " T3 DKP for Encounter: " .. bossEncounter, GUILD, CEPGP_LANGUAGE);
				end
				CEPGP_UpdateTrafficScrollBar();
				SendChatMessage("Whisper me \"" .. CEPGP_standby_whisper_msg .. "\" from your MAIN to add yourself to the Standby list", GUILD, CEPGP_LANGUAGE);
			end
		end
		CEPGP_UpdateStandbyScrollBar();
	end
end

-- Returns true if the given boss encounter is actually defeated.
-- There are several encounters which require multiple units to die before being
-- considered defeated, this logic determines if the required number of units
-- have been killed for each such encounter.
function CEPGP_confirmBossEncounterDefeated(encounterName)

	-- Determine if all 8 of Majordomo's advisors have been killed
	if encounterName == "Majordomo Executus" then
		CEPGP_kills = CEPGP_kills + 1;
		if CEPGP_kills == 8 then
			return true;
		else
			return false;
		end
	end
	
	-- Razorgore is only successfully defeated if he is killed AND all 30 of his eggs
	-- have been killed. Egg kills are captured via "SPELL_CAST_SUCCESS" events, and
	-- as such are tracked in CEPGP_OnEvent()
	-- if encounterName == "Razorgore the Untamed" then
	-- 	if CEPGP_kills == 30 then --For this encounter, CEPGP_kills is used for the eggs
	-- 		return true;
	-- 	else
	-- 		return false;
	-- 	end
	-- end
	
	-- Determine if all 3 bugs have been killed
	if encounterName == "The Bug Trio" then
		CEPGP_kills = CEPGP_kills + 1;
		if CEPGP_kills == 3 then
			return true;
		else
			return false;
		end
	end
	
	-- Determine if both emperors have been killed
	if encounterName == "The Twin Emperors" then
		CEPGP_kills = CEPGP_kills + 1;
		if CEPGP_kills == 2 then
			return true;
		else
			return false;
		end
	end
	
	-- Determine if all four horsemen have been killed
	if encounterName == "The Four Horsemen" then
		CEPGP_kills = CEPGP_kills + 1;
		if CEPGP_kills == 4 then
			return true;
		else
			return false;
		end
	end
	return true;
end

function CEPGP_handleLoot(event, arg1, arg2)
	-- If the "LOOT_CLOSED" event was fired, we need to tear down the Distribute Frame
	-- and reset all related variables
	if event == "LOOT_CLOSED" then
		CEPGP_distributing = false;
		CEPGP_distItemLink = nil;
		_G["distributing"]:Hide();
		if CEPGP_mode == "loot" then
			CEPGP_cleanTable();
			HideUIPanel(CEPGP_frame);
		end
		HideUIPanel(CEPGP_distribute_popup);
		--HideUIPanel(CEPGP_button_loot_dist);
		HideUIPanel(CEPGP_loot);
		HideUIPanel(CEPGP_distribute);
		HideUIPanel(CEPGP_loot_CEPGP_distributing);
		HideUIPanel(CEPGP_button_loot_dist);
		if UnitInRaid("player") then
			CEPGP_toggleFrame(CEPGP_raid);
		elseif GetGuildRosterInfo(1) then
			CEPGP_toggleFrame(CEPGP_guild);
		else
			HideUIPanel(CEPGP_frame);
			if CEPGP_isML() == 0 then
				distributing:Hide();
			end
		end
		
		if CEPGP_distribute:IsVisible() == 1 then
			HideUIPanel(CEPGP_distribute);
			ShowUIPanel(CEPGP_loot);
			TnTDKP_lottery_participants = {};
			TnTDKP_priority_recipients = {};
			CEPGP_UpdateLootScrollBar();
		end

	-- If LOOT_OPENED was fired, run our core logic to determine what items are on the NEED Table
	elseif event == "LOOT_OPENED" and (UnitInRaid("player") or CEPGP_debugMode) then
		if CEPGP_debugMode then print(format("[%s] LOOT_OPENED event received", TAG)) end

		-- This populates the loot frame with the items
		CEPGP_LootFrame_Update(true);
		ShowUIPanel(CEPGP_button_loot_dist);

	-- If LOOT_SLOT_CLEARED was fired that means a piece of loot was distributed. Print an informative message
	-- and refresh the LootFrame by calling CEPGP_LootFrame_Update()
	-- CEPGP_distPlayer gets set in Button.lua, when a particular player in the "CEPGP_distribute_popup" is clicked
	elseif event == "LOOT_SLOT_CLEARED" then
		if CEPGP_distributing and arg1 == CEPGP_lootSlot then
			if CEPGP_distPlayer ~= "" then
				CEPGP_distributing = false;
				local distItemID = tonumber(CEPGP_DistID)
				local tier = determineRaidTierFromItemID(tonumber(distItemID))
				local dkpCost = tonumber(TnTDKP_determineDKPCostOfItem(distItemID))
				local dkpDisplayValue = dkpCost
				if dkpCost ~= 0 then
					dkpDisplayValue = dkpCost * -1
				end
				if TnTDKP_lootDistMode == "Priority" then
					SendChatMessage("Awarded " .. CEPGP_distItemLink .. " to ".. CEPGP_distPlayer .. " for " .. dkpDisplayValue .. " (" .. tier .. ") Priority DKP", GUILD, CEPGP_LANGUAGE);
					TnTDKP_removeItemFromPriorityList(CEPGP_distPlayer, tonumber(distItemID))
					TnTDKP_addOrRemovePriorityDKP(CEPGP_distPlayer, dkpCost, distItemID, CEPGP_distItemLink, tier);
				elseif TnTDKP_lootDistMode == "Lottery" then
					SendChatMessage("Awarded " .. CEPGP_distItemLink .. " to ".. CEPGP_distPlayer .. " for " .. dkpDisplayValue .. " (" .. tier .. ") Lottery DKP", GUILD, CEPGP_LANGUAGE);
					TnTDKP_removeItemFromLotteryList(CEPGP_distPlayer, tonumber(distItemID))

					-- This call handles the case where CEPGP_distPlayer had item with ItemID = distItemID on their Priority list, but didn't have
					-- enough Priority DKP to take it at Priority, causing the item to be distributed via Lottery instead. If CEPGP_distPlayer wins
					-- the item in this way (at Lottery instead of Priority) we need to make sure the item is removed from their Priority
					-- list when all is said and done.
					if CEPGP_tContains(PLAYER_PRIORITY_REGISTRY, tonumber(distItemID), true) then
						if CEPGP_tContains(PLAYER_PRIORITY_REGISTRY[tonumber(distItemID)], CEPGP_distPlayer, true) then
							TnTDKP_removeItemFromPriorityList(CEPGP_distPlayer, tonumber(distItemID))
						end
					end

					TnTDKP_addOrRemoveLotteryDKP(CEPGP_distPlayer, dkpCost, distItemID, CEPGP_distItemLink, tier);
				else
					-- TODO: This distPlayer will have to be set as a result of the Open Roll item being distributed
					SendChatMessage(CEPGP_distItemLink .. " was distributed for without cost", GUILD, CEPGP_LANGUAGE);
					-- SendChatMessage("Awarded " .. CEPGP_distItemLink .. " to ".. CEPGP_distPlayer .. " for free (Open Roll)", GUILD, CEPGP_LANGUAGE);
					-- TnTDKP_logOpenTransaction(CEPGP_distPlayer, CEPGP_DistID)
				end
				CEPGP_distPlayer = "";
				CEPGP_distribute_popup:Hide();
				CEPGP_distribute:Hide();
				_G["distributing"]:Hide();
				CEPGP_loot:Show();
			else
				-- If CEPGP_distPlayer was not set, that means an item was MLed to someone without going through EPGPs functions
				-- CEPGP_distPlayer being set implies that the decision has been made via EPGP rules
				CEPGP_distributing = false;
				SendChatMessage(CEPGP_distItemLink .. " has been distributed without DKP", GUILD, CEPGP_LANGUAGE);
				CEPGP_distribute_popup:Hide();
				CEPGP_distribute:Hide();
				_G["distributing"]:Hide();
				CEPGP_loot:Show();
			end
		end
		CEPGP_LootFrame_Update(false);
	end	
end