X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local ColdFeet = bot:GetAbilityByName("ancient_apparition_cold_feet")
local IceVortex = bot:GetAbilityByName("ancient_apparition_ice_vortex")
local ChillingTouch = bot:GetAbilityByName("ancient_apparition_chilling_touch")
local IceBlast = bot:GetAbilityByName("ancient_apparition_ice_blast")
local IceBlastRelease = bot:GetAbilityByName("ancient_apparition_ice_blast_release")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, ColdFeet:GetName())
	table.insert(abilities, IceVortex:GetName())
	table.insert(abilities, ChillingTouch:GetName())
	table.insert(abilities, IceBlast:GetName())
	
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
	abilities[2], -- Level 3
	abilities[1], -- Level 4
	abilities[1], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[2], -- Level 8
	abilities[2], -- Level 9
	talents[1],   -- Level 10
	abilities[2], -- Level 11
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

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
		ItemBuild = { 
		"item_arcane_boots",
		"item_magic_wand",
		
		"item_glimmer_cape",
		"item_guardian_greaves",
		
		"item_force_staff",
		"item_lotus_orb",
		"item_aeon_disk",
		}
	end
	
	return ItemBuild
end

return X