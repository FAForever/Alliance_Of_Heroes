local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local FX = import(ModPath..'Modules/Effects.lua')
local Buff = import('/lua/sim/buff.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Color = import(ModPath..'Modules/Colors.lua').Colors

function Name(unit) -- Mandatory function
	return 'BattleSong'
end

function IsAvailable(unit) -- Mandatory function
	local id = unit:GetEntityId()
	if CF.IsMilitary(unit) and DM.GetProperty(id,'PrestigeClass', nil) == 'Bard' then return true end
	return false
end

function Description(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local Int = DM.GetProperty(id, 'Intelligence')
	local Bardsong = 0
	if DM.GetProperty(id, 'Bardsong', 0) then Bardsong = CF.GetSkillCurrent(id, 'Bardsong') end
	local PowerModifier = CF.GetStanceModifier(unit, 'PowerStrengh_Mod')
	local Power = 10 * (1 + Int/50 + Bardsong/25) * PowerModifier
	local TechLevel = CF.GetUnitTech(unit)
	local DamageBonus = math.min(math.ceil(Power), 60)
	local Specialization = ''
	local SpecializationBonus = math.ceil(DamageBonus * 1.5)
	local Tp = {} Tp.Line = {} Tp.Width = 240 Tp.OffSetY = -70
	table.insert(Tp.Line, {'Battle Song'})
	table.insert(Tp.Line, {'AOE (20) Damage & Power Damage Buff Chant' , Color.WHITE})
	table.insert(Tp.Line, {'..Personal :', Color.GREY_LIGHT})
	table.insert(Tp.Line, {'......Damage +'..DamageBonus..' %', Color.AEON})
	table.insert(Tp.Line, {'......Power efficiency + '..DamageBonus..' %', Color.AEON})
	local UnitTypes = CF.GetUnitTypes(unit)
	table.insert(Tp.Line, {'..Mobile Units up to Tech '..TechLevel, Color.GREY_LIGHT})
	table.insert(Tp.Line, {'......Damage + '..DamageBonus..' %', Color.AEON})
	table.insert(Tp.Line, {'......Power efficiency + '..DamageBonus..' %', Color.AEON})
	local ConvertCategory = {EXPERIMENTAL = 'Experimental', COMMAND = 'ACU', SUBCOMMANDER = 'Sub-Commanders', HIGHALTAIR = 'Interceptors', DEFENSE = 'Defense Turrets', STRUCTURE = 'Buildings', AIR = 'Ground Aricrafts', NAVAL = 'Naval units', BOT = 'Bots', TANK = 'Tanks'}
	for _, Category in UnitTypes do
		if Category != 'Defense Turrets' or Category != 'Buildings' then
			table.insert(Tp.Line, {'..Unit Specialization :', Color.GREY_LIGHT})
			table.insert(Tp.Line, {'......Damage for '..ConvertCategory[Category]..' +'..SpecializationBonus..' %', Color.YELLOW1})
			table.insert(Tp.Line, {'......Powers efficiency for '..ConvertCategory[Category]..' +'..SpecializationBonus..' %', Color.YELLOW1})
		end
	end
	table.insert(Tp.Line, {''})
	if DM.GetProperty(id, 'CurrentBardsong') == 'BattleSong' then
		table.insert(Tp.Line, {'Current Chant State : ACTIVE', Color.AEON})
	elseif DM.GetProperty(id, 'CurrentBardsong') == 'None' then
		table.insert(Tp.Line, {'Current Chant State : NO ACTIVE CHANT', Color.CYBRAN})
	else
		table.insert(Tp.Line, {'Current Chant State : Another Chant Active', Color.GREY_LIGHT})
		table.insert(Tp.Line, {'Only one Chant can be casted at the same time', Color.GREY_LIGHT})
	end
	table.insert(Tp.Line, {''})
	table.insert(Tp.Line, {'Duration : infinite', Color.AQUA})
	table.insert(Tp.Line, {'ReCast Time : 5 s', Color.AQUA})
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
	return 1
end

function OnCast(unit, TempEntity, Option) -- Mandatory function. This function is called from ui immediately when the power icon is clicked on
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	if DM.GetProperty(id, 'CurrentBardsong') ~= 'BattleSong' then
		-- LOG('Try to active'..Name(unit))
		DM.SetProperty(id, 'CurrentBardsong', 'BattleSong')
		DM.SetProperty(id, 'EffectTime_'..'GentleMelody', nil)
		DM.SetProperty(id, 'EffectTime_'..'BalladoftheWind', nil)
		DM.SetProperty(id, 'EffectTime_'..'CalmingMelody', nil)
		DM.SetProperty(id, 'EffectTime_'..'PowerGeneratorBlessing', nil)
		DM.SetProperty(id, 'EffectTime_'..'ExtractorBlessing', nil)
		local army = unit:GetArmy()
		local Int = DM.GetProperty(id, 'Intelligence')
		local Bardsong = 0
		if DM.GetProperty(id, 'Bardsong', 0) then Bardsong = CF.GetSkillCurrent(id, 'Bardsong') end
		local PowerModifier = CF.GetStanceModifier(unit, 'PowerStrengh_Mod')
		local Power = 10 * (1 + Int/50 + Bardsong/25) * PowerModifier
		local TechLevel = CF.GetUnitTech(unit)
		local DamageBonus = math.min(math.ceil(Power), 60)
		local Specialization = CF.GetUnitTypes(unit)
		local SpecializationBonus = math.ceil(DamageBonus * 1.5)
		local time = math.floor(GetGameTimeSeconds())
		DM.SetProperty(id, 'CastTime_'..Name(unit), time)
		-- self buff
		-- LOG(DM.GetProperty(id, 'EffectTime_'..Name(unit)))
		if not DM.GetProperty(id, 'EffectTime_'..Name(unit))  then	-- we check to not stack Fx
			DM.SetProperty(id, 'EffectTime_'..Name(unit), 1) -- this is a flag informing that the power is on (may be useful for further add of an active icon on units flagged)
			unit[Name()..'PersonalBuffThread'] = unit:ForkThread(PersonalBuff, SpecializationBonus)
			unit[Name()..'BardSongBuffThread'] = unit:ForkThread(BardSongBuff, Specialization)
		else
			DM.SetProperty(id, 'CurrentBardsong', 'None')
		end
		DM.IncProperty(id, 'Capacitor', - GetPowerCost(unit))
	else
		-- LOG('Inactiving'..Name(unit))
		DM.SetProperty(id, 'CurrentBardsong', 'None')
		local time = math.floor(GetGameTimeSeconds())
		DM.SetProperty(id, 'CastTime_'..Name(unit), time)
		unit[Name()..'KillPowerThread'] = unit:ForkThread(KillPower, 5, Name(unit))
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

BardSongBuff = function(unit, Specialization)
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local army = unit:GetArmy()
	local TechLevel = CF.GetUnitTech(unit)
	repeat
		-- LOG('BardSongBuff Active from Ballad of the wind')
		local Int = DM.GetProperty(id, 'Intelligence')
		local Bardsong = 0
		if DM.GetProperty(id, 'Bardsong', 0) then Bardsong = CF.GetSkillCurrent(id, 'Bardsong') end
		local PowerModifier = CF.GetStanceModifier(unit, 'PowerStrengh_Mod')
		local Power = 10 * (1 + Int/50 + Bardsong/25) * PowerModifier
		local TechLevel = CF.GetUnitTech(unit)
		local DamageBonus = math.min(math.ceil(Power), 60)
		local SpecializationBonus = DamageBonus
		local time = math.floor(GetGameTimeSeconds())
		local units = unit:GetAIBrain():GetUnitsAroundPoint(categories.MOBILE + categories.DEFENSE, unit:GetPosition(), 20, 'Ally')
		for k, _unit in units do
			local _bp = _unit:GetBlueprint()
			if CF.GetUnitTech(unit) >= CF.GetUnitTech(_unit) then -- only bonus on same or lower tech level units.
				local _id = _unit:GetEntityId()
				local _army = _unit:GetArmy()
				if not DM.GetProperty(_id, 'EffectTime_'..Name(unit)) and _unit.IsBuilt == true then	
					for _,category in Specialization do
						if table.find(_bp.Categories, category) then
							SpecializationBonus = math.ceil(DamageBonus * 1.5)
						end
					end
					DM.SetProperty(_id, 'EffectTime_'..Name(unit), 1)
					CreateLightParticleIntel(_unit, -1, _army, 3, 20, 'glow_01', 'Ramp_Red_01')
					_unit[Name()..'DamageBonusBuffThread'] = _unit:ForkThread(DamageBonusBuff, SpecializationBonus)
					_unit[Name()..'KillPowerThread'] = _unit:ForkThread(KillPower, 4.9, Name(unit))
				end
			end
		end
		WaitSeconds(5)
	until(unit.Dead == true or DM.GetProperty(id, 'CurrentBardsong') ~= 'BattleSong')
end

DamageBonusBuff = function(unit, DamageBonus)
	AofBuffBlueprint = {
		Name = 'BardDamageBuff',
		BuffCat = 'ACTIVE',
		BuffFamily = 'BardSong',
		Stacks = 'STACK',
		StackRank = 1,
		Duration = 5,
		Affects = {
			Damage = {
				ALL = {
					Add = DamageBonus,
				},
			},
		},
	}
	AoHBuff.ApplyBuff(unit, AofBuffBlueprint)
	
	PowerDamage = {
		Name = 'BardPowerDamageBuff',
		BuffCat = 'ACTIVE',
		BuffFamily = 'BardSong',
		Stacks = 'STACK',
		StackRank = 1,
		Duration = 5,
		Affects = {
			PowerDamage = {
				ALL = {
					Add = DamageBonus,
				},
			},
		},
	}
	AoHBuff.ApplyBuff(unit, PowerDamage)
end

PersonalBuff = function(unit, DamageBonus)
	local id = unit:GetEntityId()
	repeat
 		local bp = unit:GetBlueprint()
		unit:CreateFx(ModPath..'Graphics/Emitters/BattleSong.bp', 0, 1, 1, 'CreateFxOnBones')
		AofBuffBlueprint = {
			Name = 'BardDamageBuff',
			BuffCat = 'ACTIVE',
			BuffFamily = 'BardSong',
			Stacks = 'STACK',
			StackRank = 1,
			Duration = 5,
			Affects = {
				Damage = {
					ALL = {
						Add = DamageBonus,
					},
				},
			},
		}
		AoHBuff.ApplyBuff(unit, AofBuffBlueprint)
		
		PowerDamage = {
			Name = 'BardPowerDamageBuff',
			BuffCat = 'ACTIVE',
			BuffFamily = 'BardSong',
			Stacks = 'STACK',
			StackRank = 1,
			Duration = 5,
			Affects = {
				PowerDamage = {
					ALL = {
						Add = DamageBonus,
					},
				},
			},
		}
	AoHBuff.ApplyBuff(unit, PowerDamage)
	WaitSeconds(5)
	until(unit.Dead == true or DM.GetProperty(id, 'CurrentBardsong') ~= 'BattleSong')
end


function GetDuration(unit) -- Mandatory function
	return 5
end

function ReCastTime(unit) -- Mandatory function
	local _id = unit:GetEntityId()
	local time = math.floor(GetGameTimeSeconds())
	local ReCastTime = ''
	if DM.GetProperty(_id, 'CastTime_'..Name()) then
		ReCastTime = math.max(0, 5 - (time - DM.GetProperty(_id, 'CastTime_'..Name())))
	end
	if ReCastTime <= 1 then 
		SimCallback	({Func= 'KillCastTime', Args = {id = _id, PowerName = Name()}})
	end
	return ReCastTime
end

