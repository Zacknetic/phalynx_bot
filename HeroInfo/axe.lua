X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local BerserkersCall = bot:GetAbilityByName("axe_berserkers_call")
local BattleHunger = bot:GetAbilityByName("axe_battle_hunger")
local CounterHelix = bot:GetAbilityByName("axe_counter_helix")
local CullingBlade = bot:GetAbilityByName("axe_culling_blade")

local BerserkersCallDesire = 0
local BattleHungerDesire = 0
local CullingBladeDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, BerserkersCall:GetName())
	table.insert(abilities, BattleHunger:GetName())
	table.insert(abilities, CounterHelix:GetName())
	table.insert(abilities, CullingBlade:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[2], -- Level 1
	abilities[3], -- Level 2
	abilities[3], -- Level 3
	abilities[1], -- Level 4
	abilities[3], -- Level 5
	abilities[4], -- Level 6
	abilities[3], -- Level 7
	abilities[1], -- Level 8
	abilities[1], -- Level 9
	talents[1],   -- Level 10
	abilities[1], -- Level 11
	abilities[4], -- Level 12
	abilities[2], -- Level 13
	abilities[2], -- Level 14
	talents[4],   -- Level 15
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
	talents[3],   -- Level 28
	talents[6],   -- Level 29
	talents[8]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_bracer",
		"item_vanguard",
		"item_phase_boots",
		"item_magic_wand",
		
		"item_crimson_guard",
		
		"item_blink",
		"item_blade_mail",
		"item_black_king_bar",
		"item_assault",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	-- The order to use abilities in
	CullingBladeDesire, CullingBladeTarget = UseCullingBlade()
	if CullingBladeDesire > 0 then
		bot:Action_UseAbilityOnEntity(CullingBlade, CullingBladeTarget)
		return
	end
	
	BerserkersCallDesire = UseBerserkersCall()
	if BerserkersCallDesire > 0 then
		bot:Action_UseAbility(BerserkersCall)
		return
	end
	
	BattleHungerDesire, BattleHungerTarget = UseBattleHunger()
	if BattleHungerDesire > 0 then
		bot:Action_UseAbilityOnEntity(BattleHunger, BattleHungerTarget)
		return
	end
end

function UseBerserkersCall()
	if not BerserkersCall:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = BerserkersCall:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(250, true, BOT_MODE_NONE)
	local target = P.GetWeakestNonImmuneEnemyHero(enemies)
	
	if target ~= nil and P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	if target ~= nil and P.IsInCombativeMode(bot) then
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseBattleHunger()
	if not BattleHunger:IsFullyCastable() then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = BattleHunger:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 100, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

function UseCullingBlade()
	if not CullingBlade:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = CullingBlade:GetCastRange()
	local AbilityLevel = CullingBlade:GetLevel()
	local AbilityDamage = 150 + (100 * AbilityLevel)
	
	if bot:GetLevel() >= 20 then
		AbilityDamage = (AbilityDamage + 150)
	end
	
	local enemies = bot:GetNearbyHeroes(300, true, BOT_MODE_NONE)
	
	local LowestHealth = AbilityDamage
	local target = nil
	
	if #enemies > 0 then
		for v, enemy in pairs(enemies) do
			if P.CanCastOnNonImmune(enemy) and not P.IsPossibleIllusion(enemy) then
				if enemy:GetHealth() <= LowestHealth then
					target = enemy
					LowestHealth = enemy:GetHealth()
				end
			end
		end
	end
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

return X