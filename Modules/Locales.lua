local Module = {}

local script = {}

----------------------------------------------------------------------------------------------------------------------

script.folder = "scrapewhale"
script.file = "scrapewhale"
script.extension = "lua"

----------------------------------------------------------------------------------------------------------------------

function script:GetArgs(project, config, silent)

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
	
	return args

end



----------------------------------------------------------------------------------------------------------------------

Module.script = script

return Module