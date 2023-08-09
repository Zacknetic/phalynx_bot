local bot = GetBot()

local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

local target = nil
local PATarget = nil
local desiremode = ""
local StartRunTime = 0
local RetreatTime = 0

function GetDesire()
	BotFindTarget()

	local allycreeps = bot:GetNearbyLaneCreeps(1000, false)
	local enemycreeps = bot:GetNearbyLaneCreeps(1000, true)
	local neutralcreeps = bot:GetNearbyNeutralCreeps(1000)
	
	target = nil
	
	local attackdmg = bot:GetAttackDamage()
	
	if DotaTime() > 0 then
		ShouldRetreat()
		if (DotaTime() - StartRunTime) < RetreatTime then
			desiremode = "ForceRetreat"
			return BOT_MODE_DESIRE_ABSOLUTE * 1.2
		end
	end
	
	if bot:GetUnitName() == "npc_dota_hero_shadow_shaman" then
		local Shackles = bot:GetAbilityByName("shadow_shaman_shackles")
		if Shackles:IsInAbilityPhase() or Shackles:IsChanneling() or bot:IsChanneling() then
			desiremode = "AbilityChannel"
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	if bot:GetUnitName() == "npc_dota_hero_drow_ranger" then
		local Multishot = bot:GetAbilityByName("drow_ranger_multishot")
		if Multishot:IsInAbilityPhase() or Multishot:IsChanneling() or bot:IsChanneling() then
			desiremode = "AbilityChannel"
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	if bot:GetUnitName() == "npc_dota_hero_enigma" then
		local BlackHole = bot:GetAbilityByName("enigma_black_hole")
		if BlackHole:IsInAbilityPhase() or BlackHole:IsChanneling() or bot:IsChanneling() then
			desiremode = "AbilityChannel"
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	if bot:GetUnitName() == "npc_dota_hero_pugna" then
		local LifeDrain = bot:GetAbilityByName("pugna_life_drain")
		if LifeDrain:IsInAbilityPhase() or LifeDrain:IsChanneling() or bot:IsChanneling() then
			desiremode = "AbilityChannel"
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	if bot:GetUnitName() == "npc_dota_hero_bane" then
		local FiendsGrip = bot:GetAbilityByName("bane_fiends_grip")
		if FiendsGrip:IsInAbilityPhase() or FiendsGrip:IsChanneling() or bot:IsChanneling() then
			desiremode = "AbilityChannel"
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	if bot:GetUnitName() == "npc_dota_hero_pudge" then
		local Dismember = bot:GetAbilityByName("pudge_dismember")
		if Dismember:IsInAbilityPhase() or Dismember:IsChanneling() or bot:IsChanneling() then
			desiremode = "AbilityChannel"
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	if bot:GetUnitName() == "npc_dota_hero_riki" then
		local TricksOfTheTrade = bot:GetAbilityByName("riki_tricks_of_the_trade")
		if TricksOfTheTrade:IsInAbilityPhase() or TricksOfTheTrade:IsChanneling() or bot:IsChanneling() then
			desiremode = "AbilityChannel"
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	if bot:GetUnitName() == "npc_dota_hero_sand_king" then
		local Epicenter = bot:GetAbilityByName("sandking_epicenter")
		if Epicenter:IsInAbilityPhase() or Epicenter:IsChanneling() or bot:IsChanneling() then
			desiremode = "AbilityChannel"
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	if bot:GetUnitName() == "npc_dota_hero_tiny" then
		local TreeVolley = bot:GetAbilityByName("tiny_tree_channel")
		if TreeVolley:IsInAbilityPhase() or TreeVolley:IsChanneling() or bot:IsChanneling() then
			desiremode = "AbilityChannel"
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	if bot:GetUnitName() == "npc_dota_hero_oracle" then
		local FortunesEnd = bot:GetAbilityByName("oracle_fortunes_end")
		if FortunesEnd:IsInAbilityPhase() or FortunesEnd:IsChanneling() or bot:IsChanneling() then
			desiremode = "AbilityChannel"
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	if bot:GetUnitName() == "npc_dota_hero_clinkz" then
		local BurningBarrage = bot:GetAbilityByName("clinkz_burning_barrage")
		if BurningBarrage:IsInAbilityPhase() or BurningBarrage:IsChanneling() or bot:IsChanneling() then
			desiremode = "AbilityChannel"
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	
	if P.IsInLaningPhase() then
		--[[if bot:GetUnitName() == "npc_dota_hero_nevermore" then
			local Shadowraze1 = bot:GetAbilityByName("nevermore_shadowraze1")
			local Shadowraze2 = bot:GetAbilityByName("nevermore_shadowraze2")
			local Shadowraze3 = bot:GetAbilityByName("nevermore_shadowraze3")
			local CastRange1 = Shadowraze1:GetSpecialValueInt("shadowraze_range")
			local CastRange2 = Shadowraze2:GetSpecialValueInt("shadowraze_range")
			local CastRange3 = Shadowraze3:GetSpecialValueInt("shadowraze_range")
			
			local enemies = bot:GetNearbyHeroes(825, true, BOT_MODE_NONE)
			target = P.GetWeakestEnemyHero(enemies)
			
			local towers = bot:GetNearbyTowers(825, true)
			
			if target ~= nil and Shadowraze1:GetLevel() >= 2 and #towers <= 0 then
				if Shadowraze2:IsFullyCastable() and not P.CantUseAbility(bot) and GetUnitToUnitDistance(bot, target) < CastRange2 + 100 and GetUnitToUnitDistance(bot, target) > CastRange2 - 100 then
					desiremode = "SFRaze"
					return BOT_MODE_DESIRE_HIGH
				elseif Shadowraze3:IsFullyCastable() and not P.CantUseAbility(bot) and GetUnitToUnitDistance(bot, target) < CastRange3 + 100 and GetUnitToUnitDistance(bot, target) > CastRange3 - 100 then
					desiremode = "SFRaze"
					return BOT_MODE_DESIRE_HIGH
				end
			end
		end]]--
	
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" or PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" or PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
			if IsSuitableToLastHit() then
				if CanLastHitCreep(enemycreeps) then
					desiremode = "LH"
					return BOT_MODE_DESIRE_ABSOLUTE * 1.12
				end
				if CanLastHitCreep(allycreeps) then
					desiremode = "Deny"
					return BOT_MODE_DESIRE_ABSOLUTE * 1.12
				end
			end
		elseif PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" or PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
			if IsSuitableToLastHit() then
				if CanLastHitCreep(allycreeps) then
					desiremode = "Deny"
					return BOT_MODE_DESIRE_ABSOLUTE * 1.12
				end
				if CanLastHitCreep(enemycreeps) then
					desiremode = "StopLH"
					return BOT_MODE_DESIRE_ABSOLUTE * 1.12
				end
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_RETREAT then
		if bot:GetAttackTarget() ~= nil and ShouldIgnoreRetreatMode() then
			desiremode = "IgnoreRetreat"
			return BOT_MODE_DESIRE_ABSOLUTE * 1.1
		end
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" or PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" or PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		if IsSuitableToLastHit()
		and bot:GetActiveMode() ~= BOT_MODE_DEFEND_TOWER_TOP
		and bot:GetActiveMode() ~= BOT_MODE_DEFEND_TOWER_MID
		and bot:GetActiveMode() ~= BOT_MODE_DEFEND_TOWER_BOT then
			if CanLastHitCreep(enemycreeps) then
				desiremode = "LH"
				return BOT_MODE_DESIRE_ABSOLUTE * 1.12
			end
		end
	end
	
	return 0
end

function Think()
	if desiremode == "LH" or desiremode == "Deny" then
		bot:Action_AttackUnit(target, false)
	elseif desiremode == "StopLH" then
		bot:Action_ClearActions(false)
	elseif desiremode == "IgnoreRetreat" then
		bot:Action_AttackUnit(bot:GetAttackTarget(), false)
	elseif desiremode == "Harass" then
		bot:Action_AttackUnit(bot:GetAttackTarget(), false)
	elseif desiremode == "PartnerAttack" then
		bot:Action_AttackUnit(PATarget, true)
	elseif desiremode == "SFRaze" and target ~= nil then
		bot:Action_MoveToLocation(target:GetLocation())
	elseif desiremode == "ForceRetreat" then
		if P.IsInLaningPhase() then
			local FriendlyTowers = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS)
			local ClosestTower = nil
			local ClosestDistance = 99999999
			
			for v, Tower in pairs(FriendlyTowers) do
				if Tower:IsTower() and GetUnitToUnitDistance(bot, Tower) < ClosestDistance then
					ClosestTower = Tower
					ClosestDistance = GetUnitToUnitDistance(bot, Tower)
				end
			end
			
			local RetreatSpot = ClosestTower:GetLocation()
			
			local Enemies = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)
			
			for v, enemy in pairs(Enemies) do
				if GetUnitToUnitDistance(enemy, ClosestTower) <= 800 then
					if bot:GetTeam() == TEAM_RADIANT then
						RetreatSpot = Vector(-7174.0, -6671.0, 0.0)
					elseif bot:GetTeam() == TEAM_DIRE then
						RetreatSpot = Vector(7023.0, 6450.0, 0.0)
					end
					
					break
				end
			end
			
			bot:Action_MoveToLocation(RetreatSpot)
		else
			if bot:GetTeam() == TEAM_RADIANT then
				bot:Action_MoveToLocation(Vector(-7174.0, -6671.0, 0.0))
			elseif bot:GetTeam() == TEAM_DIRE then
				bot:Action_MoveToLocation(Vector(7023.0, 6450.0, 0.0))
			end
		end
	elseif desiremode == "AbilityChannel" then
	end
end

function OnEnd()
	StartRunTime = 0
	RetreatTime = 0
end

-----------------------------------------------------------------------------------------------------------------------------

function GetWeakestAttackableUnit(units)
	local weakestunit = nil
	local lowesthealth = 99999

	for v, unit in pairs(units) do
		if not unit:HasModifier("modifier_item_chainmail")
		and not unit:HasModifier("modifier_abaddon_borrowed_time")
		and not PAF.IsPhysicalImmune(unit) then
			if unit:GetHealth() < lowesthealth then
				weakestunit = unit
				lowesthealth = unit:GetHealth()
			end
		end
	end
	
	return weakestunit
end

function BotFindTarget()
	local tBot = GetBot()
	local BotTarget = tBot:GetTarget()
	
	if not PAF.IsValidHeroAndNotIllusion(BotTarget) then return 0 end
	
	local AttackRange = tBot:GetAttackRange()
	if AttackRange > 1600 then AttackRange = 1600 end
	if AttackRange < 300 then AttackRange = 350 end
	
	local EnemiesWithinRange = tBot:GetNearbyHeroes(AttackRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	local PotentialTarget = GetWeakestAttackableUnit(FilteredEnemies)
	
	if PAF.IsValidHeroAndNotIllusion(PotentialTarget)
	and GetUnitToUnitDistance(tBot, BotTarget) > AttackRange then
		tBot:SetTarget(PotentialTarget)
		return
	end
end

function CanLastHitCreep(creeps)
	local attackdmg = bot:GetAttackDamage()

	for v, hcreep in pairs(creeps) do
		if #creeps > 0 and hcreep ~= nil and hcreep:CanBeSeen() then
			local incdmg = hcreep:GetActualIncomingDamage(attackdmg, DAMAGE_TYPE_PHYSICAL)
					
			local projectiles = hcreep:GetIncomingTrackingProjectiles()
			local casterdmg = 0
			local projloc = Vector(0,0,0)
					
			for i, proj in pairs(projectiles) do
				if proj.is_attack == true then
					local caster = proj.caster
							
					if caster ~= nil and caster:CanBeSeen() then
						casterdmg = caster:GetAttackDamage()
						projloc = proj.location
						break
					end
				end
			end
					
			local actualcasterdmg = hcreep:GetActualIncomingDamage(casterdmg, DAMAGE_TYPE_PHYSICAL)
				
			if hcreep:GetHealth() <= incdmg or ((hcreep:GetHealth() - actualcasterdmg) < incdmg and GetUnitToLocationDistance(hcreep, projloc) <= 300) then
				target = hcreep
				return true
			end
		end
	end
	
	return false
end

function IsSuitableToLastHit()
	return bot:GetActiveMode() ~= BOT_MODE_EVASIVE_MANEUVERS
	and not P.IsRetreating(bot)
	and not PAF.IsEngaging(bot)
	and bot:GetHealth() > (bot:GetMaxHealth() * 0.35)
end

function ShouldRetreat()
	if not ShouldIgnoreRetreatMode() then
		if bot:GetUnitName() == "npc_dota_hero_batrider" then
			if bot:HasModifier("modifier_batrider_flaming_lasso")
			or bot:HasModifier("modifier_batrider_flaming_lasso_self")
			or bot:HasModifier("modifier_batrider_flaming_lasso_damage") then
				return true
			end	
		end
	
		if P.IsInLaningPhase() then
			local towers = bot:GetNearbyTowers(1000, true)
			if #towers >= 1 then
				StartRunTime = DotaTime()
				RetreatTime = 1
				return true
			end
			
			--[[local InitAllies = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
			local InitEnemies = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
			local Allies = PAF.FilterTrueUnits(InitAllies)
			local Enemies = PAF.FilterTrueUnits(InitEnemies)
			
			if #Allies < #Enemies then
				StartRunTime = DotaTime()
				RetreatTime = 3
				return true
			end]]--

			return false
		else
			--[[local InitAllies = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
			local InitEnemies = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
			local Allies = PAF.FilterTrueUnits(InitAllies)
			local Enemies = PAF.FilterTrueUnits(InitEnemies)
			
			if (#Enemies - #Allies) >= 2 and not PAF.IsEngaging(bot) then
				StartRunTime = DotaTime()
				RetreatTime = 3
				return true
			end]]--
		end
		return false
	end
end

function ShouldIgnoreRetreatMode()
	if P.IsInPhalanxTeamFight(bot) then
		if bot:HasModifier("modifier_item_satanic_unholy") 
		or bot:HasModifier("modifier_abaddon_borrowed_time")
		or bot:HasModifier("modifier_item_mask_of_madness_berserk")
		or bot:HasModifier("modifier_oracle_false_promise_timer")
		or bot:HasModifier("modifier_black_king_bar_immune") then
			return true
		end
		
		if bot:GetUnitName() == "npc_dota_hero_razor" and bot:GetLevel() >= 6 then
			if bot:HasModifier("modifier_item_bloodstone_active") then
				return true
			end
		end
		
		if bot:GetUnitName() == "npc_dota_hero_skeleton_king" and bot:GetLevel() >= 6 then
			local Reincarnation = bot:GetAbilityByName("skeleton_king_reincarnation")
			
			if Reincarnation:GetCooldownTimeRemaining() <= 1 and bot:GetMana() >= Reincarnation:GetManaCost() then
				return true
			end
		end
	end

	return false
end

function CanAttackWithPartner()
	--if PRoles.GetPRole(bot, bot:GetUnitName()) ~= "MidLane" then
		local allies = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)
		local enemies = bot:GetNearbyHeroes(600, true, BOT_MODE_NONE)
		local attacktarget = PAF.GetWeakestUnit(enemies)
		local AttackRange = bot:GetAttackRange()
		
		local CCPower = 2
		local TargetHealth = 0
		local EstimatedDamage = 0
		
		if attacktarget ~= nil then
			for v, AllyP in pairs(allies) do
				local StunDuration = AllyP:GetStunDuration(true)
				local SlowDuration = AllyP:GetSlowDuration(true)
				
				CCPower = CCPower + (StunDuration + SlowDuration)
			end
			
			for v, AllyP in pairs(allies) do
				EstimatedDamage = EstimatedDamage + AllyP:GetEstimatedDamageToTarget(true, attacktarget, CCPower, DAMAGE_TYPE_ALL)
			end
			
			local TargetHealth = attacktarget:GetHealth()
			print (EstimatedDamage.." to "..TargetHealth)
		end
		
		if attacktarget ~= nil and #allies >= 2 and EstimatedDamage > TargetHealth and GetUnitToUnitDistance(bot, attacktarget) <= 800 and GetUnitToUnitDistance(allies[2], attacktarget) <= 600 then
			PATarget = attacktarget
			return true
		end
	--end
	
	return false
end