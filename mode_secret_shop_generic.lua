local bot = GetBot()

local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

local BuildingTarget = nil

local ShouldCollectWisdomRune = false
local IsAllyCheckingWisdomRune = false
local ShouldKillTormentor = false

local WisdomAlly = nil

local TeamTormentor
local RT = Vector( -8122, -1218, 256 )
local DT = Vector( 8127, 1025, 256 )

local TeamWisdomRune
local RWR = Vector( -8126, -320, 256 )
local DWR = Vector( 8319, 266, 256 )

local LastWisdomRuneTime = 0
local LastTormentorTime = 0

local CheckTimer = 0

local LastMessageTime = DotaTime()

function GetDesire()
	if bot:GetTeam() == TEAM_RADIANT then
		TeamWisdomRune = RWR
		TeamTormentor = RT
	elseif bot:GetTeam() == TEAM_DIRE then
		TeamWisdomRune = DWR
		TeamTormentor = DT
	end
	
	--ShouldCollectWisdomRune = IsWisdomRuneAvailable()
	ShouldKillTormentor = IsTormentorAlive()
	
	--[[if WisdomAlly == bot then
		return 0.80
	end]]--
	
	if ShouldKillTormentor then
		return 0.81
	end
	
	return BOT_MODE_DESIRE_NONE
end

function Think()
	if bot:GetTeam() == TEAM_RADIANT then
		TeamWisdomRune = RWR
		TeamTormentor = RT
	elseif bot:GetTeam() == TEAM_DIRE then
		TeamWisdomRune = DWR
		TeamTormentor = DT
	end

	if WisdomAlly == bot then
		if CheckTimer > 0 and DotaTime() - CheckTimer >= 1 then
			--LastWisdomRuneTime = DotaTime()
			IsAllyCheckingWisdomRune = false
			WisdomAlly = nil
		end
		
		if GetUnitToLocationDistance(bot, TeamWisdomRune) > 50 then
			bot:Action_MoveToLocation(TeamWisdomRune)
			return
		else
			if CheckTimer == 0 then
				CheckTimer = DotaTime()
			end
			
			return
		end
	end

	if ShouldKillTormentor then
		if GetUnitToLocationDistance(bot, TeamTormentor) > 700 then
			bot:Action_MoveToLocation(TeamTormentor)
			return
		else
			local NC = bot:GetNearbyNeutralCreeps(450)
			
			for v, creep in pairs(NC) do
				if string.find(creep:GetUnitName(), "miniboss") then
					if IsReadyToAttackTormentor() then
						bot:Action_AttackUnit(creep, false)
					end
					
					if (DotaTime() - LastMessageTime) > 30 then
						LastMessageTime = DotaTime()
						bot:ActionImmediate_Chat("Let's kill the Tormentor!", false)
						bot:ActionImmediate_Ping(creep:GetLocation().x, creep:GetLocation().y, true)
					end
					
					return
				end
			end
		end
		return
	end
end

function OnEnd()
	BuildingTarget = nil
	CheckTimer = 0
end

function IsWisdomRuneAvailable()
	if DotaTime() >= (7 * 60) and ShouldCheckWisdomRune() and not IsAllyCheckingWisdomRune then
		IsAllyCheckingWisdomRune = true
		LastWisdomRuneTime = DotaTime()
		
		if GetClosestBotToWisdomRune() == bot then
			WisdomAlly = bot
		end
		
		return true
	end
	
	return false
end

function GetClosestBotToWisdomRune()
	local allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local ClosestBot = nil
	local ClosestDistance = 99999999

	for v, allyhero in pairs(allies) do
		if not PAF.IsPossibleIllusion(allyhero)
		and allyhero:IsBot() then
			if GetUnitToLocationDistance(allyhero, TeamWisdomRune) <= ClosestDistance then
				ClosestBot = allyhero
				ClosestDistance = GetUnitToLocationDistance(allyhero, TeamWisdomRune)
			end
		end
	end
	
	return ClosestBot
end

function IsTormentorAlive()
	if DotaTime() >= (20 * 60) and ShouldCheckTormentor() then
		if IsLocationVisible(TeamTormentor) and IsAllyChecking(TeamTormentor) then
			local NeutralCreeps = GetUnitList(UNIT_LIST_NEUTRAL_CREEPS)
			
			for v, Creep in pairs(NeutralCreeps) do
				if string.find(Creep:GetUnitName(), "miniboss") and GetUnitToLocationDistance(Creep, TeamTormentor) <= 200 then
					return true
				end
			end
			
			LastTormentorTime = DotaTime()
			return false
		else
			return true -- If we don't have vision on the tormentor, assume it's alive and go to check
		end
	else
		return false
	end
end

function ShouldCheckWisdomRune()
	if (DotaTime() - LastWisdomRuneTime) > 420 then
		return true
	else
		return false
	end
end

function ShouldCheckTormentor()
	if (DotaTime() - LastTormentorTime) > 600
	and bot:GetHealth() > (bot:GetMaxHealth() * 0.25)
	and IsTeamSuitableToTormentor() then
		return true
	else
		return false
	end
end

function IsAllyChecking(loc)
	local allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	
	for v, ally in pairs(allies) do
		if GetUnitToLocationDistance(ally, loc) <= 450 then
			return true
		end
	end
	
	return false
end

function IsTeamSuitableToTormentor()
	local allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	for v, allyhero in pairs(allies) do
		if P.IsDefending(allyhero) then
			return false
		end
	end

	local AliveAllies = 0
	
	local IDs = GetTeamPlayers(GetTeam())
	for v, id in pairs(IDs) do
		if IsHeroAlive(id) then
			AliveAllies = AliveAllies + 1
		end
	end
	
	if AliveAllies == 5 then
		return true
	end
	
	return false
end

function IsReadyToAttackTormentor()
	local BotAllies = 0
	
	local IDs = GetTeamPlayers(GetTeam())
	for v, id in pairs(IDs) do
		if IsPlayerBot(id) then
			BotAllies = BotAllies + 1
		end
	end
	
	local allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local NearAllies = 0
	
	for v, allyhero in pairs(allies) do
		if allyhero:IsAlive()
		and not PAF.IsPossibleIllusion(allyhero)
		and not P.IsMeepoClone(allyhero)
		and not allyhero:HasModifier("modifier_arc_warden_tempest_double") then
			if GetUnitToUnitDistance(allyhero, bot) <= 800 then
				NearAllies = (NearAllies + 1)
			end
		end
	end
	
	if (BotAllies - NearAllies) <= 1 then
		return true
	else
		return false
	end
end