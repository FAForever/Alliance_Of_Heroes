local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local FX = import(ModPath..'Modules/Effects.lua')
local Buff = import('/lua/sim/buff.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Color = import(ModPath..'Modules/Colors.lua').Colors
BCMod = {Fighter = 1, Rogue = 0.75, Support = 0.25, Ardent = 0.25}
PCMod = {Elite = 0, Guardian = 0.25, Dreadnought = 0.50, Bard = 0, Ranger = 0.25}

function Name(unit) -- Mandatory function
	return 'ColdBeam'
end

function IsAvailable(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
	if CF.IsMilitary(unit) and DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 then
		if BaseClass == 'Fighter' or  BaseClass == 'Rogue' then
			for i, wep in bp.Weapon do
				if wep.Label == 'ColdBeam' then
					return true 
				end
			end
		end
	end
	return false
end

function Description(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local Tp = {} Tp.Line = {} Tp.Width = 260 Tp.OffSetY = -35
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
	local RankLevel = ((BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
	local Int = DM.GetProperty(id, 'Intelligence')
	local PowerModifier = CF.GetStanceModifier(unit, 'PowerStrengh_Mod') + (DM.GetProperty(id, 'Buff_PowerDamage_ALL_Add', 0) / 100)
	local Power = math.ceil(math.pow(bp.Economy.BuildCostMass, 0.7) * (2 + Int/25) * PowerModifier * 2)
	local WeaponIndexList, WeaponCategoriesList = CF.GetWeaponIndexList(unit)
	local len = table.getn(WeaponIndexList)
	local wepdata = {}
	for i, wep in bp.Weapon do
		if wep.Label == 'ColdBeam' then
			wepdata.Name = wep.DisplayName
			wepdata.Damage = math.ceil(wep.Damage * RankLevel * (1 + Power/1000))
			wepdata.rof = wep.RateOfFire
			wepdata.MaxRadius = wep.MaxRadius
			wepdata.DamageType = wep.WeaponCategory
			wepdata.DamRadius = wep.DamageRadius
		end
	end
	
	-- LOG(repr(wepdata))
	Power = math.ceil(Power * RankLevel)
	table.insert(Tp.Line, {wepdata.Name})
	table.insert(Tp.Line, {'Rank : '..CF.GetRankName(RankLevel), Color.GREY_LIGHT})
	table.insert(Tp.Line, {wepdata.DamageType, Color.PURPLE})
	table.insert(Tp.Line, {''})
	table.insert(Tp.Line, {'Base damage : '..wepdata.Damage, Color.WHITE})
	table.insert(Tp.Line, {'Base Rate of Fire : '..wepdata.rof, Color.WHITE})
	table.insert(Tp.Line, {'Damage Radius : '..wepdata.DamRadius, Color.AEON})
	table.insert(Tp.Line, {''})
	table.insert(Tp.Line, {'Use Weapon Capacitor', Color.ORANGE_LIGHT})
	if DM.GetProperty(id,  Name(unit)..'_AutoCast', nil) == 1 then
		table.insert(Tp.Line, {'BEAM AUTOFIRE is ON', Color.AEON})
	else
		table.insert(Tp.Line, {'Left click to activate BEAM FIRE', Color.CYBRAN})
		table.insert(Tp.Line, {'Right click to activate BEAM AUTOFIRE', Color.CYBRAN})
	end
	return Tp
end

function CanCast(unit, callfromsim) -- Mandatory function
	local id = unit:GetEntityId()
	if DM.GetProperty(id, 'HasATarget') == true and DM.GetProperty(id, 'Stamina') > 20 then
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
	return math.ceil(10 * RankLevel)
end

function OnCast(unit, TempEntity, Option) -- Mandatory function. This function is called from ui immediately when the power icon is clicked on
	unit:SetWeaponEnabledByLabel('ColdBeam', true)
end

KillPower = function(unit, duration, PowerName) -- Mandatory function
	WaitSeconds(duration)
	local id = unit:GetEntityId()
	DM.SetProperty(id, 'EffectTime_'..PowerName, nil)
end

function OnWeaponHit(target, instigator) -- Mandatory if this function is called when the unit hit the target (active if DM.SetProperty(id, 'ExecuteWeaponBuffOnTarget', Name(unit)) has been set in OnCast function)
end

function StrikeData(unit) -- Mandatory if this function is called. When DM.SetProperty(id, 'ExecuteStrikeAtBone', Name(unit)) is set on Oncast function. It will change a projectile bp and cast a strike on the next weapon fire.
	local StrikeData = {} -- Please note that for now only Direct Fire, Direct Fire Naval and Direct Fire Experimental are supported. 
	return StrikeData
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
		ReCastTime = math.max(0, 1 - (time - DM.GetProperty(_id, 'CastTime_'..Name())))
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

