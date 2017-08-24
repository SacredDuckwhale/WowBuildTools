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
--	local script = assert(dofile("Modules/" .. moduleName .. ".lua"), "Failed to open module definition")
	local script = WBT.Modules[moduleName].script

	-- Read script that will be used to build the addon according to the config
	local scriptFile = "Libs\\" .. script.folder .. "\\" .. script.file .. "." .. script.extension
	local Script = assert(loadfile(scriptFile), "Failed to load script file: " .. scriptFile)()
	
	-- Run script with this configuration
	_ = not silent and print("Attempting to run script: " .. script)
	Script:Run(config)
	
	_ = not silent and print("Module " .. M.name .. " finished running - successful = " .. tostring(success))
	return success
	
end

return M



			-- if not Module or type(Module) ~= "table" or not Module.Run or not type(Module.Run) == "function" then -- Module is invalid (failed to load properly?)

				-- print("Failed to run module: " .. enabledModule.name .. " - skipping it...")
				-- enabledModule.ranSuccessfully = false

			-- else -- Run module for this project
			
				-- print("\nRunning module: " .. tostring(enabledModule.name) .. "...")
				-- -- TODO: Return whether or not it was successful (a successful build should be defined as a) not having any errors or b) according to user-defined criteria in global config)
				-- Module:Run()
				-- assert(enabledModule.ranSuccessfully, "Unable to finish running module " .. enabledModule.name .. " because there were errors. Exiting...") -- Module encountered an error
				
			-- end