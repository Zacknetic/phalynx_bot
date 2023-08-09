X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Swarm = bot:GetAbilityByName("death_prophet_carrion_swarm")
local Silence = bot:GetAbilityByName("death_prophet_silence")
local SpiritSiphon = bot:GetAbilityByName("death_prophet_spirit_siphon")
local Exorcism = bot:GetAbilityByName("death_prophet_exorcism")

local SwarmDesire = 0
local SilenceDesire = 0
local SpiritSiphonDesire = 0
local ExorcismDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Swarm:GetName())
	table.insert(abilities, Silence:GetName())
	table.insert(abilities, SpiritSiphon:GetName())
	table.insert(abilities, Exorcism:GetName())
	
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
	abilities[3], -- Level 8
	abilities[3], -- Level 9
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
		"item_faerie_fire",
	
		"item_null_talisman",
		"item_power_treads",
		"item_magic_wand",
		
		"item_cyclone",
		"item_kaya_and_sange",
		"item_black_king_bar",
		"item_shivas_guard",
		"item_octarine_core",
		"item_aeon_disk",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		ItemBuild = { 
		"item_null_talisman",
		
		"item_power_treads",
		"item_magic_wand",
		
		"item_crimson_guard",
		
		"item_cyclone",
		"item_kaya_and_sange",
		"item_black_king_bar",
		"item_shivas_guard",
		"item_octarine_core",
		"item_aeon_disk",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	manathreshold = 100
	manathreshold = manathreshold + Swarm:GetManaCost()
	manathreshold = manathreshold + Silence:GetManaCost()
	manathreshold = manathreshold + SpiritSiphon:GetManaCost()
	manathreshold = manathreshold + Exorcism:GetManaCost()
	
	-- The order to use abilities in
	ExorcismDesire = UseExorcism()
	if ExorcismDesire > 0 then
		bot:Action_UseAbility(Exorcism)
		return
	end
	
	SilenceDesire, SilenceTarget = UseSilence()
	if SilenceDesire > 0 then
		bot:Action_UseAbilityOnLocation(Silence, SilenceTarget)
		return
	end
	
	SpiritSiphonDesire, SpiritSiphonTarget = UseSpiritSiphon()
	if SpiritSiphonDesire > 0 then
		bot:Action_UseAbilityOnEntity(SpiritSiphon, SpiritSiphonTarget)
		return
	end
	
	SwarmDesire, SwarmTarget = UseSwarm()
	if SwarmDesire > 0 then
		bot:Action_UseAbilityOnLocation(Swarm, SwarmTarget)
		return
	end
end

function UseSwarm()
	if not Swarm:IsFullyCastable() then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if P.IsInLaningPhase() then
		if bot:GetAssignedLane() ~= LANE_MID then
			if not P.IsInCombativeMode(bot) then return 0 end
		end
	end
	
	local CastRange = Swarm:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 100, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil then
		if bot:GetActiveMode() == BOT_MODE_LANING then
			if Swarm:GetLevel() >= 2 then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
			else
				return 0
			end
		else
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local neutrals = bot:GetNearbyNeutralCreeps(CastRange)
		
		if #neutrals >= 2 and (bot:GetMana() - Swarm:GetManaCost()) > manathreshold then
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
		
			return BOT_ACTION_DESIRE_HIGH, weakestneutral:GetLocation()
		end
	end
	
	return 0
end

function UseSilence()
	if not Silence:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Silence:GetCastRange() + 100
	local CastPoint = Silence:GetCastPoint()
	
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
				if GetUnitToUnitDistance(bot, target) > Silence:GetCastRange() then
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
		return BOT_ACTION_DESIRE_HIGH, target:GetExtrapolatedLocation(1)
	end
	
	return 0
end

function UseSpiritSiphon()
	if not SpiritSiphon:IsFullyCastable() then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = SpiritSiphon:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 100, true, BOT_MODE_NONE)
	local NonSiphonedEnemies = {}
	
	for v, enemy in pairs(enemies) do
		if not enemy:HasModifier("modifier_death_prophet_spirit_siphon_debuff") then
			table.insert(NonSiphonedEnemies, enemy)
		end
	end
	
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

function UseExorcism()
	if not Exorcism:IsFullyCastable() then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local enemies = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	local tableTrueEnemies = P.FilterTrueEnemies(enemies)
	
	if P.IsInPhalanxTeamFight(bot) and #tableTrueEnemies >= 2 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	local attacktarget = bot:GetAttackTarget()
	
	if attacktarget ~= nil then
		if attacktarget:IsBuilding() then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

return X