X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Refraction = bot:GetAbilityByName("templar_assassin_refraction")
local Meld = bot:GetAbilityByName("templar_assassin_meld")
local PsiBlades = bot:GetAbilityByName("templar_assassin_psi_blades")
local PsionicTrap = bot:GetAbilityByName("templar_assassin_psionic_trap")

local RefractionDesire = 0
local MeldDesire = 0
local PsionicTrapDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Refraction:GetName())
	table.insert(abilities, Meld:GetName())
	table.insert(abilities, PsiBlades:GetName())
	table.insert(abilities, PsionicTrap:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[1], -- Level 1
	abilities[3], -- Level 2
	abilities[1], -- Level 3
	abilities[3], -- Level 4
	abilities[1], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[2], -- Level 8
	abilities[2], -- Level 9
	talents[2],   -- Level 10
	abilities[2], -- Level 11
	abilities[2], -- Level 12
	abilities[4], -- Level 13
	abilities[3], -- Level 14
	talents[4],   -- Level 15
	abilities[3], -- Level 16
	"NoLevel",    -- Level 17
	abilities[4], -- Level 18
	"NoLevel",    -- Level 19
	talents[5],   -- Level 20
	"NoLevel",    -- Level 21
	"NoLevel",    -- Level 22
	"NoLevel",    -- Level 23
	"NoLevel",    -- Level 24
	talents[8],   -- Level 25
	"NoLevel",    -- Level 26
	talents[1],   -- Level 27
	talents[3],   -- Level 28
	talents[6],   -- Level 29
	talents[7]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		ItemBuild = { 
		"item_wraith_band",
		"item_power_treads",
		
		"item_dragon_lance",
		"item_desolator",
		"item_blink",
		"item_black_king_bar",
		"item_greater_crit",
		"item_swift_blink",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		ItemBuild = { 
		"item_faerie_fire",
	
		"item_wraith_band",
		"item_power_treads",
		
		"item_dragon_lance",
		"item_desolator",
		"item_blink",
		"item_black_king_bar",
		"item_greater_crit",
		"item_swift_blink",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	manathreshold = 100
	manathreshold = manathreshold + Refraction:GetManaCost()
	manathreshold = manathreshold + Meld:GetManaCost()
	manathreshold = manathreshold + PsionicTrap:GetManaCost()
	
	-- The order to use abilities in
	PsionicTrapDesire, PsionicTrapTarget = UsePsionicTrap()
	if PsionicTrapDesire > 0 then
		bot:Action_UseAbilityOnLocation(PsionicTrap, PsionicTrapTarget)
		return
	end
	
	RefractionDesire = UseRefraction()
	if RefractionDesire > 0 then
		bot:Action_UseAbility(Refraction)
		return
	end
	
	MeldDesire = UseMeld()
	if MeldDesire > 0 then
		bot:Action_UseAbility(Meld)
		return
	end
end

function UseRefraction()
	if not Refraction:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if bot:HasModifier("modifier_templar_assassin_meld") then return 0 end
	if bot:HasModifier("modifier_templar_assassin_refraction_absorb") then return 0 end
	
	local enemies = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	
	if (P.IsInCombativeMode(bot) or P.IsRetreating(bot)) and #enemies >= 1 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	local projectiles = bot:GetIncomingTrackingProjectiles()
	
	for v, proj in pairs(projectiles) do
		if GetUnitToLocationDistance(bot, proj.location) <= 300 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if bot:WasRecentlyDamagedByAnyHero(1) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local AttackTarget = bot:GetAttackTarget()
		
		if AttackTarget ~= nil and AttackTarget:IsCreep() and GetUnitToUnitDistance(bot, AttackTarget) < AttackRange and (bot:GetMana() - Refraction:GetManaCost()) > manathreshold then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseMeld()
	if not Meld:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil and AttackTarget:IsHero() and GetUnitToUnitDistance(bot, AttackTarget) < AttackRange then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UsePsionicTrap()
	if not PsionicTrap:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if bot:HasModifier("modifier_templar_assassin_meld") then return 0 end
	
	local CastRange = PsionicTrap:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
	end
	
	return 0
end

return X