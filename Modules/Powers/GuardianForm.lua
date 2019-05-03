local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local FX = import(ModPath..'Modules/Effects.lua')
local Buff = import('/lua/sim/buff.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Color = import(ModPath..'Modules/Colors.lua').Colors

function Name(unit) -- Mandatory function
	return 'Guardian Transformation'
end

function IsAvailable(unit) -- Mandatory function
	local id = unit:GetEntityId()
	if CF.IsMilitary(unit) and DM.GetProperty(id,'PrestigeClass', nil) == 'Guardian' then return true end
	return false
end

function Description(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local Int = DM.GetProperty(id, 'Intelligence')
	local Restoration = 0
	if DM.GetProperty(id, 'Restoration', 0) then Restoration = CF.GetSkillCurrent(id, 'Restoration') end
	local PowerModifier = CF.GetStanceModifier(unit, 'PowerStrengh_Mod') + (DM.GetProperty(id, 'Buff_PowerDamage_ALL_Add', 0) / 100)
	local Power = math.pow(bp.Economy.BuildCostMass, 0.5) * (1 + Int/100 + Restoration/400) * PowerModifier
	local RegenerationBonus = math.ceil(Power * 2.2 *  (1 + DM.GetProperty(id, 'Buff_HealthRecovery_ALL_Add', 0) / 100))
	local HealthBonus = math.ceil(bp.Defense.MaxHealth * (1 + DM.GetProperty(id, 'Buff_HealthRecovery_ALL_Add', 0) / 100))
	local TechLevel = CF.GetUnitTech(unit)
	local ImmediateHealthBonus = math.ceil((Power + 10) * (1 + (TechLevel - 1) * 0.5))
	local ImmediateHealthBonusTech2 = math.ceil((Power + 10) * (1 + (TechLevel - 2) * 0.5))
	local ImmediateHealthBonusTech3 = math.ceil((Power + 10) * (1 + (TechLevel - 3) * 0.5)) 
	local ArmorBonus = math.ceil((Power * 0.75 + 5) * (1 + (TechLevel - 1) * 0.5))
	local ArmorBonus2 = math.ceil((Power * 0.75 + 5) * (1 + (TechLevel - 2) * 0.5))
	local ArmorBonus3 = math.ceil((Power * 0.75 + 5) * (1 + (TechLevel - 3) * 0.5))
	local Specialization = ''
	local SpecializationBonus = math.ceil(100 / TechLevel)
	
	local Tp = {} Tp.Line = {} Tp.Width = 370 Tp.OffSetY = -35
	table.insert(Tp.Line, {'Guardian Form'})
	table.insert(Tp.Line, {'Personal Guardian form transformation', Color.WHITE})
	table.insert(Tp.Line, {'Personal Regeneration bonus : '..'+ '..RegenerationBonus, Color.AEON})
	table.insert(Tp.Line, {'Personal Immediate Repair : '..'+ '..HealthBonus, Color.AEON})
	table.insert(Tp.Line, {''})
	table.insert(Tp.Line, {'Add Health and Armor to  Defenses (self & allies) (AOE : 30) : ' , Color.WHITE})
	
	local CatToSpe = {COMMAND = 'Direct Fire', EXPERIMENTAL = 'Direct Fire Experimental', SUBCOMMAND = 'Direct Fire', BOMBER = 'Bomb', ARTILLERY = 'Artillery', NAVAL = 'Direct Fire Naval', BOT = 'Direct Fire', TANK = 'Direct Fire', STRUCTURE = 'Missile'}
	for Category, Spe in CatToSpe do
		if table.find(bp.Categories, Category) then
			Specialization = Spe
		end
	end

	if TechLevel >= 1 then
		table.insert(Tp.Line, {'..Tech 1 Defenses : ', Color.GREY_LIGHT})
		table.insert(Tp.Line, {'......Immediate Repair : '..ImmediateHealthBonus..' %', Color.AEON})
		table.insert(Tp.Line, {'......Armor Bonus : + '..ArmorBonus, Color.AEON})
	end
	if TechLevel >= 2 then
		table.insert(Tp.Line, {'..Tech 2 Defenses : ', Color.GREY_LIGHT})
		table.insert(Tp.Line, {'......Immediate Repair : '..ImmediateHealthBonusTech2..' %', Color.AEON})
		table.insert(Tp.Line, {'......Armor Bonus : + '..ArmorBonus2, Color.AEON})
	end
	if TechLevel >= 3 then
		table.insert(Tp.Line, {'..Tech 3 Defenses : ', Color.GREY_LIGHT})
		table.insert(Tp.Line, {'......Immediate Repair : '..ImmediateHealthBonusTech3..' %', Color.AEON})
		table.insert(Tp.Line, {'......Armor Bonus : + '..ArmorBonus3, Color.AEON})
	end
	ArmorBonus =  math.ceil((Power * 0.60 + 4) * (1 + (TechLevel - 1) * 0.5))
	ArmorBonus2 = math.ceil((Power * 0.60 + 4) * (1 + (TechLevel - 2) * 0.5))
	ArmorBonus3 = math.ceil((Power * 0.60 + 4) * (1 + (TechLevel - 3) * 0.5))
	table.insert(Tp.Line, {''})
	table.insert(Tp.Line, {'Add Armor to civilian structures (self & allies) (AOE : 30) : ' , Color.WHITE})
	if TechLevel >= 1 then
		table.insert(Tp.Line, {'..Tech 1 Civilian Structures : ', Color.GREY_LIGHT})
		table.insert(Tp.Line, {'......Armor Bonus : + '..ArmorBonus, Color.AEON})
	end
	if TechLevel >= 2 then
		table.insert(Tp.Line, {'..Tech 2 Civilian Structures : ', Color.GREY_LIGHT})
		table.insert(Tp.Line, {'......Armor Bonus : + '..ArmorBonus2, Color.AEON})
	end
	if TechLevel >= 3 then
		table.insert(Tp.Line, {'..Tech 3 Civilian Structures : ', Color.GREY_LIGHT})
		table.insert(Tp.Line, {'......Armor Bonus : + '..ArmorBonus3, Color.AEON})
	end
	table.insert(Tp.Line, {''})
	if Specialization ~= '' then
		table.insert(Tp.Line, {'Defenses and Civilian structures : ' , Color.WHITE})
		table.insert(Tp.Line, {'Armor Bonus against '..Specialization..' : + '..SpecializationBonus..' %', Color.YELLOW1})
	end
	table.insert(Tp.Line, {''})
	table.insert(Tp.Line, {'Duration : 60 s', Color.AQUA})
	table.insert(Tp.Line, {'ReCast Time : 225 s', Color.AQUA})
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
	if DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 and ReCastTime(unit, callfromsim) == '' and GetPowerCost(unit) < DM.GetProperty(id, 'Capacitor') then
		return true
	else
		return false
	end
end

function GetLevel(unit)
end


function GetPowerCost(unit) -- Mandatory function
	return 100
end

function OnCast(unit, TempEntity, Option) -- Mandatory function. This function is called from ui immediately when the power icon is clicked on
	local bp = unit:GetBlueprint()
	local id = unit:GetEntityId()
	local army = unit:GetArmy()
	local Int = DM.GetProperty(id, 'Intelligence')
	local Restoration = 0
	if DM.GetProperty(id, 'Restoration', 0) then Restoration = CF.GetSkillCurrent(id, 'Restoration') end
	local PowerModifier = CF.GetStanceModifier(unit, 'PowerStrengh_Mod') + (AoHBuff.GetBuffValue(unit, 'PowerDamage', 'ALL') / 100)
	local Power = math.pow(bp.Economy.BuildCostMass, 0.5) * (1 + Int/100 + Restoration/400) * PowerModifier
	CreateLightParticleIntel(unit, -1, army, 4, 50, 'glow_02', 'ramp_green_01' )
	CreateEmitterAtEntity(unit, unit:GetArmy(), ModPath..'Graphics/Emitters/GuardianFormDefenseBuff.bp'):OffsetEmitter(0, 0.5, 0):ScaleEmitter(1)
	local time = math.floor(GetGameTimeSeconds())
	DM.SetProperty(id, 'CastTime_'..Name(unit), time)
	-- self buff
	local RegenerationBonus = math.ceil(Power * 2.2 * (1 + AoHBuff.GetBuffValue(unit, 'HealthRecovery', 'ALL') / 100))
	local HealthBonus = math.ceil(bp.Defense.MaxHealth * (1 + AoHBuff.GetBuffValue(unit, 'HealthRecovery', 'ALL') / 100))
	local sizeeffect = 1.5
	if table.find(bp.Categories, 'COMMAND') or table.find(bp.Categories, 'SUBCOMMAND') then
		sizeeffect = 1
	end
	if not DM.GetProperty(id, 'EffectTime_'..Name(unit))  then	-- we check to not stack Fx
		DM.SetProperty(id, 'EffectTime_'..Name(unit), 1) -- this is a flag informing that the power is on (may be useful for further add of an active icon on units flagged)
		unit.KillPowerThread = unit:ForkThread(KillPower, GetDuration(unit), Name(unit))
		unit:CreateFx(ModPath..'Graphics/Emitters/GuardianFormPersonal1.bp', 0, GetDuration(unit)-6, sizeeffect, 'CreateFxOnBones')
		unit:CreateFx(ModPath..'Graphics/Emitters/GuardianFormPersonal1_Refract.bp', 0, GetDuration(unit)-6, sizeeffect * 2, 'CreateFxOnBones')
		unit:CreateFx(ModPath..'Graphics/Emitters/GuardianFormPersonal1_BlackSmoke.bp', 0, GetDuration(unit)-6, sizeeffect, 'CreateFxOnBones')
		unit.UnitsBuffThread = unit:ForkThread(PersonalBuff, HealthBonus, RegenerationBonus)
	end
	unit:UpdateUnitData(5)
	-- Ally buff
	local units = unit:GetAIBrain():GetUnitsAroundPoint(categories.STRUCTURE, unit:GetPosition(), 30, 'Ally')
	local Lock = false
	local Specialization = ''
	local CatToSpe = {COMMAND = 'Direct Fire', EXPERIMENTAL = 'Direct Fire Experimental', SUBCOMMAND = 'Direct Fire', BOMBER = 'Bomb', ARTILLERY = 'Artillery', NAVAL = 'Direct Fire Naval', BOT = 'Direct Fire', TANK = 'Direct Fire', STRUCTURE = 'Missile'}
	for Category, Spe in CatToSpe do
		if table.find(bp.Categories, Category) then
			Specialization = Spe
		end
	end
	local SpecializationBonus = (1 / CF.GetUnitTech(unit))
	for k, _unit in units do
		local _bp = _unit:GetBlueprint()
		if table.find(_bp.Categories, 'WALL') then 
		elseif table.find(_bp.Categories, 'DEFENSE') then -- We need to exclude walls cause there are defense units.
			if CF.GetUnitTech(unit) >= CF.GetUnitTech(_unit) then -- only bonus on same or lower tech level units.
				local DiffLevels = CF.GetUnitTech(unit) - CF.GetUnitTech(_unit)
				local _id = _unit:GetEntityId()
				local _army = _unit:GetArmy()
				local _ImmediateHealthBonus = math.ceil((Power + 10) * (1 + DiffLevels * 0.5) * (_bp.Defense.MaxHealth / 100)) * (1 + AoHBuff.GetBuffValue(unit, 'HealthRecovery', 'ALL') / 100)
				local _ArmorBonus = math.ceil(Power * 0.75 + 5)* (1 + DiffLevels * 0.5)
				if not DM.GetProperty(_id, 'EffectTime_'..Name(unit))  then	
					DM.SetProperty(_id, 'EffectTime_'..Name(unit), 1)
					if table.find(bp.Categories, 'COMMAND') or table.find(bp.Categories, 'SUBCOMMAND') then
						if Lock == false then
							CreateEmitterAtEntity(unit, unit:GetArmy(), ModPath..'Graphics/Emitters/AOH_MovingGreenAura.bp'):OffsetEmitter(0, 1, 0):ScaleEmitter(1)
						end
						Lock = true
					end
					_unit:CreateFx(ModPath..'Graphics/Emitters/AuraWhite.bp', 0, GetDuration(unit), 1.5)
				
					_unit.UnitsBuffThread = _unit:ForkThread(DefenseBuff, _ImmediateHealthBonus, _ArmorBonus, Specialization, SpecializationBonus, _id)
					_unit.KillPowerThread = _unit:ForkThread(KillPower, GetDuration(unit), Name(unit))
				end
			end
		else
			if CF.GetUnitTech(unit) >= CF.GetUnitTech(_unit) then -- only bonus on same or lower tech level units.
				local DiffLevels = math.min(CF.GetUnitTech(unit) - CF.GetUnitTech(_unit), 2)
				local _id = _unit:GetEntityId()
				local _army = _unit:GetArmy()
				local _ArmorBonus = math.ceil(Power * 0.60 + 4)* (1 + DiffLevels * 0.5)
				if not DM.GetProperty(_id, 'EffectTime_'..Name(unit))  then	
					DM.SetProperty(_id, 'EffectTime_'..Name(unit), 1)
					if table.find(bp.Categories, 'COMMAND') or table.find(bp.Categories, 'SUBCOMMAND') then
						if Lock == false then
							CreateEmitterAtEntity(unit, unit:GetArmy(), ModPath..'Graphics/Emitters/AOH_MovingGreenAura.bp'):OffsetEmitter(0, 1, 0):ScaleEmitter(1)
						end
						Lock = true
					end
					_unit:CreateFx(ModPath..'Graphics/Emitters/AuraWhite.bp', 0, GetDuration(unit), 1.5)
					CreateLightParticleIntel(_unit, -1, _army, 1, 600, 'glow_02', 'ramp_white_01' )
					_unit.UnitsBuffThread = _unit:ForkThread(DefenseBuff, 0, _ArmorBonus, Specialization, SpecializationBonus, _id)
					_unit.KillPowerThread = _unit:ForkThread(KillPower, GetDuration(unit), Name(unit))
				end
			end
		end
	end
	if DM.GetProperty(id, 'Restoration') then -- Automatic XP to Restoration
		local Attenuate = math.min(CF.GetSkillCurrent(id, 'Restoration')/10, 10)
		local Gain = 25 * math.pow(0.90, Attenuate)
		DM.IncProperty(id, 'Restoration', Gain)
	end
	DM.IncProperty(id, 'Capacitor', - GetPowerCost(unit))
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

DefenseBuff = function(unit, HealAmount, ArmorBuffAmount, Specialization, SpecializationBonus)
	local id = unit:GetEntityId()
	local army = unit:GetArmy()
	if Specialization == '' then
		if unit.IsBuilt == true then -- don't heal being built units
			unit:AdjustHealth(unit, HealAmount) 
			CreateLightParticleIntel(unit, -1, army, 5, 50, 'glow_02', 'ramp_green_01' )
			FX.DrawNumbers(unit, HealAmount, 'Green') 
		end 
		AofBuffBlueprint = {
			Name = 'GuardianArmor',
			BuffCat = 'ACTIVE',
			BuffFamily = 'Armorbuff',
			Stacks = 'STACK',
			StackRank = 1,
			Duration = GetDuration(unit),
			Affects = {
				Armor = {
					ALL = {
						Add = ArmorBuffAmount,
					},
				},
			},
		}
		AoHBuff.ApplyBuff(unit, AofBuffBlueprint)
	else
		if unit.IsBuilt == true then -- don't heal being built units
			unit:AdjustHealth(unit, HealAmount) 
			CreateLightParticleIntel(unit, -1, army, 5, 50, 'glow_02', 'ramp_green_01' )
			FX.DrawNumbers(unit, HealAmount, 'Green') 
		end 
		AofBuffBlueprint = {} -- Another way to use AofBuffBlueprint
		AofBuffBlueprint.Name = 'GuardianArmor'
		AofBuffBlueprint.BuffCat = 'ACTIVE'
		AofBuffBlueprint.BuffFamily = 'Armorbuff'
		AofBuffBlueprint.Stacks = 'STACK'
		AofBuffBlueprint.StackRank = 1
		AofBuffBlueprint.Duration = GetDuration(unit)
		AofBuffBlueprint.Affects = {}
		AofBuffBlueprint.Affects.Armor = {}
		AofBuffBlueprint.Affects.Armor.ALL = {}
		AofBuffBlueprint.Affects.Armor.ALL.Add = ArmorBuffAmount
		AofBuffBlueprint.Affects.Armor[Specialization] = {}
		AofBuffBlueprint.Affects.Armor[Specialization].Add = (ArmorBuffAmount * SpecializationBonus)
		AoHBuff.ApplyBuff(unit, AofBuffBlueprint)
	end
end

PersonalBuff = function(unit, HealAmount, RegenBonus)
	FX.DrawNumbers(unit, HealAmount, 'Green')
	unit:AdjustHealth(unit, HealAmount) 
	local id = unit:GetEntityId()
	BuffBlueprint {
			Name = 'GuardianRegen',
			DisplayName = 'GuardianRegen',
			BuffType = 'Power',
			Stacks = 'STACK',
			Duration = 60,
			Affects = {
				Regen = {
					Add = RegenBonus,
					Mult = 1,
				},
			},
	}
	Buff.ApplyBuff(unit, 'GuardianRegen')
end


function GetDuration(unit) -- Mandatory function
	return 60
end

function ReCastTime(unit, callfromsim) -- Mandatory function
	local _id = unit:GetEntityId()
	local time = math.floor(GetGameTimeSeconds())
	local ReCastTime = ''
	if DM.GetProperty(_id, 'CastTime_'..Name()) then
		ReCastTime = math.max(0, 225 - (time - DM.GetProperty(_id, 'CastTime_'..Name())))
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

