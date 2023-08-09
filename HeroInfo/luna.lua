X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local LucentBeam = bot:GetAbilityByName("luna_lucent_beam")
local MoonGlaives = bot:GetAbilityByName("luna_moon_glaive")
local LunarBlessing = bot:GetAbilityByName("luna_lunar_blessing")
local Eclipse = bot:GetAbilityByName("luna_eclipse")

local LucentBeamDesire = 0
local EclipseDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, LucentBeam:GetName())
	table.insert(abilities, MoonGlaives:GetName())
	table.insert(abilities, LunarBlessing:GetName())
	table.insert(abilities, Eclipse:GetName())
	
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
	abilities[2], -- Level 4
	abilities[3], -- Level 5
	abilities[4], -- Level 6
	abilities[3], -- Level 7
	abilities[2], -- Level 8
	abilities[2], -- Level 9
	talents[1],   -- Level 10
	abilities[2], -- Level 11
	abilities[4], -- Level 12
	abilities[1], -- Level 13
	abilities[1], -- Level 14
	talents[4],   -- Level 15
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
	talents[2],   -- Level 27
	talents[3],   -- Level 28
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
	
		"item_wraith_band",
		"item_power_treads",
		"item_mask_of_madness",
	
		"item_dragon_lance",
		"item_manta",
		"item_black_king_bar",
		"item_greater_crit",
		"item_satanic",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	manathreshold = 100
	manathreshold = manathreshold + LucentBeam:GetManaCost()
	manathreshold = manathreshold + Eclipse:GetManaCost()
	
	-- The order to use abilities in
	EclipseDesire,EclipseTarget = UseEclipse()
	if EclipseDesire > 0 then
		bot:Action_UseAbility(Eclipse)
		return
	end
	
	LucentBeamDesire, LucentBeamTarget = UseLucentBeam()
	if LucentBeamDesire > 0 then
		bot:Action_UseAbilityOnEntity(LucentBeam, LucentBeamTarget)
		return
	end
end

function UseLucentBeam()
	if not LucentBeam:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = 0
	
	if P.IsInLaningPhase() then
		CastRange = LucentBeam:GetCastRange() + 100
	else
		CastRange = LucentBeam:GetCastRange() + 500
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
				if GetUnitToUnitDistance(bot, target) > LucentBeam:GetCastRange() then
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
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local neutrals = bot:GetNearbyNeutralCreeps(CastRange)
		
		if #neutrals >= 2 and (bot:GetMana() - LucentBeam:GetManaCost()) > manathreshold then
			local weakestneutral = nil
			local smallesthealth = 99999
		
			for v, neutral in pairs(neutrals) do
				if neutral ~= nil and neutral:CanBeSeen() then
					if neutral:GetHealth() < smallesthealth then
						weakestneutral = neutral
						smallesthealth = neutral:GetHealth()
					end
				end
			end
		
			return BOT_ACTION_DESIRE_HIGH, weakestneutral
		end
	end
	
	return 0
end

function UseEclipse()
	if not Eclipse:IsFullyCastable() then return 0 end
	if not P.IsInPhalanxTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Radius = Eclipse:GetSpecialValueInt("radius")
	local enemies = bot:GetNearbyHeroes(Radius, true, BOT_MODE_NONE)
	
	if #enemies >= 2 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

return X