M = {}

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

--- Call a module's script with the appropriate configuration parameters
-- @param moduleName The module's name (NOT the script name, which is found in the module definition file)
-- @param project The project table, which includes critical information required to run the script on it
-- @param silent Toggles silent mode, i.e., all output is being muted
-- @return Boolean indicating whether the script ran without issues (true) or if it was skipped (false)
function M:CallScript(moduleName, project, silent)
	
	local _ -- Used for silent mode only
	local root = project.root
	local exclusions = project.exclusions
	
	_ = not silent and print("Module " .. moduleName .. " is running with path " .. tostring(root) .. " - excluding " .. #exclusions .. " files")
	local success = true
	
	--_ = not silent and print("Module is running in verbose mode")
	
	-- Read config for this module
	local configFile = "Config/" .. moduleName .. ".lua"
	local config = assert(loadfile(configFile), "Failed to load configuration file:	" .. configFile)()
	
	-- Read script config (definition and paths that don't usually change, and therefore aren't part of the user-focused config)
	local script = WBT.Modules[moduleName].script
	if script and script.file == "" then return end -- TODO. Temporary skipping of unfinished modules
	
	-- Pass everything to the module's script loader (which will call the script according to its settings)
	_ = not silent and print("Executing script loader for module: " .. moduleName)
	script:Run(project, config, silent)
	
	_ = not silent and print("Module " .. moduleName .. " finished running  (success = " .. tostring(success) .. ")")
	return success
	
end

return M