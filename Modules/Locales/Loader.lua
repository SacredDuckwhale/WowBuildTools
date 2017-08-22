-- TODO: This is just a prototype module
M = {}

M.name = "Locales"
M.libsFolder = "scrapewhale"
M.libsFile = "scrapewhale"

function M:Run(silent)
	
	print("Module " .. M.name .. " is running...")
	local success = true
	
	if not silent then
		print("Module is running in verbose mode")
	end
	
	print("Module " .. M.name .. " finished running - return value: " .. tostring(success))
	return success
	
end

return M