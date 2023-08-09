X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Shrapnel = bot:GetAbilityByName("sniper_shrapnel")
local Headshot = bot:GetAbilityByName("sniper_headshot")
local TakeAim = bot:GetAbilityByName("sniper_take_aim")
local Assassinate = bot:GetAbilityByName("sniper_assassinate")
local ConcussiveGrenade = bot:GetAbilityByName("sniper_concussive_grenade")

local ShrapnelDesire = 0
local TakeAimDesire = 0
local AssassinateDesire = 0
local ConcussiveGrenadeDesire = 0

local AttackRange
local manathreshold

local LastShrapnelLoc = Vector(-99999, -99999, -99999)

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Shrapnel:GetName())
	table.insert(abilities, Headshot:GetName())
	table.insert(abilities, TakeAim:GetName())
	table.insert(abilities, Assassinate:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[2], -- Level 1
	abilities[1], -- Level 2
	abilities[1], -- Level 3
	abilities[3], -- Level 4
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

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		ItemBuild = { 
		"item_wraith_band",
		"item_power_treads",
	
		"item_dragon_lance",
		"item_maelstrom",
		"item_black_king_bar",
		"item_hurricane_pike",
		"item_mjollnir",
		"item_greater_crit",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		ItemBuild = { 
		"item_faerie_fire",

		"item_wraith_band",
		"item_power_treads",
	
		"item_dragon_lance",
		"item_maelstrom",
		"item_black_king_bar",
		"item_hurricane_pike",
		"item_mjollnir",
		"item_greater_crit",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	-- The order to use abilities in
	AssassinateDesire, AssassinateTarget = UseAssassinate()
	if AssassinateDesire > 0 then
		bot:Action_UseAbilityOnEntity(Assassinate, AssassinateTarget)
		return
	end
	
	ConcussiveGrenadeDesire, ConcussiveGrenadeTarget = UseConcussiveGrenade()
	if ConcussiveGrenadeDesire > 0 then
		bot:Action_UseAbilityOnLocation(ConcussiveGrenade, ConcussiveGrenadeTarget)
		return
	end
	
	ShrapnelDesire, ShrapnelTarget = UseShrapnel()
	if ShrapnelDesire > 0 then
		bot:Action_UseAbilityOnLocation(Shrapnel, ShrapnelTarget)
		LastShrapnelLoc = ShrapnelTarget
		return
	end
	
	TakeAimDesire = UseTakeAim()
	if TakeAimDesire > 0 then
		bot:Action_UseAbility(TakeAim)
		return
	end
end

function UseShrapnel()
	if not Shrapnel:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Shrapnel:GetCastRange()
	local Radius = Shrapnel:GetSpecialValueInt("radius")
	
	local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	local ShouldCastShrapnel = false
	
	if target ~= nil then
		local distancediff = GetUnitToLocationDistance(target, LastShrapnelLoc)
		if distancediff > Radius then
			ShouldCastShrapnel = true
		end
	end
	
	if target ~= nil and ShouldCastShrapnel == true then
		return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
	end
	
	return 0
end

function UseTakeAim()
	if not TakeAim:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = TakeAim:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(AttackRange, true, BOT_MODE_NONE)
	local trueenemies = P.FilterTrueEnemies(enemies)
	
	if #trueenemies >= 1 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	if (bot:GetActiveMode() == BOT_MODE_FARM and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_VERYLOW) then
		local neutrals = bot:GetNearbyNeutralCreeps(AttackRange)
		
		if #neutrals >= 2 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseAssassinate()
	if not Assassinate:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Assassinate:GetCastRange()
	local Damage = Assassinate:GetAbilityDamage()
	
	local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
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

function UseConcussiveGrenade()
	if not ConcussiveGrenade:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = ConcussiveGrenade:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
	end
	
	return 0
end

return X