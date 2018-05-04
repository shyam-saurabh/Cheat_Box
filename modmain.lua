local require = GLOBAL.require
local package = GLOBAL.package
local rawget = GLOBAL.rawget

-- Load Strings
modimport("strings.lua")

--=================================================================================================--
--										Mod Debug Handler								   	   --
--=================================================================================================--

-- Enable/Disable Debugging Based on ModForceEnabled or ModInitPrint
modimport("scripts/CB_Debug.lua")
local CB_DEBUG = rawget(GLOBAL, "CB_DEBUG") and GLOBAL.CB_DEBUG or false

-- Notify if debugger status
if CB_DEBUG then print("Cheat Box Debug Active!") else print "Cheat Box Debug Inactive!" end

--=================================================================================================--
--										Mod Screens								   	   --
--=================================================================================================--

-- Add Pause Menu Button
modimport("scripts/extensions/CB_PauseMenu.lua")

--=================================================================================================--
--										Mod InGame Settings Helpers								   --
--=================================================================================================--

-- Get InGame Config Data Based On GetModConfigData
local function GetModInGameConfigData(optionname)

	-- Get Mod Configs
	local config = GLOBAL.KnownModIndex:GetModConfigurationOptions(modname)
	
	-- Exit If No Valid Data
	if not config
		or type(config) ~= "table"
		and #config[#config] <= 0
	then return end
	
	-- Get Option
	for i,v in pairs(config[#config]) do
		if v.name == optionname then
			if v.saved ~= nil then return v.saved end
			return v.default
		end
	end
	
	return
end


-- Set InGame Config Data
local function SetModInGameConfigData(optionname, value)

	-- Get Mod Configs
	local config = GLOBAL.KnownModIndex:GetModConfigurationOptions(modname)
	
	-- Exit If No Valid Data
	if not config
		or type(config) ~= "table"
		and #config[#config] <= 0
	then return end
	
	-- Get Option
	for i,v in pairs(config[#config]) do
		if v.name == optionname then
			v.saved = value
			return true
		end
	end
	
	return
end

--=================================================================================================--
--										Mod Settings Update									   	   --
--=================================================================================================--

-- Update Settings
local function update_settings()
	
	local opt = {}
	
	-- InGame Menu Hotkey
	opt.KEY_INGAME_MOD_CONFIG = GetModConfigData("INGAME_SETTINGS_KEY"):lower():byte()
	
	-- Encode Save Settings
	opt.FLAG_ENCODE_SAVE = GetModConfigData("CB_ENCODE_SAVE")
	
	-- Character Unlock Settings
	opt.FLAG_UNLOCK_CHARS = GetModConfigData("CB_UNLOCK_CHARS")
	
	---------- InGame Settings ----------
	
	-- Player Speed Multiplier Settings
	opt.MULTIPLIER_SPEED = GetModInGameConfigData("CB_Speed_Modifier")
	
	-- Invincible Settings
	opt.FLAG_INVINCIBLE = GetModInGameConfigData("CB_Invincible_State")
	opt.TINT_INVINCIBLE = GetModInGameConfigData("CB_GM_Color")
	
	-- Map Fog Settings
	opt.FLAG_REVEAL_MAP = GetModInGameConfigData("CB_Reveal_Map")
	
	-- Damage Type Settings
	opt.FLAG_DAMAGE_REFLECT = GetModInGameConfigData("CB_Damage_Reflect")
	opt.TYPE_DAMAGE = GetModInGameConfigData("CB_Damage_Type")
	
	-- Max Status Settings
	opt.FLAG_MAXSTATUS = GetModInGameConfigData("CB_Max_Status")
	opt.TYPE_MAXSTATUS = GetModInGameConfigData("CB_Max_Status_Type")
	
	-- Piper Mode Settings
	opt.FLAG_PIPER_MODE = GetModInGameConfigData("CB_Piper_State")
	
	---------- Other Constants ----------
	
	opt.RANGE_PIPER_MODE = 25 				-- 9001 is Whole Map, 25 is horn, 12 is onemanband,spiderhat
	opt.PIPER_MODE_MAX_FOLLOWERS = 10
	
	-- Return Updated Values
	GLOBAL.TUNING.CHEAT_BOX = opt
end

-- Initilize Settings
update_settings()

-- Add Update Settings Hook
AddSimPostInit(function(inst) inst:ListenForEvent(modname.."_InGameSettingsUpdate",update_settings) end)

--=================================================================================================--
--										Mod Features Section									   --
--=================================================================================================--

-- Helper Local Variable Variables
local CHEAT_BOX = GLOBAL.TUNING.CHEAT_BOX

-- thesim -> GetWorkshopMods
-- thesim -> GetWorkshopUpdateStatus
-- screens/modsscreen.lua

-- Disable Save Game Encoding
local SaveEncoding = require "features/CB_DisableSaveEncoding"
AddGamePostInit(SaveEncoding)


-- Unlock Characters
local UnlockChars = require "features/CB_UnlockCharacters"
AddGamePostInit(UnlockChars)


-- Player Speed
local PlayerSpeedModifier = require "features/CB_PlayerSpeedModifier"
AddSimPostInit(PlayerSpeedModifier)


-- Map Fog
local MapFog = require "features/CB_ToggleMapFog"
AddSimPostInit(function(inst)
	inst:ListenForEvent(modname.."_InGameSettingsUpdate",MapFog)
end)


-- Invincible
local Invincible = require "features/CB_Invincible"
AddSimPostInit(function(inst)
	Invincible.Install(inst)
	inst:ListenForEvent(modname.."_InGameSettingsUpdate",function(inst)
		Invincible.Update(inst)
	end)
end)


-- Damage Type
local Damage = require "features/CB_DamageType"
AddSimPostInit(function(inst)
	inst:ListenForEvent("attacked", Damage.ReturnDamage)
	inst:ListenForEvent("onattackother", Damage.AttackDamage)
end)


-- Max Status
local CB_MaxStatus = require "features/CB_MaxStatus_v2"
AddSimPostInit(function(inst)
	inst:ListenForEvent(modname.."_InGameSettingsUpdate",function(inst)
		if CHEAT_BOX.FLAG_MAXSTATUS then
			CB_MaxStatus(inst)
			CHEAT_BOX.FLAG_MAXSTATUS = false
			SetModInGameConfigData("CB_Max_Status", false)
		end
	end)
end)


-- Piper Mode
local PiperMode = require "features/CB_PiperMode"
AddSimPostInit(function(inst)
	inst:DoPeriodicTask(10+math.random(),PiperMode,1)
end)