-- The configuration which hosts boss-specific configuration variables. Presently, they are:
-- "KillDKPAward" - The base DKP value awarded for killing this boss. This gets multiplied by
--                the CONTENT_PHASE_SCALAR to determine the actual amount of DKP awarded
--                for killing it.
-- "LootDKPCost" - The flat cost of loot from this boss. This is configured to align perfectly with
--                the Content Release plan, where the cost of items increases for each subsequent
--                raid tier. If all is running well, the most expensive boss loot available at any
--                given point should line up directly with the current CONTENT_PHASE_SCALAR value.
--                The reason these DKP costs don't scale via the CONTENT_PHASE_SCALAR is so that
--                loot from previous raid tiers will naturally be way cheaper than loot from the current tier.
bossConfig = {
	["Hydrospawn"] = {
		["KillDKPAward"] = 25,
		["LootDKPCost"] = 1000,
	},
	["Zevrim Thornhoof"] = {
		["KillDKPAward"] = 75,
		["LootDKPCost"] = 1000,
	},
	["Lethtendris"] = {
		["KillDKPAward"] = 50,
		["LootDKPCost"] = 1000,
	},
	["Lucifron"] = {
		["KillDKPAward"] = 25,
		["LootDKPCost"] = 1000,
	},
}