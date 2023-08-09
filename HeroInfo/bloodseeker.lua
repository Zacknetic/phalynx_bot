X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Bloodrage = bot:GetAbilityByName("bloodseeker_bloodrage")
local BloodBath = bot:GetAbilityByName("bloodseeker_blood_bath")
local Thirst = bot:GetAbilityByName("bloodseeker_thirst")
local Rupture = bot:GetAbilityByName("bloodseeker_rupture")

local BloodrageDesire = 0
local BloodBathDesire = 0
local RuptureDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Bloodrage:GetName())
	table.insert(abilities, BloodBath:GetName())
	table.insert(abilities, Thirst:GetName())
	table.insert(abilities, Rupture:GetName())
	
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
	abilities[3], -- Level 3
	abilities[1], -- Level 4
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
	talents[5],   -- Level 20
	"NoLevel",    -- Level 21
	"NoLevel",    -- Level 22
	"NoLevel",    -- Level 23
	"NoLevel",    -- Level 24
	talents[8],   -- Level 25
	"NoLevel",    -- Level 26
	talents[2],   -- Level 27
	talents[4],   -- Level 28
	talents[6],   -- Level 29
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
		"item_phase_boots",
		"item_magic_wand",
	
		"item_maelstrom",
		"item_black_king_bar",
		"item_basher",
		"item_satanic",
		"item_butterfly",
		"item_abyssal_blade",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_wraith_band",
		"item_phase_boots",
		"item_magic_wand",
	
		"item_crimson_guard",
	
		"item_maelstrom",
		"item_black_king_bar",
		"item_basher",
		"item_satanic",
		"item_butterfly",
		"item_abyssal_blade",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	-- The order to use abilities in
	RuptureDesire, RuptureTarget = UseRupture()
	if RuptureDesire > 0 then
		bot:Action_UseAbilityOnEntity(Rupture, RuptureTarget)
		return
	end
	
	BloodBathDesire, BloodBathTarget = UseBloodBath()
	if BloodBathDesire > 0 then
		bot:Action_UseAbilityOnLocation(BloodBath, BloodBathTarget)
		return
	end
	
	BloodrageDesire, BloodrageTarget = UseBloodrage()
	if BloodrageDesire > 0 then
		bot:Action_UseAbilityOnEntity(Bloodrage, BloodrageTarget)
		return
	end
end

function UseBloodrage()
	if not Bloodrage:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if (bot:GetActiveMode() == BOT_MODE_ATTACK and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_LOW) then
		return BOT_ACTION_DESIRE_HIGH, bot
	end
	
	if (bot:GetActiveMode() == BOT_MODE_FARM and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_VERYLOW) then
		local neutrals = bot:GetNearbyNeutralCreeps(AttackRange)
		
		if #neutrals >= 1 then
			return BOT_ACTION_DESIRE_HIGH, bot
		end
	end
	
	return 0
end

function UseBloodBath()
	if not BloodBath:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = BloodBath:GetCastRange()
	local CastPoint = BloodBath:GetCastPoint()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 50, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if P.IsRetreating(bot) and #enemies >= 1 then
		return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
	end
	
	if P.IsInCombativeMode(bot) then
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target:GetExtrapolatedLocation(1)
		end
	end
	
	return 0
end

function UseRupture()
	if not Rupture:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Rupture:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 50, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil and not P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

return X