function d_decodedata(path, skipread, suffix, datacb)
	print("DECODING",path)
	suffix = suffix or "_decoded"
	TheSim:GetPersistentString(path, function(load_success, str)
		if load_success then
			print("LOADED...")
			if not skipread then
				local success, savedata = RunInSandbox(str)
				if datacb ~= nil then
					datacb(savedata)
				end
				str = DataDumper(savedata, nil, false)
			end
			TheSim:SetPersistentString(path..suffix, str, false, function()
				print("SAVED!")
			end)
		else
			print("ERROR LOADING FILE! (wrong path?)")
		end
	end)
end

function d_allsavenames(suffix)
	suffix = suffix or ""
	local filenames = {
		"saveindex"..suffix,
		"profile"..suffix,
		"modindex"..suffix,
	}
	for i,type in ipairs({"survival", "shipwrecked", "adventure", "cave", "volcano"}) do
		if type == "cave" then
			for num=1,10 do
				for level=1,2 do
					for slot=1,5 do
						table.insert(filenames, string.format("%s_%d_%d_%d%s", type, num, level, slot, suffix))
					end
				end
			end
		else
			for slot=1,5 do
				table.insert(filenames, string.format("%s_%d%s", type, slot, suffix))
			end
		end
	end
	return filenames
end

function d_decodealldata(suffix, prefix)
	print("*******************************")
	print("ABOUT TO DECODE")
	prefix = prefix or ""
	for i,file in ipairs(d_allsavenames(suffix)) do
		d_decodedata(prefix..file, true)
	end
	print("Done decoding")
	print("*******************************")
end