local config = {}

setfenv(1, config)

export = {}

----------------------------------------------------------------------------------------------------------------------
-- Edit stuff below
----------------------------------------------------------------------------------------------------------------------

-- TODO: Default values - can be overwritten by CLI args
-- TODO: Move comments to README.MD

-- Parser settings
parser.localizationTable = "L" -- Name of the localization table (usually, this is simply "L")
parser.useSquareBrackets = true -- Whether or not square brackets notation should be read
parser.ignoreFolders = { -- Folders that should not be scraped
	"_DEV/",
	"Libs/",
	"Locales/",
}
-- TODO: parser.useDotNotation = false -- Whether or not nested tables separated by a dot should be read (.e.g, L.PHRASE_KEY) -- may need special handling to replace constants with strings

-- Export settings
export.enabled = true -- Save scraped results in file (as opposed to simply outputting them)
export.folder = "Locales" -- This is the folder inside the project directory where the output file will be deposited
export.file = "enGB" -- The Lua file that will hold the default locale (which is being exported)
export.extension = "lua"
export.overwriteMode = "ask" -- TODO: NYI (ask, notiffy, silent, skip options)
export.sort = true -- Whether or not the phrases should be sorted
export.group = true -- Whether or not the phrases should be grouped (by files they were encountered in) -> This will show the file name as a commented group header
export.purgeDuplicates = false -- Whether or not duplicate phrases should be squashed to one line (makes no difference functionally, but when a phrase appears in several files removing them might leave that group empty)
export.prefixString = "" -- A string to add before writing the exported phrases, e.g. for initialising the Locales table or conditional assignments and debug code
export.suffixString = "" -- A string to add after the exported phrases, e.g. for closure ends or similar structures

----------------------------------------------------------------------------------------------------------------------
-- Stop editing here
----------------------------------------------------------------------------------------------------------------------

return config