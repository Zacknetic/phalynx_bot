local PPush = {}

local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local PC = require(GetScriptDirectory() ..  "/Library/PhalanxCarries")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

function PPush.GetPushDesire(bot, lane)
	if not P.IsInLaningPhase() then
		--if bot:GetActiveMode() == BOT_MODE_ATTACK then return 0 end
		
		local AssignedLane = bot:GetAssignedLane()
		local LaneFrontAmount = GetLaneFrontAmount(bot:GetTeam(), AssignedLane, true)
	
		local PushTopDesire = GetLaneFrontAmount(bot:GetTeam(), LANE_TOP, false)
		local PushMidDesire = GetLaneFrontAmount(bot:GetTeam(), LANE_MID, false)
		local PushBottomDesire = GetLaneFrontAmount(bot:GetTeam(), LANE_BOT, false)
		
		local MostDesiredLane = LANE_MID
		local HighestDesire = 0
		
		if PushMidDesire > HighestDesire then
			MostDesiredLane = LANE_MID
			HighestDesire = PushMidDesire
		end
		if PushTopDesire > HighestDesire then
			MostDesiredLane = LANE_TOP
			HighestDesire = PushTopDesire
		end
		if PushBottomDesire > HighestDesire then
			MostDesiredLane = LANE_BOT
			HighestDesire = PushBotDesire
		end
		
		if MostDesiredLane == lane then
			return BOT_MODE_DESIRE_MODERATE
		end
	else
		return 0
	end
end

function PPush.PushThink(bot, lane)
	local lanefrontloc = GetLaneFrontLocation(bot:GetTeam(), lane, 0)
	local towertarget = nil
	
	local creeps = bot:GetNearbyLaneCreeps(1000, true)
	local creepfrontdistance = 9999
	if #creeps > 0 then
		creepfrontdistance = GetUnitToLocationDistance(creeps[1], lanefrontloc)
	end
	
	local towers = bot:GetNearbyTowers(700, true)
	local towerfrontdistance = 9999
	if #towers > 0 then
		towerfrontdistance = GetUnitToLocationDistance(towers[1], lanefrontloc)
	end
	
	local barracks = bot:GetNearbyBarracks(1000, true)
	local barracksfrontdistance = 9999
	if #barracks > 0 then
		barracksfrontdistance = GetUnitToLocationDistance(barracks[1], lanefrontloc)
	end
	
	local ancient = GetAncient(GetOpposingTeam())
	local ancientfrontdistance = 9999
	if ancient ~= nil and ancient:CanBeSeen() and not ancient:IsInvulnerable() then
		ancientfrontdistance = GetUnitToLocationDistance(ancient, lanefrontloc)
	end
	
	local fillers = bot:GetNearbyFillers(700, true)
	local fillerfrontdistance = 9999
	if #fillers > 0 then
		fillerfrontdistance = GetUnitToLocationDistance(fillers[1], lanefrontloc)
	end
	
	if bot:WasRecentlyDamagedByTower(1) then
		local allycreeps = bot:GetNearbyLaneCreeps(1600, false)
		if allycreeps[1] ~= nil and towers[1] ~= nil and GetUnitToUnitDistance(allycreeps[1], towers[1]) < 700 then
			bot:Action_AttackUnit(allycreeps[1], false)
		else
			bot:Action_MoveToLocation(lanefrontloc)
		end
	elseif #creeps > 0 and creepfrontdistance <= 1000 then
		bot:Action_AttackUnit(creeps[1], false)
	elseif #towers > 0 and not towers[1]:IsInvulnerable() and towerfrontdistance <= 700 then
		bot:Action_AttackUnit(towers[1], false)
		towertarget = towers[1]:GetAttackTarget()
	elseif #barracks > 0 and not barracks[1]:IsInvulnerable() and barracksfrontdistance <= 1000 then
		bot:Action_AttackUnit(barracks[1], false)
	elseif ancient:CanBeSeen() and not ancient:IsInvulnerable() and ancientfrontdistance <= 1000 then
		bot:Action_AttackUnit(ancient, false)
	elseif #fillers > 0 and not fillers[1]:IsInvulnerable() and fillerfrontdistance <= 1000 then
		bot:Action_AttackUnit(fillers[1], false)
	else
		bot:Action_MoveToLocation(lanefrontloc+RandomVector(500))
	end
end

function GetTeamPushLaneDesire(bot, lane)
	local LaneFrontAmount = GetLaneFrontAmount(GetTeam(), lane, false)
	local HasAdvantage = false
	
	local AliveAllies = 0
	local AliveEnemies = 0
	
	local AllyLevels = 0
	local EnemyLevels = 0

	local IDs = GetTeamPlayers(GetTeam())
	for v, id in pairs(IDs) do
		if IsHeroAlive(id) then
			AliveAllies = AliveAllies + 1
		end
		
		AllyLevels = AllyLevels + GetHeroLevel(id)
	end
	IDs = GetTeamPlayers(GetOpposingTeam())
	for v, id in pairs(IDs) do
		if IsHeroAlive(id) then
			AliveEnemies = AliveEnemies + 1
		end
		
		EnemyLevels = EnemyLevels + GetHeroLevel(id)
	end
	
	if AliveAllies > AliveEnemies then
		HasAdvantage = true
	elseif AliveAllies == AliveEnemies and AllyLevels > EnemyLevels then
		HasAdvantage = true
	end
	
	if HasAdvantage then
		return LaneFrontAmount
	end
	
	return 0
end

function GetFarmAssignedLaneDesire(bot, lane)
	local LaneFrontAmount = GetLaneFrontAmount(GetTeam(), lane, false)
	return (1 - LaneFrontAmount)
end

return PPush