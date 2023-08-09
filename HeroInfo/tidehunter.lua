X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Gush = bot:GetAbilityByName("tidehunter_gush")
local KrakenShell = bot:GetAbilityByName("tidehunter_kraken_shell")
local AnchorSmash = bot:GetAbilityByName("tidehunter_anchor_smash")
local Ravage = bot:GetAbilityByName("tidehunter_ravage")
local TendrilsOfTheDeep = bot:GetAbilityByName("tidehunter_arm_of_the_deep")

local GushDesire = 0
local AnchorSmashDesire = 0
local RavageDesire = 0
local TendrilsOfTheDeepDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Gush:GetName())
	table.insert(abilities, KrakenShell:GetName())
	table.insert(abilities, AnchorSmash:GetName())
	table.insert(abilities, Ravage:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[1], -- Level 1
	abilities[2], -- Level 2
	abilities[1], -- Level 3
	abilities[3], -- Level 4
	abilities[1], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[2], -- Level 8
	abilities[2], -- Level 9
	talents[1],   -- Level 10
	abilities[2], -- Level 11
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
	talents[7],   -- Level 25
	"NoLevel",    -- Level 26
	talents[2],   -- Level 27
	talents[4],   -- Level 28
	talents[5],   -- Level 29
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
		"item_soul_ring",
		"item_magic_wand",
		"item_phase_boots",
		
		"item_crimson_guard",
		
		"item_blink",
		"item_ultimate_scepter",
		"item_shivas_guard",
		"item_refresher",
		"item_overwhelming_blink",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	-- The order to use abilities in
	RavageDesire = UseRavage()
	if RavageDesire > 0 then
		bot:Action_UseAbility(Ravage)
		return
	end
	
	TendrilsOfTheDeepDesire, TendrilsOfTheDeepTarget = UseTendrilsOfTheDeep()
	if TendrilsOfTheDeepDesire > 0 then
		bot:Action_UseAbilityOnLocation(TendrilsOfTheDeep, TendrilsOfTheDeepTarget)
		return
	end
	
	AnchorSmashDesire = UseAnchorSmash()
	if AnchorSmashDesire > 0 then
		bot:Action_UseAbility(AnchorSmash)
		return
	end
	
	GushDesire, GushTarget = UseGush()
	if GushDesire > 0 then
		bot:Action_UseAbilityOnEntity(Gush, GushTarget)
		return
	end
end

function UseGush()
	if not Gush:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Gush:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 100, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

function UseAnchorSmash()
	if not AnchorSmash:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = AnchorSmash:GetSpecialValueInt("radius")
	local enemies = bot:GetNearbyHeroes(CastRange - 50, true, BOT_MODE_NONE)
	
	if #enemies >= 1 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local neutrals = bot:GetNearbyNeutralCreeps(CastRange)
		
		if #neutrals >= 2 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseRavage()
	if not Ravage:IsFullyCastable() then return 0 end
	if not P.IsInPhalanxTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Ravage:GetSpecialValueInt("radius")
	local enemies = bot:GetNearbyHeroes(CastRange - 100, true, BOT_MODE_NONE)
	local trueenemies = P.FilterEnemiesForStun(enemies)
	
	if #trueenemies >= 2 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseTendrilsOfTheDeep()
	if not TendrilsOfTheDeep:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = TendrilsOfTheDeep:GetCastRange()
	
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
				if GetUnitToUnitDistance(bot, target) > TendrilsOfTheDeep:GetCastRange() then
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
		return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
	end
	
	return 0
end

return X