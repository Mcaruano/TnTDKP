# TnTDKP
TODO: Write-up

**"Loading" the data into the AddOn:** To load the data into the data, the player must perform the following steps IN THIS ORDER:
1. Go to https://git.reolyze.com/tntclassic/tnt-dkp-addon/tree/master/TnTDKP/latest_data_fetch and click on the TnTDKPData_*.lua file to view its contents
2. Click the "Copy source to clipboard" button
3. Completely exit out of the game
4. Navigate to the existing TnTDKP.lua file in their **WTF/Account/<account_name>/SavedVariables** folder, and open it in a text editor
5. Delete the **PRIORITY_DKP_TABLE**, **LOTTERY_DKP_TABLE**, **PLAYER_PRIORITY_REGISTRY**, and **PLAYER_LOTTERY_REGISTRY** data, *including the "PRIORITY_DKP_TABLE = {" lines and the closing "}"*
6. Log into the game again. The latest data should now appear when you type `tnt show`