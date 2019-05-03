local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local FX = import(ModPath..'Modules/Effects.lua')
local Buff = import('/lua/sim/buff.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Color = import(ModPath..'Modules/Colors.lua').Colors

function Name(unit) -- Mandatory function
	return 'Ritardando'
end

function IsAvailable(unit) -- Mandatory function
	local id = unit:GetEntityId()
	if CF.IsMilitary(unit) and DM.GetProperty(id,'PrestigeClass', nil) == 'Bard' then return true end
	return false
end

function Description(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local Tp = {} Tp.Line = {} Tp.Width = 280 Tp.OffSetY = -35
	local Int =  DM.GetProperty(id, 'Intelligence')
	local Bardsong = 0
	if DM.GetProperty(id, 'Bardsong', 0) then Bardsong = CF.GetSkillCurrent(id, 'Bardsong') end
	local PowerModifier = CF.GetStanceModifier(unit, 'PowerStrengh_Mod') + (DM.GetProperty(id, 'Buff_PowerDamage_ALL_Add', 0) / 100)
	local Power = 10 * (1 + Int/200) * (1 + Bardsong/100) * PowerModifier * 2
	local Snare = math.ceil(math.min(Power, 60))
	local AttackSpeed = math.ceil(math.min(Power * 0.8, 60))
	local Techlevel = CF.GetUnitTech(unit)
	table.insert(Tp.Line, {'Ritardando'})
	table.insert(Tp.Line, {'Single Target Snare and Attack Speed Debuff', Color.WHITE})
	table.insert(Tp.Line, {'Target : units up to tech '..Techlevel, Color.GREY_LIGHT})
	table.insert(Tp.Line, {'Snare : - '..Snare..' % Mouvement Rate', Color.AEON})
	table.insert(Tp.Line, {'Duration : 20 s', Color.AQUA})
	table.insert(Tp.Line, {''})
	table.insert(Tp.Line, {'Attack Speed Debuff : - '..AttackSpeed..' % Rate of Fire', Color.AEON})
	table.insert(Tp.Line, {'Duration : 30 s', Color.AQUA})
	table.insert(Tp.Line, {''})
	table.insert(Tp.Line, {'Loaded on next weapon projectile fire', Color.CYBRAN})
	table.insert(Tp.Line, {'ReCast Time : 3 s', Color.AQUA})
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
	return 25
end

function OnCast(unit, TempEntity, Option) -- Mandatory function. This function is called from ui immediately when the power icon is clicked on
	local bp = unit:GetBlueprint()
	local id = unit:GetEntityId()
	local army = unit:GetArmy()
	local Time = 150
	local Weight =  5
	DM.SetProperty(id, 'ExecuteWeaponBuffOnTarget', Name(unit)) -- If we want to call a weaponbuff power
	CreateLightParticleIntel(unit, -1, army, Weight, 50, 'glow_02', 'ramp_red_01' )
	local time = math.floor(GetGameTimeSeconds())
	DM.SetProperty(id, 'CastTime_'..Name(unit), time)
	-- self buff
	local UnitCatId = unit:GetUnitId()
	if not DM.GetProperty(id, 'EffectTime_'..Name(unit))  then	-- we check to not stack Fx
		DM.SetProperty(id, 'EffectTime_'..Name(unit), 1) -- this is a flag informing that the power is on (may be useful for further add of an active icon on units flagged)
		unit.KillPowerThread = unit:ForkThread(KillPower, GetDuration(unit), Name(unit))
		unit:CreateFx(ModPath..'Graphics/Emitters/AuraRed.bp', 0.5, 5, 1)
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
		if CF.GetUnitTech(instigator) >= CF.GetUnitTech(target) then
			local id = instigator:GetEntityId()
			local Int =  DM.GetProperty(id, 'Intelligence')
			local Bardsong = 0
			if DM.GetProperty(id, 'Bardsong', 0) then Bardsong = CF.GetSkillCurrent(id, 'Bardsong') end
			local PowerModifier = CF.GetStanceModifier(instigator, 'PowerStrengh_Mod') + (DM.GetProperty(id, 'Buff_PowerDamage_ALL_Add', 0) / 100)
			local Power = 10 * (1 + Int/200) * (1 + Bardsong/100) * PowerModifier * 2
			local Snare = math.ceil(math.min(Power, 60))
			local AttackSpeed = math.ceil(math.min(Power * 0.6, 60))
		
			
			AofBuffBlueprint = {
				Name = 'RitardandoAttackSpeedDebuff',
				BuffCat = 'ACTIVE',
				BuffFamily = 'Bardsong',
				Stacks = 'STACK',
				StackRank = 1,
				Duration = 30,
				Affects = {
					RateOfFire = {
						ALL = {
							Add = - AttackSpeed,
						},
					},
				},
			}
			AoHBuff.ApplyBuff(target, AofBuffBlueprint)
			
			BuffBlueprint {
				Name = 'RitardandoSnare',
				DisplayName = 'RitardandoSnare',
				BuffType = 'Bardsong',
				Stacks = 'REPLACE',
				Duration = 20,
				Affects = {
					MoveMult = {
						Add = 0,
						Mult = (1 - (Snare/100)),
					},
				},
			}
			Buff.ApplyBuff(target, 'RitardandoSnare')
			
			if DM.GetProperty(id, 'Bardsong') then -- Automatic XP to Restoration
				local Attenuate = math.min(CF.GetSkillCurrent(id, 'Bardsong')/10, 10)
				local Gain = 10 * math.pow(0.90, Attenuate)
				DM.IncProperty(id, 'Bardsong', Gain)
			end
		end
	end
end

function StrikeData(unit) -- Mandatory if this function is called. When DM.SetProperty(id, 'ExecuteStrikeAtBone', Name(unit)) is set on Oncast function. It will change a projectile bp and cast a strike on the next weapon fire.
end

function GetDuration(unit) -- Mandatory function
	return 30
end

function ReCastTime(unit) -- Mandatory function
	local _id = unit:GetEntityId()
	local time = math.floor(GetGameTimeSeconds())
	local ReCastTime = ''
	if DM.GetProperty(_id, 'CastTime_'..Name()) then
		ReCastTime = math.max(0, 3 - (time - DM.GetProperty(_id, 'CastTime_'..Name())))
	end
	if ReCastTime <= 1 then 
		SimCallback	({Func= 'KillCastTime', Args = {id = _id, PowerName = Name()}})
	end
	return ReCastTime
end

