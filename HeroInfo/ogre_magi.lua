X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Fireblast = bot:GetAbilityByName("ogre_magi_fireblast")
local Ignite = bot:GetAbilityByName("ogre_magi_ignite")
local Bloodlust = bot:GetAbilityByName("ogre_magi_bloodlust")
local Multicast = bot:GetAbilityByName("ogre_magi_multicast")
local UnrefinedFireblast = bot:GetAbilityByName("ogre_magi_unrefined_fireblast")
local FireShield = bot:GetAbilityByName("ogre_magi_smash")

local FireblastDesire = 0
local IgniteDesire = 0
local BloodlustDesire = 0
local UnrefinedFireblastDesire = 0
local FireShieldDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Fireblast:GetName())
	table.insert(abilities, Ignite:GetName())
	table.insert(abilities, Bloodlust:GetName())
	table.insert(abilities, Multicast:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[2], -- Level 1
	abilities[1], -- Level 2
	abilities[2], -- Level 3
	abilities[1], -- Level 4
	abilities[2], -- Level 5
	abilities[4], -- Level 6
	abilities[2], -- Level 7
	abilities[1], -- Level 8
	abilities[1], -- Level 9
	talents[1],   -- Level 10
	abilities[3], -- Level 11
	abilities[4], -- Level 12
	abilities[3], -- Level 13
	abilities[3], -- Level 14
	talents[3],   -- Level 15
	abilities[3], -- Level 16
	"NoLevel",    -- Level 17
	abilities[4], -- Level 18
	"NoLevel",    -- Level 19
	talents[5],   -- Level 20
	"NoLevel",    -- Level 21
	"NoLevel",    -- Level 22
	"NoLevel",    -- Level 23
	"NoLevel",    -- Level 24
	talents[8],   -- Level 25
	"NoLevel",    -- Level 26
	talents[2],   -- Level 27
	talents[4],   -- Level 28
	talents[6],   -- Level 29
	talents[7]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		ItemBuild = { 
		"item_quelling_blade",
		
		"item_bracer",
		"item_vanguard",
		"item_hand_of_midas",
		"item_arcane_boots",
		"item_magic_wand",
		
		"item_crimson_guard",
		
		"item_blink",
		"item_heart",
		"item_sange_and_yasha",
		"item_sheepstick",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	-- The order to use abilities in
	FireShieldDesire, FireShieldTarget = UseFireShield()
	if FireShieldDesire > 0 then
		bot:Action_UseAbilityOnEntity(FireShield, FireShieldTarget)
		return
	end
	
	FireblastDesire, FireblastTarget = UseFireblast()
	if FireblastDesire > 0 then
		bot:Action_UseAbilityOnEntity(Fireblast, FireblastTarget)
		return
	end
	
	UnrefinedFireblastDesire, UnrefinedFireblastTarget = UseUnrefinedFireblast()
	if UnrefinedFireblastDesire > 0 then
		bot:Action_UseAbilityOnEntity(UnrefinedFireblast, UnrefinedFireblastTarget)
		return
	end
	
	IgniteDesire, IgniteTarget = UseIgnite()
	if IgniteDesire > 0 then
		bot:Action_UseAbilityOnEntity(Ignite, IgniteTarget)
		return
	end
	
	BloodlustDesire, BloodlustTarget = UseBloodlust()
	if BloodlustDesire > 0 then
		bot:Action_UseAbilityOnEntity(Bloodlust, BloodlustTarget)
		return
	end
end

return X