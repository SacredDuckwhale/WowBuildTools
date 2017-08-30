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

--- Scanning of directories using the LFS module
local lfs = require("lfs") -- LuaFileSystem
local LFS = {}

--- Returns whether or not a given file is in the list of ignored elements (that should not be parsed)
-- Workaround because Lua patterns can't do | (regexp syntax) and I'm not installing a separate library just for this
--- @param str The file path
-- @return True if there's an entry for this file object; nil otherwise
local function MatchesBlacklistEntry(str, blacklist)
--		print(str)
	for k, v in pairs(blacklist) do
--		print("Test for match of str " .. str .. " with k =  " .. k)
		if string.find(str, k) then return true end
	end
	
	return false
	
end

--- Scan a directory and add lua files to the scrape list (queue)
-- Recursive filesystem navigation via LFS to find all Lua files that could be scraped
-- @param path The path to the directory (file object)
-- @param scanList the Table that will be used to store the matches
-- @param blacklsitedFile A table that contains files which should not be added to the results
function LFS:ScanDir(path, scanList, blacklistedFiles)
	
	-- TOOD: Invalid parameters -> if blacklistedFiles and type(blacklistedFiles) == "table" then return end (etc)
	
	    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path..'/'..file
	
			if string.match(file, ".lua$") and not MatchesBlacklistEntry(f, blacklistedFiles) then -- Is a valid file for scraping
				print ("\tAdding file to the scrape list: "..f)
				table.insert(scanList, f)
			else
				--print("Ignored file (not a .lua file): " .. file)
			end

            local attr = lfs.attributes (f)
            assert (type(attr) == "table", "ScanDir -> LFS attribute for" .. path .. " is not table")
            if attr.mode == "directory" then -- Down the rabbit hole we go
                LFS:ScanDir (f, scanList, blacklistedFiles)
            end
        end
    end
end

return LFS