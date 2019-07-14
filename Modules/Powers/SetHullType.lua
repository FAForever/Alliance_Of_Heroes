local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local FX = import(ModPath..'Modules/Effects.lua')
local Buff = import('/lua/sim/buff.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Color = import(ModPath..'Modules/Colors.lua').Colors

local Hulls_Desc = {
	Terran = {
		Desc = {
			'Puissance cap : 100',
			'Dexterity cap : 100',
			'Hull cap : 100',
			'Intelligence cap : 100',
			'Energy cap : 100',
			'XP Gain : +25 %',
			'Available to all classes',
		},
		Color = {
			Color.GREY_LIGHT,
			Color.GREY_LIGHT,
			Color.GREY_LIGHT,
			Color.GREY_LIGHT,
			Color.GREY_LIGHT,
			Color.AEON,
			Color.SERAPHIM,
		},
	},
	Aelfen = {
		Desc = {
			'Puissance cap : 95',
			'Dexterity cap : 120',
			'Hull cap : 95',
			'Intelligence cap : 105',
			'Energy cap : 85',
			'Energy : -5',
			'Snare Immunity',
			'Available to all classes',
		},
		Color = {
			Color.CYBRAN,
			Color.GREY_LIGHT,
			Color.CYBRAN,
			Color.GREY_LIGHT,
			Color.CYBRAN,
			Color.CYBRAN,
			Color.AEON,
			Color.SERAPHIM,
		},
	},
	Cenrian = {
		Desc = {
			'Puissance cap : 110',
			'Dexterity cap : 85',
			'Dexterity : -5',
			'Hull cap : 125',
			'Intelligence cap : 85',
			'Intelligence : -5',
			'Energy cap : 105',
			'Mouvement Speed Bonus : +5%',
			'Available as fighter or support',
		},
		Color = {
			Color.AEON,
			Color.CYBRAN,
			Color.CYBRAN,
			Color.AEON,
			Color.CYBRAN,
			Color.CYBRAN,
			Color.AEON,
			Color.AEON,
			Color.SERAPHIM,
		},
	},
	Dwerden = {
		Desc = {
			'Puissance cap : 110',
			'Dexterity cap : 80',
			'Dexterity : -5',
			'Hull cap : 140',
			'Intelligence cap : 70',
			'Intelligence : -10',
			'Energy cap : 100',
			'Bombing Damage Armor : +10',
			'Artillery Damage Armor : +10',
			'Available as fighter or support',
		},
		Color = {
			Color.AEON,
			Color.CYBRAN,
			Color.CYBRAN,
			Color.AEON,
			Color.CYBRAN,
			Color.CYBRAN,
			Color.GREY_LIGHT,
			Color.AEON,
			Color.AEON,
			Color.SERAPHIM,
		},
	},
	Elean = {
		Desc = {
			'Puissance cap : 70',
			'Puissance -5',
			'Dexterity cap : 140',
			'Dexterity +10',
			'Hull cap : 70',
			'Hull : -5',
			'Intelligence cap : 120',
			'Intelligence +10',
			'Energy cap : 100',
			'Heal Receptivity: +15%',
			'Weapon Mastery : +10',
			'Available to all classes',
		},
		Color = {
			Color.CYBRAN,
			Color.CYBRAN,
			Color.AEON,
			Color.AEON,
			Color.CYBRAN,
			Color.CYBRAN,
			Color.AEON,
			Color.AEON,
			Color.GREY_LIGHT,
			Color.AEON,
			Color.AEON,
			Color.SERAPHIM,
		},
	},
	Gorg = {
		Desc = {
			'Puissance cap : 150',
			'Dexterity cap : 65',
			'Hull cap : 140',
			'Intelligence cap : 85',
			'Energy cap : 60',
			'Cannot be stunned by powers',
			'Available as fighter only',
		},
		Color = {
			Color.AEON,
			Color.CYBRAN,
			Color.AEON,
			Color.CYBRAN,
			Color.CYBRAN,
			Color.AEON,
			Color.SERAPHIM,
		},
	},
	Irekan = {
		Desc = {
			'Puissance cap : 85',
			'Dexterity cap : 130',
			'Dexterity : +15',
			'Hull cap : 90',
			'Intelligence cap : 110',
			'Energy cap : 85',
			'Energy : -10',
			'+10% damage when target range < 5',
			'Available to all classes',
		},
		Color = {
			Color.CYBRAN,
			Color.AEON,
			Color.AEON,
			Color.CYBRAN,
			Color.AEON,
			Color.CYBRAN,
			Color.CYBRAN,
			Color.AEON,
			Color.SERAPHIM,
		},
	},
	Minoedian = {
		Desc = {
			'Puissance cap : 170',
			'Puissance +5',
			'Dexterity cap : 70',
			'Dexterity : -15',
			'Hull cap : 140',
			'Intelligence cap : 65',
			'Intelligence -15',
			'Energy cap : 65',
			'Energy : -15',
			'Armor : +10',
			'Available as fighter and support',
		},
		Color = {
			Color.AEON,
			Color.AEON,
			Color.CYBRAN,
			Color.CYBRAN,
			Color.AEON,
			Color.CYBRAN,
			Color.CYBRAN,
			Color.CYBRAN,
			Color.CYBRAN,
			Color.AEON,
			Color.SERAPHIM,
		},
	},
	Hellimen = {
		Desc = {
			'Puissance cap : 140',
			'Puissance : +5',
			'Dexterity cap : 60',
			'Hull cap : 90',
			'Intelligence cap : 130',
			'Intelligence : +10',
			'Energy cap : 80',
			'+15% damage taken from powers',
			'Available as fighter, rogue and ardent',
		},
		Color = {
			Color.AEON,
			Color.AEON,
			Color.CYBRAN,
			Color.CYBRAN,
			Color.AEON,
			Color.AEON,
			Color.CYBRAN,
			Color.CYBRAN,
			Color.SERAPHIM,
		},
	},
}

function Name(unit) -- Mandatory function
	return 'Choose hull for units production :'
end

function IsAvailable(unit) -- Mandatory function
	-- local id = unit:GetEntityId()
	-- local bp = unit:GetBlueprint()
	-- if table.find(bp.Categories, 'ENGINEER') then return true end
	-- if table.find(bp.Categories, 'FACTORY') and DM.GetProperty(id,'IsFactoryActive') == true then return true end
	return false
end

function Description(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local Tp = {} Tp.Line = {} Tp.Width = 240 Tp.OffSetY = -70
	local CurrentHull = DM.GetProperty(id,'Hull_Type', 'Terran')
	local SelectionColor = Color.GREY_LIGHT
	table.insert(Tp.Line, {Name(unit)})
	for c, Attributes in Hulls_Desc[CurrentHull].Desc do
		table.insert(Tp.Line, {Attributes, Hulls_Desc[CurrentHull].Color[c]})
	end
	table.insert(Tp.Line,{''})
	for hull,_ in Hulls_Desc do
		if CurrentHull == hull then SelectionColor = Color.AEON else SelectionColor = Color.GREY_LIGHT end
		table.insert(Tp.Line, {hull, SelectionColor, hull})
	end
	return Tp
end

function CanCast(unit) -- Mandatory function
	local id = unit:GetEntityId()
	if ReCastTime(unit) == '' and GetPowerCost(unit) < DM.GetProperty(id, 'Capacitor')  then
		return true
	else
		return false
	end
end

function GetLevel(unit)
end

function GetPowerCost(unit) -- Mandatory function
	return 0
end

function OnCast(unit, TempEntity, Option) -- Mandatory function. This function is called from ui immediately when the power icon is clicked on
	local id = unit:GetEntityId()
	-- if Option == nil then Option = 'Low Trained Imperial Troops' end
	DM.SetProperty(id,'Hull_Type', Option)
end

KillPower = function(unit, duration, PowerName) -- Mandatory function
	WaitSeconds(duration)
	local id = unit:GetEntityId()
	DM.SetProperty(id, 'EffectTime_'..PowerName, nil)
end

function OnWeaponHit(target, instigator) -- Mandatory if this function is called when the unit hit the target (active if DM.SetProperty(id, 'ExecuteWeaponBuffOnTarget', Name(unit)) has been set in OnCast function)
end

function StrikeData(unit) -- Mandatory if this function is called. When DM.SetProperty(id, 'ExecuteStrikeAtBone', Name(unit)) is set on Oncast function. It will change a projectile bp and cast a strike on the next weapon fire.
end


function GetDuration(unit) -- Mandatory function
	return 0
end

function ReCastTime(unit) -- Mandatory function
	local _id = unit:GetEntityId()
	local time = math.floor(GetGameTimeSeconds())
	local ReCastTime = ''
	if DM.GetProperty(_id, 'CastTime_'..Name()) then
		ReCastTime = math.max(0, GetDuration(unit) - (time - DM.GetProperty(_id, 'CastTime_'..Name())))
	end
	if ReCastTime <= 1 then 
		SimCallback	({Func= 'KillCastTime', Args = {id = _id, PowerName = Name()}})
	end
	return ReCastTime
end