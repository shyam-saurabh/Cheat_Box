-- Load CB_DEBUG Value
local CB_DEBUG = rawget(_G, "CB_DEBUG") and _G.CB_DEBUG or false

-- Load Screen Helpers
local Screen = require "helpers/ScreenHelpers"

-- Do damage Of damage_type
local function CB_DoDamage(inst,delta)

	-- Do Nothing If Type Damage Off
	if not TUNING.CHEAT_BOX.TYPE_DAMAGE
		or TUNING.CHEAT_BOX.TYPE_DAMAGE <= 0
	then return end

	-- Other Values
	-- sleeper,combat,locomoter,poisonable,burnable,freezable,health
	
	-- Set Doer Type
	local doer_type = "Target"
	
	-- Get Damage Value
	local damage
	if type(delta) == "number" then
		damage = delta
	elseif type(delta) == "table"
		and delta.components
		and delta.components.weapon
		and delta.components.weapon.damage
	then
		doer_type = "Attacker"
		damage = delta.components.weapon.damage
	else return end
	
	-- Set Status
	local freezable = inst.components.freezable and inst.components.freezable or nil
	local burnable = inst.components.burnable and inst.components.burnable or nil
	local sleeper = inst.components.sleeper and inst.components.sleeper or nil
	local health = inst.components.health and inst.components.health or nil
	
	-- Get Damage Type Value
	local damage_type = TUNING.CHEAT_BOX.TYPE_DAMAGE
	
	-- Say status
	local mode = {"FREEZE","BURN","SLEEP","DEATH"}
	
	local Player = GetPlayer()
	Player.components.talker:Say(GetString(Player.prefab,"CB_DAMAGE_TYPE",mode[damage_type]))
	
	-- Damage Attacker
	if damage_type == 1 and freezable and not freezable:IsFrozen() then
		if CB_DEBUG then print(string.format("Freezing %s",doer_type)) end
		freezable:AddColdness((freezable.resistance+5),5)
		freezable:SpawnShatterFX()
	elseif damage_type == 2 and burnable and not burnable:IsBurning() then
		if CB_DEBUG then print(string.format("Burning %s",doer_type)) end
		burnable:Ignite(true)
	elseif damage_type == 3 and sleeper and not (sleeper:IsAsleep() or sleeper:IsHibernating()) then
		if CB_DEBUG then print(string.format("Putting %s to sleep",doer_type)) end
		sleeper:AddSleepiness((sleeper.resistance+5),5)
	elseif damage_type == 4 and health and not health:IsDead() then
		if CB_DEBUG then print(string.format("Killing %s",doer_type)) end
		health:Kill()
	end
end


-- Burn/Freeze Attacker Based On Option
local function CB_ReturnDamage(inst, data)
	
	-- Do Nothing If Feature Disabled
	if not TUNING.CHEAT_BOX.FLAG_DAMAGE_REFLECT then return end
	
	-- Exit If PlayerHud Missing
	if not Screen.IsHudScreen() then return end
	
	-- Exit if Attacker Instance Missing
	if type(data) ~= "table"
		or type(data.attacker) ~= "table"
		or type(data.attacker.components) ~= "table"
	then return end
	
	-- Exit If Damage Missing
	if not (data.damage and data.damage > 0) then return end
	
	-- Damage Attacker 10% of damage taken
	data.attacker.components.health:DoDelta(-(data.damage/10))
	
	-- Lets Do Damage If Not Dead
	if not data.attacker.components.health:IsDead() then
		CB_DoDamage(data.attacker,data.damage)
	end
end

-- Burn/Freeze Target Based On Option
local CB_AttackDamage = function(inst, data)

	-- Do Nothing If Feature Disabled
	if not TUNING.CHEAT_BOX.TYPE_DAMAGE then return end
	
	-- Exit If PlayerHud Missing
	if not Screen.IsHudScreen() then return end
	
	-- Exit if Target Instance Missing
	if type(data) ~= "table"
		or type(data.target) ~= "table"
		or type(data.target.components) ~= "table"
	then return end
	
	-- Exit If Weapon Missing
	if not (data.weapon
		and data.weapon.components
		and data.weapon.components.weapon
		and data.weapon.components.weapon.damage
	) then return end
	
	-- Lets Do Damage If Not Dead
	if not data.target.components.health:IsDead() then
		CB_DoDamage(data.target,data.weapon)
	end
end

return {
	ReturnDamage = CB_ReturnDamage,
	AttackDamage = CB_AttackDamage,
}