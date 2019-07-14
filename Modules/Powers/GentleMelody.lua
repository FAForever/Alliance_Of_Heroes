local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local FX = import(ModPath..'Modules/Effects.lua')
local Buff = import('/lua/sim/buff.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Color = import(ModPath..'Modules/Colors.lua').Colors

function Name(unit) -- Mandatory function
	return 'GentleMelody'
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
	local PowerModifier = CF.GetStanceModifier(unit, 'PowerStrengh_Mod') + (DM.GetProperty(id, 'Buff_PowerDamage_ALL_Add', 0) / 100)
	local Power = math.pow(bp.Economy.BuildCostMass, 0.5) * (2 + Int/50 + Bardsong/50) * PowerModifier
	local TechLevel = CF.GetUnitTech(unit)
	local HealthRecoveryBonus = math.min(math.ceil((Power + 5) * (0.5 + (TechLevel - 1) * 0.25)), 150)
	local HealthRempBonus = math.ceil((Power + 5) * (1 + (TechLevel - 1) * 0.5) * 0.8)
	local HealthRecoveryBonus2 = math.min(math.ceil((Power + 5) * (0.5 + (TechLevel - 2) * 0.25)), 150)
	local HealthRecoveryBonus3 = math.min(math.ceil((Power + 5) * (0.5 + (TechLevel - 3) * 0.25)), 150)
	
	local Specialization = ''
	local SpecializationBonus = 50
	local Tp = {} Tp.Line = {} Tp.Width = 275 Tp.OffSetY = -70
	table.insert(Tp.Line, {'Gentle Melody'})
	table.insert(Tp.Line, {'AOE (20) Health Recovery Buff Melody Chant' , Color.WHITE})
	table.insert(Tp.Line, {'..Personal :', Color.GREY_LIGHT})
	table.insert(Tp.Line, {'...... Health Replenishment : '..HealthRempBonus..' HP / 5 s', Color.AEON})
	table.insert(Tp.Line, {'...... Health Recovery Rate +'..HealthRecoveryBonus..' %', Color.AEON})
	if TechLevel >= 1 then
		table.insert(Tp.Line, {'..Tech 1 Mobile Units :', Color.GREY_LIGHT})
		table.insert(Tp.Line, {'......Health Recovery Rate +'..HealthRecoveryBonus..' %', Color.AEON})
	end
	if TechLevel >= 2 then
		table.insert(Tp.Line, {'..Tech 2 Mobile Units :', Color.GREY_LIGHT})
		table.insert(Tp.Line, {'......Health Recovery Rate +'..HealthRecoveryBonus2..' %', Color.AEON})
	end
	if TechLevel >= 3 then
		table.insert(Tp.Line, {'..Tech 3 Mobile Units :', Color.GREY_LIGHT})
		table.insert(Tp.Line, {'......Health Recovery Rate +'..HealthRecoveryBonus3..' %', Color.AEON})
		
	end
	local UnitTypes = CF.GetUnitTypes(unit)
	local TechU = TechLevel
	table.insert(Tp.Line, {'..Mobile Units up to Tech '..TechU, Color.GREY_LIGHT})
	table.insert(Tp.Line, {'......Health Replenishment : '..HealthRempBonus..' HP / 5 s', Color.AEON})
	local ConvertCategory = {EXPERIMENTAL = 'Experimental', COMMAND = 'ACU', SUBCOMMANDER = 'Sub-Commanders', HIGHALTAIR = 'Interceptors', DEFENSE = 'Defense Turrets', STRUCTURE = 'Buildings', AIR = 'Ground Aricrafts', NAVAL = 'Naval units', BOT = 'Bots', TANK = 'Tanks'}
	for _, Category in UnitTypes do
		table.insert(Tp.Line, {'..Unit Specialization :', Color.GREY_LIGHT})
		table.insert(Tp.Line, {'......Health Replenishment for '..ConvertCategory[Category]..' +'..SpecializationBonus..' %', Color.YELLOW1})
	end
	table.insert(Tp.Line, {''})
	if DM.GetProperty(id, 'CurrentBardsong') == 'GentleMelody' then
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
	if DM.GetProperty(id, 'CurrentBardsong') ~= 'GentleMelody' then
		-- LOG('Try to active'..Name(unit))
		DM.SetProperty(id, 'CurrentBardsong', 'GentleMelody')
		-- Inactivating all Bard songs
		DM.SetProperty(id, 'EffectTime_'..'BattleSong', nil)
		DM.SetProperty(id, 'EffectTime_'..'BalladoftheWind', nil)
		DM.SetProperty(id, 'EffectTime_'..'CalmingMelody', nil)
		DM.SetProperty(id, 'EffectTime_'..'PowerGeneratorBlessing', nil)
		DM.SetProperty(id, 'EffectTime_'..'ExtractorBlessing', nil)
		local army = unit:GetArmy()
		local Int = DM.GetProperty(id, 'Intelligence')
		local Bardsong = 0
		if DM.GetProperty(id, 'Bardsong', 0) then Bardsong = CF.GetSkillCurrent(id, 'Bardsong') end
		local PowerModifier = CF.GetStanceModifier(unit, 'PowerStrengh_Mod') + (AoHBuff.GetBuffValue(unit, 'PowerDamage', 'ALL') / 100)
		local Power = math.pow(bp.Economy.BuildCostMass, 0.5) * (2 + Int/50 + Bardsong/50) * PowerModifier
		local TechLevel = CF.GetUnitTech(unit)
		local HealthRecoveryBonus = math.min(math.ceil((Power + 5) * (0.5 + (TechLevel - 1) * 0.25)), 150)
		local HealthRempBonus = math.ceil((Power + 5) * (1 + (TechLevel - 1) * 0.5) * 0.8)
		local Specialization = CF.GetUnitTypes(unit)
		local SpecializationBonus = HealthRempBonus * 1.5
		local time = math.floor(GetGameTimeSeconds())
		DM.SetProperty(id, 'CastTime_'..Name(unit), time)
		-- self buff
		-- LOG(DM.GetProperty(id, 'EffectTime_'..Name(unit)))
		if not DM.GetProperty(id, 'EffectTime_'..Name(unit))  then	-- we check to not stack Fx
			DM.SetProperty(id, 'EffectTime_'..Name(unit), 1) -- this is a flag informing that the power is on (may be useful for further add of an active icon on units flagged)
			unit[Name()..'PersonalBuffThread'] = unit:ForkThread(PersonalBuff, HealthRempBonus, HealthRecoveryBonus)
			unit[Name()..'BardSongBuffThread'] = unit:ForkThread(BardSongBuff, HealthRempBonus, Specialization)
		else
			DM.SetProperty(id, 'CurrentBardsong', 'None')
		end
		DM.IncProperty(id, 'Capacitor', - GetPowerCost(unit))
	else
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

BardSongBuff = function(unit, HealthRempBonus, Specialization)
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local army = unit:GetArmy()
	local TechLevel = CF.GetUnitTech(unit)
	repeat
		-- LOG('BardSongBuff Active from gentle melody')
		local Int = DM.GetProperty(id, 'Intelligence')
		local Bardsong = 0
		if DM.GetProperty(id, 'Bardsong', 0) then Bardsong = CF.GetSkillCurrent(id, 'Bardsong') end
		local PowerModifier = CF.GetStanceModifier(unit, 'PowerStrengh_Mod') + (AoHBuff.GetBuffValue(unit, 'PowerDamage', 'ALL') / 100)
		local Power = math.pow(bp.Economy.BuildCostMass, 0.5) * (2 + Int/100 + Bardsong/50) * PowerModifier
		local time = math.floor(GetGameTimeSeconds())
		local units = unit:GetAIBrain():GetUnitsAroundPoint(categories.MOBILE + categories.DEFENSE, unit:GetPosition(), 20, 'Ally')
		for k, _unit in units do
			local _bp = _unit:GetBlueprint()
			if CF.GetUnitTech(unit) >= CF.GetUnitTech(_unit) then -- only bonus on same or lower tech level units.
				local DiffLevels = CF.GetUnitTech(unit) - CF.GetUnitTech(_unit)
				local _id = _unit:GetEntityId()
				local _army = _unit:GetArmy()
				local _HealthRecoveryBonus = math.min(math.ceil((Power + 5) * (0.5 + DiffLevels * 0.25)), 150)
				local SpecializationBonus = HealthRempBonus
				if not DM.GetProperty(_id, 'EffectTime_'..Name(unit)) and _unit.IsBuilt == true then	
					for _,category in Specialization do
						if table.find(_bp.Categories, category) then
							SpecializationBonus = math.ceil(HealthRempBonus * 1.5)
						end
					end
					DM.SetProperty(_id, 'EffectTime_'..Name(unit), 1)
					CreateLightParticleIntel(_unit, -1, _army, 3, 5, 'glow_02', 'ramp_green_01' )
					local unithealth = _unit:GetHealth()
					local unitmaxhealth = _unit:GetMaxHealth()
					if _unit.IsBuilt == true and unithealth < unitmaxhealth then
						local army = _unit:GetArmy()
						CreateLightParticleIntel(_unit, -1, army, 5, 50, 'glow_02', 'ramp_green_01')
						HealAmount = math.min(unitmaxhealth - unithealth, SpecializationBonus)
						FX.DrawNumbers(_unit, HealAmount, 'Green') 
						unit.HpHealed = unit.HpHealed + HealAmount
						_unit:AdjustHealth(_unit, HealAmount)
					end 
					_unit.HealthRecoveryBuffThread = _unit:ForkThread(HealthRecoveryBuff, _HealthRecoveryBonus)
					_unit[Name()..'KillPowerThread'] = _unit:ForkThread(KillPower, 4.9, Name(unit))
				end
			end
		end
		WaitSeconds(5)
	until(unit.Dead == true or DM.GetProperty(id, 'CurrentBardsong') ~= 'GentleMelody')
end

HealthRecoveryBuff = function(unit, HealthRecoveryBonus)
	local bp = unit:GetBlueprint()
	BuffBlueprint {
		Name = 'GentleMelody',
		DisplayName = 'GentleMelody',
		BuffType = 'Bardsong',
		Stacks = 'REPLACE',
		Duration = 5,
		Affects = {
			Regen = {
				Add = (CF.GetUnitRegen(unit)) * (HealthRecoveryBonus / 100),
				Mult = 1,
			},
		},
	}
	Buff.ApplyBuff(unit, 'GentleMelody')
	
	HealthRecovery = {
		Name = 'HealthRecoveryBuff',
		BuffCat = 'ACTIVE',
		BuffFamily = 'BardSong',
		Stacks = 'STACK',
		StackRank = 1,
		Duration = 5,
		Affects = {
			HealthRecovery = {
				ALL = {
					Add = HealthRecoveryBonus,
				},
			},
		},
	}
	AoHBuff.ApplyBuff(unit, HealthRecovery)
end

PersonalBuff = function(unit, HealthRempBonus, HealthRecoveryBonus)
	local id = unit:GetEntityId()
	repeat
		local bp = unit:GetBlueprint()
		unit:CreateFx(ModPath..'Graphics/Emitters/GentleMelody.bp', 0, 1, 1, 'CreateFxOnBones')
		unit:AdjustHealth(unit, HealthRempBonus) 
		BuffBlueprint {
			Name = 'GentleMelody',
			DisplayName = 'GentleMelody',
			BuffType = 'Bardsong',
			Stacks = 'REPLACE',
			Duration = 5,
			Affects = {
				Regen = {
					Add = (CF.GetUnitRegen(unit)) * (HealthRecoveryBonus / 100),
					Mult = 1,
				},
			},
		}
		Buff.ApplyBuff(unit, 'GentleMelody')
		WaitSeconds(5)
	until(unit.Dead == true or DM.GetProperty(id, 'CurrentBardsong') ~= 'GentleMelody')
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

