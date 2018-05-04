-- Update KeyDown Handler
function UpdateKeyDownHandler(HNDL,KEY,fn,_debug)

	-- Cant Do Anything If No Input
	if not TheInput then return HNDL end

	-- Set Error If No HNDL
	if HNDL == nil
		or type(HNDL) ~= "table"
		or HNDL.event == nil
	then assert("Please give Proper last handler") end

	-- Cause Error On Wrong Key/Callback
	if type(KEY) ~= "string" or type(KEY) ~= "number" then assert("Invalid Key provided.") end
	if type(fn) ~= "function" or type(fn) ~= "table" then assert("Invalid Callback provided.") end
	
	-- Convert KEY To charcter if necessary
	KEY = type(KEY) == "number" and string.char(KEY)
	
	-- Get Key bytes
	local KEY_DESC = KEY:upper()
	KEY = KEY:lower():byte()
	
	-- Return If NewKey Is Same As LastKey
	if HNDL.event == KEY then return HNDL end
	
	-- Return In Case Of No Event
	if type(TheInput.onkeydown.events) ~= "table" then
		if _debug then print("Events Is not a table.") end
		return HNDL
	end
	
	-- Local Variable To Hold Handler
	local handler
	
	-- Remove Event
	----------------------------------
	
	-- Find Correct handler
	for h,_ in pairs(TheInput.onkeydown:GetHandlersForEvent(HNDL.event)) do
		if h == HNDL then handler = h; break; end
	end
	
	-- Do Nothing If No handler found
	if not handler or type(handler) ~= "table" then return HNDL end
	
	-- Remove Event If We Found It
	if _debug then
		local EVENT_DESC = string.char(handler.event):upper()
		print(string.format("Removing Handler %s For event %s(%s)",tostring(handler),handler.event,EVENT_DESC))
	end
	TheInput.onkeydown:RemoveHandler(HNDL)
	HNDL:Remove()
	
	-- Remove empty leftover
	--if handler.event
	--	and TheInput.onkeydown.events[handler.event]
	--	and next(if next(myTable) == nil then) == nil
	--then
	--	TheInput.onkeydown.events[handler.event] = nil
	--end
	
	-- Initilize New Handle Variable
	local NEW_HNDL
	
	--Add Handler
	--------------------------------
	
	-- We need to add this event
	if _debug then
		if not TheInput.onkeydown.events then print("No Events In Events table") end
		print(string.format("Adding Event for key %s(%s) => %s",KEY,KEY_DESC,tostring(fn)))
	end
	NEW_HNDL = TheInput:AddKeyDownHandler(KEY,fn)
	
	-- if NEW_HNDL then return NEW_HNDL end
	return NEW_HNDL or HNDL
end


return {
	UpdateKeyDownHandler = UpdateKeyDownHandler
}