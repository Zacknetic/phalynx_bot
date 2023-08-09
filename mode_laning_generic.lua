local bot = GetBot()

local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

function GetDesire()
	if P.IsInLaningPhase() then
		--return 0.446
		return BOT_MODE_DESIRE_MODERATE
	else
		return 0
	end

	return 0
end