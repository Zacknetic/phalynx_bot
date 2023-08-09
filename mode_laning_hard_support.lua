local team = bot:GetTeam() -- Get the team (Radiant or Dire)
local towerNumber

if team == TEAM_RADIANT then
  towerNumber = TOWER_BOT_1 -- Safe lane's first tower for Radiant
else
  towerNumber = TOWER_TOP_1 -- Safe lane's first tower for Dire
end

local tower = GetTower(team, towerNumber) -- Get the safe lane's first tower
local neutralSpawners = GetNeutralSpawners() -- Get the neutral camp locations

local closestCamp = nil
local minDistance = math.huge

for _, camp in pairs(neutralSpawners) do
  local distance = GetUnitToLocationDistance(tower, camp[2]) -- Calculate distance to camp
  if distance < minDistance then
    minDistance = distance
    closestCamp = camp
  end
end

function CalculateStartingPosition(campLocation)
	local ancient = GetAncient(bot:GetTeam()) -- Get the team's ancient
	local endingPosition = ancient:GetLocation() -- Get the location of the ancient
	
	local direction = (endingPosition - campLocation):Normalized() -- Direction towards ancient
	local distance = 250 -- Just outside the aggro radius
	local startingPosition = campLocation + direction * distance -- Calculate starting position
	
	-- Check if the location is passable and adjust if necessary
	while not IsLocationPassable(startingPosition) do
	  distance = distance + 10 -- Increment distance slightly
	  startingPosition = campLocation + direction * distance
	end
	
	return startingPosition
end

function CalculateArrivalTime(bot, destination)
	local currentLocation = bot:GetLocation()
	local movementSpeed = bot:GetCurrentMovementSpeed()
	
	GeneratePath(currentLocation, destination, nil, function(distance, waypoints)
	  if distance > 0 then
		local timeToArrive = distance / movementSpeed
		return timeToArrive, waypoints
	  else
		-- Handle pathfinding failure
		return nil, nil
	  end
	end)
end

function CalculateStackTime(bot, timeToArrive)
	local attackAnimationTime = bot:GetAttackPoint()
	local aggroRadius = 240
	local chaseDistance = 1750
	local timeForChase = 5
	
	if timeToArrive then
	  local timeToAggro = (aggroRadius + chaseDistance) / bot:GetCurrentMovementSpeed()
	  local totalStackTime = timeToArrive + attackAnimationTime + timeToAggro
	  
	  if totalStackTime <= 60 - timeForChase then
		return totalStackTime
	  else
		-- Handle case where stacking is not possible within the time limit
		return nil, nil
	  end
	else
	  -- Handle pathfinding failure
	  return nil, nil
	end
end

function GetDesire()
	local campLocation = closestCamp
	local startingPosition = startingPositions[campLocation]
	
	-- Calculate the time to arrive at the starting position
	local timeToArrive, waypoints = CalculateArrivalTime(bot, startingPosition)
	
	-- Calculate the total stack time
	local totalStackTime = CalculateStackTime(bot, timeToArrive)
	
	-- Calculate the remaining time before the next stack time
	local remainingTime = (60 - (GameTime() % 60)) - totalStackTime
	
	-- If stacking is possible, return a desire value based on the remaining time
	if totalStackTime and remainingTime > 0 then
	  bot:Action_Chat("Stacking is possible. Preparing to move.", false) -- Chat output
	  return math.min(0.9 + (0.1 * (1 - remainingTime / 60)), 1.0) -- Increase priority as remaining time decreases
	else
	  bot:Action_Chat("Stacking is not feasible.", false) -- Chat output
	  return 0.1 -- Low priority if stacking is not feasible
	end
end
  
  function Think()
	local campLocation = closestCamp
	local startingPosition = startingPositions[campLocation]
	
	-- Calculate the time to arrive at the starting position
	local timeToArrive, waypoints = CalculateArrivalTime(bot, startingPosition)
	
	-- If waypoints are available, move the bot along the path
	if waypoints and #waypoints > 0 then
	  local nextWaypoint = waypoints[1] -- Get the next waypoint
	  bot:Action_MoveToLocation(nextWaypoint) -- Move the bot to the next waypoint
	  bot:Action_Chat("Moving to the next waypoint.", false) -- Chat output
	else
	  bot:Action_Chat("Pathfinding failure. Unable to move.", false) -- Chat output
	  -- Handle pathfinding failure or other logic
	  -- ...
	end
	
	-- Additional logic to initiate stacking, attack the camp, etc.
	-- ...
end
  