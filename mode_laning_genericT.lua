function GetDesire()
	if(DotaTime() <= 60 * 10) and (DotaTime() >= 0) then
		return 0.446 -- Needs to be kept under 0.5
	elseif(DotaTime() < 10) then
		return 0.2
	else
		return BOT_MODE_DESIRE_NONE
	end
end

--[[function Think()

end]]--