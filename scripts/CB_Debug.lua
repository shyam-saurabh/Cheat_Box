-- Make Sure Its Loaded With modimport
if pcall and pcall(function() return type(_G) == "table" end) then error("Use modimport to load File") end

local require = GLOBAL.require
local rawget = GLOBAL.rawget

local KnownModIndex = GLOBAL.KnownModIndex

-- Exit If Already Defined
if rawget(GLOBAL, "CB_DEBUG") then return end

-- Enable/Disable Debugging Based on ModForceEnabled or ModInitPrint
if not KnownModIndex or not KnownModIndex.modsettings then return end

-- Set Debug based on IsModForceEnabled or IsModInitPrintEnabled
-- NOTE: ForceEnableMod() in modsettings.lua is case sensitve and it is mod directoryname
if not KnownModIndex:IsModInitPrintEnabled() and not KnownModIndex:IsModForceEnabled(modname) then return end

-- Set Global CB_DEBUG
GLOBAL.global("CB_DEBUG")
GLOBAL.CB_DEBUG = true

-- Set Debug Variable In Environment
env.CB_DEBUG = GLOBAL.CB_DEBUG

-- Activate InGame DebugKeys
GLOBAL.CHEATS_ENABLED = true
require 'debugkeys'

-- Load Debug Tools
require "debugtools"
env.dumptable = GLOBAL.dumptable

-- Auto Hide Console Log On Close
local Mod_BC = KnownModIndex:GetModActualName("Better Console")
if not KnownModIndex:IsModEnabled(Mod_BC) and not KnownModIndex:IsModForceEnabled(Mod_BC) then
	
	print("Adding Console AutoHide")
	
	AddClassPostConstruct( "screens/consolescreen", function(self)
	
		-- Set Local Frontend
		local TheFrontEnd = GLOBAL.TheFrontEnd
	
		-- Hide Console Log On Exit
		TheFrontEnd.consoletext.closeonexit = TheFrontEnd.consoletext.closeonexit == nil and true
		-- TheFrontEnd.consoletext.closeonrun = true
		
		self._Close = self.Close
		self.Close = function(self)
			self:_Close()
			if TheFrontEnd.consoletext.closeonexit then
				TheFrontEnd:HideConsoleLog()
				TheFrontEnd.consoletext.closeonexit = nil
			end
		end
	end)
end

-- If DebugKeys Loaded No need to load our slipstream version of debugkeys
if rawget(GLOBAL, "AddGameDebugKey") and type(GLOBAL.AddGameDebugKey) == "function" then return end

print("Adding Console Commands")

-- Load Console Commands
require "consolecommands"

-- Reload Scripts
AddGamePostInit(function()
	
	local TheInput = GLOBAL.TheInput
	local StartNextInstance = GLOBAL.StartNextInstance
	local SaveGameIndex = GLOBAL.SaveGameIndex
	
	TheInput:AddKeyDownHandler(GLOBAL.KEY_R,function()
		if TheInput:IsKeyDown(GLOBAL.KEY_CTRL) then
			if TheInput:IsKeyDown(GLOBAL.KEY_SHIFT) then
				StartNextInstance({reset_action = GLOBAL.RESET_ACTION.LOAD_SLOT, save_slot=SaveGameIndex:GetCurrentSaveSlot()})
			elseif TheInput:IsKeyDown(GLOBAL.KEY_ALT) then
				SaveGameIndex:DeleteSlot(SaveGameIndex:GetCurrentSaveSlot(), function()
					StartNextInstance({reset_action = GLOBAL.RESET_ACTION.LOAD_SLOT, save_slot=SaveGameIndex:GetCurrentSaveSlot()})
				end, true)
			else
				StartNextInstance()
			end
			return true
		end
	end)
end)