local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

function UpdatePushLaneDesires()
	if P.IsInLaningPhase() then return {0,0,0} end
	
	local PushTopDesire = 0
	local PushMidDesire = 0
	local PushBottomDesire = 0
	
	local TopFrontAmount = GetLaneFrontAmount(GetTeam(), LANE_TOP, false)
	local MidFrontAmount = GetLaneFrontAmount(GetTeam(), LANE_MID, false)
	local BottomFrontAmount = GetLaneFrontAmount(GetTeam(), LANE_BOT, false)
	
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
	
	if AllyLevels > EnemyLevels then
		HasAdvantage = true
	else
		if AliveAllies > AliveEnemies then
			HasAdvantage = true
		end
	end
	
	if HasAdvantage then
		PushTopDesire = Clamp(TopFrontAmount, BOT_MODE_DESIRE_NONE, BOT_MODE_DESIRE_HIGH)
		PushMidDesire = Clamp(MidFrontAmount, BOT_MODE_DESIRE_NONE, BOT_MODE_DESIRE_HIGH)
		PushBotDesire = Clamp(BottomFrontAmount, BOT_MODE_DESIRE_NONE, BOT_MODE_DESIRE_HIGH)
	end
	
	return {TopFrontAmount, MidFrontAmount, BottomFrontAmount}
end

function UpdateFarmLaneDesires()
	if P.IsInLaningPhase() then return {0,0,0} end

	local FarmTopDesire = 0
	local FarmMidDesire = 0
	local FarmBottomDesire = 0

	local TopFrontAmount = GetLaneFrontAmount(GetTeam(), LANE_TOP, false)
	local MidFrontAmount = GetLaneFrontAmount(GetTeam(), LANE_MID, false)
	local BottomFrontAmount = GetLaneFrontAmount(GetTeam(), LANE_BOT, false)
	
	FarmTopDesire = Clamp((1 - TopFrontAmount), BOT_MODE_DESIRE_NONE, BOT_MODE_DESIRE_HIGH)
	FarmMidDesire = Clamp((1 - MidFrontAmount), BOT_MODE_DESIRE_NONE, BOT_MODE_DESIRE_HIGH)
	FarmBottomDesire = Clamp((1 - BottomFrontAmount), BOT_MODE_DESIRE_NONE, BOT_MODE_DESIRE_HIGH)
	
	return {(1 - TopFrontAmount), (1 - MidFrontAmount), (1 - BottomFrontAmount)}
end
