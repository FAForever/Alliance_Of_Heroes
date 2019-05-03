local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')

function IsAvailable(unit)
	if unit then
		local u = DM.GetUnitBp(unit)
		if u.BaseClass != 'Ardent' and u.BaseClass != 'Support' then		
			if CF.IsMilitary(unit) then
				return true
			end
		end
		return false
	else
		return false
	end
end
