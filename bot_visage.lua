local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

local bot = GetBot()

local StoneFormDesire = 0

function MinionThink(  hMinionUnit ) 
	if not hMinionUnit:IsNull() and hMinionUnit ~= nil then 
		if string.find(hMinionUnit:GetUnitName(), "visage_familiar") then
			if (hMinionUnit:IsUsingAbility()) then return end
			
			StoneForm = hMinionUnit:GetAbilityByName("visage_summon_familiars_stone_form")
			
			StoneFormDesire = UseStoneForm(hMinionUnit)
			if StoneFormDesire > 0 then
				hMinionUnit:Action_UseAbility(StoneForm)
				return
			end
			
			local target = P.IllusionTarget(hMinionUnit, bot)
		
			if target ~= nil then
				hMinionUnit:Action_AttackUnit(target, false)
			else
				hMinionUnit:Action_MoveToLocation(bot:GetLocation()+RandomVector(200))
			end
		end
		
		if hMinionUnit:IsIllusion() then
			local target = P.IllusionTarget(hMinionUnit, bot)
		
			if target ~= nil and bot:IsAlive() then
				hMinionUnit:Action_AttackUnit(target, false)
			else
				if bot:IsAlive() then
					hMinionUnit:Action_MoveToLocation(bot:GetLocation()+RandomVector(200))
				else
					hMinionUnit:Action_MoveToLocation(PAF.GetFountainLocation(bot))
				end
			end
		end
	end
end

function UseStoneForm(hMinionUnit)
	if not StoneForm:IsFullyCastable() then return 0, nil end
	if P.CantUseAbility(hMinionUnit) then return 0, nil end
	
	local Radius = StoneForm:GetSpecialValueInt("stun_radius")
	
	if hMinionUnit:GetHealth() <= (hMinionUnit:GetMaxHealth() * 0.4) then
		return 1
	end
	
	local AttackTarget = hMinionUnit:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if AttackTarget:IsHero() and not PAF.IsDisabled(AttackTarget) then
			return 1
		end
	end
	
	return 0, nil
end