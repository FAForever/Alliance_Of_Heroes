local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local FX = import(ModPath..'Modules/Effects.lua')
local Buff = import('/lua/sim/buff.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Color = import(ModPath..'Modules/Colors.lua').Colors
local BCMod = {Fighter = 1, Rogue = 0.75, Support = 0.5, Ardent = 0.5}
local PCMod = {Elite = 0.25, Guardian = 0.25, Dreadnought = 1, Bard = 0.5, Restorer = 0.25, Ranger = 0.75}



function Name(unit) -- Mandatory function
	return 'WhirlingSlash'
end

function IsAvailable(unit) -- Mandatory function
	local id = unit:GetEntityId()
	if CF.IsMilitary(unit) and DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 then 
		if DM.GetProperty(id,'PrestigeClass','Dreadnought') != 'Restorer' then
			return true 
		end
	end
	return false
end

function Description(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
	local RankLevel = ((BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
	local PuissanceMod = 1 + CF.GetSkillCurrent(id, 'Weapon Skill') / 100 + CF.GetSkillCurrent(id, 'Weapon Mastery') / 100
	local DamageBonus = math.ceil(100 * RankLevel * PuissanceMod)
	local ArmorReduction = math.ceil(41*RankLevel)
	local ExpDuration = math.ceil(10 * RankLevel + 2)
	local BuffDuration = math.ceil(10 * RankLevel + 5)
	local Techlevel = CF.GetUnitTech(unit)
	local Tp = {} Tp.Line = {} Tp.Width = 235 Tp.OffSetY = -70
	table.insert(Tp.Line, {'Whirling Slash'})
	table.insert(Tp.Line, {'Rank : '..CF.GetRankName(RankLevel), Color.GREY_LIGHT})
	table.insert(Tp.Line, {'Personal Damage Buff', Color.WHITE})
	table.insert(Tp.Line, {'+ '..DamageBonus..' % Damage', Color.AEON})
	table.insert(Tp.Line, {'Duration : '..BuffDuration..' s', Color.AQUA})
	table.insert(Tp.Line, {''})
	table.insert(Tp.Line, {'Armor reduction', Color.WHITE})
	table.insert(Tp.Line, {'Units Up to Tech '..Techlevel, Color.GREY_LIGHT})
	table.insert(Tp.Line, {'Target armor reduction : -'..ArmorReduction..' %', Color.ORANGE})
	table.insert(Tp.Line, {'Effect duration : '..ExpDuration..' s', Color.ORANGE})
	table.insert(Tp.Line, {'Loaded on next weapon projectile fire', Color.CYBRAN})
	table.insert(Tp.Line, {''})
	if DM.GetProperty(id,  Name(unit)..'_AutoCast', nil) == 1 then
		table.insert(Tp.Line, {'AutoCast is ON', Color.AEON})
	else
		table.insert(Tp.Line, {'Right click to activate autocast', Color.AEON})
	end
	table.insert(Tp.Line, {'ReCast Time : 20 s', Color.AQUA})
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
	local id = unit:GetEntityId()
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
	local RankLevel = ((BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
	return math.ceil(20 * RankLevel)
end


function OnCast(unit, TempEntity, Option) -- Mandatory function. This function is called from ui immediately when the power icon is clicked on
	local bp = unit:GetBlueprint()
	local id = unit:GetEntityId()
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
	local RankLevel = ((BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
	local BuffDuration = math.ceil(10 * RankLevel + 2)
	local PuissanceMod = 1 + CF.GetSkillCurrent(id, 'Weapon Skill') / 100 + CF.GetSkillCurrent(id, 'Weapon Mastery') / 100
	local DamageBonus = math.ceil(100 * RankLevel * PuissanceMod)
	local army = unit:GetArmy()
	local Time = 150
	local Weight =  5
	DM.SetProperty(id, 'ExecuteWeaponBuffOnTarget', Name(unit)) -- If we want to call a weaponbuff power
	local time = math.floor(GetGameTimeSeconds())
	DM.SetProperty(id, 'CastTime_'..Name(unit), time)
	-- self buff
	local UnitCatId = unit:GetUnitId()
	if not DM.GetProperty(id, 'EffectTime_'..Name(unit))  then	-- we check to not stack Fx
		DM.SetProperty(id, 'EffectTime_'..Name(unit), 1) -- this is a flag informing that the power is on (may be useful for further add of an active icon on units flagged)
		unit.KillPowerThread = unit:ForkThread(KillPower, GetDuration(unit), Name(unit))
		-- unit:CreateFx(ModPath..'Graphics/Emitters/AuraRed.bp', 0.5, 5, 1)
		unit.UnitsBuffThread = unit:ForkThread(UnitsBuff, DamageBonus, BuffDuration)
	end
	unit:UpdateUnitData(5)
	DM.IncProperty(id, 'Stamina', - GetPowerCost(unit))
end

KillPower = function(unit, duration, PowerName) -- Mandatory function
	WaitSeconds(duration)
	local id = unit:GetEntityId()
	DM.SetProperty(id, 'EffectTime_'..PowerName, nil)
end

function OnWeaponHit(target, instigator) -- Mandatory if this function is called when the unit hit the target (active if DM.SetProperty(id, 'ExecuteWeaponBuffOnTarget', Name(unit)) has been set in OnCast function)
	if instigator and target then
		if CF.GetUnitTech(instigator) >= CF.GetUnitTech(target) then
			local idi = instigator:GetEntityId()
			local BaseClass = DM.GetProperty(idi,'BaseClass','Fighter')
			local PrestigeClass = DM.GetProperty(idi,'PrestigeClass','Dreadnought')
			local RankLevel = ((BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
			local ExpDuration = math.ceil(10 * RankLevel + 10)
			local ArmorReduction = math.ceil(41*RankLevel)
			AofBuffBlueprint = {
				Name = 'WhirlingSlash',
				BuffCat = 'ACTIVE',
				BuffFamily = 'WeaponPower',
				Stacks = 'STACK',
				StackRank = 1,
				Duration = ExpDuration,
				Affects = {
					ArmorPerc = {
						ALL = {
							Add = -ArmorReduction,
						},
					},
				},
			}
			AoHBuff.ApplyBuff(target, AofBuffBlueprint)
			DM.SetProperty(idi, 'ExecuteWeaponBuffOnTarget', nil)
		end
	end
end

function StrikeData(unit) -- Mandatory if this function is called. When DM.SetProperty(id, 'ExecuteStrikeAtBone', Name(unit)) is set on Oncast function. It will change a projectile bp and cast a strike on the next weapon fire.
end

UnitsBuff = function(unit, bonus, BuffDuration)
	AofBuffBlueprint = {
		Name = 'WhirlingSlash',
		BuffCat = 'ACTIVE',
		BuffFamily = 'WeaponPower',
		Stacks = 'STACK',
		StackRank = 1,
		Duration = BuffDuration,
		Affects = {
			Damage = {
				ALL = {
					Add = bonus,
				},
			},
		},
	}
	AoHBuff.ApplyBuff(unit, AofBuffBlueprint)
end

function GetDuration(unit) -- Mandatory function
	local bp = unit:GetBlueprint()
	local id = unit:GetEntityId()
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
	local RankLevel = ((BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
	local BuffDuration = math.ceil(10 * RankLevel + 2)
	return BuffDuration
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

