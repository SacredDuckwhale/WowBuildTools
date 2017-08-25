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

--- Parsing of command-line arguments using the "-key value" syntax

local CLI = {}

-- Settings (TODO)
local silentMode = true

-- Upvalues
local luaprint = print

--- Helper function to print more concise debug messages
local function print(...)
	
	if not silentMode then
	
		luaprint("CLI: ", ...)
	
	end
	
end

--- Parse a typical args array consisting of Strings representing keys and/or values
-- @param args Table containing the passed arguments as values
-- @return The parameters in a table = { key = value } format
function CLI:ParseArguments(args)

	local parameters = {}
	local param, value
	
--	print("Detected " .. #args .. " arguments")
	for index, arg in pairs(args) do -- Compare arg against defaults table structure
	
		param, value = arg:match("^-([^%s]+)%s?(.*)$")
		print(param, value)
		
		-- Split values if several are concatenated (list of ignored folders)	
		
		-- Split key and value pairs if any are found
		print("Checking arg " .. index .. ": \"" .. tostring(arg) .. "\"")
		if param and value ~= nil then -- Extraction was successful -> Save values
		
			parameters[param] = value ~= "" and value or true -- Set boolean keys to true, as only enabling parameters are valid (-enableStuff sets parameters.enableStuff = true - if it was false, there'd be no point)

		else -- use default value
		
			print("Ignoring arg " .. index .. " because it was invalid")
			
		end
	end

	return parameters

end

return CLI