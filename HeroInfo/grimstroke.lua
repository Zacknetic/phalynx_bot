X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local StrokeOfFate = bot:GetAbilityByName("grimstroke_dark_artistry")
local PhantomsEmbrace = bot:GetAbilityByName("grimstroke_ink_creature")
local InkSwell = bot:GetAbilityByName("grimstroke_spirit_walk")
local Soulbind = bot:GetAbilityByName("grimstroke_soul_chain")

local StrokeOfFateDesire = 0
local PhantomsEmbraceDesire = 0
local InkSwellDesire = 0
local SoulbindDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, StrokeOfFate:GetName())
	table.insert(abilities, PhantomsEmbrace:GetName())
	table.insert(abilities, InkSwell:GetName())
	table.insert(abilities, Soulbind:GetName())
	
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
	abilities[3], -- Level 5
	abilities[4], -- Level 6
	abilities[3], -- Level 7
	abilities[1], -- Level 8
	abilities[1], -- Level 9
	talents[2],   -- Level 10
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
	talents[7],   -- Level 25
	"NoLevel",    -- Level 26
	talents[1],   -- Level 27
	talents[3],   -- Level 28
	talents[5],   -- Level 29
	talents[8]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
		ItemBuild = { 
		"item_tranquil_boots",
		"item_magic_wand",
		
		"item_pavise",
		"item_force_staff",
		"item_boots_of_bearing",
		"item_pipe",
		"item_veil_of_discord",
		
		"item_aether_lens",
		"item_sheepstick",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
		ItemBuild = { 
		"item_arcane_boots",
		"item_magic_wand",
		
		"item_glimmer_cape",
		"item_guardian_greaves",
		
		"item_aether_lens",
		"item_sheepstick",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	-- The order to use abilities in
	SoulbindDesire, SoulbindTarget = UseSoulbind()
	if SoulbindDesire > 0 then
		bot:Action_UseAbilityOnEntity(Soulbind, SoulbindTarget)
		return
	end
	
	PhantomsEmbraceDesire, PhantomsEmbraceTarget = UsePhantomsEmbrace()
	if PhantomsEmbraceDesire > 0 then
		bot:Action_UseAbilityOnEntity(PhantomsEmbrace, PhantomsEmbraceTarget)
		return
	end
	
	InkSwellDesire, InkSwellTarget = UseInkSwell()
	if InkSwellDesire > 0 then
		bot:Action_UseAbilityOnEntity(InkSwell, InkSwellTarget)
		return
	end
	
	StrokeOfFateDesire, StrokeOfFateTarget = UseStrokeOfFate()
	if StrokeOfFateDesire > 0 then
		bot:Action_UseAbilityOnLocation(StrokeOfFate, StrokeOfFateTarget)
		return
	end
end

function UseStrokeOfFate()
	if not StrokeOfFate:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = StrokeOfFate:GetCastRange()
	local CastPoint = StrokeOfFate:GetCastPoint()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 50, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target:GetExtrapolatedLocation(CastPoint)
	end
	
	return 0
end

function UsePhantomsEmbrace()
	if not PhantomsEmbrace:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = PhantomsEmbrace:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

function UseInkSwell()
	if not InkSwell:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = InkSwell:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 100, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	local allies = {}
	
	if target ~= nil then
		allies = target:GetNearbyHeroes(300, true, BOT_MODE_NONE)
	end
	
	local closestally = nil
	local closestdistance = 9999
	
	for v, ally in pairs(allies) do
		if GetUnitToUnitDistance(ally, target) < closestdistance then
			closestdistance = GetUnitToUnitDistance(ally, target)
			closestally = ally
		end
	end
	
	if closestally ~= nil then
		return BOT_ACTION_DESIRE_HIGH, closestally
	end
	
	if P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH, bot
	end
	
	return 0
end

function UseSoulbind()
	if not Soulbind:IsFullyCastable() then return 0 end
	if not P.IsInPhalanxTeamFight(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = PhantomsEmbrace:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 100, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

return X