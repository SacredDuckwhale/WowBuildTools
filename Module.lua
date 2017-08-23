-- TODO: This is just a prototype module
M = {}

-- TODO: This should be in the module config, while the rest should be moved to the main directory and generalised to call all scripts (avoid clutter with folders and duplicate code)
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
	local configFile = "Modules/" .. M.name .. "/Config.lua"
	local config = assert(loadfile(configFile))
	config()
	
	-- Read script that will be used to build the addon according to the config
	local script = "Libs\\" .. M.libsFolder .. "\\" .. M.libsFile .. ".lua"
	print("Attempting to run script: " .. script)
	local Script = assert(loadfile(script), "Failed to load script " .. script)
	local Module = Script()	
--dump(Module)
	-- Run script with this configuration
	Module:Run(config)
	
	print("Module " .. M.name .. " finished running - return value: " .. tostring(success))
	return success
	
end

return M