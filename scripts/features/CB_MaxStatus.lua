local GetPlayer = GLOBAL.GetPlayer
local TheInput = GLOBAL.TheInput
local TheFrontEnd = GLOBAL.TheFrontEnd

-- Initilize Keys/Handles And Other Settings Variables
local KEY_maxstatus, HNDL_maxstatus
local TYPE_maxstatus

-- Updated Max Status Settings
local CB_MaxStatus_Update_Settings = function()
	TYPE_maxstatus = GetModConfigData("CB_Max_Status_Type")
	KEY_maxstatus = GetModConfigData("CB_Max_Status_Key"):lower():byte()
end

-- Max Status Handler
local CB_MaxStatus = function(inst)

	-- Exit If PlayerHud Missing
	if not TheFrontEnd:IsHudScreen() then return end

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
	local id = TYPE_maxstatus
	
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

-- After Player Intialized
AddSimPostInit(function(inst)
	CB_MaxStatus_Update_Settings()
	HNDL_maxstatus = TheInput:AddKeyDownHandler(KEY_maxstatus,CB_MaxStatus)
end)

-- Add Update Settings
AddSimPostInit(function(inst)
	inst:ListenForEvent(modname.."_InGameSettingsUpdate",function(inst)
		CB_MaxStatus_Update_Settings()
		HNDL_maxstatus = TheInput:UpdateKeyDownHandler(HNDL_maxstatus, KEY_maxstatus, CB_MaxStatus)
	end)
end)