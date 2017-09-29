-- Basic TOC file reader to extract addon files (and embedded libraries) from the table of contents
-- Adds them to the mock environment, so that they can be used for unit tests
-- TODO: Move to libs/utils
local TOC = {}


--. Read XML file and keep reading until no further nested XML files were found
-- This is used to load library dependencies that are not part of the actual addon
-- TODO: Clean up this giant mess (too lazy right now)
function TOC:ParseXML(path, file, addonFiles, libraries, addToPath)

print("Path = " .. path)
print("File = " .. file)
print("Prefix = " .. (addToPath or "<none>"))

	print("Parsing XML file: " .. path .. file)

	local xmlFile = assert(io.open(path .. file, "r") or io.open(file) or io.open((addToPath or "") .. path .. file), "Could not open " .. file)
	local text = xmlFile:read("*all")
	xmlFile:close()
	
	local luaPattern = "<Script%sfile=\"(.-)\"/>"
	local folder = file:match("(.+)\\.-%.xml") .. "\\"
	
	print("Changed directory: " .. folder)
	print("Detected XML file: " .. file)
	
	local xmlPattern = "[^%-]<Include%sfile=\"(.-)\"/>"
	
--	print(); dump(string.match(text, xmlPattern)); print()
	for nestedFile in string.gmatch(text, xmlPattern) do -- Extract XML files to load recursively, as they could contain further .lua files (usually library dependencies)
		print("-----" .. nestedFile)
	--	if not isCommentedOut then -- Isn't commented out and must be added
			print("Recursing to check out nested file: " .. folder .. nestedFile)
			TOC:ParseXML(path .. folder, nestedFile, addonFiles, libraries, folder)
	--	else
	--		print("----- Skipped entry " .. nestedFile .. " because it was commented out")
	--	end
		
	end
	
	for embeddedFile in string.gmatch(text, luaPattern) do -- Extract lua files to load directly (could be addon files, or embedded library files)
	
		if file:match("Libs\\") or addToPath and addToPath:match("Libs\\") then -- embedded library -> add to Libs
		
			libraries[#libraries+1] = (addToPath or "") .. folder .. embeddedFile
			print("Adding embedded file: " .. (addToPath or "") .. folder .. embeddedFile .. " (position: " .. #libraries .. ")")
		
		else -- embedded addon file (localization etc) -> add to addonFiles
		
			addonFiles[#addonFiles+1] = (addToPath or "") .. folder .. embeddedFile
			print("Adding embedded file: " .. (addToPath or "") .. folder .. embeddedFile .. " (position: " .. #addonFiles .. ")")
			
		end
		
	end

end


-- Read TOC file and load all addon-specific lua and xml files (will extract embeds, but not parse actual XML)
function TOC:Read(path, toc) -- TODO: Split this up into TOC Parser and Lua Loader; TODO: toc is actually the fileName, and path is the filePath

	-- Reset files in case another project has been parsed prior to this one
	local addonFiles, libraries = {}, {}

	-- Read TOC file
	print("Opening file: " .. toc .. "\n")
	local filePath = path and (path .. "/") or "\.." -- .. = root/parent folder
	local file = assert(io.open( filePath .. toc, "r") or io.open(toc), "Could not open " .. filePath .. toc)
		
	-- Add files to loading queue
	for line in file:lines() do -- Read line to find .lua files that are to be loaded
		if line ~= "" and not line:match("#") then -- is a valid file (no comment or empty line) -> Add file to loader
			
			if line:match("Libs\\" ) and not line:match("%.xml") then -- is a valid file, but not part of the addon -> Add to libraries (loaded separately, although it doesn't really make a difference)
			
				libraries[#libraries+1] = line
				print("Adding library: " .. line .. " (position: " .. #libraries .. ")")
			
			elseif not line:match("%.xml") then -- .lua file -> add directly
			
				addonFiles[#addonFiles+1] = line
				print("Adding file: " .. line .. " (position: " .. #addonFiles .. ")")
				
			else -- .xml file -> parse and add files that are included instead

				TOC:ParseXML(filePath, line, addonFiles, libraries)
				dump(libraries); dump(addonFiles)
			end
			
		end
	end	
	print("\nA total of " .. #libraries .. " library and " .. #addonFiles .. " addon files were added to the loader after parsing " .. toc)
	file:close()

	 -- Load addon files in order (simulating the client's behaviour)
	G.Libs = {}
	G[addonName] = {}
	
	print("\nLibs:")
	for index, fileName in ipairs(libraries) do -- Attempt to load file 
		
		print(index, #G.Libs, fileName)
		local R = loadfile(filePath .. fileName)(addonName, T)
		G.Libs[#G.Libs+1] = R or {} -- Apparently, most Libs don't adhere to the best practice of returning themselves (as a package)

	end
	--dump(G.Libs)
	print("\nSummary: Added " .. #G.Libs .. " library files to the (simulated) global environment\n")
	
	print("\nAddon files:")
	for index, fileName in ipairs(addonFiles) do -- Attempt to load file 
		
		print(index, #G[addonName], fileName)
		
		local chunk, err = loadfile(filePath .. fileName)
		if err then error(err) 
		else
			
			G[addonName][#G[addonName]+1] = chunk(addonName, T)
		
		end
		
	end
	--dump(G[addonName])
	print("\nSummary: Added " .. #G[addonName] .. " addon files to the (simulated) global environment\n")

end

--Read TOC
-- readTOC(root .. toc)

return TOC