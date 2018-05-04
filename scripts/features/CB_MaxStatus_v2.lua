-- Load CB_DEBUG Value
local CB_DEBUG = rawget(_G, "CB_DEBUG") and _G.CB_DEBUG or false

-- Load Screen Helpers
local Screen = require "helpers/ScreenHelpers"

-- Max Status Handler
local CB_MaxStatus = function(inst)

	-- Exit If PlayerHud Missing
	if not (Screen.IsHudScreen() or Screen.IsPauseScreen()) then return end

	-- Set Instance If its missing
	if not inst
		or type(inst) ~= "table"
		or not inst:HasTag("player")
	then inst = GetPlayer() end

	-- Exit if HealthComponent missing
	if not (type(inst.components) == "table"
		and type(inst.components.health) == "table"
		and type(inst.components.hunger) == "table"
		and type(inst.components.sanity) == "table"
	) then return end
	
	-- Set id default value to all
	local id = TUNING.CHEAT_BOX.TYPE_MAXSTATUS
	
	-- Set Max Health
	if id == 0				-- All
		or id == 1			-- Health
		or id == 2			-- Health+Hunger
		or id == 6			-- Health+Sanity
	then
		if CB_DEBUG then print("Setting Player Health To Max") end
		inst.components.health:SetPercent(1)
	end
	
	-- Set Max Hunger
	if id == 0				-- All
		or id == 2			-- Hunger+Health
		or id == 3			-- Hunger
		or id == 4			-- Hunger+Sanity	
	then
		if CB_DEBUG then print("Setting Player Hunger To Max") end
		inst.components.hunger:SetPercent(1)
	end
	
	-- Set Max Sanity
	if id == 0				-- All
		or id == 4			-- Sanity+Hunger
		or id == 5			-- Sanity
		or id == 6			-- Sanity+Health
	then
		if CB_DEBUG then print("Setting Player Sanity To Max") end
		inst.components.sanity:SetPercent(1)
	end
	
	-- Say status
	inst.components.talker:Say(GetString(inst.prefab,"CB_MAX_STATUS"))
end

return CB_MaxStatus