  ----------------------------------------------------------------------------------------------------------------------
    -- This program is free software: you can redistribute it and/or modify
    -- it under the terms of the GNU General Public License as published by
    -- the Free Software Foundation, either version 3 of the License, or
    -- (at your option) any later version.
	
    -- This program is distributed in the hope that it will be useful,
    -- but WITHOUT ANY WARRANTY; without even the implied warranty of
    -- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    -- GNU General Public License for more details.

    -- You should have received a copy of the GNU General Public License
    -- along with this program.  If not, see <http://www.gnu.org/licenses/>.
----------------------------------------------------------------------------------------------------------------------

local WBT = {}

WBT.version = "0.0.1"


-- Upvalues
local assert = assert
local pairs = pairs
local print = print
local tostring = tostring


function WBT:Build(project) end

function WBT:BuildAll() end

function WBT:ReadConfig()

	local GlobalConfig = require("GlobalConfig")
	
	-- Check if global config is valid here
	
	-- Check if individual module configs are valid here
	
	return GlobalConfig
	
end

function WBT:PrintHelp() end

function WBT:Load(args)
	
	print("\nWowBuildTools " .. WBT.version .. " is now running...\n")
	
	if args then -- Parse arguments (TODO)
	end
	
	local EnabledModules = {}
	
	--Read global config (to determine which modules to run and how to build projects)
	local GlobalConfig = WBT:ReadConfig()
	
	local projects = GlobalConfig.Projects
	local modules = GlobalConfig.Modules
	
	-- TODO: Check format for projects and modules to make sure the entries are valid
	
	assert(projects, "No projects are scheduled to be run. Exiting...")
	assert(modules, "No modules found in global config. Exiting...")
	
	-- If those tables are left empty, the modules will abort
	WBT.Projects = projects or {}
	WBT.Modules = {}
	
	print("Loading required modules...")
	
	-- Load required modules (those that are set to enabled = true in the global config)
	for moduleName, isEnabled in pairs(modules) do -- Check if module is enabled
	--	print("Found module: " .. tostring(moduleName) .. " (Enabled: " .. tostring(isEnabled) .. ")")
		
		if isEnabled then -- Load module and parse its config
		
			print("Loading module: " .. tostring(moduleName))
			
			local moduleFile = "Modules/" .. tostring(moduleName) .. ".lua"
			WBT.Modules[tostring(moduleName)] = assert(dofile(moduleFile), "Failed to load module in file: " .. moduleFile)
			EnabledModules[#EnabledModules+1] = { name = moduleName, ranSuccessfully = false }
			
		end
		
	end
	
	print("Finished loading " .. #EnabledModules .. " module" .. (#EnabledModules > 1 and "s" or ""))
	
	-- Build projects (by running all the enabled modules for them individually)
	for projectName, settings in pairs(projects) do -- Check if project is valid
	
		print("\nDiscovered project: " .. tostring(projectName) .. " (" .. tostring(settings.root) .. ")")
		for key, enabledModule in pairs(EnabledModules) do -- 

			Module = WBT.Modules[enabledModule.name]
			
			if not Module or type(Module) ~= "table" or not Module.Run or not type(Module.Run) == "function" then -- Module is invalid (failed to load properly?)

				print("Failed to run module: " .. enabledModule.name .. " - skipping it...")
				enabledModule.ranSuccessfully = false

			else -- Run module for this project
			
				print("\nRunning module: " .. tostring(enabledModule.name) .. "...")
				-- TODO: Return whether or not it was successful (a successful build should be defined as a) not having any errors or b) according to user-defined criteria in global config)
				enabledModule.ranSuccessfully = Module:Run(true) -- TODO: args = silent (to suppress output)
				assert(enabledModule.ranSuccessfully, "Unable to finish running module " .. enabledModule.name .. " because there were errors. Exiting...") -- Module encountered an error
				
			end
			
		end
		
		-- Print summary (TODO: Count skipped modules and continue building the others, instead of exiting with an error? Maybe depends on settings, as in: if buildStrict -> abort (to prevent untested builds), otherwise skip and proceed?)
		print("\nFinished building project ".. projectName .. " (successfully ran " .. #EnabledModules .. " module" .. (#EnabledModules > 1 and "s" or "") .. ")\n\nSummary:")
		for k, v in pairs(EnabledModules) do 
		
			print(tostring(k) .. ". " .. tostring(v.name) .. ": " .. tostring((v.ranSuccessfully and "Done") or "Skipped"))
		
		end
		
	end
	
	print("\nFinished building all projects. Have a good day!")
	
end

return WBT