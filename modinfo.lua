name = "Cheat Box"
description = "Provides Cheats Feature Inside Game"
author = "xxx"
version = "1.03"

forumthread = '' -- None

api_version = 6

icon_atlas = "cheatbox.xml"
icon = "cheatbox.tex"

dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true
dst_compatible = false


priority=00110000


local keyslist = {}
local string = ""
for i = 1, 26 do
	local ch = string.char(65 + i)
	keyslist[i] = {description = ch, data = ch:lower():byte()}
end

local percent_options = {}
for i = 1, 30 do
	if i == 10 then
		percent_options[i] = {description = "Default", data = i}
	else
		percent_options[i] = {description = i*10, data = i}
	end
end

configuration_options=
{
	{
		name="CB_Save_Encoding",
		label="Save Encryption",
		options=
		{
			{description = "Enabled", data=true},
			{description = "Disabled", data=false},
		},
		default=true,
	},
	{
		name="CB_Unlock_All_Chars",
		label="Unlock Characters",
		options=
		{
			{description = "On", data=true},
			{description = "Off", data=false},
		},
		default=false,
	},
	{
		name="CB_Speed_Modifier",
		label="Player Speed Modifier Percent",
		options=percent_options,
		default=10,
	},
	{
		name="CB_GM_Color",
		label="God Mode Changes Color",
		options=
		{
			{description = "On", data=true},
			{description = "Off", data=false},
		},
		default=true,
	},
	{
		name="CB_GM_Key",
		label="God Mode Key",
		options = keyslist,
		default = string.byte(string.lower("G")),
		hover = "Toggle God Mode With This Key.",
	},
	{
		name="CB_FOG_Key",
		label="Toggle Map Key",
		options = keyslist,
		default = string.byte(string.lower("F")),
		hover = "Toggle Map Fog With This Key.",
	},
	{
	    name = "CB_Heal_Key",
        label = "Give Max Health Key",
        options = keyslist,
        default = string.byte(string.lower("H")),
	},
	{
	    name = "CB_Feed_Key",
        label = "Give Max Hunger Key",
        options = keyslist,
        default = string.byte(string.lower("V")),
	},
	{
	    name = "CB_Sane_Key",
        label = "Give Max Sanity Key",
        options = keyslist,
        default = string.byte(string.lower("C")),
	},
	{
	    name = "CB_Attacker_Damage_Type",
        label = "Attack Mode",
		options=
        {
			{description = "Deafult", data=false},
			{description = "Freeze", data=1},
			{description = "Burn", data=2},
		},
        default = 0,
	},
	{
	    name = "CB_Piper_Mode",
        label = "Piper Mode",
		options=
        {
			{description = "None", data=false},
			{description = "Pigs", data=1},
			{description = "Bunnymans", data=2},
			{description = "Spiders", data=3},
		},
        default = false,
	},
	{
	    name = "CB_Piper_Key",
        label = "Piper Mode Key",
		options=
        {
			{description = "Always", data=0},
			{description = "CTRL", data=1},
			{description = "Shift", data=2},
			{description = "Alt", data=3},
		},
        default = 2,
		hover = "While key down",
	},
}