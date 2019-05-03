local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')

function IsAvailable(unit)
	if unit then
		local u = DM.GetUnitBp(unit)
		if u.BaseClass != 'Ardent' then
			return true
		else
			return false
		end
	else
		return false
	end
end

function Description(unit)
	local description = 'Light Armor Mastery drives armor use effiency. At higher level, it increase defense and dodge capabilities.'
	return description
end

function Name(unit)
	return 'Light Armor Mastery'
end