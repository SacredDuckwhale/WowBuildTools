-- WOW UI functions
CreateFrame = function(frameType, frameName, parentFrameReference, inheritsFrame, id)

	local Frame = { -- TODO: Would prefer to use actual UI code, but can't find it? :| Libs should work regardless... but still
		frameType = frameType,
		frameName = frameName,
		parentFrame = parentFrameReference,
		inheritsFrame = inheritsFrame,
		id = id
	}
	
	function Frame:RegisterEvent(eventName)
	
	end
	
	function Frame:SetScript(event)

	end

	return Frame

end



-- WOW API functions
GetAddOnMetadata = function(addon, value)
	
	if addon == addonName then
		return "1.3.1 (r-23)"
	end
	
end

GetLocale = function()

	return locale or "enUS"
	
end

GetRealmName = function()

	return realm or "Outland"

end

GetCurrentRegion = function()

	local regions = { US = 1, KR = 2, EU = 3, TW = 4, CN = 5 } -- Reverse LUT
	return regions[region or "EU"]
	
end

UnitName = function(unit)

	if unit == "player" then
		
		return "Duckwhale"
		
	end	

end

UnitClass = function(unit)

	if unit == "player" then
		
		local classDisplayName, class, classID = "Rogue", "ROGUE", 4
		return classDisplayName, class, classID
		
	end	

end

UnitRace = function(unit)

	if unit == "player" then
		
		local raceName, raceId = "Human", "Human"
		return raceName, raceId 
		
	end	

end

UnitFactionGroup = function(unit)

	if unit == "player" then
	
		englishFaction, localizedFaction = "Alliance", "Alliance"
		return englishFaction, localizedFaction
		
	end	

end

GetNumSpecializations = function()

	return 3
	
end

GetSpecialization = function()

	return 1
	
end

IsQuestFlaggedCompleted = function(questID)

	--print("Called IsQuestFlaggedCompleted with questID " .. tostring(questID))
	if questID == 24545 then return true end -- "The Sacred and the Corrupt (for testing purposes only)
	return false

end

GetAchievementInfo = function(achievementOrCategoryID, index)

	local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy 

	local _
	
	return 0, "AchievementName", 0, false, nil, nil, nil, "AchievementDescription", 0x00, "IconPath", "RewardText", false, false, nil 
	
end

GetBuildInfo = function()
	
	-- Taken from the actual 7.3 client (not that it matters for testing whether or not this info is outdated...)
	version = "7.3.0"
	build = "24974"
	date = "Sep 5 2017"
	tocversion = 70300

	return version, build, date, tocversion
	
end

-- WOW API objects
GameTooltip = {}
function GameTooltip:HookScript(triggerEvent, scriptFunction)

end

-- Aliased Lua functions
time = os.time