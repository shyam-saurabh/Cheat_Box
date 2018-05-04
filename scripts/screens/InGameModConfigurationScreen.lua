-- Get Required Files
local Text = require "widgets/text"
local Spinner = require "widgets/spinner"
local Widget = require "widgets/widget"

-- Get modconfigurationscreen class
local MCS = require "screens/modconfigurationscreen"

-- Rows And Columns in Configuration Page
local COLS = 2
local ROWS_PER_COL = 7

-- Table To Hold Options While Config Screen Open
local options = {}

local InGameModConfigurationScreen = Class(MCS, function(self,modname,_debug)

	-- Set Debug
	self.debug = _debug or false
	
	-- Validate Modname
	if type(modname) ~= "string" or KnownModIndex:GetModInfo(modname) == nil then
		assert(false,"No Valid Modname Provided. Cannot Proceed")
	end
	
	-- Call Parent class constructor
    self._base._ctor(self, modname)
	
	-- Get Current Settings
	local config = KnownModIndex:GetModConfigurationOptions(modname)
	if config
		and type(config) == "table"
		and #config[#config] > 0
	then
		self.config = config[#config]
	end
	
	-- Reset
	options = {}
	
	-- Get Options
	if self.config and type(self.config) == "table" then
		for i,v in ipairs(self.config) do
			-- Only show the option if it matches our format exactly
			if v.name and v.options and (v.saved ~= nil or v.default ~= nil) then 
				table.insert(options, {name = v.name, label = v.label, options = v.options, default = v.default, value = v.saved})
			end
		end
	end
	
	-- Set started with default settings falg
	self.started_default = self:IsDefaultSettings()
	
	-- Debug Print
	if self.debug then
		print(string.format("Preparing Ingame %s Mod Configuration Screen Window..",modname))
	end
	
	-- Handle Pause
	self:SetInGamePause(true)
	
	-- Event To Fired On settings Update 
	self.update_event = string.format("%s_InGameSettingsUpdate",modname)
	
	-- Remove Old background
	self.bg:Kill()
	self.bg = nil
	
	-- Add a overlay behind dialog
	self.overlay = self:AddChild(Image("images/global.xml", "square.tex"))
	self.overlay:SetVRegPoint(ANCHOR_MIDDLE)
	self.overlay:SetHRegPoint(ANCHOR_MIDDLE)
	self.overlay:SetVAnchor(ANCHOR_MIDDLE)
	self.overlay:SetHAnchor(ANCHOR_MIDDLE)
	self.overlay:SetScaleMode(SCALEMODE_FILLSCREEN)
	
	-- Change Tint Color Based On DLC Selection
	if IsDLCEnabled(REIGN_OF_GIANTS) and not IsDLCEnabled(CAPY_DLC) then
		self.overlay:SetTint(BGCOLOURS.PURPLE[1],BGCOLOURS.PURPLE[2],BGCOLOURS.PURPLE[3], 0.5)
	elseif IsDLCEnabled(CAPY_DLC) then
		self.overlay:SetTint(BGCOLOURS.TEAL[1],BGCOLOURS.TEAL[2],BGCOLOURS.TEAL[3], 0.5)
	else
		self.overlay:SetTint(BGCOLOURS.RED[1],BGCOLOURS.RED[2],BGCOLOURS.RED[3], 0.5)
	end
	
	-- Set overlay as dialog parent
	self.root.parent = self.overlay
	self.root.inst.entity:SetParent(self.overlay.inst.entity)
	
	-- Get Dialog Container (Optional)
	for _,v in pairs(self.root:GetChildren()) do
		if v.name == "Image"
			and v.atlas == "images/globalpanels.xml"
			and v.texture == "panel.tex"
		then self.bg = v end
	end

	-- Refresh Options
    self:RefreshOptions()
end)

---------------------------------
--[[ New Methods ]]
---------------------------------

-- Check If InGame
function InGameModConfigurationScreen:GetInGame()
	if TheFrontEnd
		and (TheFrontEnd:GetActiveScreen().name:find("HUD") ~= nil
		or TheFrontEnd:GetActiveScreen().name:find("PauseScreen") ~= nil)
	then return true end
	return false
end


-- Set Pause State
function InGameModConfigurationScreen:SetInGamePause(state)

	-- No Pause Handling If Not Ingame or already paused/running
	if not self:GetInGame() or state == IsPaused() then
		self.pause = false
		return
	end
	
	-- Set Self Pause
	self.pause = state
	
	-- Set Pause State
	SetPause(state,self.modname)
end

---------------------------------------------------
--[[ Overwritten Methods ]]
---------------------------------------------------

function InGameModConfigurationScreen:Apply()
	
	-- Save Configs
	if self.config
		and type(self.config) == "table"
		and #self.config > 0
	then
		for i,v in ipairs(options) do
			if v.value == v.default then
				self.config[i].saved = nil
			else
				self.config[i].saved = v.value
			end
		end
	end
	
	-- Close Config Screen
	self:MakeDirty(false)
	TheFrontEnd:PopScreen()
	
	-- Push Event That InGame Settings Have Been Updated
	local Player = GetPlayer()
	if Player and self.update_event then
		if self.debug then print("Firing Event: "..self.update_event) end
		Player:PushEvent(self.update_event, {})
	end
	
	-- Remove Pause
	self:SetInGamePause(false)
end

---------------------------------------------------
--[[ Extended Methods ]]
---------------------------------------------------

-- Cancel
function InGameModConfigurationScreen:Cancel()

	-- Call Parent Method 
	self._base.Cancel(self)
	
	-- Remove Pause
	self:SetInGamePause(false)
end

---------------------------------------------------
--[[ Exact Copy Methods ]]

-- These Methods Are Copied Because They Were
-- Accessing Parent Local Variable Which We Cannot
-- Change
-- They Are As Is
---------------------------------------------------


function InGameModConfigurationScreen:CollectSettings()
	local settings = nil
	for i,v in pairs(options) do
		if not settings then settings = {} end
		table.insert(settings, {name=v.name, label = v.label, options=v.options, default=v.default, saved=v.value})
	end
	return settings
end


function InGameModConfigurationScreen:ResetToDefaultValues()
	local function reset()
		for i,v in pairs(options) do
			options[i].value = options[i].default
		end
		self:RefreshOptions()
	end

	if not self:IsDefaultSettings() then
		self:ConfirmRevert(function() 
			TheFrontEnd:PopScreen()
			self:MakeDirty()
			reset()
		end)
	end
end

function InGameModConfigurationScreen:IsDefaultSettings()
	local alldefault = true
	for i,v in pairs(options) do
		if options[i].value ~= options[i].default then
			alldefault = false
			break
		end
	end
	return alldefault
end

function InGameModConfigurationScreen:Scroll(dir)
	if (dir > 0 and (self.option_offset + ROWS_PER_COL*2) < #options) or
		(dir < 0 and self.option_offset + dir >= 0) then
	
		self.option_offset = self.option_offset + dir
	end
	
	if self.option_offset > 0 then
		self.leftbutton:Show()
	else
		self.leftbutton:Hide()
	end
	
	if self.option_offset + ROWS_PER_COL*2 < #options then
		self.rightbutton:Show()
	else
		self.rightbutton:Hide()
	end
	
	self:RefreshOptions()
end

function InGameModConfigurationScreen:RefreshOptions()

	local focus = self:GetDeepestFocus()
	local old_column = focus and focus.column
	local old_idx = focus and focus.idx
	
	for k,v in pairs(self.optionwidgets) do
		v.root:Kill()
	end
	self.optionwidgets = {}

	self.left_spinners = {}
	self.right_spinners = {}

	for k = 1, ROWS_PER_COL*2 do
	
		local idx = self.option_offset+k
		
		if options[idx] then
			
			local spin_options = {} --{{text="default"..tostring(idx), data="default"},{text="2", data="2"}, }
			for k,v in ipairs(options[idx].options) do
				table.insert(spin_options, {text=v.description, data=v.data})
			end
			
			local opt = self.optionspanel:AddChild(Widget("option"))
			
			local spin_height = 50
			local w = 220
			local spinner = opt:AddChild(Spinner( spin_options, w, spin_height))
			spinner:SetTextColour(0,0,0,1)
			local default_value = options[idx].value
			if default_value == nil then default_value = options[idx].default end
			
			spinner.OnChanged =
				function( _, data )
					options[idx].value = data
					self:MakeDirty()
				end
				
			spinner:SetSelected(default_value)
			spinner:SetPosition(35,0,0 )

			local spacing = 55
			local label_width = 180
			
			local label = spinner:AddChild( Text( BUTTONFONT, 30, (options[idx].label or options[idx].name) or STRINGS.UI.MODSSCREEN.UNKNOWN_MOD_CONFIG_SETTING ) )
			label:SetPosition( -label_width/2 - 105, 0, 0 )
			label:SetRegionSize( label_width, 50 )
			label:SetHAlign( ANCHOR_MIDDLE )

			if k <= ROWS_PER_COL then
				opt:SetPosition(-155, (ROWS_PER_COL-1)*spacing*.5 - (k-1)*spacing - 10, 0)
				table.insert(self.left_spinners, spinner)
				spinner.column = "left"
				spinner.idx = #self.left_spinners
			else
				opt:SetPosition(265, (ROWS_PER_COL-1)*spacing*.5 - (k-1-ROWS_PER_COL)*spacing- 10, 0)
				table.insert(self.right_spinners, spinner)
				spinner.column = "right"
				spinner.idx = #self.right_spinners
			end
			
			table.insert(self.optionwidgets, {root = opt})
		end
	end

	--hook up all of the focus moves
	self:HookupFocusMoves()

	if old_column and old_idx then
		local list = old_column == "right" and self.right_spinners or self.left_spinners
		list[math.min(#list, old_idx)]:SetFocus()
	end
	
end

return InGameModConfigurationScreen