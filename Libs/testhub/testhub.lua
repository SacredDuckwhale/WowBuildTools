-- testhub.lua
-- Very basic luaunit test environment, containing mockups for the WOW API and Lua functions
-- Will call any test suites for the given project
-- -----

-- Libraries
local CLI = WBT.CLI

local TestHub = {}
local args = { ... }




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
	
		-- Run test suite for this project
		local filePath = parameters.projectRoot .. "/" .. tostring(parameters.testDir) .. "/" .. tostring(parameters.testFile) .. ".lua"
		print("Running test suites from file " .. filePath .. "...")
		local testMain = assert(loadfile(filePath)(parameters.projectRoot), "Failed to open file " .. filePath)
		
		-- Try to detect failed tests
		local exitCode = testMain()
		print("luaunit exitCode = " .. exitCode)
		assert(exitCode == 0, "Unit tests failed")
		
	end
	
	print("-------------------------")
	
end

TestHub:Run()

return TestHub