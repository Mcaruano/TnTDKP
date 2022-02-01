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
		local DKP = TnTDKP_getLotteryDKP(nameWithoutServer, "T4")
		SendChatMessage(format("[Report for %s] Lottery DKP = " .. DKP, nameWithoutServer), WHISPER, CEPGP_LANGUAGE, fullyQualifiedName);
	end
end

-- Awards DKP only if the boss encounter was actually defeated
function CEPGP_handleCombat(bossEncounter, except)
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
		local tier = "T4"
		if CEPGP_tContains(tierFourBossConfig, bossEncounter, true) then
			DKP = tierFourBossConfig[bossEncounter]["KillDKPAward"]
			tier = "T4"
		elseif CEPGP_tContains(tierFiveBossConfig, bossEncounter, true) then
			DKP = tierFiveBossConfig[bossEncounter]["KillDKPAward"]
			tier = "T5"
		elseif CEPGP_tContains(tierSixBossConfig, bossEncounter, true) then
			DKP = tierSixBossConfig[bossEncounter]["KillDKPAward"]
			tier = "T6"
		elseif CEPGP_tContains(tierSixPointFiveBossConfig, bossEncounter, true) then
			DKP = tierSixPointFiveBossConfig[bossEncounter]["KillDKPAward"]
			tier = "T6.5"
		end
		if DKP > 0 then
			-- For Raidwide DKP Awards, we use the same Timestamp for each transaction record
			local timestamp = date("%c", time())

			-- If a T4 boss is killed, we award DKP for the T4 DKP table only in Phase 1. This logic will
			-- need to be extended when future raid tiers are out so that T4 boss kills award T4 + T5 DKP, etc.
			if tier == "T4" then
				-- Announce the boss kill to Raid and Gchat
				SendChatMessage(bossEncounter .. " has been defeated! " .. DKP .. " T4 DKP has been awarded to the Raid & Standby", RAID, CEPGP_LANGUAGE);
				CEPGP_AddRaidDKP(timestamp, DKP, nil, bossEncounter, "T4");
			elseif tier == "T5" then
				-- Announce the boss kill to Raid and Gchat
				SendChatMessage(bossEncounter .. " has been defeated! " .. DKP .. " T5 DKP has been awarded to the Raid & Standby", RAID, CEPGP_LANGUAGE);
				CEPGP_AddRaidDKP(timestamp, DKP, nil, bossEncounter, "T5");
			elseif tier == "T6" then
				-- Announce the boss kill to Raid and Gchat
				SendChatMessage(bossEncounter .. " has been defeated! " .. DKP .. " T5 DKP has been awarded to the Raid & Standby", RAID, CEPGP_LANGUAGE);
				CEPGP_AddRaidDKP(timestamp, DKP, nil, bossEncounter, "T6");
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
							if tier == "T4" then
								CEPGP_addStandbyDKP(timestamp, standbyMember, DKP*(STANDBYPERCENT/100), "[T4 DKP " .. DKP .. "]: " .. bossEncounter .. " (Standby)", "T4");
							elseif tier == "T5" then
								CEPGP_addStandbyDKP(timestamp, standbyMember, DKP*(STANDBYPERCENT/100), "[T5 DKP " .. DKP .. "]: " .. bossEncounter .. " (Standby)", "T5");
							elseif tier == "T6" then
								CEPGP_addStandbyDKP(timestamp, standbyMember, DKP*(STANDBYPERCENT/100), "[T6 DKP " .. DKP .. "]: " .. bossEncounter .. " (Standby)", "T6");
							end
						end
					end
				end
				if tier == "T4" then
					SendChatMessage("Standby members have been awarded " .. DKP*(STANDBYPERCENT/100) .. " T4 DKP for Encounter: " .. bossEncounter, GUILD, CEPGP_LANGUAGE);
				elseif tier == "T5" then
					SendChatMessage("Standby members have been awarded " .. DKP*(STANDBYPERCENT/100) .. " T5 DKP for Encounter: " .. bossEncounter, GUILD, CEPGP_LANGUAGE);
				elseif tier == "T6" then
					SendChatMessage("Standby members have been awarded " .. DKP*(STANDBYPERCENT/100) .. " T6 DKP for Encounter: " .. bossEncounter, GUILD, CEPGP_LANGUAGE);
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

	-- Determine if Al'ar died twice (Phase 1 & Phase 2)
	-- if encounterName == "Al'ar" then
	-- 	CEPGP_kills = CEPGP_kills + 1;
	-- 	if CEPGP_kills == 2 then
	-- 		return true;
	-- 	else
	-- 		return false;
	-- 	end
	-- end
	
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
					-- This block only gets hit if a CEPGP_distPlayer (AKA a recipient) was set, yet the loot mode wasn't
					-- Priority or Lottery. AKA this should never be hit based on how I've designed the logic
					SendChatMessage(CEPGP_distItemLink .. " was distributed without cost", GUILD, CEPGP_LANGUAGE);
				end
				CEPGP_distPlayer = "";
				CEPGP_distribute_popup:Hide();
				CEPGP_distribute:Hide();
				_G["distributing"]:Hide();
				CEPGP_loot:Show();
			else
				-- If CEPGP_distPlayer was not set this likely means that the item was distributed via Open Roll
				CEPGP_distributing = false;
				SendChatMessage(CEPGP_distItemLink .. " has been distributed without DKP", GUILD, CEPGP_LANGUAGE);
				local distItemID = tonumber(CEPGP_DistID)
				local tier = determineRaidTierFromItemID(tonumber(distItemID))
				TnTDKP_logOpenTransaction(tonumber(distItemID), tier)
				CEPGP_distribute_popup:Hide();
				CEPGP_distribute:Hide();
				_G["distributing"]:Hide();
				CEPGP_loot:Show();
			end
		end
		CEPGP_LootFrame_Update(false);
	end	
end