-- Make Sure Its Loaded With modimport
if pcall and pcall(function() return type(_G) == "table" end) then error("Use modimport to load File") end

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

-- Get InGameModConfigurationScreen Class
local IGMCS = require "screens/InGameModConfigurationScreen"

-- Pause Menu Hook
--[[
	self.menu.offset == width of a single button
	self.menu:GetNumberOfItems() = Total Items In menu
	and it seems 65 is height of single button
	x and y are set at end of menu on bottom right
	also whole background is ment for 4x4 buttons 
	
	eg:
	so if we want to move bottom right above the last item then
	x = -self.menu.offset
	y = 65
	
	and if we want to move button at below the 1st item on left then
	x = -self.menu.offset*self.menu:GetNumberOfItems()
	y = -65
]]

local AddToPauseScreen = function(self)
	
	local button = {
		text=STRINGS.UI.PAUSEMENU.CB_BUTTON,
		cb=function()GLOBAL.TheFrontEnd:PushScreen(IGMCS(modname,CB_DEBUG))end
	}
	
	local offset = GLOBAL.Vector3(0,0,0)
	offset.x = -(self.menu.offset*self.menu:GetNumberOfItems())
	offset.y = 65*3
	self.menu:AddItem(button.text, button.cb, offset)
end

-- Hook Pause Screen Creation
AddClassPostConstruct("screens/pausescreen", AddToPauseScreen)

-- Set Hotkey For Settings Page
local KEYBOARDTOGGLEKEY = GetModConfigData("INGAME_SETTINGS_KEY")
if KEYBOARDTOGGLEKEY ~= nil then

	if type(KEYBOARDTOGGLEKEY) == "number" then KEYBOARDTOGGLEKEY = KEYBOARDTOGGLEKEY:char() end
	KEYBOARDTOGGLEKEY = KEYBOARDTOGGLEKEY:lower():byte()

	-- Add Key Down Handler For InGame Menu
	AddSimPostInit(function()
		GLOBAL.TheInput:AddKeyDownHandler(KEYBOARDTOGGLEKEY,function()
			GLOBAL.TheFrontEnd:PushScreen(IGMCS(modname,CB_DEBUG))
		end)
	end)
end