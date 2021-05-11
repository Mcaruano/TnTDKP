local TAG = "Scrollbar.lua"

-- This is the remnants of the logic which saturates the "CEPGP_distribute" frame,
-- which previously would display an item and allow people to whisper for it and
-- add themselves to a list. I'm keeping this dead code in for now because I can
-- use a lot of this logic when I implement my "RollCaptureFrame" logic
function CEPGP_UpdateLootScrollBar()
	local y;
	local yoffset;
	local t;
	local tSize;
	local name;
	local class;
	local guildStatus;
	local role;
	local DKP;
	local tickets;
	local colour;
	-- t = {};
	-- tSize = table.getn(CEPGP_responses);
	-- CEPGP_updateGuild();

	-- Iterate over the list of players who have submitted "!want"
	-- for x = 1, tSize do
	-- 	name = CEPGP_responses[x]
	-- 	if CEPGP_debugMode and not UnitInRaid("player") then
	-- 		class = UnitClass("player");
	-- 	end

	-- 	-- Pull out the class metadata of the player
	-- 	for i = 1, GetNumGroupMembers() do
	-- 		if name == GetRaidRosterInfo(i) then
	-- 			_, _, _, _, class = GetRaidRosterInfo(i);
	-- 		end
	-- 	end

	-- 	if CEPGP_tContains(CEPGP_guildRosterAndRelatedMetadata, name, true) then
	-- 		guildStatus = "Yes"
	-- 	else
	-- 		guildStatus = "No"
	-- 	end

	-- 	-- Gather metadata about the player for saturation of the DistributeScrollFrame
	-- 	-- As stated in the method doc, this only pulls values from the Greed table
	-- 	role = TnTDKP_getRoleForPlayerAndCreateRecordIfNotFound(name)
	-- 	DKP = TnTDKP_getLotteryDKP(name);
	-- 	tickets = math.floor(DKP/100); -- TODO: Replace this with PR later
	-- 	t[x] = {
	-- 		[1] = name,
	-- 		[2] = role,
	-- 		[3] = guildStatus,
	-- 		[4] = DKP,
	-- 		[5] = "",
	-- 		[6] = tickets,
	-- 		[7] = class -- Simply used to fetch the class color when saturating the row
	-- 	}
	-- end

	-- Saturate the DistributeScrollFrame with all of the players in the "t" table
	-- t = CEPGP_tSort(t, CEPGP_criteria)
	-- FauxScrollFrame_Update(DistributeScrollFrame, tSize, 18, 120);
	-- for y = 1, 18, 1 do
	-- 	yoffset = y + FauxScrollFrame_GetOffset(DistributeScrollFrame);
	-- 	if (yoffset <= tSize) then
	-- 		if not CEPGP_tContains(t, yoffset, true) then
	-- 			_G["LootDistButton" .. y]:Hide();
	-- 		else
	-- 			name = t[yoffset][1];
	-- 			role = t[yoffset][2];
	-- 			guildStatus = t[yoffset][3];
	-- 			DKP = t[yoffset][4];
	-- 			tickets = t[yoffset][6];
	-- 			class = t[yoffset][7];
	-- 			local link;
	-- 			local iString = nil;
	-- 			local iString2 = nil;
	-- 			local tex = nil;
	-- 			local tex2 = nil;
	-- 			if CEPGP_itemsTable[name]then
	-- 				if CEPGP_itemsTable[name][1] ~= nil then
	-- 					iString = CEPGP_itemsTable[name][1].."|r";
	-- 					_, link, _, _, _, _, _, _, _, tex = GetItemInfo(iString);
	-- 					if CEPGP_itemsTable[name][2] ~= nil then
	-- 						iString2 = CEPGP_itemsTable[name][2].."|r";
	-- 						_, _, _, _, _, _, _, _, _, tex2 = GetItemInfo(iString2);
	-- 					end
	-- 				end
	-- 			end
				
	-- 			if class then
	-- 				colour = RAID_CLASS_COLORS[string.upper(class)];
	-- 			else
	-- 				colour = RAID_CLASS_COLORS["WARRIOR"];
	-- 			end
	-- 			if not colour then colour = RAID_CLASS_COLORS["WARRIOR"]; end
	-- 			_G["LootDistButton" .. y]:Show();
	-- 			_G["LootDistButton" .. y .. "Info"]:SetText(name);
	-- 			_G["LootDistButton" .. y .. "Info"]:SetTextColor(colour.r, colour.g, colour.b);
	-- 			_G["LootDistButton" .. y .. "Role"]:SetText(role);
	-- 			if role == "NOT SET" then
	-- 				_G["LootDistButton" .. y .. "Role"]:SetTextColor(255/255, 0/255, 0/255);
	-- 			else
	-- 				_G["LootDistButton" .. y .. "Role"]:SetTextColor(colour.r, colour.g, colour.b);
	-- 			end
	-- 			_G["LootDistButton" .. y .. "GuildStatus"]:SetText(guildStatus);
	-- 			if guildStatus == "Yes" then
	-- 				_G["LootDistButton" .. y .. "GuildStatus"]:SetTextColor(0/255, 255/255, 0/255);
	-- 			else
	-- 				_G["LootDistButton" .. y .. "GuildStatus"]:SetTextColor(255/255, 0/255, 0/255);
	-- 			end
				
	-- 			_G["LootDistButton" .. y .. "EP"]:SetText(DKP);
	-- 			_G["LootDistButton" .. y .. "EP"]:SetTextColor(colour.r, colour.g, colour.b);
	-- 			_G["LootDistButton" .. y .. "GP"]:SetText("");
	-- 			_G["LootDistButton" .. y .. "GP"]:SetTextColor(colour.r, colour.g, colour.b);
	-- 			_G["LootDistButton" .. y .. "Tickets"]:SetText(tickets);
	-- 			_G["LootDistButton" .. y .. "Tickets"]:SetTextColor(colour.r, colour.g, colour.b);
	-- 			_G["LootDistButton" .. y .. "Remove"]:SetScript('OnClick', function()	
	-- 					-- Remove player from CEPGP_responses table
	-- 					if CEPGP_tContains(CEPGP_responses, name) then
	-- 						for k, v in pairs(CEPGP_responses) do
	-- 							if v == name then
	-- 								table.remove(CEPGP_responses, k);
	-- 							end
	-- 						end
	-- 					end
	-- 					CEPGP_UpdateLootScrollBar();
	-- 				end);


	-- 			-- _G["LootDistButton" .. y .. "Tex"]:SetScript('OnLeave', function()
	-- 			-- 														GameTooltip:Hide()
	-- 			-- 													end);
	-- 			-- _G["LootDistButton" .. y .. "Tex2"]:SetScript('OnLeave', function()
	-- 			-- 														GameTooltip:Hide()
	-- 			-- 													end);
	-- 			-- if iString then
	-- 			-- 	_G["LootDistButton" .. y .. "Tex"]:SetScript('OnEnter', function()	
	-- 			-- 															GameTooltip:SetOwner(_G["LootDistButton" .. y .. "Tex"], "ANCHOR_TOPLEFT");
	-- 			-- 															GameTooltip:SetHyperlink(iString);
	-- 			-- 															GameTooltip:Show();
	-- 			-- 														end);
	-- 			-- 	_G["LootDistButton" .. y .. "Icon"]:SetTexture(tex);
	-- 			-- 	if iString2 then
	-- 			-- 		_G["LootDistButton" .. y .. "Tex2"]:SetScript('OnEnter', function()	
	-- 			-- 										GameTooltip:SetOwner(_G["LootDistButton" .. y .. "Tex2"], "ANCHOR_TOPLEFT")
	-- 			-- 										GameTooltip:SetHyperlink(iString2)
	-- 			-- 										GameTooltip:Show()
	-- 			-- 									end);				
	-- 			-- 		_G["LootDistButton" .. y .. "Icon2"]:SetTexture(tex);
	-- 			-- 	else
	-- 			-- 		_G["LootDistButton" .. y .. "Tex2"]:SetScript('OnEnter', function() end);
	-- 			-- 		_G["LootDistButton" .. y .. "Icon2"]:SetTexture(nil);
	-- 			-- 	end
				
	-- 			-- else
	-- 			-- 	_G["LootDistButton" .. y .. "Tex"]:SetScript('OnEnter', function() end);
	-- 			-- 	_G["LootDistButton" .. y .. "Icon"]:SetTexture(nil);
	-- 			-- end
	-- 		end
	-- 	else
	-- 		_G["LootDistButton" .. y]:Hide();
	-- 	end
	-- end
end

-- Displays all of the EPGP records of players in either the NEED Table or the Greed Table,
-- depending on which TNTGO_displaymode we are in (which is determined by the CheckBoxes)
function CEPGP_UpdateAllMembersScrollBar()
	local records = {}
	if TnTDKP_displayMode == "priority" then
		if TnTDKP_tierToDisplay == "T3" then
			records = T3_PRIORITY_DKP_TABLE
		elseif TnTDKP_tierToDisplay == "T2.5" then
			records = T2PT5_PRIORITY_DKP_TABLE
		elseif TnTDKP_tierToDisplay == "T2" then
			records = T2_PRIORITY_DKP_TABLE
		elseif TnTDKP_tierToDisplay == "T1" then
			records = T1_PRIORITY_DKP_TABLE
		end
	else
		if TnTDKP_tierToDisplay == "T3" then
			records = T3_LOTTERY_DKP_TABLE
		elseif TnTDKP_tierToDisplay == "T2.5" then
			records = T2PT5_LOTTERY_DKP_TABLE
		elseif TnTDKP_tierToDisplay == "T2" then
			records = T2_LOTTERY_DKP_TABLE
		elseif TnTDKP_tierToDisplay == "T1" then
			records = T1_LOTTERY_DKP_TABLE
		end
	end

	local x, y;
	local yoffset;
	local t;
	local tSize;
	local name;
	local class;
	local DKP;
	local colour;
	local role;
	t = {};

	tSize = CEPGP_ntgetn(records);
	x = 1
	for name,DKP in pairs(records) do
		-- We want to fetch this player's class, which we can do so via either the CEPGP_guildRosterAndRelatedMetadata
		-- Table or the CEPGP_raidRosterAndRelatedMetadata Table - the player will be present in at least one of these.
		_, class = CEPGP_getPlayerInfoFromGuildRosterTable(name);
		if not class then
			class, _ = TnTDKP_getPlayerInfoFromRaidRosterTable(name);
		end

		-- If class wasn't found in the CEPGP_raidRosterAndRelatedMetadata either, then we simply set it to "Unknown"
		if not class then
			class = "Unknown"
		end

		role = TnTDKP_getRoleForPlayerAndCreateRecordIfNotFound(name)
		t[x] = {
			[1] = name, -- Playername
			[2] = class, -- Class
			[3] = role,
			[4] = DKP,
			[5] = "",
			[6] = "" -- PR
		}
		x = x + 1
	end

	t = CEPGP_tSort(t, CEPGP_criteria)
	FauxScrollFrame_Update(GuildScrollFrame, tSize, 18, 240);
	for y = 1, 18, 1 do
		yoffset = y + FauxScrollFrame_GetOffset(GuildScrollFrame);
		if (yoffset <= tSize) then
			if not CEPGP_tContains(t, yoffset, true) then
				_G["GuildButton" .. y]:Hide();
			else
				name = t[yoffset][1]
				class = t[yoffset][2];
				role = t[yoffset][3];
				DKP = t[yoffset][4];
				if class then
					colour = RAID_CLASS_COLORS[string.upper(class)];
				else
					colour = RAID_CLASS_COLORS["WARRIOR"];
				end
				if not colour then colour = RAID_CLASS_COLORS["WARRIOR"]; end
				_G["GuildButton" .. y .. "Info"]:SetText(name);
				_G["GuildButton" .. y .. "Info"]:SetTextColor(colour.r, colour.g, colour.b);
				_G["GuildButton" .. y .. "RolePicker"]:SetText(role); -- You cannot set the TextColor of a Button
				_G["GuildButton" .. y .. "EP"]:SetText("");
				_G["GuildButton" .. y .. "EP"]:SetTextColor(colour.r, colour.g, colour.b);
				_G["GuildButton" .. y .. "GP"]:SetText("");
				_G["GuildButton" .. y .. "GP"]:SetTextColor(colour.r, colour.g, colour.b);
				_G["GuildButton" .. y .. "PR"]:SetText(DKP);
				_G["GuildButton" .. y .. "PR"]:SetTextColor(colour.r, colour.g, colour.b);
				_G["GuildButton" .. y]:Show();
			end
		else
			_G["GuildButton" .. y]:Hide();
		end
	end
end

-- Displays all of the Priority or Lottery DKP records of members in the raid group. If any member of
-- the raid is not present in either the Priority or Lottery DKP tables, a new record will be created
-- for them, initialized at DKP = 0
function CEPGP_UpdateRaidScrollBar()
	TnTDKP_updateRaidRosterTable()
	local x, y;
	local yoffset;
	local t;
	local tSize;
	local group;
	local name;
	local role;
	local DKP;
	local colour;
	t = {};
	tSize = GetNumGroupMembers();
	for x = 1, tSize do
		name, _, group, _, class = GetRaidRosterInfo(x);
		if name == UnitName("player") then
			name = UnitName("player");
		end

		-- Fetch the DKP values for this player. If this player doesn't have a record,
		-- a new one will be initialized for them
		if TnTDKP_displayMode == "priority" then
			DKP = TnTDKP_getPriorityDKP(name, TnTDKP_tierToDisplay);
		else
			DKP = TnTDKP_getLotteryDKP(name, TnTDKP_tierToDisplay);
		end

		role = TnTDKP_getRoleForPlayerAndCreateRecordIfNotFound(name)
		t[x] = {
			[1] = name,
			[2] = class,
			[3] = role,
			[4] = DKP,
			[5] = "",
			[6] = "",
			[7] = group
		}
	end
	t = CEPGP_tSort(t, CEPGP_criteria)
	FauxScrollFrame_Update(RaidScrollFrame, tSize, 18, 240);
	for y = 1, 18, 1 do
		yoffset = y + FauxScrollFrame_GetOffset(RaidScrollFrame);
		if (yoffset <= tSize) then
			if not CEPGP_tContains(t, yoffset, true) then
				_G["RaidButton" .. y]:Hide();
			else
				t2 = t[yoffset];
				name = t2[1];
				class = t2[2];
				role = t2[3];
				DKP = t2[4];
				group = t2[7];
				if class then
					colour = RAID_CLASS_COLORS[string.upper(class)];
				else
					colour = RAID_CLASS_COLORS["WARRIOR"];
				end
				if not colour then colour = RAID_CLASS_COLORS["WARRIOR"]; end
				_G["RaidButton" .. y .. "Group"]:SetText(group);
				_G["RaidButton" .. y .. "Group"]:SetTextColor(colour.r, colour.g, colour.b);
				_G["RaidButton" .. y .. "Info"]:SetText(name);
				_G["RaidButton" .. y .. "Info"]:SetTextColor(colour.r, colour.g, colour.b);
				_G["RaidButton" .. y .. "RolePicker"]:SetText(role); -- You cannot set the TextColor of a Button
				_G["RaidButton" .. y .. "EP"]:SetText("");
				_G["RaidButton" .. y .. "EP"]:SetTextColor(colour.r, colour.g, colour.b);
				_G["RaidButton" .. y .. "GP"]:SetText("");
				_G["RaidButton" .. y .. "GP"]:SetTextColor(colour.r, colour.g, colour.b);
				_G["RaidButton" .. y .. "PR"]:SetText(DKP);
				_G["RaidButton" .. y .. "PR"]:SetTextColor(colour.r, colour.g, colour.b);
				_G["RaidButton" .. y]:Show();
			end
		else
			_G["RaidButton" .. y]:Hide();
		end
	end
end

-- Iterates over the PRIORITY_TRANSACTIONS table and updates the "trafficScrollFrame" with the records
function CEPGP_UpdateTrafficScrollBar()
	local records = {}
	if TnTDKP_displayMode == "priority" then
		if TnTDKP_tierToDisplay == "T3" then
			records = T3_PRIORITY_TRANSACTIONS
		elseif TnTDKP_tierToDisplay == "T2.5" then
			records = T2PT5_PRIORITY_TRANSACTIONS
		elseif TnTDKP_tierToDisplay == "T2" then
			records = T2_PRIORITY_TRANSACTIONS
		elseif TnTDKP_tierToDisplay == "T1" then
			records = T1_PRIORITY_TRANSACTIONS
		end
	elseif TnTDKP_displayMode == "lottery" then
		if TnTDKP_tierToDisplay == "T3" then
			records = T3_LOTTERY_TRANSACTIONS
		elseif TnTDKP_tierToDisplay == "T2.5" then
			records = T2PT5_LOTTERY_TRANSACTIONS
		elseif TnTDKP_tierToDisplay == "T2" then
			records = T2_LOTTERY_TRANSACTIONS
		elseif TnTDKP_tierToDisplay == "T1" then
			records = T1_LOTTERY_TRANSACTIONS
		end
	else
		if TnTDKP_tierToDisplay == "T3" then
			records = T3_OPEN_TRANSACTIONS
		elseif TnTDKP_tierToDisplay == "T2.5" then
			records = T2PT5_OPEN_TRANSACTIONS
		elseif TnTDKP_tierToDisplay == "T2" then
			records = T2_OPEN_TRANSACTIONS
		elseif TnTDKP_tierToDisplay == "T1" then
			records = T1_OPEN_TRANSACTIONS
		end
	end

	if records == nil then
		return;
	end

	local yoffset;
	local tSize;
	tSize = CEPGP_ntgetn(records);
	FauxScrollFrame_Update(trafficScrollFrame, tSize, 18, 240);
	for y = 1, 18, 1 do
		yoffset = y + FauxScrollFrame_GetOffset(trafficScrollFrame);
		if (yoffset <= tSize) then
			local name = records[CEPGP_ntgetn(records) - (yoffset-1)][1];
			local issuer = records[CEPGP_ntgetn(records) - (yoffset-1)][2];
			local action = records[CEPGP_ntgetn(records) - (yoffset-1)][3];
			local dkpBefore = records[CEPGP_ntgetn(records) - (yoffset-1)][4];
			local dkpAfter = records[CEPGP_ntgetn(records) - (yoffset-1)][5];
			local item = records[CEPGP_ntgetn(records) - (yoffset-1)][6];

			-- Set the name of the Recipient, and even set the Recipient's class color if possible
			local _, colour = CEPGP_getPlayerClass(name);
			_G["trafficButton" .. y .. "Name"]:SetText(name);
			if colour then
				_G["trafficButton" .. y .. "Name"]:SetTextColor(colour.r, colour.g, colour.b);
			else
				_G["trafficButton" .. y .. "Name"]:SetTextColor(1, 1, 1);
			end

			-- Set the name of the Issuer, and even set the issuer's class color if possible
			_, colour = CEPGP_getPlayerClass(issuer);
			_G["trafficButton" .. y .. "Issuer"]:SetText(issuer);
			if colour then
				_G["trafficButton" .. y .. "Issuer"]:SetTextColor(colour.r, colour.g, colour.b);
			else
				_G["trafficButton" .. y .. "Issuer"]:SetTextColor(1, 1, 1);
			end

			-- If there's an item, we set it accordingly and even provide a nifty Ref to it
			if item then
				_G["trafficButton" .. y .. "ItemName"]:SetText(item);
				_G["trafficButton" .. y .. "ItemName"]:Show();
				_G["trafficButton" .. y .. "Item"]:SetScript('OnClick', function() SetItemRef(tostring(CEPGP_getItemString(item))) end);
			else
				_G["trafficButton" .. y .. "ItemName"]:SetText("");
				_G["trafficButton" .. y .. "ItemName"]:Hide();
				_G["trafficButton" .. y .. "Item"]:SetScript('OnClick', function() end);
			end

			-- All of the other fields are basic text fields with no coloration or links, so
			-- we simply saturate all of them. If there is no value for any of these fields,
			-- it has already been initialized to "" in the PRIORITY_TRANSACTIONS table
			_G["trafficButton" .. y .. "Action"]:SetText(action);
			_G["trafficButton" .. y .. "Action"]:SetTextColor(1, 1, 1);
			_G["trafficButton" .. y .. "EPBefore"]:SetText(dkpBefore);
			_G["trafficButton" .. y .. "EPBefore"]:SetTextColor(1, 1, 1);
			_G["trafficButton" .. y .. "EPAfter"]:SetText(EPA);
			_G["trafficButton" .. y .. "EPAfter"]:SetTextColor(1, 1, 1);
			_G["trafficButton" .. y .. "GPBefore"]:SetText(dkpAfter);
			_G["trafficButton" .. y .. "GPBefore"]:SetTextColor(1, 1, 1);
			_G["trafficButton" .. y .. "GPAfter"]:SetText(GPA);
			_G["trafficButton" .. y .. "GPAfter"]:SetTextColor(1, 1, 1);
			_G["trafficButton" .. y]:Show();
		else
			_G["trafficButton" .. y]:Hide();
		end
	end
end

-- The StandbyScrollBar simply displays an actionable list of people who have signed up
-- to be on the Standby list by whispering the person running this AddOn. I actually don't
-- know why this frame bothers showing the EP/GP values of standby members
-- TODO: Trim this frame down considerably. We don't need this much data about standby members.
-- If I wish to keep it, I need to add the NEED/GREED CheckBox toggles to this window...
function CEPGP_UpdateStandbyScrollBar()
	local x, y;
	local yoffset;
	local t;
	local tSize;
	local name;
	local class;
	local DKP;
	local role;
	local colour;
	t = {};
	tSize = CEPGP_ntgetn(STANDBY_ROSTER);
	for x = 1, tSize do
		name = STANDBY_ROSTER[x];
		_, class = CEPGP_getPlayerInfoFromGuildRosterTable(name);
		role = TnTDKP_getRoleForPlayerAndCreateRecordIfNotFound(name)
		DKP = TnTDKP_getPriorityDKP(name, "T1");
		t[x] = {
			[1] = name,
			[2] = class,
			[3] = role,
			[4] = DKP
		};
	end
	t = CEPGP_tSort(t, CEPGP_criteria);
	FauxScrollFrame_Update(CEPGP_StandbyScrollFrame, tSize, 18, 240);
	for y = 1, 18, 1 do
		yoffset = y + FauxScrollFrame_GetOffset(CEPGP_StandbyScrollFrame);
		if (yoffset <= tSize) then
			if not CEPGP_tContains(t, yoffset, true) then
				_G["CEPGP_StandbyButton" .. y]:Hide();
			else
				name = t[yoffset][1]
				class = t[yoffset][2];
				role = t[yoffset][3];
				DKP = t[yoffset][4];
				if class then
					colour = RAID_CLASS_COLORS[string.upper(class)];
				else
					colour = RAID_CLASS_COLORS["WARRIOR"];
				end
				if not colour then colour = RAID_CLASS_COLORS["WARRIOR"]; end
				_G["CEPGP_StandbyButton" .. y .. "Info"]:SetText(name);
				_G["CEPGP_StandbyButton" .. y .. "Info"]:SetTextColor(colour.r, colour.g, colour.b);
				_G["CEPGP_StandbyButton" .. y .. "Class"]:SetText(class);
				_G["CEPGP_StandbyButton" .. y .. "Class"]:SetTextColor(colour.r, colour.g, colour.b);
				_G["CEPGP_StandbyButton" .. y .. "Rank"]:SetText(role);
				_G["CEPGP_StandbyButton" .. y .. "Rank"]:SetTextColor(colour.r, colour.g, colour.b);
				_G["CEPGP_StandbyButton" .. y .. "EP"]:SetText("");
				_G["CEPGP_StandbyButton" .. y .. "EP"]:SetTextColor(colour.r, colour.g, colour.b);
				_G["CEPGP_StandbyButton" .. y .. "GP"]:SetText("");
				_G["CEPGP_StandbyButton" .. y .. "GP"]:SetTextColor(colour.r, colour.g, colour.b);
				_G["CEPGP_StandbyButton" .. y .. "PR"]:SetText(DKP);
				_G["CEPGP_StandbyButton" .. y .. "PR"]:SetTextColor(colour.r, colour.g, colour.b);
				_G["CEPGP_StandbyButton" .. y]:Show();
			end
		else
			_G["CEPGP_StandbyButton" .. y]:Hide();
		end
	end
end

-- This method gets invoked whenever we perform an DKP Transaction.
-- When we do so, we update all scrollbars which display player records
-- containing DKP values so that we be sure that whatever page the user
-- is on, the scrollbar gets updated. This also makes a call to update
-- the TrafficScrollBar
function TnTDKP_UpdateDKPRelatedScrollBars()
	CEPGP_updateGuild()
	CEPGP_UpdateAllMembersScrollBar()
	CEPGP_UpdateRaidScrollBar()
	CEPGP_UpdateStandbyScrollBar()
	CEPGP_UpdateTrafficScrollBar()
end