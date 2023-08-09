X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local IceShards = bot:GetAbilityByName("tusk_ice_shards")
local Snowball = bot:GetAbilityByName("tusk_snowball")
local TagTeam = bot:GetAbilityByName("tusk_tag_team")
local WalrusPunch = bot:GetAbilityByName("tusk_walrus_punch")
local LaunchSnowball = bot:GetAbilityByName("tusk_launch_snowball")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, IceShards:GetName())
	table.insert(abilities, Snowball:GetName())
	table.insert(abilities, TagTeam:GetName())
	table.insert(abilities, WalrusPunch:GetName())
	
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
	abilities[2], -- Level 4
	abilities[1], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[2], -- Level 8
	abilities[2], -- Level 9
	talents[2],   -- Level 10
	abilities[3], -- Level 11
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

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
		ItemBuild = { 
		"item_ring_of_basilius",
		"item_tranquil_boots",
		"item_magic_wand",
	
		"item_pavise",
		"item_ancient_janggo",
		"item_blink",
		"item_boots_of_bearing",
		"item_pipe",
		"item_veil_of_discord",
	
		"item_overwhelming_blink",
		"item_black_king_bar",
		}
	end
	
	return ItemBuild
end

return X