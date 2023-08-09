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

local HellfireBlast = bot:GetAbilityByName("skeleton_king_hellfire_blast")
local VampiricAura = bot:GetAbilityByName("skeleton_king_vampiric_aura")
local MortalStrike = bot:GetAbilityByName("skeleton_king_mortal_strike")
local Reincarnation = bot:GetAbilityByName("skeleton_king_reincarnation")

local HellfireBlastDesire = 0
local VampiricAuraDesire = 0

local AttackRange
local BotTarget
local AttackRange = 0
local ReincarnationMC = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	if Reincarnation:IsTrained() then
		ReincarnationMC = Reincarnation:GetManaCost()
	else
		ReincarnationMC = 0
	end
	
	-- The order to use abilities in
	HellfireBlastDesire, HellfireBlastTarget = UseHellfireBlast()
	if HellfireBlastDesire > 0 then
		bot:Action_UseAbilityOnEntity(HellfireBlast, HellfireBlastTarget)
		return
	end
	
	VampiricAuraDesire = UseVampiricAura()
	if VampiricAuraDesire > 0 then
		bot:Action_UseAbility(VampiricAura)
		return
	end
end

function UseHellfireBlast()
	if not HellfireBlast:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if (bot:GetMana() - HellfireBlast:GetManaCost()) < ReincarnationMC then return 0 end
	
	local CR = HellfireBlast:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget
		end
	end
	
	return 0
end

function UseVampiricAura()
	if not VampiricAura:IsFullyCastable() then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local modifier = bot:GetModifierByName("modifier_skeleton_king_vampiric_aura")
	local skeletoncharges = bot:GetModifierStackCount(modifier)
	local maxcharges = VampiricAura:GetSpecialValueInt("max_skeleton_charges")

	if (bot:GetMana() - VampiricAura:GetManaCost()) > ReincarnationMC and skeletoncharges >= maxcharges then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end