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

local ViscousNasalGoo = bot:GetAbilityByName("bristleback_viscous_nasal_goo")
local QuillSpray = bot:GetAbilityByName("bristleback_quill_spray")
local Bristleback = bot:GetAbilityByName("bristleback_bristleback")
local Warpath = bot:GetAbilityByName("bristleback_warpath")
local Hairball = bot:GetAbilityByName("bristleback_hairball")

local ViscousNasalGooDesire = 0
local QuillSprayDesire = 0
local HairballDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()

	manathreshold = (bot:GetMaxMana() * 0.4)
	
	-- The order to use abilities in
	HairballDesire, HairballTarget = UseHairball()
	if HairballDesire > 0 then
		bot:Action_UseAbilityOnLocation(Hairball, HairballTarget)
		return
	end
	
	if bot:HasScepter() then
		ViscousNasalGooDesire = UseViscousNasalGoo()
		if ViscousNasalGooDesire > 0 then
			bot:Action_UseAbility(ViscousNasalGoo)
			return
		end
	else
		ViscousNasalGooDesire, ViscousNasalGooTarget = UseViscousNasalGoo()
		if ViscousNasalGooDesire > 0 then
			bot:Action_UseAbilityOnEntity(ViscousNasalGoo, ViscousNasalGooTarget)
			return
		end
	end
	
	QuillSprayDesire = UseQuillSpray()
	if QuillSprayDesire > 0 then
		bot:Action_UseAbility(QuillSpray)
		return
	end
end

function UseViscousNasalGoo()
	if not ViscousNasalGoo:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = ViscousNasalGoo:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if bot:HasScepter() then
				if #FilteredEnemies > 0 then
					return BOT_ACTION_DESIRE_HIGH
				end
			else
				if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
				and not PAF.IsMagicImmune(BotTarget) then
					return BOT_ACTION_DESIRE_HIGH, BotTarget
				end
			end
		end
	end
	
	if bot:HasScepter() and P.IsRetreating(bot) then
		if #FilteredEnemies > 0 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if AttackTarget ~= nil and PAF.IsRoshan(AttackTarget) then
			if bot:HasScepter() then
				return BOT_ACTION_DESIRE_HIGH
			else
				return BOT_ACTION_DESIRE_HIGH, AttackTarget
			end
		end
	end
	
	return 0
end

function UseQuillSpray()
	if not QuillSpray:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = QuillSpray:GetSpecialValueInt("radius")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) or P.IsRetreating(bot) then
		if #FilteredEnemies > 0 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local CreepsWithinRange = bot:GetNearbyCreeps(CastRange, true)
		
		if AttackTarget ~= nil and AttackTarget:IsCreep() then
			if #CreepsWithinRange >= 2 and (bot:GetMana() - QuillSpray:GetManaCost()) > manathreshold then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if AttackTarget ~= nil and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseHairball()
	if not Hairball:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Hairball:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = Hairball:GetSpecialValueInt("radius")
	
	if PAF.IsEngaging(bot) then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
		if (AoE.count >= 1) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
		end
	end
	
	if P.IsRetreating(bot) then
		local EnemiesWithinRange = bot:GetNearbyHeroes(Radius, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
		if #FilteredEnemies > 0 then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
		end
	end
	
	return 0
end