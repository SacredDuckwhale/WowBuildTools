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

--- WBT Loader

-- Read command line arguments
local args = ...

-- Global functions (used across modules) - TODO: Move elsewhere?
function dump(value)

	print(inspect(value))

end

-- Load main module
WBT = require("WBT")

-- Load libs
local inspect = require('Libs/inspect/inspect')
local CLI = loadfile("Libs/utils/CLI.lua") or loadfile("CLI.lua") -- Command-line interface (arguments/parsing)
WBT.CLI = CLI()

-- Execute main module
os.exit( WBT:Load(args) )