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
--TODO: Add License text to file headers
--- 
-- @module WBT

--- GlobalConfig.lua.
-- Contains settings that control how and which modules are being executed during the build phase
-- @section GlobalConfig

local GlobalConfig = {}
setfenv(1, GlobalConfig) -- This is to avoid littering the global namespace with config options

----------------------------------------------------------------------------------------------------------------------
-- Edit stuff below
----------------------------------------------------------------------------------------------------------------------

-- Projects structure (must adhere to the layout outlined in the readme) ->
-- each project entry consists of: "Name" -> { key =  value } pairs for all valid parameters
-- exclusions = folders that are not going to be checked for .lua files
Projects = {
	["TotalAP"] = {
		["root"] = "F:\\\\GitHub\\TotalAP",
		["exclusions"] = { -- TODO: Are they even used somewhere?
			-- Folders
			"_DEV",
			"Docs",
			"Libs",
			"Tests",
			"Locales",
			".git",
		}
	}
}

--- These are the modules that should be executed. Note that this will be overwritten by command line arguments where necessary
Modules = {
	["ChangeLogs"] = true,
	["CodeStandards"] = true,
	["CurseForge"] = true,
	["Documentation"] = true,
	["Locales"] = true,
	["StaticAnalysis"] = true,
	["UnitTests"] = true,
	["Versioning"] = true,
}



----------------------------------------------------------------------------------------------------------------------
-- Stop editing here
----------------------------------------------------------------------------------------------------------------------

return GlobalConfig