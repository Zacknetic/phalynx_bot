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

local MeatHook = bot:GetAbilityByName("pudge_meat_hook")
local Rot = bot:GetAbilityByName("pudge_rot")
local FleshHeap = bot:GetAbilityByName("pudge_flesh_heap")
local Dismember = bot:GetAbilityByName("pudge_dismember")

local MeatHookDesire = 0
local RotDesire = 0
local FleshHeapDesire = 0
local DismemberDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	MeatHookDesire, MeatHookTarget = UseMeatHook()
	if MeatHookDesire > 0 then
		bot:Action_UseAbilityOnLocation(MeatHook, MeatHookTarget)
		return
	end
	
	DismemberDesire, DismemberTarget = UseDismember()
	if DismemberDesire > 0 then
		bot:Action_UseAbilityOnEntity(Dismember, DismemberTarget)
		return
	end
	
	RotDesire = UseRot()
	if RotDesire > 0 then
		bot:Action_UseAbility(Rot)
		return
	end
	
	FleshHeapDesire = UseFleshHeap()
	if FleshHeapDesire > 0 then
		bot:Action_UseAbility(FleshHeap)
		return
	end
end

function UseMeatHook()
	if not MeatHook:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = MeatHook:GetCastRange()
	local CastPoint = MeatHook:GetCastPoint()
	local Radius = MeatHook:GetSpecialValueInt('hook_width') - 50
	local Speed = MeatHook:GetSpecialValueInt('hook_speed')
	
	if BotTarget ~= nil and PAF.IsEngaging(bot) then
		local MovementStability = BotTarget:GetMovementDirectionStability()
		local PredictedLoc = BotTarget:GetExtrapolatedLocation(CastPoint + (GetUnitToUnitDistance(bot, BotTarget) / Speed))
		
		if MovementStability < 0.6 then
			PredictedLoc = BotTarget:GetLocation()
		end
		
		if not P.IsHeroBetweenMeAndTarget(bot, BotTarget, PredictedLoc, Radius) and not P.IsCreepBetweenMeAndTarget(bot, BotTarget, PredictedLoc, Radius) then
			return BOT_ACTION_DESIRE_HIGH, PredictedLoc
		end
	end
	
	return 0
end

function UseRot()
	if not Rot:IsFullyCastable() then return 0 end
	if bot:IsSilenced() or bot:IsHexed() or bot:HasModifier("modifier_doom_bringer_doom") then return 0 end
	
	local CastRange = (Rot:GetSpecialValueInt('rot_radius') + 50)
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				if Rot:GetToggleState() == false then
					return BOT_ACTION_DESIRE_HIGH
				else
					return 0
				end
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if bot:GetActiveMode() == BOT_MODE_FARM and AttackTarget:IsCreep() then
			if GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
				if Rot:GetToggleState() == false then
					return BOT_ACTION_DESIRE_HIGH
				else
					return 0
				end
			end
		end
	end
	
	if P.IsRetreating(bot) then
		if Rot:GetToggleState() == true then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if Rot:GetToggleState() == true then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseFleshHeap()
	if not FleshHeap:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if Rot:GetToggleState() == true then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if P.IsRetreating(bot) and (#FilteredEnemies >= 1 or bot:WasRecentlyDamagedByAnyHero(2)) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseDismember()
	if not Dismember:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = (Dismember:GetCastRange() + 100)
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	return 0
end