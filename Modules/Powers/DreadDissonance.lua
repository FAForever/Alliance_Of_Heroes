local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local FX = import(ModPath..'Modules/Effects.lua')
local Buff = import('/lua/sim/buff.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Color = import(ModPath..'Modules/Colors.lua').Colors
local BCMod = {Fighter = 0, Rogue = 0, Support = 0, Ardent = 1}
local PCMod = {Elite = 0, Guardian = 0, Dreadnought = 0, Bard = 1}


function Name(unit) -- Mandatory function
	return 'DreadDissonance'
end

function IsAvailable(unit) -- Mandatory function
local id = unit:GetEntityId()
	if CF.IsMilitary(unit) and DM.GetProperty(id,'PrestigeClass', nil) == 'Bard' then return true end
	return false
end

function Description(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local Tp = {} Tp.Line = {} Tp.Width = 200 Tp.OffSetY = -70
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
	local RankLevel = ((BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
	local Int = DM.GetProperty(id, 'Intelligence')
	local Bardsong = 0
	if DM.GetProperty(id, 'Bardsong', 0) then Bardsong = CF.GetSkillCurrent(id, 'Bardsong') end
	local PowerModifier = CF.GetStanceModifier(unit, 'PowerStrengh_Mod') + (DM.GetProperty(id, 'Buff_PowerDamage_ALL_Add', 0) / 100)
	local Power = math.pow(bp.Economy.BuildCostMass, 0.7) * (1 + Int/15)* (1 + Bardsong/100) * PowerModifier * 8
	Power = math.ceil(Power * RankLevel)
	local StrikeToShield = math.ceil(Power * 2.5)
	local Radius = math.min(math.ceil(7 * RankLevel), 7)
	local stunduration = math.max(math.ceil(4 * RankLevel), 2)
	local Techlevel = CF.GetUnitTech(unit)
	table.insert(Tp.Line, {'Dread Dissonance'})
	table.insert(Tp.Line, {'Rank : '..CF.GetRankName(RankLevel), Color.GREY_LIGHT})
	table.insert(Tp.Line, {'Single Target Damage and Stun', Color.WHITE})
	table.insert(Tp.Line, {''})
	table.insert(Tp.Line, {'Damage strike', Color.WHITE})
	table.insert(Tp.Line, {'Plasma', Color.PURPLE})
	table.insert(Tp.Line, {'Damage : '..Power..' (Ignore Armor)', Color.CYBRAN})
	table.insert(Tp.Line, {'Damage to Shields : '..StrikeToShield, Color.BLUE1})
	table.insert(Tp.Line, {'Damage Radius : '..Radius, Color.CYBRAN})
	table.insert(Tp.Line, {'Units Up to Tech '..Techlevel, Color.GREY_LIGHT})
	table.insert(Tp.Line, {'Stun duration  : '..stunduration..' s', Color.CYBRAN})
	table.insert(Tp.Line, {''})
	table.insert(Tp.Line, {'Loaded on next weapon projectile fire', Color.CYBRAN})
	if DM.GetProperty(id,  Name(unit)..'_AutoCast', nil) == 1 then
		table.insert(Tp.Line, {'AutoCast is ON', Color.AEON})
	else
		table.insert(Tp.Line, {'Right click to activate autocast', Color.AEON})
	end
	table.insert(Tp.Line, {'Duration : '..GetDuration(unit)..' s', Color.AQUA})
	table.insert(Tp.Line, {'ReCast Time : 8 s', Color.AQUA})
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
	local Bardsong = 0
	if DM.GetProperty(id, 'Bardsong', 0) then Bardsong = CF.GetSkillCurrent(id, 'Bardsong') end
	return math.ceil(35 * RankLevel * (1 + Int/75) + Bardsong/250)
end

function OnCast(unit, TempEntity, Option) -- Mandatory function. This function is called from ui immediately when the power icon is clicked on
	local bp = unit:GetBlueprint()
	local id = unit:GetEntityId()
	local army = unit:GetArmy()
	local Time = 150
	local Weight =  2
	DM.SetProperty(id, 'ExecuteWeaponBuffOnTarget', Name(unit)) -- If we want to call a weaponbuff power
	DM.SetProperty(id, 'ExecuteStrikeAtBone', Name(unit)) -- If we want to call a strike power. 
	local time = math.floor(GetGameTimeSeconds())
	DM.SetProperty(id, 'CastTime_'..Name(unit), time)
	-- self buff
	local UnitCatId = unit:GetUnitId()
	if not DM.GetProperty(id, 'EffectTime_'..Name(unit))  then	-- we check to not stack Fx
		DM.SetProperty(id, 'EffectTime_'..Name(unit), 1) -- this is a flag informing that the power is on (may be useful for further add of an active icon on units flagged)
		unit.KillPowerThread = unit:ForkThread(KillPower, GetDuration(unit), Name(unit))
	end
	unit:UpdateUnitData(2)
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
		local targetbp = target:GetBlueprint()
		if CF.GetUnitTech(instigator) >= CF.GetUnitTech(target) and not table.find(targetbp, 'AIR') then
			local BaseClass = DM.GetProperty(idi,'BaseClass','Fighter')
			local PrestigeClass = DM.GetProperty(idi,'PrestigeClass','Dreadnought')
			local RankLevel = ((BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
			local stunduration = math.max(math.ceil(4 * RankLevel), 2)
			target:SetStunned(stunduration)
			CreateLightParticleIntel(target, -1, target:GetArmy(), 3, 40, 'glow_02', 'ramp_white_01' )
		end
		if DM.GetProperty(idi, 'Bardsong') then -- Automatic XP to Restoration
			local Attenuate = math.min(CF.GetSkillCurrent(idi, 'Bardsong')/10, 10)
			local Gain = math.pow(0.90, Attenuate)
			DM.IncProperty(idi, 'Bardsong', Gain)
		end
	end
end

function StrikeData(unit) -- Mandatory if this function is called. When DM.SetProperty(id, 'ExecuteStrikeAtBone', Name(unit)) is set on Oncast function. It will change a projectile bp and cast a strike on the next weapon fire.
	local StrikeData = {} -- Please note that for now only Direct Fire, Direct Fire Naval and Direct Fire Experimental are supported. 
	-- Projectile ID -- will change the Projectile bp 
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
	local RankLevel = ((BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
	local Tp = {} Tp.Line = {} Tp.Width = 225 Tp.OffSetY = -70
	local Int = DM.GetProperty(id, 'Intelligence')
	local Bardsong = 0
	if DM.GetProperty(id, 'Bardsong', 0) then Bardsong = CF.GetSkillCurrent(id, 'Bardsong') end
	local PowerModifier = CF.GetStanceModifier(unit, 'PowerStrengh_Mod') + (AoHBuff.GetBuffValue(unit, 'PowerDamage', 'ALL') / 100)
	local Power = math.pow(bp.Economy.BuildCostMass, 0.7) * (1 + Int/15)* (1 + Bardsong/100) * PowerModifier * 8
	Power = math.ceil(Power * RankLevel)
	local Radius = math.min(math.ceil(7 * RankLevel), 7)
	local stunduration = math.max(math.ceil(4 * RankLevel), 2)
	StrikeData.ProjectileBp = '/Mods/Alliance_Of_Heroes/Modules/Projectiles/CDFCannonMolecularOvercharge01/CDFCannonMolecularOvercharge01_proj.bp'
	-- StrikeData.InitialDamageAmount = Power
	StrikeData.DamageAmount = Power
	StrikeData.DamageRadius = Radius
	StrikeData.ShieldDamageMod = 2.5
	StrikeData.DamageFriendly = false
	StrikeData.CollideFriendly = false
	StrikeData.DamType = 'Plasma'
	StrikeData.Instigator = unit
	StrikeData.TargetIds = {}
	-- Beams ID -- will change the beam bp 
	StrikeData.FxBeamStartPoint = {}
	StrikeData.FxBeam = {}
	StrikeData.FxBeamEndPoint = {} 
	return StrikeData
end

function GetDuration(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
	local RankLevel = ((BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
	return math.ceil(4 * RankLevel)
end

function ReCastTime(unit, callfromsim) -- Mandatory function
	local _id = unit:GetEntityId()
	local time = math.floor(GetGameTimeSeconds())
	local ReCastTime = ''
	if DM.GetProperty(_id, 'CastTime_'..Name()) then
		ReCastTime = math.max(0, 8 - (time - DM.GetProperty(_id, 'CastTime_'..Name())))
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

