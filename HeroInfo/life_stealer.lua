X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Rage = bot:GetAbilityByName("life_stealer_rage")
local Feast = bot:GetAbilityByName("life_stealer_feast")
local GhoulFrenzy = bot:GetAbilityByName("life_stealer_ghoul_frenzy")
local Infest = bot:GetAbilityByName("life_stealer_infest")
local Consume = bot:GetAbilityByName("life_stealer_consume")
local OpenWounds = bot:GetAbilityByName("life_stealer_open_wounds")

local RageDesire = 0
local InfestDire = 0
local ConsumeDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Rage:GetName())
	table.insert(abilities, Feast:GetName())
	table.insert(abilities, GhoulFrenzy:GetName())
	table.insert(abilities, Infest:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[3], -- Level 1
	abilities[2], -- Level 2
	abilities[3], -- Level 3
	abilities[1], -- Level 4
	abilities[3], -- Level 5
	abilities[4], -- Level 6
	abilities[3], -- Level 7
	abilities[2], -- Level 8
	abilities[1], -- Level 9
	talents[2],   -- Level 10
	abilities[1], -- Level 11
	abilities[4], -- Level 12
	abilities[1], -- Level 13
	abilities[2], -- Level 14
	talents[3],   -- Level 15
	abilities[2], -- Level 16
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
	talents[1],   -- Level 27
	talents[4],   -- Level 28
	talents[5],   -- Level 29
	talents[7]    -- Level 30
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
		"item_basher",
		"item_assault",
		"item_skadi",
		"item_abyssal_blade",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	-- The order to use abilities in
	ConsumeDesire = UseConsume()
	if ConsumeDesire > 0 then
		bot:Action_UseAbility(Consume)
		return
	end
	
	InfestDesire, InfestTarget = UseInfest()
	if InfestDesire > 0 then
		bot:Action_UseAbilityOnEntity(Infest, InfestTarget)
		return
	end
	
	RageDesire = UseRage()
	if RageDesire > 0 then
		bot:Action_UseAbility(Rage)
		return
	end
	
	OpenWoundsDesire, OpenWoundsTarget = UseOpenWounds()
	if OpenWoundsDesire > 0 then
		bot:Action_UseAbilityOnEntity(OpenWounds, OpenWoundsTarget)
		return
	end
end

function UseRage()
	if not Rage:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if Rage:IsHidden() then return 0 end
	
	if P.IsInPhalanxTeamFight(bot) and (P.IsInCombativeMode(bot) or P.IsRetreating(bot)) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	local projectiles = bot:GetIncomingTrackingProjectiles()
	
	for v, proj in pairs(projectiles) do
		if GetUnitToLocationDistance(bot, proj.location) <= 300 and proj.is_attack == false then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	local enemies = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE)
	
	if P.IsRetreating(bot) and #enemies >= 1 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseInfest()
	if not Infest:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if Infest:IsHidden() then return 0 end
	
	local allies = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)
	local trueallies = {}
	
	for v, ally in pairs(allies) do
		if not ally:IsIllusion() and ally ~= bot then
			table.insert(trueallies, ally)
		end
	end
	
	if #trueallies >= 1 then
		local closestally = nil
		local closestdistance = 99999
		
		for v, ally in pairs(trueallies) do
			if GetUnitToUnitDistance(bot, ally) < closestdistance then
				closestally = ally
				closestdistance = GetUnitToUnitDistance(bot, ally)
			end
		end
		
		local enemies = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE)
		
		if closestally ~= nil and bot:GetHealth() < (bot:GetMaxHealth() * 0.3) and #enemies >= 1 then
			return BOT_ACTION_DESIRE_HIGH, closestally
		end
	end
	
	return 0
end

function UseConsume()
	if Consume:IsHidden() then return 0 end
	
	if bot:GetHealth() >= (bot:GetMaxHealth() * 0.8) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseOpenWounds()
	if not OpenWounds:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if OpenWounds:IsHidden() then return 0 end
	
	local CastRange = OpenWounds:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 500, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

return X