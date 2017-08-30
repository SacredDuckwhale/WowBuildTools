
local luacheck = require("luacheck")

local CLI = WBT.CLI
local LFS = WBT.LFS

local args = { ... }


-- Extract args (as the luacheck CLI requires an options table
local options = CLI:ParseArguments(args)
--dump(options)

-- Extract ignored files
local ignoredFolders = {}
for folder in string.gmatch(options.ignoredFolders, "([^%s;]+);?") do -- Add folder to list of ignored folders
	ignoredFolders[folder] = true
end
options.ignoredFolders = nil
--dump(ignoredFolders)

print("-------------------------")

-- Extract start dir
local startDir = options.startDir
options.startDir = nil

-- Build list of valid files
local files = {}
LFS:ScanDir(startDir, files, ignoredFolders)

-- Call luacheck with args
local report = luacheck(files, options)
--dump(report)

local errors, fatals, warnings = report["errors"], report["fatals"], report["warnings"]
local numFiles = 0
print("Total: " .. warnings .. " warnings / " .. errors .. " errors in " .. numFiles .. " files")

-- Print report
--local finalReport = luacheck.process_reports(report, options)
-- dump(finalReport)

print("-------------------------")