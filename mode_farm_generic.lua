local bot = GetBot()

local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PC = require(GetScriptDirectory() ..  "/Library/PhalanxCarries")

local availablecamps = {}
local emptycamps = {}
local allies = {}
local enemies = {}

local FarmMode = ""
local LaneToClear

function GetDesire()
	allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	enemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)

	local enemies = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	if #enemies >= 1 then
		return 0
	end

	if not P.IsInLaningPhase() then	
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" or PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" or PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
			local FarmTopDesire = GetFarmLaneDesire(LANE_TOP)
			local FarmMidDesire = GetFarmLaneDesire(LANE_MID)
			local FarmBottomDesire = GetFarmLaneDesire(LANE_BOT)
	
			local MostDesiredLane = LANE_MID
			local HighestDesire = 0
		
			if FarmMidDesire > HighestDesire then
				MostDesiredLane = LANE_MID
				HighestDesire = FarmMidDesire
			end
			if FarmTopDesire > HighestDesire then
				MostDesiredLane = LANE_TOP
				HighestDesire = FarmTopDesire
			end
			if FarmBottomDesire > HighestDesire then
				MostDesiredLane = LANE_BOT
				HighestDesire = FarmBottomDesire
			end
	
			local lanefront = GetLaneFrontLocation(GetOpposingTeam(), MostDesiredLane, 0)
			
			if not IsEnemyNearLaneFront(lanefront) then
				local ClosestAllyToFront = nil
				local ClosestAllyDistance = 99999
				
				for v, ally in pairs(allies) do
					if ally:IsAlive()
					and not P.IsPossibleIllusion(ally)
					and (PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" or PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" or PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane")
					and (bot:GetActiveMode() ~= BOT_MODE_DEFEND_TOWER_TOP and bot:GetActiveMode() ~= BOT_MODE_DEFEND_TOWER_MID and bot:GetActiveMode() ~= BOT_MODE_DEFEND_TOWER_BOT) then
						if GetUnitToLocationDistance(ally, lanefront) < ClosestAllyDistance then
							ClosestAllyToFront = ally
							ClosestAllyDistance = GetUnitToLocationDistance(ally, lanefront)
						end
					end
				end
				
				if ClosestAllyToFront == bot and not IsEnemyNearLaneFront(lanefront) then
					FarmMode = "ClearLane"
					LaneToClear = lanefront
					
					if bot:GetUnitName() == "npc_dota_hero_phantom_assassin" then
						return HighestDesire
					else
						return HighestDesire
					end
				end
			end
		
			if bot:GetLevel() >= 6 and ShouldFarm() then
				FarmMode = "Jungle"
				
				if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
					if bot:GetUnitName() == "npc_dota_hero_phantom_assassin" then
						if PC.IsCarrySuitableToFight(bot, bot:GetUnitName()) then
							return BOT_MODE_DESIRE_MODERATE - 0.1
							--return BOT_MODE_DESIRE_LOW - 0.1
						else
							--return BOT_MODE_DESIRE_MODERATE + (0.15 - 0.1)
							return BOT_MODE_DESIRE_HIGH - 0.15
						end
					else
						if PC.IsCarrySuitableToFight(bot, bot:GetUnitName()) then
							--return BOT_MODE_DESIRE_MODERATE
							return BOT_MODE_DESIRE_LOW
						else
							--return BOT_MODE_DESIRE_MODERATE
							return BOT_MODE_DESIRE_HIGH
						end
					end
				elseif PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
					--return BOT_MODE_DESIRE_MODERATE + 0.075
					return BOT_MODE_DESIRE_NONE
				elseif PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
					return BOT_MODE_DESIRE_NONE
				end
			end
		else
			return BOT_MODE_DESIRE_NONE
		end
	else
		return BOT_MODE_DESIRE_NONE
	end
	
	return BOT_MODE_DESIRE_NONE
end

function OnStart()
	local camps = GetNeutralSpawners()
	availablecamps = {}
	emptycamps = {}
	
	for v, camp in pairs(camps) do
		if bot:GetLevel() < 12 then
			if camp.type ~= "ancient" and camp.team == bot:GetTeam() then
				table.insert(availablecamps, camp)
			end
		elseif bot:GetLevel() >= 12 then
			if camp.team == bot:GetTeam() then
				table.insert(availablecamps, camp)
			end
		end
	end
end

function Think()
	if #emptycamps == #availablecamps then
		emptycamps = {}
	end
	
	if FarmMode == "ClearLane" then
		local lanecreeps = bot:GetNearbyLaneCreeps(800, true)
			
		local weakestcreep = nil
		local smallesthealth = 99999
			
		for v, creep in pairs(lanecreeps) do
			if creep ~= nil and creep:CanBeSeen() then
				if creep:GetHealth() < smallesthealth then
					weakestcreep = creep
					smallesthealth = creep:GetHealth()
				end
			end
		end
	
		if weakestcreep ~= nil and weakestcreep:CanBeSeen() and GetUnitToLocationDistance(weakestcreep, LaneToClear) < 800 then
			bot:Action_AttackUnit(weakestcreep, false)
		else
			bot:Action_MoveToLocation(LaneToClear)
		end
	elseif FarmMode == "Jungle" then
		local neutrals = bot:GetNearbyNeutralCreeps(bot:GetAttackRange() + 100)
	
		local closestcamp = nil
		local campdistance = 99999
			
		if #neutrals == 0 then
			for i, camp in pairs(availablecamps) do
				if GetUnitToLocationDistance(bot, availablecamps[i].location) < campdistance and not IsCampEmpty(camp) and not IsCampBeingFarmed(camp) then
					closestcamp = availablecamps[i]
					campdistance = GetUnitToLocationDistance(bot, availablecamps[i].location)
				end
			end
				
			if closestcamp ~= nil then
				bot:Action_MoveToLocation(closestcamp.location)
					
				if GetUnitToLocationDistance(bot, closestcamp.location) <= 200 and #neutrals == 0 then
					table.insert(emptycamps, closestcamp)
				end
			end
		elseif #neutrals >= 1 then
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
				
			if weakestneutral ~= nil and weakestneutral:CanBeSeen() then
				bot:Action_AttackUnit(weakestneutral, false)
			end
		end
	end
end

function ShouldFarm()
	local AliveAllies = 0
	local AliveEnemies = 0

	local IDs = GetTeamPlayers(GetTeam())
	for v, id in pairs(IDs) do
		if IsHeroAlive(id) then
			AliveAllies = AliveAllies + 1
		end
	end
	IDs = GetTeamPlayers(GetOpposingTeam())
	for v, id in pairs(IDs) do
		if IsHeroAlive(id) then
			AliveEnemies = AliveEnemies + 1
		end
	end
	
	if AliveAllies < AliveEnemies then
		return true
	else
		return false
	end
end

function IsCampEmpty(camp)
	if #emptycamps > 0 then
		for v, emptycamp in pairs(emptycamps) do
			if emptycamp == camp then
				return true
			end
		end
		
		return false
	end
end

function IsCampBeingFarmed(camp)
	for v, ally in pairs(allies) do
		if ally ~= bot and not P.IsPossibleIllusion(ally) then
			if GetUnitToLocationDistance(ally, camp.location) <= 500 then
				return true
			end
		end
	end
	
	return false
end

function IsEnemyNearLaneFront(lanefront)
	for v, enemy in pairs(enemies) do
		if not P.IsPossibleIllusion(enemy) and enemy:CanBeSeen() and GetUnitToLocationDistance(enemy, lanefront) < 2000 then
			return true
		end
	end
end