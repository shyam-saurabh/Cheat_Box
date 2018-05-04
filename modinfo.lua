name = "Cheat Box"
author = "xxx"
version = "1.03"
description = "Provides Cheats Feature Inside Game.\nVersion: ".. version

forumthread = '' -- No form thread

api_version = 6

icon_atlas = "cheatbox.xml"
icon = "cheatbox.tex"

id = "cheat_box"

dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true
dst_compatible = false

priority=00110000

----------- Mod Configurations Helpers ---------------

-- Key List
local string,ch = "","A"
local keys_list = { {description="None",data=i} }
for i = 2, 27 do
	keys_list[i] = {description = ch, data = ch}
	ch = string.char(ch:byte()+1):upper()
end

-- Multiplier List
local multiplier_list = {}
for i = 1,20 do
	multiplier_list[i] = { data=i/4, description = i == 4 and "Default" or i/4 .. "x" }
end

-- On/Off Options
local toggle_list = {
	{description = "On", data=true},
	{description = "Off", data=false},
}

-------------------------------------------------------------
--------------------- Mod Configurations --------------------
-------------------------------------------------------------

-- Options Table
local opts = {

	-- Save Encryption
	{
		name = "CB_ENCODE_SAVE",
		label = "Save Encoding",
		options = toggle_list,
		default = true,
	},

	-- Unlock Characters
	{
		name = "CB_UNLOCK_CHARS",
		label = "Unlock Characters",
		options = toggle_list,
		default = false,
	},

	-- InGame Settings Key
	{
		name = "INGAME_SETTINGS_KEY",
		label = "Toggle Cheat Box Key",
		options = keys_list,
		default = "C",
		hover = "Toggle In-Game Settings With This Key.",
	},
}

-------------------------------------------------------------
----------------- Mod Ingame Configurations -----------------
-------------------------------------------------------------

opts[#opts+1] = {

	-- Invincible Mode
	{
		name="CB_Invincible_State",
		label="Toggle Invincibility",
		options = toggle_list,
		default = false,
		hover = "Toggle Invincibility",
	},

	-- Invincible Tint
	{
		name = "CB_GM_Color",
		label = "Invincible Tint",
		options = toggle_list,
		default = true,
	},

	-- Toggle Max Status
	{
		name="CB_Max_Status",
		label="Toggle Max Status",
		options = toggle_list,
		default = false,
		hover = "Toggle Max Status",
	},

	-- Toggle Map Fog
	{
		name="CB_Reveal_Map",
		label="Toggle Full Map",
		options = toggle_list,
		default = false,
		hover = "Toggle Full Map",
	},

	-- Reflect Damage to attacker
	{
		name = "CB_Damage_Reflect",
		label = "Damage Reflect",
		options = toggle_list,
		default = true,
	},

	-- Piper Mode
	{
		name = "CB_Piper_State",
		label = "Toggle Piper Mode",
		options = toggle_list,
		default = false,
	},

	-- Speed Modifier
	{
		name = "CB_Speed_Modifier",
		label = "Player Speed",
		options = multiplier_list,
		default = 1,
	},

	-- Max Status Type
	{
		name = "CB_Max_Status_Type",
		label = "Max Status",
		options = {
			{description = "All", data=0},
			{description = "Health", data=1},
			{description = "Health+Hunger", data=2},
			{description = "Hunger", data=3},
			{description = "Hunger+Sanity", data=4},
			{description = "Sanity", data=5},
			{description = "Sanity+Health", data=6},
		},
		default = 0,
		hover = "Max Status Key Effects These Status.",
	},

	-- Damage Type
	{
		name = "CB_Damage_Type",
		label = "Damage Type",
		options=
		{
			{description = "None", data=0},
			{description = "Freeze", data=1},
			{description = "Burn", data=2},
			{description = "Sleep", data=3},
			{description = "Death", data=4},
		},
		default = 0,
	},
}

-- Add Configuration Options
configuration_options = opts