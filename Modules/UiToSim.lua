local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local ArmorModifiers =  import(ModPath..'Modules/ArmorModifiers.lua')
local WeaponModifiers =  import(ModPath..'Modules/WeaponModifiers.lua')
local LandTech = import(ModPath..'Modules/LandTechSim.lua').Modifiers
local ThreadId = 0

function EngineerConsolidation(Unit)
	local unit = GetUnitById(Unit.id)
	unit:ExecuteConsolidation()
end

function SetBuildingSpeed(Unit)
	DM.SetProperty(Unit.id,'SetBuildingSpeed', Unit.BuildingRate)
	DM.SetProperty(Unit.id,'UpdateUnit',1)
end

function EcoEvent(Unit)
	local unit = GetUnitById(Unit.id)
	ThreadId = ThreadId + 1
	unit['EcoEvent'..ThreadId] = unit:ForkThread(unit.CreateEcoEvent, Unit.EnergyCost, Unit.MassCost, Unit.TimeStress, Unit.EventName, Unit.SetArmor, Unit.WeaponIndex, Unit.SetWeapon, Unit.TemplateName, Unit.Modifiers)
end

function SimulatePower(Unit)
	-- if not DM.GetProperty(nil,'SimulatePower') then
		-- DM.SetProperty(nil,'SimulatePower', 1)
		DM.SetMouseCoordonnates(Unit.x, Unit.y, Unit.z)
	-- end
end

function LeavePowerHitMode(Unit)
	-- DM.SetProperty(Unit.id,'LeavePowerHitMode', Unit.Value)
end

function OnGivingXP(Unit)
	local unit = GetUnitById(Unit.id)
	local bp = unit:GetBlueprint()
	local Power = math.floor(math.pow(bp.Economy.BuildCostMass, 0.5))
	DM.IncProperty('Global'..unit:GetArmy(), Unit.type, - Unit.xp * Power)
	unit:UpdateUnitData(Unit.xp, false)
end

function OnTraining(Unit)
	local id = Unit.Id
	DM.SetProperty(id, Unit.ability..'_TrainingWeight', Unit.weight)
end

function ClearDialog(Dialog)
	DM.SetProperty(nil, Dialog.DialogType, 0)
end

function CallPower(Unit)
	local power = CF.GetUnitPower(Unit.id, Unit.PowerName)
	local lunit = GetUnitById(Unit.id)
	if DM.GetProperty(Unit.id, 'Capacitor') > power.GetPowerCost(lunit) then
		lunit.ExecutePower(lunit, Unit.PowerName, Unit.Choice)
	end
end

function SetAutoCast(Unit)
	DM.SetProperty(Unit.id, Unit.PowerName..'_AutoCast', Unit.Value)
end

function KillCastTime(unit)
	DM.SetProperty(unit.id, 'CastTime_'..unit.PowerName, nil)
	DM.SetProperty(unit.id, 'RefreshPowers', 1)
end

function SpendRessources(Unit)
	local unit = GetUnitById(Unit.id)
	unit:GetAIBrain():TakeResource('Mass', Unit.Mass)
	unit:GetAIBrain():TakeResource('Energy', Unit.Energy)
end

function OnChangeStance(Unit)
	DM.SetProperty(Unit.id,'StanceState',Unit.Stance)
	DM.SetProperty(Unit.id,'UpdateUnit', 0)
end

function OnChangeProduction(Unit)
	-- LOG('On Change Production')
	-- DM.SetProperty(nil,'UpgradeHull', 0)
	local id = Unit.id
	local lunit = GetUnitById(id)
	local army = lunit:GetArmy()
	local bp = lunit:GetBlueprint()
	CreateLightParticleIntel( lunit, -1, army, 5, 5, 'glow_01', 'ramp_blue_07' )
	Converter = -- Stances conversion form training box number
	{'Fighter','Support','Rogue','Ardent'}
	Production = Converter[Unit.ability-102] 
	DM.SetProperty(id,'Active_Production', Production)
end

function OnChoosePromotion(Unit)
	local PromoteList = CF.GetAvailablePromoteList(Unit.id)	
	local unit = GetUnitById(Unit.id)
	local army = unit:GetArmy()
	CreateLightParticleIntel( unit, -1, army, 5, 5, 'glow_01', 'ramp_blue_07' )
	local bp = unit:GetBlueprint()
	local UnitLevel, UnitLevelP =  CF.GetUnitLevel(unit)
	if DM.GetProperty(Unit.id,'PrestigeClass') == 'NeedPromote'  then 
		unit.PromoteThread = unit:ForkThread(unit.CreateEcoEvent, Unit.EnergyCost, Unit.MassCost, 1, 'Promoting')
		if Unit.Template then
			unit.OrderPromoteThread = unit:ForkThread(unit.OrderPromote,  Unit.EnergyCost, Unit.MassCost, Unit.PrestigeClass, Unit.BaseClass, Unit.Template, Unit.Modifiers)
		else
			unit.OrderPromoteThread = unit:ForkThread(unit.OrderPromote,  Unit.EnergyCost, Unit.MassCost, Unit.PrestigeClass, Unit.BaseClass)
		end
	end
end

function SyncValueFromUi(Unit)
	local unit = GetUnitById(Unit.id)
	local AddValue = 0
	local MultValue = 1
	if unit.AoHBuffs[Unit.AffectName] then
		for Family,_ in unit.AoHBuffs[Unit.AffectName] do
			for Buff,_ in unit.AoHBuffs[Unit.AffectName][Family] do
				for CategoryName,_ in  unit.AoHBuffs[Unit.AffectName][Family][Buff] do
					if unit.AoHBuffs[Unit.AffectName][Family][Buff][CategoryName] and CategoryName == Unit.Specialization then
						if unit.AoHBuffs[Unit.AffectName][Family][Buff][CategoryName].Add then
							AddValue = AddValue + unit.AoHBuffs[Unit.AffectName][Family][Buff][CategoryName].Add
						end
						if unit.AoHBuffs[Unit.AffectName][Family][Buff][CategoryName].Mult then
							MultValue = MultValue + (unit.AoHBuffs[Unit.AffectName][Family][Buff][CategoryName].Mult - 1)
						end
					end
				end
			end
		end
	end
	DM.SetProperty(Unit.id, 'Buff_'..Unit.AffectName..'_'..Unit.Specialization..'_Add', AddValue)
	DM.SetProperty(Unit.id, 'Buff_'..Unit.AffectName..'_'..Unit.Specialization..'_Mult', MultValue)
end

function ApplyTemplate(Unit)
	local unit = GetUnitById(Unit.id)
	-- LOG(repr(Unit.Modifiers))
	unit.ApplyTemplateThread = unit:ForkThread(unit.ApplyTemplate, Unit.MassCost, Unit.EnergyCost, Unit.TemplateName, Unit.Modifiers)
end

function UpdateDataTechs(data)
	if data.Techs then
		local unit = GetUnitById(data.Unitid)
		for tech, level in data.Techs do
			DM.SetProperty('Global'..unit:GetArmy(), 'LandMobileTech'..tech, level)
		end
		if not DM.GetProperty('Global'..unit:GetArmy(), 'LandMobileXPSpentPoints') then 
			DM.SetProperty('Global'..unit:GetArmy(), 'LandMobileXPSpentPoints', data.TechPoints)
		else
			DM.IncProperty('Global'..unit:GetArmy(), 'LandMobileXPSpentPoints', data.TechPoints)
		end
		local HeroesList = CF.GetPlayerHeroesList(GetArmyBrain(data.Player))
		for _,Hero in HeroesList do
			local bp = Hero:GetBlueprint()
			if table.find(bp.Categories, 'LAND') and table.find(bp.Categories, 'MOBILE') then
				if table.find(bp.Categories, 'EXPERIMENTAL') then
				else
					for tech, _ in LandTech do
						if DM.GetProperty('Global'..data.Player, 'LandMobileTech'..tech) then	
							local level = DM.GetProperty('Global'..data.Player, 'LandMobileTech'..tech)
							if LandTech[tech].OnStopBeingBuilt then
								LandTech[tech].OnStopBeingBuilt(unit, level) -- Executing Tech tree node script
							end
							if LandTech[tech].OnCreate then
								LandTech[tech].OnCreate(unit, level) -- Executing Tech tree node script
							end
						end
					end
				end
			end
		end
	end
end