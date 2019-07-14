local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local FX = import(ModPath..'Modules/Effects.lua')
local Buff = import('/lua/sim/buff.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Color = import(ModPath..'Modules/Colors.lua').Colors
local BCMod = {Fighter = 1, Rogue = 0.5, Support = 0.5, Ardent = 0.25}
local PCMod = {Elite = 0.25, Guardian = 1, Dreadnought = 0.75, Bard = 0.25, Restorer = 0.5, Ranger = 0.5}

function Name(unit) -- Mandatory function
	return 'Wall of Steel'
end

function IsAvailable(unit) -- Mandatory function
	local id = unit:GetEntityId()
	if CF.IsMilitary(unit) and DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 then return true end
	return false
end

function Description(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local Tp = {} Tp.Line = {} Tp.Width = 130 Tp.OffSetY = -70
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
	local RankLevel = ((BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
	local BuffAmount = math.ceil(85 * RankLevel)
	table.insert(Tp.Line, {'Wall of Steel'})
	table.insert(Tp.Line, {'Rank : '..CF.GetRankName(RankLevel), Color.GREY_LIGHT})
	table.insert(Tp.Line, {'Personal buff', Color.WHITE})
	table.insert(Tp.Line, {'+ '..BuffAmount..' Armor', Color.AEON})
	table.insert(Tp.Line, {''})
	table.insert(Tp.Line, {'Duration : '..GetDuration(unit)..' s', Color.AQUA})
	table.insert(Tp.Line, {'ReCast time : 120 s', Color.AQUA})
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

function CanCast(unit) -- Mandatory function
	local id = unit:GetEntityId()
	if ReCastTime(unit) == '' and GetPowerCost(unit) < DM.GetProperty(id, 'Capacitor') then
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
	return math.ceil(100 * RankLevel)
end

function OnCast(unit, TempEntity, Option) -- Mandatory function. This function is called from ui immediately when the power icon is clicked on
	local bp = unit:GetBlueprint()
	local id = unit:GetEntityId()
	local army = unit:GetArmy()
	local Time = 150
	local Weight =  5
	CreateLightParticleIntel(unit, -1, army, Weight, 50, 'glow_02', 'ramp_white_01' )
	local time = math.floor(GetGameTimeSeconds())
	DM.SetProperty(id, 'CastTime_'..Name(unit), time)
	-- self buff
	if not DM.GetProperty(id, 'EffectTime_'..Name(unit))  then	-- we check to not stack Fx
		local soundfx = Sound({Bank = 'UEADestroy', Cue = 'UEA_Destroy_Air_Killed'})
		unit:PlaySound(soundfx)
		DM.SetProperty(id, 'EffectTime_'..Name(unit), 1) -- this is a flag informing that the power is on (may be useful for further add of an active icon on units flagged)
		unit.KillPowerThread = unit:ForkThread(KillPower, GetDuration(unit), Name(unit))
		local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
		local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
		local RankLevel = ((BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
		local BuffAmount = math.ceil(85 * RankLevel)
		unit.UnitsBuffThread = unit:ForkThread(UnitsBuff, BuffAmount)
	end
	DM.IncProperty(id, 'Capacitor', - GetPowerCost(unit))
	unit:UpdateUnitData(5)
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
	local id = unit:GetEntityId()
	AofBuffBlueprint = {
		Name = 'ArmorStrengh',
		BuffCat = 'ACTIVE',
		BuffFamily = 'Armorbuff',
		Stacks = 'STACK',
		StackRank = 1,
		Duration = GetDuration(unit),
		Affects = {
			Armor = {
				ALL = {
					Add = bonus,
				},
			},
		},
	}
	AoHBuff.ApplyBuff(unit, AofBuffBlueprint)
end

function GetDuration(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
	local RankLevel = ((BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
	return math.ceil(60 * RankLevel)
end

function ReCastTime(unit) -- Mandatory function
	local _id = unit:GetEntityId()
	local time = math.floor(GetGameTimeSeconds())
	local ReCastTime = ''
	if DM.GetProperty(_id, 'CastTime_'..Name()) then
		ReCastTime = math.max(0, 120 - (time - DM.GetProperty(_id, 'CastTime_'..Name())))
	end
	if ReCastTime <= 1 then 
		SimCallback	({Func= 'KillCastTime', Args = {id = _id, PowerName = Name()}})
	end
	return ReCastTime
end

