-- Last Screen We notified user about
local LAST_SCREEN

-- Is Screen Name Matches To Given Screen Name
local function IsScreen(name,_debug)

	-- Exit If No frontend
	if not TheFrontEnd then return false end

	-- Exit If No Name
	if not name then return false end

	-- Get Current Screen
	local screen = TheFrontEnd:GetActiveScreen()
	
	-- Exit if ActiveScreen Missing
	if type(screen) ~= "table" then return false end
	
	-- Print Helper
	if _debug and LAST_SCREEN ~= screen.name then print(string.format("Screen Is %s",screen.name)) end
	
	-- Set Last Screen
	LAST_SCREEN = screen.name
	
	return screen.name:find(name) ~= nil
end


-- Is HUD Present On Screen
local function IsHudScreen(_debug)

	-- Return false if no PlayerHUD
	if not IsScreen("HUD",_debug) then return false end
	
	-- Get Player
	local Player = GetPlayer and GetPlayer()
	
	-- Return If Player Not Valid
	if not Player then return false end

	-- Return false if Crafting/Inventory window open on controller
	if GetPlayer().HUD:IsControllerCraftingOpen()
		or GetPlayer().HUD:IsControllerInventoryOpen()
	then return false end

	return true
end

-- Is It Score Board Screen
local function IsScoreboardScreen(_debug) return IsScreen("PlayerStatusScreen",_debug) end

-- Is It Console Screen
local function IsConsoleScreen(_debug) return IsScreen("ConsoleScreen",_debug) end

-- Is It Pause Screen
local function IsPauseScreen(_debug) return IsScreen("PauseScreen",_debug) end

return {
	IsScreen = IsScreen,
	IsHudScreen = IsHudScreen,
	IsScoreboardScreen = IsScoreboardScreen,
	IsConsoleScreen = IsConsoleScreen,
	IsPauseScreen = IsPauseScreen,
}