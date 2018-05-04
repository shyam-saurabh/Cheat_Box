-- Load CB_DEBUG Value
local CB_DEBUG = rawget(_G, "CB_DEBUG") and _G.CB_DEBUG or false

-- Invincible Mode
-- 1=Health, 2=Health+Hunger, 3=Health+Hunger+Sanity
local GM_MODE = 3

-- Set Default State
local gm_forcefield = false

-- Last State
local gm_laststate = false

-- Invincible Color Codes
local gm_colorvalue = {
	inactive = {1, 1, 1, 1},
	active = {0.5, 1, 0.5, 1},
}

-- Handle Health
local CB_GMHealth_DoDelta = function(self, amount, overtime, cause, ignore_invincible)

	-- Handle invincible
	if amount < 0 and TUNING.CHEAT_BOX.FLAG_INVINCIBLE then
		if CB_DEBUG then print(string.format("Damage Amount: %s",tostring(amount))) end
		amount = 0
	end
	
	-- Call Original Function
	self:_DoDelta(amount, overtime, cause, ignore_invincible)
end

-- Handle Health
local CB_GMHealth_SetVal = function(self, val, cause)

	-- Handle invincible
	if val < self.currenthealth and TUNING.CHEAT_BOX.FLAG_INVINCIBLE then
		if CB_DEBUG then print(string.format("Damage val: %s",tostring(val))) end
		val = self.currenthealth
	end
	
	-- Call Original Function
	self:_SetVal(val, cause)
end

-- Handle Hunger
local CB_GMHunger_DoDelta = function(self, delta, overtime, ignore_invincible)

	-- Handle invincible
	if delta < 0 and TUNING.CHEAT_BOX.FLAG_INVINCIBLE then
		if CB_DEBUG then print(string.format("Hunger Damage delta: %s",tostring(delta))) end
		delta = 0
	end
	
	-- Call Original Function
	self:_DoDelta(delta, overtime, ignore_invincible)
end

-- Handle Sanity
local CB_GMSanity_DoDelta = function(self, delta, overtime)

	-- Dont do anything if invincible
	if delta < 0 and TUNING.CHEAT_BOX.FLAG_INVINCIBLE then
		if CB_DEBUG then print(string.format("Sanity Damage delta: %s",tostring(delta))) end
		delta = 0
	end
	
	-- Call Original Function
	self:_DoDelta(delta, overtime)
end

-- Get Attacked
local function CB_GMCombat_GetAttacked(self, attacker, damage, weapon)
	-- Neutralize damage if we are invincible
	if damage > 0 and TUNING.CHEAT_BOX.FLAG_INVINCIBLE then
		damage = 0
	end
	
	self:_GetAttacked(attacker, damage, weapon)
end

-- Add Force Field
local function CB_GMForceField(inst, data)

	-- Do Nothing If force field already active
	if gm_forcefield then return end
	
	-- If Current Armour Already has a forcefield property dont add it
	if inst.components.inventory
		and inst.components.inventory:ArmorHasTag("forcefield")
	then return end

	-- Create Force field
	local fx = SpawnPrefab("forcefieldfx")
	fx.entity:SetParent(inst.entity)
	fx.Transform:SetPosition(0, 0.2, 0)
	-- fx.AnimState:SetMultColour(unpack(gm_colorvalue.active))
	fx.AnimState:SetAddColour(unpack(gm_colorvalue.active))
	
	local fx_hitanim = function()
		fx.AnimState:PlayAnimation("hit")
		fx.AnimState:PushAnimation("idle_loop")
	end
	fx:ListenForEvent("blocked", fx_hitanim, inst)
	gm_forcefield = true
	
	-- Add Auto Remover For Force Field
	inst:DoTaskInTime(5, function()
		fx:RemoveEventCallback("blocked", fx_hitanim, inst)
		fx.kill_fx(fx)
		gm_forcefield = false
	end)
end

-- God Mode Update Function
local CB_GodMode_Update = function(inst)

	-- Check Last State
	if gm_laststate ~= TUNING.CHEAT_BOX.FLAG_INVINCIBLE then
	
		local mode = "INACTIVE"
		
		if TUNING.CHEAT_BOX.FLAG_INVINCIBLE then
			mode = "ACTIVE"
			inst:ListenForEvent("blocked",CB_GMForceField)
		else
			inst:RemoveEventCallback("blocked",CB_GMForceField)
		end
		
		-- Say status
		inst.components.talker:Say(GetString(inst.prefab,"CB_INVINCIBLE",mode))
	end
	
	-- Add Color Tint To Player
	if TUNING.CHEAT_BOX.TINT_INVINCIBLE and TUNING.CHEAT_BOX.FLAG_INVINCIBLE then
		inst.AnimState:SetMultColour(unpack(gm_colorvalue.active))
		-- inst.AnimState:SetAddColour(unpack(gm_colorvalue.active))
	else
		inst.AnimState:SetMultColour(unpack(gm_colorvalue.inactive))
		-- inst.AnimState:SetAddColour(unpack(gm_colorvalue.inactive))
	end
	
	-- Set Last State
	gm_laststate = TUNING.CHEAT_BOX.FLAG_INVINCIBLE
end

-- God Mode Initilize Function
local CB_GodMode = function(inst)
	
	-- Set Instance If its missing
	if not inst
		or type(inst) ~= "table"
		or not inst:HasTag("player")
	then inst = GetPlayer() end
	
	-- Exit if health missing
	if type(inst.components) ~= "table"
		or type(inst.components.health) ~= "table"
		or type(inst.components.hunger) ~= "table"
		or type(inst.components.sanity) ~= "table"
		or type(inst.components.combat) ~= "table"
	then return end
	
	-- Create Backup Functions
	inst.components.health._DoDelta = inst.components.health.DoDelta
	inst.components.health._SetVal = inst.components.health.SetVal
	
	inst.components.hunger._DoDelta = inst.components.hunger.DoDelta
	inst.components.sanity._DoDelta = inst.components.sanity.DoDelta
	
	inst.components.combat._GetAttacked = inst.components.combat.GetAttacked
	
	-- Install Moded Functions
	inst.components.health.DoDelta = CB_GMHealth_DoDelta
	inst.components.health.SetVal = CB_GMHealth_SetVal
	
	inst.components.hunger.DoDelta = CB_GMHunger_DoDelta
	inst.components.sanity.DoDelta = CB_GMSanity_DoDelta
	
	inst.components.combat.GetAttacked = CB_GMCombat_GetAttacked
end

return {
	Install = CB_GodMode,
	Update = CB_GodMode_Update,
}