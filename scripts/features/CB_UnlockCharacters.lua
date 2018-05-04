-- Load CB_DEBUG Value
local CB_DEBUG = rawget(_G, "CB_DEBUG") and _G.CB_DEBUG or false

-- Record last state of CB_UNLOCK_CHARS
local last_state

-- Unlock Characters
local UnlockChars = function()
	
	-- Exit if IsCharacterUnlocked function missing
	if not (type(PlayerProfile) == "table"
		and type(PlayerProfile.IsCharacterUnlocked) == "function"
	) then return end
	
	-- Backup IsCharacterUnlocked Function
	PlayerProfile._IsCharacterUnlocked = PlayerProfile.IsCharacterUnlocked
	
	-- Moded IsCharacterUnlocked Function
	PlayerProfile.IsCharacterUnlocked = function(self,character)
		
		-- Print Debug Message
		if CB_DEBUG
			and TUNING.CHEAT_BOX.FLAG_UNLOCK_CHARS
			and TUNING.CHEAT_BOX.FLAG_UNLOCK_CHARS ~= last_state
		then
			print("Characters Unlocked")
			last_state = TUNING.CHEAT_BOX.FLAG_UNLOCK_CHARS
		end
		
		-- Return Character Unlocked Status
		return TUNING.CHEAT_BOX.FLAG_UNLOCK_CHARS or self:_IsCharacterUnlocked(character)
	end
end

return UnlockChars