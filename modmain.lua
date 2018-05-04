-- refrence:- /data/scripts/screens/consolescreen.lua
-- refrence:- /data/scripts/input.lua

-- refrence:- /dtat/scripts/debugkeys.lua

-- refrence:- /data/scripts/components/health.lua
-- refrence:- /data/scripts/components/grue.lua

local CB_DEBUG = false

local CB_Enable_Fog = true
local CB_Enable_GM = false

local CB_Save_Encoding = GetModConfigData("CB_Save_Encoding")
local CB_Unlock_All_Chars = GetModConfigData("CB_Unlock_All_Chars")
local CB_Speed_Modifier = GetModConfigData("CB_Speed_Modifier")
local CB_GM_Color = GetModConfigData("CB_GM_Color")
local CB_GM_Key = GetModConfigData("CB_GM_Key")
local CB_FOG_Key = GetModConfigData("CB_FOG_Key")
local CB_Heal_Key = GetModConfigData("CB_Heal_Key")
local CB_Feed_Key = GetModConfigData("CB_Feed_Key")
local CB_Sane_Key = GetModConfigData("CB_Sane_Key")
local CB_Attacker_Damage_Type = GetModConfigData("CB_Attacker_Damage_Type")
local CB_Piper_Mode = GetModConfigData("CB_Piper_Mode")
local CB_Piper_Key = GetModConfigData("CB_Piper_Key")


local TheInput = GLOBAL.TheInput
local GetPlayer = GLOBAL.GetPlayer
	
-- Get Active Screen Name
local function GetActiveScreenName()
	local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
	return screen and screen.name or ""
end

-- Is HUD Present On Screen
local function IsDefaultScreen()
	return GetActiveScreenName():find("HUD") ~= nil
end

-- Is It Score Board Screen
local function IsScoreboardScreen()
	return GetActiveScreenName():find("PlayerStatusScreen") ~= nil
end

-- Check If Ingame To Activate Hotkey Functions
local function CB_InGame()
  return not (GLOBAL.IsPaused()
    or TheInput:IsKeyDown(GLOBAL.KEY_CTRL)
    or TheInput:IsKeyDown(GLOBAL.KEY_SHIFT)
    or TheInput:IsKeyDown(GLOBAL.KEY_ALT))
end

local function CB_Print(...)
	if CB_DEBUG then print(...) end
end

-- Dump Objects In Game Console For Debug Purpose Only
GLOBAL.CB_dump = function (d)
	for k,v in pairs(d) do CB_Print(k,v) end
end

--=================================================================================================--
--										Mod Features Section									   --
--=================================================================================================--

-- Disable Save Game Encoding
local function CB_DisableSaveCompression()
	CB_Print("Save Compression Disabled.")
	GLOBAL.ENCODE_SAVES = false
end

-- Unlock All Characters
local function CB_UnlockAllChars(inst)
	CB_Print("Unlocking Characters.")
	local PlayerProfile = GLOBAL.PlayerProfile
	PlayerProfile._IsCharacterUnlocked = PlayerProfile.IsCharacterUnlocked
	PlayerProfile.IsCharacterUnlocked = function() return true end
end

-- Player Speed Modifier
local function CB_SpeedModifier()

	-- Do Nothing If Not Default Screen
	if not IsDefaultScreen() then return end
	
	CB_Print("Modifing Player Speed.")
	local LocoMotor = GetPlayer().components.locomotor
	LocoMotor._GetSpeedMultiplier = LocoMotor.GetSpeedMultiplier
	LocoMotor.GetSpeedMultiplier = function()
		local mult = LocoMotor:_GetSpeedMultiplier()
		-- CB_Print("Multiplier is "..mult.." and Modifier is "..CB_Speed_Modifier)
		return mult*CB_Speed_Modifier/10
	end
end

-- Map Fog Toggle Function
local function CB_MapFogToggle()

	-- Do Nothing If Not Default Screen
	if not IsDefaultScreen() then return end
	
	local Map = GLOBAL.TheSim:FindFirstEntityWithTag("minimap")
	if GetPlayer and Map then
		if CB_Enable_Fog then
			CB_Print("Map Fog Disabled")
			CB_Enable_Fog = false
			Map.MiniMap:EnableFogOfWar(false)
			
			-- Next Line Will Hides Whole Map Like Starting Point
			-- Map.MiniMap:ClearRevealedAreas(true)
		else
			CB_Print("Map Fog Enabled")
			CB_Enable_Fog = true
			Map.MiniMap:EnableFogOfWar(true)
		end
	end
end

-- God Mode Function
local function CB_GodMode()

	-- Do Nothing If Not Default Screen
	if not IsDefaultScreen() then return end
	
	-- God Mode Key Handler
	if GetPlayer() then
		if GetPlayer().components.health:IsInvincible() then
			CB_Print("Godmode Off!")
			CB_Enable_GM = false
			GetPlayer().components.health:SetInvincible(false)
			if CB_GM_Color==true then
				-- Remove Color Tint
				GetPlayer().AnimState:SetMultColour(1, 1, 1, 1)
				--GetPlayer().AnimState:SetAddColour(0, 0, 0 ,0)
			end
		else
			CB_Print("Godmode On!")
			CB_Enable_GM = true
			GetPlayer().components.health:SetInvincible(true)
			if CB_GM_Color==true then
				-- Add Color Tint
				GetPlayer().AnimState:SetMultColour(0, 1, 1, 1)
				--GetPlayer().AnimState:SetAddColour(0, 0, 0 ,0)
			end
		end
	end
end

-- Handle God Mode Disable Event Not Caused By Mod
local function CB_GMEventListener()

	-- Do Nothing If Not Default Screen
	if not IsDefaultScreen() then return end
	
	if not GetPlayer().components.health:IsInvincible() and CB_Enable_GM then
		GetPlayer().components.health:SetInvincible(true)
		if CB_GM_Color==true then
			GetPlayer().AnimState:SetMultColour(0, 1, 1, 1)
			--GetPlayer().AnimState:SetAddColour(0, 0, 0 ,0)
		end
	end
end

-- Set Health To Max
local function CB_Heal()

	-- Do Nothing If Not Default Screen
	if not IsDefaultScreen() then return end
	
	local Health=GetPlayer().components.health
	Health:SetPercent(1)
end

-- Set Hunger To Max
local function CB_Feed()

	-- Do Nothing If Not Default Screen
	if not IsDefaultScreen() then return end

	local Hunger=GetPlayer().components.hunger
	Hunger:SetPercent(1)
end

-- Set Sanity To Max
local function CB_Sane()

	-- Do Nothing If Not Default Screen
	if not IsDefaultScreen() then return end

	local Sanity=GetPlayer().components.sanity
	Sanity:SetPercent(1)
end


-- Burn/Freeze Attacker Based On Option
local function CB_DamageAttacker(inst, data)
	
	-- Do Nothing If Feature Disabled
	if not CB_Attacker_Damage_Type then return end
	
	-- Do Nothing If Not Default Screen
	if not IsDefaultScreen() then return end

	if data and data.attacker then
		local Attacker = data and data.attacker
		if CB_Attacker_Damage_Type == 1 then
			CB_Print("Freezing Attacker")
			if Attacker.components.freezable then
				Attacker.components.freezable:Freeze(2)
				Attacker.components.freezable:SpawnShatterFX()
			end
		else
			CB_Print("Burning Attacker.")
			if Attacker.components.burnable then
				Attacker.components.burnable:Ignite(2)
			end
		end
	end
end

-- Piper Mode
local function CB_PiperMode()

	-- Do Nothing if piper mode not set
	if CB_Piper_Mode < 1 and CB_Piper_Mode > 3 then return end

	-- Determine Piper key down or always
	if CB_Piper_Key ~= 0 then
		local key = ""
		if CB_Piper_Key == 1 then
			key = GLOBAL.KEY_CTRL
		elseif CB_Piper_Key == 2 then
			key = GLOBAL.KEY_SHIFT
		elseif CB_Piper_Key == 3 then
			key = GLOBAL.KEY_ALT
		end
		if not TheInput:IsKeyDown(key) then return end
	end
	
	-- CB_Print("Running Piper Mode.")
	local owner = GetPlayer()
	if owner and owner.components.leader then
		
		local follower = {}
		if CB_Piper_Mode == 1 then 
			owner.components.leader:RemoveFollowersByTag("spider")
			follower = {{'pig'}, {'werepig'}}
		elseif CB_Piper_Mode == 2 then
			follower = {'bunnyman'}
		elseif CB_Piper_Mode == 3 then
			owner.components.leader:RemoveFollowersByTag("pig")
			follower = {'spider'}
		end
			
		local x,y,z = owner.Transform:GetWorldPosition()
		local ents = TheSim:FindEntities(x,y,z, 15, follower)
		for k,v in pairs(ents) do
			if v.components.follower and not v.components.follower.leader  and not owner.components.leader:IsFollower(v) and owner.components.leader.numfollowers < 10 then
				owner.components.leader:AddFollower(v)
			end
		end

		for k,v in pairs(owner.components.leader.followers) do
			if k:HasTag("pig") and k.components.follower then
				k.components.follower:AddLoyaltyTime(15)
			end
		end
	end
end

--===============================================================================--

local function CB_Main(inst)
	
	CB_Print(CB_Speed_Modifier)
	-- Player Speed Modifier
	if CB_Speed_Modifier ~= 1 then CB_SpeedModifier() end
	
	-- Toggle Map Fog Handler
	TheInput:AddKeyDownHandler(CB_FOG_Key, CB_MapFogToggle)
	
	-- God Mode Handler
	TheInput:AddKeyDownHandler(CB_GM_Key, CB_GodMode)
	GetPlayer():ListenForEvent("invincibletoggle",CB_GMEventListener)
	
	-- Max Health Handler
	TheInput:AddKeyDownHandler(CB_Heal_Key, CB_Heal)
	-- Max Hunger Handler
	TheInput:AddKeyDownHandler(CB_Feed_Key, CB_Feed)
	-- Max Sanity Handler
	TheInput:AddKeyDownHandler(CB_Sane_Key, CB_Sane)
	
	-- Burn/Freeze Attacker Based On Option
	if CB_Attacker_Damage_Type then GetPlayer():ListenForEvent("attacked", CB_DamageAttacker) end
	
	-- Piper Mode
	if CB_Piper_Mode then inst:DoPeriodicTask(1, CB_PiperMode, 1) end
end

-- Disable Save Compression Handling
if not CB_Save_Encoding then CB_DisableSaveCompression() end
-- Unlock All Characters Handling
if CB_Unlock_All_Chars then AddGamePostInit(CB_UnlockAllChars) end

-- Fire Main
AddSimPostInit(CB_Main)