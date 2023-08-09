X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local InsatiableHunger = bot:GetAbilityByName("broodmother_insatiable_hunger")
local SpinWeb = bot:GetAbilityByName("broodmother_spin_web")
local SilkenBola = bot:GetAbilityByName("broodmother_silken_bola")
local SpawnSpiderlings = bot:GetAbilityByName("broodmother_spawn_spiderlings")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, InsatiableHunger:GetName())
	table.insert(abilities, SpinWeb:GetName())
	table.insert(abilities, SilkenBola:GetName())
	table.insert(abilities, SpawnSpiderlings:GetName())
	
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
	abilities[3], -- Level 4
	abilities[2], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[1], -- Level 8
	abilities[2], -- Level 9
	talents[2],   -- Level 10
	abilities[2], -- Level 11
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
	talents[7],   -- Level 25
	"NoLevel",    -- Level 26
	talents[1],   -- Level 27
	talents[4],   -- Level 28
	talents[5],   -- Level 29
	talents[8]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_wraith_band",
		"item_power_treads",
		"item_soul_ring",
		"item_magic_wand",
		
		"item_crimson_guard",
		
		"item_echo_sabre",
		"item_harpoon",
		"item_manta",
		"item_black_king_bar",
		"item_nullifier",
		"item_refresher",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		ItemBuild = { 
		"item_faerie_fire",
	
		"item_wraith_band",
		"item_power_treads",
		"item_soul_ring",
		"item_magic_wand",
		
		"item_echo_sabre",
		"item_harpoon",
		"item_manta",
		"item_black_king_bar",
		"item_nullifier",
		"item_refresher",
		}
	end
	
	return ItemBuild
end

return X