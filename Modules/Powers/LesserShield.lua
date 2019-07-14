local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local FX = import(ModPath..'Modules/Effects.lua')
local Buff = import('/lua/sim/buff.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Color = import(ModPath..'Modules/Colors.lua').Colors
local BCMod = {Fighter = 1, Rogue = 0.5, Support = 0.5, Ardent = 0.25}
local PCMod = {Elite = 0, Guardian = 1, Dreadnought = 0.75, Bard = 0.25, Restorer = 1,  Ranger = 0.5}


function Name(unit) -- Mandatory function
	return 'LesserShield'
end

function IsAvailable(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	if DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 then 
		local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
		local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
		if BaseClass != 'Ardent' then 
			return true
		end
	end
	return false
end

function Description(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local Prefix = ' Hero'
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
	local RankLevel = ((BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
	local Tp = {} Tp.Line = {} Tp.Width = 200 Tp.OffSetY = -70
	local Power = GetShieldPower(unit)
	local RegenRateTech = DM.GetProperty(id, 'Tech_Shield_RegenRate_Bonus', 0)
	local RegenRate = math.max(math.ceil(Power / 250 * RankLevel), 20) + RegenRateTech
	local RegenStarttime = math.max(math.ceil(1 / RankLevel), 1)
	local Rechargetime =  math.max(math.ceil(10 / RankLevel), 10)
	table.insert(Tp.Line, {PrestigeClass..Prefix..' Shield'})
	table.insert(Tp.Line, {'Rank : '..CF.GetRankName(RankLevel), Color.GREY_LIGHT})
	table.insert(Tp.Line, {'Cast Hero Shield', Color.WHITE})
	table.insert(Tp.Line, {''})
	table.insert(Tp.Line, {'Shield Power : +'..Power, Color.AEON})
	table.insert(Tp.Line, {'Regen Rate : +'..RegenRate..' /s', Color.AEON})
	table.insert(Tp.Line, {'Regen Start Time : '..RegenStarttime..' s', Color.AEON})
	table.insert(Tp.Line, {''})
	table.insert(Tp.Line, {'Duration : -', Color.AQUA})
	table.insert(Tp.Line, {'ReCast Time : 240 s', Color.AQUA})
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

function GetShieldPower(unit, refresh)
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local ExperimentalMod = 1
	if table.find(bp.Categories, 'EXPERIMENTAL') then
		ExperimentalMod = 0.5
		if table.find(bp.Categories, 'AIR') or table.find(bp.Categories, 'HIGHALTAIR') then
			ExperimentalMod = 0.25
		end
	end
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
	local RankLevel = ((BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
	local Int = DM.GetProperty(id, 'Intelligence')
	local Tech_Shield_MaxHealth_Bonus =  DM.GetProperty(id, 'Tech_Shield_MaxHealth_Bonus', 0) + 1
	local PowerModifier = CF.GetStanceModifier(unit, 'PowerStrengh_Mod') + (DM.GetProperty(id, 'Buff_PowerDamage_ALL_Add', 0) / 100)
	local Power = math.floor(math.pow(bp.Economy.BuildCostMass, 0.7) * (1 + Int/50) * PowerModifier * RankLevel * ExperimentalMod * Tech_Shield_MaxHealth_Bonus * 100)
	if refresh == true then
		DM.SetProperty(id, 'Power_Shield_MaxHealth', Power)
		local RegenRate = math.max(math.ceil(Power / 250 * RankLevel), 20)
		local RegenRateTech = DM.GetProperty(id, 'Tech_Shield_RegenRate_Bonus', 0)
		DM.SetProperty(id, 'Power_Shield_RegenRate', RegenRate + RegenRateTech)
	end
	return Power
end






function GetPowerCost(unit) -- Mandatory function
	local id = unit:GetEntityId()
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
	local RankLevel = ((BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
	return math.ceil(100 * RankLevel)
end

function OnCast(unit, TempEntity, Option) -- Mandatory function. This function is called from ui immediately when the power icon is clicked on
	local soundfx = Sound({Bank = 'UEADestroy', Cue = 'UEA_Destroy_Air_Killed'})
	unit:PlaySound(soundfx)
	local id = unit:GetEntityId()
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
	local RankLevel = ((BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
	local Power = GetShieldPower(unit, true)
	local RegenRate = math.max(math.ceil(Power / 250 * RankLevel), 20)
	local RegenStarttime = math.max(math.ceil(1 / RankLevel), 1)
	local Rechargetime =  math.max(math.ceil(30 / RankLevel), 30)
	local x, y, z = unit:GetUnitSizes()
	local vol = math.max(x, y)
	vol = math.max(vol, z)
	local PersonalBubble = {
		Type = 'Power',
		ImpactEffects = 'UEFShieldHit01',
		ImpactMesh = '/effects/entities/ShieldSection01/ShieldSection01_mesh',
		Mesh = '/effects/entities/Shield01/Shield01_mesh',
		MeshZ = '/effects/entities/Shield01/Shield01z_mesh',
		RegenAssistMult = 60,
		ShieldEnergyDrainRechargeTime = 60,
		ShieldMaxHealth = 0,
		ShieldRechargeTime = Rechargetime,
		ShieldRegenRate = 0,
		ShieldRegenStartTime = RegenStarttime,
		ShieldSize = math.max(2, vol * 2.4),
		ShieldSpillOverDamageMod = 0,
		ShieldVerticalOffset = 0,
	}
	unit:CreateShield(PersonalBubble)
	CreateLightParticleIntel(unit, -1, unit:GetArmy(), 3, 100, 'glow_02', 'ramp_blue_01' )
	local time = math.floor(GetGameTimeSeconds())
	DM.SetProperty(id, 'CastTime_'..Name(unit), time)
	DM.IncProperty(id, 'Capacitor', - GetPowerCost(unit))
end

KillPower = function(unit, duration, PowerName) -- Mandatory function
	WaitSeconds(duration)
	local id = unit:GetEntityId()
	DM.SetProperty(id, 'EffectTime_'..PowerName, nil)
end

function OnWeaponHit(target, instigator) -- Mandatory if this function is called when the unit hit the target (active if DM.SetProperty(id, 'ExecuteWeaponBuffOnTarget', Name(unit)) has been set in OnCast function)
end

function StrikeData(unit) -- Mandatory if this function is called. When DM.SetProperty(id, 'ExecuteStrikeAtBone', Name(unit)) is set on Oncast function. It will change a projectile bp 
end

UnitsBuff = function(unit, bonus)
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
	return 5
end

function ReCastTime(unit) -- Mandatory function
	local _id = unit:GetEntityId()
	local time = math.floor(GetGameTimeSeconds())
	local ReCastTime = ''
	if DM.GetProperty(_id, 'CastTime_'..Name()) then
		ReCastTime = math.max(0, 240 - (time - DM.GetProperty(_id, 'CastTime_'..Name())))
	end
	if ReCastTime <= 1 then 
		SimCallback	({Func= 'KillCastTime', Args = {id = _id, PowerName = Name()}})
	end
	return ReCastTime
end

