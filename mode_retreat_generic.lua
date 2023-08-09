local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

local bot = GetBot()
local UrgentRetreat = false

function GetDesire()
	local RetreatDesire = 0
	
	local BotHealth = bot:GetHealth()
	local BotMaxHealth = bot:GetMaxHealth()
	
	if bot:GetUnitName() == "npc_dota_hero_medusa" then
		BotHealth = (BotHealth + bot:GetMana())
		BotMaxHealth = (BotMaxHealth + bot:GetMaxMana())
	end
	
	local HealthMissing = (BotMaxHealth - BotHealth)
	
	local HealthRetreatVal = RemapValClamped(HealthMissing, 0, BotMaxHealth, 0.0, 1.0)
	local RecentlyDamagedVal = 0.2 -- The amount to add if the bot is being attacked by a hero(s)
	local OutnumberedVal = 0.3 -- Multiplier for every hero that outnumbers the bot team
	local SafeVal = 0.25 -- How much to subtract from the desire to retreat if there are no visible enemy heroes
	
	if (BotHealth <= (BotMaxHealth * 0.3) or bot:GetMana() <= (bot:GetMaxMana() * 0.2)) and bot:DistanceFromFountain() < 3500 then
		UrgentRetreat = true
	elseif UrgentRetreat and BotHealth > (BotMaxHealth * 0.95) then
		UrgentRetreat = false
	end
	
	if UrgentRetreat then
		return 0.9
	end
	
	RetreatDesire = HealthRetreatVal
	
	if bot:WasRecentlyDamagedByAnyHero(1) or bot:WasRecentlyDamagedByTower(1) then
		RetreatDesire = (RetreatDesire + RecentlyDamagedVal)
	end
	
	local Allies = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	local Enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	
	local TrueAllies = {}
	local TrueEnemies = {}
	
	if #Allies > 0 and #Enemies > 0 then
		for v, Ally in pairs(Allies) do
			if not PAF.IsPossibleIllusion(Ally)
			and not P.IsMeepoClone(Ally)
			and not Ally:HasModifier("modifier_arc_warden_tempest_double") then
				table.insert(TrueAllies, Ally)
			end
		end
		
		for v, Enemy in pairs(Enemies) do
			if not PAF.IsPossibleIllusion(Enemy)
			and not P.IsMeepoClone(Enemy)
			and not Enemy:HasModifier("modifier_arc_warden_tempest_double") then
				table.insert(TrueEnemies, Enemy)
			end
		end
		
		if (#TrueEnemies - #TrueAllies) > 0 then
			local Difference = (#TrueEnemies - #TrueAllies)
			local OVal = (OutnumberedVal * Difference)
			
			RetreatDesire = (RetreatDesire + OVal)
		end
	end
	
	if #TrueEnemies == 0 then
		RetreatDesire = (RetreatDesire - SafeVal)
	end
	
	local ClampedRetreatDesire = Clamp(RetreatDesire, 0.0, 1.0)
	return ClampedRetreatDesire
end