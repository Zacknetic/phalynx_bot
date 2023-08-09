X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local NetherBlast = bot:GetAbilityByName("pugna_nether_blast")
local Decrepify = bot:GetAbilityByName("pugna_decrepify")
local NetherWard = bot:GetAbilityByName("pugna_nether_ward")
local LifeDrain = bot:GetAbilityByName("pugna_life_drain")

local NetherBlastDesire = 0
local DecrepifyDesire = 0
local NetherWardDesire = 0
local LifeDrainDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, NetherBlast:GetName())
	table.insert(abilities, Decrepify:GetName())
	table.insert(abilities, NetherWard:GetName())
	table.insert(abilities, LifeDrain:GetName())
	
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
	abilities[1], -- Level 3
	abilities[2], -- Level 4
	abilities[1], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[2], -- Level 8
	abilities[2], -- Level 9
	talents[2],   -- Level 10
	abilities[3], -- Level 11
	abilities[4], -- Level 12
	abilities[3], -- Level 13
	abilities[3], -- Level 14
	talents[4],   -- Level 15
	abilities[3], -- Level 16
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
	talents[3],   -- Level 28
	talents[5],   -- Level 29
	talents[8]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		ItemBuild = { 
		"item_faerie_fire",
	
		"item_null_talisman",
		"item_boots",
		"item_magic_wand",
		
		"item_travel_boots",
		"item_aether_lens",
		"item_blink",
		"item_dagon",
		"item_sheepstick",
		"item_dagon_5",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	manathreshold = 100
	manathreshold = manathreshold + NetherBlast:GetManaCost()
	manathreshold = manathreshold + Decrepify:GetManaCost()
	manathreshold = manathreshold + NetherWard:GetManaCost()
	
	-- The order to use abilities in
	NetherWardDesire, NetherWardTarget = UseNetherWard()
	if NetherWardDesire > 0 then
		bot:Action_UseAbilityOnLocation(NetherWard, NetherWardTarget)
		return
	end
	
	DecrepifyDesire, DecrepifyTarget = UseDecrepify()
	if DecrepifyDesire > 0 then
		bot:Action_UseAbilityOnEntity(Decrepify, DecrepifyTarget)
		return
	end
	
	NetherBlastDesire, NetherBlastTarget = UseNetherBlast()
	if NetherBlastDesire > 0 then
		bot:Action_UseAbilityOnLocation(NetherBlast, NetherBlastTarget)
		return
	end
	
	LifeDrainDesire, LifeDrainTarget = UseLifeDrain()
	if LifeDrainDesire > 0 then
		bot:Action_UseAbilityOnEntity(LifeDrain, LifeDrainTarget)
		return
	end
end

function UseNetherBlast()
	if not NetherBlast:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = NetherBlast:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(AttackRange + 100, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil and not P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH, target:GetExtrapolatedLocation(1)
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local neutrals = bot:GetNearbyNeutralCreeps(CastRange)
		
		if #neutrals >= 1 and (bot:GetMana() - NetherBlast:GetManaCost()) > manathreshold then
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
		
			return BOT_ACTION_DESIRE_HIGH, weakestneutral:GetLocation()
		end
	end
	
	return 0
end

function UseDecrepify()
	if not Decrepify:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = 0
	
	if P.IsInLaningPhase() then
		CastRange = Decrepify:GetCastRange() + 100
	else
		CastRange = Decrepify:GetCastRange() + 500
	end
	
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local target = nil
	
	if target == nil and #enemies >= 1 then
		if P.IsRetreating(bot) then
			target = P.GetClosestEnemy(bot, enemies)
			
			if target ~= nil then
				if GetUnitToUnitDistance(bot, target) > Decrepify:GetCastRange() then
					target = nil
				end
			end
		else
			target = P.GetWeakestEnemyHero(enemies)
		end
	end
	
	if target ~= nil and (P.IsInCombativeMode(bot) or P.IsRetreating(bot)) then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

function UseNetherWard()
	if not NetherWard:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if not P.IsInPhalanxTeamFight(bot) then return 0 end
	
	return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
end

function UseLifeDrain()
	if not LifeDrain:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	
	local CastRange = LifeDrain:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 100, true, BOT_MODE_NONE)
	local target = P.GetStrongestEnemyHero(enemies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

return X