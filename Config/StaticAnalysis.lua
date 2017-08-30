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

quietMode = true -- Only display errors
filter = "011" -- Apply this filter
 
----------------------------------------------------------------------------------------------------------------------
-- Stop editing here
----------------------------------------------------------------------------------------------------------------------

return config