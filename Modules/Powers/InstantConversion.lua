local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local FX = import(ModPath..'Modules/Effects.lua')
local Buff = import('/lua/sim/buff.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Color = import(ModPath..'Modules/Colors.lua').Colors

function Name(unit) -- Mandatory function
	return 'InstantConversion'
end

function IsAvailable(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local BaseClass =  DM.GetProperty(id,'BaseClass')
	if DM.GetProperty(id,'PrestigeClass', nil) == 'Guardian' and BaseClass == 'Support' then return true end
	return false
end

function Description(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local PowerModifier = CF.GetStanceModifier(unit, 'PowerStrengh_Mod') + (DM.GetProperty(id, 'Buff_PowerDamage_ALL_Add', 0) / 100)
	local Power = math.floor(math.pow(bp.Economy.BuildCostMass, 0.5) * PowerModifier)
	local Int = DM.GetProperty(id, 'Intelligence')
	local EnergyAmount = math.ceil(Power) * 4000 * Int/25
	local econData = GetEconomyTotals()
	EnergyAmount = math.floor(math.min(econData.stored.ENERGY, EnergyAmount))
	local Techlevel = CF.GetUnitTech(unit)
	local ConversionRate = 0.006 * (1 + Int/75) * math.pow(Techlevel, 0.3) * (1 + math.pow(bp.Economy.BuildCostMass, 0.35) / 100)
	local Massconverted = math.floor(EnergyAmount * ConversionRate)
	local Rate = math.ceil(1/ConversionRate)
	local Tp = {} Tp.Line = {} Tp.Width = 230 Tp.OffSetY = -70
	table.insert(Tp.Line, {'Instant Power to Mass Conversion'})
	table.insert(Tp.Line, {'Convert up to '..EnergyAmount..' energy in '..string.format("%.1f",Massconverted)..' mass', Color.AEON})
	table.insert(Tp.Line, {'Conversion Rate : 1 mass for '..Rate.. ' energy', Color.GREY_LIGHT})
	table.insert(Tp.Line, {''})
	table.insert(Tp.Line, {'ReCast Time : 3 s', Color.AQUA})
	local Capacitor = DM.GetProperty(id, 'Capacitor')
	if GetPowerCost(unit) > Capacitor then
		local NeedCapacitor =  math.ceil(GetPowerCost(unit) - Capacitor)
		table.insert(Tp.Line, {'Power Cost : '..GetPowerCost(unit)..' (-'..NeedCapacitor..')', Color.UEF})
	else
		table.insert(Tp.Line, {'Power Cost : '..GetPowerCost(unit), Color.UEF})
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
	return 10
end

function OnCast(unit, TempEntity, Option) -- Mandatory function. This function is called from ui immediately when the power icon is clicked on
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local PowerModifier = CF.GetStanceModifier(unit, 'PowerStrengh_Mod') + (AoHBuff.GetBuffValue(unit, 'PowerDamage', 'ALL') / 100)
	local Power = math.floor(math.pow(bp.Economy.BuildCostMass, 0.5) * PowerModifier)
	local Int = DM.GetProperty(id, 'Intelligence')
	local EnergyAmount = math.ceil(Power) * 4000 * Int/25
	local EnergyStored = unit:GetAIBrain():GetEconomyStored('ENERGY')
	EnergyAmount = math.floor(math.min(EnergyStored, EnergyAmount))
	local Techlevel = CF.GetUnitTech(unit)
	local ConversionRate = 0.006 * (1 + Int/75) * math.pow(Techlevel, 0.3) * (1 + math.pow(bp.Economy.BuildCostMass, 0.35) / 100)
	local Massconverted = math.floor(EnergyAmount * ConversionRate)
	unit:GetAIBrain():TakeResource('Energy', EnergyAmount)
	unit:GetAIBrain():TakeResource('Mass', -Massconverted)
	local time = math.floor(GetGameTimeSeconds())
	DM.SetProperty(id, 'CastTime_'..Name(unit), time)
	local sound = Sound({Bank = 'UEADestroy', Cue = 'UEA_Destroy_Air_Killed'})
	unit:PlaySound(sound)
	CreateLightParticleIntel(unit, -1, unit:GetArmy(), 10, 40, 'glow_02', 'ramp_blue_01' )
	DM.IncProperty(id, 'Capacitor', - GetPowerCost(unit))
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
	return 5
end

function ReCastTime(unit) -- Mandatory function
	local _id = unit:GetEntityId()
	local time = math.floor(GetGameTimeSeconds())
	local ReCastTime = ''
	if DM.GetProperty(_id, 'CastTime_'..Name()) then
		ReCastTime = math.max(0, 3 - (time - DM.GetProperty(_id, 'CastTime_'..Name())))
	end
	if ReCastTime <= 1 then 
		SimCallback	({Func= 'KillCastTime', Args = {id = _id, PowerName = Name()}})
	end
	return ReCastTime
end