-- Load CB_DEBUG Value
local CB_DEBUG = rawget(_G, "CB_DEBUG") and _G.CB_DEBUG or false

-- Set CB Speed Multiplier Value
local last_SpeedMul = nil

-- Player Speed Modifier
local CB_PlayerSpeedModifier = function(inst)
	
	-- Set Instance If its missing
	if not inst
		or type(inst) ~= "table"
		or not inst:HasTag("player")
	then inst = GetPlayer() end

	-- Exit if GetSpeedMultiplier missing
	if not (type(inst.components) == "table"
		and type(inst.components.locomotor) == "table"
		and type(inst.components.locomotor.GetSpeedMultiplier) == "function"
	) then return end
	
	-- Set locomotor local variable
	local LocoMotor = inst.components.locomotor
	
	-- Backup Original GetSpeedMultiplier Function
	LocoMotor._GetSpeedMultiplier = LocoMotor.GetSpeedMultiplier
	
	-- Set Moded GetSpeedMultiplier Function
	LocoMotor.GetSpeedMultiplier = function(self)
		
		-- Get Player Current speed multiplier
		local mult = self:_GetSpeedMultiplier()
		
		-- Get Speed Multiplier variable
		local SpeedMul = TUNING.CHEAT_BOX.MULTIPLIER_SPEED
		
		-- Get Multiplier
		if not SpeedMul or SpeedMul == 1 then return mult end
		
		-- Say things if we are on increased speed
		if SpeedMul ~= last_SpeedMul then
		
			-- Say status
			local player = GetPlayer()
			local mode = SpeedMul > 1 and "FAST" or "SLOW" 
			player.components.talker:Say(GetString(player.prefab,"CB_SPEED_BOOST",mode))
			last_SpeedMul = SpeedMul
			
			-- Print Debug Message
			if CB_DEBUG then
				print("Player Original speed: "..mult.." and Modified Speed is: ".. mult*SpeedMul)
			end
		end
		
		-- Change Player Speed Multiplier
		return mult*SpeedMul
	end
end

return CB_PlayerSpeedModifier