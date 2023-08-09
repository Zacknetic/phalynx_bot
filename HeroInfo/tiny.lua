X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Avalanche = bot:GetAbilityByName("tiny_avalanche")
local Toss = bot:GetAbilityByName("tiny_toss")
local TreeGrab = bot:GetAbilityByName("tiny_tree_grab")
local Grow = bot:GetAbilityByName("tiny_grow")
local TossTree = bot:GetAbilityByName("tiny_toss_tree")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Avalanche:GetName())
	table.insert(abilities, Toss:GetName())
	if bot:HasModifier("modifier_tiny_tree_grab") then
		table.insert(abilities, TossTree:GetName())
	else
		table.insert(abilities, TreeGrab:GetName())
	end
	table.insert(abilities, Grow:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[3], -- Level 1
	abilities[1], -- Level 2
	abilities[1], -- Level 3
	abilities[2], -- Level 4
	abilities[1], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[2], -- Level 8
	abilities[2], -- Level 9
	talents[2],   -- Level 10
	abilities[2], -- Level 11
	abilities[4], -- Level 12
	abilities[3], -- Level 13
	abilities[3], -- Level 14
	talents[4],   -- Level 15
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
	talents[3],   -- Level 28
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
	
		"item_bracer",
		"item_power_treads",
		"item_magic_wand",
		
		"item_blink",
		"item_echo_sabre",
		"item_ultimate_scepter",
		"item_greater_crit",
		"item_black_king_bar",
		}
	end
	
	return ItemBuild
end

return X