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

local DeathCoil = bot:GetAbilityByName("abaddon_death_coil")
local AphoticShield = bot:GetAbilityByName("abaddon_aphotic_shield")
local Frostmourne = bot:GetAbilityByName("abaddon_frostmourne")
local BorrowedTime = bot:GetAbilityByName("abaddon_borrowed_time")

local DeathCoilDesire = 0
local AphoticShieldDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	AphoticShieldDesire, AphoticShieldTarget = UseAphoticShield()
	if AphoticShieldDesire > 0 then
		bot:Action_UseAbilityOnEntity(AphoticShield, AphoticShieldTarget)
		return
	end
	
	DeathCoilDesire, DeathCoilTarget = UseDeathCoil()
	if DeathCoilDesire > 0 then
		bot:Action_UseAbilityOnEntity(DeathCoil, DeathCoilTarget)
		return
	end
end

function UseDeathCoil()
	if not DeathCoil:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = DeathCoil:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local WeakestAlly = PAF.GetWeakestUnit(FilteredAllies)
	
	if WeakestAlly ~= nil and WeakestAlly ~= bot then
		if WeakestAlly:GetHealth() < (WeakestAlly:GetMaxHealth() * 0.7) then
			return BOT_ACTION_DESIRE_HIGH, WeakestAlly
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and bot:GetHealth() >= (bot:GetMaxHealth() * 0.25) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	return 0
end

function UseAphoticShield()
	if not AphoticShield:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = AphoticShield:GetCastRange()
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local WeakestAlly = PAF.GetWeakestUnit(FilteredAllies)
	
	local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	
	if WeakestAlly ~= nil
	and not WeakestAlly:HasModifier("modifier_abaddon_aphotic_shield")
	and #enemies > 0
	and WeakestAlly:GetHealth() <= (WeakestAlly:GetMaxHealth() * 0.6) then
		return BOT_ACTION_DESIRE_HIGH, WeakestAlly
	end
	
	return 0
end