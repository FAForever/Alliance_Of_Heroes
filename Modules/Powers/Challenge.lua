local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local FX = import(ModPath..'Modules/Effects.lua')
local Buff = import('/lua/sim/buff.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Color = import(ModPath..'Modules/Colors.lua').Colors
local BCMod = {Fighter = 1, Rogue = 0.75, Support = 0, Ardent = 0}
local PCMod = {Elite = 0.25, Guardian = 1, Dreadnought = 0.75, Bard = 0}



function Name(unit) -- Mandatory function
	return 'Challenge'
end

function IsAvailable(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
	if CF.IsMilitary(unit) and DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 then
		if BaseClass == 'Fighter' or  BaseClass == 'Rogue' then
			if PrestigeClass == 'Dreadnought' or PrestigeClass == 'Guardian' then 
				return true
			end
		end
	end
	return false
end

function Description(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local Tp = {} Tp.Line = {} Tp.Width = 240 Tp.OffSetY = -35
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
	local RankLevel = ((BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
	local RangeEffect = math.ceil(RankLevel * 40)
	local Techlevel = CF.GetUnitTech(unit)
	local Duration =  GetDuration(unit)
	table.insert(Tp.Line, {'Challenge'})
	table.insert(Tp.Line, {'Rank : '..CF.GetRankName(RankLevel), Color.GREY_LIGHT})
	table.insert(Tp.Line, {'Target taunt and orders disruption.', Color.WHITE})
	table.insert(Tp.Line, {'Aggro mobile units to the caster', Color.WHITE})
	table.insert(Tp.Line, {'Units up to Tech '..Techlevel, Color.GREY_LIGHT})
	table.insert(Tp.Line, {'Range effect : '..RangeEffect , Color.WHITE})
	table.insert(Tp.Line, {''})
	if DM.GetProperty(id,  Name(unit)..'_AutoCast', nil) == 1 then
		table.insert(Tp.Line, {'AutoCast is ON', Color.AEON})
	else
		table.insert(Tp.Line, {'Right click to activate autocast', Color.AEON})
	end
	table.insert(Tp.Line, {'Taunt Duration : '..Duration..' s', Color.AQUA})
	table.insert(Tp.Line, {'ReCast Time : 45 s', Color.AQUA})
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
	if DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 and DM.GetProperty(id, 'HasATarget') == true and ReCastTime(unit, callfromsim) == '' and GetPowerCost(unit) < DM.GetProperty(id, 'Capacitor') then
		return true
	else
		return false
	end
end

function GetLevel(unit)
end


function GetPowerCost(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
	local RankLevel = ((BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
	return math.ceil(35 * RankLevel)
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
		local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
		local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
		local RankLevel = ((BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
		local RangeEffect = math.ceil(RankLevel * 50)
		local units = unit:GetAIBrain():GetUnitsAroundPoint(categories.ALLUNITS, unit:GetPosition(), RangeEffect, 'Enemy')
		for k, _unit in units do
			local _bp = _unit:GetBlueprint()
			if CF.GetUnitTech(unit) >= CF.GetUnitTech(_unit) then -- only bonus on same or lower tech level units.
				IssueClearCommands({_unit})
				IssueAttack({_unit}, unit)
				CreateLightParticleIntel(_unit, -1, _unit:GetArmy(), 3, 40, 'glow_02', 'ramp_red_01' )
				_unit.KillPowerTargetThread = _unit:ForkThread(KillPowerTarget, GetDuration(unit))
			end
		end
	end
	unit:UpdateUnitData(5)
	DM.IncProperty(id, 'Stamina', - GetPowerCost(unit))
end

WarpInEffectThreadFx = function(self)
	local sound = Sound({Bank = 'UEADestroy', Cue = 'UEA_Destroy_Air_Killed'})
	self:PlaySound(sound)
	self:CreateProjectile(ModPath..'effects/entities/Challenge/Challenge_proj.bp', 0, 1.35, 0, nil, nil, nil):SetCollision(false)
end

KillPower = function(unit, duration, PowerName) -- Mandatory function
	WaitSeconds(duration)
	local id = unit:GetEntityId()
	DM.SetProperty(id, 'EffectTime_'..PowerName, nil)
end

KillPowerTarget = function(target, duration) -- Mandatory function
	WaitSeconds(duration)
	if target then
		IssueClearCommands({target})
	end
end


function OnWeaponHit(target, instigator) -- Mandatory if this function is called when the unit hit the target (active if DM.SetProperty(id, 'ExecuteWeaponBuffOnTarget', Name(unit)) has been set in OnCast function)
end

function StrikeData(unit) -- Mandatory if this function is called. When DM.SetProperty(id, 'ExecuteStrikeAtBone', Name(unit)) is set on Oncast function. It will change a projectile bp and cast a strike on the next weapon fire.
end

UnitsBuff = function(unit, bonus)
end

function GetDuration(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local Tp = {} Tp.Line = {} Tp.Width = 240 Tp.OffSetY = -70
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
	local RankLevel = ((BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
	local Duration =  math.ceil(RankLevel * 12)
	return Duration
end

function ReCastTime(unit, callfromsim) -- Mandatory function
	local _id = unit:GetEntityId()
	local time = math.floor(GetGameTimeSeconds())
	local ReCastTime = ''
	if DM.GetProperty(_id, 'CastTime_'..Name()) then
		ReCastTime = math.max(0, 45 - (time - DM.GetProperty(_id, 'CastTime_'..Name())))
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

