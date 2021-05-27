# Overview
This test requires Nocjr, Akaran, and Anarra to do a DM East "jump run", killing the following bosses (IN THIS ORDER):
1. Hydrospawn
2. Zevrim Thornhoof
3. Lethtendris
4. Allzin the Wildshaper

# AddOn Administrator Setup (How to run this test)
As the administrator of the AddOn, these steps must be followed to properly "load" in this data:
1. Completely exit the game
2. Navigate to your World of Warcraft/\_classic\_/Interface/AddOns/TnTDKP/ directory and **delete BossConfig.lua, MainRaidRoster.lua, and ReserveRaidRoster.lua**
3. Copy in the BossConfig.lua, MainRaidRoster.lua, and ReserveRaidRoster.lua files from this repository into your TnTDKP AddOn directory
4. Navigate to your World of Warcfrat/\_classic\_/WTF/Account/<your_account_name>/SavedVariables/ directory and open TnTDKP.lua in your Text Editor of choice
5. Open the **TestData.lua** file in this repository in either a text editor, or view it on the repository website and simply click "Copy source to clipboard"
6. Go to the text editor with TnTDKP.lua open and **delete** the *PLAYER_PRIORITY_REGISTRY*, *PLAYER_LOTTERY_REGISTRY*, *PRIORITY_DKP_TABLE*, and *LOTTERY_DKP_TABLE* entries. Leave all other data in TnTDKP.lua intact.
7. Paste in the data from your clipboard, which should be these same four entries.
8. **Save** TnTDKP.lua
9. Log back into the game
10. **IMPORTANT** Enable the debug mode of the AddOn by typing: `/tnt debugMode`. Note that this flag needs to be re-enabled every time you log out or /reload.

# Data Setup
This section simply describes the data setup that was done in order to prepare the AddOn to run these tests. This is pasted here for informational purposes only, the Administrator of the AddOn wishing to run these tests can simply disregard this section. The data was prepared as follows:
* Hydrospawn, Zevrim Thornhoof, and Lethtendris were added to BossConfig (Allzin the Wildshaper was intentionally left out)
* Hydrospawn's kill DKP set to 25, Zevrim's kill DKP set to 75, and Lethtendris' kill DKP set to 50
* Akaran was set as a "Reserve" Raider. Nocjr and Anarra remain Main Raiders
* Nocjr set to -1000 Priority & Lottery DKP
* Anarra set to -1000 Priority & Lottery DKP
* Akaran set to 2000 Priority & -1000 Lottery DKP
* All boss loot from Hydrospawn added to Nocjr and Anarra's Priority lists
* All boss loot from Hydrospawn added to Akaran's Lottery lists
* All boss loot from Zevrim Thornhoof added to Nocjr, Anarra, and Akaran's Priority lists
* All boss loot from Lethtendris added to Nocjr, Anarra, and Akaran's Priority lists
* **Razor Gauntlets** and **Shadewood Cloak** added to Akaran's Priority list, and *all* other boss loot from Allzin the Wildshaper added to Akaran's Lottery list
* All boss loot from Allzin the Wildshaper added to Nocjr and Anarra's Lottery lists

# Tests
This is the list of tests that are executed by this AddOn. They provide a brief summary of what the current state of the data will be by the time the group gets to the boss (again, assuming the bosses were killed in the order outlined in the Overview), as well as what the expected results should be. The **What is Tested** section enumerates what specific corner-cases were tested.
## Hydrospawn
Awards 25DKP upon death.
### Current State Before Distribution:
* Nocjr and Anarra have *all* boss loot on Priority
* Akaran has *all* boss loot on Lottery
* Nocjr has -975 Priority & Lottery DKP
* Anarra has -975 Priority & Lottery DKP
* Akaran has 2025 Priority and -975 Lottery DKP

### Expected Result:
* Should Lottery amongst all 3, since Noc and Anarra are negative Priority DKP
* The Lottery should simply be a roll from 1-3 since all three members have negative Lottery DKP
* Nocjr has -900 Priority DKP and either -900 or -1900 Lottery DKP (depending if he won the Lottery)
* Anarra has -900 Priority DKP and either -900 or -1900 Lottery DKP (depending if she won the Lottery)
* Akaran has 2025 Priority DKP and either -900 or -1900 Lottery DKP (depending if he won the Lottery)

### What is Tested:
* Negative DKP "Haast" rule logic which adds it to Lottery for the player automatically
* Negative Lottery DKP reducing to 1 ticket
* Reserve raiders can still participate in Lottery

## Zevrim Thornhoof
Awards 75DKP upon death.
### Current State Before Distribution:
* Nocjr, Anarra, and Akaran have *all* boss loot on Priority
* Nocjr has -900 Priority DKP and either -900 or -1900 Lottery DKP (depending if he won the Lottery on Hydrospawn)
* Anarra has -900 Priority DKP and either -900 or -1900 Lottery DKP (depending if she won the Lottery on Hydrospawn)
* Akaran has 2100 Priority DKP and either -900 or -1900 Lottery DKP (depending if he won the Lottery on Hydrospawn)

### Expected Result:
* Akaran wins Priority since other two were negative Priority DKP
* Akaran has 1100 Priority DKP and either -900 or -1900 Lottery DKP (depending if he won the Lottery on Hydrospawn)

### What is Tested:
* Negative DKP "Haast" rule which skips players in Priority who have negative Priority DKP
* Reserve member still getting Priority before falling down to Lottery

## Lethtendris
Awards 50DKP upon death.
### Required Actions:
* Nocjr and Anarra must be awarded 1000 Priority DKP to get them out of the negatives

### Current State Before Distribution:
* Nocjr, Anarra, and Akaran have *all* boss loot on Priority
* Nocjr has 150 Priority DKP and either -900 or -1900 Lottery DKP (depending if he won the Lottery on Hydrospawn)
* Anarra has 150 Priority DKP and either -900 or -1900 Lottery DKP (depending if she won the Lottery on Hydrospawn)
* Akaran has 1150 Priority DKP and either -900 or -1900 Lottery DKP (depending if he won the Lottery on Hydrospawn)

### Expected Result:
* Tiebreaker Priority roll-off between Nocjr and Anarra
* Nocjr has either 150 or -850 Priority DKP (depending if he won the Priority roll-off on Lethtendris) and either -900 or -1900 Lottery DKP (depending if he won the Lottery on Hydrospawn)
* Anarra has either 150 or -850 Priority DKP (depending if she won the Priority roll-off on Lethtendris) and either -900 or -1900 Lottery DKP (depending if she won the Lottery on Hydrospawn)
* Akaran has 1150 Priority DKP and either -900 or -1900 Lottery DKP (depending if he won the Lottery on Hydrospawn)

### What is Tested:
* Tiebreaker Priority roll-off logic
* Reserve members can't win at Priority over Main raiders


## Alzzin the Wildshaper
**Does not award any DKP upon death.**

### Current State Before Distribution:
* Akaran has **Razor Gauntlets** and **Shadewood Cloak** on Priority, and *all* other boss loot on Lottery
* Nocjr and Anarra have *all* boss loot on Lottery
* Nocjr has either 150 or -850 Priority DKP (depending if he won the Priority roll-off on Lethtendris) and either -900 or -1900 Lottery DKP (depending if he won the Lottery on Hydrospawn)
* Anarra has either 150 or -850 Priority DKP (depending if she won the Priority roll-off on Lethtendris) and either -900 or -1900 Lottery DKP (depending if she won the Lottery on Hydrospawn)
* Akaran has 1150 Priority DKP and either -900 or -1900 Lottery DKP (depending if he won the Lottery on Hydrospawn)

### Expected Result:
* If Razor Gauntlets or Shadewood Cloak drop, Akaran wins them at Priority and ends up with 150 Priority DKP
* If any other loot drops, it gets resolved in Lottery.
* **All items will still cost 1000 Priority/Lottery DKP**

### What is Tested:
* Alzzin the Wildshaper is **not** in the BossConfig, so this tests the case where a T1 BoE drops off of a trash mob
* This also tests my logic where I make sure Trash loot still costs as much as boss loot in the same Raid