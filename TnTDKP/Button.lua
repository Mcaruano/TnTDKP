local TAG = "Button.lua"

-- This class handles the displaying of various popup windows. MANY of these
-- popup flows simply leverage the same CEPGP_context_popup and Show/Hide
-- whatever fields they choose in accordance with their own workflow.
function CEPGP_ListButton_OnClick(obj)		
	--[[ Distribution Menu ]]--
	if strfind(obj, "LootDistButton") then --A player in the distribution menu is clicked
		-- ShowUIPanel(CEPGP_distribute_popup);
		-- CEPGP_distribute_popup_title:SetText(_G[_G[obj]:GetName() .. "Info"]:GetText());
		-- CEPGP_distPlayer = _G[_G[obj]:GetName() .. "Info"]:GetText();
		-- CEPGP_distribute_popup:SetID(CEPGP_distribute:GetID()); --CEPGP_distribute:GetID gets the ID of the LOOT SLOT. Not the player.
		-- if CEPGP_debugMode then print(format("[%s] LootDistButton was clicked. CEPGP_distPlayer set to: %s", TAG, CEPGP_distPlayer)) end
	
	-- If a player from the ScrollBar on either the "All" Frame or the "Raid" Frame was clicked,
	-- we surface a workflow allowing for a manual EP/GP transaction
	elseif strfind(obj, "GuildButton") or strfind(obj, "RaidButton") then
		-- There are two RolePicker entrypoints which can come down through either
		-- the GuildButton or the RaidButton, so we check right here to see if
		-- we are dealing with the RolePicker flow and divert if so
		if strfind(obj, "RolePicker") then
			-- In this flow, the button name is either "GuildButtonNRolePicker" or "RaidButtonNRolePicker",
			-- so we can still fetch the PlayerName from "GuildButtonNInfo" or "RaidButtonNInfo", we just have
			-- to do some string massaging to trim off the "RolePicker" suffix first
			local objectName = _G[obj]:GetName() -- "GuildButtonNRolePicker" or "RaidButtonNRolePicker"
			local objectNameWithSuffixRemoved = objectName:sub(1, -11) -- "GuildButtonN" or "RaidButtonN"
			local name = _G[objectNameWithSuffixRemoved .. "Info"]:GetText();
			TnTDKP_handleRolePicker(name)
			return
		end

		-- This fetches the Playername from the "GuildButtonNInfo"/"RaidButtonNInfo" FontString
		local name = _G[_G[obj]:GetName() .. "Info"]:GetText();

		ShowUIPanel(CEPGP_context_popup);
		ShowUIPanel(CEPGP_context_amount_editbox);
		ShowUIPanel(CEPGP_context_reason_editbox);
		HideUIPanel(CEPGP_context_role_dropdown);
		HideUIPanel(CEPGP_context_editbox_centered);

		-- Enable all Priority/Lottery/Open CheckBoxes for this flow
		ShowUIPanel(CEPGP_context_popup_priority_check);
		ShowUIPanel(CEPGP_context_popup_lottery_check);
		ShowUIPanel(CEPGP_context_popup_open_check);
		_G["CEPGP_context_popup_priority_check_text"]:Show();
		_G["CEPGP_context_popup_lottery_check_text"]:Show();
		_G["CEPGP_context_popup_open_check_text"]:Show();
		TnTDKP_awardMode = "priority"
		CEPGP_context_popup_priority_check:SetChecked(1);
		CEPGP_context_popup_lottery_check:SetChecked(nil);
		CEPGP_context_popup_open_check:SetChecked(nil);

		-- Suppress the "ADD" and "REMOVE" Checkboxes
		HideUIPanel(CEPGP_context_popup_ADD_check);
		HideUIPanel(CEPGP_context_popup_REMOVE_check);
		_G["CEPGP_context_popup_ADD_check_text"]:Hide();
		_G["CEPGP_context_popup_REMOVE_check_text"]:Hide();
		CEPGP_context_popup_ADD_check:SetChecked(nil);
		CEPGP_context_popup_REMOVE_check:SetChecked(nil);

		-- Display the T4/T5/T6/T6.5 Checkboxes, and initialize them with "T4" checked
		ShowUIPanel(CEPGP_context_popup_T4_check);
		ShowUIPanel(CEPGP_context_popup_T5_check);
		ShowUIPanel(CEPGP_context_popup_T6_check);
		ShowUIPanel(CEPGP_context_popup_T6PT5_check);
		_G["CEPGP_context_popup_T4_check_text"]:Show();
		_G["CEPGP_context_popup_T5_check_text"]:Show();
		_G["CEPGP_context_popup_T6_check_text"]:Show();
		_G["CEPGP_context_popup_T6PT5_check_text"]:Show();
		CEPGP_context_popup_T4_check:SetChecked(1);
		CEPGP_context_popup_T5_check:SetChecked(nil);
		CEPGP_context_popup_T6_check:SetChecked(nil);
		CEPGP_context_popup_T6PT5_check:SetChecked(nil);

		-- Display the text fields we want to display and initialize them for this flow
		CEPGP_context_popup_header:SetText("Manual Transaction");
		CEPGP_context_popup_title:SetText("Add manual transaction for: " .. name);
		_G["CEPGP_context_popup_desc_centered"]:Show();
		CEPGP_context_popup_desc_centered:SetText("Adding manual PRIORITY transaction");
		_G["CEPGP_context_popup_amount_header"]:Show();
		_G["CEPGP_context_popup_reason_header"]:Show();
		CEPGP_context_popup_amount_header:SetText("Amount:")
		CEPGP_context_popup_reason_header:SetText("ItemID/Reason:")

		CEPGP_context_amount_editbox:SetText("0");
		CEPGP_context_amount_editbox:SetNumeric(false);
		CEPGP_context_reason_editbox:SetText("");
		CEPGP_context_popup_confirm:SetScript('OnClick', function()
															PlaySound(799);
															HideUIPanel(CEPGP_context_popup);
															local itemIDOrReason = CEPGP_context_reason_editbox:GetText()
															if not itemIDOrReason or itemIDOrReason == "" then
																message("A Reason or ItemID must be given")
																return
															end

															-- If we're just trying to log an Open transaction, the flow is way more trivial
															if TnTDKP_awardMode == "open" then
																CEPGP_print("The ability to log Open Transactions on a per-character basis is just old code that should be removed. This is an unnecessary action. Disregarding.")
																return
															end

															if not CEPGP_isNumber(CEPGP_context_amount_editbox:GetText()) then
																message("Amount was not a valid number")
																return
															end

															if TnTDKP_awardMode == "priority" then
																-- Check each "Tier" checkbox and award the corresponding tables with DKP
																if CEPGP_context_popup_T4_check:GetChecked() then
																	TnTDKP_addOrRemovePriorityDKP(name, tonumber(CEPGP_context_amount_editbox:GetText()), itemIDOrReason, nil, "T4");
																end
																if CEPGP_context_popup_T5_check:GetChecked() then
																	TnTDKP_addOrRemovePriorityDKP(name, tonumber(CEPGP_context_amount_editbox:GetText()), itemIDOrReason, nil, "T5");
																end
																if CEPGP_context_popup_T6_check:GetChecked() then
																	TnTDKP_addOrRemovePriorityDKP(name, tonumber(CEPGP_context_amount_editbox:GetText()), itemIDOrReason, nil, "T6");
																end
																if CEPGP_context_popup_T6PT5_check:GetChecked() then
																	TnTDKP_addOrRemovePriorityDKP(name, tonumber(CEPGP_context_amount_editbox:GetText()), itemIDOrReason, nil, "T6.5");
																end
															else
																-- Check each "Tier" checkbox and award the corresponding tables with DKP
																if CEPGP_context_popup_T4_check:GetChecked() then
																	TnTDKP_addOrRemoveLotteryDKP(name, tonumber(CEPGP_context_amount_editbox:GetText()), itemIDOrReason, nil, "T4");
																end
																if CEPGP_context_popup_T5_check:GetChecked() then
																	TnTDKP_addOrRemoveLotteryDKP(name, tonumber(CEPGP_context_amount_editbox:GetText()), itemIDOrReason, nil, "T5");
																end
																if CEPGP_context_popup_T6_check:GetChecked() then
																	TnTDKP_addOrRemoveLotteryDKP(name, tonumber(CEPGP_context_amount_editbox:GetText()), itemIDOrReason, nil, "T6");
																end
																if CEPGP_context_popup_T6PT5_check:GetChecked() then
																	TnTDKP_addOrRemoveLotteryDKP(name, tonumber(CEPGP_context_amount_editbox:GetText()), itemIDOrReason, nil, "T6.5");
																end
															end
														end);
	
	elseif strfind(obj, "TnTDKP_decay") then --Click the Decay Guild EPGP button in the Guild menu
		ShowUIPanel(CEPGP_context_popup);
		ShowUIPanel(CEPGP_context_editbox_centered);
		HideUIPanel(CEPGP_context_role_dropdown);
		HideUIPanel(CEPGP_context_amount_editbox);
		HideUIPanel(CEPGP_context_reason_editbox);

		-- Hide all of the various CheckBoxes, they aren't used in this flow.
		HideUIPanel(CEPGP_context_popup_priority_check);
		HideUIPanel(CEPGP_context_popup_lottery_check);
		HideUIPanel(CEPGP_context_popup_open_check);
		_G["CEPGP_context_popup_priority_check_text"]:Hide();
		_G["CEPGP_context_popup_lottery_check_text"]:Hide();
		_G["CEPGP_context_popup_open_check_text"]:Hide();
		CEPGP_context_popup_priority_check:SetChecked(nil);
		CEPGP_context_popup_lottery_check:SetChecked(nil);
		CEPGP_context_popup_open_check:SetChecked(nil);

		-- Suppress the "ADD" and "REMOVE" Checkboxes
		HideUIPanel(CEPGP_context_popup_ADD_check);
		HideUIPanel(CEPGP_context_popup_REMOVE_check);
		_G["CEPGP_context_popup_ADD_check_text"]:Hide();
		_G["CEPGP_context_popup_REMOVE_check_text"]:Hide();
		CEPGP_context_popup_ADD_check:SetChecked(nil);
		CEPGP_context_popup_REMOVE_check:SetChecked(nil);

		-- Suppress the T4/T5/T6/T6.5 Checkboxes
		HideUIPanel(CEPGP_context_popup_T4_check);
		HideUIPanel(CEPGP_context_popup_T5_check);
		HideUIPanel(CEPGP_context_popup_T6_check);
		HideUIPanel(CEPGP_context_popup_T6PT5_check);
		_G["CEPGP_context_popup_T4_check_text"]:Hide();
		_G["CEPGP_context_popup_T5_check_text"]:Hide();
		_G["CEPGP_context_popup_T6_check_text"]:Hide();
		_G["CEPGP_context_popup_T6PT5_check_text"]:Hide();
		CEPGP_context_popup_T4_check:SetChecked(nil);
		CEPGP_context_popup_T5_check:SetChecked(nil);
		CEPGP_context_popup_T6_check:SetChecked(nil);
		CEPGP_context_popup_T6PT5_check:SetChecked(nil);

		-- Hide the Prefix/Suffix text fields, we use a centered one for this flow
		_G["CEPGP_context_popup_title"]:Hide();
		_G["CEPGP_context_popup_amount_header"]:Hide();
		_G["CEPGP_context_popup_reason_header"]:Hide();
		
		-- Display the text fields we want to display and initialize them for this flow
		CEPGP_context_popup_header:SetText("Decay DKP");
		_G["CEPGP_context_popup_desc_centered"]:Show();
		CEPGP_context_popup_desc_centered:SetText("Decays DKP standings by a percentage.\nValid Range: 0-100");

		CEPGP_context_editbox_centered:SetText("0");
		CEPGP_context_editbox_centered:SetNumeric(false);
		CEPGP_context_popup_confirm:SetScript('OnClick', function()
															PlaySound(799);
															HideUIPanel(CEPGP_context_popup);
															TnTDKP_decay(tonumber(CEPGP_context_editbox_centered:GetText()));
														end);
	
	elseif strfind(obj, "CEPGP_raid_add_EP") then --Click the Add Raid EP button in the Raid menu
		ShowUIPanel(CEPGP_context_popup);
		ShowUIPanel(CEPGP_context_amount_editbox);
		ShowUIPanel(CEPGP_context_reason_editbox);
		HideUIPanel(CEPGP_context_editbox_centered);
		HideUIPanel(CEPGP_context_role_dropdown);
		
		-- Hide all of the Priority/Lottery/Open CheckBoxes, they aren't used in this flow.
		HideUIPanel(CEPGP_context_popup_priority_check);
		HideUIPanel(CEPGP_context_popup_lottery_check);
		HideUIPanel(CEPGP_context_popup_open_check);
		_G["CEPGP_context_popup_priority_check_text"]:Hide();
		_G["CEPGP_context_popup_lottery_check_text"]:Hide();
		_G["CEPGP_context_popup_open_check_text"]:Hide();
		CEPGP_context_popup_priority_check:SetChecked(nil);
		CEPGP_context_popup_lottery_check:SetChecked(nil);
		CEPGP_context_popup_open_check:SetChecked(nil);

		-- Suppress the "ADD" and "REMOVE" Checkboxes
		HideUIPanel(CEPGP_context_popup_ADD_check);
		HideUIPanel(CEPGP_context_popup_REMOVE_check);
		_G["CEPGP_context_popup_ADD_check_text"]:Hide();
		_G["CEPGP_context_popup_REMOVE_check_text"]:Hide();
		CEPGP_context_popup_ADD_check:SetChecked(nil);
		CEPGP_context_popup_REMOVE_check:SetChecked(nil);

		-- Hide TextFields we won't be using
		_G["CEPGP_context_popup_title"]:Hide();

		-- Display the T4/T5/T6/T6.5 Checkboxes, and initialize them with "T4" checked
		ShowUIPanel(CEPGP_context_popup_T4_check);
		ShowUIPanel(CEPGP_context_popup_T5_check);
		ShowUIPanel(CEPGP_context_popup_T6_check);
		ShowUIPanel(CEPGP_context_popup_T6PT5_check);
		_G["CEPGP_context_popup_T4_check_text"]:Show();
		_G["CEPGP_context_popup_T5_check_text"]:Show();
		_G["CEPGP_context_popup_T6_check_text"]:Show();
		_G["CEPGP_context_popup_T6PT5_check_text"]:Show();
		CEPGP_context_popup_T4_check:SetChecked(1);
		CEPGP_context_popup_T5_check:SetChecked(nil);
		CEPGP_context_popup_T6_check:SetChecked(nil);
		CEPGP_context_popup_T6PT5_check:SetChecked(nil);

		CEPGP_context_popup_header:SetText("Award Raid DKP");
		_G["CEPGP_context_popup_desc_centered"]:Show();
		CEPGP_context_popup_desc_centered:SetText("Adds an amount of DKP to the entire raid.\nThis adds DKP to both the Priority AND Lottery tables.");
		_G["CEPGP_context_popup_amount_header"]:Show();
		_G["CEPGP_context_popup_reason_header"]:Show();
		CEPGP_context_popup_amount_header:SetText("Amount:");
		CEPGP_context_popup_reason_header:SetText("Reason:");

		CEPGP_context_amount_editbox:SetText("0");
		CEPGP_context_amount_editbox:SetNumeric(false);
		CEPGP_context_reason_editbox:SetText("");
		CEPGP_context_popup_confirm:SetScript('OnClick', function()
															PlaySound(799);
															HideUIPanel(CEPGP_context_popup);
															local reason = CEPGP_context_reason_editbox:GetText()
															if not reason or reason == "" then
																message("A Reason or ItemID must be given")
																return
															elseif not CEPGP_isNumber(CEPGP_context_amount_editbox:GetText()) then
																message("Amount was not a valid number")
																return
															end
															local amount = tonumber(CEPGP_context_amount_editbox:GetText())
															-- For Raidwide DKP Awards, we use the same Timestamp for each transaction record
															local timestamp = date("%c", time())

															-- Check each "Tier" checkbox and award the corresponding tables with DKP
															local tiersBeingAwarded = {}
															if CEPGP_context_popup_T4_check:GetChecked() then
																CEPGP_AddRaidDKP(timestamp, amount, reason, nil, "T4");
																table.insert(tiersBeingAwarded, "T4")
															end
															if CEPGP_context_popup_T5_check:GetChecked() then
																CEPGP_AddRaidDKP(timestamp, amount, reason, nil, "T5");
																table.insert(tiersBeingAwarded, "T5")
															end
															if CEPGP_context_popup_T6_check:GetChecked() then
																CEPGP_AddRaidDKP(timestamp, amount, reason, nil, "T6");
																table.insert(tiersBeingAwarded, "T6")
															end
															if CEPGP_context_popup_T6PT5_check:GetChecked() then
																CEPGP_AddRaidDKP(timestamp, amount, reason, nil, "T6.5");
																table.insert(tiersBeingAwarded, "T6.5")
															end

															-- Form the string for the award message: E.g. "T4 & T5"
															tierString = table.concat(tiersBeingAwarded, " & ")

															SendChatMessage("Awarded the Raid & Standby " .. amount .. " " .. tierString .. " DKP. Reason: " .. reason, RAID, CEPGP_LANGUAGE);
															SendChatMessage("Awarded the Raid & Standby " .. amount .. " " .. tierString .. " DKP. Reason: " .. reason, GUILD, CEPGP_LANGUAGE);															

															-- Any award to the raid should also award those on Standby
															if STANDBYEP then
																for i = 1, table.getn(STANDBY_ROSTER) do
																	-- We only award Standby DKP to players in the guild.
																	local standbyMember = STANDBY_ROSTER[i]
																	if CEPGP_tContains(CEPGP_guildRosterAndRelatedMetadata, standbyMember, true) then
																		local _, _, _, _, _, _, _, _, online = GetGuildRosterInfo(CEPGP_guildRosterAndRelatedMetadata[standbyMember][1]);
														
																		-- Enforce the Online requirement if STANDBYOFFLINE override not enabled
																		if online == 1 or STANDBYOFFLINE then
																			if CEPGP_context_popup_T4_check:GetChecked() then
																				CEPGP_addStandbyDKP(timestamp, standbyMember, amount*(STANDBYPERCENT/100), "[T4 DKP " .. amount .. "]: " .. reason .. " (Standby)", "T4");
																			end
																			if CEPGP_context_popup_T5_check:GetChecked() then
																				CEPGP_addStandbyDKP(timestamp, standbyMember, amount*(STANDBYPERCENT/100), "[T5 DKP " .. amount .. "]: " .. reason .. " (Standby)", "T5");
																			end
																			if CEPGP_context_popup_T6_check:GetChecked() then
																				CEPGP_addStandbyDKP(timestamp, standbyMember, amount*(STANDBYPERCENT/100), "[T6 DKP " .. amount .. "]: " .. reason .. " (Standby)", "T6");
																			end
																			if CEPGP_context_popup_T6PT5_check:GetChecked() then
																				CEPGP_addStandbyDKP(timestamp, standbyMember, amount*(STANDBYPERCENT/100), "[T6.5 DKP " .. amount .. "]: " .. reason .. " (Standby)", "T6.5");
																			end
																		end
																	end
																end
																SendChatMessage("Standby members have been awarded " .. amount*(STANDBYPERCENT/100) .. " " .. tierString ..  " DKP. Reason: " .. reason, GUILD, CEPGP_LANGUAGE);
																CEPGP_UpdateTrafficScrollBar();
																SendChatMessage("Whisper me \"" .. CEPGP_standby_whisper_msg .. "\" from your MAIN to add yourself to the Standby list", GUILD, CEPGP_LANGUAGE);
															end
														end);
	
	-- "Manually Distribute Item" button on the Toolbox page												
	elseif strfind(obj, "TnTDKP_manually_distribute") then
		-- TODO: Start with the "Init Player" logic. There won't be tickboxes
		-- If I end up using CEPGP_distributing as my signal for loot, then I need to be sure to set this to true in the CONFIRM button logic
		ShowUIPanel(CEPGP_context_popup);
		ShowUIPanel(CEPGP_context_editbox_centered);
		HideUIPanel(CEPGP_context_role_dropdown);
		HideUIPanel(CEPGP_context_amount_editbox);
		HideUIPanel(CEPGP_context_reason_editbox);

		-- Hide all of the various CheckBoxes, they aren't used in this flow.
		HideUIPanel(CEPGP_context_popup_priority_check);
		HideUIPanel(CEPGP_context_popup_lottery_check);
		HideUIPanel(CEPGP_context_popup_open_check);
		_G["CEPGP_context_popup_priority_check_text"]:Hide();
		_G["CEPGP_context_popup_lottery_check_text"]:Hide();
		_G["CEPGP_context_popup_open_check_text"]:Hide();
		CEPGP_context_popup_priority_check:SetChecked(nil);
		CEPGP_context_popup_lottery_check:SetChecked(nil);
		CEPGP_context_popup_open_check:SetChecked(nil);

		-- Suppress the "ADD" and "REMOVE" Checkboxes
		HideUIPanel(CEPGP_context_popup_ADD_check);
		HideUIPanel(CEPGP_context_popup_REMOVE_check);
		_G["CEPGP_context_popup_ADD_check_text"]:Hide();
		_G["CEPGP_context_popup_REMOVE_check_text"]:Hide();
		CEPGP_context_popup_ADD_check:SetChecked(nil);
		CEPGP_context_popup_REMOVE_check:SetChecked(nil);

		-- Suppress the T4/T5/T6/T6.5 Checkboxes
		HideUIPanel(CEPGP_context_popup_T4_check);
		HideUIPanel(CEPGP_context_popup_T5_check);
		HideUIPanel(CEPGP_context_popup_T6_check);
		HideUIPanel(CEPGP_context_popup_T6PT5_check);
		_G["CEPGP_context_popup_T4_check_text"]:Hide();
		_G["CEPGP_context_popup_T5_check_text"]:Hide();
		_G["CEPGP_context_popup_T6_check_text"]:Hide();
		_G["CEPGP_context_popup_T6PT5_check_text"]:Hide();
		CEPGP_context_popup_T4_check:SetChecked(nil);
		CEPGP_context_popup_T5_check:SetChecked(nil);
		CEPGP_context_popup_T6_check:SetChecked(nil);
		CEPGP_context_popup_T6PT5_check:SetChecked(nil);

		-- Hide TextFields we won't be using
		_G["CEPGP_context_popup_title"]:Hide();
		_G["CEPGP_context_popup_amount_header"]:Hide();
		_G["CEPGP_context_popup_reason_header"]:Hide();

		CEPGP_context_popup_header:SetText("Manually Distribute an Item");
		CEPGP_context_popup_desc_centered:SetText("Determines the winner for an item.\nIf the item is no longer on the corpse to be MLed\nyou will have to MANUALLY deduct DKP from the winner.");
		CEPGP_context_editbox_centered:SetText("");
		CEPGP_context_popup_confirm:SetScript('OnClick', function()
															PlaySound(799);
															HideUIPanel(CEPGP_context_popup);
															local itemID = CEPGP_context_editbox_centered:GetText()
															if not itemID or itemID == "" then
																message("An ItemID must be given")
																return
															end
															if not CEPGP_isNumber(itemID) then
																message("ItemID must be a number")
																return
															end
															TnTDKP_manuallyDetermineWinnerForItem(tonumber(itemID))
														end);

	-- "Edit Priority/Lottery List" button on the Toolbox page												
	elseif strfind(obj, "TnTDKP_edit_priority_or_lottery") then
		local TnTDKP_displayMode_snapshot = TnTDKP_displayMode
		TnTDKP_displayMode = "priority_lottery_edit"
		ShowUIPanel(CEPGP_context_popup);
		ShowUIPanel(CEPGP_context_amount_editbox);
		ShowUIPanel(CEPGP_context_reason_editbox);
		HideUIPanel(CEPGP_context_role_dropdown);
		HideUIPanel(CEPGP_context_editbox_centered);
		HideUIPanel(CEPGP_context_popup_open_check);
		_G["CEPGP_context_popup_open_check_text"]:Hide();
		CEPGP_context_popup_open_check:SetChecked(nil);

		-- Enable the Priority/Lottery CheckBoxes for this flow.
		ShowUIPanel(CEPGP_context_popup_priority_check);
		ShowUIPanel(CEPGP_context_popup_lottery_check);
		_G["CEPGP_context_popup_priority_check_text"]:Show();
		_G["CEPGP_context_popup_lottery_check_text"]:Show();
		TnTDKP_awardMode = "priority"
		CEPGP_context_popup_priority_check:SetChecked(1);
		CEPGP_context_popup_lottery_check:SetChecked(nil);

		-- SHOW the "ADD" and "REMOVE" Checkboxes
		ShowUIPanel(CEPGP_context_popup_ADD_check);
		ShowUIPanel(CEPGP_context_popup_REMOVE_check);
		_G["CEPGP_context_popup_ADD_check_text"]:Show();
		_G["CEPGP_context_popup_REMOVE_check_text"]:Show();
		CEPGP_context_popup_ADD_check:SetChecked(1);
		CEPGP_context_popup_REMOVE_check:SetChecked(nil);

		-- Suppress the T4/T5/T6/T6.5 Checkboxes
		HideUIPanel(CEPGP_context_popup_T4_check);
		HideUIPanel(CEPGP_context_popup_T5_check);
		HideUIPanel(CEPGP_context_popup_T6_check);
		HideUIPanel(CEPGP_context_popup_T6PT5_check);
		_G["CEPGP_context_popup_T4_check_text"]:Hide();
		_G["CEPGP_context_popup_T5_check_text"]:Hide();
		_G["CEPGP_context_popup_T6_check_text"]:Hide();
		_G["CEPGP_context_popup_T6PT5_check_text"]:Hide();
		CEPGP_context_popup_T4_check:SetChecked(nil);
		CEPGP_context_popup_T5_check:SetChecked(nil);
		CEPGP_context_popup_T6_check:SetChecked(nil);
		CEPGP_context_popup_T6PT5_check:SetChecked(nil);

		-- Display the text fields we want to display and initialize them for this flow
		CEPGP_context_popup_header:SetText("Modify Item List");
		CEPGP_context_popup_title:SetText("");
		_G["CEPGP_context_popup_desc_centered"]:Show();
		_G["CEPGP_context_popup_amount_header"]:Show();
		_G["CEPGP_context_popup_reason_header"]:Show();
		CEPGP_context_popup_amount_header:SetText("Player:")
		CEPGP_context_popup_reason_header:SetText("ItemID:")
		CEPGP_context_popup_desc_centered:SetText("Modify PRIORITY list for a player")

		CEPGP_context_amount_editbox:SetText("");
		CEPGP_context_reason_editbox:SetText("");
		CEPGP_context_popup_cancel:SetScript('OnClick', function()
															PlaySound(799);
															HideUIPanel(CEPGP_context_popup);
															TnTDKP_displayMode = TnTDKP_displayMode_snapshot
														end);
		CEPGP_context_popup_confirm:SetScript('OnClick', function()
															PlaySound(799);
															HideUIPanel(CEPGP_context_popup);
															local player = CEPGP_context_amount_editbox:GetText()
															local itemID = CEPGP_context_reason_editbox:GetText()
															if not player or player == "" then
																message("A player name must be given")
																return
															end
															if not itemID or itemID == "" then
																message("An ItemID must be given")
																return
															end
															if not CEPGP_isNumber(itemID) then
																message("ItemID must be a number")
																return
															end

															if CEPGP_context_popup_ADD_check:GetChecked() then
																if TnTDKP_awardMode == "priority" then
																	TnTDKP_addItemToPriorityList(player, tonumber(itemID))
																else
																	TnTDKP_addItemToLotteryList(player, tonumber(itemID))
																end
															else
																if TnTDKP_awardMode == "priority" then
																	TnTDKP_removeItemFromPriorityList(player, tonumber(itemID))
																else
																	TnTDKP_removeItemFromLotteryList(player, tonumber(itemID))
																end
															end
															TnTDKP_displayMode = TnTDKP_displayMode_snapshot
														end);

	-- The "Add to Standby" button on the Standby List page
	elseif strfind(obj, "CEPGP_standby_ep_list_add") then
		ShowUIPanel(CEPGP_context_popup);
		ShowUIPanel(CEPGP_context_editbox_centered);
		HideUIPanel(CEPGP_context_role_dropdown);
		HideUIPanel(CEPGP_context_amount_editbox);
		HideUIPanel(CEPGP_context_reason_editbox);

		-- Hide all of the various CheckBoxes, they aren't used in this flow.
		HideUIPanel(CEPGP_context_popup_priority_check);
		HideUIPanel(CEPGP_context_popup_lottery_check);
		HideUIPanel(CEPGP_context_popup_open_check);
		_G["CEPGP_context_popup_priority_check_text"]:Hide();
		_G["CEPGP_context_popup_lottery_check_text"]:Hide();
		_G["CEPGP_context_popup_open_check_text"]:Hide();
		CEPGP_context_popup_priority_check:SetChecked(nil);
		CEPGP_context_popup_lottery_check:SetChecked(nil);
		CEPGP_context_popup_open_check:SetChecked(nil);

		-- Suppress the "ADD" and "REMOVE" Checkboxes
		HideUIPanel(CEPGP_context_popup_ADD_check);
		HideUIPanel(CEPGP_context_popup_REMOVE_check);
		_G["CEPGP_context_popup_ADD_check_text"]:Hide();
		_G["CEPGP_context_popup_REMOVE_check_text"]:Hide();
		CEPGP_context_popup_ADD_check:SetChecked(nil);
		CEPGP_context_popup_REMOVE_check:SetChecked(nil);

		-- Suppress the T4/T5/T6/T6.5 Checkboxes
		HideUIPanel(CEPGP_context_popup_T4_check);
		HideUIPanel(CEPGP_context_popup_T5_check);
		HideUIPanel(CEPGP_context_popup_T6_check);
		HideUIPanel(CEPGP_context_popup_T6PT5_check);
		_G["CEPGP_context_popup_T4_check_text"]:Hide();
		_G["CEPGP_context_popup_T5_check_text"]:Hide();
		_G["CEPGP_context_popup_T6_check_text"]:Hide();
		_G["CEPGP_context_popup_T6PT5_check_text"]:Hide();
		CEPGP_context_popup_T4_check:SetChecked(nil);
		CEPGP_context_popup_T5_check:SetChecked(nil);
		CEPGP_context_popup_T6_check:SetChecked(nil);
		CEPGP_context_popup_T6PT5_check:SetChecked(nil);

		-- Hide TextFields we won't be using
		_G["CEPGP_context_popup_title"]:Hide();
		_G["CEPGP_context_popup_amount_header"]:Hide();
		_G["CEPGP_context_popup_reason_header"]:Hide();

		CEPGP_context_popup_header:SetText("Add to Standby");
		CEPGP_context_popup_desc_centered:SetText("Add a Guild member to the standby list");
		CEPGP_context_editbox_centered:SetText("");
		CEPGP_context_popup_confirm:SetScript('OnClick', function()
															PlaySound(799);
															HideUIPanel(CEPGP_context_popup);
															CEPGP_addToStandby(CEPGP_context_editbox_centered:GetText());
														end);
    -- "Init Player" button on the Toolbox page
	elseif strfind(obj, "TnTDKP_init_player") then
		ShowUIPanel(CEPGP_context_popup);
		ShowUIPanel(CEPGP_context_editbox_centered);
		HideUIPanel(CEPGP_context_role_dropdown);
		HideUIPanel(CEPGP_context_amount_editbox);
		HideUIPanel(CEPGP_context_reason_editbox);

		-- Hide all of the various CheckBoxes, they aren't used in this flow.
		HideUIPanel(CEPGP_context_popup_priority_check);
		HideUIPanel(CEPGP_context_popup_lottery_check);
		HideUIPanel(CEPGP_context_popup_open_check);
		_G["CEPGP_context_popup_priority_check_text"]:Hide();
		_G["CEPGP_context_popup_lottery_check_text"]:Hide();
		_G["CEPGP_context_popup_open_check_text"]:Hide();
		CEPGP_context_popup_priority_check:SetChecked(nil);
		CEPGP_context_popup_lottery_check:SetChecked(nil);
		CEPGP_context_popup_open_check:SetChecked(nil);

		-- Suppress the "ADD" and "REMOVE" Checkboxes
		HideUIPanel(CEPGP_context_popup_ADD_check);
		HideUIPanel(CEPGP_context_popup_REMOVE_check);
		_G["CEPGP_context_popup_ADD_check_text"]:Hide();
		_G["CEPGP_context_popup_REMOVE_check_text"]:Hide();
		CEPGP_context_popup_ADD_check:SetChecked(nil);
		CEPGP_context_popup_REMOVE_check:SetChecked(nil);

		-- Suppress the T4/T5/T6/T6.5 Checkboxes
		HideUIPanel(CEPGP_context_popup_T4_check);
		HideUIPanel(CEPGP_context_popup_T5_check);
		HideUIPanel(CEPGP_context_popup_T6_check);
		HideUIPanel(CEPGP_context_popup_T6PT5_check);
		_G["CEPGP_context_popup_T4_check_text"]:Hide();
		_G["CEPGP_context_popup_T5_check_text"]:Hide();
		_G["CEPGP_context_popup_T6_check_text"]:Hide();
		_G["CEPGP_context_popup_T6PT5_check_text"]:Hide();
		CEPGP_context_popup_T4_check:SetChecked(nil);
		CEPGP_context_popup_T5_check:SetChecked(nil);
		CEPGP_context_popup_T6_check:SetChecked(nil);
		CEPGP_context_popup_T6PT5_check:SetChecked(nil);

		-- Hide TextFields we won't be using
		_G["CEPGP_context_popup_title"]:Hide();
		_G["CEPGP_context_popup_amount_header"]:Hide();
		_G["CEPGP_context_popup_reason_header"]:Hide();

		CEPGP_context_popup_header:SetText("Initialize Player");
		CEPGP_context_popup_desc_centered:SetText("Initializes the specified player if it hasn't been done already.\nDoes nothing if a record already exists for this player.");
		CEPGP_context_editbox_centered:SetText("");
		CEPGP_context_popup_confirm:SetScript('OnClick', function()
															PlaySound(799);
															HideUIPanel(CEPGP_context_popup);
															-- Simply Fetching the DKP for the given player from ANY table is sufficient to init their record
															local DKP = TnTDKP_getLotteryDKP(CEPGP_context_editbox_centered:GetText(), "T4")
														end);
	
	elseif strfind(obj, "CEPGP_StandbyButton") then
		local name = _G[_G[_G[obj]:GetName()]:GetParent():GetName() .. "Info"]:GetText();
		for i = 1, CEPGP_ntgetn(STANDBY_ROSTER) do
			if STANDBY_ROSTER[i] == name then
				table.remove(STANDBY_ROSTER, i);
			end
		end
		CEPGP_UpdateStandbyScrollBar();
	end
end

-- Displays the RolePicker dialog box
function TnTDKP_handleRolePicker(playerName)
	ShowUIPanel(CEPGP_context_popup);
	ShowUIPanel(CEPGP_context_role_dropdown);
	HideUIPanel(CEPGP_context_editbox_centered);
	HideUIPanel(CEPGP_context_amount_editbox);
	HideUIPanel(CEPGP_context_reason_editbox);

	-- Hide all of the various CheckBoxes, they aren't used in this flow.
	HideUIPanel(CEPGP_context_popup_priority_check);
	HideUIPanel(CEPGP_context_popup_lottery_check);
	HideUIPanel(CEPGP_context_popup_open_check);
	_G["CEPGP_context_popup_priority_check_text"]:Hide();
	_G["CEPGP_context_popup_lottery_check_text"]:Hide();
	_G["CEPGP_context_popup_open_check_text"]:Hide();
	CEPGP_context_popup_priority_check:SetChecked(nil);
	CEPGP_context_popup_lottery_check:SetChecked(nil);
	CEPGP_context_popup_open_check:SetChecked(nil);

	-- Suppress the "ADD" and "REMOVE" Checkboxes
	HideUIPanel(CEPGP_context_popup_ADD_check);
	HideUIPanel(CEPGP_context_popup_REMOVE_check);
	_G["CEPGP_context_popup_ADD_check_text"]:Hide();
	_G["CEPGP_context_popup_REMOVE_check_text"]:Hide();
	CEPGP_context_popup_ADD_check:SetChecked(nil);
	CEPGP_context_popup_REMOVE_check:SetChecked(nil);

	-- Suppress the T4/T5/T6/T6.5 Checkboxes
	HideUIPanel(CEPGP_context_popup_T4_check);
	HideUIPanel(CEPGP_context_popup_T5_check);
	HideUIPanel(CEPGP_context_popup_T6_check);
	HideUIPanel(CEPGP_context_popup_T6PT5_check);
	_G["CEPGP_context_popup_T4_check_text"]:Hide();
	_G["CEPGP_context_popup_T5_check_text"]:Hide();
	_G["CEPGP_context_popup_T6_check_text"]:Hide();
	_G["CEPGP_context_popup_T6PT5_check_text"]:Hide();
	CEPGP_context_popup_T4_check:SetChecked(nil);
	CEPGP_context_popup_T5_check:SetChecked(nil);
	CEPGP_context_popup_T6_check:SetChecked(nil);
	CEPGP_context_popup_T6PT5_check:SetChecked(nil);

	-- Hide TextFields we won't be using
	_G["CEPGP_context_popup_amount_header"]:Hide();
	_G["CEPGP_context_popup_reason_header"]:Hide();

	_G["CEPGP_context_popup_title"]:Show();
	CEPGP_context_popup_header:SetText("Set Role");
	CEPGP_context_popup_title:SetText("Set Role for: " .. playerName);
	CEPGP_context_popup_desc_centered:SetText("Assign the designated player a role from the dropdown.\nSorry the order is chaotic - nothing I can do about it :/");
	CEPGP_context_popup_confirm:SetScript('OnClick', function()
														PlaySound(799);
														HideUIPanel(CEPGP_context_popup);
														local role = TnTDKP_selectedRole;
														PLAYER_ROLE_CONFIG[playerName] = role;
														CEPGP_UpdateAllMembersScrollBar();
														CEPGP_UpdateRaidScrollBar();
													end);
end

function CEPGP_distribute_popup_OnEvent(event)
	if event == "CHAT_MSG_LOOT" then
		CEPGP_distPlayer = string.sub(arg1, 0, string.find(arg1, " ")-1);
		if CEPGP_distPlayer == "You" then
			CEPGP_distPlayer = UnitName("player");
		end
	end
	if CEPGP_distributing then
		if event == "UI_ERROR_MESSAGE" and arg1 == "Inventory is full." and CEPGP_distPlayer ~= "" then
			CEPGP_print(CEPGP_distPlayer .. "'s inventory is full", 1);
			CEPGP_distribute_popup:Hide();
		elseif event == "UI_ERROR_MESSAGE" and arg1 == "You can't carry any more of those items." and CEPGP_distPlayer ~= "" then
			CEPGP_print(CEPGP_distPlayer .. " can't carry any more of this unique item", 1);
			CEPGP_distribute_popup:Hide();
		end
	end
end

-- This function gets passed into and invoked in CEPGP_UIDropDownMenu_Initialize()
function CEPGP_initRoleDropdown(frame, level, menuList)
	for _, role in pairs(playerRoles) do
		local info = {text = role, func = CEPGP_setPlayerRoleDropdownOnClick};
		local entry = UIDropDownMenu_AddButton(info);
	end
end

-- This gets called when one of the entries in the Role Dropdown gets clicked
function CEPGP_setPlayerRoleDropdownOnClick(self, arg1, arg2, checked)
	if (not checked) then
		local selectedRole = self:GetText();
		UIDropDownMenu_SetSelectedName(CEPGP_context_role_dropdown, selectedRole);
		-- Honestly, I simply don't know how to read this key from the UI once it's set,
		-- so I do it the clumsy way via setting a global variable
		TnTDKP_selectedRole = selectedRole;
	end
end