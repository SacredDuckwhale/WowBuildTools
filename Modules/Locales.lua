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
	
	-- Read config for this module
	local configFile = "Config/" .. M.name .. ".lua"
	local config = assert(dofile(configFile), "Failed to load configuration file: " .. configFile)
	
	-- Read script that will be used to build the addon according to the config
	local script = "Libs\\" .. M.libsFolder .. "\\" .. M.libsFile .. ".lua"
	print("Attempting to run script: " .. script)
	local Script = assert(dofile(script), "Failed to load script file: " .. script)
--dump(Module)
	-- Run script with this configuration
	Script:Run(config)
	
	print("Module " .. M.name .. " finished running - successful = " .. tostring(success))
	return success
	
end

return M