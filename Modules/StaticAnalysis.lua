local Module = {}

script = {}

----------------------------------------------------------------------------------------------------------------------

script.folder = "luacheck"
script.file = "loader"
script.extension = "lua"

----------------------------------------------------------------------------------------------------------------------

function script:GetArgs(project, config, silent)

	local args = {}

	--args.quiet = config.quietMode or true
	args.only = config.filter or{ "011" }
	args.ignoredFolders = config.ignoreFolders or {}
	args.cache = config.cacheResults or true
	args.config = (config.configPath and config.configPath .. "/") or "."
	args.detailedReports = config.detailedReport or true
	args.strictMode = config.strictMode or true
	args.startDir = project.root or ".."
	
	return args

end

----------------------------------------------------------------------------------------------------------------------

Module.script = script

return Module