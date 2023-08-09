X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local HellfireBlast = bot:GetAbilityByName("skeleton_king_hellfire_blast")
local VampiricAura = bot:GetAbilityByName("skeleton_king_vampiric_aura")
local MortalStrike = bot:GetAbilityByName("skeleton_king_mortal_strike")
local Reincarnation = bot:GetAbilityByName("skeleton_king_reincarnation")

local HellfireBlastDesire = 0
local VampiricAuraDesire = 0

local AttackRange
local manathreshold
local ReincarnationMC = 0

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, HellfireBlast:GetName())
	table.insert(abilities, VampiricAura:GetName())
	table.insert(abilities, MortalStrike:GetName())
	table.insert(abilities, Reincarnation:GetName())
	
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
	abilities[3], -- Level 3
	abilities[2], -- Level 4
	abilities[2], -- Level 5
	abilities[3], -- Level 6
	abilities[2], -- Level 7
	abilities[4], -- Level 8
	abilities[3], -- Level 9
	talents[2],   -- Level 10
	abilities[3], -- Level 11
	abilities[4], -- Level 12
	abilities[1], -- Level 13
	abilities[1], -- Level 14
	talents[3],   -- Level 15
	abilities[1], -- Level 16
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
	talents[1],   -- Level 27
	talents[4],   -- Level 28
	talents[6],   -- Level 29
	talents[8]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_bracer",
		"item_phase_boots",
		"item_magic_wand",
	
		"item_armlet",
		"item_desolator",
		"item_blink",
		"item_black_king_bar",
		"item_assault",
		"item_abyssal_blade",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	if Reincarnation:IsTrained() then
		ReincarnationMC = Reincarnation:GetManaCost()
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
	
	local CastRange = 0
	
	if P.IsInLaningPhase() then
		CastRange = HellfireBlast:GetCastRange() + 100
	else
		CastRange = HellfireBlast:GetCastRange() + 500
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
				if GetUnitToUnitDistance(bot, target) > HellfireBlast:GetCastRange() then
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

function UseVampiricAura()
	if not VampiricAura:IsFullyCastable() then return 0 end
	if not P.IsInPhalanxTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local modifier = bot:GetModifierByName("modifier_skeleton_king_vampiric_aura")
	local skeletoncharges = bot:GetModifierStackCount(modifier)
	local maxcharges = VampiricAura:GetSpecialValueInt("max_skeleton_charges")

	if (bot:GetMana() - VampiricAura:GetManaCost()) > ReincarnationMC and skeletoncharges >= maxcharges then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

return X