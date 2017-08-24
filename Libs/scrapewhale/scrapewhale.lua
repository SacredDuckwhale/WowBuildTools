-- ScrapeWhale.lua
-- Scraper for localized strings
-- Initially based on the WeakAuras 2 "babelfish" scraper, which was a great idea even though it didn't do things in the same way (Windows... :P)
--
-- TODO: Auto upload to CF via GET/API
-- TODO: What about the TOC namespace? (might as well leave that be for now)
-- -----

require 'lfs' -- LuaFileSystem

local Scrapewhale = {}

local defaults = {}


-- Parser settings (defaults)
defaults.startDir = ".." -- start scraping here
defaults.useSquareBrackets = true -- TODO
defaults.localizationTable = "L" -- TODO

-- Export settings (defaults)
defaults.enableExport = true
defaults.exportFolder = "Locales/"  -- relative to startDir
defaults.renameTo = "enGB.lua" -- Careful: Will overwrite stuff without asking (TODO: config option to save a copy?)
defaults.exportFileType = "lua"
defaults.sortByName = true
defaults.groupByFile = true
defaults.purgeDuplicateEntries = false -- TODO
defaults.prefixString = [[local L = LibStub("AceLocale-3.0"):NewLocale("TotalAP", "enGB", true)]]
defaults.suffixString = ""

defaults.ignoredFolders = {}

-- Read CLI args and extract settings (overwrites the default values above)
local args = { ... }
dump(args)
if #args > 0 then -- Validate arguments and discard unusable ones

	local param, value
	print("Detected " .. #args .. " arguments")
	for index, arg in pairs(args) do -- Compare arg against defaults table structure
	
		param, value = arg:match("^-([^%s]+)%s?(.*)$")
		print(param, value)
		-- Split key and value pairs if any are found
	
		print("Checking arg " .. index .. ": \"" .. tostring(arg) .. "\"")
		if defaults[param] ~= nil then -- Is a valid entry -> Use this setting instead of the default value
		
			defaults[param] = value ~= "" and value or true -- Set boolean keys to true, as only enabling parameters are valid (-enableStuff sets defaults.enableStuff = true - if it was false, there'd be no point)
			print("Argument " .. index .. " with value = \"" .. tostring(defaults[param]) .. "\" will be used")
			
		else -- use default value
		
			--print("Ignoring arg " .. index .. " because it was invalid")
			
		end
	end
	
end


-- CurseForge namespaces (if several are to be used)
local namespaces = {
    "Base",
}

-- Folders that should not be scraped
local ignoredFolders = {
	"_DEV/",
	"Libs/",
	"Locales/",
}
ignoredFolders = defaults.ignoredFolders -- TODO

-- Prefix to all files if this script is run from a subdir, for example
local filePrefix = defaults.startDir .. "/" -- TODO


local ignoreList = {} -- Folders that are to be ignored
local scrapeList = {} -- Files that will be scraped
local phrases = {} -- Which phrases will be exported


 -- Mark folders as "ignored" and build the "ignore list"
 for key, value in ipairs(ignoredFolders) do
	--print(key, value)
	ignoreList[value] = true
end

-- Workaround because Lua patterns can't do | (regexp syntax) and I'm not installing a separate library just for this
local function MatchesIgnorelistEntry(str)
	--	print(str)
	for k, v in pairs(ignoreList) do
	--	print("Test for match of str " .. str .. " with k =  " .. k)
		if string.find(str, k) then return true end
	end
	
	return false
end

-- Recursive filesystem navigation via LFS to find all Lua files that could be scraped
local function ScanDir(path)
	
	    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path..'/'..file
	
			if string.match(file, ".lua$") and not MatchesIgnorelistEntry(f) then -- Is a valid file for scraping
				--print ("\tAdding file to the scrape list: "..f)
				table.insert(scrapeList, f)
			else
				--print("Ignored file (not a .lua file): " .. file)
			end

            local attr = lfs.attributes (f)
            assert (type(attr) == "table")
            if attr.mode == "directory" then -- Down the rabbit hole we go
                ScanDir (f)
            end
        end
    end
end

-- Orig. WA2 // Parse file and add localized phrases that were found in them
local function parseFile(filename)
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


function Scrapewhale:Run(config)
	print("scrapewhale.Run is being executed")
end

function Scrapewhale:ScanTemp() -- Actual script begins here
	print("scrapewhale is running in testing mode")
	if true then return end
	
	ScanDir(startDir) -- Fill scrapeList with entries of files to be parsed
	
	-- extract data from specified lua files
	for _, namespace in ipairs(namespaces) do
		print("\nNamespace: " .. namespace)
		local ns_file = assert(io.open(namespace .. "_Overview.lua", "w"), "Error opening file")
		

		for _, file in ipairs(scrapeList) do  -- Check for .lua files in this directory
			
			print("\nParsing file: " .. file)
			
			local strings = parseFile(file)

			local sorted = {}
			for k in next, strings do
				table.insert(sorted, k)
			end
			table.sort(sorted)
			
			if #sorted > 0 then -- Write entry for this file
				ns_file:write(string.format("-- %s (%d phrases)\n", string.gsub(file, "", ""), #sorted))
				for _, v in ipairs(sorted) do
					--print("Writing file, set for index " .. v .. " = true")
					ns_file:write(string.format("L[\"%s\"] = true\n", v))
				end
				ns_file:write("\n")
			end
			print("  (" .. #sorted .. ") " .. file)
		end
		ns_file:close()
		
		-- Write summary (to be imported by CF)
		local ns_cmp_file = assert(io.open(namespace .. "_Import.lua", "w"), "Error opening file")
		
		p = phrases
		phrases = {}
		
		for k in next, p do -- Can't sort entries by value alone -> insert into temporary table
			table.insert(phrases, k)
		end
		table.sort(phrases)
		
		-- Write ALL phrases to compare with CF export
		if #phrases > 0 then
			for k, v in ipairs(phrases) do 
				ns_cmp_file:write(string.format("L[\"%s\"] = true\n", v))
			end
		end
		
		-- All done, yay ^_^ (Print summary) - Well, almost...
		print("\nFinished scraping " .. #scrapeList .. " files for a total of " .. #phrases .. " phrases")
		
		-- Export to Locales/ folder (or elsewhere, I guess)
		if enableExport then 
			local exportFilePath = startDir .. "/" .. exportFolder .. "/" .. renameTo
			print("\nExporting scraped phrases to " .. exportFilePath)
			ns_cmp_file:close()
			local ns_cmp_file = assert(io.open(namespace .. "_Import.lua", "r"), "Error opening file")
			local writeStr = ns_cmp_file:read("*all")
		
			local exportFile = assert(io.open(exportFilePath, "w"), "Error opening file")
			exportFile:write(prefixString, "\n\n", writeStr)
			exportFile:close()	
		end		
	end
end


return Scrapewhale