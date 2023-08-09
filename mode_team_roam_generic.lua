local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

local bot = GetBot()
local RoamTarget = nil
local BotTarget = nil
local LastMessageTime = DotaTime()

local SuitableToEngageLaneTarget = false
local SuitableToAttackHero = false
local SuitableToAttackSpecialUnit = false
local SuitableToRoam = false

local RadiantSpawn = Vector(-6950,-6275)
local DireSpawn = Vector(7150, 6300)
local EnemyBase

function GetDesire()
	if bot:GetActiveMode() == BOT_MODE_ATTACK
	or bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY then return 0 end
	
	if P.IsRetreating(bot) then return 0 end

	if bot:GetTeam() == TEAM_RADIANT then
		EnemyBase = DireSpawn
	elseif bot:GetTeam() == TEAM_DIRE then
		EnemyBase = RadiantSpawn
	end
	
	SuitableToAttackSpecialUnit = CanAttackSpecialUnit()
	if SuitableToAttackSpecialUnit then
		return 0.97
	end
	
	--[[if P.IsInLaningPhase() then
		SuitableToEngageLaneTarget = CanEngageLaneTarget()
		if SuitableToEngageLaneTarget then
			return 0.83
		end
	end
	
	SuitableToAttackHero = CanAttackHero()
	if SuitableToAttackHero then
		return 0.85
	end]]--

	if not P.IsInLaningPhase() then
	--[[	SuitableToAttackHero = CanAttackHero()
		if SuitableToAttackHero then
			return 0.85
		end]]--
		
		SuitableToRoam = CanRoamToTarget()
		if SuitableToRoam then
			return 0.83
		end
	end
end

--[[function OnStart()
	if (DotaTime() - LastMessageTime) > 30 then
		LastMessageTime = DotaTime()
		local RoamLoc = RoamTarget:GetLocation()
		bot:ActionImmediate_Ping(RoamLoc.x, RoamLoc.y, true)
	end
end]]--

function Think()
	if (SuitableToAttackSpecialUnit or SuitableToAttackHero)
	and RoamTarget ~= nil
	and RoamTarget:CanBeSeen() then
		bot:Action_AttackUnit(RoamTarget, false)
		return
	end

	if SuitableToEngageLaneTarget then
		if (DotaTime() - LastMessageTime) > 30 then
			LastMessageTime = DotaTime()
			local RoamLoc = BotTarget:GetLocation()
			bot:ActionImmediate_Ping(RoamLoc.x, RoamLoc.y, true)
		end
	
		bot:Action_AttackUnit(BotTarget, false)
		return
	end

	if SuitableToRoam
	and RoamTarget ~= nil 
	and RoamTarget:CanBeSeen() then
		if (DotaTime() - LastMessageTime) > 30 then
			LastMessageTime = DotaTime()
			local RoamLoc = RoamTarget:GetLocation()
			bot:ActionImmediate_Ping(RoamLoc.x, RoamLoc.y, true)
		end
	
		if GetUnitToUnitDistance(bot, RoamTarget) > 1000 then
			bot:Action_MoveToLocation(RoamTarget:GetLocation())
		else
			bot:Action_AttackUnit(RoamTarget, false)
		end
	end
end

function OnEnd()
	SuitableToEngageLaneTarget = false
	SuitableToRoam = false

	RoamTarget = nil
	BotTarget = nil
	
	if bot.teamroaming == true then
		bot.teamroaming = false
	end
end

function CanEngageLaneTarget()
	if bot:GetHealth() < (bot:GetMaxHealth() * 0.5) then return 0 end
	
	local AssignedLane = bot:GetAssignedLane()
	local LaneFrontLoc = GetLaneFrontLocation(bot:GetTeam(), AssignedLane, 0)

	local EnemiesWithinRange = bot:GetNearbyHeroes(500, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if #FilteredEnemies > 0 then
		BotTarget = PAF.GetWeakestUnit(FilteredEnemies)
	end
	
	if BotTarget == nil then return false end
	
	local AlliesWithinRange = BotTarget:GetNearbyHeroes(500, true, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	print("Determining if we can go on "..BotTarget:GetUnitName())
	
	-- Offensive Power condition --
	local CombinedAlliesOffensivePower = 0
	local CombinedEnemiesOffensivePower = 0
	
	if #FilteredAllies > 0 then
		for v, Ally in pairs(FilteredAllies) do
			CombinedAlliesOffensivePower = (CombinedAlliesOffensivePower + Ally:GetOffensivePower())
		end
	end
	if #FilteredEnemies > 0 then
		for v, Enemy in pairs(FilteredEnemies) do
			CombinedEnemiesOffensivePower = (CombinedEnemiesOffensivePower + Enemy:GetRawOffensivePower())
		end
	end
	
	if CombinedAlliesOffensivePower >= CombinedEnemiesOffensivePower then
		print("Go on")
		return true
	end
	
	-- Estimated Damage condition --
	local CCDuration = 0.5
	local EstimatedTotalDamage = 0
	
	if #FilteredAllies > 0 then
		for v, Ally in pairs(FilteredAllies) do
			if Ally:HasBlink(true) then
				CCDuration = (CCDuration + 2)
			end
			
			CCDuration = (CCDuration + Ally:GetStunDuration(true))
			CCDuration = (CCDuration + Ally:GetSlowDuration(true))
		end
		
		for v, Ally in pairs(FilteredAllies) do
			EstimatedTotalDamage = (EstimatedTotalDamage + Ally:GetEstimatedDamageToTarget(true, BotTarget, CCDuration, DAMAGE_TYPE_ALL))
		end
	end
	
	local NearbyTowers = BotTarget:GetNearbyTowers(900, false)
	
	if EstimatedTotalDamage >= BotTarget:GetHealth()
	and #NearbyTowers == 0
	and GetUnitToLocationDistance(BotTarget, LaneFrontLoc) <= 500 then
		print("Go on")
		return true
	end
end

function CanAttackSpecialUnit()
	local SearchRange = bot:GetAttackRange()
	
	if SearchRange < 1000 then
		SearchRange = 1000
	end

	local EnemyUnits = GetUnitList(UNIT_LIST_ENEMIES)

	for v, Unit in pairs(EnemyUnits) do
		if string.find(Unit:GetUnitName(), "courier")
		or string.find(Unit:GetUnitName(), "tombstone")
		or string.find(Unit:GetUnitName(), "phoenix_sun")
		or string.find(Unit:GetUnitName(), "warlock_golem")
		or string.find(Unit:GetUnitName(), "ignis_fatuus")
		or string.find(Unit:GetUnitName(), "visage_familiar")
		or string.find(Unit:GetUnitName(), "grimstroke_ink_creature")
		or string.find(Unit:GetUnitName(), "observer_ward")
		or string.find(Unit:GetUnitName(), "sentry_ward") then
			if GetUnitToUnitDistance(bot, Unit) <= SearchRange then
				RoamTarget = Unit
				return true
			end
		end
	end
end

function CanAttackHero()
	if bot:GetHealth() <= (bot:GetMaxHealth() * 0.45) then return false end
	
	if P.IsInLaningPhase() then
		local LaneCreeps = bot:GetNearbyLaneCreeps(600, true)
		
		if #LaneCreeps > 0 then
			return false
		end
	end

	local SearchRange = bot:GetAttackRange()
	
	if SearchRange < 1000 then
		SearchRange = 1000
	end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(SearchRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	local AlliesWithinRange = bot:GetNearbyHeroes(SearchRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	if #FilteredEnemies > 0 and #FilteredAllies >= #FilteredEnemies then
		RoamTarget = PAF.GetWeakestUnit(FilteredEnemies)
		
		local NearbyTowers = RoamTarget:GetNearbyTowers(800, false)
		
		if #NearbyTowers == 0 or RoamTarget:DistanceFromFountain() < 100 then
			return true
		end
	end
	
	return false
end

function CanRoamToTarget()
	if bot:GetLevel() < 12 then return false end

	local initallies = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
		
	local allies = {}
	for v, ally in pairs(initallies) do
		if not P.IsPossibleIllusion(ally) and not P.IsMeepoClone(ally) then
			table.insert(allies, ally)
		end
	end
		
	local initenemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
		
	local enemies = {}
	for v, enemy in pairs(initenemies) do
		if not P.IsPossibleIllusion(enemy) then
			table.insert(enemies, enemy)
		end
	end
		
	local ClosestEnemy = nil
	local ClosestDistance = 99999
		
	for v, enemy in pairs(enemies) do
		if bot:GetLevel() < 12 then
			local enemytowers = enemy:GetNearbyTowers(1200, false)
			
			if P.IsValidTarget(enemy) and enemy:CanBeSeen() and GetUnitToUnitDistance(bot, enemy) <= 3000 and #enemytowers <= 0 and GetUnitToLocationDistance(enemy, EnemyBase) > 4000 then
				ClosestEnemy = enemy
				ClosestDistance = GetUnitToUnitDistance(bot, enemy)
			end
		elseif bot:GetLevel() >= 12 then
			if P.IsValidTarget(enemy) and enemy:CanBeSeen() and GetUnitToUnitDistance(bot, enemy) <= 3000 and GetUnitToLocationDistance(enemy, EnemyBase) > 4000 then
				ClosestEnemy = enemy
				ClosestDistance = GetUnitToUnitDistance(bot, enemy)
			end
		end
	end
		
	local EnemyAlliesNearby = {}
	local AlliesWithinRoamDistance = {}
		
	if P.IsValidTarget(ClosestEnemy) then	
		EnemyAlliesNearby = ClosestEnemy:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
		
		for v, ally in pairs(allies) do
			if ally:GetLevel() < 12 then
				local enemytowers = ClosestEnemy:GetNearbyTowers(1200, false)
			
				if ClosestEnemy:CanBeSeen() and GetUnitToUnitDistance(ally, ClosestEnemy) <= 3000 and #enemytowers <= 0 and GetUnitToLocationDistance(ClosestEnemy, EnemyBase) > 4000 then
					table.insert(AlliesWithinRoamDistance, ally)
				end
			elseif ally:GetLevel() >= 12 then
				if ClosestEnemy:CanBeSeen() and GetUnitToUnitDistance(ally, ClosestEnemy) <= 3000 and GetUnitToLocationDistance(ClosestEnemy, EnemyBase) > 4000 then
					table.insert(AlliesWithinRoamDistance, ally)
				end
			end
		end
			
		if #AlliesWithinRoamDistance > #EnemyAlliesNearby then
			RoamTarget = ClosestEnemy
			bot.teamroaming = true
			return true
		end
	end
	
	return false
end