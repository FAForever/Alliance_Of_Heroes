local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')

function IsAvailable(unit)
	if unit then
		local u = DM.GetUnitBp(unit)
		if table.find(u.bp.Categories, 'CONSTRUCTION') or table.find(u.bp.Categories, 'FACTORY') or table.find(u.bp.Categories, 'COMMAND') or table.find(u.bp.Categories, 'SUBCOMMAND') then
			return true
		end
		return false
	else
		return false
	end
end
