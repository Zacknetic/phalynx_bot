X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local SpiritLance = bot:GetAbilityByName("phantom_lancer_spirit_lance")
local DoppelGanger = bot:GetAbilityByName("phantom_lancer_doppelwalk")
local PhantomRush = bot:GetAbilityByName("phantom_lancer_phantom_edge")
local Juxtapose = bot:GetAbilityByName("phantom_lancer_juxtapose")

local SpiritLanceDesire = 0
local DoppelGangerDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, SpiritLance:GetName())
	table.insert(abilities, DoppelGanger:GetName())
	table.insert(abilities, PhantomRush:GetName())
	table.insert(abilities, Juxtapose:GetName())
	
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
	abilities[2], -- Level 3
	abilities[3], -- Level 4
	abilities[3], -- Level 5
	abilities[4], -- Level 6
	abilities[3], -- Level 7
	abilities[2], -- Level 8
	abilities[2], -- Level 9
	talents[2],   -- Level 10
	abilities[2], -- Level 11
	abilities[4], -- Level 12
	abilities[1], -- Level 13
	abilities[1], -- Level 14
	talents[3],   -- Level 15
	abilities[1], -- Level 16
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
		"item_quelling_blade",
	
		"item_wraith_band",
		"item_power_treads",
		"item_magic_wand",
	
		"item_diffusal_blade",
		"item_manta",
		"item_heart",
		"item_skadi",
		"item_butterfly",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	-- The order to use abilities in
	PhantomRushDesire = UsePhantomRush()
	if PhantomRushDesire > 0 then
		bot:Action_UseAbility(PhantomRush)
		return
	end
	
	SpiritLanceDesire, SpiritLanceTarget = UseSpiritLance()
	if SpiritLanceDesire > 0 then
		bot:Action_UseAbilityOnEntity(SpiritLance, SpiritLanceTarget)
		return
	end
	
	DoppelGangerDesire, DoppelGangerTarget = UseDoppelGanger()
	if DoppelGangerDesire > 0 then
		bot:Action_UseAbilityOnLocation(DoppelGanger, DoppelGangerTarget)
		return
	end
end

function UseSpiritLance()
	if not SpiritLance:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = SpiritLance:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 100, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

function UseDoppelGanger()
	if not DoppelGanger:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = DoppelGanger:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
	end
	
	return 0
end

function UsePhantomRush()
	if not PhantomRush:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end

	if bot:GetActiveMode() == BOT_MODE_ATTACK then
		if PhantomRush:GetToggleState() == true and not SpiritLance:IsFullyCastable() and not DoppelGanger:IsFullyCastable() then
			return BOT_ACTION_DESIRE_HIGH
		else
			return 0
		end
	else
		if PhantomRush:GetToggleState() == false then
			return BOT_ACTION_DESIRE_HIGH
		else
			return 0
		end
	end
	
	return 0
end

return X