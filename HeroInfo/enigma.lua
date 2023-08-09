X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Malefice = bot:GetAbilityByName("enigma_malefice")
local DemonicConversion = bot:GetAbilityByName("enigma_demonic_conversion")
local MidnightPulse = bot:GetAbilityByName("enigma_midnight_pulse")
local BlackHole = bot:GetAbilityByName("enigma_black_hole")

local MaleficeDesire = 0
local DemonicConversionDesire = 0
local MidnightPulseDesire = 0
local BlackHoleDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Malefice:GetName())
	table.insert(abilities, DemonicConversion:GetName())
	table.insert(abilities, MidnightPulse:GetName())
	table.insert(abilities, BlackHole:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[2], -- Level 1
	abilities[1], -- Level 2
	abilities[2], -- Level 3
	abilities[1], -- Level 4
	abilities[2], -- Level 5
	abilities[4], -- Level 6
	abilities[2], -- Level 7
	abilities[1], -- Level 8
	abilities[1], -- Level 9
	talents[1],   -- Level 10
	abilities[3], -- Level 11
	abilities[4], -- Level 12
	abilities[3], -- Level 13
	abilities[3], -- Level 14
	talents[3],   -- Level 15
	abilities[3], -- Level 16
	"NoLevel",    -- Level 17
	abilities[4], -- Level 18
	"NoLevel",    -- Level 19
	talents[6],   -- Level 20
	"NoLevel",    -- Level 21
	"NoLevel",    -- Level 22
	"NoLevel",    -- Level 23
	"NoLevel",    -- Level 24
	talents[8],   -- Level 25
	"NoLevel",    -- Level 26
	talents[2],   -- Level 27
	talents[4],   -- Level 28
	talents[5],   -- Level 29
	talents[7]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		ItemBuild = { 
		"item_null_talisman",
		
		"item_arcane_boots",
		"item_magic_wand",
		
		"item_crimson_guard",
		
		"item_blink",
		"item_black_king_bar",
		"item_sphere",
		"item_refresher",
		"item_octarine_core",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	-- The order to use abilities in
	MaleficeDesire, MaleficeTarget = UseMalefice()
	if MaleficeDesire > 0 then
		bot:Action_UseAbilityOnEntity(Malefice, MaleficeTarget)
		return
	end
	
	MidnightPulseDesire, MidnightPulseTarget = UseMidnightPulse()
	if MidnightPulseDesire > 0 then
		bot:Action_UseAbilityOnLocation(MidnightPulse, MidnightPulseTarget)
		return
	end
	
	BlackHoleDesire, BlackHoleTarget = UseBlackHole()
	if BlackHoleDesire > 0 then
		bot:Action_UseAbilityOnLocation(BlackHole, BlackHoleTarget)
		return
	end
	
	DemonicConversionDesire, DemonicConversionTarget = UseDemonicConversion()
	if DemonicConversionDesire > 0 then
		bot:Action_UseAbilityOnEntity(DemonicConversion, DemonicConversionTarget)
		return
	end
end

function UseMalefice()
	if not Malefice:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = 0
	
	if P.IsInLaningPhase() then
		CastRange = Malefice:GetCastRange() + 100
	else
		CastRange = Malefice:GetCastRange() + 500
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
				if GetUnitToUnitDistance(bot, target) > Malefice:GetCastRange() then
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

function UseDemonicConversion()
	if not DemonicConversion:IsFullyCastable() then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = DemonicConversion:GetCastRange()
	local target = nil
	
	if P.IsInLaningPhase(bot) then
		local creeps = bot:GetNearbyCreeps(800, true)
		
		for v, creep in pairs(creeps) do
			if string.find(creep:GetUnitName(), "siege") then
				target = creep
				return BOT_ACTION_DESIRE_HIGH, target
			end
		end
		for v, creep in pairs(creeps) do
			if string.find(creep:GetUnitName(), "flagbearer") then
				target = creep
				return BOT_ACTION_DESIRE_HIGH, target
			end
		end
		for v, creep in pairs(creeps) do
			if string.find(creep:GetUnitName(), "ranged") then
				target = creep
				return BOT_ACTION_DESIRE_HIGH, target
			end
		end
	else
		local lanecreeps = bot:GetNearbyLaneCreeps(800, true)
		
		for v, lanecreep in pairs(lanecreeps) do
			if lanecreep:GetLevel() <= 4 then
				target = lanecreep
				return BOT_ACTION_DESIRE_HIGH, target
			end
		end
		
		if bot:GetActiveMode() == BOT_MODE_FARM then
			local neutralcreeps = bot:GetNearbyNeutralCreeps(AttackRange + 100)
		
			for v, neutralcreep in pairs(neutralcreeps) do
				if neutralcreep:GetLevel() <= 4 then
					target = neutralcreep
					return BOT_ACTION_DESIRE_HIGH, target
				end
			end
		end
	end
	
	return 0
end

function UseMidnightPulse()
	if not MidnightPulse:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = MidnightPulse:GetCastRange()
	local Radius = MidnightPulse:GetSpecialValueInt("radius")
	
	local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
	if (AoE.count >= 2) then
		return BOT_ACTION_DESIRE_HIGH, AoE.targetloc;
	end
	
	return 0
end

function UseBlackHole()
	if not BlackHole:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = AttackRange + 100
	local Radius = BlackHole:GetSpecialValueInt("radius")
	
	local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
	if (AoE.count >= 2) then
		return BOT_ACTION_DESIRE_HIGH, AoE.targetloc;
	end
	
	return 0
end

return X