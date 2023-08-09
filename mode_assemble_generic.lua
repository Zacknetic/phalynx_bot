local bot = GetBot()

local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local allies = {}

function GetDesire()
	--if GetTeam() == TEAM_RADIANT then return 0 end

	local enemies = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	if #enemies > 0 then
		return BOT_MODE_DESIRE_NONE
	end

	if not P.IsInLaningPhase() then	
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" or PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
			return BOT_MODE_DESIRE_LOW
		else
			return BOT_MODE_DESIRE_NONE
		end
	else
		return BOT_MODE_DESIRE_NONE
	end
	
	return BOT_MODE_DESIRE_NONE
end

function Think()
	allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local AlliesToAssembleWith = {}
	
	for v, ally in pairs(allies) do
		if ally:IsAlive() and not P.IsPossibleIllusion(ally) and PRoles.GetPRole(ally, ally:GetUnitName()) ~= "SoftSupport" and PRoles.GetPRole(ally, ally:GetUnitName()) ~= "HardSupport" then
			table.insert(AlliesToAssembleWith, ally)
		end
	end
	
	if #AlliesToAssembleWith > 0 then
		local closestally = nil
		local closestdistance = 99999
	
		for v, ally in pairs(AlliesToAssembleWith) do
			if GetUnitToUnitDistance(bot, ally) < closestdistance then
				closestally = ally
				closestdistance = GetUnitToUnitDistance(bot, ally)
			end
		end
	
		if closestally ~= nil then
			bot:Action_MoveToLocation(closestally:GetLocation()+RandomVector(500))
		end
	else
		bot:Action_MoveToLocation(GetAncient(bot:GetTeam()):GetLocation())
	end
end