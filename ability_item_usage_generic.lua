local BotsInit = require("game/botsinit")
local MyModule = BotsInit.CreateGeneric()

local bot = GetBot()

if bot:GetUnitName() == 'npc_dota_hero_monkey_king' then
	local trueMK = nil;
	for i, id in pairs(GetTeamPlayers(GetTeam())) do
		if IsPlayerBot(id) and GetSelectedHeroName(id) == 'npc_dota_hero_monkey_king' then
			local member = GetTeamMember(i)
			if member ~= nil then
				trueMK = member
			end
		end
	end
	if trueMK ~= nil and bot ~= trueMK then
		print("AbilityItemUsage "..tostring(bot).." isn't true MK")
		return;
	elseif trueMK == nil or bot == trueMK then
		print("AbilityItemUsage "..tostring(bot).." is true MK")
	end
end

if bot:IsInvulnerable() or bot:IsHero() == false or bot:IsIllusion()
then
	return
end

local HeroInfoFile = "NOT IMPLEMENTED"

if bot:IsHero() then
	HeroInfoFile = require(GetScriptDirectory() .. "/HeroInfo/" .. string.gsub(GetBot():GetUnitName(), "npc_dota_hero_", ""));
end

local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PItems = require(GetScriptDirectory() .. "/Library/PhalanxItems")
local PIU = require(GetScriptDirectory() .. "/Library/PhalanxItemUsage")

bot.castAmuletTime = DotaTime();
local backpack_item = {};
local update_bi_time = -90;

local courierTime = -90
local cState = -1
bot.SShopUser = false
local returnTime = -90
local apiAvailable = true

bot.courierID = 0
bot.courierAssigned = false
local checkCourier = false
local define_courier = false
local cr = nil
local tm =  GetTeam()
local pIDs = GetTeamPlayers(tm)

local bbtime = {}
bbtime['lastbbtime'] = -90;

function AbilityUsageThink()
	if P.IsMeepoClone(bot) then
		HeroInfoFile = "/HeroInfo/meepo"
	end

	HeroInfoFile.UseAbilities()
end

function ItemUsageThink()
	if bot:IsAlive() == false 
	   or bot:IsHero() == false 
	   or bot:IsMuted() == true 
	   or bot:IsHexed() == true
	   or bot:IsStunned() == true
	   or bot:IsChanneling() == true
	   or bot:IsInvulnerable() == true
	   or bot:IsUsingAbility() == true
	   or bot:IsCastingAbility() == true
	   or bot:NumQueuedActions() > 0 
	   or P.IsTaunted(bot) == true
	   or bot:HasModifier('modifier_teleporting') == true
	   or bot:HasModifier('modifier_doom_bringer_doom') == true
	   or bot:HasModifier('modifier_phantom_lancer_phantom_edge_boost') == true
	   or ( bot:IsInvisible() == true and not bot:HasModifier("modifier_phantom_assassin_blur_active") == true )
    then 
		return	BOT_ACTION_DESIRE_NONE 
	end
	
	local extra_range = 0;
	local aether_lens_slot_type = bot:GetItemSlotType(bot:FindItemSlot('item_aether_lens'))
	if aether_lens_slot_type == ITEM_SLOT_TYPE_MAIN 
	then
		extra_range = extra_range + 225
	end

	local item_slot = {0,1,2,3,4,5,15,16}
	local mode = bot:GetActiveMode()
	for i=1, #item_slot do
		local item = bot:GetItemInSlot(item_slot[i])
		if PIU.CanCastItem(item) == true 
			and JustSwapped(item:GetName()) == false
			and ShouldNotUseNeutralItemFromMainSlot(item:GetName(), item_slot[i]) == false
			and PIU.Use[item:GetName()] ~= nil
		then
			local desire, target, target_type = PIU.Use[item:GetName()](item, bot, mode, extra_range)
			if desire > BOT_ACTION_DESIRE_NONE 
			then
				if target_type == 'no_target' then
					bot:Action_UseAbility(item)
					return
				elseif target_type == 'point' then
					bot:Action_UseAbilityOnLocation(item, target)
					return;
				elseif target_type == 'unit' then
					bot:Action_UseAbilityOnEntity(item, target)
					return;
				elseif target_type == 'tree' then
					bot:Action_UseAbilityOnTree(item, target)
					return;
				end
			end
		end	
	end
end

function CourierUsageThink()
	if P.pIDInc < #pIDs + 1 and DotaTime() > -60 then
		if IsPlayerBot(pIDs[P.pIDInc]) == true then
			local currID = pIDs[P.pIDInc];
				if bot:GetPlayerID() == currID  then
					if checkCourier == true and DotaTime() > P.calibrateTime + 5  then
						local cst = GetCourierState(cr);
						if cst == COURIER_STATE_MOVING then
							P.pIDInc = P.pIDInc + 1;
							print(bot:GetUnitName().." : Courier Successfully Assigned ."..tostring(bot.courierID));
							checkCourier = false;
							bot.courierAssigned = true;
							P.calibrateTime = DotaTime();
							bot:ActionImmediate_Courier( cr, COURIER_ACTION_RETURN_STASH_ITEMS )
							return;
						else
							bot.courierID = bot.courierID + 1;
							checkCourier = false;
							P.calibrateTime = DotaTime();
						end
					elseif checkCourier == false then
						cr = GetCourier(bot.courierID);
						bot:ActionImmediate_Courier( cr, COURIER_ACTION_SECRET_SHOP )
						checkCourier = true;
					end
				end
		else
			P.pIDInc = P.pIDInc + 1;
		end
	end	
	
	if not bot.courierAssigned then
		return
	end
	
	local Courier = GetCourier(bot.courierID)
	
	if not Courier:IsAlive() or not Courier:IsCourier() then
		return
	end
	
	if GetCourierState(Courier) == COURIER_STATE_RETURNING_TO_BASE
	or GetCourierState(Courier) == COURIER_STATE_DEAD then
		return
	end
	
	if not bot:IsAlive() and  GetCourierState(Courier) == COURIER_STATE_DELIVERING_ITEMS then
		bot:ActionImmediate_Courier(Courier, COURIER_ACTION_RETURN_STASH_ITEMS)
	end
	
	local Enemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
	for v, enemy in pairs(Enemies) do
		if GetUnitToUnitDistance(Courier, enemy) <= 1200 then
			bot:ActionImmediate_Courier(Courier, COURIER_ACTION_RETURN_STASH_ITEMS)
			
			local burst = Courier:GetAbilityByName("courier_burst")
			if bot:GetLevel() >= 10 and burst:IsFullyCastable() then
				bot:ActionImmediate_Courier(Courier, COURIER_ACTION_BURST)
			end
		end
	end
	
	if bot:IsAlive() and bot.SecretShop and Courier:DistanceFromFountain() < 7000 then
		bot:ActionImmediate_Courier(npcCourier, COURIER_ACTION_SECRET_SHOP)
	end
	
	local ValueThreshold = 100
	if bot:GetStashValue() > ValueThreshold or bot:GetCourierValue() > ValueThreshold then
		if GetCourierState(Courier) ~= COURIER_STATE_RETURNING_TO_BASE
		and GetCourierState(Courier) ~= COURIER_STATE_DELIVERING_ITEMS then
			if bot:GetStashValue() > ValueThreshold then
				bot:ActionImmediate_Courier(Courier, COURIER_ACTION_TAKE_STASH_ITEMS)
			elseif bot:GetCourierValue() > ValueThreshold then
				bot:ActionImmediate_Courier(Courier, COURIER_ACTION_TRANSFER_ITEMS)
			end
		end
	end
end

function BuybackUsageThink() 
	if bot:IsInvulnerable() or not bot:IsHero() or bot:IsIllusion() or P.IsMeepoClone(bot) or bot:HasModifier("modifier_arc_warden_tempest_double") or ShouldBuyBack() == false then
		return;
	end
	
	if bot:IsAlive() and TimeDeath ~= nil then
		TimeDeath = nil;
	end
	
	if not bot:HasBuyback() then
		return;
	end

	if not bot:IsAlive() then
		if TimeDeath == nil then
			TimeDeath = DotaTime();
		end
	end
	
	local RespawnTime = GetRemainingRespawnTime();
	
	if RespawnTime < 10 then
		return;
	end
	
	local ancient = GetAncient(GetTeam());
	
	if ancient ~= nil 
	then
		local nEnemies = GetNumEnemyNearby(ancient);
		if  nEnemies > 0 and nEnemies >= GetNumOfAliveHeroes(GetTeam()) then
			PRoles['lastbbtime'] = DotaTime();
			bot:ActionImmediate_Buyback();
			return;
		end	
	end
end

local PointLevel = 1

function AbilityLevelUpThink()
	UseGlyph()

	local BotLevel = bot:GetLevel()
	local SkillPoints = HeroInfoFile.GetHeroLevelPoints()
	
	if bot:GetAbilityPoints() > 0 and BotLevel <= 30 then
		if SkillPoints[PointLevel] == "NoLevel" then
			PointLevel = (PointLevel + 1)
		else
			bot:ActionImmediate_LevelAbility(SkillPoints[PointLevel])
			PointLevel = (PointLevel + 1)
		end
	end
end

-- Extra functions --

function UseGlyph()
	if GetGlyphCooldown( ) > 0 then
		return
	end	
	
	local T1 = {
		TOWER_TOP_1,
		TOWER_MID_1,
		TOWER_BOT_1,
		TOWER_TOP_3,
		TOWER_MID_3, 
		TOWER_BOT_3, 
		TOWER_BASE_1, 
		TOWER_BASE_2
	}
	
	for _,t in pairs(T1)
	do
		local tower = GetTower(GetTeam(), t);
		if  tower ~= nil and tower:GetHealth() > 0 and tower:GetHealth()/tower:GetMaxHealth() < 0.15 and tower:GetAttackTarget() ~=  nil
		then
			bot:ActionImmediate_Glyph( )
			return
		end
	end
	

	local MeleeBarrack = {
		BARRACKS_TOP_MELEE,
		BARRACKS_MID_MELEE,
		BARRACKS_BOT_MELEE
	}
	
	for _,b in pairs(MeleeBarrack)
	do
		local barrack = GetBarracks(GetTeam(), b);
		if barrack ~= nil and barrack:GetHealth() > 0 and barrack:GetHealth()/barrack:GetMaxHealth() < 0.5 and IsTargetedByEnemy(barrack)
		then
			bot:ActionImmediate_Glyph()
			return
		end
	end
	
	local Ancient = GetAncient(GetTeam())
	if Ancient ~= nil and Ancient:GetHealth() > 0 and Ancient:GetHealth()/Ancient:GetMaxHealth() < 0.5 and IsTargetedByEnemy(Ancient)
	then
		bot:ActionImmediate_Glyph()
		return
	end
end

function ShouldBuyBack()
	return DotaTime() > bbtime['lastbbtime'] + 2.0;
end

function GetNumEnemyNearby(building)
	local nearbynum = 0;
	for i,id in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id);
			if info ~= nil then
				local dInfo = info[1]; 
				if dInfo ~= nil and GetUnitToLocationDistance(building, dInfo.location) <= 2750 and dInfo.time_since_seen < 1.0 then
					nearbynum = nearbynum + 1;
				end
			end
		end
	end
	return nearbynum;
end

function GetNumOfAliveHeroes(team)
	local nearbynum = 0;
	for i,id in pairs(GetTeamPlayers(team)) do
		if IsHeroAlive(id) then
			nearbynum = nearbynum + 1;
		end
	end
	return nearbynum;
end

function GetRemainingRespawnTime()
	if TimeDeath == nil then
		return 0;
	else
		return bot:GetRespawnTime() - ( DotaTime() - TimeDeath );
	end
end

function GetNumOfAliveHeroes(team)
	local nearbynum = 0;
	for i,id in pairs(GetTeamPlayers(team)) do
		if IsHeroAlive(id) then
			nearbynum = nearbynum + 1;
		end
	end
	return nearbynum;
end

function GetRemainingRespawnTime()
	if TimeDeath == nil then
		return 0;
	else
		return bot:GetRespawnTime() - ( DotaTime() - TimeDeath );
	end
end

function UpdateBackPackItem(bot)
	local curr_time = DotaTime();
	for i=6, 8 do
		local bp_item = bot:GetItemInSlot(i);
		if bp_item ~= nil then
			backpack_item[bp_item:GetName()] = curr_time;
		end
	end
	
	if curr_time > update_bi_time + 7.0 then
		for k,v in pairs(backpack_item) do
			if v ~= nil and v + 7.0 < curr_time then
				backpack_item[k] = nil;
			end
		end
		update_bi_time = curr_time;
	end
end

function JustSwapped(item_name)
	return backpack_item[item_name] ~= nil and backpack_item[item_name] + 6.5 > DotaTime();
end

function ShouldNotUseNeutralItemFromMainSlot(item_name, slot)
	return PItems.GetNeutralItemTier(item_name) > 0 and bot:GetItemSlotType(slot) == ITEM_SLOT_TYPE_MAIN
end

return MyModule