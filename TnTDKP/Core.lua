--[[ Globals ]]--
CEPGP = CreateFrame("Frame");
MAX_INT = 2147483646
SLASH_TNTDKP1 = "/tntdkp";
SLASH_TNTDKP2 = "/tnt";
CEPGP_mode = "guild"; -- This is used to indicate which workflow in the UI we are currently in. This way we can have singular methods that clear and populate frames, which will switch based on what mode we're in
TnTDKP_displayMode = "priority"; -- Toggle indicating which table to show in the frame - the "Priority" table or the "Lottery" table based on the CheckBox in the main frame
TnTDKP_awardMode = "priority"; -- Used when determining which table the given action should write to based on the CheckBox in CEPGP_context_popup
TnTDKP_selectedRole = "None"; -- This global variable is used to communicate which Role was selected from the Role dropdown when "Confirm" is pressed from the Context Popup
CEPGP_distPlayer = "";
TnTDKP_lootDistMode = "Priority" -- This is a flag used to communicate what mode an item was just distributed it when the "LOOT_SLOT_CLEARED" event is received
CEPGP_distGP = false;
CEPGP_lootSlot = nil;
CEPGP_DistID = nil; -- At any point, this is the ItemID of the item presently being distributed. Referenced in various parts of the codebase
CEPGP_distSlot = nil; -- Similar to the above, this would be the equip slot of the item
CEPGP_distItemLink = nil; -- Similar to the above, this would be the itemlink of the item
CEPGP_debugMode = false;
CEPGP_critReverse = false; -- Criteria reverse
CEPGP_distributing = false;
CEPGP_looting = false;
CEPGP_criteria = 4; -- This is used by CEPGP_tSort() to sort a given set of data. There is a lot of logic for it in Utility.CEPGP_populateFrame()
CEPGP_kills = 0;
CEPGP_frames = {CEPGP_guild, CEPGP_raid, CEPGP_loot, CEPGP_distribute, CEPGP_options, CEPGP_distribute_popup, CEPGP_context_popup, CEPGP_traffic, CEPGP_standby};
CEPGP_LANGUAGE = GetDefaultLanguage("player");
TnTDKP_lottery_participants = {}; -- A table used to keep track of all of the players who are currently involved in the Lottery for the item designated by CEPGP_DistID
TnTDKP_priority_recipients = {}; -- A table used to keep track of which players have been determined as priority recipients from this boss kill thus far, prior to distribution
TnTDKP_tied_priority_players = {} -- Table used to keep track of Priority players who are currently tied for the active CEPGP_DistID. These are used when listing for the rolls
CEPGP_itemsTable = {};
CEPGP_guildRosterAndRelatedMetadata = {}; -- This is very much the GUILD roster. Keyed by name, and has sub-keys 1 & 2 for indexInGuild and Class. Not saved to disk, always refreshed.
STANDBY_ROSTER = {}; -- The roster of the standby list
CEPGP_raidRosterAndRelatedMetadata = {}; -- The roster of the current raid group. Keyed by name, and has sub-keys 1 & 2 for Class and RaidGroup. Not saved to disk, always refreshed.
CEPGP_ElvUI = nil; --nil or 1, used when determining where to mount one of the buttons
CEPGP_RAZORGORE_EGG_COUNT = 0;
TnTDKP_tierToDisplay = "T4" -- This is the global variable which holds the state of the T4/T5 checkboxes on various flows of the AddOn

--[[ SAVED VARIABLES ]]--
BASEGP = 1500;
STANDBYEP = true;
STANDBYOFFLINE = true;
CEPGP_standby_whisper_msg = "!standby";
STANDBYPERCENT = 100;

-- Managing Player Roles can be a little tricky as it can be done both on our Web Portal (back-end) and in
-- the AddOn GUI directly. We start each raid night by copying and pasting the PLAYER_ROLE_CONFIG
-- from our back-end into our "TnTDKP.lua" (TODO: Rename) AddOn data file. Over the course of the raid night,
-- these values might change as the AddOn Administrator updates players' Roles via the GUI, which get reflected
-- in the PLAYER_ROLE_CONFIG Table object. At the END of a raid night, the AddOn Administrator uploads
-- the TnTDKP.lua file to our back-end for processing - during this processing is when any Roles which have
-- changed during the raid will be stored in our back-end.

-- No other Data Structure can be modified by players on our back-end via the Web Interface and also modified
-- in the game itself. Due to this, there is ONE edge-case in this data flow that will result in a loss
-- of data, and that's if a player updates their Role on our Website AFTER the raid has begun AND we've also
-- updated their Role from the AddOn's GUI. Given the lifecycle described above, this would result in the
-- Role we've set in the AddOn's GUI overwriting the value the user set at the end of the raid night when
-- the CEPGP.lua file is uploaded. This edge case can be prevented altogether if we prevent raid members
-- from changing their own role, which is a good idea IMO.
PLAYER_ROLE_CONFIG = {};

local TAG = "Core.lua"

-- ================================================================================================================
-- =================================================== BACKLOG ====================================================
-- ================================================================================================================
-- ==== Features I Should Add ====
-- Extend the currently-supported chat commands:
	-- !help - Displays a list of supported commands
	-- !me - tells you your current Priority and Lottery DKP
		-- Only functions if user is in the raid
	-- Add a !<class> whisper command to summarize all of a given class
		-- Only functions if user is in the raid
	-- Add a !<itemID> whisper command to show who would get it if it dropped, as well as who has it on priority/lottery
		-- Only functions if user is in the raid
-- Capture Trade events as a potential egress for loot distribution. Use it to compare the distID, identify a recipient for logging, and set CEPGP_distributing = false.
	-- This would be a great way to wrap-up the manual distribution flow.
-- When manually adding items to a player's Priority list from the AddOn (a flow which should rarely, if ever, happen),
	-- enforce the priority list adding logic to have 1 item of each slot, and special-case handling for items like the Ancient Petrified Leaf

-- ==== Nice-to-Have Features ====
-- Add a View where the administrator can see everyone's Priority/Lottery lists in a nice list view identical to the "Standby" view, with the X's to remove items
-- Capture all Open Rolls and present them in a frame, sorted descending. (Can consider making this a separate addon)
-- See about resolving each winner all at once, if possible. This is not required, but would be neat to have
	-- Add useful print statements describing who was the runner-up for each item

-- ==== Documentation/Cleanup ====
-- Code cleanup:
	-- Refactor the hell out of the methods which are all over the place and place them in sane locations
	-- Take a look at all method docs to be sure they are accurate
	-- Add more method docs
	-- Delete unused methods
-- Write the README:
	-- Should include a descriptive section about each of the pieces of data that needs to be imported
	-- Should include a descriptive section about what gets parsed when the file is uploaded to the back-end
-- ================================================================================================================
-- ================================================================================================================
-- ================================================================================================================

  
--[[ EVENT AND COMMAND HANDLER ]]--
function CEPGP_OnEvent(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
	if event == "ADDON_LOADED" and arg1 == "TnTDKP" then --arg1 = addon name
		CEPGP_initialise();
	elseif event == "PLAYER_ENTERING_WORLD" then
		-- When the player enters world, we want to make sure to remind them to clear out the Standby Roster if
		-- the raid is over. We send this reminder only if they aren't in a raid. We have to delay it by 3 seconds
		-- because the client is super slow when it starts up, and it takes half a second or so to register that
		-- the player is in a raid. Just to be safe, we delay this check a full 3 seconds.
		local delayedFrame = CreateFrame("Frame")
		delayedFrame:Hide()
		delayedFrame:SetScript("OnShow", function(self)
			self.time = 3.0
		end)
		delayedFrame:SetScript("OnUpdate", function(self, elapsed)
			self.time = self.time - elapsed
			if self.time <= 0 then
				self:Hide()

				-- If we're in a raid group, initialize the CEPGP_raidRosterAndRelatedMetadata table
				if UnitInRaid("player") then
					CEPGP_UpdateRaidScrollBar()
				elseif STANDBY_ROSTER ~= nil and CEPGP_ntgetn(STANDBY_ROSTER) > 0 then
						message(format("You're not currently in a Raid, but you still have %s players on the Standby list. You should probably clear them out.", CEPGP_ntgetn(STANDBY_ROSTER)), true)
				end
			end
		end)
		delayedFrame:Show()

	-- If players join or leave the raid we need to update the roster. Additionally, if we make a
	-- call to "GuildRoster()" the GUILD_ROSTER_UPDATE event will come back, indicating that the roster
	-- has been updated so we can refresh our own table
	elseif event == "GUILD_ROSTER_UPDATE" or event == "GROUP_ROSTER_UPDATE" then
		CEPGP_rosterUpdate(event);
		
	elseif event == "CHAT_MSG_WHISPER" and string.lower(arg1) == CEPGP_standby_whisper_msg then
		-- Remove the "-Whitemane" from the username for further processing
		local nameWithoutServer = arg2
		if string.find(arg2, "-") then
			nameWithoutServer = string.sub(arg2, 0, string.find(arg2, "-")-1);
		end
		if not CEPGP_tContains(CEPGP_raidRosterAndRelatedMetadata, nameWithoutServer, true) then
			CEPGP_addToStandby(nameWithoutServer);
		end
			
	-- elseif (event == "CHAT_MSG_WHISPER" and string.lower(arg1) == "!info") or
	-- 	(event == "CHAT_MSG_WHISPER" and string.lower(arg1) == "!me") or
	-- 	(event == "CHAT_MSG_WHISPER" and (string.lower(arg1) == "!infoguild" or string.lower(arg1) == "!inforaid" or string.lower(arg1) == "!infoclass")) then
	-- 		CEPGP_handleComms(event, arg1, arg2);
	
	elseif (event == "CHAT_MSG_WHISPER" and string.lower(arg1) == "!me") then
			CEPGP_handleComms(event, arg1, arg2);
	
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, action = CombatLogGetCurrentEventInfo();
		local name;
		if action == "UNIT_DIED" then
			_, _, _, _, _, _, _, _, name = CombatLogGetCurrentEventInfo();

			-- Certain fights have several mobs that need to be killed in order for the
			-- encounter to be considered over. For these fights, I take all of the unique
			-- names of the various mobs which need to die and map them all to a single
			-- EncounterName, simply keying off of the raw number of significant mobs
			-- killed during the fight to evaluate whether or not the fight is actually
			-- over. The logic determining how many significant mobs are required to be
			-- killed for each fight is contained in CEPGP_confirmBossEncounterDefeated()
			if name == "Kiggler the Crazed" or name == "Blindeye the Seer" or name == "Olm the Summoner" or name == "Krosh Firehand" then
				name = "High King Maulgar"
			end

			-- Make sure this is a boss we support
			if tierFourBossConfig[name] or tierFiveBossConfig[name] or tierSixBossConfig[name] or tierSixPointFiveBossConfig[name] then
				CEPGP_handleCombat(name)
			end
		
	elseif (event == "LOOT_OPENED" or event == "LOOT_CLOSED" or event == "LOOT_SLOT_CLEARED") then
		CEPGP_handleLoot(event, arg1, arg2);
		
	elseif event == "CHAT_MSG_SYSTEM" then
		-- Regex matches "Akaran rolls 1 (1-100)"
		local name, rollResult, minRoll, maxRoll = arg1:match("^(.+) rolls (%d+) %((%d+)%-(%d+)%)$")

		-- CEPGP_lootSlot == 99 signifies a manual loot distribution has been initiated
		if CEPGP_distributing or CEPGP_lootSlot == 99 then
			if name then
				if name == UnitName("player") then

					-- In the case of Open Rolls, when the master looter wants to partake in an Open Roll
					-- we need to make sure the Lottery Logic contained in this code block doesn't trigger
					local isOpenRollAndShouldSkip = false
					if TnTDKP_lootDistMode then
						if TnTDKP_lootDistMode == "Open Roll" then
							isOpenRollAndShouldSkip = true
						end
					end

					-- Determine if this player is on the Priority Players table
					local playerIsOnPriorityTieBreakList = false
					for index, playerRecord in pairs(TnTDKP_tied_priority_players) do
						if playerRecord["playerName"] == name then
							playerIsOnPriorityTieBreakList = true
						end
					end
					
					-- Make sure that if the Administrator of this AddOn is participating in a Priority roll that this case is handled
					if tonumber(maxRoll) == 100 and playerIsOnPriorityTieBreakList then
						-- Log the roll result
						for index, playerRecord in pairs(TnTDKP_tied_priority_players) do
							if playerRecord["playerName"] == name then
								-- Make sure we only regard the very first roll from the player
								if playerRecord["rollResult"] == 0 then
									playerRecord["rollResult"] = tonumber(rollResult)
									CEPGP_print(format("%d roll result logged for %s", rollResult, name))
								else
									CEPGP_print(format("Disregarded roll from %s because he/she already rolled and got a %d", name, playerRecord["rollResult"]))
								end
							end
						end
						TnTDKP_checkIfAllPriorityTieBreakerRollsAreInAndDetermineWinner()
					else -- TODO: I can do an elseif and actually confirm that the maxRoll here is identical to the current lottery total
						
						-- Otherwise we're just running a Lottery roll
						if isOpenRollAndShouldSkip == false then
							for playerName,record in pairs(TnTDKP_lottery_participants) do
								local rangeMin = TnTDKP_lottery_participants[playerName]["RangeMin"]
								local rangeMax = TnTDKP_lottery_participants[playerName]["RangeMax"]
								if tonumber(rollResult) >= tonumber(rangeMin) and tonumber(rollResult) <= tonumber(rangeMax) then
									TnTDKP_lottery_participants = {}
									SendChatMessage(playerName .. " wins the lottery for " .. CEPGP_distItemLink .. "!", "RAID_WARNING", CEPGP_LANGUAGE);
									CEPGP_distPlayer = playerName
									return
								end
							end
						end
					end
				-- This block is for monitoring rolls coming back to resolve Priority tie-breakers
				elseif tonumber(maxRoll) == 100 then
					
					-- Determine if this player is on the Priority Players table
					local playerIsOnPriorityTieBreakList = false
					for index, playerRecord in pairs(TnTDKP_tied_priority_players) do
						if playerRecord["playerName"] == name then
							playerIsOnPriorityTieBreakList = true
						end
					end

					if playerIsOnPriorityTieBreakList then
						-- Log the roll result
						for index, playerRecord in pairs(TnTDKP_tied_priority_players) do
							if playerRecord["playerName"] == name then
								-- Make sure we only regard the very first roll from the player
								if playerRecord["rollResult"] == 0 then
									playerRecord["rollResult"] = tonumber(rollResult)
									CEPGP_print(format("%d roll result logged for %s", rollResult, name))
								else
									CEPGP_print(format("Disregarded roll from %s because he/she already rolled and got a %d", name, playerRecord["rollResult"]))
								end
							end
						end
						TnTDKP_checkIfAllPriorityTieBreakerRollsAreInAndDetermineWinner()
					end
				end
			end
		end
	elseif event == "PLAYER_REGEN_DISABLED" then -- Player has started combat
		if CEPGP_debugMode then
			CEPGP_print("Combat started");
		end
		CEPGP_kills = 0;
	end
end

-- Registers all of the slash commands the player who is running this AddOn can invoke
function SlashCmdList.TNTDKP(msg, editbox)
	msg = string.lower(msg);
	if msg == "" then
		CEPGP_print("TNT DKP Usage");
		CEPGP_print("|cFF80FF80show|r - |cFFFF8080Manually shows the TnTDKP window|r");
		CEPGP_print("|cFF80FF80setDefaultChannel channel|r - |cFFFF8080Sets the default channel to send confirmation messages. Default is Guild|r");
		
	elseif msg == "show" then
		CEPGP_populateFrame();
		ShowUIPanel(CEPGP_frame);
		CEPGP_updateGuild();
	
	elseif strfind(msg, "currentchannel") then
		CEPGP_print("Current channel to report: " .. getCurChannel());
		
	elseif strfind(msg, "debugmode") then
		CEPGP_debugMode = not CEPGP_debugMode;
		if CEPGP_debugMode then
			CEPGP_print("Debug Mode Enabled");
		else
			CEPGP_print("Debug Mode Disabled");
		end
		
	elseif strfind(msg, "debug") then
		CEPGP_debuginfo:Show();

	else
		CEPGP_print("|cFF80FF80" .. msg .. "|r |cFFFF8080is not a valid request. Type /tntdkp to check addon usage|r", true);
	end
end


-- Awards DKP to the entire raid. Logs the entire award as 40 separate Transactions to both the Need and Greed Transaction Tables.
-- Generates a single timestamp to use for each of these Transactions, yet still generates a unique TransactionID for
-- each transaction. 
-- timestamp - Since we can invoke this multiple times in sequence as we award DKP to separate tables for a single boss kill, we want
--             to maintain a consistent timestamp for all transactions from the same boss kill. As such, we generate the timestamp at
--             the higher level and pass it into each separate call, so that each event gets logged with the exact same timestamp
-- amount - The amount of DKP to award
-- msg - (Optional) a CUSTOM message. This will be added permanently in the Transactions table, and also broadcasted to the raid
-- encounter - (Optional) The boss that was killed. If a "msg" was not provided, the "encounter" will be used to generate a broadcast message
-- tier - The "Tier" of content this boss was from. Used to determine which DKP and Transaction tables to modify. Examples: "T4", "T5", etc.
function CEPGP_AddRaidDKP(timestamp, amount, msg, encounter, tier)
	if msg == nil and encounter == nil then
		CEPGP_print("DKP NOT awarded. Either a message or encounter is required and neither was provided.", true)
		return
	end

	-- Fetch a reference to the proper tables. This logic can't be abstracted to a helper method because if I return
	-- these, they won't be returned by Reference
	local priorityDKPTable = {}
	local lotteryDKPTable = {}
	local priorityTransactionsTable = {}
	local lotteryTransactionsTable = {}
	if tier == "T6.5" then
		priorityDKPTable = T6PT5_PRIORITY_DKP_TABLE
		lotteryDKPTable = T6PT5_LOTTERY_DKP_TABLE
		priorityTransactionsTable = T6PT5_PRIORITY_TRANSACTIONS
		lotteryTransactionsTable = T6PT5_LOTTERY_TRANSACTIONS
	elseif tier == "T6" then
		priorityDKPTable = T6_PRIORITY_DKP_TABLE
		lotteryDKPTable = T6_LOTTERY_DKP_TABLE
		priorityTransactionsTable = T6_PRIORITY_TRANSACTIONS
		lotteryTransactionsTable = T6_LOTTERY_TRANSACTIONS
	elseif tier == "T5" then
		priorityDKPTable = T5_PRIORITY_DKP_TABLE
		lotteryDKPTable = T5_LOTTERY_DKP_TABLE
		priorityTransactionsTable = T5_PRIORITY_TRANSACTIONS
		lotteryTransactionsTable = T5_LOTTERY_TRANSACTIONS
	elseif tier == "T4" then
		priorityDKPTable = T4_PRIORITY_DKP_TABLE
		lotteryDKPTable = T4_LOTTERY_DKP_TABLE
		priorityTransactionsTable = T4_PRIORITY_TRANSACTIONS
		lotteryTransactionsTable = T4_LOTTERY_TRANSACTIONS
	end

	-- If a custom message was provided, use it as the Transaction record description
	local actionMsg
	if msg then
		if amount <= 0 then
			actionMsg = "[" .. tier .. " DKP " .. amount .. "]: " .. msg
		else
			actionMsg = "[" .. tier .. " DKP +" .. amount .. "]: " .. msg
		end
	-- Otherwise, just use the encounter name as the message
	else
		if amount <= 0 then
			actionMsg = "[" .. tier .. " DKP " .. amount .. "]: " .. encounter
		else
			actionMsg = "[" .. tier .. " DKP +" .. amount .. "]: " .. encounter
		end
	end

	local total = GetNumGroupMembers();
	if total > 0 then
		for i = 1, total do
			local name = GetRaidRosterInfo(i);
			name = TnTDKP_getMainCharacterName(name)

			-- Even though we use the same Timestamp across all transactions, we still generate separate Transaction IDs
			local transactionID = format("%010d%010d", random(0, MAX_INT), random(0, MAX_INT))

			-- Update the player's DKP value in the "Priority" table
			local initialPlayerPriorityDKP = TnTDKP_getPriorityDKP(name, tier)
			local newPriorityDKP = initialPlayerPriorityDKP + amount
			priorityTransactionsTable[CEPGP_ntgetn(priorityTransactionsTable)+1] = {
				[1] = name, -- Recipient
				[2] = UnitName("player"), -- Issuer
				[3] = actionMsg, -- Action
				[4] = initialPlayerPriorityDKP, -- Priority DKP Before
				[5] = newPriorityDKP, -- Priority DKP After
				[6] = "", -- Field used for ItemLink
				[7] = transactionID,
				[8] = timestamp
			};

			-- Actually update the value
			priorityDKPTable[name] = newPriorityDKP

			-- Update the player's DKP value in the "Lottery" table
			local initialPlayerLotteryDKP = TnTDKP_getLotteryDKP(name, tier)
			local newLotteryDKP = initialPlayerLotteryDKP + amount
			lotteryTransactionsTable[CEPGP_ntgetn(lotteryTransactionsTable)+1] = {
				[1] = name, -- Recipient
				[2] = UnitName("player"), -- Issuer
				[3] = actionMsg, -- Action
				[4] = initialPlayerLotteryDKP, -- Lottery DKP Before
				[5] = newLotteryDKP, -- Lottery DKP After
				[6] = "", -- Field used for ItemLink
				[7] = transactionID,
				[8] = timestamp
			};

			-- Actually update the value
			lotteryDKPTable[name] = newLotteryDKP
		end
		TnTDKP_UpdateDKPRelatedScrollBars();
	end
end

-- Award Standby DKP to the given player. There are a number of unique things about this method. This
-- method is only invoked as part of the CEPGP_handleCombat() flow, which does all necessary
-- Guild Roster checking - so we don't need to do that here.
--
-- Guild Roster checking is necessary for Standby. If we didn't Guild Roster check, we
-- invite trolls to whisper the individual who runs this AddOn with the command to enroll on
-- standby, which could quickly become very problematic
-- timestamp - Since Standby DKP is usually awarded to more than one player, it's more consistent to log these
--             Transactions with a common timestamp. However, since the iteration over the players on the 
--             Standby list isn't performed here, we need the caller to pass this common timestamp to us
-- player - The player to award. This player has already been confirmed to be in our Guild
-- amount - The amount of DKP to award
-- actionMsg - The message to put in the Transaction log for this award
-- tier - The "Tier" of content this boss was from. Used to determine which DKP and Transaction tables to modify. Examples: "T4", "T5", etc.
function CEPGP_addStandbyDKP(timestamp, playerNameOnStandby, amount, actionMsg, tier)
	if amount == nil then
		CEPGP_print("Please enter a valid number", 1);
		return;
	end

	-- Fetch a reference to the proper tables. This logic can't be abstracted to a helper method because if I return
	-- these, they won't be returned by Reference
	local priorityDKPTable = {}
	local lotteryDKPTable = {}
	local priorityTransactionsTable = {}
	local lotteryTransactionsTable = {}
	if tier == "T6.5" then
		priorityDKPTable = T6PT5_PRIORITY_DKP_TABLE
		lotteryDKPTable = T6PT5_LOTTERY_DKP_TABLE
		priorityTransactionsTable = T6PT5_PRIORITY_TRANSACTIONS
		lotteryTransactionsTable = T6PT5_LOTTERY_TRANSACTIONS
	elseif tier == "T6" then
		priorityDKPTable = T6_PRIORITY_DKP_TABLE
		lotteryDKPTable = T6_LOTTERY_DKP_TABLE
		priorityTransactionsTable = T6_PRIORITY_TRANSACTIONS
		lotteryTransactionsTable = T6_LOTTERY_TRANSACTIONS
	elseif tier == "T5" then
		priorityDKPTable = T5_PRIORITY_DKP_TABLE
		lotteryDKPTable = T5_LOTTERY_DKP_TABLE
		priorityTransactionsTable = T5_PRIORITY_TRANSACTIONS
		lotteryTransactionsTable = T5_LOTTERY_TRANSACTIONS
	elseif tier == "T4" then
		priorityDKPTable = T4_PRIORITY_DKP_TABLE
		lotteryDKPTable = T4_LOTTERY_DKP_TABLE
		priorityTransactionsTable = T4_PRIORITY_TRANSACTIONS
		lotteryTransactionsTable = T4_LOTTERY_TRANSACTIONS
	end

	player = TnTDKP_getMainCharacterName(playerNameOnStandby)

	local transactionID = format("%010d%010d", random(0, MAX_INT), random(0, MAX_INT))

	-- Update the player's "Priority" DKP value
	local initialPriorityDKP = TnTDKP_getPriorityDKP(player, tier)
	local newPriorityDKP = initialPriorityDKP + amount
	priorityTransactionsTable[CEPGP_ntgetn(priorityTransactionsTable)+1] = {
		[1] = player, -- Recipient
		[2] = UnitName("player"), -- Issuer
		[3] = actionMsg, -- Action
		[4] = initialPriorityDKP, -- Priority DKP Before
		[5] = newPriorityDKP, -- Priority DKP After
		[6] = "", -- Field used for ItemLink
		[7] = transactionID,
		[8] = timestamp
	};

	-- Actually update the value
	priorityDKPTable[player] = newPriorityDKP

	-- Update the player's "Lottery" DKP value
	local initialLotteryDKP = TnTDKP_getLotteryDKP(player, tier)
	local newLotteryDKP = initialLotteryDKP + amount
	lotteryTransactionsTable[CEPGP_ntgetn(lotteryTransactionsTable)+1] = {
		[1] = player, -- Recipient
		[2] = UnitName("player"), -- Issuer
		[3] = actionMsg, -- Action
		[4] = initialLotteryDKP, -- Lottery DKP Before
		[5] = newLotteryDKP, -- Lottery DKP After
		[6] = "", -- Field used for ItemLink
		[7] = transactionID,
		[8] = timestamp
	};

	-- Actually update the value
	lotteryDKPTable[player] = newLotteryDKP

	-- Send a whisper to the player to let them know they've been awarded Standby DKP
	TnTDKP_UpdateDKPRelatedScrollBars()
	SendChatMessage(actionMsg, WHISPER, CEPGP_LANGUAGE, playerNameOnStandby);
end

-- Logs a transaction to the OPEN_TRANSACTIONS table. These transactions require very little metadata
-- player - The player to record the transaction for
-- itemIDOrReason - The message to use for this transaction. If an ItemID is provided, it will be
--                  used to fetch the String Name for the item to auto-generate a "reason"
--                  for the Transaction of the format: "Quick Strike Ring - 18821"
-- tier - The "Tier" of content this boss was from. Used to determine which Transaction table to modify. Examples: "T4", "T5", etc.
function TnTDKP_logOpenTransaction(itemIDOrReason, tier)

	-- Fetch a reference to the proper table. This logic can't be abstracted to a helper method because if I return
	-- these, they won't be returned by Reference
	local openTransactionsTable = {}
	if tier == "T6.5" then
		openTransactionsTable = T6PT5_OPEN_TRANSACTIONS
	elseif tier == "T6" then
		openTransactionsTable = T6_OPEN_TRANSACTIONS
	elseif tier == "T5" then
		openTransactionsTable = T5_OPEN_TRANSACTIONS
	elseif tier == "T4" then
		openTransactionsTable = T4_OPEN_TRANSACTIONS
	end

	-- Check to see if itemIDOrReason is, in fact, an itemID
	local itemID, actionMsg
	if CEPGP_isNumber(itemIDOrReason) then
		local name, _, rarity = GetItemInfo(tonumber(itemIDOrReason))

		-- We have a valid itemID, so build the Transaction Message string
		if name then
			itemID = tonumber(itemIDOrReason)
			actionMsg = "[" .. tier .. " Open Transaction]: " .. name .. " (ItemID: " .. itemID .. ")"
		-- itemIDOrReason is a number but is not a valid item ID, so the actionMsg will just be the reason exactly as it was provided
		else
			actionMsg = "[" .. tier .. " Open Transaction]: " .. itemIDOrReason
		end
	-- itemIDOrReason isn't even a number, so the actionMsg will just be the reason exactly as it was provided
	else
		actionMsg = "[" .. tier .. " Open Transaction]: " .. itemIDOrReason
	end

	local transactionID = format("%010d%010d", random(0, MAX_INT), random(0, MAX_INT))
	local timestamp = date("%c", time())
	openTransactionsTable[CEPGP_ntgetn(openTransactionsTable)+1] = {
		[1] = "", -- Recipient
		[2] = UnitName("player"), -- Issuer
		[3] = actionMsg, -- Action
		[4] = "", -- DKP Before
		[5] = "", -- DKP After
		[6] = "", -- Field used for ItemLink
		[7] = transactionID,
		[8] = timestamp
	};

	TnTDKP_UpdateDKPRelatedScrollBars();
end

-- Award or Remove the designated amount of DKP from a specific player. This transaction will be logged with the
-- provided message in the PRIORITY Transactions Table.
--
-- In general, any time we add DKP we want to add it to both the PRIORITY and LOTTERY tables at the same time. However,
-- I'm not going to strictly enforce that in code, as I could foresee some situatuations where we might want to
-- award someone some PRIORITY DKP but NOT LOTTERY DKP for a small reward for some task - perhaps incentive for joining
-- in on helping us farm for Scarab Lord or something of that nature. On the same note, perhaps we want to penalize
-- a player for some action but not against both the PRIORITY and LOTTERY tables, as that'd be a bit rough.
--
-- player - The player to be awarded/penalized
-- amount - The amount to add/remove (this number can be either positive or negative)
-- itemIDOrReason - [Required] All Transactions require a reason. The UI allows the user to pass in either a Reason or the ItemID.
--                  The ItemID, if provided, will be used to fetch the String Name for the item to auto-generate a "reason"
--                  for the Transaction of the format: "[GP +1000]: Quick Strike Ring - 18821"
-- itemLink - [Optional] Two flows invoke this method, one is via the Loot distribution flow and the other is due to a manual transaction.
--            When a Manual Transaction is entered, an itemLink is not provided, and itemIDOrReason could be a string ItemID or not. When
--            invoked via the Loot Distribution flow, both a valid ItemID and an itemLink will be provided. We need to handle either case.
-- tier - The "Tier" of content this boss was from. Used to determine which DKP and Transaction tables to modify. Examples: "T4", "T5", etc.
function TnTDKP_addOrRemovePriorityDKP(player, amount, itemIDOrReason, itemLink, tier)
	if amount == nil then
		CEPGP_print("Please enter a valid number", 1);
		return;
	end

	-- Fetch a reference to the proper tables. This logic can't be abstracted to a helper method because if I return
	-- these, they won't be returned by Reference
	local priorityDKPTable = {}
	local priorityTransactionsTable = {}
	if tier == "T6.5" then
		priorityDKPTable = T6PT5_PRIORITY_DKP_TABLE
		priorityTransactionsTable = T6PT5_PRIORITY_TRANSACTIONS
	elseif tier == "T6" then
		priorityDKPTable = T6_PRIORITY_DKP_TABLE
		priorityTransactionsTable = T6_PRIORITY_TRANSACTIONS
	elseif tier == "T5" then
		priorityDKPTable = T5_PRIORITY_DKP_TABLE
		priorityTransactionsTable = T5_PRIORITY_TRANSACTIONS
	elseif tier == "T4" then
		priorityDKPTable = T4_PRIORITY_DKP_TABLE
		priorityTransactionsTable = T4_PRIORITY_TRANSACTIONS
	end

	player = TnTDKP_getMainCharacterName(player)
	local timestamp = date("%c", time())
	local transactionID = format("%010d%010d", random(0, MAX_INT), random(0, MAX_INT))

	-- Check to see if itemIDOrReason is, in fact, an itemID
	local itemID, actionMsg
	if CEPGP_isNumber(itemIDOrReason) then
		local name, _, rarity = GetItemInfo(tonumber(itemIDOrReason))

		-- We have a valid itemID, so build the Transaction Message string
		if name then
			itemID = tonumber(itemIDOrReason)

			-- This should NEVER occur, but if by chance we were given a String ItemID without a
			-- corresponding valid itemLink, we will regenerate the itemLink
			if not itemLink then
				itemLink = CEPGP_getItemLink(itemID)
			end
			actionMsg = "[" .. tier .. " Priority DKP " .. amount .. "]: " .. name .. " (ItemID: " .. itemID .. ")"
		-- itemIDOrReason is a number but is not a valid item ID, so the actionMsg will just be the reason exactly as it was provided
		else
			if amount <= 0 then
				actionMsg = "[" .. tier .. " Priority DKP " .. amount .. "]: " .. itemIDOrReason
			else
				actionMsg = "[" .. tier .. " Priority DKP +" .. amount .. "]: " .. itemIDOrReason
			end
		end
	-- itemIDOrReason isn't even a number, so the actionMsg will just be the reason exactly as it was provided
	else
		if amount <= 0 then
			actionMsg = "[" .. tier .. " Priority DKP " .. amount .. "]: " .. itemIDOrReason
		else
			actionMsg = "[" .. tier .. " Priority DKP +" .. amount .. "]: " .. itemIDOrReason
		end
	end


	-- Update the player's "Priority" DKP value
	local initialPriorityDKP = TnTDKP_getPriorityDKP(player, tier)
	local newPriorityDKP = tonumber(string.format("%2.2f", tonumber(initialPriorityDKP + amount)))
	priorityTransactionsTable[CEPGP_ntgetn(priorityTransactionsTable)+1] = {
		[1] = player, -- Recipient
		[2] = UnitName("player"), -- Issuer
		[3] = actionMsg, -- Action
		[4] = initialPriorityDKP, -- Priority DKP Before
		[5] = newPriorityDKP, -- Priority DKP After
		[6] = "", -- Field used for ItemLink
		[7] = transactionID,
		[8] = timestamp
	};

	-- Actually update the value
	priorityDKPTable[player] = newPriorityDKP

	TnTDKP_UpdateDKPRelatedScrollBars();
	SendChatMessage(format("(%s) %s. // New %s Priority DKP = %s", player, actionMsg, tier, newPriorityDKP), RAID, CEPGP_LANGUAGE);
end

-- Award or Remove the designated amount of DKP from a specific player. This transaction will be logged with the
-- provided message in the LOTTERY Transactions Table.
--
-- In general, any time we add DKP we want to add it to both the PRIORITY and LOTTERY tables at the same time. However,
-- I'm not going to strictly enforce that in code, as I could foresee some situatuations where we might want to
-- award someone some LOTTERY DKP but NOT PRIORITY DKP for a small reward for some task - perhaps incentive for joining
-- in on helping us farm for Scarab Lord or something of that nature. On the same note, perhaps we want to penalize
-- a player for some action but not against both the PRIORITY and LOTTERY tables, as that'd be a bit rough.
--
-- player - The player to be awarded/penalized
-- amount - The amount to add/remove (this number can be either positive or negative)
-- itemIDOrReason - [Required] All Transactions require a reason. The UI allows the user to pass in either a Reason or the ItemID.
--                  The ItemID, if provided, will be used to fetch the String Name for the item to auto-generate a "reason"
--                  for the Transaction of the format: "[GP +1000]: Quick Strike Ring - 18821"
-- itemLink - [Optional] Two flows invoke this method, one is via the Loot distribution flow and the other is due to a manual transaction.
--            When a Manual Transaction is entered, an itemLink is not provided, and itemIDOrReason could be a string ItemID or not. When
--            invoked via the Loot Distribution flow, both a valid ItemID and an itemLink will be provided. We need to handle either case.
-- tier - The "Tier" of content this boss was from. Used to determine which DKP and Transaction tables to modify. Examples: "T4", "T5", etc.
function TnTDKP_addOrRemoveLotteryDKP(player, amount, itemIDOrReason, itemLink, tier)
	if amount == nil then
		CEPGP_print("Please enter a valid number", 1);
		return;
	end

	-- Fetch a reference to the proper tables. This logic can't be abstracted to a helper method because if I return
	-- these, they won't be returned by Reference
	local lotteryDKPTable = {}
	local lotteryTransactionsTable = {}
	if tier == "T6.5" then
		lotteryDKPTable = T6PT5_LOTTERY_DKP_TABLE
		lotteryTransactionsTable = T6PT5_LOTTERY_TRANSACTIONS
	elseif tier == "T6" then
		lotteryDKPTable = T6_LOTTERY_DKP_TABLE
		lotteryTransactionsTable = T6_LOTTERY_TRANSACTIONS
	elseif tier == "T5" then
		lotteryDKPTable = T5_LOTTERY_DKP_TABLE
		lotteryTransactionsTable = T5_LOTTERY_TRANSACTIONS
	elseif tier == "T4" then
		lotteryDKPTable = T4_LOTTERY_DKP_TABLE
		lotteryTransactionsTable = T4_LOTTERY_TRANSACTIONS
	end

	player = TnTDKP_getMainCharacterName(player)
	local timestamp = date("%c", time())
	local transactionID = format("%010d%010d", random(0, MAX_INT), random(0, MAX_INT))

	-- Check to see if itemIDOrReason is, in fact, an itemID
	local itemID, actionMsg
	if CEPGP_isNumber(itemIDOrReason) then
		local name, _, rarity = GetItemInfo(tonumber(itemIDOrReason))

		-- We have a valid itemID, so build the Transaction Message string
		if name then
			itemID = tonumber(itemIDOrReason)

			-- This should NEVER occur, but if by chance we were given a String ItemID without a
			-- corresponding valid itemLink, we will regenerate the itemLink
			if not itemLink then
				itemLink = CEPGP_getItemLink(itemID)
			end
			actionMsg = "[" .. tier .. " Lottery DKP " .. amount .. "]: " .. name .. " (ItemID: " .. itemID .. ")"
		-- itemIDOrReason is a number but is not a valid item ID, so the actionMsg will just be the reason exactly as it was provided
		else
			if amount <= 0 then
				actionMsg = "[" .. tier .. " Lottery DKP " .. amount .. "]: " .. itemIDOrReason
			else
				actionMsg = "[" .. tier .. " Lottery DKP +" .. amount .. "]: " .. itemIDOrReason
			end
		end
	-- itemIDOrReason isn't even a number, so the actionMsg will just be the reason exactly as it was provided
	else
		if amount <= 0 then
			actionMsg = "[" .. tier .. " Lottery DKP " .. amount .. "]: " .. itemIDOrReason
		else
			actionMsg = "[" .. tier .. " Lottery DKP +" .. amount .. "]: " .. itemIDOrReason
		end
	end

	-- Update the player's "Lottery" DKP value.
	local initialLotteryDKP = TnTDKP_getLotteryDKP(player, tier)
	local newLotteryDKP = tonumber(string.format("%2.2f", tonumber(initialLotteryDKP + amount)))
	
	-- Log an event representing this transaction. I won't do this again for the DKP update on the "Lottery" table
	lotteryTransactionsTable[CEPGP_ntgetn(lotteryTransactionsTable)+1] = {
		[1] = player, -- Recipient
		[2] = UnitName("player"), -- Issuer
		[3] = actionMsg, -- Action
		[4] = initialLotteryDKP, -- DKP Before
		[5] = newLotteryDKP, -- DKP After
		[6] = "", -- itemLink
		[7] = transactionID,
		[8] = timestamp
	};

	-- Actually update the value
	lotteryDKPTable[player] = newLotteryDKP

	TnTDKP_UpdateDKPRelatedScrollBars();
	SendChatMessage(format("(%s) %s. // New %s Lottery DKP: %s", player, actionMsg, tier, newLotteryDKP), RAID, CEPGP_LANGUAGE);
end

-- When a Decay is performed, it's done so on BOTH DKP tables. Each Decay
-- transaction is logged as an independent Transaction on both the PRIORITY and LOTTERY
-- Transaction Tables.
-- amount - The percent amount to decay the DKP tables by. This amount comes in as a basic int,
--          we do the math to use it as a percentage here.
function TnTDKP_decay(amount)
	if amount == nil then
		CEPGP_print("Please enter a valid number", 1);
		return;
	end

	-- We use a single timestamp for the Decay event
	local timestamp = date("%c", time())
	local actionMsg = "All DKP Tables decayed by " .. amount .. "%"

	-- Decay the T4 "Priority" DKP table
	for name,_ in pairs(T4_PRIORITY_DKP_TABLE)do
		local transactionID = format("%010d%010d", random(0, MAX_INT), random(0, MAX_INT))
		local initialPriorityDKP = TnTDKP_getPriorityDKP(name, "T4")
		local decayedPriorityDKP = 0
		if initialPriorityDKP < 0 then -- Don't decay Negative values
			decayedPriorityDKP = initialPriorityDKP
			CEPGP_print(format("%s had negative T4 Priority DKP (%d), skipping.", name, initialPriorityDKP))
		else
			decayedPriorityDKP = tonumber(string.format("%2.2f", tonumber(initialPriorityDKP)*(1-(amount/100))))
		end
		T4_PRIORITY_TRANSACTIONS[CEPGP_ntgetn(T4_PRIORITY_TRANSACTIONS)+1] = {
			[1] = name, -- Recipient
			[2] = UnitName("player"), -- Issuer
			[3] = actionMsg, -- Action
			[4] = initialPriorityDKP, -- Priority DKP Before
			[5] = decayedPriorityDKP, -- Priority DKP After
			[6] = "", -- Field used for ItemLink
			[7] = transactionID,
			[8] = timestamp
		};

		-- Actually update the value
		T4_PRIORITY_DKP_TABLE[name] = decayedPriorityDKP
	end

	-- Decay the T4 "Lottery" DKP table
	for name,_ in pairs(T4_LOTTERY_DKP_TABLE)do
		local transactionID = format("%010d%010d", random(0, MAX_INT), random(0, MAX_INT))
		local initialLotteryDKP = TnTDKP_getLotteryDKP(name, "T4")
		local decayedLotteryDKP = 0
		if initialLotteryDKP < 0 then -- Don't decay Negative values
			decayedLotteryDKP = initialLotteryDKP
			CEPGP_print(format("%s had negative T4 Lottery DKP (%d), skipping.", name, initialLotteryDKP))
		else
			decayedLotteryDKP = tonumber(string.format("%2.2f", tonumber(initialLotteryDKP)*(1-(amount/100))))
		end
		T4_LOTTERY_TRANSACTIONS[CEPGP_ntgetn(T4_LOTTERY_TRANSACTIONS)+1] = {
			[1] = name, -- Recipient
			[2] = UnitName("player"), -- Issuer
			[3] = actionMsg, -- Action
			[4] = initialLotteryDKP, -- Lottery DKP Before
			[5] = decayedLotteryDKP, -- Lottery DKP After
			[6] = "", -- Field used for ItemLink
			[7] = transactionID,
			[8] = timestamp
		};

		-- Actually update the value
		T4_LOTTERY_DKP_TABLE[name] = decayedLotteryDKP
	end

	-- Decay the T5 "Priority" DKP table
	for name,_ in pairs(T5_PRIORITY_DKP_TABLE)do
		local transactionID = format("%010d%010d", random(0, MAX_INT), random(0, MAX_INT))
		local initialPriorityDKP = TnTDKP_getPriorityDKP(name, "T5")
		local decayedPriorityDKP = 0
		if initialPriorityDKP < 0 then -- Don't decay Negative values
			decayedPriorityDKP = initialPriorityDKP
			CEPGP_print(format("%s had negative T5 Priority DKP (%d), skipping.", name, initialPriorityDKP))
		else
			decayedPriorityDKP = tonumber(string.format("%2.2f", tonumber(initialPriorityDKP)*(1-(amount/100))))
		end
		T5_PRIORITY_TRANSACTIONS[CEPGP_ntgetn(T5_PRIORITY_TRANSACTIONS)+1] = {
			[1] = name, -- Recipient
			[2] = UnitName("player"), -- Issuer
			[3] = actionMsg, -- Action
			[4] = initialPriorityDKP, -- Priority DKP Before
			[5] = decayedPriorityDKP, -- Priority DKP After
			[6] = "", -- Field used for ItemLink
			[7] = transactionID,
			[8] = timestamp
		};

		-- Actually update the value
		T5_PRIORITY_DKP_TABLE[name] = decayedPriorityDKP
	end

	-- Decay the T5 "Lottery" DKP table
	for name,_ in pairs(T5_LOTTERY_DKP_TABLE)do
		local transactionID = format("%010d%010d", random(0, MAX_INT), random(0, MAX_INT))
		local initialLotteryDKP = TnTDKP_getLotteryDKP(name, "T5")
		local decayedLotteryDKP = 0
		if initialLotteryDKP < 0 then -- Don't decay Negative values
			decayedLotteryDKP = initialLotteryDKP
			CEPGP_print(format("%s had negative T5 Lottery DKP (%d), skipping.", name, initialLotteryDKP))
		else
			decayedLotteryDKP = tonumber(string.format("%2.2f", tonumber(initialLotteryDKP)*(1-(amount/100))))
		end
		T5_LOTTERY_TRANSACTIONS[CEPGP_ntgetn(T5_LOTTERY_TRANSACTIONS)+1] = {
			[1] = name, -- Recipient
			[2] = UnitName("player"), -- Issuer
			[3] = actionMsg, -- Action
			[4] = initialLotteryDKP, -- Lottery DKP Before
			[5] = decayedLotteryDKP, -- Lottery DKP After
			[6] = "", -- Field used for ItemLink
			[7] = transactionID,
			[8] = timestamp
		};

		-- Actually update the value
		T5_LOTTERY_DKP_TABLE[name] = decayedLotteryDKP
	end

	-- Decay the T6 "Priority" DKP table
	for name,_ in pairs(T6_PRIORITY_DKP_TABLE)do
		local transactionID = format("%010d%010d", random(0, MAX_INT), random(0, MAX_INT))
		local initialPriorityDKP = TnTDKP_getPriorityDKP(name, "T6")
		local decayedPriorityDKP = 0
		if initialPriorityDKP < 0 then -- Don't decay Negative values
			decayedPriorityDKP = initialPriorityDKP
			CEPGP_print(format("%s had negative T6 Priority DKP (%d), skipping.", name, initialPriorityDKP))
		else
			decayedPriorityDKP = tonumber(string.format("%2.2f", tonumber(initialPriorityDKP)*(1-(amount/100))))
		end
		T6_PRIORITY_TRANSACTIONS[CEPGP_ntgetn(T6_PRIORITY_TRANSACTIONS)+1] = {
			[1] = name, -- Recipient
			[2] = UnitName("player"), -- Issuer
			[3] = actionMsg, -- Action
			[4] = initialPriorityDKP, -- Priority DKP Before
			[5] = decayedPriorityDKP, -- Priority DKP After
			[6] = "", -- Field used for ItemLink
			[7] = transactionID,
			[8] = timestamp
		};

		-- Actually update the value
		T6_PRIORITY_DKP_TABLE[name] = decayedPriorityDKP
	end

	-- Decay the T6 "Lottery" DKP table
	for name,_ in pairs(T6_LOTTERY_DKP_TABLE)do
		local transactionID = format("%010d%010d", random(0, MAX_INT), random(0, MAX_INT))
		local initialLotteryDKP = TnTDKP_getLotteryDKP(name, "T6")
		local decayedLotteryDKP = 0
		if initialLotteryDKP < 0 then -- Don't decay Negative values
			decayedLotteryDKP = initialLotteryDKP
			CEPGP_print(format("%s had negative T6 Lottery DKP (%d), skipping.", name, initialLotteryDKP))
		else
			decayedLotteryDKP = tonumber(string.format("%2.2f", tonumber(initialLotteryDKP)*(1-(amount/100))))
		end
		T6_LOTTERY_TRANSACTIONS[CEPGP_ntgetn(T6_LOTTERY_TRANSACTIONS)+1] = {
			[1] = name, -- Recipient
			[2] = UnitName("player"), -- Issuer
			[3] = actionMsg, -- Action
			[4] = initialLotteryDKP, -- Lottery DKP Before
			[5] = decayedLotteryDKP, -- Lottery DKP After
			[6] = "", -- Field used for ItemLink
			[7] = transactionID,
			[8] = timestamp
		};

		-- Actually update the value
		T6_LOTTERY_DKP_TABLE[name] = decayedLotteryDKP
	end

	-- Decay the T6.5 "Priority" DKP table
	for name,_ in pairs(T6PT5_PRIORITY_DKP_TABLE)do
		local transactionID = format("%010d%010d", random(0, MAX_INT), random(0, MAX_INT))
		local initialPriorityDKP = TnTDKP_getPriorityDKP(name, "T6.5")
		local decayedPriorityDKP = 0
		if initialPriorityDKP < 0 then -- Don't decay Negative values
			decayedPriorityDKP = initialPriorityDKP
			CEPGP_print(format("%s had negative T5 Priority DKP (%d), skipping.", name, initialPriorityDKP))
		else
			decayedPriorityDKP = tonumber(string.format("%2.2f", tonumber(initialPriorityDKP)*(1-(amount/100))))
		end
		T6PT5_PRIORITY_TRANSACTIONS[CEPGP_ntgetn(T6PT5_PRIORITY_TRANSACTIONS)+1] = {
			[1] = name, -- Recipient
			[2] = UnitName("player"), -- Issuer
			[3] = actionMsg, -- Action
			[4] = initialPriorityDKP, -- Priority DKP Before
			[5] = decayedPriorityDKP, -- Priority DKP After
			[6] = "", -- Field used for ItemLink
			[7] = transactionID,
			[8] = timestamp
		};

		-- Actually update the value
		T6PT5_PRIORITY_DKP_TABLE[name] = decayedPriorityDKP
	end

	-- Decay the T6.5 "Lottery" DKP table
	for name,_ in pairs(T6PT5_LOTTERY_DKP_TABLE)do
		local transactionID = format("%010d%010d", random(0, MAX_INT), random(0, MAX_INT))
		local initialLotteryDKP = TnTDKP_getLotteryDKP(name, "T6.5")
		local decayedLotteryDKP = 0
		if initialLotteryDKP < 0 then -- Don't decay Negative values
			decayedLotteryDKP = initialLotteryDKP
			CEPGP_print(format("%s had negative T5 Lottery DKP (%d), skipping.", name, initialLotteryDKP))
		else
			decayedLotteryDKP = tonumber(string.format("%2.2f", tonumber(initialLotteryDKP)*(1-(amount/100))))
		end
		T6PT5_LOTTERY_TRANSACTIONS[CEPGP_ntgetn(T6PT5_LOTTERY_TRANSACTIONS)+1] = {
			[1] = name, -- Recipient
			[2] = UnitName("player"), -- Issuer
			[3] = actionMsg, -- Action
			[4] = initialLotteryDKP, -- Lottery DKP Before
			[5] = decayedLotteryDKP, -- Lottery DKP After
			[6] = "", -- Field used for ItemLink
			[7] = transactionID,
			[8] = timestamp
		};

		-- Actually update the value
		T6PT5_LOTTERY_DKP_TABLE[name] = decayedLotteryDKP
	end

	TnTDKP_UpdateDKPRelatedScrollBars();
	-- SendChatMessage(actionMsg, GUILD, CEPGP_LANGUAGE); -- No real need to print this
end
