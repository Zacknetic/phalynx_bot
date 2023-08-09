local PDefend = {}

local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

local enemies

function NotNilOrDead(unit)
	if unit == nil or unit:IsNull() then
		return false
	end
	if unit:IsAlive() then
		return true
	end
	return false
end

function PDefend.GetDefendDesire(bot, lane)
	local BuildingToDefend = GetCurrentBuilding(bot, lane)

	if not P.IsInLaningPhase() then
		if ShouldUrgentDefend(BuildingToDefend, bot, lane) then
			if #enemies == 1 then
				if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" 
				or PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
					return BOT_MODE_DESIRE_VERYHIGH
				end
			elseif #enemies == 2 then
				if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" 
				or PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" 
				or PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
					return BOT_MODE_DESIRE_VERYHIGH
				end
			elseif #enemies == 3 then
				if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" 
				or PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" 
				or PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane"
				or PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
					return BOT_MODE_DESIRE_VERYHIGH
				end
			elseif #enemies >= 4 then
				return BOT_MODE_DESIRE_VERYHIGH
			end
		else
			return BOT_MODE_DESIRE_NONE
		end
	end
end

function ShouldUrgentDefend(BuildingToDefend, bot, lane)
	if BuildingToDefend == GetAncient(bot:GetTeam()) then
		return true
	else
		local AliveAllies = 0

		local IDs = GetTeamPlayers(GetTeam())
		for v, id in pairs(IDs) do
			if IsHeroAlive(id) then
				AliveAllies = AliveAllies + 1
			end
		end
		
		enemies = {}
	
		for v, enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
			local distance = GetUnitToUnitDistance(BuildingToDefend, enemy)
			local lanefrontloc = GetLaneFrontLocation(bot:GetTeam(), lane, 0)
			
			if distance <= 1600
			and GetUnitToLocationDistance(BuildingToDefend, lanefrontloc) <= 1600
			and not PAF.IsPossibleIllusion(enemy)
			and not P.IsMeepoClone(enemy) then
				table.insert(enemies, enemy)
			end
		end
		
		if (AliveAllies - #enemies) >= -1 then
			return true
		else
			return false
		end
	end
	
	return false
end

function GetCurrentBuilding(bot, lane)
	if lane == LANE_TOP then
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_TOP_1)) then
			return GetTower(bot:GetTeam(), TOWER_TOP_1)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_TOP_2)) then
			return GetTower(bot:GetTeam(), TOWER_TOP_2)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_TOP_3)) then
			return GetTower(bot:GetTeam(), TOWER_TOP_3)
		end
		if NotNilOrDead(GetBarracks(bot:GetTeam(), BARRACKS_TOP_MELEE)) then
			return GetBarracks(bot:GetTeam(), BARRACKS_TOP_MELEE)
		end
		if NotNilOrDead(GetBarracks(bot:GetTeam(), BARRACKS_TOP_RANGED)) then
			return GetBarracks(bot:GetTeam(), BARRACKS_TOP_RANGED)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BASE_1)) then
			return GetTower(bot:GetTeam(), TOWER_BASE_1)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BASE_2)) then
			return GetTower(bot:GetTeam(), TOWER_BASE_2)
		end
		if NotNilOrDead(GetAncient(bot:GetTeam())) then
			return GetAncient(bot:GetTeam())
		end
	end
	
	if lane == LANE_MID then
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_MID_1)) then
			return GetTower(bot:GetTeam(), TOWER_MID_1)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_MID_2)) then
			return GetTower(bot:GetTeam(), TOWER_MID_2)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_MID_3)) then
			return GetTower(bot:GetTeam(), TOWER_MID_3)
		end
		if NotNilOrDead(GetBarracks(bot:GetTeam(), BARRACKS_MID_MELEE)) then
			return GetBarracks(bot:GetTeam(), BARRACKS_MID_MELEE)
		end
		if NotNilOrDead(GetBarracks(bot:GetTeam(), BARRACKS_MID_RANGED)) then
			return GetBarracks(bot:GetTeam(), BARRACKS_MID_RANGED)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BASE_1)) then
			return GetTower(bot:GetTeam(), TOWER_BASE_1)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BASE_2)) then
			return GetTower(bot:GetTeam(), TOWER_BASE_2)
		end
		if NotNilOrDead(GetAncient(bot:GetTeam())) then
			return GetAncient(bot:GetTeam())
		end
	end
	
	if lane == LANE_BOT then
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BOT_1)) then
			return GetTower(bot:GetTeam(), TOWER_BOT_1)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BOT_2)) then
			return GetTower(bot:GetTeam(), TOWER_BOT_2)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BOT_3)) then
			return GetTower(bot:GetTeam(), TOWER_BOT_3)
		end
		if NotNilOrDead(GetBarracks(bot:GetTeam(), BARRACKS_BOT_MELEE)) then
			return GetBarracks(bot:GetTeam(), BARRACKS_BOT_MELEE)
		end
		if NotNilOrDead(GetBarracks(bot:GetTeam(), BARRACKS_BOT_RANGED)) then
			return GetBarracks(bot:GetTeam(), BARRACKS_BOT_RANGED)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BASE_1)) then
			return GetTower(bot:GetTeam(), TOWER_BASE_1)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BASE_2)) then
			return GetTower(bot:GetTeam(), TOWER_BASE_2)
		end
		if NotNilOrDead(GetAncient(bot:GetTeam())) then
			return GetAncient(bot:GetTeam())
		end
	end
end

return PDefend