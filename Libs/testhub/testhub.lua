-- testhub.lua
-- Very basic luaunit test environment, containing mockups for the WOW API and Lua functions
-- Will call any test suites for the given project
-- -----

-- Libraries
luaunit = require("Libs/testhub/luaunit")

local TestHub = {}
local args = { ... }

-- Required WBT modules
local CLI = WBT.CLI
local TOC = WBT.TOC

-- Helper functions
local inspect = require('Libs/utils/inspect')
function dump(value)

	print(inspect(value))

end

-- Mock environment
require("MockUps/mock_wowapi")
require("MockUps/mock_luaenv")


--- Starts the parsing process with the given settings
function TestHub:Run() -- Actual script begins here

	-- Read CLI args and extract settings (overwrites the default values)
	local args = args or {}
	local parameters = CLI:ParseArguments(args)

	print("-------------------------")

	if not (parameters.testDir and parameters.testFile) then -- Skip testing as there are no test suites available
		print("Skipped unit testing as there are no test suites for this project...")
	else -- Run test suite (handled by individual "main" test file, for now) (TODO)
	
		-- Append lua path so that the project folder is browsed for required files
		package.path = package.path .. ";" .. parameters.projectRoot .. "/" .. parameters.testDir .. "/?.lua"
	
		-- Drop previously created tests to avoid misleading errors
		for k, v in pairs(_G) do -- Drop the entry if it's a table/function and starts with "Test" (luaunit scans for this criteria)

			if k:match("Test") and (type(v) == "table" or type(v) == "function") then -- Is test suite that was created by other projects -> Drop it
--				print("Dropping test suite with key = " .. k)
				_G[k] = nil
			end

		end
		
		
		-- Parse TOC contents and add files to the global mock environment
		local path = parameters.projectRoot
		local root = "..\\"  -- path from tests subfolder to addon root dir
		local toc = parameters.projectName .. ".toc"

		-- Set global variable used for mock API and ReadTOC (TODO: This needn't be -> Find a better solution)
		-- Set globals that are accessed by the mock APIs (only those that are needed by this addon's test suite)
		addonName = parameters.projectName
		
		-- Read TOC file and 
		TOC:Read((path and path .. "/") or root, toc)
		
		-- Run test suite for this project
		local filePath = parameters.projectRoot .. "/" .. tostring(parameters.testDir) .. "/" .. tostring(parameters.testFile) .. ".lua"
		print("Running test suites from file " .. filePath .. "...")
		local testMain = assert(loadfile(filePath)(parameters.projectRoot), "Failed to open file " .. filePath)
		
		-- Try to detect failed tests
		local exitCode = testMain()
--		print("luaunit exitCode = " .. exitCode .. "= NUMBER OF ERRORS")
		assert(exitCode == 0, "Unit tests failed because there were errors")
		
	end
	
	print("-------------------------")
	
end

TestHub:Run()

return TestHub