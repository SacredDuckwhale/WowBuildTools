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

	args.enableExport = config.export.enabled
	args.exportFolder = config.export.folder
	args.renameTo = config.export.file
	args.exportFileType = config.export.extension
	args.overwriteMode = config.export.overwriteMode
	args.sortByName = config.export.sort
	args.groupByFile = config.export.group
	args.purgeDuplicateEntries	 = config.export.purgeDuplicates
	args.suffixString = config.export.prefixString
	args.prefixString = config.export.suffixString

	args.localizationTable = config.parser.localizationTable
	args.useSquareBrackets = config.parser.useSquareBrackets
	args.ignoredFolders = config.ignoreFolders
	
	args.startDir = project.root
	
	-- Build args table for parameters
	local params = {}
	for k, v in pairs(args) do -- Form string to pass along
		
		if not (type(v) == "boolean" and not v) -- Skip boolean values that are false (as no setting needs to be disabled manually)
		and not (type(v) == "string" and v == "") -- empty strings need not be passed either
		then -- Is a valid argument and should be passed
		
			params[#params+1] = "-" .. k ..  (type(v) ~= "boolean" and (" " .. v) or "") -- remove boolean values even if they are true to get the -key syntax
		
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