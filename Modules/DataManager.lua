------------------------------
-- Alliance of Heroes Mod ----
-- Franck83 [2016-2017] ------
------------------------------

local ModPath = '/mods/Alliance_Of_Heroes/'
local CF = import('/Mods/Alliance_Of_Heroes/Modules/Calculate_Formula.lua')
local Prefs = import('/lua/user/prefs.lua')
local ArmorModifiers =  import(ModPath..'Modules/ArmorModifiers.lua')
local WeaponModifiers =  import(ModPath..'Modules/WeaponModifiers.lua')

Sync.Data = {}
MyData = {}
MyData.global ={}

function SetProperty(id, key, value)
	local TempData = {}
	if not id then
		TempData.global[key] = value -- beware that setting a global property without an id will not care of armyindex. So it will be a between faction shared data.
		MyData.global[key] = value
	else
		TempData[id] = {}
		TempData[id].data = {}
		if not MyData[id] then
			MyData[id] = {}
			MyData[id].data = {}
		end
		MyData[id].data[key] = value
		TempData[id].data[key] = value
		if value == nil then
			TempData[id].data[key] = 'nil'
		end
	end
	Sync.Data = table.merged(Sync.Data, TempData)
end

function GetProperty(id, key, fallbackValue)
	if not id then
		return MyData.global[key] or fallbackValue
	else
		if MyData[id].data[key] == 'nil' then
			MyData[id].data[key] = nil
			return fallbackValue or nil
		end
		return MyData[id].data[key] or fallbackValue
	end
end

function IncProperty(id, key, incValue)
	local value = GetProperty(id, key)
	if value then
		value = value + incValue
		SetProperty(id, key, value)
	end
end

function SetSync(data)
	MyData = table.merged(MyData, data)
end

function RemoveId(id)
	for k,_ in MyData[id].data do
		SetProperty(id, k, nil)
	end
	MyData[id].data = nil
	MyData[id] = nil
end

function GetUnitBp(unit, id) -- we cannot get too much data from this way. Because this capped system.
	local UnitData = {}
	if unit then 
		UnitData.id = unit:GetEntityId()
		UnitData.unit = unit
	elseif id then 
		UnitData.id = id
		UnitData.unit = GetUnitById(id)
	end
	if UnitData.unit then
		UnitData.bp = UnitData.unit:GetBlueprint()
		UnitData.description = LOC(UnitData.bp.Description)	
		UnitData.Level, UnitData.LevelP =  CF.GetUnitLevel(UnitData.unit)
		UnitData.BaseClass = GetProperty(UnitData.id,'BaseClass','Fighter')
		UnitData.PrestigeClass = GetProperty(UnitData.id,'PrestigeClass','Dreadnought')
		-- UnitData.classid = UnitData.unit:GetUnitId()
		UnitData.army = UnitData.unit:GetArmy()
		UnitData.Puissance = GetProperty(UnitData.id,'Puissance')
		UnitData.Dexterity = GetProperty(UnitData.id,'Dexterity')
		UnitData.Hull = GetProperty(UnitData.id,'Hull')
		UnitData.Intelligence = GetProperty(UnitData.id,'Intelligence')
		UnitData.Energy = GetProperty(UnitData.id,'Energy')
		return UnitData, UnitData.unit
	end
end

function SetMouseCoordonnates(x, y, z, protected)
	SetProperty(nil, 'MousePosX',x)
	SetProperty(nil, 'MousePosY',y)
	SetProperty(nil, 'MousePosZ',z)
	if protected then
		SetProperty(nil, 'PMousePosX',x)
		SetProperty(nil, 'PMousePosY',y)
		SetProperty(nil, 'PMousePosZ',z)
	end
end

function GetMouseCoordonnates(protected)
	local Mouse = {}
	Mouse[1] = GetProperty(nil, 'MousePosX')
	Mouse[2] = GetProperty(nil, 'MousePosY')
	Mouse[3] = GetProperty(nil, 'MousePosZ')
	if protected then
		Mouse[1] = GetProperty(nil, 'PMousePosX')
		Mouse[2] = GetProperty(nil, 'PMousePosY')
		Mouse[3] = GetProperty(nil, 'PMousePosZ')
	end
	return Mouse
end

function SaveTemplates(type, tablemodifiers, tablelevels, Generaltable)
	if type == 'Weapons' then
		if tablemodifiers != nil then Prefs.SetToCurrentProfile('WeaponsTemplate', tablemodifiers) end
		if tablelevels != nil then Prefs.SetToCurrentProfile('WeaponsTemplateLevels', tablelevels) end
	elseif type == 'Armors' then
		if tablemodifiers != nil then Prefs.SetToCurrentProfile('ArmorsTemplate', tablemodifiers) end
		if tablelevels != nil then Prefs.SetToCurrentProfile('ArmorsTemplateLevels', tablelevels) end
	end
	if Generaltable != nil then Prefs.SetToCurrentProfile('GeneralTemplateTable', Generaltable) end
end

function GetTemplates(Type)
	return Prefs.GetFromCurrentProfile(Type..'Template') or {}, Prefs.GetFromCurrentProfile(Type..'TemplateLevels') or {}, Prefs.GetFromCurrentProfile('GeneralTemplateTable') or {}
end