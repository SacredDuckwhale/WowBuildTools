local config = {}

setfenv(1, config)

----------------------------------------------------------------------------------------------------------------------
-- Edit stuff below
----------------------------------------------------------------------------------------------------------------------

ignoreFolders = { -- Folders that should not be checked

	"_DEV",
	"Libs",
	"Locales",
	
}

--quietMode = true -- Only display errors TODO: Doesn't work with module (only CLI?)
detailedReports = true -- Show detailed report messages (as opposed to just a summary) if things have gone wrong
strictMode = true -- Stop build if warnings occured, and not just fatals/errors

filter = { "011" } -- Apply these filters
configPath = "F://GitHub/WowBuildTools" -- .luacheckrc file path
cacheResults = true -- Improves run time by only checking files that changed since the last time they were checked (stores cache in .luacheckcache)

----------------------------------------------------------------------------------------------------------------------
-- Stop editing here
----------------------------------------------------------------------------------------------------------------------

return config