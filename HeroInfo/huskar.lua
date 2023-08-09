X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local InnerFire = bot:GetAbilityByName("huskar_inner_fire")
local BurningSpear = bot:GetAbilityByName("huskar_burning_spear")
local BerserkersBlood = bot:GetAbilityByName("huskar_berserkers_blood")
local LifeBreak = bot:GetAbilityByName("huskar_life_break")

local Desire = 0
local BurningSpearDesire = 0
local LifeBreakDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, InnerFire:GetName())
	table.insert(abilities, BurningSpear:GetName())
	table.insert(abilities, BerserkersBlood:GetName())
	table.insert(abilities, LifeBreak:GetName())
	
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
	abilities[3], -- Level 4
	abilities[3], -- Level 5
	abilities[2], -- Level 6
	abilities[2], -- Level 7
	abilities[4], -- Level 8
	abilities[3], -- Level 9
	talents[1],   -- Level 10
	abilities[1], -- Level 11
	abilities[1], -- Level 12
	abilities[1], -- Level 13
	abilities[1], -- Level 14
	talents[3],   -- Level 15
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
	talents[4],   -- Level 28
	talents[6],   -- Level 29
	talents[7]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		ItemBuild = { 
		"item_bracer",
		"item_power_treads",
		
		"item_armlet",
		"item_sange",
		"item_black_king_bar",
		"item_heavens_halberd",
		"item_ultimate_scepter",
		"item_assault",
		"item_satanic",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	manathreshold = 100
	manathreshold = manathreshold + InnerFire:GetManaCost()
	
	-- The order to use abilities in
	LifeBreakDesire, LifeBreakTarget = UseLifeBreak()
	if LifeBreakDesire > 0 then
		bot:Action_UseAbilityOnEntity(LifeBreak, LifeBreakTarget)
		return
	end
	
	InnerFireDesire = UseInnerFire()
	if InnerFireDesire > 0 then
		bot:Action_UseAbility(InnerFire)
		return
	end
	
	BurningSpearDesire, BurningSpearTarget = UseBurningSpear()
	if BurningSpearDesire > 0 then
		bot:Action_UseAbilityOnEntity(BurningSpear, BurningSpearTarget)
		return
	end
end

function UseInnerFire()
	if not InnerFire:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = InnerFire:GetSpecialValueInt("radius")
	
	local enemies = bot:GetNearbyHeroes(CastRange - 100, true, BOT_MODE_NONE)
	
	if #enemies >= 1 and (P.IsInCombativeMode(bot) or P.IsRetreating(bot)) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local neutrals = bot:GetNearbyNeutralCreeps(CastRange)
		
		if #neutrals >= 2 and (bot:GetMana() - InnerFire:GetManaCost()) > manathreshold then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseBurningSpear()
	if not BurningSpear:IsFullyCastable() then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if P.IsInLaningPhase() then
		local enemies = bot:GetNearbyHeroes(AttackRange + 50, true, BOT_MODE_NONE)
		local target = P.GetWeakestEnemyHero(enemies)
		
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if (AttackTarget ~= nil and AttackTarget:IsHero()) or bot:GetActiveMode() == BOT_MODE_FARM then
		if BurningSpear:GetAutoCastState() == false then
			BurningSpear:ToggleAutoCast()
		end
	else
		if BurningSpear:GetAutoCastState() == true then
			BurningSpear:ToggleAutoCast()
		end
	end
	
	return 0
end

function UseLifeBreak()
	if not LifeBreak:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = LifeBreak:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 500, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

return X