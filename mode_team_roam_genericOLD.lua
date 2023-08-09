local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local bot = GetBot()
local RoamTarget = nil
local LastMessageTime = DotaTime()

local RadiantSpawn = Vector(-6950,-6275)
local DireSpawn = Vector(7150, 6300)

function GetDesire()
	if bot:GetLevel() < 12 then return 0 end

	local EnemyBase
	if bot:GetTeam() == TEAM_RADIANT then
		EnemyBase = DireSpawn
	elseif bot:GetTeam() == TEAM_DIRE then
		EnemyBase = RadiantSpawn
	end

	if not P.IsInLaningPhase() then
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
				return BOT_MODE_DESIRE_HIGH
			end
		end
	end
end

function OnStart()
	if (DotaTime() - LastMessageTime) > 30 then
		LastMessageTime = DotaTime()
		local RoamLoc = RoamTarget:GetLocation()
		bot:ActionImmediate_Ping(RoamLoc.x, RoamLoc.y, true)
--		bot:ActionImmediate_Chat(("Roaming to "..RoamTarget:GetUnitName().." to gank"), false)
	end
end

function Think()
	if RoamTarget ~= nil and RoamTarget:CanBeSeen() then
		if GetUnitToUnitDistance(bot, RoamTarget) > 1000 then
			bot:Action_MoveToLocation(RoamTarget:GetLocation())
		else
			bot:Action_AttackUnit(RoamTarget, false)
		end
	end
end

function OnEnd()
	RoamTarget = nil
end