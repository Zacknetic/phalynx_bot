X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Reflection = bot:GetAbilityByName("terrorblade_reflection")
local ConjureImage = bot:GetAbilityByName("terrorblade_conjure_image")
local Metamorphosis = bot:GetAbilityByName("terrorblade_metamorphosis")
local Sunder = bot:GetAbilityByName("terrorblade_sunder")
local DemonZeal = bot:GetAbilityByName("terrorblade_demon_zeal")

local ReflectionDesire = 0
local ConjureImageDesire = 0
local MetamorphosisDesire = 0
local SunderDesire = 0
local DemonZealDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Reflection:GetName())
	table.insert(abilities, ConjureImage:GetName())
	table.insert(abilities, Metamorphosis:GetName())
	table.insert(abilities, Sunder:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[3], -- Level 1
	abilities[1], -- Level 2
	abilities[2], -- Level 3
	abilities[2], -- Level 4
	abilities[3], -- Level 5
	abilities[2], -- Level 6
	abilities[4], -- Level 7
	abilities[2], -- Level 8
	abilities[3], -- Level 9
	talents[2],   -- Level 10
	abilities[3], -- Level 11
	abilities[4], -- Level 12
	abilities[1], -- Level 13
	abilities[1], -- Level 14
	talents[3],   -- Level 15
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
	talents[1],   -- Level 27
	talents[4],   -- Level 28
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
		"item_magic_wand",
	
		"item_dragon_lance",
		"item_manta",
		"item_skadi",
		"item_satanic",
		"item_greater_crit",
		"item_swift_blink",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	-- The order to use abilities in
	SunderDesire, SunderTarget = UseSunder()
	if SunderDesire > 0 then
		bot:Action_UseAbilityOnEntity(Sunder, SunderTarget)
		return
	end
	
	MetamorphosisDesire = UseMetamorphosis()
	if MetamorphosisDesire > 0 then
		bot:Action_UseAbility(Metamorphosis)
		return
	end
	
	DemonZealDesire = UseDemonZeal()
	if DemonZealDesire > 0 then
		bot:Action_UseAbility(DemonZeal)
		return
	end
	
	ReflectionDesire, ReflectionTarget = UseReflection()
	if ReflectionDesire > 0 then
		bot:Action_UseAbilityOnLocation(Reflection, ReflectionTarget)
		return
	end
	
	ConjureImageDesire = UseConjureImage()
	if ConjureImageDesire > 0 then
		bot:Action_UseAbility(ConjureImage)
		return
	end
end

function UseReflection()
	if not Reflection:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Reflection:GetCastRange()
	local Radius = Reflection:GetSpecialValueInt("range")
	
	local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
	if (AoE.count >= 2) then
		return BOT_ACTION_DESIRE_HIGH, AoE.targetloc;
	end
	
	return 0
end

function UseConjureImage()
	if not ConjureImage:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local combocost = Sunder:GetManaCost()
	
	if (Sunder:IsFullyCastable() and (bot:GetMana() - ConjureImage:GetManaCost() > combocost)) and (P.IsInCombativeMode(bot) or P.IsFarming(bot)) then
		return BOT_ACTION_DESIRE_HIGH
	elseif P.IsInCombativeMode(bot) or P.IsFarming(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseMetamorphosis()
	if not Metamorphosis:IsFullyCastable() then return 0 end
	if not P.IsInPhalanxTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	return BOT_ACTION_DESIRE_HIGH
end

function UseSunder()
	if not Sunder:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Sunder:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local target = P.GetStrongestEnemyHero(enemies)
	
	if bot:GetHealth() <= bot:GetMaxHealth() * 0.35 then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

function UseDemonZeal()
	if not DemonZeal:IsFullyCastable() then return 0 end
	if not P.IsInPhalanxTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	return BOT_ACTION_DESIRE_HIGH
end

return X