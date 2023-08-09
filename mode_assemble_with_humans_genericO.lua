local bot = GetBot()

local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PC = require(GetScriptDirectory() ..  "/Library/PhalanxCarries")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

function GetDesire()
	if ShouldAssemble() then
		local SplitAllies = GetSplitAllies()
		
		if #SplitAllies > 0 and GetAssembleLeader() ~= nil then
			return (BOT_MODE_DESIRE_HIGH + 0.02)
		end
		
		return 0
	end
	
	return 0
end

function Think()
	local HeroToFollow = GetAssembleLeader()
	
	if HeroToFollow ~= nil then
		bot:Action_MoveToLocation(HeroToFollow:GetLocation())
	end
end

function ShouldAssemble()
	if not P.IsInLaningPhase()
	and bot:GetActiveMode() ~= BOT_MODE_DEFEND_TOP
	and bot:GetActiveMode() ~= BOT_MODE_DEFEND_MID
	and bot:GetActiveMode() ~= BOT_MODE_DEFEND_BOT 
	and bot:GetActiveMode() ~= BOT_MODE_RUNE
	and bot:GetActiveMode() ~= BOT_MODE_ATTACK
	and bot:GetActiveMode() ~= BOT_MODE_RETREAT
	and bot:GetActiveMode() ~= BOT_MODE_SECRET_SHOP
	and bot:GetActiveMode() ~= BOT_MODE_FARM
	and bot:GetActiveMode() ~= BOT_MODE_SIDE_SHOP
	and bot:GetActiveMode() ~= BOT_MODE_WARD
	and not P.IsMeepoClone(bot) then
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
			if PC.IsCarrySuitableToFight(bot, bot:GetUnitName()) then
				return true
			end
		else
			return true
		end
	end
	
	return false
end

function GetSplitAllies()
	local allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local splitallies = {}

	for v, ally in pairs(allies) do
		if ally:IsAlive()
		and ally:IsBot()
		and not PAF.IsPossibleIllusion(ally)
		and not P.IsMeepoClone(ally)
		and ally ~= bot then
			if ally:GetActiveMode() ~= BOT_MODE_DEFEND_TOP
			and ally:GetActiveMode() ~= BOT_MODE_DEFEND_MID
			and ally:GetActiveMode() ~= BOT_MODE_DEFEND_BOT
			and ally:GetActiveMode() ~= BOT_MODE_RETREAT
			and ally:GetActiveMode() ~= BOT_MODE_FARM
			and ally:GetActiveMode() ~= BOT_MODE_SIDE_SHOP
			and ally:GetActiveMode() ~= BOT_MODE_SECRET_SHOP
			and ally:GetActiveMode() ~= BOT_MODE_ATTACK then
				if GetUnitToUnitDistance(ally, bot) > 1200 then
					if PRoles.GetPRole(ally, ally:GetUnitName()) == "SafeLane" then
						if PC.IsCarrySuitableToFight(ally, ally:GetUnitName()) then
							table.insert(splitallies, ally)
						end
					else
						table.insert(splitallies, ally)
					end
				end
			end
		end
	end
	
	return splitallies
end

function GetAssembleLeader()
	local SplitAllies = GetSplitAllies()
	
	local ClosestHero = nil
	local ClosestDistance = 99999999
	
	for v, hero in pairs(SplitAllies) do
		if GetUnitToUnitDistance(bot, hero) < ClosestDistance then
			ClosestHero = hero
			ClosestDistance = GetUnitToUnitDistance(bot, hero)
		end
	end
	
	return ClosestHero
end