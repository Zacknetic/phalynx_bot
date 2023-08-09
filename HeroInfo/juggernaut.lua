X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local BladeFury = bot:GetAbilityByName("juggernaut_blade_fury")
local HealingWard = bot:GetAbilityByName("juggernaut_healing_ward")
local BladeDance = bot:GetAbilityByName("juggernaut_blade_dance")
local OmniSlash = bot:GetAbilityByName("juggernaut_omni_slash")

local BladeFuryDesire = 0
local HealingWardDesire = 0
local OmniSlashDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, BladeFury:GetName())
	table.insert(abilities, HealingWard:GetName())
	table.insert(abilities, BladeDance:GetName())
	table.insert(abilities, OmniSlash:GetName())
	
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
	abilities[2], -- Level 8
	abilities[3], -- Level 9
	talents[1],   -- Level 10
	abilities[3], -- Level 11
	abilities[4], -- Level 12
	abilities[3], -- Level 13
	abilities[2], -- Level 14
	talents[4],   -- Level 15
	abilities[2], -- Level 16
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
	talents[3],   -- Level 28
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
	
		"item_wraith_band",
		"item_magic_wand",
		"item_phase_boots",
		"item_hand_of_midas",
	
		"item_mjollnir",
		"item_manta",
		"item_basher",
		"item_skadi",
		"item_abyssal_blade",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	-- The order to use abilities in
	OmniSlashDesire, OmniSlashTarget = UseOmniSlash()
	if OmniSlashDesire > 0 then
		bot:Action_UseAbilityOnEntity(OmniSlash, OmniSlashTarget)
		return
	end
	
	HealingWardDesire, HealingWardTarget = UseHealingWard()
	if HealingWardDesire > 0 then
		bot:Action_UseAbilityOnLocation(HealingWard, HealingWardTarget)
		return
	end
	
	BladeFuryDesire = UseBladeFury()
	if BladeFuryDesire > 0 then
		bot:Action_UseAbility(BladeFury)
		return
	end
end

function UseBladeFury()
	if not BladeFury:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = BladeFury:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(400, true, BOT_MODE_NONE)
	
	if #enemies >= 1 and P.IsInCombativeMode(bot) then
		return BOT_ACTION_DESIRE_HIGH
	elseif P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseHealingWard()
	if not HealingWard:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = HealingWard:GetCastRange()
	
	if P.IsInPhalanxTeamFight(bot) or (bot:GetHealth() <= (bot:GetMaxHealth() * 0.5)) then
		return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
	end
	
	return 0
end

function UseOmniSlash()
	if not OmniSlash:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = OmniSlash:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 200, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil and not P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

return X