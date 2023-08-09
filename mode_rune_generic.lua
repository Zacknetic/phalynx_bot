if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or GetBot():IsIllusion() then
	return
end

local bot = GetBot()

local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local BottomBounty = RUNE_BOUNTY_2
local TopRiver = RUNE_POWERUP_1
local TopBounty = RUNE_BOUNTY_1
local BottomRiver = RUNE_POWERUP_2

local RiverRunes = {TopRiver, BottomRiver}
local AllRunes = {BottomBounty, TopRiver, TopBounty, BottomRiver}

local RuneMode = ""
local RuneToInvestigate = nil

function GetDesire()
	if P.IsInLaningPhase() then
		if DotaTime() >= -20 and DotaTime() < 1 then
			return 0.6
		else
			if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
				if DotaTime() < 60 * 6 and DotaTime() > 0 then
					if GetRuneStatus(TopRiver) == RUNE_STATUS_MISSING then
						return BOT_MODE_DESIRE_NONE
					elseif GetRuneStatus(TopRiver) == RUNE_STATUS_UNKNOWN or GetRuneStatus(TopRiver) == RUNE_STATUS_AVAILABLE then
						RuneMode = "Collect"
						RuneToInvestigate = TopRiver
						return 0.80
					else
						return BOT_MODE_DESIRE_NONE
					end
				elseif DotaTime() >= 60 * 6 and DotaTime() < 60 * 10 then
					local closestrune = nil
					local closestrune = 99999
				
					for v, rune in pairs(RiverRunes) do
						if GetUnitToLocationDistance(bot, GetRuneSpawnLocation(rune)) < closestrune then
							closestrune = GetUnitToLocationDistance(bot, GetRuneSpawnLocation(rune))
							RuneToInvestigate = rune
						end
					end
				end
			elseif PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
				if bot:GetTeam() == TEAM_RADIANT then
					if GetRuneStatus(TopBounty) == RUNE_STATUS_MISSING then
						return BOT_MODE_DESIRE_NONE
					elseif GetRuneStatus(TopBounty) == RUNE_STATUS_UNKNOWN or GetRuneStatus(TopBounty) == RUNE_STATUS_AVAILABLE then
						RuneMode = "Collect"
						RuneToInvestigate = TopBounty
						return 0.80
					end
				elseif bot:GetTeam() == TEAM_DIRE then
					if GetRuneStatus(BottomBounty) == RUNE_STATUS_MISSING then
						return BOT_MODE_DESIRE_NONE
					elseif GetRuneStatus(BottomBounty) == RUNE_STATUS_UNKNOWN or GetRuneStatus(BottomBounty) == RUNE_STATUS_AVAILABLE then
						RuneMode = "Collect"
						RuneToInvestigate = BottomBounty
						return 0.80
					end
				else
					return BOT_MODE_DESIRE_NONE
				end
			elseif PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
				if bot:GetTeam() == TEAM_RADIANT then
					if GetRuneStatus(BottomBounty) == RUNE_STATUS_MISSING then
						return BOT_MODE_DESIRE_NONE
					elseif GetRuneStatus(BottomBounty) == RUNE_STATUS_UNKNOWN or GetRuneStatus(BottomBounty) == RUNE_STATUS_AVAILABLE then
						RuneMode = "Collect"
						RuneToInvestigate = BottomBounty
						return 0.80
					end
				elseif bot:GetTeam() == TEAM_DIRE then
					if GetRuneStatus(TopBounty) == RUNE_STATUS_MISSING then
						return BOT_MODE_DESIRE_NONE
					elseif GetRuneStatus(TopBounty) == RUNE_STATUS_UNKNOWN or GetRuneStatus(TopBounty) == RUNE_STATUS_AVAILABLE then
						RuneMode = "Collect"
						RuneToInvestigate = TopBounty
						return 0.80
					end
				else
					return BOT_MODE_DESIRE_NONE
				end
			end
		end
	else
		local closestrune = nil
		local closestdistance = 99999
						
		for v, rune in pairs(AllRunes) do
			if GetUnitToLocationDistance(bot, GetRuneSpawnLocation(rune)) < closestdistance then
				closestrune = rune
				closestdistance = GetUnitToLocationDistance(bot, GetRuneSpawnLocation(rune))
			end
		end
			
		if closestdistance <= 3000 and (GetRuneStatus(closestrune) == RUNE_STATUS_UNKNOWN or GetRuneStatus(closestrune) == RUNE_STATUS_AVAILABLE) then
			RuneMode = "Collect"
			RuneToInvestigate = closestrune
			
			--if GetUnitToLocationDistance(bot, GetRuneSpawnLocation(closestrune)) <= 1600 then
			--	return 0.85
			--else
				return 0.80
			--end
		end
	end
	
	return BOT_MODE_DESIRE_NONE
end

function Think()
	if DotaTime() >= -20 and DotaTime() < 1 then
		if bot:GetTeam() == TEAM_RADIANT then
			if bot:GetAssignedLane() == LANE_TOP or bot:GetAssignedLane() == LANE_MID then
				bot:Action_MoveToLocation(GetRuneSpawnLocation(TopRiver))
			elseif bot:GetAssignedLane() == LANE_BOT then
				bot:Action_MoveToLocation(GetRuneSpawnLocation(BottomBounty))
			end
		elseif bot:GetTeam() == TEAM_DIRE then
			if bot:GetAssignedLane() == LANE_BOT or bot:GetAssignedLane() == LANE_MID then
				bot:Action_MoveToLocation(GetRuneSpawnLocation(BottomRiver))
			elseif bot:GetAssignedLane() == LANE_TOP then
				bot:Action_MoveToLocation(GetRuneSpawnLocation(TopBounty))
			end
		end
	else
		if RuneMode == "Investigate" then
			bot:Action_MoveToLocation(GetRuneSpawnLocation(RuneToInvestigate))
		elseif RuneMode == "Collect" then
			if GetUnitToLocationDistance(bot, GetRuneSpawnLocation(RuneToInvestigate)) > 50 then
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RuneToInvestigate)+RandomVector(25))
			else
				bot:Action_PickUpRune(RuneToInvestigate)
			end
		end
	end
end