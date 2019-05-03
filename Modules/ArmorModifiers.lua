------------------------------
-- Alliance of Heroes Mod ----
-- Franck83 [2016-2017] ------
------------------------------

-- Here is the code for all armor upgrades data -

local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')

-- Armor Upgrades Modifiers
-- Here are all the modifiers formula called when a unit is upgrading its Armor

Modifiers = {
	HealthIncrease = {
		Name = 'Health Increase',
		IsAvailable = function(id)
			local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
			if PrestigeClass == 'Elite' then return false else return true end
		end,
		Calculate = function(id)
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			local Modifier = 1
			if CF.IsMilitary(unit) == false then
				Modifier = 0.25
			end
			if table.find(bp.Categories, 'BOMBER') then Modifier = 0.1 end
			local Power = math.floor(math.pow(bp.Economy.BuildCostMass, 0.6))
			if BaseClass == 'Fighter' then
				return Power * 50 * Modifier
			elseif BaseClass == 'Rogue' then
				return Power * 35 * Modifier
			elseif BaseClass == 'Support' then
				return Power * 30 * Modifier	
			elseif BaseClass == 'Ardent' then
				return Power * 25 * Modifier		
			end	
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.16
			else
				return 0.04
			end
		end,
		Space = 15,
		
	},
	RegenerationIncrease = {
		Name = 'Regeneration Increase',
		IsAvailable = function(id)
			local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
			if PrestigeClass == 'Elite' then return false else return true end
		end,
		Calculate = function(id)
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			local Power = math.floor(math.pow(bp.Economy.BuildCostMass, 0.4))
			if BaseClass == 'Fighter' then
				return math.floor(Power * 0.55)
			elseif BaseClass == 'Rogue' then
				return math.floor(Power * 0.5)
			elseif BaseClass == 'Support' then
				return math.floor(Power * 0.25)	
			elseif BaseClass == 'Ardent' then
				return math.floor(Power * 0.25)
			end			
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.16
			else
				return 0.06
			end
		end,
		Space = 10,
	},
	ArmorLight = {
		Name = 'Light Armor',
		IsAvailable = function(id)
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			if BaseClass == 'Ardent' then
				return false
			else
				local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
				if PrestigeClass == 'Elite' then return false else return true end
			end
		end,
		Calculate = function(id)
			return 5
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.08
			else
				return 0.04
			end
		end,
		Space = 8,
	},
	ArmorMedium = {
		Name = 'Medium Armor',
		IsAvailable = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
			if table.find(bp.Categories, 'AIR') then
				return false
			end
			if PrestigeClass == 'Guardian' or PrestigeClass == 'Restorer' or PrestigeClass == 'Dreadnought' then
				return true
			elseif PrestigeClass == 'Ranger' and BaseClass == 'Fighter' then
				return true
			elseif table.find(bp.Categories, 'STRUCTURE')  then
				return true
			else
				return false
			end
		end,
		Calculate = function(id)
			return 10
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.16
			else
				return 0.04
			end
		end,
		Space = 10,
	},
	ArmorHeavy = {
		Name = 'Heavy Armor',
		IsAvailable = function(id)
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'AIR') then
				return false
			end
			if BaseClass == 'Fighter' and PrestigeClass == 'Guardian' then
				return true
			elseif PrestigeClass == 'Dreadnought' then
				return true
			else
				return false
			end
		end,
		Calculate = function(id)
			return 15
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.32
			else
				return 0.08
			end
		end,
		Space = 12,
	},
	ArmorDirectFire = {
		Name = 'Armor for Direct Fire',
		IsAvailable = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			if BaseClass == 'Ardent' then
				return false
			elseif table.find(bp.Categories, 'HIGHALTAIR') then
				return false	
			else
				local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
				if PrestigeClass == 'Elite' then return false else return true end
			end
		end,
		Calculate = function(id)
			return 50
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.16
			else
				return 0.08
			end
		end,
		Space = 10,
	},
	ArmorDirectFireNaval = {
		Name = 'Armor for Direct Fire Naval',
		IsAvailable = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			if BaseClass == 'Ardent' then
				return false
			elseif table.find(bp.Categories, 'AIR') or table.find(bp.Categories, 'HIGHALTAIR') then
				return false	
			else
				local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
				if PrestigeClass == 'Elite' then return false else return true end
			end
		end,
		Calculate = function(id)
			return 75
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.08
			else
				return 0.04
			end
		end,
		Space = 10,
	},
	ArmorDirectFireExperimental = {
		Name = 'Armor for Direct Fire Experimental',
		IsAvailable = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			if BaseClass == 'Ardent' then
				return false
			elseif table.find(bp.Categories, 'AIR') or table.find(bp.Categories, 'HIGHALTAIR') then
				return false	
			else
				local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
				if PrestigeClass == 'Elite' then return false else return true end
			end
		end,
		Calculate = function(id)
			return 100
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.08
			else
				return 0.04
			end
		end,
		Space = 10,
	},
	ArmorOvercharge = {
		Name = 'Armor for Overcharge',
		IsAvailable = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			if BaseClass == 'Ardent' then
				return false
			elseif table.find(bp.Categories, 'AIR') or table.find(bp.Categories, 'HIGHALTAIR') then
				return false	
			else
				local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
				if PrestigeClass == 'Elite' then return false else return true end
			end
		end,
		Calculate = function(id)
			return 75
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.08
			else
				return 0.04
			end
		end,
		Space = 5,
	},
	ArmorArtillery = {
		Name = 'Armor for Artillery',
		IsAvailable = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			if BaseClass == 'Ardent' then
				return false
			elseif table.find(bp.Categories, 'AIR') or table.find(bp.Categories, 'HIGHALTAIR') then
				return false	
			else
				local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
				if PrestigeClass == 'Elite' then return false else return true end
			end
		end,
		Calculate = function(id)
			return 125
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.08
			else
				return 0.04
			end
		end,
		Space = 7,
	},
	ArmorAntiAir = {
		Name = 'Armor for Anti Air',
		IsAvailable = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			if BaseClass == 'Ardent'  then
				return false
			elseif table.find(bp.Categories, 'AIR') or table.find(bp.Categories, 'HIGHALTAIR') then
				local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
				if PrestigeClass == 'Elite' then return false else return true end
			else
				return false
			end
		end,
		Calculate = function(id)
			return 50
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.08
			else
				return 0.04
			end
		end,
		Space = 7,
	},
	ArmorBomb = {
		Name = 'Armor for Bomb',
		IsAvailable = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			if BaseClass == 'Ardent' then
				return false
			elseif table.find(bp.Categories, 'AIR') or table.find(bp.Categories, 'HIGHALTAIR') then
				return false	
			else
				local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
				if PrestigeClass == 'Elite' then return false else return true end
			end
		end,
		Calculate = function(id)
			return 75
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.08
			else
				return 0.02
			end
		end,
		Space = 5,
	},
	ArmorMissile = {
		Name = 'Armor for Missile',
		IsAvailable = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			if BaseClass == 'Ardent' then
				return false
			elseif table.find(bp.Categories, 'AIR') or table.find(bp.Categories, 'HIGHALTAIR') then
				return false	
			else
				local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
				if PrestigeClass == 'Elite' then return false else return true end
			end
		end,
		Calculate = function(id)
			return 125
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.04
			else
				return 0.01
			end
		end,
		Space = 5,
	},
	ArmorNuclear = {
		Name = 'Armor for Nuclear',
		IsAvailable = function(id)
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			if BaseClass == 'Ardent' then
				return false
			else
				local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
				if PrestigeClass == 'Elite' then return false else return true end
			end
		end,
		Calculate = function(id)
			return 100
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.04
			else
				return 0.01
			end
		end,
		Space = 5,
	},
	PlasmaAbsorb = {
		Name = 'Plasma damages Absorb',
		IsAvailable = function(id)
			return false
		end,
		Calculate = function(id)
			return 100
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.04
			else
				return 0.01
			end
		end,
		Space = 10,
	},
	ShieldAbsorb = {
		Name = 'Shield Absorb',
		IsAvailable = function(id)
			return true
		end,
		Calculate = function(id)
			return 15
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.1
			else
				return 0.1
			end
		end,
		Space = 20,
	},
	ShieldArtilleryAbsorb = {
		Name = 'Shield Absorb Artillery',
		IsAvailable = function(id)
			return true
		end,
		Calculate = function(id)
			return 40
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.1
			else
				return 0.1
			end
		end,
		Space = 10,
	},
	ShieldMissileAbsorb = {
		Name = 'Shield Absorb Missile',
		IsAvailable = function(id)
			return true
		end,
		Calculate = function(id)
			return 80
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.1
			else
				return 0.1
			end
		end,
		Space = 10,
	},
	ShieldDirectFireExperimentalAbsorb = {
		Name = 'Shield Absorb DF Experimental',
		IsAvailable = function(id)
			return true
		end,
		Calculate = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'EXPERIMENTAL') then
				return 15
			else
				return 30
			end
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.1
			else
				return 0.1
			end
		end,
		Space = 10,
	},
	ShieldDirectFireAbsorb = {
		Name = 'Shield Absorb DF',
		IsAvailable = function(id)
			return true
		end,
		Calculate = function(id)
			return 20
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.1
			else
				return 0.1
			end
		end,
		Space = 10,
	},
	ShieldDirectFireNavalAbsorb = {
		Name = 'Shield Absorb DF Naval',
		IsAvailable = function(id)
			return true
		end,
		Calculate = function(id)
			return 35
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.1
			else
				return 0.1
			end
		end,
		Space = 10,
	},
	ShieldBombingAbsorb = {
		Name = 'Shield Absorb Bomb',
		IsAvailable = function(id)
			return true
		end,
		Calculate = function(id)
			return 40
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.1
			else
				return 0.1
			end
		end,
		Space = 10,
	},
	BuildRateIncrease = {
		Name = 'Build Rate Increase',
		IsAvailable = function(id)
			-- local unit = GetUnitById(id)
			-- local bp = unit:GetBlueprint()
			-- if table.find(bp.Categories, 'FACTORY') or table.find(bp.Categories, 'ENGINEER') 
				-- then return true
			-- else
				return false
			-- end
		end,
		Calculate = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'ENGINEER') then
				return 5 * CF.GetUnitTech(unit)
			end
			local BuildRate = 25 * CF.GetUnitTech(unit)
			return BuildRate
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.1
			else
				return 0.1
			end
		end,
		Space = 10,
	},
	MassProductionIncrease = {
		Name = 'Mass Production Increase',
		IsAvailable = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
			if table.find(bp.Categories, 'SUBCOMMANDER') and BaseClass == 'Support' and PrestigeClass == 'Guardian' 
				then return true
			else
				return false
			end
		end,
		Calculate = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			local Power = bp.Economy.BuildCostMass / 1000
			local unit = GetUnitById(id)
			local MassProduction = 1.5 * (1 + DM.GetProperty(id, 'Intelligence') / 100) * Power
			return MassProduction
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.25
			else
				return 0.25
			end
		end,
		Space = 15,
	},
	EnergyProductionIncrease = {
		Name = 'Energy Production Increase',
		IsAvailable = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Dreadnought')
			if table.find(bp.Categories, 'SUBCOMMANDER') and BaseClass == 'Support' and PrestigeClass == 'Guardian' 
				then return true
			else
				return false
			end
		end,
		Calculate = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			local Power = bp.Economy.BuildCostMass / 1000
			local EnergyProduction = 150 * (1 + DM.GetProperty(id, 'Intelligence') / 100) * Power
			return EnergyProduction
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.25
			else
				return 0.25
			end
		end,
		Space = 15,
	},
}

-- Reference for sorting keys and views
RefRank = {
		'HealthIncrease',
		'RegenerationIncrease',
		'ArmorLight',
		'ArmorMedium',
		'ArmorHeavy',
		'ArmorDirectFire',
		'ArmorDirectFireNaval',
		'ArmorDirectFireExperimental',
		'ArmorOvercharge',
		'ArmorArtillery',
		'ArmorAntiAir',
		'ArmorBomb',
		'ArmorMissile',
		'ArmorNuclear',
		'PlasmaAbsorb',
		'ShieldAbsorb',
		'ShieldDirectFireAbsorb',
		'ShieldDirectFireNavalAbsorb',
		'ShieldDirectFireExperimentalAbsorb',
		'ShieldArtilleryAbsorb',
		'ShieldBombingAbsorb',
		'ShieldMissileAbsorb',
		'BuildRateIncrease',
		'MassProductionIncrease',
		'EnergyProductionIncrease',
	}
		
RefView = {
		'Health Increase',
		'Regeneration Increase',
		'Light Armor',
		'Medium Armor',
		'Heavy Armor',
		'Armor for Direct Fire',
		'Armor for Direct Fire Naval',
		'Armor for Direct Fire Experimental',
		'Armor for Overcharge',
		'Armor for Artillery',
		'Armor for Anti Air',
		'Armor for Bomb',
		'Armor for Missile',
		'Armor for Nuclear',
		'Plasma damages Absorb',
		'Shield Absorb',
		'Shield Absorb DF',
		'Shield Absorb DF Naval',
		'Shield Absorb DF Experimental',
		'Shield Absorb Artillery',
		'Shield Absorb Bomb',
		'Shield Absorb Missile',
		'Build Rate Increase',
		'Mass Production Increase',
		'Energy Production Increase',
	}



-- Theses 2 funtions add prefix and suffix for friendly view depending of the modifier type
GetPrefix = function(key)
	PrefixView = {'+ ', '+ ', '', '', '', '+ ','+ ','+ ','+ ', '+ ', '+ ', '+ ', '+ ', '+ ','+ ', '+ ','+ ','+ ','+ ','+ ','+ ','+ ', '+ ', '+ ', '+ '}
	for i, modifier in RefView do
		if modifier == key then
			return PrefixView[i]
		end
	end
	return 'No key found in Weapon Reference view'
end

GetSuffix = function(key)
	SuffixView = {' ', ' hp / s', ' [ Base ]', ' [ Base ]',' [ Base ]',' %',' %',' %',' %',' %', ' %', ' %',' %', ' %', ' %', ' %',' %', ' %', ' %', ' %', ' %', ' %', ' BR', ' /s', ' /s'}
	for i, modifier in RefView do
		if modifier == key then
			return SuffixView[i]
		end
	end
	return 'No key found in Weapon Reference view'
end

-- This function convert RefView key to RefRank key. 
GetInternalKey = function(RefViewKey)
	for i, modifier in RefView do
		if modifier == RefViewKey then
			return RefRank[i]
		end
	end
	return 'No key found in reference key'
end
