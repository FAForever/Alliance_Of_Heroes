local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local FX = import(ModPath..'Modules/Effects.lua')
local Buff = import('/lua/sim/buff.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Color = import(ModPath..'Modules/Colors.lua').Colors

function Name(unit) -- Mandatory function
	return 'Choose unit behaviour when taking damages'
end

function IsAvailable(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	-- if CF.IsMilitary(unit) and DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 and table.find(bp.Categories, 'LAND') and table.find(bp.Categories, 'MOBILE') then return true end
	return false
end

function Description(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local Tp = {} Tp.Line = {} Tp.Width = 420 Tp.OffSetY = -35
	local APColor = Color.GREY_LIGHT
	local Behaviour = DM.GetProperty(id, 'Behaviour', 'Standing')
	local BehaviourList = {'Auto Move', 'Aggressive','Normal','Defensive','Standing'}
	table.insert(Tp.Line, {Name(unit)})
	if Behaviour == 'Standing' then
		Tp.Width = 370
		table.insert(Tp.Line, {'In standing mode, the unit behaviour is same as vanilla FA', Color.GREY_LIGHT})
	elseif Behaviour == 'Defensive' then
		Tp.Width = 320
		table.insert(Tp.Line, {'In defensive mode, the unit will attack the opponent.', Color.GREY_LIGHT})
		table.insert(Tp.Line, {'After killing the opponent, the unit goes back.', Color.GREY_LIGHT})
		table.insert(Tp.Line, {'Maximum opponent distance : 50', Color.GREY_LIGHT})
	elseif Behaviour == 'Normal' then
		Tp.Width = 390
		table.insert(Tp.Line, {"In normal mode, the unit will move attack to opponent's direction", Color.GREY_LIGHT})
		table.insert(Tp.Line, {'After killing the opponent, the unit does a patrol then goes back.', Color.GREY_LIGHT})
		table.insert(Tp.Line, {'Maximum opponent distance : 100', Color.GREY_LIGHT})
	elseif Behaviour == 'Aggressive' then
		table.insert(Tp.Line, {"In aggressive mode, the unit will move attack further to opponent place.", Color.GREY_LIGHT})
		table.insert(Tp.Line, {'After killing the opponent, the unit does a patrol then goes back.', Color.GREY_LIGHT})
		table.insert(Tp.Line, {'Maximum opponent distance : 150', Color.GREY_LIGHT})
	elseif Behaviour == 'Auto Move' then
		table.insert(Tp.Line, {"In Auto-Move mode, the unit will move to evade fire.", Color.GREY_LIGHT})
	end
	table.insert(Tp.Line, {''})
	for _,Beh in BehaviourList do
		if Behaviour == Beh then APColor = Color.AEON else APColor = Color.GREY_LIGHT end
		table.insert(Tp.Line, {Beh, APColor, Beh})
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
	DM.SetProperty(id,'Behaviour', Option)
	if Option == 'Auto Move' then 
		DM.SetProperty(id,'InitMove',1)
	else
		DM.SetProperty(id,'ChangingBehaviour',1)
	end
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