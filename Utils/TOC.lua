-- Basic TOC file reader to extract addon files (and embedded libraries) from the table of contents
-- Adds them to the mock environment, so that they can be used for unit tests

local TOC = {}

-- Read TOC file and load all addon-specific lua and xml files (will extract embeds, but not parse actual XML)
function TOC:Read(path, toc) -- TODO: Split this up into TOC Parser and Lua Loader; TODO: toc is actually the fileName, and path is the filePath

	-- Establish load order and assemble list of all addon files (by reading the TOC file)
	local addonFiles = {}
	local libraries = {}

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

				local xmlFile = assert(io.open(filePath .. line, "r") or io.open(line), "Could not open " .. line)
				local text = xmlFile:read("*all")
				xmlFile:close()
				
				local pattern = "<Script%sfile=\"(.-)\"/>"
				local folder = line:match("(.+)\\.-%.xml") .. "\\"
				
				print("Changed directory: " .. folder)
				print("Detected XML file: " .. line)
				
				for embeddedFile in string.gmatch(text, pattern) do
				
					if line:match("Libs\\") then -- embedded library -> add to Libs
					
						libraries[#libraries+1] = folder .. embeddedFile
						print("Adding embedded file: " .. folder .. embeddedFile .. " (position: " .. #libraries .. ")")
					
					else -- embedded addon file (localization etc) -> add to addonFiles
					
						addonFiles[#addonFiles+1] = folder .. embeddedFile
						print("Adding embedded file: " .. folder .. embeddedFile .. " (position: " .. #addonFiles .. ")")
						
					end
					
				end
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
		G[addonName][#G[addonName]+1] = loadfile(filePath .. fileName)(addonName, T)
		
	end
	--dump(G[addonName])
	print("\nSummary: Added " .. #G[addonName] .. " addon files to the (simulated) global environment\n")

end

--Read TOC
-- readTOC(root .. toc)

return TOC