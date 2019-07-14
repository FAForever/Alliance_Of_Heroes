local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local FX = import(ModPath..'Modules/Effects.lua')
local Buff = import('/lua/sim/buff.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Color = import(ModPath..'Modules/Colors.lua').Colors

function Name(unit) -- Mandatory function
	return 'Repair Structures'
end

function IsAvailable(unit) -- Mandatory function
	local id = unit:GetEntityId()
	if CF.IsMilitary(unit) and DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 and DM.GetProperty(id,'PrestigeClass', nil) == 'Guardian' then return true end
	return false
end

function Description(unit) -- Mandatory function
	local bp = unit:GetBlueprint()
	local id = unit:GetEntityId()
	local PowerModifier = CF.GetStanceModifier(unit, 'PowerStrengh_Mod') + (DM.GetProperty(id, 'Buff_PowerDamage_ALL_Add', 0) / 100)
	local Power = math.floor(math.pow(bp.Economy.BuildCostMass, 0.5) * PowerModifier)
	local Int = DM.GetProperty(id, 'Intelligence')
	local Restoration = 0
	if DM.GetProperty(id, 'Restoration', 0) then Restoration = CF.GetSkillCurrent(id, 'Restoration') end
	local Health = Power * 40 * (1 + Int/100 + Restoration/100) 
	local HealthMin = math.floor(Health * 0.75)
	local HealthMax = math.floor(Health * 1.25)
	local Tp = {} Tp.Line = {} Tp.Width = 230 Tp.OffSetY = -70
	local Techlevel = CF.GetUnitTech(unit)
	table.insert(Tp.Line, {'Repair Structures'})
	table.insert(Tp.Line, {'Repair all self & allies structures up to tech '..Techlevel, Color.WHITE})
	table.insert(Tp.Line, {'+ '..HealthMin..'-'..HealthMax..' to health', Color.AEON})
	table.insert(Tp.Line, {''})
	table.insert(Tp.Line, {'1 Cycle (5 building / s) (AOE 25)', Color.AQUA})
	if DM.GetProperty(id,  Name(unit)..'_AutoCast', nil) == 1 then
		table.insert(Tp.Line, {'AutoCast is ON', Color.AEON})
	else
		table.insert(Tp.Line, {'Right click to activate autocast', Color.AEON})
	end
	table.insert(Tp.Line, {'ReCast time : 15 s', Color.AQUA})
	local id = unit:GetEntityId()
	local Capacitor = DM.GetProperty(id, 'Capacitor')
	if GetPowerCost(unit) > Capacitor then
		local NeedCapacitor =  math.ceil(GetPowerCost(unit) - Capacitor)
		table.insert(Tp.Line, {'Power Cost : '..GetPowerCost(unit)..' (-'..NeedCapacitor..')', Color.UEF})
	else
		table.insert(Tp.Line, {'Power Cost : '..GetPowerCost(unit), Color.UEF})
	end
	return Tp
end

function CanCast(unit, callfromsim) -- Mandatory function
	local id = unit:GetEntityId()
	if DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 and ReCastTime(unit, callfromsim) == '' and GetPowerCost(unit) < DM.GetProperty(id, 'Capacitor') then
		return true
	else
		return false
	end
end

function GetLevel(unit)
end


function GetPowerCost(unit) -- Mandatory function
	return 30
end

function OnCast(unit, TempEntity, Option) -- Mandatory function. This function is called from ui immediately when the power icon is clicked on
	local bp = unit:GetBlueprint()
	local id = unit:GetEntityId()
	local army = unit:GetArmy()
	local Time = 150
	local Weight =  5
	local time = math.floor(GetGameTimeSeconds())
	local CapacitorDecrease = false
	local PowerModifier = CF.GetStanceModifier(unit, 'PowerStrengh_Mod') + (AoHBuff.GetBuffValue(unit, 'PowerDamage', 'ALL') / 100)
	local Power = math.floor(math.pow(bp.Economy.BuildCostMass, 0.5) * PowerModifier)
	local Int = DM.GetProperty(id, 'Intelligence')
	if DM.GetProperty(id, 'Restoration', 0) then Restoration = CF.GetSkillCurrent(id, 'Restoration') end
	local Health = Power * 40 * (1 + Int/100 + Restoration / 100) 
	local HealthMin = math.floor(Health * 0.75)
	local HealthMax = math.floor(Health * 1.25)
	--  buff
	local units = unit:GetAIBrain():GetUnitsAroundPoint(categories.STRUCTURE - categories.WALL, unit:GetPosition(), 25, 'Ally')
	local TimeOffSet = 0
	for k, _unit in units do
		local _bp = _unit:GetBlueprint()
		local _HealAmount = 0
		local HealAmount = math.ceil(math.random(HealthMin, HealthMax))	
		local unithealth = _unit:GetHealth()
		local unitmaxhealth = _unit:GetMaxHealth()
		if _unit.IsBuilt == true and unithealth < unitmaxhealth then
			_HealAmount = math.min(unitmaxhealth - unithealth, HealAmount)
			_unit.UnitsBuffThread = _unit:ForkThread(Heal, _HealAmount, TimeOffSet, unit)
			_unit.KillPowerThread = _unit:ForkThread(KillPower, GetDuration(unit), Name(unit))
			CapacitorDecrease = true
			unit.HpHealed = unit.HpHealed + math.ceil(_HealAmount)
		end
		TimeOffSet = TimeOffSet + 0.2
	end	
	if CapacitorDecrease == true then
		DM.IncProperty(id, 'Capacitor', - GetPowerCost(unit))
		if DM.GetProperty(id, 'Restoration') then -- Adding XP to Restoration
			local Attenuate = math.min(CF.GetSkillCurrent(id, 'Restoration')/10, 10)
			local Gain = 15 * math.pow(0.90, Attenuate)
			DM.IncProperty(id, 'Restoration', Gain)
		end
		DM.SetProperty(id, 'CastTime_'..Name(unit), time)
		unit:UpdateUnitData(5)
	end
end


Heal = function(unit, HealAmount, TimeOffSet, Healer)
	WaitSeconds(TimeOffSet)
	local army = unit:GetArmy()
	CreateLightParticleIntel(unit, -1, army, 5, 50, 'glow_02', 'ramp_green_01')
	unit:AdjustHealth(unit, HealAmount) 
	FX.DrawNumbers(unit, HealAmount, 'Green') 
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

function ReCastTime(unit, callfromsim) -- Mandatory function
	local _id = unit:GetEntityId()
	local time = math.floor(GetGameTimeSeconds())
	local ReCastTime = ''
	if DM.GetProperty(_id, 'CastTime_'..Name()) then
		ReCastTime = math.max(0, 15 - (time - DM.GetProperty(_id, 'CastTime_'..Name())))
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

