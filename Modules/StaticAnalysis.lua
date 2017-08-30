local Module = {}

script = {}

----------------------------------------------------------------------------------------------------------------------

script.folder = "luacheck"
script.file = "loader"
script.extension = "lua"

----------------------------------------------------------------------------------------------------------------------

function script:GetArgs(project, config, silent)

	local args = {}

	args.quiet = config.quietMode or true
	args.filter = config.filter or "011"
	args.ignoredFolders = config.ignoreFolders or {}
	
	args.startDir = project.root or ".."
	
	return args

end

----------------------------------------------------------------------------------------------------------------------

Module.script = script

return Module