local config = {}

setfenv(1, config)

parser = {}
export = {}

----------------------------------------------------------------------------------------------------------------------
-- Edit stuff below
----------------------------------------------------------------------------------------------------------------------

-- TODO: Default values - can be overwritten by CLI args (move them to the script as well? It can't rely on them always being supplied by CLI)
-- TODO: Move comments to README.MD

-- Parser settings
parser.localizationTable = "L" -- Name of the localization table (usually, this is simply "L")
parser.useSquareBrackets = true -- Whether or not square brackets notation should be read (e.g., L['Hello'] = 'Hello' will be added)
-- parser.useDotNotation = false -- Whether or not dot notation should be read (e.g., L.key = 'Hello' will be added if key can be found - NYI)
-- TODO: parser.useDotNotation = false -- Whether or not nested tables separated by a dot should be read (.e.g, L.PHRASE_KEY) -- may need special handling to replace constants with strings)
parser.ignoreFolders = { -- Folders that should not be scraped
	"_DEV",
	"Libs",
	"Locales",
}

-- Export settings
export.enabled = true -- Save scraped results in file (as opposed to simply outputting them)
export.folder = "Locales" -- This is the folder inside the project directory where the output file will be deposited
export.file = "enGB" -- The Lua file that will hold the default locale (which is being exported)
export.extension = "lua"
export.overwriteMode = "silent" -- How to act if the export file already exists NYI (ask -> read, then (write or skip) and notify, notify -> write and print, silent -> write, skip -> skip and print - options) (only applies if exports are enabled)
export.sort = true -- Whether or not the phrases should be sorted lexicographically, or listed in the order of appearance. Applies to both namespace overview files, as well as the exported file (if exports are enabled)
export.group = true -- Whether or not the phrases should be grouped (by files they were encountered in) -> This will show the file name as a commented group header in namespace overview files (doesn't apply to condensed import files)
export.purgeDuplicates = true -- Whether or not duplicate phrases should be squashed to one line (makes no difference functionally, but when a phrase appears in several files removing them might leave that group empty)
export.prefixString = "" -- A string to add before writing the exported phrases, e.g. for initialising the Locales table or conditional assignments and debug code
export.suffixString = "" -- A string to add after the exported phrases, e.g. for closure ends or similar structures

----------------------------------------------------------------------------------------------------------------------
-- Stop editing here
----------------------------------------------------------------------------------------------------------------------

return config