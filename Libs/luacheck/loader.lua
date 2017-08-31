-- Simple luacheck wrapper to call it with options specified in the module's configuration file
local luacheck = require("luacheck")

-- Utility modules (shortcuts)
local CLI = WBT.CLI
local LFS = WBT.LFS

-- Extract args (as the luacheck CLI requires an options table
local args = { ... }
local options = CLI:ParseArguments(args)
--print("Parsed CLI args: "); dump(options)

-- Extract ignored files (luacheck module needs a different format than provided by the CLI module) -> TODO: Allow option in CLI to return array instead of comma-separated list?
local ignoredFolders = {}
local excludedFilesString = ""
for folder in string.gmatch(options.ignoredFolders, "([^%s;]+);?") do -- Add folder to list of ignored folders
	
	ignoredFolders[folder] = true
	excludedFilesString = excludedFilesString .. "--exclude-files */" .. folder .. "*.lua "
	
end
options.ignoredFolders = nil -- Unset, as this is an invalid luacheck option
--print("Ignored folders are now:"); dump(ignoredFolders)

-- TODO: see above, allow table as parameter instead of parsing it (in CLI)
if type(options.only) ~= table then -- Invalid format (luacheck wants a table here)
	options.only = { only }
end
--dump(options)

-- Extract module options used by the loader (and not luacheck itself)
local detailedReports = options.detailedReports
options.detailedReports = nil

local strictMode = options.strictMode
options.strictMode = nil

local startDir = options.startDir
options.startDir = nil

-- Build list of files that should be checked
local files = {}
LFS:ScanDir(startDir, files, ignoredFolders)
--print("List of selected files:"); dump(files)


-- Call luacheck with args to retrieve its report table
local finalReport = luacheck(files, options) 
--dump(finalReport)

print("-------------------------")

-- Print luacheck report
print("Starting analysis with luacheck v" .. luacheck._VERSION .. " in path " .. startDir .. "\n") -- " \nShow detailed reports: " .. tostring(detailedReports) .. "\n")
local errors, fatals, warnings = finalReport["errors"], finalReport["fatals"], finalReport["warnings"]
local numFiles = #files

if detailedReports and (errors > 0 or warnings > 0 or fatals > 0)  then -- Give a detailed summary of potential issues (can be skipped otherwise, as the reports are going to be empty tables)

	for key, fileReports in pairs(finalReport) do -- Print file report

		if key ~= "errors" and key ~= "fatals" and key ~= "warnings" then -- Entry is an actual file report -> Print it
			
			for i, issue in pairs(fileReports) do -- Check this report
				
				 if issue.msg then -- Print errors or warnings found
					
					local relativePath = string.match(files[key], "" .. startDir .. "/(.*)")
					print("(" .. issue.code .. ")	" .. relativePath .. ":" .. issue.line .. ":" .. issue.column .. ":	" .. issue.msg)
					
				 end
				
			end
		end

	end
	
	print()
	
end

-- Print summary
local checksPassed = not (fatals > 0 or errors > 0 or strictMode and warnings > 0)
print("Total: " .. warnings .. " warnings / " .. errors .. " errors in " .. numFiles .. " files" .. (checksPassed and "" or "\n\n"))
assert(checksPassed, "\nBuild failed! Please fix any errors" .. (strictMode and warnings > 0 and " and warnings" or "") .. " before trying again") -- Stop build, as errors need to be fixed

print("-------------------------")