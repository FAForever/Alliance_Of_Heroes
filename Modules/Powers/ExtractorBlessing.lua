local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local FX = import(ModPath..'Modules/Effects.lua')
local Buff = import('/lua/sim/buff.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Color = import(ModPath..'Modules/Colors.lua').Colors

function Name(unit) -- Mandatory function
	return 'ExtractorBlessing'
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
	local Power = math.pow(bp.Economy.BuildCostMass, 0.5) * (0.5 + Int/50 + Bardsong/25) * PowerModifier
	local TechLevel = CF.GetUnitTech(unit)
	local ProductionBonus = math.ceil(math.pow((Power + 5) * (0.5 + (TechLevel - 1)) * 0.8, 0.7) * 3)
	local ProductionBonus2 = math.ceil(math.pow((Power + 5) * (0.5 + (TechLevel - 2)) * 0.8, 0.7) * 3)
	local ProductionBonus3 = math.ceil(math.pow((Power + 5) * (0.5 + (TechLevel - 3)) * 0.8, 0.7) * 3)
	local Tp = {} Tp.Line = {} Tp.Width = 270 Tp.OffSetY = -70
	table.insert(Tp.Line, {'Mass Maximizer'})
	table.insert(Tp.Line, {'AOE (20) Mass Extractors blessing Chant' , Color.WHITE})
	if TechLevel >= 1 then
		table.insert(Tp.Line, {'..Tech 1 mass extractors :', Color.GREY_LIGHT})
		table.insert(Tp.Line, {'......Mass Production Rate +'..ProductionBonus..' %', Color.AEON})
	end
	if TechLevel >= 2 then
		table.insert(Tp.Line, {'..Tech 2 mass extractors :', Color.GREY_LIGHT})
		table.insert(Tp.Line, {'......Mass Production Rate +'..ProductionBonus2..' %', Color.AEON})
	end
	if TechLevel >= 3 then
		table.insert(Tp.Line, {'..Tech 3 mass extractors :', Color.GREY_LIGHT})
		table.insert(Tp.Line, {'......Mass Production Rate +'..ProductionBonus3..' %', Color.AEON})
	end
	table.insert(Tp.Line, {''})
	if DM.GetProperty(id, 'CurrentBardsong') == 'ExtractorBlessing' then
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
	if DM.GetProperty(id, 'CurrentBardsong') ~= 'ExtractorBlessing' then
		-- LOG('Try to active'..Name(unit))
		DM.SetProperty(id, 'CurrentBardsong', 'ExtractorBlessing')
		-- Inactivating all Bard songs
		DM.SetProperty(id, 'EffectTime_'..'BattleSong', nil)
		DM.SetProperty(id, 'EffectTime_'..'BalladoftheWind', nil)
		DM.SetProperty(id, 'EffectTime_'..'CalmingMelody', nil)
		DM.SetProperty(id, 'EffectTime_'..'GentleMelody', nil)
		DM.SetProperty(id, 'EffectTime_'..'PowerGeneratorBlessing', nil)
		local army = unit:GetArmy()
		local Int = DM.GetProperty(id, 'Intelligence')
		local Bardsong = 0
		if DM.GetProperty(id, 'Bardsong', 0) then Bardsong = CF.GetSkillCurrent(id, 'Bardsong') end
		local PowerModifier = CF.GetStanceModifier(unit, 'PowerStrengh_Mod') + (AoHBuff.GetBuffValue(unit, 'PowerDamage', 'ALL') / 100)
		local Power = math.pow(bp.Economy.BuildCostMass, 0.5) * (0.5 + Int/50 + Bardsong/25) * PowerModifier
		local TechLevel = CF.GetUnitTech(unit)
		local ProductionBonus = math.ceil(math.pow((Power + 5) * (0.5 + (TechLevel - 1)) * 0.8, 0.7) * 3)
		local time = math.floor(GetGameTimeSeconds())
		DM.SetProperty(id, 'CastTime_'..Name(unit), time)
		-- self buff
		-- LOG(DM.GetProperty(id, 'EffectTime_'..Name(unit)))
		if not DM.GetProperty(id, 'EffectTime_'..Name(unit))  then	-- we check to not stack Fx
			DM.SetProperty(id, 'EffectTime_'..Name(unit), 1) -- this is a flag informing that the power is on (may be useful for further add of an active icon on units flagged)
			unit[Name()..'BardSongBuffThread'] = unit:ForkThread(BardSongBuff)
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

BardSongBuff = function(unit)
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
		local Power = math.pow(bp.Economy.BuildCostMass, 0.5) * (0.5 + Int/50 + Bardsong/25) * PowerModifier
		local time = math.floor(GetGameTimeSeconds())
		local units = unit:GetAIBrain():GetUnitsAroundPoint(categories.MASSPRODUCTION, unit:GetPosition(), 20, 'Ally')
		for k, _unit in units do
			local _bp = _unit:GetBlueprint()
			if CF.GetUnitTech(unit) >= CF.GetUnitTech(_unit) then -- only bonus on same or lower tech level units.
				local DiffLevels = CF.GetUnitTech(unit) - CF.GetUnitTech(_unit)
				local _id = _unit:GetEntityId()
				local _army = _unit:GetArmy()
				local _ProductionBonus = math.ceil(math.pow((Power + 5) * (0.5 + DiffLevels) * 0.8, 0.7) * 3)
				if not DM.GetProperty(_id, 'EffectTime_'..Name(unit)) and _unit.IsBuilt == true then	
					DM.SetProperty(_id, 'EffectTime_'..Name(unit), 1)
					CreateLightParticleIntel(_unit, -1, _army, 3, 5, 'glow_02', 'ramp_green_01' )
					_unit.ProductionBuffThread = _unit:ForkThread(ProductionBuff, _ProductionBonus)
					_unit[Name()..'KillPowerThread'] = _unit:ForkThread(KillPower, 4.9, Name(unit))
					CreateEmitterAtEntity(_unit, _unit:GetArmy(),ModPath..'Graphics/Emitters/UpArrow_Green.bp')
				end
			end
		end
		WaitSeconds(5)

	until(unit.Dead == true or DM.GetProperty(id, 'CurrentBardsong') ~= 'ExtractorBlessing')
end

ProductionBuff = function(unit, _ProductionBonus)
	local bp = unit:GetBlueprint()
	local id = unit:GetEntityId()
	local MassProduction = DM.GetProperty(id,'Upgrade_Armor_Mass Production Increase', 0)
	if table.find(bp.Categories, 'SUBCOMMANDER') and table.find(bp.Categories, 'SERAPHIM') then
		MassProduction = MassProduction / 2
	end
	if unit:HasEnhancement('ResourceAllocation') then
		BuffBlueprint {
			Name = 'ExtractorBlessing',
			DisplayName = 'ExtractorBlessing',
			BuffType = 'Bardsong',
			Stacks = 'IGNORE',
			Duration = 5,
			Affects = {
				MassProduction = {
					Add = (_ProductionBonus/100) * 10 + MassProduction * (_ProductionBonus/100),
				},
			},
		}
		Buff.ApplyBuff(unit, 'ExtractorBlessing')
	else
		BuffBlueprint {
			Name = 'ExtractorBlessing',
			DisplayName = 'ExtractorBlessing',
			BuffType = 'Bardsong',
			Stacks = 'IGNORE',
			Duration = 5,
			Affects = {
				MassProduction = {
					Add = (_ProductionBonus/100) + MassProduction * (_ProductionBonus/100),
				},
			},
		}
		Buff.ApplyBuff(unit, 'ExtractorBlessing')
	end
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

