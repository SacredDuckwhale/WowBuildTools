-- ScrapeWhale.lua
-- Scraper for localized strings
-- Initially based on the WeakAuras 2 "babelfish" scraper, which was a great idea even though it didn't do things in the same way (Windows... :P)
--
-- TODO: Auto upload to CF via GET/API
-- TODO: What about the TOC namespace? (might as well leave that be for now)
-- -----

-- Libraries
local lfs = require("lfs") -- LuaFileSystem
local CLI = loadfile("Libs/scrapewhale/CLI.lua") or loadfile("CLI.lua") -- Command-line interface (arguments/parsing)
CLI = CLI()


-- Script data structures
local Scrapewhale = {}
local settings = {} -- Current settings (read from the CLI), or default settings (if no parameters were given)

local ignoreList = {} -- Folders that are to be ignored
local scrapeList = {} -- Files that will be scraped
local phrases = {} -- Which phrases will be exported

local args = { ... }


-- Parser settings (defaults)
settings.startDir = ".." -- start scraping here
settings.useSquareBrackets = true -- TODO
settings.localizationTable = "L" -- TODO

-- Export settings (defaults)
settings.enableExport = true
settings.exportFolder = "Locales\\"  -- relative to startDir
settings.renameTo = "enGB" -- Careful: Will overwrite stuff without asking (TODO: config option to save a copy?)
settings.exportFileType = "lua"
settings.sortByName = true -- TODO
settings.groupByFile = true -- TODO
settings.purgeDuplicateEntries = false -- TODO
settings.prefixString = [[local L = LibStub("AceLocale-3.0"):NewLocale("TotalAP", "enGB", true)]] -- TODO
settings.suffixString = "" -- TODO

settings.ignoredFolders = "" -- Folders that should not be scraped, given as a comma-separated list (folder1;folder2;...;folderN)


-- CurseForge namespaces (if several are to be used)
local namespaces = {
    "Base",
}


--dump(ignoredFolders)
-- Prefix to all files if this script is run from a subdir, for example
local filePrefix = settings.startDir .. "/" -- TODO


--- Prepare internal data structures for parsing and scraping according to the currently active settings
-- This should be run before parsing, obviously
function Scrapewhale:Init()

	-- Read CLI args and extract settings (overwrites the default values)
	local args = args or {}
	local parameters = CLI:ParseArguments(args)
	if parameters then -- Validate arguments and discard unusable ones
		for k, v in pairs(parameters) do -- Check if this key exists in the default settings (which means it is valid)
			--print(k, v)
			if settings[k] and v ~= "" then -- Overwrite default with the command line argument
				--print("Overwriting default settings for key = " .. tostring(k) .. " with CLI parameter v = " .. tostring(v) .. " (was: " .. type(settings[k]) .. " = \"" .. tostring(settings[k]) .. "\")")
				settings[k] = v
			end
		end
	end

	-- Split ignored folders parameter to extract ignored folder names (as it can contain several folders in just one CLI argument)
	for folderName in string.gmatch(settings.ignoredFolders, "([^%s;]+);?") do  -- Mark folders as "ignored" and build the "ignore list"
--		print("Init -> ignoring folder " .. folderName)
		ignoreList[folderName] = true
	end

end

--- Returns whether or not a given file is in the list of ignored elements (that should not be parsed)
-- Workaround because Lua patterns can't do | (regexp syntax) and I'm not installing a separate library just for this
--- @param str The file path
-- @return True if there's an entry for this file object; nil otherwise
local function MatchesIgnorelistEntry(str)
--		print(str)
	for k, v in pairs(ignoreList) do
--		print("Test for match of str " .. str .. " with k =  " .. k)
		if string.find(str, k) then return true end
	end
	
	return false
end

--- Scan a directory and add lua files to the scrape list (queue)
-- Recursive filesystem navigation via LFS to find all Lua files that could be scraped
-- @param path The path to the directory (file object)
function Scrapewhale:ScanDir(path)
	
	    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path..'/'..file
	
			if string.match(file, ".lua$") and not MatchesIgnorelistEntry(f) then -- Is a valid file for scraping
			--	print ("\tAdding file to the scrape list: "..f)
				table.insert(scrapeList, f)
			else
				--print("Ignored file (not a .lua file): " .. file)
			end

            local attr = lfs.attributes (f)
            assert (type(attr) == "table", "ScanDir -> LFS attribute for" .. path .. " is not table")
            if attr.mode == "directory" then -- Down the rabbit hole we go
                Scrapewhale:ScanDir (f)
            end
        end
    end
end

--- Parses a file and adds localized phrases that were found in them to the export list
-- @param filename The name of the file (will be appended after the directory from settings)
-- @return The list of matches (table)
function Scrapewhale:ParseFile(filename)
    local strings = {}
	
    local file = assert(io.open(string.format("%s%s", filePrefix or "", filename), "r") or io.open(filename), "Could not open " .. filename)
    local text = file:read("*all")
    file:close()

    for match in string.gmatch(text, "L%[\"(.-)\"%]") do
        strings[match] = true
		phrases[match] = true
    end
    return strings
end

-- Write <Namespace>_Overview file: Shows where each phrase originated, and how many phrases were found in each parsed file (may contain duplicate entries)
-- While the resulting file could be imported, it serves mainly as a summary intended for the human eye
-- @param namespace The namespace to use (TODO: Other namespaces are NYI?)
function Scrapewhale:WriteOverviewFile(namespace)

	local ns_file = assert(io.open(namespace .. "_Overview.lua", "w"), "Error opening file")
	for _, file in ipairs(scrapeList) do  -- Check for .lua files in this directory
		
	--	print("\nParsing file: " .. file)
		
		local strings = Scrapewhale:ParseFile(file)

		local sorted = {}
		for k in next, strings do
			table.insert(sorted, k)
		end
		table.sort(sorted)
		
		if #sorted > 0 then -- Write entry for this file
			ns_file:write(string.format("-- %s (%d phrases)\n", string.gsub(file, "", ""), #sorted))
			for _, v in ipairs(sorted) do
				--print("Writing file, set for index " .. v .. " = true")
				ns_file:write(string.format(settings.localizationTable .. "[\"%s\"] = true\n", v)) -- TODO: squareBrackets setting
			end
			ns_file:write("\n")
		end
		--print("  (" .. #sorted .. ") " .. file)
	end
	ns_file:close()

end

-- Write <Namespace>_Import file: Gives a condensed summary (to be imported by CF) by filtering duplicate entries and sorting results by name
-- Note that the Overview can just as easily be imported, as duplicate entries overwrite each other and comments are irrelevant; it is larger, though, and would be a waste of space if included in an addon
--@param namespace The namespace to use (TODO: Other namespaces are NYI?)
function Scrapewhale:WriteImportFile(namespace)

	local ns_cmp_file = assert(io.open(namespace .. "_Import.lua", "w"), "Error opening file")
	
	p = phrases
	phrases = {}
	
	for k in next, p do -- Can't sort entries by value alone -> insert into temporary table
		table.insert(phrases, k)
	end
	table.sort(phrases)
--	if settings.sortByName then table.sort(phrases) end
	
	-- Write ALL phrases to compare with CF export
	if #phrases > 0 then
		for k, v in ipairs(phrases) do 
			ns_cmp_file:write(string.format(settings.localizationTable .. "[\"%s\"] = true\n", v)) -- TODO: squareBrackets setting
		end
	end
	
	ns_cmp_file:close()
	
end


--- Write import file to desired output location (read from settings) for a given namespace
--@param namespace The namespace to use (TODO: Other namespaces are NYI?)
function Scrapewhale:ExportPhrases(namespace)

	local exportFilePath = settings.startDir .. "\\" .. settings.exportFolder .. "\\" .. settings.renameTo .. "." .. settings.exportFileType
	print("\nExporting scraped phrases to " .. exportFilePath)
	
	local ns_cmp_file = assert(io.open(namespace .. "_Import.lua", "r"), "Error opening file")
	local writeStr = ns_cmp_file:read("*all")

	local exportFile = assert(io.open(exportFilePath, "w"), "Error opening export file: " .. exportFilePath)
	exportFile:write(settings.prefixString, "\n\n", writeStr, "\n\n", settings.suffixString)
	exportFile:close()	
	
end

--- Starts the parsing process with the given settings
function Scrapewhale:Run() -- Actual script begins here

	-- Read parameters from CLI and prepare internal storage tables
	Scrapewhale:Init()

	-- Fill scrapeList with entries of files to be parsed
	Scrapewhale:ScanDir(settings.startDir) 

	-- extract data from specified lua files
	for _, namespace in ipairs(namespaces) do
	
		print("\nScraping namespace: " .. namespace)
		
		-- Write overview (for the user, mainly)
		Scrapewhale:WriteOverviewFile(namespace)
	
		-- Write import file (to include in the addon or use for CurseForge uploads)
		Scrapewhale:WriteImportFile(namespace)
		
		-- All done, yay ^_^ (Print summary) - Well, almost...
		print("\nFinished scraping " .. #scrapeList .. " files for a total of " .. #phrases .. " phrases")
		
		-- Export to Locales/ folder (or elsewhere, I guess) if applicable
		if settings.enableExport then Scrapewhale:ExportPhrases(namespace) end	

	end
	
end

Scrapewhale:Run()

return Scrapewhale