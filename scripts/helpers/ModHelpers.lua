-- Get ModName
local function GetOwnerModName(error_flag)

	-- Get source
	local source = debug.getinfo(1).source
	
	-- Exit if no source
	if type(source) ~= "string" then return end
	
	-- Set error flag default state 
	error_flag = error_flag or true
	
	-- Get Modname
	local modname = string.match( source:gsub("\\", "/"), ".-/\.\./mods/(.-)/.+\.lua$" )
	
	-- Return
	if modname and type(modname) == "string" then
		return modname
	elseif error_flag then
		assert("Failed to get modname")
	end
	
	return
end

-- Get Mod environment
local function GetOwnerModEnv(modname,error_flag)

	-- Exit If ModManager Not Missing
	if not ModManager or type(ModManager) ~= "table" then return end
	
	-- Get Modname
	if not modname then modname = GetOwnerModName(error_flag) end
	
	-- Set error flag default state 
	error_flag = error_flag or true
	
	local _env
	for _,v in ipairs(ModManager.mods) do _env = v.modname == modname and v.env; break end
	if _env and type(_env) == "table" then return _env end
	
	-- Return
	if error_flag then
		assert(string.format("Failed to get %s environment",modname))
	end
	
	return
end


return {
	GetOwnerModName = GetOwnerModName
	GetOwnerModEnv = GetOwnerModEnv
}