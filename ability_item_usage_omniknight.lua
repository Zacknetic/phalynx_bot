------------------------------
-- CREATED BY: MANSLAUGHTER --
------------------------------

local bot = GetBot()
if bot:IsInvulnerable() or not bot:IsHero() or bot:IsIllusion() then return end

local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end
function ItemUsageThink()
	ability_item_usage_generic.ItemUsageThink();
end

local Purification = bot:GetAbilityByName("omniknight_purification")
local HeavenlyGrace = bot:GetAbilityByName("omniknight_martyr")
local HammerOfPurity = bot:GetAbilityByName("omniknight_hammer_of_purity")
local GuardianAngel = bot:GetAbilityByName("omniknight_guardian_angel")

local PurificationDesire = 0
local HeavenlyGraceDesire = 0
local HammerOfPurityDesire = 0
local GuardianAngelDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	GuardianAngelDesire = UseGuardianAngel()
	if GuardianAngelDesire > 0 then
		bot:Action_UseAbility(GuardianAngel)
		return
	end
	
	HeavenlyGraceDesire, HeavenlyGraceTarget = UseHeavenlyGrace()
	if HeavenlyGraceDesire > 0 then
		bot:Action_UseAbilityOnEntity(HeavenlyGrace, HeavenlyGraceTarget)
		return
	end
	
	PurificationDesire, PurificationTarget = UsePurification()
	if PurificationDesire > 0 then
		bot:Action_UseAbilityOnEntity(Purification, PurificationTarget)
		return
	end
	
	HammerOfPurityDesire, HammerOfPurityTarget = UseHammerOfPurity()
	if HammerOfPurityDesire > 0 then
		bot:Action_UseAbilityOnEntity(HammerOfPurity, HammerOfPurityTarget)
		return
	end
end

function UsePurification()
	if not Purification:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Purification:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local allies = {}
	
	if target ~= nil then
		allies = target:GetNearbyHeroes(260, true, BOT_MODE_NONE)
	end
	
	local closestally = nil
	local closestdistance = 9999
	
	for v, ally in pairs(allies) do
		if GetUnitToUnitDistance(ally, target) < closestdistance then
			closestdistance = GetUnitToUnitDistance(ally, target)
			closestally = ally
		end
	end
	
	if closestally ~= nil then
		return BOT_ACTION_DESIRE_HIGH, closestally
	end
	
	
	local allies = bot:GetNearbyHeroes(CastRange + 200, false, BOT_MODE_NONE)
	target = P.GetWeakestAllyHero(allies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

function UseHeavenlyGrace()
	if not HeavenlyGrace:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = HeavenlyGrace:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local allies = bot:GetNearbyHeroes(CastRange + 200, false, BOT_MODE_NONE)
	target = P.GetWeakestAllyHero(allies)
	
	if target ~= nil and target ~= bot then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	if P.IsRetreating(bot) then
		local nearbyallies = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
		
		if #nearbyallies >= 1 then
			return BOT_ACTION_DESIRE_HIGH, nearbyallies[1]
		else
			return BOT_ACTION_DESIRE_HIGH, bot
		end
	end
	
	return 0
end

function UseHammerOfPurity()
	if not HammerOfPurity:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = HammerOfPurity:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	return 0
end

function UseGuardianAngel()
	if not GuardianAngel:IsFullyCastable() then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	return BOT_ACTION_DESIRE_HIGH
end