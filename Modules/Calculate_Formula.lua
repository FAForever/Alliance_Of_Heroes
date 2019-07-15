------------------------------
-- Alliance of Heroes Mod ----
-- Franck83 [2016-2017] ------
------------------------------
-- Formula and tools.


local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local BCbp = import(ModPath..'Modules/ClassDefinitions.lua').BaseClassBlueprint
local Skills = import(ModPath..'Modules/Skills.lua').Skills
local Powers = import(ModPath..'Modules/Powers.lua').Powers
local ArmorModifiers =  import(ModPath..'Modules/ArmorModifiers.lua')
local WeaponModifiers =  import(ModPath..'Modules/WeaponModifiers.lua')
local PC = import(ModPath..'Modules/ClassDefinitions.lua').PrestigeClass
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')


function Calculate_HallofFameBonus(FamePoints, Class)
	local bonus = math.pow(FamePoints or 0, 0.7)
	if Class == 'Fighter' then
		return math.ceil(bonus)
	elseif Class == 'Rogue' then
		return math.ceil(bonus)
	elseif Class == 'Support' then
		return math.ceil(bonus * 0.3)
	elseif Class == 'Ardent' then
		return math.ceil(bonus*0.35)
	end
end

function GetAllHeroesList() 
	local AllBrainHeroesList = {}
	for i, brain in ArmyBrains do
		for j, hero in brain.HeroesList do
			if hero and hero.Dead == false then 
				local id = hero:GetEntityId()
				if DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 or DM.GetProperty(id, 'Promoting') == 1 then
					table.insert(AllBrainHeroesList, hero)
				else
					table.remove(AllBrainHeroesList, j)
				end
			else
				table.remove(AllBrainHeroesList, j)
			end
		end
	end
	return AllBrainHeroesList
end

function GetPlayerHeroesList(yourbrain) 
	local PlayerHeroesList = {}
	for j, hero in yourbrain.HeroesList do
		if hero and hero.Dead == false then 
			local id = hero:GetEntityId()
			if DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 or DM.GetProperty(id, 'Promoting') == 1 then
				table.insert(PlayerHeroesList, hero)
			else
				table.remove(PlayerHeroesList, j)
			end	
		end
	end
	yourbrain.HeroesList = {}
	for j, hero in PlayerHeroesList do
		table.insert(yourbrain.HeroesList, hero)
	end
	return PlayerHeroesList
end

function GetLogisticAvailable(ArmyBrain)
	local HeroesList = GetPlayerHeroesList(ArmyBrain)
	local Logistics = 100
	for j, hero in HeroesList do
		Logistics = Logistics - GetLogisticCost(hero)
	end
	return Logistics
end

function GetLogisticCost(unit)
	local bp = unit:GetBlueprint() 
	local level = GetUnitLevel(unit)
	local Tech = GetUnitTech(unit)
	local LogisticCostMod = 2
	if table.find(bp.Categories, 'STRUCTURE') then LogisticCostMod = 1 end
	if level >= 10 then LogisticCostMod = 0.5 end
	if level >= 20 then LogisticCostMod = 0 end
	if level >= 30 then LogisticCostMod = -0.5 * Tech end
	if level >= 40 then LogisticCostMod = -1 * Tech end
	if level >= 50 then LogisticCostMod = -1.5 * Tech end
	if level >= 60 then LogisticCostMod = -2 * Tech end
	if level >= 70 then LogisticCostMod = -2.5 * Tech end
	if table.find(bp.Categories, 'COMMAND') then LogisticCostMod = 0 end
	return math.ceil(math.pow(bp.Economy.BuildCostMass / 10, 0.6))
end



function SortHeroesListToUi(HeroList, Data)
	local Hero = {}
	for i, _Hero in HeroList do
		if _Hero and _Hero.Dead == false then
			Hero[_Hero:GetEntityId()] = _Hero[Data]
		end
	end
	local function spairs(t, order)
		local keys = {}
		local i = 1
		for k in pairs(t) do 
			keys[i] = k 
			i = i + 1
		end
		if order then
			table.sort(keys, function(a,b) return order(t, a, b) end)
		else
			table.sort(keys)
		end
		local i = 0
		return function()
			i = i + 1
			if keys[i] then
				return keys[i], t[keys[i]]
			end
		end
	end
	local Sorted = {}
	for k,v in spairs(Hero, function(t,a,b) return t[b] < t[a] end) do
		table.insert(Sorted, {k, v})
	end
	return Sorted
end

function GetRankInHeroList(id, data)
	local HeroList = SortHeroesListToUi(GetAllHeroesList(), data)
	for i, Hero in HeroList do
		if Hero[1] == id then return i end
	end
	return LOG('GetRankinHeroList : Hero not found')
end

function SortDualHeroList()
	local PointsSystem = {25, 18, 15, 12, 10, 8, 6, 4, 2, 1}
	local PointsSystem = {25, 18, 15, 12, 10, 8, 6, 4, 2, 1}
	local HeroList = GetAllHeroesList()
	local HeroListMod = {}
	local HeroListModSorted = {}
	-- LOG(repr(HeroList))
	for i, Hero in HeroList do
		local id = Hero:GetEntityId()
		local HeroRankM = GetRankInHeroList(id, 'MassKilled')
		local PointsEarnedInMassKilled = 0
		if Hero.MassKilled > 0 then
			PointsEarnedInMassKilled = PointsSystem[HeroRankM] or 0
		else
			PointsEarnedInMassKilled = 0
			HeroRankM = 999
		end
		local HeroRankH = GetRankInHeroList(id, 'HpHealed')
		local PointsEarnedInHpHealed = 0
		if Hero.HpHealed > 0 then
			PointsEarnedInHpHealed = PointsSystem[HeroRankH] or 0
		else
			PointsEarnedInHpHealed = 0
			HeroRankH = 999
		end
		local PointsEarnedTotal = PointsEarnedInMassKilled + PointsEarnedInHpHealed
		Hero.MassKilledRank = HeroRankM
		Hero.HpHealedRank = HeroRankH
		Hero.FamePoints = PointsEarnedTotal
		table.insert(HeroListMod, Hero)
	end
	HeroListModSorted = SortHeroesListToUi(HeroListMod, 'FamePoints')
	return HeroListModSorted
end

function HasATargetOnWeapon(unit)
	if unit and IsMilitary(unit) == true then
		local bp = unit:GetBlueprint()
		for i, wep in bp.Weapon do
			if wep.Label == 'DeathWeapon' or wep.Label == 'DeathImpact' or  bp.Weapon.TargetType == 'RULEWTT_Projectile' or wep.DisplayName == 'Teleport in' or wep.Label =='ChronoDampener' or wep.Label =='CollossusDeath' or wep.Label =='MegalithDeath' or wep.Label == 'Tactical Warhead' then
			else
				if wep.Damage > 0 then
					Weap = unit:GetWeapon(i)
					if Weap:WeaponHasTarget() == true then return true end
				end
			end
		end
	end
	return false
end

function GetUnitTypes(unit)
	local typelist = {'EXPERIMENTAL', 'COMMAND', 'SUBCOMMANDER', 'HIGHALTAIR', 'DEFENSE', 'STRUCTURE', 'AIR', 'NAVAL', 'BOT', 'TANK'}
	local types = {}
	local bp = unit:GetBlueprint()
	for _, type in typelist do
		if table.find(bp.Categories, type) then
			table.insert(types, type)
		end
	end
	-- LOG(repr(types))
	return types
end

function GetUnitLayerType(unit)
	local typelist = {'HIGHALTAIR', 'AIR', 'NAVAL', 'LAND', 'SATELLITE'}
	local bp = unit:GetBlueprint()
	for _, type in typelist do
		if table.find(bp.Categories, type) then
			return type
		end
	end
	return 'UNKNOWN'
end

function GetUnitLayerTypeHero(unit)
	local typelist = {'AIR', 'NAVAL', 'LAND'}
	local bp = unit:GetBlueprint()
	for _, type in typelist do
		if table.find(bp.Categories, type) then
			return type
		end
	end
	return 'UNKNOWN'
end

function GetGainPerLevel(unit, category)
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local BaseClass = DM.GetProperty(id,'BaseClass', 'Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass') or 'NeedPromote'
	if category == 'Health' then
		local Base = math.pow(bp.Defense.MaxHealth, 0.8)
		local Power =  math.pow(bp.Economy.BuildCostMass, 0.6)
		local Hull =  DM.GetProperty(id,'Hull')
		local ClassModifier =  BCbp[BaseClass]['HealthGainModifier']
		local PrestigeClassMod = PC[PrestigeClass]['MaxHealthMod'] or 1
		return math.floor((bp.Defense.MaxHealth * 0.05) * (1 + Hull / 50 + ClassModifier + PrestigeClassMod))
	end
	if category == 'Weapon Capacitor' then
		local ClassModifier =  BCbp[BaseClass]['StaminaGainModifier']
		local Hull =  DM.GetProperty(id,'Hull')
		return math.floor(ClassModifier * (1 + Hull / 25) * 5)
	end
	if category == 'Power Capacitor' then
		local ClassModifier =  BCbp[BaseClass]['CapacitorGainModifier']
		local Energy =  DM.GetProperty(id,'Energy')
		return math.floor(ClassModifier * (1 + Energy / 25) * 4)
	end
end

function GetStanceModifier(unit, Modifier, _Stance)
	local id = unit:GetEntityId()
	local Stance = DM.GetProperty(id,'StanceState', 'Normal')
	local BaseClass = DM.GetProperty(id,'BaseClass', 'Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass') or 'NeedPromote'
	if PrestigeClass == 'NeedPromote' then PrestigeClass = 'Dreadnought' end
	local BpStance = BCbp[BaseClass]['Stance']
	local ModifierVal = BpStance[Stance][Modifier] or BpStance['Normal'][Modifier] or 1
	-- LOG(BaseClass..' '..PrestigeClass)
	local StanceLevel = PC[BaseClass..' '..PrestigeClass].StanceLevel(Stance, BaseClass) or 1
	if _Stance != nil then 
		ModifierVal = BpStance[_Stance][Modifier] or BpStance['Normal'][Modifier] or 1
		StanceLevel = PC[BaseClass..' '..PrestigeClass].StanceLevel(_Stance, BaseClass) or 1
	end
	if ModifierVal >= 1 then
		return ((ModifierVal - 1) * StanceLevel) + 1
	else
		return 1 - ((1-ModifierVal) * StanceLevel)
	end
end

function GetStanceRank(unit, stance)
	local id = unit:GetEntityId()
	local BaseClass = DM.GetProperty(id,'BaseClass', 'Fighter')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass', 'Dreadnought')
	if PrestigeClass == 'NeedPromote' then PrestigeClass = 'Dreadnought' end
	local StanceLevel = PC[BaseClass..' '..PrestigeClass].StanceLevel(stance, BaseClass)
	local StanceRanks = {'Neophyte', 'Novice', 'Apprentice', 'Journeyman', 'Skilled', 'Proficient', 'Expert', 'Master'}
	local CurrentRank = 'Neophyte'
	for i, StanceRank in StanceRanks do
		if (i*0.125) <= StanceLevel then 
			CurrentRank = StanceRank
		end
	end
	return CurrentRank
end

function GetRankName(level)
	local StanceRanks = {'Neophyte', 'Novice', 'Apprentice', 'Journeyman', 'Skilled', 'Proficient', 'Expert', 'Master'}
	local CurrentRank = 'Neophyte'
	for i, StanceRank in StanceRanks do
		if (i*0.125) <= level then 
			CurrentRank = StanceRank
		end
	end
	return CurrentRank
end



function GetUnitTech(unit)
	if unit then
		local bp = unit:GetBlueprint()
		if table.find(bp.Categories, 'COMMAND') then return 4 end
		if table.find(bp.Categories, 'TECH1') then return 1 end
		if table.find(bp.Categories, 'TECH2') then return 2 end
		if table.find(bp.Categories, 'TECH3') then return 3 end
		if table.find(bp.Categories, 'EXPERIMENTAL') then return 4 end
	end
	return 1
end

function GetSpaceUsedByWeapons(unit)
	local id = unit:GetEntityId()
	local SpaceUsed = 0
	for _, modifier in WeaponModifiers.RefView do
		for WeaponIndex = 1, 30 do
			if DM.GetProperty(id, 'Upgrade_Weapon_'..WeaponIndex..'_'..modifier) then
				local level = DM.GetProperty(id, 'Upgrade_Weapon_'..WeaponIndex..'_'..modifier..'_Level')
				SpaceUsed = SpaceUsed + WeaponModifiers.Modifiers[WeaponModifiers.GetInternalKey(modifier)].Space * level
			end
		end
	end
	return math.ceil(SpaceUsed)
end

function GetSpaceUsedByWeapon(unit, WeaponIndex)
	local id = unit:GetEntityId()
	local SpaceUsed = 0
	for _, modifier in WeaponModifiers.RefView do
		if DM.GetProperty(id, 'Upgrade_Weapon_'..WeaponIndex..'_'..modifier) then
			local level = DM.GetProperty(id, 'Upgrade_Weapon_'..WeaponIndex..'_'..modifier..'_Level')
			SpaceUsed = SpaceUsed + WeaponModifiers.Modifiers[WeaponModifiers.GetInternalKey(modifier)].Space * level
		end
	end
	return math.ceil(math.max(SpaceUsed, 0))
end

function GetSpaceUsedByArmor(unit, templatename, templatetablelevels)
	local id = unit:GetEntityId()
	local SpaceUsed = 0
	if templatename then
		for _, modifier in ArmorModifiers.RefView do
			if templatetablelevels[templatename][modifier] then
				local level = templatetablelevels[templatename][modifier]
				SpaceUsed = SpaceUsed + ArmorModifiers.Modifiers[ArmorModifiers.GetInternalKey(modifier)].Space * level
			end
		end
	else	
		for _, modifier in ArmorModifiers.RefView do
			if DM.GetProperty(id, 'Upgrade_Armor_'..modifier) then
				local level = DM.GetProperty(id, 'Upgrade_Armor_'..modifier..'_Level')
				SpaceUsed = SpaceUsed + ArmorModifiers.Modifiers[ArmorModifiers.GetInternalKey(modifier)].Space * level
			end
		end
	end

	return math.ceil(math.max(SpaceUsed, 0))
end

function GetGeneralTemplateList(unit, templatetable)
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local BaseClass = DM.GetProperty(id,'BaseClass')
	local PrestigeClass = DM.GetProperty(id,'PrestigeClass')
	local MaxSpaceAvailable = math.ceil(80 + DM.GetProperty(id,'Hull') + table.getn(bp.Weapon) * 5)
	if table.find(bp.Categories, 'COMMAND') then
		MaxSpaceAvailable = math.ceil(50 + DM.GetProperty(id,'Hull') + 40)
	end
	local availabletemplatelist = {}
	local function GetTemplateArmorSpaceNeeded(templatename)
		local SpaceUsed = 0
		for _, modifier in ArmorModifiers.RefView do
			local level = templatetable[BaseClass][PrestigeClass][templatename]['Upgrade_Armor_'..modifier..'_Level'] or 0
			SpaceUsed = SpaceUsed + ArmorModifiers.Modifiers[ArmorModifiers.GetInternalKey(modifier)].Space * level
		end
		return SpaceUsed
	end
	local function GetTemplateWeaponSpaceNeeded(templatename)
		local SpaceUsed = 0
		for WeaponIndex = 1, 30 do
			for _, modifier in WeaponModifiers.RefView do
				local level = templatetable[BaseClass][PrestigeClass][templatename]['Upgrade_Weapon_'..WeaponIndex..'_'..modifier..'_Level'] or 0
				SpaceUsed = SpaceUsed + WeaponModifiers.Modifiers[WeaponModifiers.GetInternalKey(modifier)].Space * level
			end
		end
		return SpaceUsed
	end
	if templatetable[BaseClass][PrestigeClass] != nil then
		for	template,_ in templatetable[BaseClass][PrestigeClass] do
			local SpaceNeededByTemplate = GetTemplateWeaponSpaceNeeded(template) + GetTemplateArmorSpaceNeeded(template)
			if math.floor(SpaceNeededByTemplate) <= MaxSpaceAvailable then
				table.insert(availabletemplatelist, template)
			end
		end
	end
	return availabletemplatelist
end

function GetPromotionTemplateList(unit, templatetable)
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local BaseClass = DM.GetProperty(id,'BaseClass')
	local PromoteList = GetAvailablePromoteList(id)
	local MaxSpaceAvailable = math.ceil(80 + DM.GetProperty(id,'Hull') + table.getn(bp.Weapon) * 5)
	if table.find(bp.Categories, 'COMMAND') then
		MaxSpaceAvailable = math.ceil(50 + DM.GetProperty(id,'Hull') + 40)
	end
	local availabletemplatelist = {}
	local PClassList = {}
	local function GetTemplateArmorSpaceNeeded(templatename, PrestigeClass)
		local SpaceUsed = 0
		for _, modifier in ArmorModifiers.RefView do
			local level = templatetable[BaseClass][PrestigeClass][templatename]['Upgrade_Armor_'..modifier..'_Level'] or 0
			SpaceUsed = SpaceUsed + ArmorModifiers.Modifiers[ArmorModifiers.GetInternalKey(modifier)].Space * level
		end
		return SpaceUsed
	end
	local function GetTemplateWeaponSpaceNeeded(templatename, PrestigeClass)
		local SpaceUsed = 0
		for WeaponIndex = 1, 30 do
			for _, modifier in WeaponModifiers.RefView do
				local level = templatetable[BaseClass][PrestigeClass][templatename]['Upgrade_Weapon_'..WeaponIndex..'_'..modifier..'_Level'] or 0
				SpaceUsed = SpaceUsed + WeaponModifiers.Modifiers[WeaponModifiers.GetInternalKey(modifier)].Space * level
			end
		end
		return SpaceUsed
	end
	for _, PrestigeClass in PromoteList do
		if templatetable[BaseClass][PrestigeClass] != nil then
			for	template,_ in templatetable[BaseClass][PrestigeClass] do
				local SpaceNeededByTemplate = GetTemplateWeaponSpaceNeeded(template, PrestigeClass) + GetTemplateArmorSpaceNeeded(template, PrestigeClass)
				if math.floor(SpaceNeededByTemplate) <= MaxSpaceAvailable then
					table.insert(availabletemplatelist, template)
					table.insert(PClassList, PrestigeClass)
				end
			end
		end
	end
	return availabletemplatelist, PClassList
end

function GetAvailableSpace(unit)
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local SpaceUsedByWeapons = GetSpaceUsedByWeapons(unit)
	local SpaceAvailable = 0
	if table.find(bp.Categories, 'COMMAND') then
		SpaceAvailable = math.ceil(50 + DM.GetProperty(id,'Hull') + 40)
	else
		SpaceAvailable = math.ceil(80 + DM.GetProperty(id,'Hull') + table.getn(bp.Weapon) * 5)
	end
	return  math.max(math.ceil(SpaceAvailable - SpaceUsedByWeapons), 0)
end

function GetAvailableMaxSpace(unit)
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local SpaceAvailable = 0
	if table.find(bp.Categories, 'COMMAND') then
		SpaceAvailable = math.ceil(50 + DM.GetProperty(id,'Hull') + 40)
	else
		SpaceAvailable = math.ceil(80 + DM.GetProperty(id,'Hull') + table.getn(bp.Weapon) * 5)
	end
	return  math.ceil(SpaceAvailable)
end


function GetUnitRegen(unit)
	local id = unit:GetEntityId()
	local bp = unit:GetBlueprint()
	local level = GetUnitLevel(unit)
	local TechLevel = GetUnitTech(unit) or 1
	local army = unit:GetArmy()
	-- local HallofFameBonusRegen = Calculate_HallofFameBonus(DM.GetProperty(army, 'AI_'..'Support'..'_'..GetUnitLayerTypeHero(unit), 0), 'Support') * TechLevel
	local Regen = (DM.GetProperty(id, 'Hull') / 25) * TechLevel * (level - 1) * 0.3 + DM.GetProperty(id,'Upgrade_Armor_Regeneration Increase', 0)
	return Regen
end

function GetUnitLevel(Unit)
	if Unit then
		local id = Unit:GetEntityId()
		local bp = Unit:GetBlueprint()
		local Xp = DM.GetProperty(id,'XP') or 0
		local UnitLevel = 77 - 76  * math.pow(0.99, Xp/100)
		UnitLevel = math.min(UnitLevel, 75)
		return math.floor(UnitLevel), UnitLevel
	else
		return 1, 1
	end
end

function IsDefenseDodge(self, ATR, Stance)
	local id = self:GetEntityId()
	local ChanceToDodge = 5
	local AttackRating = ATR or 135
	if DM.GetProperty(id, 'CumulAttackRating') > 0 then AttackRating = DM.GetProperty(id, 'CumulAttackRating') end
	local DefenseRating = (GetDefenseRating(self, Stance) or 38)
	if DefenseRating > AttackRating then
		ChanceToDodge = math.min(50 + math.ceil(math.pow(DefenseRating - AttackRating, 0.68)), 100)
	elseif DefenseRating < AttackRating then
		ChanceToDodge = math.max(50 - math.ceil(math.pow(AttackRating - DefenseRating , 0.68) * math.pow((AttackRating / DefenseRating), 0.5)), 0)
	else
		ChanceToDodge = 50
	end
	local army = self:GetArmy()
	local HallofFameBonusDodge = Calculate_HallofFameBonus(DM.GetProperty(army, 'AI_'..'Rogue'..'_'..GetUnitLayerTypeHero(self), 0), 'Rogue')
	ChanceToDodge = ChanceToDodge + HallofFameBonusDodge
	ChanceToDodge = math.max(ChanceToDodge, 0)
	ChanceToDodge = math.min(ChanceToDodge, 85)
	return (math.random(0,100) < ChanceToDodge), ChanceToDodge
end

function GetAvailablePromoteList(id)
	local PromoteList = {}
	for Class,_ in PC do
		if PC[Class].IsAvailable(id) == true then
			table.insert(PromoteList, Class)
		end
	end
	table.sort(PromoteList)
	return PromoteList
end

function IsMilitary(unit)
	local bp = unit:GetBlueprint()
	if bp.Weapon then
		for _,wep in bp.Weapon do
			if wep.Label == 'DeathWeapon' or wep.Label == 'DeathImpact' then
			else
				if wep.Damage > 0 then
					return true
				end
			end
		end		
	end
	return false
end

function GetWeaponIndexList(unit)
	local bp = unit:GetBlueprint()
	local Weaponlist = {}
	local WeaponCategories = {}
	if bp.Weapon then
		for i,wep in bp.Weapon do
			if wep.Label == 'DeathWeapon' or wep.Label == 'DeathImpact' or wep.DisplayName == 'Teleport in' or wep.Label == 'AutoOverCharge' or wep.Label =='ChronoDampener' or wep.Label =='CollossusDeath' or wep.Label == 'LeftArmTractor' or wep.Label == 'RightArmTractor' or wep.Label == 'MegalithDeath' then
			else
				if wep.Damage > 0 then
					table.insert(Weaponlist, i)
					table.insert(WeaponCategories, wep.WeaponCategory)
				end
			end
		end
	end
	-- if Weaponlist then LOG(repr(Weaponlist)) LOG(repr(bp.Weapon))  end
	return Weaponlist, WeaponCategories
end

function GetWeaponDps(Weapon)
	local DPS = Weapon.Damage * Weapon.RateOfFire
	if Weapon.ProjectilesPerOnFire then
		DPS = DPS * Weapon.ProjectilesPerOnFire
	end
	if Weapon.RackBones.MuzzleBones then
		DPS = DPS * table.getn(Weapon.RackBones.MuzzleBones)
	end
	return math.ceil(DPS)
end

function GetHealthAbsorptionUi(id)
	local unit = GetUnitById(id)
	local level = GetUnitLevel(unit)
	local intelligence = DM.GetProperty(id, 'Intelligence') or 0
	local healthAbso = 100 * (math.min( 0.01 * level * intelligence/40, 0.4))
	return healthAbso
end

function GetEnergyAbsorptionUi(id)
	local unit = GetUnitById(id)
	local level = GetUnitLevel(unit)
	local intelligence = DM.GetProperty(id, 'Intelligence') or 0
	local EnergyAbso = 100 * (math.min(0.05 * level * intelligence/40, 1.5))
	return EnergyAbso
end

function GetArmorAbsorption(id, WeaponCategory, ArmorPiercing, DamageType)
	local unit = GetUnitById(id)
	local level = GetUnitLevel(unit)
	local WeaponCategoryList = {'Direct Fire', 'Direct Fire Naval', 'Direct Fire Experimental', 'Anti Air', 'Artillery', 'Bomb', 'Nuclear', 'Missile', 'Overcharge'}
	local ModifiedWeaponCategory = WeaponCategory
	local ArmorType = {'Light Armor', 'Medium Armor', 'Heavy Armor'}
	local BaseArmor = AoHBuff.GetBuffValue(unit, 'Armor', 'ALL')
	local TechArmor = DM.GetProperty(id, 'TechArmor', 0)
	if DamageType == 'Plasma' then
		local BaseClass = DM.GetProperty(id, 'BaseClass') == 'Ardent'
		local Stance = DM.GetProperty(id,'StanceState', 'Normal')
		local PlasmaResist = GetStanceModifier(unit, 'Plasma_Resist', Stance)
		return 1-PlasmaResist
	end
	for _, Armor in ArmorType do
		if DM.GetProperty(id, 'Upgrade_Armor_'..Armor, 0) then
			BaseArmor = BaseArmor + DM.GetProperty(id, 'Upgrade_Armor_'..Armor, 0) 
		end
	end
	if not table.find(WeaponCategoryList, ModifiedWeaponCategory) then return  math.min(math.floor(100 * (1 - math.pow(0.9, BaseArmor/10))), 75) end
	local SpecialArmor = BaseArmor
	local TechSpe = DM.GetProperty(id, 'Tech_Armor_'..ModifiedWeaponCategory, 0)
	local UpgrSpe = DM.GetProperty(id, 'Upgrade_Armor_Armor for '..ModifiedWeaponCategory, 0)
	SpecialArmor = SpecialArmor * (1 + (TechSpe + UpgrSpe)/100) + TechArmor
	SpecialArmor = math.max(0, SpecialArmor + AoHBuff.GetBuffValue(unit, 'Armor', ModifiedWeaponCategory) - (ArmorPiercing or 0))
	return math.min(math.floor(100 * (1 - math.pow(0.9, SpecialArmor/10))), 75)
end

function GetArmorAbsorptionUi(id, WeaponCategory, ArmorPiercing, DamageType)
	local unit = GetUnitById(id)
	local level = GetUnitLevel(unit)
	local WeaponCategoryList = {'Direct Fire', 'Direct Fire Naval', 'Direct Fire Experimental', 'Anti Air', 'Artillery', 'Bomb', 'Nuclear', 'Missile', 'Overcharge'}
	local ModifiedWeaponCategory = WeaponCategory
	local ArmorType = {'Light Armor', 'Medium Armor', 'Heavy Armor'}
	local BaseArmor =  DM.GetProperty(id, 'Buff_Armor_ALL_Add', 0)
	local TechArmor = DM.GetProperty(id, 'TechArmor', 0)
	if DamageType == 'Plasma' then
		local BaseClass = DM.GetProperty(id, 'BaseClass') == 'Ardent'
		local Stance = DM.GetProperty(id,'StanceState', 'Normal')
		local PlasmaResist = GetStanceModifier(unit, 'Plasma_Resist', Stance)
		return 1-PlasmaResist
	end
	for _, Armor in ArmorType do
		if DM.GetProperty(id, 'Upgrade_Armor_'..Armor, 0) then
			BaseArmor = BaseArmor + DM.GetProperty(id, 'Upgrade_Armor_'..Armor, 0)
		end
	end
	if not table.find(WeaponCategoryList, ModifiedWeaponCategory) then return math.min(math.floor(100 * (1 - math.pow(0.9, BaseArmor/10))), 75) end
	local SpecialArmor = BaseArmor 
	local TechSpe = DM.GetProperty(id, 'Tech_Armor_'..ModifiedWeaponCategory, 0)
	local UpgrSpe = DM.GetProperty(id, 'Upgrade_Armor_Armor for '..ModifiedWeaponCategory, 0)
	SpecialArmor = SpecialArmor * (1 + (TechSpe + UpgrSpe)/100) + TechArmor
	SpecialArmor = math.max(0, SpecialArmor + AoHBuff.GetBuffValue(unit, 'Armor', ModifiedWeaponCategory) - (ArmorPiercing or 0))
	return math.min(math.floor(100 * (1 - math.pow(0.9, SpecialArmor/10))), 75)
end

function GetDefenseRating(unit, _stance)
	local id = unit:GetEntityId()
	local Tech_Defense = 0
	if DM.GetProperty(id, 'Tech_Defense') then
		Tech_Defense = DM.GetProperty(id, 'Tech_Defense', 0)
	end
	if DM.GetProperty(id, 'PrestigeClassPromoted') == 1 then -- turning off vanilla units calculations for performance optimizations
		local bp = unit:GetBlueprint()
		local Stance = DM.GetProperty(id,'StanceState', 'Normal')
		local BaseClass = DM.GetProperty(id,'BaseClass', 'Fighter')
		local BpStance = BCbp[BaseClass]['Stance']
		local Defensebuff =  DM.GetProperty(id, 'Buff_Defense_ALL_Add', 0)
		local DefenseMod =  GetStanceModifier(unit, 'Defense_Mod', _stance)
		local DefenseDexterity = math.max(math.ceil(DM.GetProperty(id, 'Dexterity', 0)) * 3 - 50, 0)
		local LightArmor = DM.GetProperty(id, 'Upgrade_Armor_Light Armor', 0)
		local MediumArmor = DM.GetProperty(id, 'Upgrade_Armor_Medium Armor', 0)
		local HeavyArmor = DM.GetProperty(id, 'Upgrade_Armor_Heavy Armor', 0)
		local Dexmod = 1
		local DefenseArmor = 0
		if LightArmor > 0 then Dexmod = 0.95 DefenseArmor = (75 + DM.GetProperty(id, 'Light Armor Mastery', 0) * 1.5) *  (math.min(LightArmor, 15) / 15) end
		if MediumArmor > 0 then Dexmod = 0.75 DefenseArmor = (75 + DM.GetProperty(id, 'Medium Armor Mastery', 0) * 1.5) *  (math.min(MediumArmor, 30) / 30) end
		if HeavyArmor > 0 then Dexmod = 0.55 DefenseArmor = (75 + DM.GetProperty(id, 'Heavy Armor Mastery', 0) * 1.5) *  (math.min(HeavyArmor, 45) / 45) end
		local MovPenality = 1
		local UnitTech = GetUnitTech(unit)
		if DM.GetProperty(id, 'IsMoving') == 0 then MovPenality = 0.85 end 
		if table.find(bp.Categories, 'NAVAL') then MovPenality = 0.85  end
		if table.find(bp.Categories, 'AIR') then MovPenality = 0.85 end
		if table.find(bp.Categories, 'HIGHALTAIR') then MovPenality = 1 end
		if table.find(bp.Categories, 'STRUCTURE') then MovPenality = 0.25 end
		if table.find(bp.Categories, 'EXPERIMENTAL') then MovPenality = 0 end
		MovPenality = MovPenality / math.pow(UnitTech or 1, 0.3)
		return math.ceil((DefenseDexterity * Dexmod + Defensebuff + DefenseArmor + Tech_Defense) * DefenseMod * MovPenality)
	else
		local level = GetUnitLevel(unit) or 1
		return math.ceil(25 + Tech_Defense + level * 5)
	end
end

function GetAttackRating(unit, _stance)
	local id = unit:GetEntityId()
	if unit and DM.GetProperty(id, 'PrestigeClassPromoted') == 1 then -- turning off vanilla units calculations for performance optimizations
		local Stance = DM.GetProperty(id,'StanceState', 'Normal')
		local BaseClass = DM.GetProperty(id,'BaseClass', 'Fighter')
		local BpStance = BCbp[BaseClass]['Stance']
		local Attackbuff =  DM.GetProperty(id, 'Buff_Attack_ALL_Add', 0)
		local AttackMod = GetStanceModifier(unit, 'Attack_Mod', _stance)
		local AttackAdd = BpStance[Stance]['Attack_Add'] or BpStance['Normal']['Attack_Add'] or 150
		local AttackDexterity = math.ceil(DM.GetProperty(id, 'Dexterity', 0) * 3)
		local AttackTech = DM.GetProperty(id, 'Tech_Improved Aiming Cumputer', 0)
		local WeaponSkill, WeaponMastery = 0, 0
		if DM.GetProperty(id, 'Weapon Skill') then  WeaponSkill = GetSkillCurrent(id, 'Weapon Skill') end
		if DM.GetProperty(id, 'Weapon Mastery') then  WeaponMastery = GetSkillCurrent(id, 'Weapon Mastery') end
		local MovPenality = 1
		local UnitTech = GetUnitTech(unit)
		if DM.GetProperty(id, 'IsMoving') == 0 then MovPenality = 1.5 end 
		return math.ceil((AttackAdd + 50 + AttackDexterity + Attackbuff + AttackTech + WeaponSkill + WeaponMastery * 1.25) * AttackMod * MovPenality)
	elseif unit then 
		local level = GetUnitLevel(unit) or 1
		return math.ceil(70 + level * 5)
	end
end

function GetDamageRating(unit)
	local id = unit:GetEntityId()
	if unit and DM.GetProperty(id, 'PrestigeClassPromoted') == 1 then
		local id = unit:GetEntityId() 
		local StanceMod = GetStanceModifier(unit, 'Damage_Mod')
		local DamagePuissance = DM.GetProperty(id, 'Puissance') / 25
		local Stamina = DM.GetProperty(id, 'Stamina')
		local corrector = 1.26
		local WeaponSkill, WeaponMastery = 0, 0
		if DM.GetProperty(id, 'Weapon Skill') then  WeaponSkill = GetSkillCurrent(id, 'Weapon Skill') end
		if DM.GetProperty(id, 'Weapon Mastery') then  WeaponMastery = GetSkillCurrent(id, 'Weapon Mastery') end
		return (DamagePuissance + WeaponSkill / 200 + WeaponMastery / 100) * StanceMod - corrector
	elseif unit then 
		local level = GetUnitLevel(unit) or 1
		return math.ceil(-1 + level/20)
	end
end

function GetRateOfFireRating(unit)
	local id = unit:GetEntityId() 
	local Stance = DM.GetProperty(id,'StanceState')
	local RofMod = GetStanceModifier(unit, 'RateOfFire_Mod', Stance)
	return RofMod
end

function GetUnitSkills(id)
	local unit = GetUnitById(id)
	local SkillsList = {}
	for _, Skill in Skills do
		if Skill.IsAvailable(unit) == true then
			table.insert(SkillsList, Skill.Name)
		end
	end
	return SkillsList
end

function GetSkillDescription(SkillName)
	for _, Skill in Skills do
		if SkillName == Skill.Name and Skill.Description then
			return Skill.Description()
		end
	end
	return ''
end

function GetUnitPowers(id)
	local unit = GetUnitById(id)
	local PowersList = {}
	for _, Power in Powers do
		if Power.IsAvailable(unit) == true then
			table.insert(PowersList, Power.Name())
		end
	end
	return PowersList
end

function GetUnitPower(id, PowerName)
	local unit = GetUnitById(id)
	for _, Power in Powers do
		if Power.Name() == PowerName and Power.IsAvailable(unit) == true then
			return Power
		end
	end
end

function GetSkillMax(id, skill)
	local Skill = 0
	for i,_ in Skills do
		if Skills[i].Name == skill then
			Skill = DM.GetProperty(id, Skills[i].FocusSkill)
		end
	end
	local int = DM.GetProperty(id, 'Intelligence')
	return math.floor(55 + int + Skill / 5)
end

function GetSkillCurrent(id, skill)
	local Skill = 0
	for i,_ in Skills do
		if Skills[i].Name == skill then
			Skill = DM.GetProperty(id, Skills[i].Name)
		end
	end
	local int = DM.GetProperty(id, 'Intelligence')
	local Xp = 0
	local SkillMax = 8
	if DM.GetProperty(id, skill) then
		Xp = DM.GetProperty(id, skill)
		SkillMax = GetSkillMax(id, skill) or 100
	end
	local trains = Xp / 150
	local Skillpoints = 0
	if trains <= 10 then
		Skillpoints = trains * 2
	elseif trains > 10 and trains <= 90 then
		Skillpoints = 20 + (trains - 10)
	elseif trains > 90 and trains <= 134 then
		Skillpoints = 100 + (trains - 90) * 0.5
	elseif trains > 134 then
		Skillpoints = 122 + (trains - 134) * 0.33
	end
	return math.floor(math.min((4 + int / 6 + Skill / 10) + Skillpoints, SkillMax)) or 0
end


function GetProperties(family, Unit)
	--[ getProperties('Health', UnitID) will return a table which each key starts with 'Health'
	---]
	Properties = {}
	for _,v in pairs(Unit) do
		sub = string.sub(v,1, string.len(family))
		if sub == family then
			key = string.sub(v, string.len(family)+1, -1)
			table.insert(Properties, v)
		end
	end
	return Properties
end

-- this function sort a table by using a bigger reference table
function SortTable(TableTobeSorted, TableRef)
	local TableSorted = {}
	for _, val in TableRef do
		if table.find(TableTobeSorted, val) then
			table.insert(TableSorted, val)
		end
	end
	return TableSorted
end


-- this function compare two table and generate a differentiate table for the keys and values. Unknown keys are set to 0
-- it's is used for generating progress bar before after
function GetDiffTable(TableOld, TableNew)
	local TableDiff = {}
	local ValuesOld = {}
	local ValuesNew = {}
	local Found = false
	for key, val in TableNew do
		for key2, val2 in TableOld do
		-- Same keys
			if key == key2 then
				Found = true
				TableDiff[key] = math.floor(val) - math.floor(val2)
				ValuesOld[key] = math.floor(val2)
				ValuesNew[key] = math.floor(val)
			end
		end
		-- Not found it so it's a new key
		if Found == false then
			TableDiff[key] = math.floor(val)
			ValuesOld[key] = 0
			ValuesNew[key] = math.floor(val)
		end
		Found = false
	end
	for key, val in TableOld do
		for key2, val2 in TableDiff do
			if key == key2 then
				Found = true
			end
		end
		-- Not found it so it's nomore a key
		if Found == false then
			TableDiff[key] = - math.floor(val)
			ValuesNew[key] = 0
			ValuesOld[key] = math.floor(val)
		end
		Found = false	
	end
	return TableDiff, ValuesOld, ValuesNew
end

-- Theses fonctions extract keys or values from table
function ExtractKeys(Table)
	local KeyList = {}
	for key,_ in Table do
		table.insert(KeyList, key)
	end
	return KeyList
end

function ExtractValues(Table)
	local ValueList = {}
	for _, Value in Table do
		table.insert(ValueList, Value)
	end
	return ValueList
end

-- This function return the key from the rank position from a 2 dimension table
function ExtractKeyFromRank(Table, Number)
	local TempList =  ExtractKeys(Table)
	return TempList[Number]
end

-- This function return the key's rank position from a 2 dimension table
function ExtractRankFromKey(Table, Key)
	local TempList = ExtractKeys(Table)
	for i, k in TempList do
		if k == Key then
			return i
		end
	end
end

-- This function test weaponmodifiers on a unit for every templates and return the list of compatible templates
function GetAvailableWeaponTemplate(id, WeaponTemplate, WeaponCategory)
	local AvailableTemplateList = {}
	for template, _ in WeaponTemplate do
		if template != 'Current upgrade' then
			local AvailableTest = true
			for modifier, _ in WeaponTemplate[template] do
				if WeaponModifiers.Modifiers[WeaponModifiers.GetInternalKey(modifier)].IsAvailable(id, WeaponCategory) == false then
					AvailableTest = false
				end
			end
			if AvailableTest == true then table.insert(AvailableTemplateList, template) end
		end
	end
	return AvailableTemplateList
end

function GetAvailableWeaponTemplateFull(id, WeaponTemplate, WeaponCategory)
	local AvailableTemplateList = {}
	for template, _ in WeaponTemplate do
		if template != 'Current upgrade' then
			local AvailableTest = true
			for modifier, _ in WeaponTemplate[template] do
				if WeaponModifiers.Modifiers[WeaponModifiers.GetInternalKey(modifier)].IsAvailable(id, WeaponCategory) == false then
					AvailableTest = false
				end
			end
			if AvailableTest == true then 
				AvailableTemplateList[template] = {}
				for key, values in WeaponTemplate[template] do
					AvailableTemplateList[template][key] = WeaponTemplate[template][key]
				end
			end
		end 
	end
	return AvailableTemplateList
end

function GetAvailableArmorTemplate(id, ArmorTemplate)
	local AvailableTemplateList = {}
	for template, _ in ArmorTemplate do
		if template != 'Current upgrade' then
			local AvailableTest = true
			for modifier, _ in ArmorTemplate[template] do
				if ArmorModifiers.Modifiers[ArmorModifiers.GetInternalKey(modifier)].IsAvailable(id) == false then
					AvailableTest = false
				end
			end
			if AvailableTest == true then 
				AvailableTemplateList[template] = {}
				for key, values in ArmorTemplate[template] do
					AvailableTemplateList[template][key] = ArmorTemplate[template][key]
				end
			end
		end
	end
	return AvailableTemplateList
end

function GetTemplateCost(id, TemplateName, TemplateTable, _PrestigeClass)
	local unit = GetUnitById(id)
	local UnitCatId = unit:GetUnitId()
	local BaseClass = DM.GetProperty(id, 'BaseClass', 'Fighter')
	local PrestigeClass = DM.GetProperty(id, 'PrestigeClass')
	if PrestigeClass == 'NeedPromote' then PrestigeClass = _PrestigeClass end
	local Cost = 0
	for _,modifier in ArmorModifiers.RefView do
		if TemplateTable[UnitCatId][BaseClass][PrestigeClass][TemplateName]['Upgrade_Armor_'..modifier..'_Level'] then
			local modifierlevel = TemplateTable[UnitCatId][BaseClass][PrestigeClass][TemplateName]['Upgrade_Armor_'..modifier..'_Level'] 
			Cost = Cost + ArmorModifiers.Modifiers[ArmorModifiers.GetInternalKey(modifier)].Cost(id) * modifierlevel
		end
	end
	for _,modifier in WeaponModifiers.RefView do
		for WeaponIndex = 1, 30 do
			if TemplateTable[UnitCatId][BaseClass][PrestigeClass][TemplateName]['Upgrade_Weapon_'..WeaponIndex..'_'..modifier..'_Level'] then
				local modifierlevel = TemplateTable[UnitCatId][BaseClass][PrestigeClass][TemplateName]['Upgrade_Weapon_'..WeaponIndex..'_'..modifier..'_Level'] 
				Cost = Cost + WeaponModifiers.Modifiers[WeaponModifiers.GetInternalKey(modifier)].Cost(id) * modifierlevel
			end
		end
	end
	return Cost
end

function CanEquip(unit, _unit, TemplateName, TemplateTable)
	local MaxSpace = GetAvailableMaxSpace(unit)
	local UnitCatId = unit:GetUnitId()
	local _UnitCatId = _unit:GetUnitId()
	local id = unit:GetEntityId()
	if DM.GetProperty(id, 'PrestigeClassPromoted') == 1 then
		local _id = _unit:GetEntityId()
		local BaseClass = DM.GetProperty(_id, 'BaseClass')
		local PrestigeClass = DM.GetProperty(_id, 'PrestigeClass')
		
		local _Space = 0
		for _,modifier in ArmorModifiers.RefView do
			if TemplateTable[_UnitCatId][BaseClass][PrestigeClass][TemplateName]['Upgrade_Armor_'..modifier..'_Level']  then
				if ArmorModifiers.Modifiers[ArmorModifiers.GetInternalKey(modifier)].IsAvailable(id) == false then return false end
				local modifierlevel = TemplateTable[_UnitCatId][BaseClass][PrestigeClass][TemplateName]['Upgrade_Armor_'..modifier..'_Level'] 
				_Space = _Space + ArmorModifiers.Modifiers[ArmorModifiers.GetInternalKey(modifier)].Space * modifierlevel
			end
		end
		for _,modifier in WeaponModifiers.RefView do
			for WeaponIndex = 1, 30 do
				if TemplateTable[_UnitCatId][BaseClass][PrestigeClass][TemplateName]['Upgrade_Weapon_'..WeaponIndex..'_'..modifier..'_Level'] then
					if WeaponModifiers.Modifiers[WeaponModifiers.GetInternalKey(modifier)].IsAvailable(id) == false then return false end
					local modifierlevel = TemplateTable[_UnitCatId][BaseClass][PrestigeClass][TemplateName]['Upgrade_Weapon_'..WeaponIndex..'_'..modifier..'_Level'] 
					_Space = _Space + WeaponModifiers.Modifiers[WeaponModifiers.GetInternalKey(modifier)].Space * modifierlevel
				end
			end
		end
		return (_Space <= MaxSpace)
	else
		return false
	end
end


function AddTemplate(TemplatesBp, UnitGeneralTemplates)
	for _,model in TemplatesBp.Models do
		for _,BaseC in TemplatesBp.BaseClasses do
			for _,PrestC in TemplatesBp.PrestigeClass do
				for Modifier, value in TemplatesBp.ArmorModifiers do
					if not UnitGeneralTemplates[model] then
						UnitGeneralTemplates[model] = {}
					end
					if not UnitGeneralTemplates[model][BaseC] then
						UnitGeneralTemplates[model][BaseC] = {}
					end
					if not UnitGeneralTemplates[model][BaseC][PrestC] then
						UnitGeneralTemplates[model][BaseC][PrestC] = {}
					end
					if not UnitGeneralTemplates[model][BaseC][PrestC][TemplatesBp.TemplateName] then
						UnitGeneralTemplates[model][BaseC][PrestC][TemplatesBp.TemplateName] = {}
					end
					local ModifierName = ArmorModifiers.Modifiers[Modifier].Name
					if not UnitGeneralTemplates[model][BaseC][PrestC][TemplatesBp.TemplateName]['Upgrade_Armor_'..ModifierName..'_Level'] then
						UnitGeneralTemplates[model][BaseC][PrestC][TemplatesBp.TemplateName]['Upgrade_Armor_'..ModifierName..'_Level'] = value
					end
				end
				for Modifier, value in TemplatesBp.WeaponModifiers do
					if not UnitGeneralTemplates[model] then
						UnitGeneralTemplates[model] = {}
					end
					if not UnitGeneralTemplates[model][BaseC] then
						UnitGeneralTemplates[model][BaseC] = {}
					end
					if not UnitGeneralTemplates[model][BaseC][PrestC] then
						UnitGeneralTemplates[model][BaseC][PrestC] = {}
					end
					if not UnitGeneralTemplates[model][BaseC][PrestC][TemplatesBp.TemplateName] then
						UnitGeneralTemplates[model][BaseC][PrestC][TemplatesBp.TemplateName] = {}
					end
					local wi = TemplatesBp.WeaponIndex
					local ModifierName = WeaponModifiers.Modifiers[Modifier].Name
					if not UnitGeneralTemplates[model][BaseC][PrestC][TemplatesBp.TemplateName]['Upgrade_Weapon_'..wi..'_'..ModifierName..'_Level'] then
						UnitGeneralTemplates[model][BaseC][PrestC][TemplatesBp.TemplateName]['Upgrade_Weapon_'..wi..'_'..ModifierName..'_Level'] = value
					end
				end
				UnitGeneralTemplates[model][BaseC][PrestC][TemplatesBp.TemplateName].Puissance =  TemplatesBp.Puissance
				UnitGeneralTemplates[model][BaseC][PrestC][TemplatesBp.TemplateName].Dexterity = TemplatesBp.Dexterity
				UnitGeneralTemplates[model][BaseC][PrestC][TemplatesBp.TemplateName].Hull = TemplatesBp.Hull
				UnitGeneralTemplates[model][BaseC][PrestC][TemplatesBp.TemplateName].Intelligence = TemplatesBp.Intelligence
				UnitGeneralTemplates[model][BaseC][PrestC][TemplatesBp.TemplateName].Energy = TemplatesBp.Energy
			end
		end
	end
	return UnitGeneralTemplates
end



function format_num(amount, decimal, prefix, neg_prefix)
	local str_amount,  formatted, famount, remain
	decimal = decimal or 2  -- default 2 decimal places
	neg_prefix = neg_prefix or "-" -- default negative sign
	famount = math.abs(round(amount,decimal))
	famount = math.floor(famount)
	remain = round(math.abs(amount) - famount, decimal)
	-- comma to separate the thousands
	formatted = comma_value(famount)
	-- attach the decimal portion
	if (decimal > 0) then
		remain = string.sub(tostring(remain),3)
		formatted = formatted .. "." .. remain ..
		string.rep("0", decimal - string.len(remain))
	end
	-- attach prefix string e.g '$' 
	Formatted = (prefix or "") .. formatted 
	-- if value is negative then format accordingly
	if (amount<0) then
		if (neg_prefix=="()") then
			formatted = "("..formatted ..")"
		else
			formatted = neg_prefix .. formatted 
		end
	end
	return formatted
end

function round(val, decimal)
	if (decimal) then
		return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
	else
		return math.floor(val+0.5)
	end
end

function comma_value(amount)
	local formatted = amount
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

-- GetDistanceToTarget = function(self)
	-- local tpos = self:GetCurrentTargetPosition()
	-- local mpos = self:GetPosition()
	-- local dist = VDist2(mpos[1], mpos[3], tpos[1], tpos[3])
	-- return dist
-- end