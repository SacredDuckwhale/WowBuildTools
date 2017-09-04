-- scrapewhale.lua
-- This is a very basic scraper to find updated strings used in the addon localization process
-- Acknowledgement: Initially based on the WeakAuras 2 "babelfish" scraper, which I thought was a great idea. It didn't do things in the same way and was intended for use with Unix systems (I'm on Windows... sue me)

-- -----

-- Libraries
local CLI = WBT.CLI
local LFS = WBT.LFS
local file_exists = function(name)

	local f=io.open(name,"r")
	
	if f~=nil then
	
		io.close(f)
		return true
		
	else return false end
	
end


-- Script data structures
local Scrapewhale = {}
local settings = {} -- Current settings (read from the CLI), or default settings (if no parameters were given)

local ignoreList = {} -- Folders that are to be ignored
local scrapeList = {} -- Files that will be scraped
local phrases = {} -- Which phrases will be exported

local args = { ... }


-- Parser settings (defaults)
settings.projectName = "" -- TODO
settings.startDir = ".." -- start scraping here
settings.useSquareBrackets = true -- TODO
settings.localizationTable = "L" 

-- Export settings (defaults)
settings.enableExport = true
settings.exportFolder = "Locales"  -- relative to startDir
settings.renameTo = "enGB" -- Careful: Will overwrite stuff without asking (TODO: config option to save a copy?)
settings.exportFileType = "lua"
settings.sortByName = true
settings.groupByFile = true
settings.purgeDuplicateEntries = true
settings.prefixString = [[local L = LibStub("AceLocale-3.0"):NewLocale("TotalAP", "enGB", true)]]
settings.suffixString = ""
settings.ignoredFolders = "" -- Folders that should not be scraped, given as a comma-separated list (folder1;folder2;...;folderN)
settings.overwriteMode = "silent"

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
			if settings[k] ~= nil and v ~= "" then -- Overwrite default with the command line argument
--				print("Overwriting default settings for key = " .. tostring(k) .. " with CLI parameter v = " .. tostring(v) .. " (was " .. (type(settings[k]) == "string" and "\"" or "") .. tostring(settings[k]) .. (type(settings[k]) == "string" and "\"" or "") .. ")")
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

	local ns_file = assert(io.open("tmp/" .. settings.projectName .. "_" .. namespace .. "_Overview.lua", "w"), "Error opening file")
	for _, file in ipairs(scrapeList) do  -- Check for .lua files in this directory
		
	--	print("\nParsing file: " .. file)
		
		local strings = Scrapewhale:ParseFile(file)

		local sorted = {}
		for k in next, strings do
			table.insert(sorted, k)
		end

		if settings.sortByName then table.sort(sorted) end
		
		if #sorted > 0 then -- Write entry for this file
		
			local fileOverviewString = string.format("%s (%d phrase" .. (#sorted > 1 and "s" or "") .. ")", file, #sorted)
			print("Writing entries for " .. fileOverviewString)
			if settings.groupByFile then ns_file:write("-- " .. fileOverviewString .. "\n") end
			
			for _, v in ipairs(sorted) do
				
				--print("Writing file, set for index " .. v .. " = true")
				ns_file:write(string.format(settings.localizationTable .. "[\"%s\"] = true\n", v)) -- TODO: squareBrackets setting
				
			end
			
			if settings.groupByFile then ns_file:write("\n") end

		end
		
	end
	ns_file:close()

end

-- Write <Namespace>_Import file: Gives a condensed summary (to be imported by CF) by filtering duplicate entries and sorting results by name
-- Note that the Overview can just as easily be imported, as duplicate entries overwrite each other and comments are irrelevant; it is larger, though, and would be a waste of space if included in an addon
--@param namespace The namespace to use (TODO: Other namespaces are NYI?)
function Scrapewhale:WriteImportFile(namespace)

	local ns_cmp_file = assert(io.open("tmp/" .. settings.projectName .. "_" .. namespace .. "_Import.lua", "w"), "Error opening file")
	
	p = phrases
	phrases = {}
	
	for k in next, p do -- Can't sort entries by value alone -> insert into temporary table
		table.insert(phrases, k)
	end
	if settings.sortByName then table.sort(phrases) end
	
	-- Write ALL phrases to compare with CF export
	if settings.purgeDuplicateEntries then -- Use the consolidated matches table
	
	if #phrases > 0 then
		for k, v in ipairs(phrases) do 
			ns_cmp_file:write(string.format(settings.localizationTable .. "[\"%s\"] = true\n", v)) -- TODO: squareBrackets setting
		end
	end
	
	else -- Use the scrapeList and iterate over all files (may contain duplicate entries) - TODO: This seems kind of pointless, and it's also slower/takes up more space
	
		for _, file in pairs(scrapeList) do -- Access stored phrases for this file
		
			for k, v in ipairs(phrases) do -- Write phrase to import file
			
				ns_cmp_file:write(string.format(settings.localizationTable .. "[\"%s\"] = true\n", v))
			
			end
		
		end
	
	end
	
	ns_cmp_file:close()
	
end

--- Write import file to desired output location (read from settings) for a given namespace
--@param namespace The namespace to use (TODO: Other namespaces are NYI?)
function Scrapewhale:ExportPhrases(namespace)

	local exportFilePath = settings.startDir .. "/" .. settings.exportFolder .. "/" .. settings.renameTo .. "." .. settings.exportFileType
	print("\nExporting scraped phrases to " .. exportFilePath)
	
	local ns_cmp_file = assert(io.open("tmp/" .. settings.projectName .. "_" .. namespace .. "_Import.lua", "r"), "Error opening file")
	local writeStr = ns_cmp_file:read("*all")
	ns_cmp_file:close()
	
	if file_exists(exportFilePath) then -- Rely on the overwriteMode setting to decide how to handle this
	
		if settings.overwriteMode == "notify" then -- Print and resume
			print("Export file already exists -> Truncating it..")
		end
		
		if settings.overwriteMode == "skip" then -- Don't export anything
			print("Export file already exists -> Skipping export")
		end
		
		if settings.overwriteMode == "ask" then -- Ask user to confirm the export
			print("Export file already exists -> Overwrite (y/n)?")
			local input = io.read()
			if not (input == "y"  or input == "Y" or input == "yes" or input == "ok") then
				
				print("Got it! No writing over things...")
				return
			else
				print("Very good! Truncating it...")
			end
		
		end
		
	end
	
	local exportFile = assert(io.open(exportFilePath, "w"), "Error opening export file: " .. exportFilePath)
	exportFile:write(tostring(settings.prefixString), settings.prefixString ~= "" and "\n\n" or "", writeStr, settings.suffixString ~= "" and "\n\n" or "", tostring(settings.suffixString))
	exportFile:close()	
	
end

--- Starts the parsing process with the given settings
function Scrapewhale:Run() -- Actual script begins here

	print("-------------------------")

	-- Read parameters from CLI and prepare internal storage tables
	Scrapewhale:Init()
print("Checking namespaces for project name: " .. settings.projectName)

-- TODO: Namespaces

	-- Fill scrapeList with entries of files to be parsed
	LFS:ScanDir(settings.startDir, scrapeList, ignoreList) 

	-- Extract data from specified lua files
	for _, namespace in ipairs(namespaces) do
	
		print("Scraping namespace: " .. namespace .. "\n")
		
		-- Write overview (for the user, mainly)
		Scrapewhale:WriteOverviewFile(namespace)
	
		-- Write import file (to include in the addon or use for CurseForge uploads)
		Scrapewhale:WriteImportFile(namespace)
		
		-- All done, yay ^_^ (Print summary) - Well, almost...
		print("\nFinished scraping " .. #scrapeList .. " files for a total of " .. #phrases .. " phrases")
		
		-- Export to Locales/ folder (or elsewhere, I guess) if applicable
		if settings.enableExport then Scrapewhale:ExportPhrases(namespace) end	
	
	end

	print("-------------------------")
	
end

Scrapewhale:Run()

return Scrapewhale