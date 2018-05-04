-- Load CB_DEBUG Value
local CB_DEBUG = rawget(_G, "CB_DEBUG") and _G.CB_DEBUG or false

-- Load Screen Helpers
local Screen = require "helpers/ScreenHelpers"

-- Initilize Last Fog State
local last_fog_state

-- Map Fog Toggle Function
local CB_ToggleMapFog = function(inst)

	-- Get Fog State Current Value
	local fog_state = not TUNING.CHEAT_BOX.FLAG_REVEAL_MAP
	
	-- Nothing To Do
	if (last_fog_state == nil and fog_state) or fog_state == last_fog_state then return end
	
	-- Exit If PlayerHud Missing
	if not (Screen.IsHudScreen() or Screen.IsPauseScreen()) then return end
	
	--[[
	if TheFrontEnd
		and (TheFrontEnd:GetActiveScreen().name:find("HUD") ~= nil
			or TheFrontEnd:GetActiveScreen().name:find("PauseScreen") ~= nil
		)
	then return end
	]]
	
	-- Set MiniMap local variable
	local Map = TheSim:FindFirstEntityWithTag("minimap")
	
	-- Missing Map?
	if not Map then return end
	
	-- Set Mode Based On Fog Status
	if fog_state then
		if CB_DEBUG then print("Map Fog Enabled") end
	else
		if CB_DEBUG then print("Map Fog Disabled") end
	end

	-- Update Last Fog State
	last_fog_state = fog_state
	
	-- Say status
	local mode = fog_state and "INACTIVE" or "ACTIVE"
	inst.components.talker:Say(GetString(inst.prefab,"CB_MAP_FOG",mode))
	
	-- Toggle Map Fog
	Map.MiniMap:EnableFogOfWar(fog_state)
		
	-- Next Line Will Hides Whole Map Like Starting Point
	-- Map.MiniMap:ClearRevealedAreas(fog_state)
end

return CB_ToggleMapFog