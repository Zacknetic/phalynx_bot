X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Earthbind = bot:GetAbilityByName("meepo_earthbind")
local Poof = bot:GetAbilityByName("meepo_poof")
local Ransack = bot:GetAbilityByName("meepo_ransack")
local DividedWeStand = bot:GetAbilityByName("meepo_divided_we_stand")
local Dig = bot:GetAbilityByName("meepo_petrify")

local EarthbindDesire = 0
local PoofDesire = 0
local DividedWeStandDesire = 0
local DigDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Earthbind:GetName())
	table.insert(abilities, Poof:GetName())
	table.insert(abilities, Ransack:GetName())
	table.insert(abilities, DividedWeStand:GetName())
	
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
	abilities[2], -- Level 3
	abilities[4], -- Level 4
	abilities[2], -- Level 5
	abilities[1], -- Level 6
	abilities[2], -- Level 7
	abilities[1], -- Level 8
	abilities[3], -- Level 9
	talents[1],   -- Level 10
	abilities[4], -- Level 11
	abilities[3], -- Level 12
	abilities[3], -- Level 13
	abilities[1], -- Level 14
	talents[4],   -- Level 15
	abilities[1], -- Level 16
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
	talents[3],   -- Level 28
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
	
		"item_wraith_band",
		"item_power_treads",
	
		"item_dragon_lance",
		"item_blink",
		"item_skadi",
		"item_sheepstick",
		"item_nullifier",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		ItemBuild = { 
		"item_faerie_fire",
		"item_quelling_blade",
	
		"item_wraith_band",
		"item_power_treads",
	
		"item_dragon_lance",
		"item_blink",
		"item_skadi",
		"item_sheepstick",
		"item_nullifier",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	manathreshold = (bot:GetMaxMana() * 0.4)
	
	-- The order to use abilities in
	DigDesire = UseDig()
	if DigDesire > 0 then
		bot:Action_UseAbility(Dig)
		return
	end
	
	DividedWeStandDesire, DividedWeStandTarget = UseDividedWeStand()
	if DividedWeStandDesire > 0 then
		bot:Action_UseAbilityOnEntity(DividedWeStand, DividedWeStandTarget)
		return
	end
	
	EarthbindDesire, EarthbindTarget = UseEarthbind()
	if EarthbindDesire > 0 then
		bot:Action_UseAbilityOnLocation(Earthbind, EarthbindTarget)
		return
	end
	
	PoofDesire, PoofTarget = UsePoof()
	if PoofDesire > 0 then
		bot:Action_UseAbilityOnEntity(Poof, PoofTarget)
		return
	end
end

function UseEarthbind()
	if not Earthbind:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Earthbind:GetCastRange()
	local CastPoint = Earthbind:GetCastPoint()
	
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
				if GetUnitToUnitDistance(bot, target) > Earthbind:GetCastRange() then
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

function UsePoof()
	if not Poof:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Poof:GetSpecialValueInt("radius")
	
	local allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local MeepoTable = {}
	for v, ally in pairs(allies) do
		if ally:GetUnitName() == "npc_dota_hero_meepo" and not P.IsPossibleIllusion(ally) then
			table.insert(MeepoTable, ally)
		end
	end
	
	if P.IsRetreating(bot) then
		FurthestMeepo = nil
		FurthestDistance = 0
	
		for v, meepo in pairs(MeepoTable) do
			local enemies = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
			
			if #enemies >= 1 then
				if GetUnitToUnitDistance(bot, meepo) > FurthestDistance and bot:DistanceFromFountain() > FurthestDistance then
					FurthestMeepo = meepo
					FurthestDistance = GetUnitToUnitDistance(bot, meepo)
				end
			end
		end
		
		if FurthestMeepo ~= nil and FurthestMeepo ~= bot then
			return BOT_ACTION_DESIRE_HIGH, FurthestMeepo
		end
	end
	
	local enemies = bot:GetNearbyHeroes(CastRange - 50, true, BOT_MODE_NONE)
	
	if #enemies >= 1 then
		for v, enemy in pairs(enemies) do
			if P.IsPDisabled(enemy) then
				return BOT_ACTION_DESIRE_HIGH, bot
			end
		end
	end
	
	for v, meepo in pairs(MeepoTable) do
		if not P.IsRetreating(bot) and meepo:GetActiveMode() == BOT_MODE_ATTACK and GetUnitToUnitDistance(bot, meepo) > 2000 then
			return BOT_ACTION_DESIRE_HIGH, meepo
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM and (bot:GetMana() - Poof:GetManaCost()) > manathreshold then
		local neutrals = bot:GetNearbyNeutralCreeps(CastRange)
		
		if #neutrals >= 1 then
			return BOT_ACTION_DESIRE_HIGH, bot
		end
	end
	
	return 0
end

function UseDividedWeStand()
	if not DividedWeStand:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if DividedWeStand:IsPassive() then return 0 end
	if P.IsRetreating(bot) then return 0 end
	
	local CastRange = DividedWeStand:GetCastRange()
	local FlingRadius = 300
	
	local allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local MeepoTable = {}
	for v, ally in pairs(allies) do
		if ally:GetUnitName() == "npc_dota_hero_meepo" and not P.IsPossibleIllusion(ally) then
			table.insert(MeepoTable, ally)
		end
	end
	
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil then
		for v, meepo in pairs(MeepoTable) do
			if meepo ~= bot and GetUnitToUnitDistance(bot, meepo) <= FlingRadius then
				return BOT_ACTION_DESIRE_HIGH, target
			end
		end
	end
	
	return 0
end

function UseDig()
	if not Dig:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if bot:GetHealth() < bot:GetMaxHealth() * 0.5 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

return X