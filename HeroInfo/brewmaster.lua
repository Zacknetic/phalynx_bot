X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local ThunderClap = bot:GetAbilityByName("brewmaster_thunder_clap")
local CinderBrew = bot:GetAbilityByName("brewmaster_cinder_brew")
local DrunkenBrawler = bot:GetAbilityByName("brewmaster_drunken_brawler")
local PrimalSplit = bot:GetAbilityByName("brewmaster_primal_split")
local PrimalCompanion = bot:GetAbilityByName("brewmaster_primal_companion")

local ThunderClapDesire = 0
local CinderBrewDesire = 0
local DrunkenBrawlerDesire = 0
local PrimalSplitDesire = 0
local PrimalCompanionDesire = 0

local DrunkenBrawlerStance = "Earth"

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, ThunderClap:GetName())
	table.insert(abilities, CinderBrew:GetName())
	table.insert(abilities, DrunkenBrawler:GetName())
	table.insert(abilities, PrimalSplit:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[1], -- Level 1
	abilities[2], -- Level 2
	abilities[3], -- Level 3
	abilities[2], -- Level 4
	abilities[3], -- Level 5
	abilities[4], -- Level 6
	abilities[2], -- Level 7
	abilities[2], -- Level 8
	abilities[3], -- Level 9
	talents[1],   -- Level 10
	abilities[3], -- Level 11
	abilities[4], -- Level 12
	abilities[1], -- Level 13
	abilities[1], -- Level 14
	talents[4],   -- Level 15
	abilities[1], -- Level 16
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

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_power_treads",
		"item_magic_wand",
		
		"item_crimson_guard",
		
		"item_ultimate_scepter",
		"item_black_king_bar",
		"item_assault",
		"item_refresher",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	manathreshold = 100
	
	-- The order to use abilities in
	PrimalCompanionDesire = UsePrimalCompanion()
	if PrimalCompanionDesire > 0 then
		bot:Action_UseAbility(PrimalCompanion)
		return
	end
	
	PrimalSplitDesire = UsePrimalSplit()
	if PrimalSplitDesire > 0 then
		bot:Action_UseAbility(PrimalSplit)
		return
	end
	
	DrunkenBrawlerDesire = UseDrunkenBrawler()
	if DrunkenBrawlerDesire > 0 then
		bot:Action_UseAbility(DrunkenBrawler)
		if DrunkenBrawlerStance == "Earth" then
			DrunkenBrawlerStance = "Storm"
		elseif DrunkenBrawlerStance == "Storm" then
			DrunkenBrawlerStance = "Fire"
		elseif DrunkenBrawlerStance == "Fire" then
			DrunkenBrawlerStance = "Earth"
		end
		return
	end
	
	ThunderClapDesire = UseThunderClap()
	if ThunderClapDesire > 0 then
		bot:Action_UseAbility(ThunderClap)
		return
	end
	
	CinderBrewDesire, CinderBrewTarget = UseCinderBrew()
	if CinderBrewDesire > 0 then
		bot:Action_UseAbilityOnLocation(CinderBrew, CinderBrewTarget)
		return
	end
end

function UseThunderClap()
	if not ThunderClap:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = 350
	
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	
	if #enemies >= 1 and (P.IsInCombativeMode(bot) or P.IsRetreating(bot)) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	if (bot:GetActiveMode() == BOT_MODE_FARM and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_VERYLOW) then
		local neutrals = bot:GetNearbyNeutralCreeps(CastRange)
		
		if #neutrals >= 2 and (bot:GetMana() - ThunderClap:GetManaCost()) > manathreshold then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseCinderBrew()
	if not CinderBrew:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = CinderBrew:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 100, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
	end
	
	return 0
end

function UseDrunkenBrawler()
--[[	if not DrunkenBrawler:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if not bot:IsAlive() or not P.IsPDisabled(bot) then return 0 end
	
	if bot:GetActiveMode() == BOT_MODE_ATTACK then
		if DrunkenBrawlerStance ~= "Earth" then
			return BOT_ACTION_DESIRE_HIGH
		end
	elseif P.IsRetreating(bot) then
		if DrunkenBrawlerStance ~= "Storm" then
			return BOT_ACTION_DESIRE_HIGH
		end
	else
		if DrunkenBrawlerStance ~= "Fire" then
			return BOT_ACTION_DESIRE_HIGH
		end
	end]]--
	
	return 0
end

function UsePrimalSplit()
	if not PrimalSplit:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if not P.IsInPhalanxTeamFight(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	return BOT_ACTION_DESIRE_HIGH
end

function UsePrimalCompanion()
	if not PrimalCompanion:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local allies = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	
	for v, ally in pairs(allies) do
		if string.find(ally:GetUnitName(), "npc_dota_brewmaster_earth") then
			return 0
		end
	end
	
	return BOT_ACTION_DESIRE_HIGH
end

return X