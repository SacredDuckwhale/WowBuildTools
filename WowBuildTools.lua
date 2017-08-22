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


-- Read command line arguments
local args = ...

-- Load libs
local inspect = require('Libs/inspect/inspect')
function dump(value)

	print(inspect(value))

end


-- Load core
WBT = require("WBT")

-- Load modules
WBT.Documentation = require("Modules/Documentation/Loader")
WBT.CodeStandards = require("Modules/CodeStandards/Loader")
WBT.Versioning = require("Modules/Versioning/Loader")
WBT.ChangeLogs = require("Modules/ChangeLogs/Loader")
WBT.StaticAnalysis = require("Modules/StaticAnalysis/Loader")
WBT.UnitTests = require("Modules/UnitTests/Loader")
WBT.CurseForge = require("Modules/CurseForge/Loader")
WBT.Locales = require("Modules/Locales/Loader")

-- Exit
os.exit( WBT:Run(args) )