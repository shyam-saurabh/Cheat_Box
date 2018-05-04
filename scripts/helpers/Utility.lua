-- Convers Hex Color Codes To RGB
local function hex2rgb (hex)
	local hex = hex:gsub("#","")
	local R,G,B
	
	if hex:len() == 3 then
		R = (tonumber("0x"..hex:sub(1,1))*17)/255
		G = (tonumber("0x"..hex:sub(2,2))*17)/255
		B = (tonumber("0x"..hex:sub(3,3))*17)/255
	else
		R = tonumber("0x"..hex:sub(1,2))/255
		G = tonumber("0x"..hex:sub(3,4))/255
		B = tonumber("0x"..hex:sub(5,6))/255
	end
	
	return R,G,B
end

return {
	hex2rgb = hex2rgb
}