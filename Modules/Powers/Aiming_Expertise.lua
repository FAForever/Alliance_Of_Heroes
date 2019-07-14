local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local FX = import(ModPath..'Modules/Effects.lua')
local Buff = import('/lua/sim/buff.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Color = import(ModPath..'Modules/Colors.lua').Colors

function Name(unit) -- Mandatory function
	return 'Aiming Expertise'
end

function IsAvailable(unit) -- Mandatory function
	local id = unit:GetEntityId()
	if CF.IsMilitary(unit) and DM.GetProperty(id,'PrestigeClass', nil) == 'Ranger' then return true end
	return false
end

function Description(unit) -- Mandatory function
	local bp = unit:GetBlueprint()
	local id = unit:GetEntityId()
	local Int = DM.GetProperty(id, 'Intelligence')
	local Rangercraft = 0
	if DM.GetProperty(id, 'Rangercraft', 0) then Rangercraft = CF.GetSkillCurrent(id, 'Rangercraft') end
	local PowerModifier = CF.GetStanceModifier(unit, 'PowerStrengh_Mod') + (AoHBuff.GetBuffValue(unit, 'PowerDamage', 'ALL') / 100)
	local Power = math.floor(70 * PowerModifier * (1 + Rangercraft/100 + Int/100))
	local Attack = Power
	local Tp = {} Tp.Line = {} Tp.Width = 180 Tp.OffSetY = -70
	table.insert(Tp.Line, {'Aiming Expertise'})
	table.insert(Tp.Line, {'Personal attack buff', Color.WHITE})
	table.insert(Tp.Line, {'+ '..Attack..' accuracy', Color.AEON})
	table.insert(Tp.Line, {''})
	table.insert(Tp.Line, {'Duration : 360 s', Color.AQUA})
	table.insert(Tp.Line, {'ReCast time : 360 s', Color.AQUA})
	local id = unit:GetEntityId()
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
	return 70
end

function OnCast(unit, TempEntity, Option) -- Mandatory function. This function is called from ui immediately when the power icon is clicked on
	local bp = unit:GetBlueprint()
	local id = unit:GetEntityId()
	local army = unit:GetArmy()
	local time = math.floor(GetGameTimeSeconds())
	local PowerModifier = CF.GetStanceModifier(unit, 'PowerStrengh_Mod') + (AoHBuff.GetBuffValue(unit, 'PowerDamage', 'ALL') / 100)
	local Int = DM.GetProperty(id, 'Intelligence')
	local Rangercraft = 0
	if DM.GetProperty(id, 'Rangercraft', 0) then Rangercraft = CF.GetSkillCurrent(id, 'Rangercraft') end
	local Power = math.floor(70 * PowerModifier * (1 + Rangercraft/100 + Int/100))
	local Attack = Power
	local soundfx = Sound({Bank = 'UEADestroy', Cue = 'UEA_Destroy_Air_Killed'})
	unit:PlaySound(soundfx)
	DM.SetProperty(id, 'EffectTime_'..Name(unit), 1) -- this is a flag informing that the power is on (may be useful for further add of an active icon on units flagged)
	unit.KillPowerThread = unit:ForkThread(KillPower, GetDuration(unit), Name(unit))
	CreateLightParticleIntel(unit, -1, unit:GetArmy(), 5, 50, 'glow_02', 'ramp_white_01' )
	local time = math.floor(GetGameTimeSeconds())
	DM.SetProperty(id, 'CastTime_'..Name(unit), time)
	RangerAttack = {
		Name = 'RangerAttack',
		BuffCat = 'ACTIVE',
		BuffFamily = 'Rangercraft',
		Stacks = 'STACK',
		StackRank = 1,
		Duration = GetDuration(unit),
		Affects = {
			Attack = {
				ALL = {
					Add = Attack,
				},
			},
		},
	}
	AoHBuff.ApplyBuff(unit, RangerAttack)
	DM.IncProperty(id, 'Capacitor', - GetPowerCost(unit))
	if DM.GetProperty(id, 'Rangercraft') then -- Adding XP to Rangercraft
		local Attenuate = math.min(CF.GetSkillCurrent(id, 'Rangercraft')/10, 10)
		local Gain = 5 * math.pow(0.90, Attenuate)
		DM.IncProperty(id, 'Rangercraft', Gain)
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
	return 360
end

function ReCastTime(unit, callfromsim) -- Mandatory function
	local _id = unit:GetEntityId()
	local time = math.floor(GetGameTimeSeconds())
	local ReCastTime = ''
	if DM.GetProperty(_id, 'CastTime_'..Name()) then
		ReCastTime = math.max(0, 360 - (time - DM.GetProperty(_id, 'CastTime_'..Name())))
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

