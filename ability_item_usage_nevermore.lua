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

local Shadowraze1 = bot:GetAbilityByName("nevermore_shadowraze1")
local Shadowraze2 = bot:GetAbilityByName("nevermore_shadowraze2")
local Shadowraze3 = bot:GetAbilityByName("nevermore_shadowraze3")
local Necromastery = bot:GetAbilityByName("nevermore_necromastery")
local DarkLord = bot:GetAbilityByName("nevermore_dark_lord")
local Requiem = bot:GetAbilityByName("nevermore_requiem")

local Shadowraze1Desire = 0
local Shadowraze2Desire = 0
local Shadowraze3Desire = 0
local RequiemDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = (bot:GetMaxMana() * 0.4)
	
	if Necromastery:IsTrained() and not Necromastery:IsPassive() and Necromastery:GetAutoCastState() == false then
		Necromastery:ToggleAutoCast()
	end
	
	-- The order to use abilities in
	RequiemDesire = UseRequiem()
	if RequiemDesire > 0 then
		bot:Action_UseAbility(Requiem)
		return
	end
	
	Shadowraze1Desire, Shadowraze1Target = UseShadowraze1()
	if Shadowraze1Desire > 0 then
		bot:Action_AttackUnit(Shadowraze1Target, true)
		bot:Action_UseAbility(Shadowraze1)
		return
	end
	
	Shadowraze2Desire, Shadowraze2Target = UseShadowraze2()
	if Shadowraze2Desire > 0 then
		bot:Action_AttackUnit(Shadowraze2Target, true)
		bot:Action_UseAbility(Shadowraze2)
		return
	end
	
	Shadowraze3Desire, Shadowraze3Target = UseShadowraze3()
	if Shadowraze3Desire > 0 then
		bot:Action_AttackUnit(Shadowraze3Target, true)
		bot:Action_UseAbility(Shadowraze3)
		return
	end
end

function UseShadowraze1()
	if not Shadowraze1:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Radius = 250
	local CastRange = 200
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if bot:IsFacingLocation(BotTarget:GetLocation(), 10)
			and GetUnitToUnitDistance(bot, BotTarget) < (CastRange + Radius)
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_VERYHIGH
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if not P.IsInLaningPhase() then
		if AttackTarget ~= nil and AttackTarget:IsCreep() then
			local NearbyCreeps = bot:GetNearbyCreeps((CastRange + Radius), true)
			local AoECount = PAF.GetUnitsNearTarget(AttackTarget:GetLocation(), NearbyCreeps, Radius)
			
			if AoECount >= 3 then
				if bot:IsFacingLocation(AttackTarget:GetLocation(), 10)
				and GetUnitToUnitDistance(bot, AttackTarget) < (CastRange + Radius)
				and (bot:GetMana() - Shadowraze1:GetManaCost()) > manathreshold then
					return BOT_ACTION_DESIRE_VERYHIGH
				end
			end
		end
	elseif P.IsInLaningPhase() then
		if AttackTarget ~= nil and AttackTarget:IsCreep() then
			local NearbyHeroes = bot:GetNearbyHeroes((CastRange + Radius), true, BOT_MODE_NONE)
			local AoECount = PAF.GetUnitsNearTarget(AttackTarget:GetLocation(), NearbyHeroes, Radius)
			
			if AoECount >= 1 then
				if bot:IsFacingLocation(AttackTarget:GetLocation(), 10)
				and GetUnitToUnitDistance(bot, AttackTarget) < (CastRange + Radius) then
					return BOT_ACTION_DESIRE_VERYHIGH
				end
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget) then
			if bot:IsFacingLocation(AttackTarget:GetLocation(), 10)
			and GetUnitToUnitDistance(bot, AttackTarget) < (CastRange + Radius) then
				return BOT_ACTION_DESIRE_VERYHIGH
			end
		end
	end
	
	return 0
end

function UseShadowraze2()
	if not Shadowraze2:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Radius = 250
	local CastRange = 450
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if bot:IsFacingLocation(BotTarget:GetLocation(), 10)
			and GetUnitToUnitDistance(bot, BotTarget) > (CastRange - Radius)
			and GetUnitToUnitDistance(bot, BotTarget) < (CastRange + Radius)
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_VERYHIGH
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if not P.IsInLaningPhase() then
		if AttackTarget ~= nil and AttackTarget:IsCreep() then
			local NearbyCreeps = bot:GetNearbyCreeps((CastRange + Radius), true)
			local AoECount = PAF.GetUnitsNearTarget(AttackTarget:GetLocation(), NearbyCreeps, Radius)
			
			if AoECount >= 3 then
				if bot:IsFacingLocation(AttackTarget:GetLocation(), 10)
				and GetUnitToUnitDistance(bot, AttackTarget) > (CastRange - Radius)
				and GetUnitToUnitDistance(bot, AttackTarget) < (CastRange + Radius)
				and (bot:GetMana() - Shadowraze2:GetManaCost()) > manathreshold then
					return BOT_ACTION_DESIRE_VERYHIGH
				end
			end
		end
	elseif P.IsInLaningPhase() then
		if AttackTarget ~= nil and AttackTarget:IsCreep() then
			local NearbyHeroes = bot:GetNearbyHeroes((CastRange + Radius), true, BOT_MODE_NONE)
			local AoECount = PAF.GetUnitsNearTarget(AttackTarget:GetLocation(), NearbyHeroes, Radius)
			
			if AoECount >= 1 then
				if bot:IsFacingLocation(AttackTarget:GetLocation(), 10)
				and GetUnitToUnitDistance(bot, AttackTarget) > (CastRange - Radius)
				and GetUnitToUnitDistance(bot, AttackTarget) < (CastRange + Radius) then
					return BOT_ACTION_DESIRE_VERYHIGH
				end
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget) then
			if bot:IsFacingLocation(AttackTarget:GetLocation(), 10)
			and GetUnitToUnitDistance(bot, AttackTarget) > (CastRange - Radius)
			and GetUnitToUnitDistance(bot, AttackTarget) < (CastRange + Radius) then
				return BOT_ACTION_DESIRE_VERYHIGH
			end
		end
	end
	
	return 0
end

function UseShadowraze3()
	if not Shadowraze3:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Radius = 250
	local CastRange = 700
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if bot:IsFacingLocation(BotTarget:GetLocation(), 10)
			and GetUnitToUnitDistance(bot, BotTarget) > (CastRange - Radius)
			and GetUnitToUnitDistance(bot, BotTarget) < (CastRange + Radius)
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_VERYHIGH
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if not P.IsInLaningPhase() then
		if AttackTarget ~= nil and AttackTarget:IsCreep() then
			local NearbyCreeps = bot:GetNearbyCreeps((CastRange + Radius), true)
			local AoECount = PAF.GetUnitsNearTarget(AttackTarget:GetLocation(), NearbyCreeps, Radius)
			
			if AoECount >= 3 then
				if bot:IsFacingLocation(AttackTarget:GetLocation(), 10)
				and GetUnitToUnitDistance(bot, AttackTarget) > (CastRange - Radius)
				and GetUnitToUnitDistance(bot, AttackTarget) < (CastRange + Radius)
				and (bot:GetMana() - Shadowraze3:GetManaCost()) > manathreshold then
					return BOT_ACTION_DESIRE_VERYHIGH
				end
			end
		end
	elseif P.IsInLaningPhase() then
		if AttackTarget ~= nil and AttackTarget:IsCreep() then
			local NearbyHeroes = bot:GetNearbyHeroes((CastRange + Radius), true, BOT_MODE_NONE)
			local AoECount = PAF.GetUnitsNearTarget(AttackTarget:GetLocation(), NearbyHeroes, Radius)
			
			if AoECount >= 1 then
				if bot:IsFacingLocation(AttackTarget:GetLocation(), 10)
				and GetUnitToUnitDistance(bot, AttackTarget) > (CastRange - Radius)
				and GetUnitToUnitDistance(bot, AttackTarget) < (CastRange + Radius) then
					return BOT_ACTION_DESIRE_VERYHIGH
				end
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget) then
			if bot:IsFacingLocation(AttackTarget:GetLocation(), 10)
			and GetUnitToUnitDistance(bot, AttackTarget) > (CastRange - Radius)
			and GetUnitToUnitDistance(bot, AttackTarget) < (CastRange + Radius) then
				return BOT_ACTION_DESIRE_VERYHIGH
			end
		end
	end
	
	return 0
end

function UseRequiem()
	if not Requiem:IsFullyCastable() then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Requiem:GetSpecialValueInt("requiem_radius")
	local MaxSouls = Necromastery:GetSpecialValueInt("necromastery_max_souls")
	local Souls = bot:GetModifierStackCount(bot:GetModifierByName("modifier_nevermore_necromastery"))
	
	local enemies = bot:GetNearbyHeroes((CastRange - 200), true, BOT_MODE_NONE)
	local trueenemies = PAF.FilterUnitsForStun(enemies)
	
	if #trueenemies > 1 and (Souls >= (MaxSouls * 0.5)) and not P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end