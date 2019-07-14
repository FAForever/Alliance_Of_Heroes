local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local FX = import(ModPath..'Modules/Effects.lua')
local Buff = import('/lua/sim/buff.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Color = import(ModPath..'Modules/Colors.lua').Colors

function Name(unit) -- Mandatory function
	return 'Choose promoting and upgrading speed'
end

function IsAvailable(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	return false
end

function Description(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local Tp = {} Tp.Line = {} Tp.Width = 340 Tp.OffSetY = -70
	local APColor = Color.GREY_LIGHT
	local CurrentSpeed = DM.GetProperty(id,'PromotingUpgradingSpeed', 'Average')
	local PromotingUpgradingSpeed = {'Faster','Fast','Average','Slow','Pause' }
	local PromotingCostMalus =  math.max(4 - (GameTime()/100), 1)
	PromotingCostMalus = string.format("%.2f", PromotingCostMalus, Color.CYBRAN)
	table.insert(Tp.Line, {Name(unit)})
	table.insert(Tp.Line, {'Higher speeds decrease promoting and upgrading time.', Color.GREY_LIGHT})
	table.insert(Tp.Line, {'but increase energy and mass drain.', Color.GREY_LIGHT})
	table.insert(Tp.Line, {'In all cases, the global cost is the same.', Color.GREY_LIGHT})
	if PromotingCostMalus > 1 then
		table.insert(Tp.Line, {''})
		table.insert(Tp.Line, {'Promoting cost starting time malus : '..PromotingCostMalus..'x', Color.CYBRAN})
	end
	table.insert(Tp.Line, {''})
	for _,Speed in PromotingUpgradingSpeed do
		if CurrentSpeed == Speed then APColor = Color.AEON else APColor = Color.GREY_LIGHT end
		table.insert(Tp.Line, {Speed, APColor, Speed})
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
	DM.SetProperty(id,'PromotingUpgradingSpeed', Option)
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