local Module = {}

script = {}

----------------------------------------------------------------------------------------------------------------------

script.folder = "testhub"
script.file = "testhub"
script.extension = "lua"

----------------------------------------------------------------------------------------------------------------------

function script:GetArgs(project, config, silent)

	local args = {}
	
	args.testDir = project.testDir or ""
	args.testFile = project.testFile or ""
	args.projectRoot = project.root or "."
	args.projectName = string.match(project.root, ".*/(.+)$") -- TODO
	
	return args

end

----------------------------------------------------------------------------------------------------------------------

Module.script = script

return Module