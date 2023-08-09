X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local VenomousGale = bot:GetAbilityByName("venomancer_venomous_gale")
local PoisonSting = bot:GetAbilityByName("venomancer_poison_sting")
local PlagueWard = bot:GetAbilityByName("venomancer_plague_ward")
local NoxiousPlague = bot:GetAbilityByName("venomancer_noxious_plague")
local PoisonNova = bot:GetAbilityByName("venomancer_poison_nova")
local LatentToxicity = bot:GetAbilityByName("venomancer_latent_poison")

local VenomousGaleDesire = 0
local PlagueWardDesire = 0
local PoisonNovaDesire = 0
local LatentToxicityDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, VenomousGale:GetName())
	table.insert(abilities, PoisonSting:GetName())
	table.insert(abilities, PlagueWard:GetName())
	table.insert(abilities, NoxiousPlague:GetName())
	
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
	abilities[3], -- Level 5
	abilities[4], -- Level 6
	abilities[3], -- Level 7
	abilities[3], -- Level 8
	abilities[3], -- Level 9
	talents[1],   -- Level 10
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
	talents[8],   -- Level 25
	"NoLevel",    -- Level 26
	talents[2],   -- Level 27
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
		"item_tranquil_boots",
		"item_magic_wand",
		
		"item_pavise",
		"item_force_staff",
		"item_boots_of_bearing",
		"item_pipe",
		"item_veil_of_discord",
		
		"item_force_staff",
		"item_ultimate_scepter",
		}
	end
	
	return ItemBuild
end

return X