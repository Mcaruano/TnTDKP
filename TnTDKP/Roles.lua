-- This Table simply represents the list of roles which we use to
-- populate the Role Dropdown. Lua doesn't do proper lists well so
-- this has to be implemented as a Table.
playerRoles = {
	-- For these classes, there is literally no distinction between their specs.
	-- Their roles always stay the same. Even if a rogue is Dagger vs Swords, there's
	-- enough complexity in their talent trees that could see any spec using any weapons
	[1] = "Rogue",
	[2] = "Hunter",
	[3] = "Warlock",
	[4] = "Mage",

	-- Account for all 3 Paladin specs as they are completely different roles
	[5] = "Holy Paladin",
	[6] = "Ret Paladin",
	[7] = "Prot Paladin",

	-- Account for all 3 Druid specs as they are completely different roles
	[8] = "Resto Druid",
	[9] = "Balance Druid",
	[10] = "Feral Druid",

	-- For Priests, it makes no difference between Holy and Disc - both are healing specs and would require the same items
	[11] = "Healing Priest",
	[12] = "Shadow Priest",

	-- There is clear distinction between what weapons a 2H warrior uses versus a Fury Warrior
	[13] = "2H Warrior",
	[14] = "Fury Warrior",
	[15] = "Prot Warrior",
}
