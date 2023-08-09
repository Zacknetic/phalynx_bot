X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local ManaBreak = bot:GetAbilityByName("antimage_mana_break")
local Blink = bot:GetAbilityByName("antimage_blink")
local SpellShield = bot:GetAbilityByName("antimage_counterspell")
local ManaVoid = bot:GetAbilityByName("antimage_mana_void")

local BlinkDesire = 0
local SpellShieldDesire = 0
local ManaVoidDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, ManaBreak:GetName())
	table.insert(abilities, Blink:GetName())
	table.insert(abilities, SpellShield:GetName())
	table.insert(abilities, ManaVoid:GetName())
	
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
	abilities[3], -- Level 3
	abilities[1], -- Level 4
	abilities[2], -- Level 5
	abilities[4], -- Level 6
	abilities[2], -- Level 7
	abilities[2], -- Level 8
	abilities[1], -- Level 9
	talents[1],   -- Level 10
	abilities[1], -- Level 11
	abilities[4], -- Level 12
	abilities[3], -- Level 13
	abilities[3], -- Level 14
	talents[3],   -- Level 15
	abilities[3], -- Level 16
	"NoLevel",    -- Level 17
	abilities[4], -- Level 18
	"NoLevel",    -- Level 19
	talents[6],   -- Level 20
	"NoLevel",    -- Level 21
	"NoLevel",    -- Level 22
	"NoLevel",    -- Level 23
	"NoLevel",    -- Level 24
	talents[8],   -- Level 25
	"NoLevel",    -- Level 26
	talents[2],   -- Level 27
	talents[4],   -- Level 28
	talents[5],   -- Level 29
	talents[7]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_wraith_band",
		"item_cornucopia",
		"item_power_treads",
	
		"item_bfury",
		"item_manta",
		"item_skadi",
		"item_abyssal_blade",
		"item_butterfly",
		"item_black_king_bar",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	-- The order to use abilities in
	SpellShieldDesire = UseSpellShield()
	if SpellShieldDesire > 0 then
		bot:Action_UseAbility(SpellShield)
		return
	end
	
	ManaVoidDesire, ManaVoidTarget = UseManaVoid()
	if ManaVoidDesire > 0 then
		bot:Action_UseAbilityOnEntity(ManaVoid, ManaVoidTarget)
		return
	end
	
	BlinkDesire, BlinkTarget = UseBlink()
	if BlinkDesire > 0 then
		bot:Action_UseAbilityOnLocation(Blink, BlinkTarget)
		return
	end
end

function UseBlink()
	if not Blink:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Blink:GetSpecialValueInt("blink_range")
	local RadiantBase = Vector(-7171.12, -7261.72, 1469.28)
	local DireBase = Vector(6977.84, 5797.69, 1357.99)
	local team = bot:GetTeam()
	
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

function UseSpellShield()
	if not SpellShield:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local projectiles = bot:GetIncomingTrackingProjectiles()
	
	for v, proj in pairs(projectiles) do
		if GetUnitToLocationDistance(bot, proj.location) <= 300 and proj.is_attack == false then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseManaVoid()
	if not ManaVoid:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = ManaVoid:GetCastRange()
	local DamagePerMana = 0
	
	if ManaVoid:GetLevel() == 1 then
		DamagaPerMana = 0.8
	elseif ManaVoid:GetLevel() == 2 then
		DamagePerMana = 0.95
	elseif ManaVoid:GetLevel() == 3 then
		DamagePerMana = 1.1
	end
	
	local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local target = nil
	
	if target == nil then
		for v, enemy in pairs(enemies) do
			local EstimatedDamage = DamagaPerMana * ( enemy:GetMaxMana() - enemy:GetMana())
			local RealDamage = enemy:GetActualIncomingDamage(EstimatedDamage, DAMAGE_TYPE_MAGICAL)
			
			if RealDamage >= enemy:GetHealth() and P.IsValidTarget(enemy) and not P.IsPossibleIllusion(enemy) and P.IsNotImmune(enemy) then
				target = enemy
				break
			end
		end
	end
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

return X