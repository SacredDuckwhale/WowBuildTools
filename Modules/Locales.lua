local Module = {}

local script = {}

----------------------------------------------------------------------------------------------------------------------

script.folder = "scrapewhale"
script.file = "scrapewhale"
script.extension = "lua"

----------------------------------------------------------------------------------------------------------------------

function script:Run(project, config, silent)
	
	local _
	
	-- Read script that will be used to build the addon according to the given config settings
	local scriptFile = "Libs\\" .. script.folder .. "\\" .. script.file .. "." .. script.extension
	local Script = assert(loadfile(scriptFile), "Failed to load script file: " .. scriptFile)
	
	-- Extract relevant info from args
	
	-- TODO: Check if config etc is valid?
	
	local args = {} -- simulates CLI arguments submitted in the typical "-key value" pattern (or "-key" if the value is true)

	-- Maps config settings to actual script CLI arguments (This isn't necessary for all scripts, and could be avoided if the config options were named appropriately... but then, the required arguments aren't always the most intuitive...)
	args.enableExport = config.export.enabled
	args.exportFolder = config.export.folder
	args.renameTo = config.export.file
	args.exportFileType = config.export.extension
	args.overwriteMode = config.export.overwriteMode
	args.sortByName = config.export.sort
	args.groupByFile = config.export.group
	args.purgeDuplicateEntries	 = config.export.purgeDuplicates
	args.suffixString = config.export.suffixString
	args.prefixString = config.export.prefixString

	args.localizationTable = config.parser.localizationTable
	args.useSquareBrackets = config.parser.useSquareBrackets
	args.ignoredFolders = config.parser.ignoreFolders
	
	args.startDir = project.root
	
	-- Build args table for parameters
	local params = {}
	for k, v in pairs(args) do -- Form string to pass along
		
		if not (type(v) == "boolean" and not v) -- Skip boolean values that are false (as no setting needs to be disabled manually)
		and not (type(v) == "string" and v == "") -- empty strings need not be passed either
		then -- Is a valid argument and should be passed
		
			if type(v) == "table" then -- Concatenate table entries (will be ignoredFolders) -> -key value1;value2;...;valueN
				
				params[#params+1] = "-" .. k .. " " .. table.concat(v, ";")
				
			else -- Concatenate as -key value
		
				params[#params+1] = "-" .. k ..  (type(v) ~= "boolean" and (" " .. v) or "") -- remove boolean values even if they are true to get the -key syntax
			
			end
		
		end
		
	end

	-- Run script with this configuration
	_ = not silent and print("Attempting to run script file: " .. scriptFile)
	Script(unpack(params)) -- TODO: scrapewhale doesn't use silent mode -> should it work for scripts or just script loaders?
	--Script(project, config, silent)
	
end

----------------------------------------------------------------------------------------------------------------------

Module.script = script

return Module