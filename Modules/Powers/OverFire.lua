local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local FX = import(ModPath..'Modules/Effects.lua')
local Buff = import('/lua/sim/buff.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Color = import(ModPath..'Modules/Colors.lua').Colors
local BCMod = {Fighter = 0.25, Rogue = 0.5, Support = 0.5, Ardent = 1}
local PCMod = {Elite = 0.25, Guardian = 0.5, Dreadnought = 0.35, Bard = 0.75}



function Name(unit) -- Mandatory function
	return 'Over Fire'
end

function IsAvailable(unit) -- Mandatory function
	local id = unit:GetEntityId()
	if CF.IsMilitary(unit) and DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 then 
		local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
		local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
		if PrestigeClass == 'Ardent' then
			return true
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
	local Int = DM.GetProperty(id, 'Intelligence')
	local PowerModifier = CF.GetStanceModifier(unit, 'PowerStrengh_Mod') + (DM.GetProperty(id, 'Buff_PowerDamage_ALL_Add', 0) / 100)
	local Power = math.ceil(math.pow(bp.Economy.BuildCostMass, 0.7) * (2 + Int/25) * PowerModifier * 4)
	Power = math.ceil(Power * RankLevel)
	local RofBonus = math.ceil(50 * RankLevel)
	table.insert(Tp.Line, {'OVERFIRE'})
	table.insert(Tp.Line, {'Rank : '..CF.GetRankName(RankLevel), Color.GREY_LIGHT})
	table.insert(Tp.Line, {'Personal Rate of Fire buff', Color.WHITE})
	table.insert(Tp.Line, {'+ '..RofBonus..' % Rate of Fire', Color.AEON})
	table.insert(Tp.Line, {''})
	table.insert(Tp.Line, {'Damage strike', Color.WHITE})
	table.insert(Tp.Line, {'Plasma', Color.PURPLE})
	table.insert(Tp.Line, {'Initial Strike : '..Power..' (Ignore Armor)', Color.CYBRAN})
	Power = math.ceil(Power * 0.3)
	table.insert(Tp.Line, {'Overtime : 10 x '..Power..' for 4 s', Color.CYBRAN})
	table.insert(Tp.Line, {'Damage Radius : 2', Color.CYBRAN})
	table.insert(Tp.Line, {''})
	table.insert(Tp.Line, {'Loaded on next weapon fire', Color.CYBRAN})
	if DM.GetProperty(id,  Name(unit)..'_AutoCast', nil) == 1 then
		table.insert(Tp.Line, {'AutoCast is ON', Color.AEON})
	else
		table.insert(Tp.Line, {'Right click to activate autocast', Color.AEON})
	end
	table.insert(Tp.Line, {'Duration : '..GetDuration(unit)..' s', Color.AQUA})
	table.insert(Tp.Line, {'ReCast Time : 20 s', Color.AQUA})
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
	local Int = DM.GetProperty(id, 'Intelligence')
	return math.ceil(40 * (1 + Int/25) * RankLevel)
end

function OnCast(unit, TempEntity, Option) -- Mandatory function. This function is called from ui immediately when the power icon is clicked on
	local bp = unit:GetBlueprint()
	local id = unit:GetEntityId()
	local army = unit:GetArmy()
	local Time = 150
	local Weight =  5
	DM.SetProperty(id, 'ExecuteWeaponBuffOnTarget', Name(unit)) -- If we want to call a weaponbuff power
	DM.SetProperty(id, 'ExecuteStrikeAtBone', Name(unit)) -- If we want to call a strike power. 
	CreateLightParticleIntel(unit, -1, army, Weight, 50, 'glow_02', 'ramp_red_01' )
	local time = math.floor(GetGameTimeSeconds())
	DM.SetProperty(id, 'CastTime_'..Name(unit), time)
	-- self buff
	local UnitCatId = unit:GetUnitId()
	if not DM.GetProperty(id, 'EffectTime_'..Name(unit))  then	-- we check to not stack Fx
		DM.SetProperty(id, 'EffectTime_'..Name(unit), 1) -- this is a flag informing that the power is on (may be useful for further add of an active icon on units flagged)
		unit.KillPowerThread = unit:ForkThread(KillPower, GetDuration(unit), Name(unit))
		unit:CreateFx(ModPath..'Graphics/Emitters/AuraRed.bp', 0.5, 5, 1)
		local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
		local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
		local RankLevel = ((BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
		local RofBonus = math.ceil(50 * RankLevel)
		unit.UnitsBuffThread = unit:ForkThread(UnitsBuff, RofBonus)
	end
	unit:UpdateUnitData(5)
	DM.IncProperty(id, 'Capacitor', - GetPowerCost(unit))
end

KillPower = function(unit, duration, PowerName) -- Mandatory function
	WaitSeconds(duration)
	local id = unit:GetEntityId()
	DM.SetProperty(id, 'EffectTime_'..PowerName, nil)
end

function OnWeaponHit(target, instigator) -- Mandatory if this function is called when the unit hit the target (active if DM.SetProperty(id, 'ExecuteWeaponBuffOnTarget', Name(unit)) has been set in OnCast function)
	if instigator and target then
		local idi = instigator:GetEntityId()
		local army = target:GetArmy()
		-- CreateLightParticleIntel(target, -1, army, 0.25, 5, 'glow_02', 'ramp_red_01' )
		DM.SetProperty(idi, 'ExecuteWeaponBuffOnTarget', nil)
	end
end

function StrikeData(unit) -- Mandatory if this function is called. When DM.SetProperty(id, 'ExecuteStrikeAtBone', Name(unit)) is set on Oncast function. It will change a projectile bp and cast a strike on the next weapon fire.
	local StrikeData = {} -- Please note that for now only Direct Fire, Direct Fire Naval and Direct Fire Experimental are supported. 
	-- Projectile ID -- will change the Projectile bp 
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local Tp = {} Tp.Line = {} Tp.Width = 225 Tp.OffSetY = -70
	local Int = DM.GetProperty(id, 'Intelligence')
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
	local RankLevel = ((BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
	local PowerModifier = CF.GetStanceModifier(unit, 'PowerStrengh_Mod') + (AoHBuff.GetBuffValue(unit, 'PowerDamage', 'ALL') / 100)
	local Power = math.ceil(math.pow(bp.Economy.BuildCostMass, 0.7) * (2 + Int/25) * PowerModifier * 4)
	local Power = math.ceil(Power * RankLevel)
	StrikeData.ProjectileBp = '/Mods/Alliance_Of_Heroes/Modules/Projectiles/ADFOverCharge01/ADFOverCharge01_proj.bp'
	StrikeData.InitialDamageAmount = Power
	StrikeData.DamageAmount = math.ceil(Power * 0.2)
	StrikeData.DamageRadius = 2
	StrikeData.DamageFriendly = true
	StrikeData.CollideFriendly = false
	StrikeData.DoTTime = 4
    StrikeData.DoTPulses = 10
	StrikeData.DamType = 'Plasma'
	StrikeData.ShieldDamageMod = 1
	StrikeData.Instigator = unit
	StrikeData.TargetIds = {}
	-- Beams ID -- will change the beam bp 
	StrikeData.FxBeamStartPoint = {}
	StrikeData.FxBeam = {}
	StrikeData.FxBeamEndPoint = {} 
	return StrikeData
end

UnitsBuff = function(unit, bonus)
	local id = unit:GetEntityId()
	AofBuffBlueprint = {
		Name = 'HeroRof',
		BuffCat = 'ACTIVE',
		BuffFamily = 'PowerRof',
		Stacks = 'STACK',
		StackRank = 1,
		Duration = GetDuration(unit),
		Affects = {
			RateOfFire = {
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
	return math.ceil(10 * RankLevel)
end

function ReCastTime(unit, callfromsim) -- Mandatory function
	local _id = unit:GetEntityId()
	local time = math.floor(GetGameTimeSeconds())
	local ReCastTime = ''
	if DM.GetProperty(_id, 'CastTime_'..Name()) then
		ReCastTime = math.max(0, 20 - (time - DM.GetProperty(_id, 'CastTime_'..Name())))
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

