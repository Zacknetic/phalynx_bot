X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local BreatheFire = bot:GetAbilityByName("dragon_knight_breathe_fire")
local DragonTail = bot:GetAbilityByName("dragon_knight_dragon_tail")
local DragonBlood = bot:GetAbilityByName("dragon_knight_dragon_blood")
local ElderDragonForm = bot:GetAbilityByName("dragon_knight_elder_dragon_form")
local Fireball = bot:GetAbilityByName("dragon_knight_fireball")

local BreatheFireDesire = 0
local DragonTailDesire = 0
local ElderDragonFormDesire = 0
local FireballDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, BreatheFire:GetName())
	table.insert(abilities, DragonTail:GetName())
	table.insert(abilities, DragonBlood:GetName())
	table.insert(abilities, ElderDragonForm:GetName())
	
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
	abilities[3], -- Level 3
	abilities[2], -- Level 4
	abilities[1], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[1], -- Level 8
	abilities[3], -- Level 9
	talents[1],   -- Level 10
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
	talents[2],   -- Level 27
	talents[4],   -- Level 28
	talents[5],   -- Level 29
	talents[7]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_bracer",
		"item_power_treads",
		"item_soul_ring",
		"item_magic_wand",
		
		"item_crimson_guard",
		
		"item_blink",
		"item_black_king_bar",
		"item_ultimate_scepter",
		"item_assault",
		"item_greater_crit",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	manathreshold = 100
	manathreshold = manathreshold + BreatheFire:GetManaCost()
	manathreshold = manathreshold + DragonTail:GetManaCost()
	manathreshold = manathreshold + ElderDragonForm:GetManaCost()
	manathreshold = manathreshold + Fireball:GetManaCost()
	
	-- The order to use abilities in
	ElderDragonFormDesire = UseElderDragonForm()
	if ElderDragonFormDesire > 0 then
		bot:Action_UseAbility(ElderDragonForm)
		return
	end
	
	DragonTailDesire, DragonTailTarget = UseDragonTail()
	if DragonTailDesire > 0 then
		bot:Action_UseAbilityOnEntity(DragonTail, DragonTailTarget)
		return
	end
	
	FireballDesire, FireballTarget = UseFireball()
	if FireballDesire > 0 then
		bot:Action_UseAbilityOnLocation(Fireball, FireballTarget)
		return
	end
	
	BreatheFireDesire, BreatheFireTarget = UseBreatheFire()
	if BreatheFireDesire > 0 then
		bot:Action_UseAbilityOnLocation(BreatheFire, BreatheFireTarget)
		return
	end
end

function UseBreatheFire()
	if not BreatheFire:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = BreatheFire:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 100, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil then
		if (bot:GetActiveMode() == BOT_MODE_LANING and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_LOW) then
			if BreatheFire:GetLevel() >= 2 then
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
		
		if #neutrals >= 2 and (bot:GetMana() - BreatheFire:GetManaCost()) > manathreshold then
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

function UseDragonTail()
	if not DragonTail:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = 0
	
	if bot:HasModifier("modifier_dragon_knight_dragon_form") then
		CastRange = DragonTail:GetSpecialValueInt("dragon_cast_range")
	else
		CastRange = DragonTail:GetCastRange()
	end
	
	if P.IsInLaningPhase() then
		CastRange = CastRange + 100
	else
		CastRange = CastRange + 500
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
				if GetUnitToUnitDistance(bot, target) > DragonTail:GetCastRange() then
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

function UseElderDragonForm()
	if not ElderDragonForm:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local tableTrueEnemies = P.FilterTrueEnemies(enemies)
	
	if (bot:GetActiveMode() == BOT_MODE_ATTACK and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_LOW) and #tableTrueEnemies > 0 then
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

function UseFireball()
	if not Fireball:IsFullyCastable() then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = 0
	
	if bot:HasModifier("modifier_dragon_knight_dragon_form") then
		CastRange = Fireball:GetSpecialValueInt("dragon_form_cast_range")
	else
		CastRange = Fireball:GetCastRange()
	end
	
	local Radius = Fireball:GetSpecialValueInt("radius")
	
	local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
	if (AoE.count >= 2) then
		return BOT_ACTION_DESIRE_HIGH, AoE.targetloc;
	end
	
	return 0
end

return X