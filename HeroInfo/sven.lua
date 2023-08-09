X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local StormBolt = bot:GetAbilityByName("sven_storm_bolt")
local GreatCleave = bot:GetAbilityByName("sven_great_cleave")
local WarCry = bot:GetAbilityByName("sven_warcry")
local GodsStrength = bot:GetAbilityByName("sven_gods_strength")

local StormBoltDesire = 0
local WarCryDesire = 0
local GodsStrengthDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, StormBolt:GetName())
	table.insert(abilities, GreatCleave:GetName())
	table.insert(abilities, WarCry:GetName())
	table.insert(abilities, GodsStrength:GetName())
	
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
	abilities[2], -- Level 3
	abilities[2], -- Level 4
	abilities[2], -- Level 5
	abilities[4], -- Level 6
	abilities[2], -- Level 7
	abilities[3], -- Level 8
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
	talents[6],   -- Level 20
	"NoLevel",    -- Level 21
	"NoLevel",    -- Level 22
	"NoLevel",    -- Level 23
	"NoLevel",    -- Level 24
	talents[7],   -- Level 25
	"NoLevel",    -- Level 26
	talents[1],   -- Level 27
	talents[4],   -- Level 28
	talents[5],   -- Level 29
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
		"item_power_treads",
		"item_magic_wand",
	
		"item_echo_sabre",
		"item_sange_and_yasha",
		"item_black_king_bar",
		"item_blink",
		"item_greater_crit",
		"item_overwhelming_blink",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	-- The order to use abilities in
	GodsStrengthDesire = UseGodsStrength()
	if GodsStrengthDesire > 0 then
		bot:Action_UseAbility(GodsStrength)
		return
	end
	
	StormBoltDesire, StormBoltTarget = UseStormBolt()
	if StormBoltDesire > 0 then
		bot:Action_UseAbilityOnEntity(StormBolt, StormBoltTarget)
		return
	end
	
	WarCryDesire, WarCryTarget = UseWarCry()
	if WarCryDesire > 0 then
		bot:Action_UseAbility(WarCry)
		return
	end
end

function UseStormBolt()
	if not StormBolt:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = 0
	
	if P.IsInLaningPhase() then
		CastRange = StormBolt:GetCastRange() + 100
	else
		CastRange = StormBolt:GetCastRange() + 500
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
				if GetUnitToUnitDistance(bot, target) > StormBolt:GetCastRange() then
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

function UseWarCry()
	if not WarCry:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if (bot:GetActiveMode() == BOT_MODE_ATTACK and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_LOW) or P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseGodsStrength()
	if not GodsStrength:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local tableTrueEnemies = P.FilterTrueEnemies(enemies)
	
	if (bot:GetActiveMode() == BOT_MODE_ATTACK and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_LOW) and #tableTrueEnemies > 0 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

return X