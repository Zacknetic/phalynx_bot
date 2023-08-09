X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local SplitShot = bot:GetAbilityByName("medusa_split_shot")
local MysticSnake = bot:GetAbilityByName("medusa_mystic_snake")
local ManaShield = bot:GetAbilityByName("medusa_mana_shield")
local StoneGaze = bot:GetAbilityByName("medusa_stone_gaze")

local SplitShotDesire = 0
local MysticSnakeDesire = 0
local ManaShieldDesire = 0
local StoneGazeDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, SplitShot:GetName())
	table.insert(abilities, MysticSnake:GetName())
	table.insert(abilities, ManaShield:GetName())
	table.insert(abilities, StoneGaze:GetName())
	
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
	abilities[2], -- Level 3
	abilities[1], -- Level 4
	abilities[2], -- Level 5
	abilities[1], -- Level 6
	abilities[2], -- Level 7
	abilities[1], -- Level 8
	abilities[4], -- Level 9
	talents[1],   -- Level 10
	abilities[3], -- Level 11
	abilities[3], -- Level 12
	abilities[3], -- Level 13
	abilities[3], -- Level 14
	talents[4],   -- Level 15
	abilities[4], -- Level 16
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
	talents[3],   -- Level 28
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
		"item_power_treads",
		"item_magic_wand",
	
		"item_dragon_lance",
		"item_manta",
		"item_skadi",
		"item_greater_crit",
		"item_butterfly",
		"item_black_king_bar",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	-- The order to use abilities in
	StoneGazeDesire = UseStoneGaze()
	if StoneGazeDesire > 0 then
		bot:Action_UseAbility(StoneGaze)
		return
	end
	
	ManaShieldDesire = UseManaShield()
	if ManaShieldDesire > 0 then
		bot:Action_UseAbility(ManaShield)
		return
	end
	
	SplitShotDesire = UseSplitShot()
	if SplitShotDesire > 0 then
		bot:Action_UseAbility(SplitShot)
		return
	end
	
	MysticSnakeDesire, MysticSnakeTarget = UseMysticSnake()
	if MysticSnakeDesire > 0 then
		bot:Action_UseAbilityOnEntity(MysticSnake, MysticSnakeTarget)
		return
	end
end

function UseSplitShot()
	if not SplitShot:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end

	if P.IsInLaningPhase() then
		if SplitShot:GetToggleState() == true then
			return BOT_ACTION_DESIRE_HIGH
		else
			return 0
		end
	else
		if SplitShot:GetToggleState() == false then
			return BOT_ACTION_DESIRE_HIGH
		else
			return 0
		end
	end
	
	return 0
end

function UseMysticSnake()
	if not MysticSnake:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = MysticSnake:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 100, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

function UseManaShield()
	if not ManaShield:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end

	if ManaShield:GetToggleState() == false then
		return BOT_ACTION_DESIRE_HIGH
	else
		return 0
	end
	
	return 0
end

function UseStoneGaze()
	if not StoneGaze:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if not P.IsInPhalanxTeamFight(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	return BOT_ACTION_DESIRE_HIGH, target
end

return X