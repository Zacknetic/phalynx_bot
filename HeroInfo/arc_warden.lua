X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Flux = bot:GetAbilityByName("arc_warden_flux")
local MagneticField = bot:GetAbilityByName("arc_warden_magnetic_field")
local SparkWraith = bot:GetAbilityByName("arc_warden_spark_wraith")
local TempestDouble = bot:GetAbilityByName("arc_warden_tempest_double")

local FluxDesire = 0
local MagneticFieldDesire = 0
local SparkWraithDesire = 0
local TempestDoubleDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Flux:GetName())
	table.insert(abilities, MagneticField:GetName())
	table.insert(abilities, SparkWraith:GetName())
	table.insert(abilities, TempestDouble:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[3], -- Level 1
	abilities[1], -- Level 2
	abilities[3], -- Level 3
	abilities[1], -- Level 4
	abilities[3], -- Level 5
	abilities[4], -- Level 6
	abilities[3], -- Level 7
	abilities[1], -- Level 8
	abilities[1], -- Level 9
	talents[1],   -- Level 10
	abilities[2], -- Level 11
	abilities[4], -- Level 12
	abilities[2], -- Level 13
	abilities[2], -- Level 14
	talents[3],   -- Level 15
	abilities[2], -- Level 16
	"NoLevel",    -- Level 17
	abilities[4], -- Level 18
	"NoLevel",    -- Level 19
	talents[5],   -- Level 20
	"NoLevel",    -- Level 21
	"NoLevel",    -- Level 22
	"NoLevel",    -- Level 23
	"NoLevel",    -- Level 24
	talents[7],   -- Level 25
	"NoLevel",    -- Level 26
	talents[2],   -- Level 27
	talents[4],   -- Level 28
	talents[6],   -- Level 29
	talents[8]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_wraith_band",
		"item_hand_of_midas",
		"item_boots",
	
		"item_maelstrom",
		"item_travel_boots",
		"item_gungir",
		"item_octarine_core",
		"item_ultimate_scepter",
		"item_overwhelming_blink",
		"item_black_king_bar",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_wraith_band",
		"item_hand_of_midas",
		"item_boots",
	
		"item_maelstrom",
		"item_travel_boots",
		"item_gungir",
		"item_octarine_core",
		"item_ultimate_scepter",
		"item_overwhelming_blink",
		"item_black_king_bar",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	manathreshold = 100
	manathreshold = manathreshold + Flux:GetManaCost()
	manathreshold = manathreshold + MagneticField:GetManaCost()
	manathreshold = manathreshold + SparkWraith:GetManaCost()
	manathreshold = manathreshold + TempestDouble:GetManaCost()
	
	-- The order to use abilities in
	TempestDoubleDesire = UseTempestDouble()
	if TempestDoubleDesire > 0 then
		bot:Action_UseAbility(TempestDouble)
		return
	end
	
	FluxDesire, FluxTarget = UseFlux()
	if FluxDesire > 0 then
		bot:Action_UseAbilityOnEntity(Flux, FluxTarget)
		return
	end
	
	MagneticFieldDesire, MagneticFieldTarget = UseMagneticField()
	if MagneticFieldDesire > 0 then
		bot:Action_UseAbilityOnLocation(MagneticField, MagneticFieldTarget)
		return
	end
	
	SparkWraithDesire, SparkWraithTarget = UseSparkWraith()
	if SparkWraithDesire > 0 then
		bot:Action_UseAbilityOnLocation(SparkWraith, SparkWraithTarget)
		return
	end
end

function UseFlux()
	if not Flux:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = 0
	local CastPoint = Flux:GetCastPoint()
	
	if P.IsInLaningPhase() then
		CastRange = Flux:GetCastRange() + 100
	else
		CastRange = Flux:GetCastRange() + 500
	end
	
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local filteredenemies = P.FilterEnemiesForStun(enemies)
	local target = nil
	
	for v, enemy in pairs(enemies) do
		if P.IsValidTarget(enemy) and enemy:IsChanneling() and P.IsNotImmune(enemy) then
			target = enemy
			break
		end
	end
	
	if target == nil and #enemies >= 1 then
		if P.IsRetreating(bot) then
			target = P.GetClosestEnemy(bot, enemies)
			
			if target ~= nil then
				if GetUnitToUnitDistance(bot, target) > Flux:GetCastRange() then
					target = nil
				end
			end
		else
			target = P.GetWeakestEnemyHero(enemies)
			
			if target ~= nil and P.IsPDisabled(target) then
				target = P.GetStrongestEnemyHero(filteredenemies)
			end
		end
	end
	
	if target ~= nil and (P.IsInCombativeMode(bot) or P.IsRetreating(bot)) then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

function UseMagneticField()
	if not MagneticField:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = MagneticField:GetCastRange()
	
	local allies = bot:GetNearbyHeroes(CastRange + 100, false, BOT_MODE_NONE)
	local allytarget = P.GetWeakestAllyHero(allies)
	local EnemiesAroundAlly
	
	if allytarget ~= nil then
		EnemiesAroundAlly = allytarget:GetNearbyHeroes(800, true, BOT_MODE_NONE)
	end
	
	if allytarget ~= nil and #EnemiesAroundAlly >= 1 and allytarget:GetHealth() < (allytarget:GetMaxHealth() * 0.4) 
	and not (allytarget:HasModifier("modifier_arc_warden_magnetic_field_evasion") and not allytarget:HasModifier("modifier_arc_warden_magnetic_field_attack_speed")) then
		return BOT_ACTION_DESIRE_HIGH, allytarget:GetLocation()
	end
	
	local enemies = bot:GetNearbyHeroes(AttackRange + 100, true, BOT_MODE_NONE)
	if (P.IsInCombativeMode(bot) and #enemies >= 1) or P.IsRetreating(bot) 
	and not (bot:HasModifier("modifier_arc_warden_magnetic_field_evasion") and not bot:HasModifier("modifier_arc_warden_magnetic_field_attack_speed")) then
		return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
	end
	
	local attacktarget = bot:GetAttackTarget()
	
	if attacktarget ~= nil then
		if attacktarget:IsBuilding()
		and not (bot:HasModifier("modifier_arc_warden_magnetic_field_evasion") and not bot:HasModifier("modifier_arc_warden_magnetic_field_attack_speed")) then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local neutrals = bot:GetNearbyNeutralCreeps(AttackRange)
		
		if #neutrals >= 2 and (bot:GetMana() - MagneticField:GetManaCost()) > manathreshold
		and not (bot:HasModifier("modifier_arc_warden_magnetic_field_evasion") and not bot:HasModifier("modifier_arc_warden_magnetic_field_attack_speed")) then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
		end
	end
	
	return 0
end

function UseSparkWraith()
	if not SparkWraith:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = 1600
	
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if P.IsRetreating(bot) and #enemies >= 1 then
		return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
	end
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target:GetExtrapolatedLocation(2)
	end
	
	return 0
end

function UseTempestDouble()
	if not TempestDouble:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	
	if #enemies >= 1 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

return X