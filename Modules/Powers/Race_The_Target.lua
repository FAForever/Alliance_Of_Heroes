local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local FX = import(ModPath..'Modules/Effects.lua')
local Buff = import('/lua/sim/buff.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Color = import(ModPath..'Modules/Colors.lua').Colors

function Name(unit) -- Mandatory function
	return 'Race the target'
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
	local Tp = {} Tp.Line = {} Tp.Width = 290 Tp.OffSetY = -35
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Ranger')
	local Dex = DM.GetProperty(id, 'Dexterity')
	local Rangercraft = 0
	if DM.GetProperty(id, 'Rangercraft', 0) then Rangercraft = CF.GetSkillCurrent(id, 'Rangercraft') end
	local Power = 10 * (1 + Dex/100 + Rangercraft/50)
	local MouvementRateBonuspercent = math.min(math.ceil(Power), 55)
	table.insert(Tp.Line, {'Race the Target'})
	table.insert(Tp.Line, {'Personal mouvement buff', Color.WHITE})
	table.insert(Tp.Line, {'+ '..MouvementRateBonuspercent..' % Moving, Acc. & Turn rate', Color.AEON})
	table.insert(Tp.Line, {'Non stackable with other kind of mouvement buff', Color.WHITE})
	table.insert(Tp.Line, {''})
	table.insert(Tp.Line, {'Duration : '..GetDuration(unit)..' s', Color.AQUA})
	table.insert(Tp.Line, {'ReCast Time : 300 s', Color.AQUA})
	local Capacitor = DM.GetProperty(id, 'Stamina')
	if GetPowerCost(unit) > Capacitor then
		local NeedCapacitor =  math.ceil(GetPowerCost(unit) - Capacitor)
		table.insert(Tp.Line, {'Power Cost : '..GetPowerCost(unit)..' (-'..NeedCapacitor..')', Color.YELLOW1})
	else
		table.insert(Tp.Line, {'Power Cost : '..GetPowerCost(unit), Color.YELLOW1})
	end
	return Tp
end

function CanCast(unit) -- Mandatory function
	local id = unit:GetEntityId()
	if ReCastTime(unit) == '' and GetPowerCost(unit) < DM.GetProperty(id, 'Stamina') then
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
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Ranger')
	local Dex = DM.GetProperty(id, 'Dexterity')
	local Rangercraft = 0
	if DM.GetProperty(id, 'Rangercraft', 0) then Rangercraft = CF.GetSkillCurrent(id, 'Rangercraft') end
	local Power = 10 * (1 + Dex/100 + Rangercraft/50)
	local MouvementRateBonus = math.min(math.ceil(Power), 55) / 100
	local sound = Sound({Bank = 'UAL', Cue = 'UAL0106_Move_Start'})
	unit:PlaySound(sound)
	local bp = unit:GetBlueprint()
	local id = unit:GetEntityId()
	local army = unit:GetArmy()
	local Time = 300
	local Weight =  5
	CreateEmitterAtEntity(unit, unit:GetArmy(), ModPath..'Graphics/Emitters/FastMoving.bp'):OffsetEmitter(0, 0.5, 0):ScaleEmitter(0.25)
	local time = math.floor(GetGameTimeSeconds())
	DM.SetProperty(id, 'CastTime_'..Name(unit), time)
	-- self buff
	BuffBlueprint {
		Name = 'Fast Moving',
		DisplayName = 'Fast Moving',
		BuffType = 'Moving Buff',
		Stacks = 'STACKS',
		Duration = GetDuration(unit),
		Affects = {
				MoveMult = {
					Add = 0,
					Mult = 1 + MouvementRateBonus,
				},
		},
	}
	Buff.ApplyBuff(unit, 'Fast Moving')
	DM.IncProperty(id, 'Stamina', - GetPowerCost(unit))
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

UnitsBuff = function(unit, bonus)
end

function GetDuration(unit) -- Mandatory function
	return 60
end

function ReCastTime(unit) -- Mandatory function
	local _id = unit:GetEntityId()
	local time = math.floor(GetGameTimeSeconds())
	local ReCastTime = ''
	if DM.GetProperty(_id, 'CastTime_'..Name()) then
		ReCastTime = math.max(0, 300 - (time - DM.GetProperty(_id, 'CastTime_'..Name())))
	end
	if ReCastTime <= 1 then 
		SimCallback	({Func= 'KillCastTime', Args = {id = _id, PowerName = Name()}})
	end
	return ReCastTime
end

