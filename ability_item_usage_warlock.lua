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

local FatalBonds = bot:GetAbilityByName("warlock_fatal_bonds")
local ShadowWord = bot:GetAbilityByName("warlock_shadow_word")
local Upheaval = bot:GetAbilityByName("warlock_upheaval")
local RainOfChaos = bot:GetAbilityByName("warlock_rain_of_chaos")

local FatalBondsDesire = 0
local ShadowWordDesire = 0
local UpheavalDesire = 0
local RainOfChaosDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	ShadowWordDesire, ShadowWordTarget = UseShadowWord()
	if ShadowWordDesire > 0 then
		bot:Action_UseAbilityOnEntity(ShadowWord, ShadowWordTarget)
		return
	end
	
	FatalBondsDesire, FatalBondsTarget = UseFatalBonds()
	if FatalBondsDesire > 0 then
		bot:Action_UseAbilityOnEntity(FatalBonds, FatalBondsTarget)
		return
	end
	
	RainOfChaosDesire, RainOfChaosTarget = UseRainOfChaos()
	if RainOfChaosDesire > 0 then
		bot:Action_UseAbilityOnLocation(RainOfChaos, RainOfChaosTarget)
		return
	end
	
	UpheavalDesire, UpheavalTarget = UseUpheaval()
	if UpheavalDesire > 0 then
		bot:Action_UseAbilityOnLocation(Upheaval, UpheavalTarget)
		return
	end
end

function UseFatalBonds()
	if not FatalBonds:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = FatalBonds:GetCastRange()
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

function UseShadowWord()
	if not ShadowWord:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = ShadowWord:GetCastRange()
	
	local allies = bot:GetNearbyHeroes(CastRange + 200, false, BOT_MODE_NONE)
	local target = P.GetWeakestAllyHero(allies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	if P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH, bot
	end
	
	return 0
end

function UseUpheaval()
	if not Upheaval:IsFullyCastable() then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Upheaval:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	return 0
end

function UseRainOfChaos()
	if not RainOfChaos:IsFullyCastable() then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Upheaval:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	return 0
end