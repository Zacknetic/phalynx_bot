X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local MirrorImage = bot:GetAbilityByName("naga_siren_mirror_image")
local Ensnare = bot:GetAbilityByName("naga_siren_ensnare")
local Riptide = bot:GetAbilityByName("naga_siren_rip_tide")
local SongOfTheSiren = bot:GetAbilityByName("naga_siren_song_of_the_siren")

local MirrorImageDesire = 0
local EnsnareDesire = 0
local SongOfTheSirenDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, MirrorImage:GetName())
	table.insert(abilities, Ensnare:GetName())
	table.insert(abilities, Riptide:GetName())
	table.insert(abilities, SongOfTheSiren:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[1], -- Level 1
	abilities[3], -- Level 2
	abilities[1], -- Level 3
	abilities[3], -- Level 4
	abilities[1], -- Level 5
	abilities[3], -- Level 6
	abilities[1], -- Level 7
	abilities[3], -- Level 8
	abilities[4], -- Level 9
	talents[1],   -- Level 10
	abilities[2], -- Level 11
	abilities[4], -- Level 12
	abilities[2], -- Level 13
	abilities[2], -- Level 14
	talents[4],   -- Level 15
	abilities[2], -- Level 16
	"NoLevel",    -- Level 17
	abilities[4], -- Level 18
	"NoLevel",    -- Level 19
	talents[6],   -- Level 20
	"NoLevel",    -- Level 21
	"NoLevel",    -- Level 22
	"NoLevel",    -- Level 23
	"NoLevel",    -- Level 24
	talents[7],   -- Level 25
	"NoLevel",    -- Level 26
	talents[2],   -- Level 27
	talents[3],   -- Level 28
	talents[5],   -- Level 29
	talents[8]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_wraith_band",
		"item_power_treads",
	
		"item_manta",
		"item_orchid",
		"item_heart",
		"item_bloodthorn",
		"item_butterfly",
		"item_sheepstick",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	-- The order to use abilities in
	SongOfTheSirenDesire, SongOfTheSirenTarget = UseSongOfTheSiren()
	if SongOfTheSirenDesire > 0 then
		bot:Action_UseAbility(SongOfTheSiren)
		return
	end
	
	MirrorImageDesire, MirrorImageTarget = UseMirrorImage()
	if MirrorImageDesire > 0 then
		bot:Action_UseAbility(MirrorImage)
		return
	end
	
	EnsnareDesire, EnsnareTarget = UseEnsnare()
	if EnsnareDesire > 0 then
		bot:Action_UseAbilityOnEntity(Ensnare, EnsnareTarget)
		return
	end
end

function UseMirrorImage()
	if not MirrorImage:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local tableTrueEnemies = P.FilterTrueEnemies(enemies)
	
	if bot:GetActiveMode() == BOT_MODE_ATTACK and #tableTrueEnemies > 0 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	local attacktarget = bot:GetAttackTarget()
	
	if attacktarget ~= nil then
		if attacktarget:IsBuilding() then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	local neutrals = bot:GetNearbyNeutralCreeps(AttackRange)
	
	if bot:GetActiveMode() == BOT_MODE_FARM and #neutrals > 0 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseEnsnare()
	if not Ensnare:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = 0
	
	if P.IsInLaningPhase() then
		CastRange = Ensnare:GetCastRange() + 100
	else
		CastRange = Ensnare:GetCastRange() + 500
	end
	
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local filteredenemies = P.FilterEnemiesForStun(enemies)
	local target = nil
	
	for v, enemy in pairs(enemies) do
		if P.IsValidTarget(enemy) and enemy:IsChanneling() and P.IsNotImmune(enemy) then
			target = enemy
			break
		end
	end
	
	if target == nil and #enemies >= 1 then
		if P.IsRetreating(bot) then
			target = P.GetClosestEnemy(bot, enemies)
			
			if target ~= nil then
				if GetUnitToUnitDistance(bot, target) > Ensnare:GetCastRange() then
					target = nil
				end
			end
		else
			target = P.GetWeakestEnemyHero(enemies)
			
			if target ~= nil and P.IsPDisabled(target) then
				target = P.GetStrongestEnemyHero(filteredenemies)
			end
		end
	end
	
	if target ~= nil and (P.IsInCombativeMode(bot) or P.IsRetreating(bot)) then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

function UseSongOfTheSiren()
	if not SongOfTheSiren:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = SongOfTheSiren:GetSpecialValueInt("radius")
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	
	if P.IsRetreating(bot) and #enemies >= 1 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

return X