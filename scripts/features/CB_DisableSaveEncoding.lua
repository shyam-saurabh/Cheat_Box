-- Load CB_DEBUG Value
local CB_DEBUG = rawget(_G, "CB_DEBUG") and _G.CB_DEBUG or false

-- Disable Save Game Encoding
local SaveEncoding = function()
	
	-- Set Save Encoding
	ENCODE_SAVES = TUNING.CHEAT_BOX.FLAG_ENCODE_SAVE
	
	-- Print Debug Message
	if CB_DEBUG then
		if ENCODE_SAVES then
			print("Default Save Encoding State.")
		else
			print("Save Encoding Disabled.")
		end
	end
end

return SaveEncoding