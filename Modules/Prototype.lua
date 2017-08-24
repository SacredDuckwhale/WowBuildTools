M = {}


function M:RunScript(scriptName, ...) -- Every script will do something different with those parameters

	
	

end

--- Lookup a module's name and return the actual script library/API that is to be used with it
-- @param moduleName
-- @return Script name if one exists; "" (empty string) otherwise
local function GetScriptName(moduleName)

	local defaultValue = ""

	local scripts = {
		["ChangeLogs"] = "logpickr",
		["CodeStandards"] = "",
		["CurseForge"] = "",
		["Documentation"] = "ldoc",
		["Locales"] = "scrapewhale",
		["StaticAnalysis"] = "luacheck",
		["UnitTests"] = "luaunit",
		["Versioning"] = "",
}

	return scripts[moduleName] or defaultValue

end


function M:Run(moduleName, project, silent)
	
	local _ -- Used for silent mode only
	local root = project.root
	local exclusions = project.exclusions
	
	_ = not silent and print("Module " .. moduleName .. " is running with path " .. tostring(root) .. " - excluding " .. #exclusions .. " files")
	local success = true
	
	_ = not silent and print("Module is running in verbose mode")
	
	-- Read config for this module
	local configFile = "Config/" .. moduleName .. ".lua"
	local config = assert(loadfile(configFile), "Failed to load configuration file:	" .. configFile)()
	
	-- Read script config (definition and paths that don't usually change, and therefore aren't part of the user-focused config)
	local script = WBT.Modules[moduleName].script
	if script and script.file == "" then return end -- TODO. Temporary skipping of unfinished modules
	
	-- Read script that will be used to build the addon according to the config
	local scriptFile = "Libs\\" .. script.folder .. "\\" .. script.file .. "." .. script.extension
	local Script = assert(loadfile(scriptFile), "Failed to load script file: " .. scriptFile)()
	
	-- Run script with this configuration
	_ = not silent and print("Attempting to run script: " .. scriptFile)
	Script:Run(config)
	
	_ = not silent and print("Module " .. moduleName .. " finished running - successful = " .. tostring(success))
	return success
	
end

return M