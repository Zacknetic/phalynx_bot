X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local DragonSlave = bot:GetAbilityByName("lina_dragon_slave")
local LightStrikeArray = bot:GetAbilityByName("lina_light_strike_array")
local FierySoul = bot:GetAbilityByName("lina_fiery_soul")
local LagunaBlade = bot:GetAbilityByName("lina_laguna_blade")

local DragonSlaveDesire = 0
local LightStrikeArrayDesire = 0
local LagunaBladeDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, DragonSlave:GetName())
	table.insert(abilities, LightStrikeArray:GetName())
	table.insert(abilities, FierySoul:GetName())
	table.insert(abilities, LagunaBlade:GetName())
	
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
	abilities[2], -- Level 4
	abilities[1], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[3], -- Level 8
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

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		ItemBuild = { 
		"item_faerie_fire",
	
		"item_null_talisman",
		"item_falcon_blade",
		"item_phase_boots",
		"item_magic_wand",
		
		"item_maelstrom",
		"item_black_king_bar",
		"item_gungir",
		"item_silver_edge",
		"item_satanic",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	manathreshold = 100
	manathreshold = manathreshold + DragonSlave:GetManaCost()
	manathreshold = manathreshold + LightStrikeArray:GetManaCost()
	manathreshold = manathreshold + LagunaBlade:GetManaCost()
	
	-- The order to use abilities in
	LagunaBladeDesire, LagunaBladeTarget = UseLagunaBlade()
	if LagunaBladeDesire > 0 then
		bot:Action_UseAbilityOnEntity(LagunaBlade, LagunaBladeTarget)
		return
	end
	
	LightStrikeArrayDesire, LightStrikeArrayTarget = UseLightStrikeArray()
	if LightStrikeArrayDesire > 0 then
		bot:Action_UseAbilityOnLocation(LightStrikeArray, LightStrikeArrayTarget)
		return
	end
	
	DragonSlaveDesire, DragonSlaveTarget = UseDragonSlave()
	if DragonSlaveDesire > 0 then
		bot:Action_UseAbilityOnLocation(DragonSlave, DragonSlaveTarget)
		return
	end
end

function UseDragonSlave()
	if not DragonSlave:IsFullyCastable() then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = DragonSlave:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 100, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil then
		if (bot:GetActiveMode() == BOT_MODE_LANING and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_LOW) then
			if DragonSlave:GetLevel() >= 2 then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
			else
				return 0
			end
		else
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
		end
	end
	
	if (bot:GetActiveMode() == BOT_MODE_FARM and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_VERYLOW) then
		local neutrals = bot:GetNearbyNeutralCreeps(CastRange)
		
		if #neutrals >= 2 and (bot:GetMana() - DragonSlave:GetManaCost()) > manathreshold then
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

function UseLightStrikeArray()
	if not LightStrikeArray:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = LightStrikeArray:GetCastRange() + 100
	local CastPoint = LightStrikeArray:GetCastPoint()
	
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
				if GetUnitToUnitDistance(bot, target) > LightStrikeArray:GetCastRange() then
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
	
	if (bot:GetActiveMode() == BOT_MODE_FARM and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_VERYLOW) then
		local neutrals = bot:GetNearbyNeutralCreeps(CastRange)
		
		if #neutrals >= 2 and (bot:GetMana() - LightStrikeArray:GetManaCost()) > manathreshold then
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

function UseLagunaBlade()
	if not LagunaBlade:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = LagunaBlade:GetCastRange()
	local Damage = LagunaBlade:GetSpecialValueInt("damage")
	
	local enemies = bot:GetNearbyHeroes(CastRange + 100, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	local RealDamage = 0
	
	if target ~= nil then
		RealDamage = target:GetActualIncomingDamage(Damage, DAMAGE_TYPE_MAGICAL)
	end
	
	if target ~= nil and target:GetHealth() < RealDamage then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

return X