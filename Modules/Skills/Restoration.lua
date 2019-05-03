local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')

function IsAvailable(unit)
	if unit then
		local u = DM.GetUnitBp(unit)
		if u.BaseClass == 'Support' or u.PrestigeClass == 'Guardian' then
			return true
		end
		return false
	else
		return false
	end
end
