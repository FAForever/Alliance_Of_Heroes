local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local FX = import(ModPath..'Modules/Effects.lua')
local Buff = import('/lua/sim/buff.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Color = import(ModPath..'Modules/Colors.lua').Colors

function Name(unit) -- Mandatory function
	return 'EMPStun'
end

function IsAvailable(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	if CF.IsMilitary(unit) then
		local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
		if PrestigeClass == 'Dreadnought' or PrestigeClass == 'Restorer' then 
			return true 
		end
	end
	return false
end

function Description(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local Tp = {} Tp.Line = {} Tp.Width = 200 Tp.OffSetY = -70
	local Techlevel = CF.GetUnitTech(unit)
	table.insert(Tp.Line, {'Stun'})
	table.insert(Tp.Line, {'AOE(40) Stun', Color.WHITE})
	table.insert(Tp.Line, {''})
	table.insert(Tp.Line, {'Lands and Naval units up to Tech '..Techlevel, Color.GREY_LIGHT})
	table.insert(Tp.Line, {'Stun Radius from caster : 40', Color.CYBRAN})
	table.insert(Tp.Line, {''})
	table.insert(Tp.Line, {'Stun Duration : '..GetDuration(unit)..' s', Color.AQUA})
	if DM.GetProperty(id,  Name(unit)..'_AutoCast', nil) == 1 then
		table.insert(Tp.Line, {'AutoCast is ON', Color.AEON})
	else
		table.insert(Tp.Line, {'Right click to activate autocast', Color.AEON})
	end
	table.insert(Tp.Line, {'ReCast Time : 30 s', Color.AQUA})
	local Capacitor = DM.GetProperty(id, 'Stamina')
	if GetPowerCost(unit) > Capacitor then
		local NeedCapacitor =  math.ceil(GetPowerCost(unit) - Capacitor)
		table.insert(Tp.Line, {'Power Cost : '..GetPowerCost(unit)..' (-'..NeedCapacitor..')', Color.ORANGE_LIGHT})
	else
		table.insert(Tp.Line, {'Power Cost : '..GetPowerCost(unit), Color.ORANGE_LIGHT})
	end
	return Tp
end

function CanCast(unit, callfromsim) -- Mandatory function
	local id = unit:GetEntityId()
	if DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 and DM.GetProperty(id, 'HasATarget') == true and ReCastTime(unit, callfromsim) == '' and GetPowerCost(unit) < DM.GetProperty(id, 'Stamina') then
		return true
	else
		return false
	end
end

function GetLevel(unit)
end


function GetPowerCost(unit) -- Mandatory function
	return 15
end

function OnCast(unit, TempEntity, Option) -- Mandatory function. This function is called from ui immediately when the power icon is clicked on
	local bp = unit:GetBlueprint()
	local id = unit:GetEntityId()
	local time = math.floor(GetGameTimeSeconds())
	DM.SetProperty(id, 'CastTime_'..Name(unit), time)
	-- self buff
	local UnitCatId = unit:GetUnitId()
	if not DM.GetProperty(id, 'EffectTime_'..Name(unit))  then	-- we check to not stack Fx
		DM.SetProperty(id, 'EffectTime_'..Name(unit), 1) -- this is a flag informing that the power is on (may be useful for further add of an active icon on units flagged)
		unit.KillPowerThread = unit:ForkThread(KillPower, GetDuration(unit), Name(unit))
		unit:ForkThread(WarpInEffectThreadFx)
		local units = unit:GetAIBrain():GetUnitsAroundPoint(categories.LAND + categories.NAVAL, unit:GetPosition(), 40, 'Enemy')
		for k, _unit in units do
			local _bp = _unit:GetBlueprint()
			if CF.GetUnitTech(unit) >= CF.GetUnitTech(_unit) then -- only bonus on same or lower tech level units.
				_unit:SetStunned(8)
				CreateLightParticleIntel(_unit, -1, _unit:GetArmy(), 3, 40, 'glow_02', 'ramp_white_01' )
			end
		end
	end
	unit:UpdateUnitData(5)
	DM.IncProperty(id, 'Stamina', - GetPowerCost(unit))
end

WarpInEffectThreadFx = function(self)
	local sound = Sound({Bank = 'UEADestroy', Cue = 'UEA_Destroy_Air_Killed'})
	self:PlaySound(sound)
	self:CreateProjectile(ModPath..'effects/entities/DreadnoughtStun/DreadnoughtStun_proj.bp', 0, 1.35, 0, nil, nil, nil):SetCollision(false)
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
	local id = unit:GetEntityId()
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
	if PrestigeClass == 'Restorer' then 
		return 10
	end
	return 4
end

function ReCastTime(unit, callfromsim) -- Mandatory function
	local _id = unit:GetEntityId()
	local time = math.floor(GetGameTimeSeconds())
	local ReCastTime = ''
	if DM.GetProperty(_id, 'CastTime_'..Name()) then
		ReCastTime = math.max(0, 30 - (time - DM.GetProperty(_id, 'CastTime_'..Name())))
	end
	if ReCastTime <= 1 then
		if callfromsim == true then
			DM.SetProperty(_id, 'CastTime_'..Name(unit), nil)
			DM.SetProperty(_id, 'RefreshPowers', 1)
		else
			SimCallback	({Func= 'KillCastTime', Args = {id = _id, PowerName = Name()}})
		end
	end
	return ReCastTime
end

