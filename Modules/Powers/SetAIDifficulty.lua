local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local FX = import(ModPath..'Modules/Effects.lua')
local Buff = import('/lua/sim/buff.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Color = import(ModPath..'Modules/Colors.lua').Colors

function Name(unit) -- Mandatory function
	return 'Choose Ai difficulty'
end

function IsAvailable(unit) -- Mandatory function
	return false
end

function Description(unit) -- Mandatory function
	local Tp = {} Tp.Line = {} Tp.Width = 270 Tp.OffSetY = -25
	local APColor = Color.GREY_LIGHT
	local Difficulty = DM.GetProperty('Global', 'AI_Difficulty', 'Low Trained Imperial Troops')
	local DifficultyLevel = {'Elite Imperial Troops', 'Well Trained Imperial Troops', 'Trained Imperial Troops', 'Low Trained Imperial Troops', 'No Imperial Troops'}
	table.insert(Tp.Line, {Name(unit)})
	table.insert(Tp.Line, {'No troops = vanilla AI', Color.GREY_LIGHT})
	table.insert(Tp.Line, {'Elite Imperial Troops = hardest cheating AI', Color.GREY_LIGHT})
	table.insert(Tp.Line, {''})
	for _,Level in DifficultyLevel do
		if Level == Difficulty then 
			APColor = Color.AEON 
		else 
			APColor = Color.GREY_LIGHT 
		end
		table.insert(Tp.Line, {Level, APColor, Level})
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
	if Option == nil then Option = 'Low Trained Imperial Troops' end
	DM.SetProperty('Global','AI_Difficulty', Option)
	DM.SetProperty('Global','LastAIDifficultyChange',math.floor(GetGameTimeSeconds()))
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