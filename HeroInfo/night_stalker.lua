X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Void = bot:GetAbilityByName("night_stalker_void")
local CripplingFear = bot:GetAbilityByName("night_stalker_crippling_fear")
local HunterInTheNight = bot:GetAbilityByName("night_stalker_hunter_in_the_night")
local Darkness = bot:GetAbilityByName("night_stalker_darkness")

local VoidDesire = 0
local CripplingFearDesire = 0
local DarknessDesire = 0
local HunterInTheNightDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Void:GetName())
	table.insert(abilities, CripplingFear:GetName())
	table.insert(abilities, HunterInTheNight:GetName())
	table.insert(abilities, Darkness:GetName())
	
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

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_bracer",
		"item_phase_boots",
		"item_magic_wand",
		
		"item_crimson_guard",
		
		"item_echo_sabre",
		"item_black_king_bar",
		"item_blink",
		"item_basher",
		"item_assault",
		"item_abyssal_blade",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	manathreshold = 100
	manathreshold = manathreshold + Void:GetManaCost()
	manathreshold = manathreshold + CripplingFear:GetManaCost()
	manathreshold = manathreshold + Darkness:GetManaCost()
	manathreshold = manathreshold + HunterInTheNight:GetManaCost()
	
	-- The order to use abilities in
	DarknessDesire = UseDarkness()
	if DarknessDesire > 0 then
		bot:Action_UseAbility(Darkness)
		return
	end
	
	CripplingFearDesire = UseCripplingFear()
	if CripplingFearDesire > 0 then
		bot:Action_UseAbility(CripplingFear)
		return
	end
	
	HunterInTheNightDesire, HunterInTheNightTarget = UseHunterInTheNight()
	if HunterInTheNightDesire > 0 then
		bot:Action_UseAbilityOnEntity(HunterInTheNight, HunterInTheNightTarget)
		return
	end
	
	VoidDesire, VoidTarget = UseVoid()
	if VoidDesire > 0 then
		bot:Action_UseAbilityOnEntity(Void, VoidTarget)
		return
	end
end

function UseVoid()
	if not Void:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Void:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 100, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local neutrals = bot:GetNearbyNeutralCreeps(CastRange)
		
		if #neutrals >= 1 and (bot:GetMana() - Void:GetManaCost()) > manathreshold then
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

function UseCripplingFear()
	if not CripplingFear:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = CripplingFear:GetSpecialValueInt("radius")
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	
	if #enemies >= 1 and (P.IsRetreating(bot) or P.IsInCombativeMode(bot)) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseDarkness()
	if not Darkness:IsFullyCastable() then return 0 end
	if not P.IsInPhalanxTeamFight(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	return BOT_ACTION_DESIRE_HIGH
end

function UseHunterInTheNight()
	if HunterInTheNight:IsPassive() then return 0 end
	if not HunterInTheNight:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if (bot:GetHealth() <= (bot:GetMaxHealth() * 0.65)) or (bot:GetMana() <= (bot:GetMaxMana() * 0.75)) then
		local creeps = bot:GetNearbyCreeps(500, true)
		
		if #creeps >= 1 then
			return BOT_ACTION_DESIRE_HIGH, creeps[1]
		end
	end
	
	return 0
end

return X