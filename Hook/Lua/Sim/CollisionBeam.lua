------------------------
-- Alliance of Heroes --
-- Franck83 - 2018    --
------------------------

local ModPath = '/mods/Alliance_Of_Heroes/'
local ProjId = import(ModPath..'Modules/ProjectilesId.lua')
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')

local oldCollisionBeam = CollisionBeam
CollisionBeam = Class(oldCollisionBeam) {
	oldCreateBeamEffects = CollisionBeam.CreateBeamEffects,
    CreateBeamEffects = function(self)
		local id = self.unit:GetEntityId()
		local army = self:GetArmy()
		local target = self.Weapon:GetCurrentTarget()
		local weaponBlueprint = self.Weapon:GetBlueprint()
		local WeaponIndexList, WeaponCategoriesList = CF.GetWeaponIndexList(self.unit)
		local bp = self.unit:GetBlueprint()
		local CurrentWeaponIndex = 0
		for i, wi in WeaponIndexList do
			if  bp.Weapon[WeaponIndexList[i]].Label == weaponBlueprint.Label then
				CurrentWeaponIndex = WeaponIndexList[i]
			end
		end
		local BaseClass =  DM.GetProperty(id, 'BaseClass', 'Fighter')
		local PrestigeClass =  DM.GetProperty(id, 'PrestigeClass', 'Elite')
		local ColdBeamDamMod = 1
		self.DamageTable = {}
		self.DamageTable.Categories = CF.GetUnitTypes(self.unit)
		self.DamageTable.WeaponIndex = CurrentWeaponIndex
		local DamageUpgradeMod = 0
		self.DamageTable.InstigatorId = id
		DamageUpgradeMod = ((DM.GetProperty(id, 'Upgrade_Weapon_'..CurrentWeaponIndex..'_Damage to All Units', 0)) / 100) -- Global Damage buff will hit shields but not spec ones.
		self.DamageTable.DamageSpecialization = {}
		local DamageSpelist = {'Damage to Experimentals', 'Damage to SubCommanders', 'Damage to High Aircrafts', 'Damage to Ground Aircrafts', 'Damage to Defenses', 'Damage to Navals', 'Damage to Bots', 'Damage to Tanks', 'Damage to Structures'}
		for _,DamageSpe in DamageSpelist do
			self.DamageTable.DamageSpecialization[DamageSpe] =  DM.GetProperty(id, 'Upgrade_Weapon_'..CurrentWeaponIndex..'_'..DamageSpe, 0) + (DM.GetProperty(id, 'Tech_'..DamageSpe, 0) * 100)
		end
		-- local DamageHallofFameBonus = CF.Calculate_HallofFameBonus(DM.GetProperty(army, 'AI_'..'Fighter'..'_'..CF.GetUnitLayerTypeHero(self.unit)), 'Fighter', 0) / 100
		self.DamageTable.DamageRadius = weaponBlueprint.DamageRadius + (DM.GetProperty(id, 'Upgrade_Weapon_'..CurrentWeaponIndex..'_Damage Area of Effect', 0) or 0)
		self.DamageTable.DamageAmount = weaponBlueprint.Damage * (1 + DamageUpgradeMod) + DM.GetProperty(id, 'Tech_Ammunitions High Velocity', 0)
		self.DamageTable.AttackRating = CF.GetAttackRating(self.unit)
		self.DamageTable.Label = weaponBlueprint.Label
		self.DamageTable.WeaponCategory = weaponBlueprint.WeaponCategory
		self.DamageTable.DisplayName = weaponBlueprint.DisplayName
		self.DamageTable.DamType = weaponBlueprint.DamageType
		self.DamageTable.ArmorPiercing = (DM.GetProperty(id, 'Upgrade_Weapon_'..CurrentWeaponIndex..'_Armor Piercing') or 0) + DM.GetProperty(id, 'Tech_'..'Armor Piercing', 0)
		self.DamageTable.ConversionToHealth = DM.GetProperty(id, 'Upgrade_Weapon_'..CurrentWeaponIndex..'_Conversion To Health', 0) or 0
		self.DamageTable.ConversionToEnergy = DM.GetProperty(id, 'Upgrade_Weapon_'..CurrentWeaponIndex..'_Conversion To Energy', 0)  or 0
		if DM.GetProperty(id, 'ExecuteWeaponBuffOnTarget') then -- Loading weapon buff order on projectile. Will execute function on an individual power script.
			self.DamageTable.ExecuteWeaponBuff = DM.GetProperty(id, 'ExecuteWeaponBuffOnTarget')
			DM.SetProperty(id, 'ExecuteWeaponBuffOnTarget', nil)
		else
			self.DamageTable.ExecuteWeaponBuff = nil			
		end
		self.DamageTable.Dodge = false
		self.DamageTable.DamageFriendly = weaponBlueprint.DamageFriendly
		self.DamageTable.CollideFriendly = weaponBlueprint.CollideFriendly
		self.DamageTable.DoTTime = weaponBlueprint.DoTTime
		self.DamageTable.DoTPulses = weaponBlueprint.DoTPulses
		self.DamageTable.Buffs = weaponBlueprint.Buffs
		self.DamageTable.WeaponNature = 'Beam'
		self.CollideFriendly = self.DamageData.CollideFriendly == true
		self.DamageTable.AttackRating = 0 -- Since beam is not refreshed, we need to calculate cumul attack rating on dotakedamage function in unit.lua.
		self.DamageTable.DamageType = ProjId.Register(self.DamageTable) -- Register projectile with an id.
		self:oldCreateBeamEffects(self)
    end
	}