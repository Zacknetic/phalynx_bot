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

local OverwhelmingOdds = bot:GetAbilityByName("legion_commander_overwhelming_odds")
local PressTheAttack = bot:GetAbilityByName("legion_commander_press_the_attack")
local MomentOfCourage = bot:GetAbilityByName("legion_commander_moment_of_courage")
local Duel = bot:GetAbilityByName("legion_commander_duel")

local OverwhelmingOddsDesire = 0
local PressTheAttackDesire = 0
local DuelDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	OverwhelmingOddsDesire = UseOverwhelmingOdds()
	if OverwhelmingOddsDesire > 0 then
		bot:Action_UseAbility(OverwhelmingOdds)
		return
	end
	
	PressTheAttackDesire, PressTheAttackTarget = UsePressTheAttack()
	if PressTheAttackDesire > 0 then
		bot:Action_UseAbilityOnEntity(PressTheAttack, PressTheAttackTarget)
		return
	end
	
	DuelDesire, DuelTarget = UseDuel()
	if DuelDesire > 0 then
		bot:Action_UseAbilityOnEntity(Duel, DuelTarget)
		return
	end
end

function UseOverwhelmingOdds()
	if not OverwhelmingOdds:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = OverwhelmingOdds:GetSpecialValueInt("radius")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	if P.IsRetreating(bot) then
		if #FilteredEnemies > 0 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH
		end
	end
	
	return 0
end

function UsePressTheAttack()
	if not PressTheAttack:IsFullyCastable() then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local enemies = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	
	if #enemies >= 1 and (PAF.IsEngaging(bot) or P.IsRetreating(bot)) then
		return BOT_ACTION_DESIRE_HIGH, bot
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_VERYHIGH
		end
	end
	
	return 0
end

function UseDuel()
	if not Duel:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Duel:GetCastRange() + 600
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	
	for v, enemy in pairs(EnemiesWithinRange) do
		if PAF.IsValidHeroAndNotIllusion(enemy) then
			if enemy:GetHealth() < (enemy:GetMaxHealth() * 0.5) then
				return BOT_ACTION_DESIRE_HIGH, enemy
			end
		end
	end
	
	return 0
end