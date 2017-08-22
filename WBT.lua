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

function WBT:Run(args)
	
	print("WowBuildTools " .. WBT.version .. " is now running...")
	
	if args then
		-- Parse arguments (TODO)
	end
	
	local EnabledModules = {}
	
	-- Read config and store its values for later
	local GlobalConfig = WBT:ReadConfig()
	
	local projects = GlobalConfig.Projects
	local modules = GlobalConfig.Modules
	
	assert(projects, "No projects are scheduled to be run. Exiting...")
	
	-- Load required modules (if any)
	for Module, isEnabled in pairs(modules) do -- Check if module is enabled
		print("Found module: " .. tostring(Module) .. " (Enabled: " .. tostring(isEnabled) .. ")")
		
		if isEnabled then -- Load module and parse its config
			print("Loading module: " .. tostring(Module))
			local loaderPath = "Modules/" .. tostring(Module) .. "/" .. "Loader.lua"
			--local config = assert(loadfile(loaderPath), "Failed to load file: " .. loaderPath)
			local moduleConfig = Module.Config -- TODO: Is nil because they don't exist yet
			EnabledModules[#EnabledModules+1] = { name = Module, ranSuccessfully = false } -- TODO: Global WBT.Module and WBT.Module.config
			
			-- TODO: Check config for validity
			
			-- Config is valid -> store for later use
		end
		
	end
	
	for projectName, settings in pairs(projects) do -- Check if project is valid
	
		print("Discovered project: " .. tostring(projectName) .. " (dir: " .. tostring(settings.root) .. ")")
		for key, enabledModule in pairs(EnabledModules) do -- 
--dump(enabledModule)
			Module = WBT[enabledModule.name]
--dump(WBT)			
			if not Module or type(Module) ~= "table" or not Module.Run or not type(Module.Run) == "function" then -- Module is invalid (failed to load properly?)

				print("Failed to run module: " .. enabledModule.name .. " - skipping it...")
				enabledModule.ranSuccessfully = false

			else -- Run module for this project
			
				print("Running module " .. tostring(enabledModule.name) .. "...")
				-- TODO: Return whether or not it was successful (a successful build should be defined as a) not having any errors or b) according to user-defined criteria in global config)
				enabledModule.ranSuccessfully = Module:Run(true) -- TODO: args = silent (to suppress output)
			
			end
		end
		
		-- rootDir = assert(io.open(root), "Could not open " .. root)
		-- if not rootDir then -- No such directory
			
		-- end
		-- settings are valid -> run modules for this project
		
		-- settings are invalid -> exit with error message
		
		-- Run enabled modules
		
		-- Print summary
	
		print("Built " .. projectName .. " running " .. # EnabledModules .. " modules")
		for k, v in pairs(EnabledModules) do 
			print(tostring(k) .. ". " .. tostring(v.name) .. ": " .. tostring((v.ranSuccessfully and "Done") or "Skipped"))
		end
		
	end
	

	

		
end

return WBT