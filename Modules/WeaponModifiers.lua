------------------------------
-- Alliance of Heroes Mod ----
-- Franck83 [2016-2017] ------
------------------------------

-- Here is the code for all weapons upgrades data -

local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')


-- Weapons Upgrades Modifiers
-- Here are all the modifiers formula called when a unit is upgrading its weapon

Modifiers = {
	Damage = {
		Name = 'Damage to All Units',
		IsAvailable = function(id, WeaponCategory, WeaponIndex)
			if DM.GetProperty(id,'Military', false) == true then
				return true
			else
				return false
			end
		end,
		Calculate = function(id, WeaponIndex)
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			local WeaponSkill = DM.GetProperty(id,'Weapon Skill', 5)
			local Puissance = DM.GetProperty(id,'Puissance', 25)
			local WeaponMastery =  (DM.GetProperty(id,'Weapon Mastery', 0) or 0)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if bp.Weapon[WeaponIndex].Label == 'MLG' then
				return ((WeaponMastery / 500 + WeaponSkill / 800 + 1) * 10)
			end
			return ((WeaponMastery / 500 + WeaponSkill / 800 + 1) * 20)
			
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.06
			else
				return 0.10
			end
		end,
		Space = 15,
		},
	DamageRadius = {
		Name = 'Damage Area of Effect', 
		IsAvailable = function(id, WeaponCategory, WeaponIndex)
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			if BaseClass == 'Ardent' then
				return true
			else
				return false
			end
		end,
		Calculate = function(id, WeaponIndex)
			return 1
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.10
			else
				return 0.15
			end
		end,
		Space = 20,
		},
	MaxRadius = {
		Name = 	'Range', 
		IsAvailable = function(id, WeaponCategory, WeaponIndex)
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			if BaseClass == 'Support' or BaseClass == 'Ardent' or WeaponCategory == 'Bomb' then
				return false
			else
				return true
			end
		end,
		Calculate = function(id, WeaponIndex)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			local Puissance = DM.GetProperty(id,'Puissance', 25)
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			if bp.Weapon[WeaponIndex].Label == 'MLG' then
				return 2
			end
			if BaseClass == 'Rogue' then 
				return 4
			else
				return 3
			end
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.10
			else
				return 0.10
			end
		end,
		Space = 12,
		},
	RateOfFire = {
		Name = 	'Rate Of Fire', 
		IsAvailable = function(id, WeaponCategory, WeaponIndex)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			local ExcludeList = {'Missile', 'Artillery', 'Bomb', 'Kamikaze', 'Anti Air', 'Anti Navy'}
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			if bp.Weapon[WeaponIndex].Label == 'MLG' then
				return false
			end
			if table.find(ExcludeList, WeaponCategory) or BaseClass == 'Support' or bp.Weapon[WeaponIndex].DamageType == 'Overcharge' then
				return false
			else
				return true
			end
		end,
		Calculate = function(id, WeaponIndex)
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			local WeaponSkill = DM.GetProperty(id,'Weapon Skill', 5)
			local Puissance = DM.GetProperty(id,'Puissance', 25)
			local WeaponMastery =  (DM.GetProperty(id,'Weapon Mastery', 0) or 0)
			return ((WeaponMastery / 500 + WeaponSkill / 800 + 1) * 15)
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.07
			else
				return 0.10
			end
		end,
		Space = 15,
		},
	AttackRating = {
		Name = 	'Attack Rating', 
		IsAvailable = function(id, WeaponCategory, WeaponIndex)
			return true
		end,
		Calculate = function(id, WeaponIndex)
			return 50
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.02
			else
				return 0.04
			end
		end,
		Space = 5,
		},
	ArmorPiercing = {
		Name = 	'Armor Piercing', 
		IsAvailable = function(id, WeaponCategory, WeaponIndex)
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			if BaseClass == 'Support' then 
				return false
			else
				return true
			end
		end,
		Calculate = function(id, WeaponIndex)
			local Puissance = DM.GetProperty(id,'Puissance', 25)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			local FactionBalance = 1
			if table.find(bp.Categories, 'HIGHALTAIR') and table.find(bp.Categories, 'TECH1') then
				if table.find(bp.Categories, 'UEF') or table.find(bp.Categories, 'SERAPHIM') then
					FactionBalance = FactionBalance * 0.5
				end
			end
			if table.find(bp.Categories, 'HIGHALTAIR') and table.find(bp.Categories, 'TECH3') then
				if table.find(bp.Categories, 'AEON') or table.find(bp.Categories, 'SERAPHIM') then
					FactionBalance = FactionBalance * 0.5
				end
			end
			return math.ceil((25 + (math.floor(Puissance/10) - 1)) * FactionBalance)
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.02
			else
				return 0.04
			end
		end,
		Space = 5,
		},
	DamageTank = {
		Name = 'Damage to Tanks', 
		IsAvailable = function(id, WeaponCategory, WeaponIndex)
			if WeaponCategory == 'Defense' then
				return false
			else
				return true
			end
		end,
		Calculate = function(id, WeaponIndex)
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			local WeaponSkill = DM.GetProperty(id,'Weapon Skill', 5)
			local Puissance = DM.GetProperty(id,'Puissance', 25)
			local WeaponMastery =  (DM.GetProperty(id,'Weapon Mastery', 0) or 0)
			return ((WeaponMastery / 500 + WeaponSkill / 800 + 1) * 35)
		end,
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.06
			else
				return 0.10
			end
		end,
		Space = 15,
		},
	DamageBot = {
		Name = 'Damage to Bots', 
		IsAvailable = function(id, WeaponCategory, WeaponIndex)
			if WeaponCategory == 'Defense' then
				return false
			else
				return true
			end
		end,
		Calculate = function(id, WeaponIndex)
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			local WeaponSkill = DM.GetProperty(id,'Weapon Skill', 5)
			local Puissance = DM.GetProperty(id,'Puissance', 25)
			local WeaponMastery =  (DM.GetProperty(id,'Weapon Mastery', 0) or 0)
			return ((WeaponMastery / 500 + WeaponSkill / 800 + 1) * 35)
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.06
			else
				return 0.10
			end
		end,
		Space = 15,
		},
	DamageHighAltAir = {
		Name = 'Damage to High Aircratfs', 
		IsAvailable = function(id, WeaponCategory, WeaponIndex)
			local ExcludeList = {'Direct Fire', 'Direct Fire Naval', 'Direct Fire Experimental', 'Missile', 'Artillery', 'Bomb', 'Kamikaze', 'Anti Navy', 'Defense'}
			if table.find(ExcludeList, WeaponCategory) then
				return false
			else
				return true
			end
		end,
		Calculate = function(id, WeaponIndex)
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			local WeaponSkill = DM.GetProperty(id,'Weapon Skill', 5)
			local Puissance = DM.GetProperty(id,'Puissance', 25)
			local WeaponMastery =  (DM.GetProperty(id,'Weapon Mastery', 0) or 0)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			local FactionBalance = 1
			if table.find(bp.Categories, 'HIGHALTAIR') and table.find(bp.Categories, 'TECH1') then
				if table.find(bp.Categories, 'UEF') or table.find(bp.Categories, 'SERAPHIM') then
					FactionBalance = FactionBalance * 0.5
				end
			end
			if table.find(bp.Categories, 'HIGHALTAIR') and table.find(bp.Categories, 'TECH3') then
				if table.find(bp.Categories, 'AEON') or table.find(bp.Categories, 'SERAPHIM') then
					FactionBalance = FactionBalance * 0.5
				end
			end
			return ((WeaponMastery / 500 + WeaponSkill / 800 + 1) * 35 * FactionBalance)
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.06
			else
				return 0.10
			end
		end,
		Space = 15,
		},
	DamageAir = {
		Name = 'Damage to Ground Aircrafts',  
		IsAvailable = function(id, WeaponCategory, WeaponIndex)
			local ExcludeList = {'Direct Fire', 'Direct Fire Naval', 'Direct Fire Experimental', 'Missile', 'Artillery', 'Bomb', 'Kamikaze', 'Anti Navy', 'Defense'}
			if table.find(ExcludeList, WeaponCategory) then
				return false
			else
				return true
			end
		end,
		Calculate = function(id, WeaponIndex)
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			local WeaponSkill = DM.GetProperty(id,'Weapon Skill', 5)
			local Puissance = DM.GetProperty(id,'Puissance', 25)
			local WeaponMastery =  (DM.GetProperty(id,'Weapon Mastery', 0) or 0)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			local FactionBalance = 1
			if table.find(bp.Categories, 'HIGHALTAIR') and table.find(bp.Categories, 'TECH1') then
				if table.find(bp.Categories, 'UEF') or table.find(bp.Categories, 'SERAPHIM') then
					FactionBalance = FactionBalance * 0.5
				end
			end
			if table.find(bp.Categories, 'HIGHALTAIR') and table.find(bp.Categories, 'TECH3') then
				if table.find(bp.Categories, 'AEON') or table.find(bp.Categories, 'SERAPHIM') then
					FactionBalance = FactionBalance * 0.5
				end
			end
			return ((WeaponMastery / 500 + WeaponSkill / 800 + 1) * 35 * FactionBalance)
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.06
			else
				return 0.10
			end
		end,
		Space = 15,
		},
	DamageExperimental = {
		Name = 'Damage to Experimentals', 
		IsAvailable = function(id, WeaponCategory, WeaponIndex)
			local ExcludeList = {'Defense'}
			if table.find(ExcludeList, WeaponCategory) then
				return false
			else
				return true
			end
		end,
		Calculate = function(id, WeaponIndex)
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			local WeaponSkill = DM.GetProperty(id,'Weapon Skill', 5)
			local Puissance = DM.GetProperty(id,'Puissance', 25)
			local WeaponMastery =  (DM.GetProperty(id,'Weapon Mastery', 0) or 0)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			local FactionBalance = 1
			if table.find(bp.Categories, 'HIGHALTAIR') and table.find(bp.Categories, 'TECH1') then
				if table.find(bp.Categories, 'UEF') or table.find(bp.Categories, 'SERAPHIM') then
					FactionBalance = FactionBalance * 0.5
				end
			end
			if table.find(bp.Categories, 'HIGHALTAIR') and table.find(bp.Categories, 'TECH3') then
				if table.find(bp.Categories, 'AEON') or table.find(bp.Categories, 'SERAPHIM') then
					FactionBalance = FactionBalance * 0.5
				end
			end
			return ((WeaponMastery / 500 + WeaponSkill / 800 + 1) * 35 * FactionBalance)
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.06
			else
				return 0.10
			end
		end,
		Space = 15,
		},
	DamageNaval = {
		Name = 'Damage to Navals',
		IsAvailable = function(id, WeaponCategory, WeaponIndex)
			local ExcludeList = {'Defense', 'Anti Air'}
			if table.find(ExcludeList, WeaponCategory) then
				return false
			else
				return true
			end
		end,
		Calculate = function(id, WeaponIndex)
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			local WeaponSkill = DM.GetProperty(id,'Weapon Skill', 5)
			local Puissance = DM.GetProperty(id,'Puissance', 25)
			local WeaponMastery =  (DM.GetProperty(id,'Weapon Mastery', 0) or 0)
			return ((WeaponMastery / 400 + WeaponSkill / 500 + 1) * 35)
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.06
			else
				return 0.10
			end
		end,
		Space = 15,
		},
	DamageStructure = {
		Name = 'Damage to Structures',
		IsAvailable = function(id, WeaponCategory, WeaponIndex)
			local ExcludeList = {'Defense', 'Anti Air'}
			if table.find(ExcludeList, WeaponCategory) then
				return false
			else
				return true
			end
		end,
		Calculate = function(id, WeaponIndex)
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			local WeaponSkill = DM.GetProperty(id,'Weapon Skill', 5)
			local Puissance = DM.GetProperty(id,'Puissance', 25)
			local WeaponMastery =  (DM.GetProperty(id,'Weapon Mastery', 0) or 0)
			return ((WeaponMastery / 500 + WeaponSkill / 800 + 1) * 35)
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.06
			else
				return 0.10
			end
		end,
		Space = 15,
		},
	DamageSubCommand = {
		Name = 'Damage to SubCommanders',
		IsAvailable = function(id, WeaponCategory, WeaponIndex)
			local ExcludeList = {'Defense', 'Anti Air'}
			if table.find(ExcludeList, WeaponCategory) then
				return false
			else
				return true
			end
		end,
		Calculate = function(id, WeaponIndex)
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			local WeaponSkill = DM.GetProperty(id,'Weapon Skill', 5)
			local Puissance = DM.GetProperty(id,'Puissance', 25)
			local WeaponMastery =  (DM.GetProperty(id,'Weapon Mastery', 0) or 0)
			return ((WeaponMastery / 500 + WeaponSkill / 800 + 1) * 35)
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.06
			else
				return 0.10
			end
		end,
		Space = 15,
		},
	DamageDefense = {
		Name = 'Damage to Defenses',
		IsAvailable = function(id, WeaponCategory, WeaponIndex)
			local ExcludeList = {'Defense', 'Anti Air'}
			if table.find(ExcludeList, WeaponCategory) then
				return false
			else
				return true
			end
		end,
		Calculate = function(id, WeaponIndex)
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			local WeaponSkill = DM.GetProperty(id,'Weapon Skill', 5)
			local Puissance = DM.GetProperty(id,'Puissance', 25)
			local WeaponMastery =  (DM.GetProperty(id,'Weapon Mastery', 0) or 0)
			return ((WeaponMastery / 500 + WeaponSkill / 800 + 1) * 35)
		end, 
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.06
			else
				return 0.10
			end
		end,
		Space = 15,
		},	
	MissileSpeed = {
		Name = 'Missile Speed', 
		IsAvailable = function(id, WeaponCategory, WeaponIndex)
			local ExcludeList = {'Direct Fire', 'Direct Fire Naval', 'Direct Fire Experimental', 'Artillery', 'Bomb', 'Kamikaze', 'Anti Air', 'Anti Navy', 'Defense'}
			if table.find(ExcludeList, WeaponCategory) then
				return false
			else
				return true
			end
		end,
		Calculate = function(id, WeaponIndex)
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			local WeaponSkill = DM.GetProperty(id,'Weapon Skill', 5)
			local Intelligence = DM.GetProperty(id,'Intelligence', 25)
			local Dexterity = DM.GetProperty(id,'Dexterity', 25)
			return math.ceil(WeaponSkill / 50 + Intelligence / 20 +  Dexterity / 20)
		end,
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.02
			else
				return 0.10
			end
		end,
		Space = 15,
		},
	MissileHealth = {
		Name = 'Missile Health',  
		IsAvailable = function(id, WeaponCategory, WeaponIndex)
			local ExcludeList = {'Direct Fire', 'Direct Fire Naval', 'Direct Fire Experimental', 'Artillery', 'Bomb', 'Kamikaze', 'Anti Air', 'Anti Navy', 'Defense'}
			if table.find(ExcludeList, WeaponCategory) then
				return false
			else
				return true
			end
		end,
		Calculate = function(id, WeaponIndex)
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			local WeaponSkill = DM.GetProperty(id,'Weapon Skill', 5)
			local Hull = DM.GetProperty(id,'Hull', 25)
			return math.ceil(1 + Hull / 25)
		end,
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.02
			else
				return 0.10
			end
		end,
		Space = 25,
		},
	MissileArmor = {
		Name = 'Missile Armor',
		IsAvailable = function(id, WeaponCategory, WeaponIndex)
			local ExcludeList = {'Direct Fire', 'Direct Fire Naval', 'Direct Fire Experimental', 'Artillery', 'Bomb', 'Kamikaze', 'Anti Air', 'Anti Navy', 'Defense'}
			if table.find(ExcludeList, WeaponCategory) then
				return false
			else
				return true
			end
		end,
		Calculate = function(id, WeaponIndex)
			local WeaponSkill = DM.GetProperty(id,'Weapon Skill', 5)
			local Dexterity = DM.GetProperty(id,'Dexterity', 25)
			local Hull = DM.GetProperty(id,'Hull', 25)
			return math.ceil(WeaponSkill / 5 + Hull * 1.5 + Dexterity)
		end,
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.02
			else
				return 0.10
			end
		end,
		Space = 25,
		},
	ConversionToHealth = {
		Name = 'Conversion To Health',
		IsAvailable = function(id, WeaponCategory, WeaponIndex)
			local ExcludeList = {'Defense'}
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			if table.find(ExcludeList, WeaponCategory) or BaseClass ~= 'Ardent' then
				return false
			else
				return true
			end
		end,
		Calculate = function(id, WeaponIndex)
			local Intelligence = DM.GetProperty(id,'Intelligence', 25)
			local Energy = DM.GetProperty(id,'Energy', 25)
			local WeaponSkill = DM.GetProperty(id,'Weapon Skill', 5)
			return math.ceil(Intelligence / 8 + Energy / 16 + WeaponSkill / 40)
		end,
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.04
			else
				return 0.10
			end
		end,
		Space = 20,
		},
	ConversionToEnergy = {
		Name = 'Conversion To Energy',
		IsAvailable = function(id, WeaponCategory, WeaponIndex)
			local ExcludeList = {'Defense'}
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			if table.find(ExcludeList, WeaponCategory) or BaseClass ~= 'Ardent' then
				return false
			else
				return true
			end
		end,
		Calculate = function(id, WeaponIndex)
			local Intelligence = DM.GetProperty(id,'Intelligence', 25)
			local Energy = DM.GetProperty(id,'Energy', 25)
			local WeaponSkill = DM.GetProperty(id,'Weapon Skill', 5)
			return math.ceil(Intelligence / 4 + Energy /2 + WeaponSkill / 40)
		end,
		Cost = function(id)
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				return 0.04
			else
				return 0.10
			end
		end,
		Space = 10,
		},
}

WeaponsTemplates = {
	LongRange = {'Damage','MaxRadius'},
	FastAttackBots = {'Damage', 'RateOfFire', 'DamageBot'},
}

	
-- Reference for sorting keys and views
RefRank = {
		'Damage', 
		'DamageHighAltAir', 
		'DamageAir', 
		'DamageBot', 
		'DamageTank', 
		'DamageNaval', 
		'DamageSubCommand',
		'DamageExperimental', 
		'DamageStructure',
		'DamageDefense',
		'DamageRadius', 
		'RateOfFire', 
		'AttackRating', 
		'MaxRadius', 
		'ArmorPiercing', 
		'MissileSpeed', 
		'MissileHealth',
		'MissileArmor',
		'ConversionToHealth', 
		'ConversionToEnergy'}
		
RefView = {
		'Damage to All Units',
		'Damage to High Aircratfs', 
		'Damage to Ground Aircrafts', 
		'Damage to Bots', 
		'Damage to Tanks', 
		'Damage to Navals',
		'Damage to SubCommanders',
		'Damage to Experimentals', 
		'Damage to Structures',
		'Damage to Defenses',
		'Damage Area of Effect', 
		'Rate Of Fire', 
		'Attack Rating', 
		'Range',
		'Armor Piercing', 
		'Missile Speed',
		'Missile Health', 
		'Missile Armor',
		'Conversion To Health',
		'Conversion To Energy'}



-- Theses 2 funtions add prefix and suffix for friendly view depending of the modifier type
GetPrefix = function(key)
	PrefixView = {'+ ', '+ ', '+ ', '+ ', '+ ', '+ ', '+ ', '+ ', '+ ', ' +', '+ ', '+ ', '+ ', '+ ', '+ ', '+ ', '+ ', '+ ', '  ', '  '}
	for i, modifier in RefView do
		if modifier == key then
			return PrefixView[i]
		end
	end
	return 'No key found in Weapon Reference view'
end

GetSuffix = function(key)
	SuffixView = {' %', ' %', ' %', ' %', ' %', ' %', ' %', ' %', ' %', ' %', '', ' %', '', '', '', '', ' %', '', ' %', ' %'}
	for i, modifier in RefView do
		if modifier == key then
			return SuffixView[i]
		end
	end
	return 'No key found in Weapon Reference view'
end

-- This function convert RefView key to RefRank key. It's usefull sometimes since space chars are not allowed for keys
GetInternalKey = function(RefViewKey)
	for i, modifier in RefView do
		if modifier == RefViewKey then
			return RefRank[i]
		end
	end
	return 'No key found in reference key'
end
