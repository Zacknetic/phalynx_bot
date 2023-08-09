X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local ShadowStrike = bot:GetAbilityByName("queenofpain_shadow_strike")
local Blink = bot:GetAbilityByName("queenofpain_blink")
local ScreamOfPain = bot:GetAbilityByName("queenofpain_scream_of_pain")
local SonicWave = bot:GetAbilityByName("queenofpain_sonic_wave")

local ShadowStrikeDesire = 0
local BlinkDesire = 0
local ScreamOfPainDesire = 0
local SonicWaveDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, ShadowStrike:GetName())
	table.insert(abilities, Blink:GetName())
	table.insert(abilities, ScreamOfPain:GetName())
	table.insert(abilities, SonicWave:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[1], -- Level 1
	abilities[2], -- Level 2
	abilities[1], -- Level 3
	abilities[3], -- Level 4
	abilities[3], -- Level 5
	abilities[4], -- Level 6
	abilities[3], -- Level 7
	abilities[3], -- Level 8
	abilities[2], -- Level 9
	talents[2],   -- Level 10
	abilities[2], -- Level 11
	abilities[4], -- Level 12
	abilities[2], -- Level 13
	abilities[1], -- Level 14
	talents[4],   -- Level 15
	abilities[1], -- Level 16
	"NoLevel",    -- Level 17
	abilities[4], -- Level 18
	"NoLevel",    -- Level 19
	talents[5],   -- Level 20
	"NoLevel",    -- Level 21
	"NoLevel",    -- Level 22
	"NoLevel",    -- Level 23
	"NoLevel",    -- Level 24
	talents[7],   -- Level 25
	"NoLevel",    -- Level 26
	talents[1],   -- Level 27
	talents[3],   -- Level 28
	talents[6],   -- Level 29
	talents[8]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		ItemBuild = { 
		"item_faerie_fire",
	
		"item_null_talisman",
		"item_power_treads",
		"item_magic_wand",
	
		"item_kaya_and_sange",
		"item_ultimate_scepter",
		"item_black_king_bar",
		"item_sphere",
		"item_shivas_guard",
		"item_sheepstick",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()
	
	manathreshold = 100
	manathreshold = manathreshold + ShadowStrike:GetManaCost()
	manathreshold = manathreshold + Blink:GetManaCost()
	manathreshold = manathreshold + SonicWave:GetManaCost()
	
	
	-- The order to use abilities in
	SonicWaveDesire, SonicWaveTarget = UseSonicWave()
	if SonicWaveDesire > 0 then
		bot:Action_UseAbilityOnLocation(SonicWave, SonicWaveTarget)
		return
	end
	
	BlinkDesire, BlinkTarget = UseBlink()
	if BlinkDesire > 0 then
		bot:Action_UseAbilityOnLocation(Blink, BlinkTarget)
		return
	end
	
	ScreamOfPainDesire = UseScreamOfPain()
	if ScreamOfPainDesire > 0 then
		bot:Action_UseAbility(ScreamOfPain)
		return
	end
	
	ShadowStrikeDesire, ShadowStrikeTarget = UseShadowStrike()
	if ShadowStrikeDesire > 0 then
		bot:Action_UseAbilityOnEntity(ShadowStrike, ShadowStrikeTarget)
		return
	end
end

function UseShadowStrike()
	if not ShadowStrike:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = ShadowStrike:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 100, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_ABSOLUTE, target
	end
	
	return 0
end

function UseBlink()
	if not Blink:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local RadiantBase = Vector(-7171.12, -7261.72, 1469.28)
	local DireBase = Vector(6977.84, 5797.69, 1357.99)
	local team = bot:GetTeam()
	
	local CastRange = Blink:GetSpecialValueInt("blink_range")
	
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if P.IsRetreating(bot) then
		if team == TEAM_RADIANT then
			return BOT_ACTION_DESIRE_HIGH, RadiantBase
		elseif team == TEAM_DIRE then
			return BOT_ACTION_DESIRE_HIGH, DireBase
		end
	end
	
	if target ~= nil and not target:IsAttackImmune() and not P.IsRetreating(bot) then
		if (bot:GetActiveMode() == BOT_MODE_ATTACK and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_LOW) then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
		end
	end
	
	return 0
end

function UseScreamOfPain()
	if not ScreamOfPain:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = ScreamOfPain:GetSpecialValueInt("area_of_effect")
	
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local trueenemies = P.FilterTrueEnemies(enemies)
	local nonimmuneenemies = {}
	
	for v, enemy in pairs(trueenemies) do
		if P.IsNotImmune(enemy) then
			table.insert(nonimmuneenemies, enemy)
		end
	end
	
	if #nonimmuneenemies >= 1 then
		return BOT_ACTION_DESIRE_ABSOLUTE
	end
	
	if (bot:GetActiveMode() == BOT_MODE_FARM and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_VERYLOW) then
		local neutrals = bot:GetNearbyNeutralCreeps(CastRange)
		
		if #neutrals >= 2 and (bot:GetMana() - ScreamOfPain:GetManaCost()) > manathreshold then
			return BOT_ACTION_DESIRE_ABSOLUTE
		end
	end
	
	return 0
end

function UseSonicWave()
	if not SonicWave:IsFullyCastable() then return 0 end
	if not P.IsInPhalanxTeamFight(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = SonicWave:GetCastRange()
	local Radius = SonicWave:GetSpecialValueInt("final_aoe")
	
	local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
	if (AoE.count >= 2) then
		return BOT_ACTION_DESIRE_HIGH, AoE.targetloc;
	end
	
	return 0
end

return X