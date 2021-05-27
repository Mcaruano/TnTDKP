-- The configuration which hosts boss-specific configuration variables.
-- As of 4/21 Onyxia no longer awards DKP, and her 75 DKP has been distributed
-- through MC.
-- As of 10/2 we are now doing Geddon/Garr only in MC, so the 590 DKP has been
-- evenly split between the two
tierOneBossConfig = {	
	-- Molten Core (Phase 1) --
	["Garr"] = {
		["KillDKPAward"] = 295,
	},
	["Baron Geddon"] = {
		["KillDKPAward"] = 295,
	},
}
