X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local DarkPact = bot:GetAbilityByName("slark_dark_pact")
local Pounce = bot:GetAbilityByName("slark_pounce")
local EssenceShift = bot:GetAbilityByName("slark_essence_shift")
local ShadowDance = bot:GetAbilityByName("slark_shadow_dance")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, DarkPact:GetName())
	table.insert(abilities, Pounce:GetName())
	table.insert(abilities, EssenceShift:GetName())
	table.insert(abilities, ShadowDance:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[3], -- Level 1
	abilities[2], -- Level 2
	abilities[1], -- Level 3
	abilities[1], -- Level 4
	abilities[1], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[2], -- Level 8
	abilities[2], -- Level 9
	abilities[2], -- Level 10
	talents[1],   -- Level 11
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
		"item_power_treads",
		"item_magic_wand",
	
		"item_falcon_blade",
		"item_diffusal_blade",
		"item_ultimate_scepter",
		"item_skadi",
		"item_black_king_bar",
		"item_basher",
		}
	end
	
	return ItemBuild
end

return X