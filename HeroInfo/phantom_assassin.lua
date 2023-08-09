X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local StiflingDagger = bot:GetAbilityByName("phantom_assassin_stifling_dagger")
local PhantomStrike = bot:GetAbilityByName("phantom_assassin_phantom_strike")
local Blur = bot:GetAbilityByName("phantom_assassin_blur")
local CoupDeGrace = bot:GetAbilityByName("phantom_assassin_coup_de_grace")
local FanOfKnives = bot:GetAbilityByName("phantom_assassin_fan_of_knives")

local StiflingDaggerDesire = 0
local PhantomStrikeDesire = 0
local BlurDesire = 0
local FanOfKnivesDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, StiflingDagger:GetName())
	table.insert(abilities, PhantomStrike:GetName())
	table.insert(abilities, Blur:GetName())
	table.insert(abilities, CoupDeGrace:GetName())
	
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
	abilities[1], -- Level 3
	abilities[3], -- Level 4
	abilities[1], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[2], -- Level 8
	abilities[2], -- Level 9
	talents[1],   -- Level 10
	abilities[2], -- Level 11
	abilities[4], -- Level 12
	abilities[3], -- Level 13
	abilities[3], -- Level 14
	talents[4],   -- Level 15
	abilities[3], -- Level 16
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

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_wraith_band",
		"item_cornucopia",
		"item_power_treads",
		"item_magic_wand",
	
		"item_bfury",
		"item_black_king_bar",
		"item_desolator",
		"item_satanic",
		"item_basher",
		"item_abyssal_blade",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()
	
	manathreshold = 100
	manathreshold = manathreshold + StiflingDagger:GetManaCost()
	manathreshold = manathreshold + PhantomStrike:GetManaCost()
	manathreshold = manathreshold + Blur:GetManaCost()
	manathreshold = manathreshold + FanOfKnives:GetManaCost()

	-- The order to use abilities in
	FanOfKnivesDesire, FanOfKnivesTarget = UseFanOfKnives()
	if FanOfKnivesDesire > 0 then
		bot:Action_UseAbility(FanOfKnives)
		return
	end
	
	BlurDesire, BlurTarget = UseBlur()
	if BlurDesire > 0 then
		bot:Action_UseAbility(Blur)
		return
	end
	
	StiflingDaggerDesire, StiflingDaggerTarget = UseStiflingDagger()
	if StiflingDaggerDesire > 0 then
		bot:Action_UseAbilityOnEntity(StiflingDagger, StiflingDaggerTarget)
		return
	end
	
	PhantomStrikeDesire, PhantomStrikeTarget = UsePhantomStrike()
	if PhantomStrikeDesire > 0 then
		bot:Action_UseAbilityOnEntity(PhantomStrike, PhantomStrikeTarget)
		return
	endturn
	end
end

function UseStiflingDagger()
	if not StiflingDagger:IsFullyCastable() then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = StiflingDagger:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 100, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local neutrals = bot:GetNearbyNeutralCreeps(CastRange)
		
		if #neutrals >= 1 and (bot:GetMana() - StiflingDagger:GetManaCost()) > manathreshold then
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
		
			return BOT_ACTION_DESIRE_HIGH, weakestneutral
		end
	end
	
	return 0
end

function UsePhantomStrike()
	if not PhantomStrike:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = PhantomStrike:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 100, true, BOT_MODE_NONE)
	local allies = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local creeps = bot:GetNearbyCreeps(CastRange, false)
	local target
	
	local RadiantBase = Vector(-7171.12, -7261.72, 1469.28)
	local DireBase = Vector(6977.84, 5797.69, 1357.99)
	local base
	local team = bot:GetTeam()
	
	if team == TEAM_RADIANT then
		base = RadiantBase
	elseif team == TEAM_DIRE then
		base = DireBase
	end
	
	if P.IsRetreating(bot) then
		for v, creep in pairs(creeps) do
			table.insert(allies, creep)
		end
		
		local AllyClosestToBase = nil
		local AllyClosestToBaseDist = 99999
		
		for v, ally in pairs(allies) do
			if ally ~= bot and GetUnitToLocationDistance(ally, base) < AllyClosestToBaseDist then
				AllyClosestToBase = ally
				AllyClosestToBaseDist = GetUnitToLocationDistance(ally, base)
			end
		end
		
		if AllyClosestToBase ~= nil and AllyClosestToBaseDist < GetUnitToLocationDistance(bot, base) then
			return BOT_ACTION_DESIRE_HIGH, AllyClosestToBase
		end
	end
	
	if P.IsInCombativeMode(bot) and not P.IsRetreating(bot) then
		target = P.GetWeakestEnemyHero(enemies)
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local neutrals = bot:GetNearbyNeutralCreeps(CastRange)
		
		if #neutrals >= 1 and (bot:GetMana() - PhantomStrike:GetManaCost()) > manathreshold then
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
		
			return BOT_ACTION_DESIRE_HIGH, weakestneutral
		end
	end
	
	return 0
end

function UseBlur()
	if not Blur:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local enemies = bot:GetNearbyHeroes(Blur:GetSpecialValueInt("radius") + 200, true, BOT_MODE_NONE)
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		return BOT_ACTION_DESIRE_HIGH
	end

	if P.IsRetreating(bot) then
		if #enemies <= 0 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseFanOfKnives()
	if not FanOfKnives:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local enemies = bot:GetNearbyHeroes(FanOfKnives:GetSpecialValueInt("radius"), true, BOT_MODE_NONE)
	local neutrals = bot:GetNearbyNeutralCreeps(FanOfKnives:GetSpecialValueInt("radius"))
	
	if #enemies >= 1 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM and #neutrals >= 2 and (bot:GetMana() - FanOfKnives:GetManaCost()) > manathreshold then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

return X