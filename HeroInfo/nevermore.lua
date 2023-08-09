X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Shadowraze1 = bot:GetAbilityByName("nevermore_shadowraze1")
local Shadowraze2 = bot:GetAbilityByName("nevermore_shadowraze2")
local Shadowraze3 = bot:GetAbilityByName("nevermore_shadowraze3")
local Necromastery = bot:GetAbilityByName("nevermore_necromastery")
local DarkLord = bot:GetAbilityByName("nevermore_dark_lord")
local Requiem = bot:GetAbilityByName("nevermore_requiem")

local Shadowraze1Desire = 0
local Shadowraze2Desire = 0
local Shadowraze3Desire = 0
local RequiemDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Shadowraze1:GetName())
	table.insert(abilities, Necromastery:GetName())
	table.insert(abilities, DarkLord:GetName())
	table.insert(abilities, Requiem:GetName())
	
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
	abilities[1], -- Level 3
	abilities[2], -- Level 4
	abilities[1], -- Level 5
	abilities[2], -- Level 6
	abilities[1], -- Level 7
	abilities[2], -- Level 8
	abilities[4], -- Level 9
	talents[2],   -- Level 10
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
	talents[1],   -- Level 27
	talents[4],   -- Level 28
	talents[6],   -- Level 29
	talents[7]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		ItemBuild = { 
		"item_faerie_fire",
	
		"item_wraith_band",
		"item_power_treads",
		"item_magic_wand",
	
		"item_dragon_lance",
		"item_black_king_bar",
		"item_greater_crit",
		"item_sange_and_yasha",
		"item_butterfly",
		"item_skadi",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		ItemBuild = { 
		"item_wraith_band",
		"item_power_treads",
		"item_magic_wand",
	
		"item_falcon_blade",
		
		"item_dragon_lance",
		"item_black_king_bar",
		"item_greater_crit",
		"item_sange_and_yasha",
		"item_butterfly",
		"item_skadi",
		}
	end
	
	return ItemBuild
end

return X