local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')

function IsAvailable(unit)
	if unit then
		local u = DM.GetUnitBp(unit)
		if u.BaseClass == 'Fighter' and u.PrestigeClass == 'Guardian' then
			return true
		elseif  u.PrestigeClass == 'Dreadnought' then	
			return true
		else
			return false
		end
	else
		return false
	end
end
