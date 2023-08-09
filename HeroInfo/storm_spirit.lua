X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local StaticRemnant = bot:GetAbilityByName("storm_spirit_static_remnant")
local ElectricVortex = bot:GetAbilityByName("storm_spirit_electric_vortex")
local Overload = bot:GetAbilityByName("storm_spirit_overload")
local BallLightning = bot:GetAbilityByName("storm_spirit_ball_lightning")

local StaticRemnantDesire = 0
local ElectricVortexDesire = 0
local OverloadDesire = 0
local BallLightningDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, StaticRemnant:GetName())
	table.insert(abilities, ElectricVortex:GetName())
	table.insert(abilities, Overload:GetName())
	table.insert(abilities, BallLightning:GetName())
	
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
	abilities[1], -- Level 4
	abilities[3], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[1], -- Level 8
	abilities[3], -- Level 9
	talents[2],   -- Level 10
	abilities[3], -- Level 11
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
	talents[1],   -- Level 27
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
		"item_soul_ring",
		"item_boots",
		
		"item_witch_blade",
		"item_power_treads",
		"item_kaya_and_sange",
		"item_black_king_bar",
		"item_ultimate_scepter",
		"item_refresher",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	manathreshold = 200
	
	-- The order to use abilities in
	ElectricVortexDesire, ElectricVortexTarget = UseElectricVortex()
	if ElectricVortexDesire > 0 then
		bot:Action_UseAbilityOnEntity(ElectricVortex, ElectricVortexTarget)
		return
	end
	
	OverloadDesire = UseOverload()
	if OverloadDesire > 0 then
		bot:Action_UseAbility(Overload)
		return
	end
	
	StaticRemnantDesire = UseStaticRemnant()
	if StaticRemnantDesire > 0 then
		bot:Action_UseAbility(StaticRemnant)
		return
	end
	
	BallLightningDesire, BallLightningTarget = UseBallLightning()
	if BallLightningDesire > 0 then
		bot:Action_UseAbilityOnLocation(BallLightning, BallLightningTarget)
		return
	end
end

function UseStaticRemnant()
	if not StaticRemnant:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = StaticRemnant:GetSpecialValueInt("static_remnant_radius")
	
	local AttackTarget = bot:GetAttackTarget()
	
	if not bot:HasModifier("modifier_storm_spirit_overload") and AttackTarget ~= nil and AttackTarget:IsHero() and GetUnitToUnitDistance(bot, AttackTarget) <= (AttackRange + 50) then
		return BOT_ACTION_DESIRE_ABSOLUTE
	end
	
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local trueenemies = P.FilterTrueEnemies(enemies)
	local nonimmuneenemies = {}
	
	for v, enemy in pairs(trueenemies) do
		if P.IsNotImmune(enemy) then
			table.insert(nonimmuneenemies, enemy)
		end
	end
	
	if #nonimmuneenemies >= 1 then
		return BOT_ACTION_DESIRE_ABSOLUTE
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local neutrals = bot:GetNearbyNeutralCreeps(CastRange + 200)
		
		if #neutrals >= 1 and (bot:GetMana() - StaticRemnant:GetManaCost()) > manathreshold then
			return BOT_ACTION_DESIRE_ABSOLUTE
		end
	end
	
	return 0
end

function UseElectricVortex()
	if not ElectricVortex:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = 0
	
	if P.IsInLaningPhase() then
		CastRange = ElectricVortex:GetCastRange() + 100
	else
		CastRange = ElectricVortex:GetCastRange() + 300
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
				if GetUnitToUnitDistance(bot, target) > ElectricVortex:GetCastRange() then
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

function UseOverload()
	if not Overload:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if Overload:IsPassive() then return 0 end
	
	local CastRange = Overload:GetSpecialValueInt("shard_activation_radius")
	local allies = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local filteredallies = P.FilterTrueEnemies(allies)
	
	local AttackTarget = bot:GetAttackTarget()
	
	if not bot:HasModifier("modifier_storm_spirit_overload") and bot:GetActiveMode() == BOT_MODE_ATTACK and #filteredallies >= 2 then
		return BOT_ACTION_DESIRE_ABSOLUTE
	end
	
	return 0
end

function UseBallLightning()
	if not BallLightning:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local AttackTarget = P.GetWeakestEnemyHero(enemies)
	
	local RadiantBase = Vector(-7171.12, -7261.72, 1469.28)
	local DireBase = Vector(6977.84, 5797.69, 1357.99)
	local team = bot:GetTeam()
	
	if bot:GetHealth() <= (bot:GetMaxHealth() * 0.35) then
		if team == TEAM_RADIANT and GetUnitToLocationDistance(bot, RadiantBase) > 800 then
			return BOT_ACTION_DESIRE_HIGH, RadiantBase
		elseif team == TEAM_DIRE and GetUnitToLocationDistance(bot, DireBase) > 800 then
			return BOT_ACTION_DESIRE_HIGH, DireBase
		end
	end
	
	if AttackTarget ~= nil and not AttackTarget:IsAttackImmune() and not P.IsRetreating(bot) and bot:GetActiveMode() == BOT_MODE_ATTACK then
		if GetUnitToUnitDistance(bot, AttackTarget) <= 1400 and GetUnitToUnitDistance(bot, AttackTarget) >= 400 then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetExtrapolatedLocation(1)
		end
		if not bot:HasModifier("modifier_storm_spirit_overload") then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetExtrapolatedLocation(1)
		end
	end
	
	return 0
end

return X