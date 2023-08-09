X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local DeathPulse = bot:GetAbilityByName("necrolyte_death_pulse")
local GhostShroud = bot:GetAbilityByName("necrolyte_sadist")
local HeartstopperAura = bot:GetAbilityByName("necrolyte_heartstopper_aura")
local ReapersScythe = bot:GetAbilityByName("necrolyte_reapers_scythe")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, DeathPulse:GetName())
	table.insert(abilities, GhostShroud:GetName())
	table.insert(abilities, HeartstopperAura:GetName())
	table.insert(abilities, ReapersScythe:GetName())
	
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
	abilities[3], -- Level 3
	abilities[1], -- Level 4
	abilities[2], -- Level 5
	abilities[4], -- Level 6
	abilities[3], -- Level 7
	abilities[1], -- Level 8
	abilities[1], -- Level 9
	talents[1],   -- Level 10
	abilities[3], -- Level 11
	abilities[4], -- Level 12
	abilities[2], -- Level 13
	abilities[2], -- Level 14
	talents[3],   -- Level 15
	abilities[2], -- Level 16
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

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_null_talisman",
		"item_arcane_boots",
		"item_magic_wand",
		
		"item_crimson_guard",
		
		"item_kaya_and_sange",
		"item_radiance",
		"item_heart",
		"item_blink",
		"item_sheepstick",
		"item_overwhelming_blink",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		ItemBuild = { 
		"item_faerie_fire",
	
		"item_null_talisman",
		"item_arcane_boots",
		"item_magic_wand",
	
		"item_kaya_and_sange",
		"item_radiance",
		"item_heart",
		"item_blink",
		"item_sheepstick",
		"item_overwhelming_blink",
		}
	end
	
	return ItemBuild
end

return X