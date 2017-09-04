local Module = {}

local script = {}

----------------------------------------------------------------------------------------------------------------------

script.folder = "scrapewhale"
script.file = "scrapewhale"
script.extension = "lua"

----------------------------------------------------------------------------------------------------------------------

function script:GetArgs(project, config, silent)

	local args = {}

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
	
	args.projectName = string.match(project.root, ".*/(.+)$") -- TODO
	args.startDir = project.root
	
	return args

end

----------------------------------------------------------------------------------------------------------------------

Module.script = script

return Module