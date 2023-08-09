local PAF = {}

local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

function PAF.CombineTables(TableOne, TableTwo)
	local CombinedTable = {}

	for v, TableItem in pairs(TableOne) do
		table.insert(CombinedTable, TableItem)
	end
	for v, TableItem in pairs(TableTwo) do
		table.insert(CombinedTable, TableItem)
	end
	
	return CombinedTable
end

function PAF.GetFountainLocation(unit)
	if unit:GetTeam() == TEAM_RADIANT then
		return Vector( -7169, -6654, 392 )
	elseif unit:GetTeam() == TEAM_DIRE then
		return Vector( 6974, 6402, 392 )
	end
	
	return nil
end

-- Detect illusions
function PAF.IsPossibleIllusion(unit)
	local bot = GetBot()

	--Detect ally illusions
	if unit:HasModifier('modifier_illusion') 
	   or unit:HasModifier('modifier_phantom_lancer_doppelwalk_illusion') or unit:HasModifier('modifier_phantom_lancer_juxtapose_illusion')
       or unit:HasModifier('modifier_darkseer_wallofreplica_illusion') or unit:HasModifier('modifier_terrorblade_conjureimage')	   
	then
		return true
	else
	   --Detect replicate and wall of replica illusions
	    if GetGameMode() ~= GAMEMODE_MO then
			if unit:GetTeam() ~= bot:GetTeam() then
				local TeamMember = GetTeamPlayers(GetTeam())
				for i = 1, #TeamMember
				do
					local ally = GetTeamMember(i)
					if ally ~= nil and ally:GetUnitName() == unit:GetUnitName() then
						return true
					end
				end
			end
		end
		return false
	end
end

function PAF.FilterTrueUnits(units)
	local trueunits = {}

	for v, unit in pairs(units) do
		if not PAF.IsPossibleIllusion(unit) then
			table.insert(trueunits, unit)
		end
	end
	
	return trueunits
end

function PAF.FilterUnitsForStun(units)
	local filteredunits = {}
	
	for v, unit in pairs(units) do
		if not PAF.IsPossibleIllusion(unit) 
		and not PAF.IsDisabled(unit) 
		and not PAF.IsMagicImmune(unit) then
			table.insert(filteredunits, unit)
		end
	end
	
	return filteredunits
end

-- Is the bot properly engaging an enemy?
function PAF.IsEngaging(SelectedUnit)
	local mode = SelectedUnit:GetActiveMode()
	return mode == BOT_MODE_ATTACK or
		   mode == BOT_MODE_DEFEND_ALLY or
		   mode == BOT_MODE_TEAM_ROAM
end

function PAF.IsInTeamFight(SelectedUnit)
	local nearbyallies = SelectedUnit:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
	local nearbyenemies = SelectedUnit:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	local trueallies = PAF.FilterTrueUnits(nearbyallies)
	local trueenemies = PAF.FilterTrueUnits(nearbyenemies)
	
	if #trueallies >= 2 and #trueenemies >= 2 and PAF.IsEngaging(SelectedUnit) then
		return true
	else
		return false
	end
end

-- Some bots have abilities with shorter ranges than their attack range, preventing ability usage
function PAF.GetProperCastRange(CastRange)
	local bot = GetBot()
	local AttackRange = bot:GetAttackRange()
	
	if CastRange < AttackRange then
		return (AttackRange + 50)
	else
		if (CastRange + 50) > 1600 then
			return 1600
		else
			return (CastRange + 50)
		end
	end
end

-- Valid unit checks
function PAF.IsValidHeroTarget(unit)
	return unit ~= nil 
	and unit:IsAlive() 
	and unit:IsHero()
	and unit:CanBeSeen()
end

function PAF.IsValidCreepTarget(unit)
	return unit ~= nil 
	and unit:IsAlive() 
	and unit:IsCreep()
	and unit:CanBeSeen()
end

function PAF.IsValidBuildingTarget(unit)
	return unit ~= nil 
	and unit:IsAlive() 
	and unit:IsBuilding()
	and unit:CanBeSeen()
end

function PAF.IsRoshan(unit)
	return unit ~= nil
	and unit:IsAlive() 
	and string.find(unit:GetUnitName(), "roshan")
end

function PAF.IsValidHeroAndNotIllusion(unit)
	return PAF.IsValidHeroTarget(unit)
	and not PAF.IsPossibleIllusion(unit)
end

-- Immunity checks
function PAF.IsMagicImmune(unit)
	if unit:IsInvulnerable() or unit:IsMagicImmune() then
		return true
	else
		return false
	end
end

function PAF.IsPhysicalImmune(unit)
	if unit:IsInvulnerable() or unit:IsAttackImmune() then
		return true
	else
		return false
	end
end

-- Disabled checks
function PAF.IsDisabled(unit)
	return (unit:IsRooted() or unit:IsStunned() or unit:IsHexed() or unit:IsNightmared() or PAF.IsTaunted(unit))
end

function PAF.IsTaunted(unit)
	return unit:HasModifier("modifier_axe_berserkers_call") 
	or unit:HasModifier("modifier_legion_commander_duel") 
	or unit:HasModifier("modifier_winter_wyvern_winters_curse") 
	or unit:HasModifier(" modifier_winter_wyvern_winters_curse_aura")
end

-- Get specific units
function PAF.GetWeakestUnit(units)
	local weakestunit = nil
	local lowesthealth = 99999

	for v, unit in pairs(units) do
		if not unit:HasModifier("modifier_item_chainmail")
		and not unit:HasModifier("modifier_abaddon_borrowed_time") then
			if unit:GetHealth() < lowesthealth then
				weakestunit = unit
				lowesthealth = unit:GetHealth()
			end
		end
	end
	
	return weakestunit
end

function PAF.GetHealthiestUnit(units)
	local healthiestunit = nil
	local highesthealth = 99999

	for v, unit in pairs(units) do
		if unit:GetHealth() < highesthealth then
			healthiestunit = unit
			highesthealth = unit:GetHealth()
		end
	end
	
	return healthiestunit
end

function PAF.GetStrongestPowerUnit(units)
	local strongestunit = nil
	local strongestpower = 0
	
	for v, unit in pairs(units) do
		if unit:GetRawOffensivePower() < strongestpower then
			strongestunit = unit
			strongestpower = unit:GetRawOffensivePower()
		end
	end
	
	return strongestunit
end

function PAF.GetStrongestAttackDamageUnit(units)
	local strongestunit = nil
	local strongestdamage = 0
	
	for v, unit in pairs(units) do
		if unit:GetAttackDamage() > strongestdamage then
			strongestunit = unit
			strongestdamage = unit:GetAttackDamage()
		end
	end
	
	return strongestunit
end

function PAF.GetClosestUnit(SelectedUnit, units)
	local closestunit = nil
	local shortestdistance = 99999

	for v, unit in pairs(units) do
		if GetUnitToUnitDistance(SelectedUnit, unit) < shortestdistance then
			closestunit = unit
			shortestdistance = GetUnitToUnitDistance(SelectedUnit, unit)
		end
	end
	
	return closestunit
end

function PAF.GetUnitsNearTarget(Loc, Units, Radius)
	local AoECount = 0
	
	for v, unit in pairs(Units) do
		if GetUnitToLocationDistance(unit, Loc) <= Radius then
			AoECount = (AoECount + 1)
		end
	end
	
	return AoECount
end

function PAF.IsChasing(SelectedUnit, Target)
	if SelectedUnit:IsFacingLocation(Target:GetLocation(), 10)
	and not Target:IsFacingLocation(SelectedUnit:GetLocation(), 150) then
		return true
	end

	return false
end

return PAF