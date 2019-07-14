local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local FX = import(ModPath..'Modules/Effects.lua')
local Buff = import('/lua/sim/buff.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Color = import(ModPath..'Modules/Colors.lua').Colors

function Name(unit) -- Mandatory function
	return 'ranger_vigor'
end

function IsAvailable(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
	if CF.IsMilitary(unit) and DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 and PrestigeClass == 'Ranger' then 
		return true 
	end
	return false
end

function Description(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local Tp = {} Tp.Line = {} Tp.Width = 205 Tp.OffSetY = -70
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Ranger')
	local Dex = DM.GetProperty(id, 'Dexterity')
	local Rangercraft = 0
	if DM.GetProperty(id, 'Rangercraft', 0) then Rangercraft = CF.GetSkillCurrent(id, 'Rangercraft') end
	local Power = 40 * (1 + Dex/100 + Rangercraft/100)
	local RecoveryBuff = math.min(math.ceil(Power), 125)
	table.insert(Tp.Line, {'Ranger Vigor'})
	table.insert(Tp.Line, {'Personal weapon capacitor recovery buff', Color.WHITE})
	table.insert(Tp.Line, {'+ '..RecoveryBuff..' % recovery', Color.AEON})
	table.insert(Tp.Line, {''})
	table.insert(Tp.Line, {'Duration : '..GetDuration(unit)..' s', Color.AQUA})
	table.insert(Tp.Line, {'ReCast Time : 30 s', Color.AQUA})
	local Capacitor = DM.GetProperty(id, 'Capacitor')
	if DM.GetProperty(id,  Name(unit)..'_AutoCast', nil) == 1 then
		table.insert(Tp.Line, {'AutoCast is ON', Color.AEON})
	else
		table.insert(Tp.Line, {'Right click to activate autocast', Color.AEON})
	end
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
	local id = unit:GetEntityId()
	local Rangercraft = 0
	if DM.GetProperty(id, 'Rangercraft', 0) then Rangercraft = CF.GetSkillCurrent(id, 'Rangercraft') end
	return math.ceil(25 * (1 + Rangercraft / 100))
end

function OnCast(unit, TempEntity, Option) -- Mandatory function. This function is called from ui immediately when the power icon is clicked on
	local id = unit:GetEntityId()
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Ranger')
	local Dex = DM.GetProperty(id, 'Dexterity')
	local Rangercraft = 0
	if DM.GetProperty(id, 'Rangercraft', 0) then Rangercraft = CF.GetSkillCurrent(id, 'Rangercraft') end
	local Power = 50 * (1 + Dex/100 + Rangercraft/100)
	local RecoveryBuff = math.min(math.ceil(Power), 125)
	local sound = Sound({Bank = 'UAL', Cue = 'UAL0106_Move_Start'})
	unit:PlaySound(sound)
	local bp = unit:GetBlueprint()
	local id = unit:GetEntityId()
	local army = unit:GetArmy()
	CreateEmitterAtEntity(unit, unit:GetArmy(), ModPath..'Graphics/Emitters/FastMoving.bp'):OffsetEmitter(0, 0.5, 0):ScaleEmitter(0.25)
	local time = math.floor(GetGameTimeSeconds())
	DM.SetProperty(id, 'CastTime_'..Name(unit), time)
	AofBuffBlueprint = {
		Name = 'Ranger Vigor',
		BuffCat = 'ACTIVE',
		BuffFamily = 'Buff',
		Stacks = 'STACK',
		StackRank = 1,
		Duration = 30,
		Affects = {
			WeaponCapacitorRecovery = {
				ALL = {
					Add = RecoveryBuff,
				},
			},
		},
	}
	AoHBuff.ApplyBuff(unit, AofBuffBlueprint)
	DM.IncProperty(id, 'Capacitor', - GetPowerCost(unit))
		if DM.GetProperty(id, 'Rangercraft') then -- Adding XP to Rangercraft
		local Attenuate = math.min(CF.GetSkillCurrent(id, 'Rangercraft')/10, 10)
		local Gain = 2 * math.pow(0.90, Attenuate)
		DM.IncProperty(id, 'Rangercraft', Gain)
	end
end

KillPower = function(unit, duration, PowerName) -- Mandatory function
end

function OnWeaponHit(target, instigator) -- Mandatory if this function is called when the unit hit the target (active if DM.SetProperty(id, 'ExecuteWeaponBuffOnTarget', Name(unit)) has been set in OnCast function)
end

function StrikeData(unit) -- Mandatory if this function is called. When DM.SetProperty(id, 'ExecuteStrikeAtBone', Name(unit)) is set on Oncast function. It will change a projectile bp and cast a strike on the next weapon fire.
end

UnitsBuff = function(unit, bonus)
end

function GetDuration(unit) -- Mandatory function
	return 30
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

