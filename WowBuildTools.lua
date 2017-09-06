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


-- Load main module
WBT = require("WBT")

-- Load libs
local inspect = require('Libs/inspect/inspect')
local CLI = assert(loadfile("Libs/utils/CLI.lua") or loadfile("CLI.lua"), "Failed to open required library/module") -- Command-line interface (arguments/parsing)
WBT.CLI = CLI()
local LFS = assert(loadfile("Libs/utils/LFS.lua") or loadfile("LFS.lua"), "Failed to open required library/module")
WBT.LFS = LFS()
local TOC = assert(loadfile("Libs/utils/TOC.lua") or loadfile("TOC.lua"), "Failed to open required library/module")
WBT.TOC = TOC()


-- Global functions (used across modules) - TODO: Move elsewhere?
function dump(value)

	print(inspect(value))

end


-- Execute main module
os.exit( WBT:Load(args) )