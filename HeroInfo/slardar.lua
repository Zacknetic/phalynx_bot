X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Sprint = bot:GetAbilityByName("slardar_sprint")
local SlithereenCrush = bot:GetAbilityByName("slardar_slithereen_crush")
local Bash = bot:GetAbilityByName("slardar_bash")
local CorrosiveHaze = bot:GetAbilityByName("slardar_amplify_damage")

local SprintDesire = 0
local SlithereenCrushDesire = 0
local CorrosiveHazeDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Sprint:GetName())
	table.insert(abilities, SlithereenCrush:GetName())
	table.insert(abilities, Bash:GetName())
	table.insert(abilities, CorrosiveHaze:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[3], -- Level 1
	abilities[2], -- Level 2
	abilities[1], -- Level 3
	abilities[3], -- Level 4
	abilities[3], -- Level 5
	abilities[4], -- Level 6
	abilities[3], -- Level 7
	abilities[1], -- Level 8
	abilities[1], -- Level 9
	talents[1],   -- Level 10
	abilities[1], -- Level 11
	abilities[4], -- Level 12
	abilities[2], -- Level 13
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

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_bracer",
		"item_power_treads",
		"item_magic_wand",
		
		"item_crimson_guard",
		
		"item_blink",
		"item_black_king_bar",
		"item_ultimate_scepter",
		"item_assault",
		"item_moon_shard",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	manathreshold = 100
	manathreshold = manathreshold + Sprint:GetManaCost()
	manathreshold = manathreshold + SlithereenCrush:GetManaCost()
	manathreshold = manathreshold + CorrosiveHaze:GetManaCost()
	
	-- The order to use abilities in
	SlithereenCrushDesire = UseSlithereenCrush()
	if SlithereenCrushDesire > 0 then
		bot:Action_UseAbility(SlithereenCrush)
		return
	end
	
	CorrosiveHazeDesire, CorrosiveHazeTarget = UseCorrosiveHaze()
	if CorrosiveHazeDesire > 0 then
		bot:Action_UseAbilityOnEntity(CorrosiveHaze, CorrosiveHazeTarget)
		return
	end
	
	SprintDesire = UseSprint()
	if SprintDesire > 0 then
		bot:Action_UseAbility(Sprint)
		return
	end
end

function UseSprint()
	if not Sprint:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	
	if #enemies >= 1 and (P.IsInCombativeMode(bot) or P.IsRetreating(bot)) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseSlithereenCrush()
	if not SlithereenCrush:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = 325
	
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	
	if #enemies >= 1 and (P.IsInCombativeMode(bot) or P.IsRetreating(bot)) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	if (bot:GetActiveMode() == BOT_MODE_FARM and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_VERYLOW) then
		local neutrals = bot:GetNearbyNeutralCreeps(CastRange)
		
		if #neutrals >= 2 and (bot:GetMana() - SlithereenCrush:GetManaCost()) > manathreshold then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseCorrosiveHaze()
	if not CorrosiveHaze:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = CorrosiveHaze:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 100, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil and not target:HasModifier("modifier_slardar_amplify_damage") then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

return X