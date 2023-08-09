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

local ArcLightning = bot:GetAbilityByName("zuus_arc_lightning")
local LightningBolt = bot:GetAbilityByName("zuus_lightning_bolt")
local HeavenlyJump = bot:GetAbilityByName("zuus_heavenly_jump")
local ThundergodsWrath = bot:GetAbilityByName("zuus_thundergods_wrath")
local Nimbus = bot:GetAbilityByName("zuus_cloud")

local ArcLightningDesire = 0
local LightningBoltDesire = 0
local HeavenlyJumpDesire = 0
local ThundergodsWrathDesire = 0
local NimbusDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	ThundergodsWrathDesire = UseThundergodsWrath()
	if ThundergodsWrathDesire > 0 then
		bot:Action_UseAbility(ThundergodsWrath)
		return
	end
	
	NimbusDesire, NimbusTarget = UseNimbus()
	if NimbusDesire > 0 then
		bot:Action_UseAbilityOnLocation(Nimbus, NimbusTarget)
		return
	end
	
	HeavenlyJumpDesire = UseHeavenlyJump()
	if HeavenlyJumpDesire > 0 then
		bot:Action_UseAbility(HeavenlyJump)
		return
	end
	
	LightningBoltDesire, LightningBoltTarget = UseLightningBolt()
	if LightningBoltDesire > 0 then
		bot:Action_UseAbilityOnEntity(LightningBolt, LightningBoltTarget)
		return
	end
	
	ArcLightningDesire, ArcLightningTarget = UseArcLightning()
	if ArcLightningDesire > 0 then
		bot:Action_UseAbilityOnEntity(ArcLightning, ArcLightningTarget)
		return
	end
end

function UseArcLightning()
	if not ArcLightning:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = ArcLightning:GetCastRange()
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

function UseLightningBolt()
	if not LightningBolt:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = LightningBolt:GetCastRange()
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
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
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

function UseHeavenlyJump()
	if not HeavenlyJump:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = HeavenlyJump:GetSpecialValueInt("range")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseThundergodsWrath()
	if not ThundergodsWrath:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local enemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
	local FilteredEnemies = PAF.FilterUnitsForStun(enemies)
	local Damage = ThundergodsWrath:GetSpecialValueInt("damage")
	local RealDamage = 0
	
	for v, enemy in pairs(FilteredEnemies) do
		RealDamage = enemy:GetActualIncomingDamage(Damage, DAMAGE_TYPE_MAGICAL)
		if enemy:GetHealth() < RealDamage then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseNimbus()
	if not Nimbus:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local Radius = Nimbus:GetSpecialValueInt("cloud_radius")
	local AllyFighting = nil
	
	for v, ally in pairs(allies) do
		if PAF.IsInTeamFight(ally) then
			AllyFighting = ally
		end
	end
	
	if AllyFighting ~= nil then
		local AoE = AllyFighting:FindAoELocation(true, true, AllyFighting:GetLocation(), 1000, Radius/2, 0, 0)
		if (AoE.count >= 2) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
		end
	end
	
	return 0
end