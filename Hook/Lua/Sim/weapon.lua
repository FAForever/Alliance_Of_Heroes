----------------------------
-- Alliance of Heroes MOD --
-- Franck83 2018------------
----------------------------

local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local ProjId = import(ModPath..'Modules/ProjectilesId.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local BCbp = import(ModPath..'Modules/ClassDefinitions.lua').BaseClassBlueprint

-- Destructive Hooking ----------------------------------------------------------------------------------------------------------------------------------------
local OldWeapon = Weapon 
Weapon = Class(OldWeapon) {
	OldGetDamageTable = Weapon.GetDamageTable,
	GetDamageTable = function(self)
		local wpbp = self:GetBlueprint()
		local weaponBlueprint = self:GetBlueprint()
		local id = self.unit:GetEntityId()
		local Promoted = DM.GetProperty(id,'PrestigeClassPromoted')
		-- Damage class mod
		local DamageClassMod = 0
		local BaseClass =  DM.GetProperty(id, 'BaseClass', 'Fighter')
		if Promoted then
			if DM.GetProperty(id, 'Stamina') > 5 then
				DamageClassMod = BCbp[BaseClass]['DamagePromotionModifier']
			end
		end
		--
		local damageTable = {}
		damageTable.Army = self.unit:GetArmy()
		damageTable.InitialDamageAmount = weaponBlueprint.InitialDamage or 0
		damageTable.DamType = weaponBlueprint.DamageType
		damageTable.DamageType = ProjId.Register(damageTable) -- Register projectile with an id.
		damageTable.ShieldDamageMod = 1
		damageTable.DamageFriendly = weaponBlueprint.DamageFriendly
		if damageTable.DamageFriendly == nil then
			damageTable.DamageFriendly = true
		end
		damageTable.CollideFriendly = weaponBlueprint.CollideFriendly or false
		damageTable.DoTTime = weaponBlueprint.DoTTime
		damageTable.DoTPulses = weaponBlueprint.DoTPulses
		damageTable.MetaImpactAmount = weaponBlueprint.MetaImpactAmount
		damageTable.MetaImpactRadius = weaponBlueprint.MetaImpactRadius
		damageTable.ArtilleryShieldBlocks = weaponBlueprint.ArtilleryShieldBlocks
		damageTable.Buffs = {}
		if weaponBlueprint.Buffs ~= nil then
			for k, v in weaponBlueprint.Buffs do
				if not self.DisabledBuffs[v.BuffType] then
					damageTable.Buffs[k] = v
				end
				
			end   
		end
		local WeaponIndexList, WeaponCategoriesList = CF.GetWeaponIndexList(self.unit)
		local bp = self.unit:GetBlueprint()
		local CurrentWeaponIndex = 0
		for i, wi in WeaponIndexList do
			if  bp.Weapon[WeaponIndexList[i]].Label == weaponBlueprint.Label then
				CurrentWeaponIndex = WeaponIndexList[i]
			end
		end
			local DamageUpgradeMod = 0
		damageTable.DamageSpecialization = {}
		damageTable.InstigatorId = id
		damageTable.DamageRadius = (weaponBlueprint.DamageRadius or 0)
		if Promoted == 1 then 
			damageTable.DamageRadius = damageTable.DamageRadius + (DM.GetProperty(id, 'Upgrade_Weapon_'..CurrentWeaponIndex..'_Damage Area of Effect', 0) or 0)
			if DM.GetProperty(id, 'Upgrade_Weapon_'..CurrentWeaponIndex..'_Damage to All Units') then
				DamageUpgradeMod = ((DM.GetProperty(id, 'Upgrade_Weapon_'..CurrentWeaponIndex..'_Damage to All Units')) / 100)
			end
			local DamageSpelist = {'Damage to Experimentals', 'Damage to SubCommanders', 'Damage to High Aircrafts', 'Damage to Ground Aircrafts', 'Damage to Defenses', 'Damage to Navals', 'Damage to Bots', 'Damage to Tanks', 'Damage to Structures'}
			for _,DamageSpe in DamageSpelist do
				damageTable.DamageSpecialization[DamageSpe] =  DM.GetProperty(id, 'Upgrade_Weapon_'..CurrentWeaponIndex..'_'..DamageSpe, 0) + (DM.GetProperty(id, 'Tech_'..DamageSpe, 0) * 100)
			end
			if DM.GetProperty(id, 'ExecuteWeaponBuffOnTarget') then -- Loading weapon buff order on projectile
				damageTable.ExecuteWeaponBuff = DM.GetProperty(id, 'ExecuteWeaponBuffOnTarget')
				DM.SetProperty(id, 'ExecuteWeaponBuffOnTarget', nil)
			else
				damageTable.ExecuteWeaponBuff = nil			
			end
			damageTable.ArmorPiercing = (DM.GetProperty(id, 'Upgrade_Weapon_'..CurrentWeaponIndex..'_Armor Piercing') or 0) + DM.GetProperty(id, 'Tech_AP', 0)
			local distfromtarget = DM.GetProperty(id, 'DistanceFromTarget'..'_Weapon_'..CurrentWeaponIndex) or 'No Target'
			local AttackRatingUpgrade = DM.GetProperty(id, 'Upgrade_Weapon_'..CurrentWeaponIndex..'_Attack Rating') or 0
			local ATR_Tech = DM.GetProperty(id, 'Tech_Accuracy', 0)
			if distfromtarget != 'No Target' then
				local DamageRadius =  damageTable.DamageRadius
				damageTable.AttackRating  = (CF.GetAttackRating(self.unit) + AttackRatingUpgrade + ATR_Tech) * math.pow(0.75, distfromtarget / 10) * (DamageRadius * 2 + 1) * (1 + ((self.DamageMod or 0) + weaponBlueprint.Damage)/4000)
			else
				damageTable.AttackRating = CF.GetAttackRating(self.unit) + AttackRatingUpgrade
			end
		else
			local ATR_Tech = DM.GetProperty(id, 'Tech_Accuracy', 0)
			damageTable.AttackRating = CF.GetAttackRating(self.unit) + ATR_Tech
		end	
		local DamageAdd,_ = AoHBuff.GetBuffValue(self.unit, 'Damage', 'ALL') / 100
		-- local DamageHallofFameBonus = CF.Calculate_HallofFameBonus(DM.GetProperty(damageTable.Army, 'AI_'..'Fighter'..'_'..CF.GetUnitLayerTypeHero(self.unit)), 'Fighter', 0) / 100
		local Tech_Dam = DM.GetProperty(id, 'Tech_Damage', 0) / 100
		damageTable.DamageAmount = ((self.DamageMod or 0) + weaponBlueprint.Damage) * (1 + CF.GetDamageRating(self.unit) + DamageUpgradeMod + DamageClassMod + DamageAdd + Tech_Dam)
		damageTable.WeaponIndex = CurrentWeaponIndex
		damageTable.Label = weaponBlueprint.Label
		damageTable.WeaponCategory = weaponBlueprint.WeaponCategory
		damageTable.DisplayName = weaponBlueprint.DisplayName
		damageTable.AoHBuffs = {}
		damageTable.WeaponNature = 'Projectile'
		damageTable.ConversionToHealth = DM.GetProperty(id, 'Upgrade_Weapon_'..CurrentWeaponIndex..'_Conversion To Health', 0) or 0
		damageTable.ConversionToEnergy = DM.GetProperty(id, 'Upgrade_Weapon_'..CurrentWeaponIndex..'_Conversion To Energy', 0)  or 0
		return damageTable
	end,
	
	CreateProjectileForWeapon = function(self, bone)
		local wpbp = self:GetBlueprint()
		if wpbp.WeaponCategory == 'Direct Fire' or wpbp.WeaponCategory == 'Direct Fire Naval' or wpbp.WeaponCategory == 'Direct Fire Experimental' or wpbp.WeaponCategory == 'Anti Air' then
			if DM.GetProperty(self.unit:GetEntityId(), 'ExecuteStrikeAtBone') then
				local PowerName = DM.GetProperty(self.unit:GetEntityId(), 'ExecuteStrikeAtBone')
				local StrikeData = self.unit.GetStrikeData(self.unit, PowerName) -- loading power strike data
				if StrikeData.ProjectileBp != nil then
					self:ChangeProjectileBlueprint(StrikeData.ProjectileBp)
					self.FxTrails = StrikeData.FxTrails
					self.FxTrailScale = StrikeData.FxTrailScale
				end
				local proj = self:CreateProjectile(bone)
				local damageTable = self:GetDamageTable()
				damageTable.InitialDamageAmount = StrikeData.InitialDamageAmount
				damageTable.DamageAmount = StrikeData.DamageAmount
				damageTable.ShieldDamageMod = StrikeData.ShieldDamageMod
				damageTable.DamageRadius = StrikeData.DamageRadius 
				damageTable.DamageFriendly = StrikeData.DamageFriendly
				damageTable.CollideFriendly = StrikeData.CollideFriendly
				damageTable.DoTTime = StrikeData.DoTTime
				damageTable.DoTPulses = StrikeData.DoTPulses
				damageTable.DamType = StrikeData.DamType
				damageTable.Instigator = StrikeData.Instigator
				if proj and not proj:BeenDestroyed() then
					proj:PassDamageData(damageTable)
					local bp = self:GetBlueprint()
					if bp.NukeOuterRingDamage and bp.NukeOuterRingRadius and bp.NukeOuterRingTicks and bp.NukeOuterRingTotalTime and bp.NukeInnerRingDamage and bp.NukeInnerRingRadius and bp.NukeInnerRingTicks and bp.NukeInnerRingTotalTime then
						proj.InnerRing = NukeDamage()
						proj.InnerRing:OnCreate(bp.NukeInnerRingDamage, bp.NukeInnerRingRadius, bp.NukeInnerRingTicks, bp.NukeInnerRingTotalTime)
						proj.OuterRing = NukeDamage()
						proj.OuterRing:OnCreate(bp.NukeOuterRingDamage, bp.NukeOuterRingRadius, bp.NukeOuterRingTicks, bp.NukeOuterRingTotalTime)
						proj.Launcher = self.unit
						proj.Army = self.unit:GetArmy()
						proj.Brain = self.unit:GetAIBrain()
					end
				end
				self:ChangeProjectileBlueprint(wpbp.ProjectileId)
				DM.SetProperty(self.unit:GetEntityId(), 'ExecuteStrikeAtBone', nil)
				return proj
			else
				local proj = self:CreateProjectile(bone)
				local damageTable = self:GetDamageTable()
				if proj and not proj:BeenDestroyed() then
					proj:PassDamageData(damageTable)
					local bp = self:GetBlueprint()
					if bp.NukeOuterRingDamage and bp.NukeOuterRingRadius and bp.NukeOuterRingTicks and bp.NukeOuterRingTotalTime and
						bp.NukeInnerRingDamage and bp.NukeInnerRingRadius and bp.NukeInnerRingTicks and bp.NukeInnerRingTotalTime then
						proj.InnerRing = NukeDamage()
						proj.InnerRing:OnCreate(bp.NukeInnerRingDamage, bp.NukeInnerRingRadius, bp.NukeInnerRingTicks, bp.NukeInnerRingTotalTime)
						proj.OuterRing = NukeDamage()
						proj.OuterRing:OnCreate(bp.NukeOuterRingDamage, bp.NukeOuterRingRadius, bp.NukeOuterRingTicks, bp.NukeOuterRingTotalTime)

						-- Need to store these three for later, in case the missile lands after the launcher dies
						proj.Launcher = self.unit
						proj.Army = self.unit:GetArmy()
						proj.Brain = self.unit:GetAIBrain()
					end
				end
				return proj
			end
		else
			local proj = self:CreateProjectile(bone)
			local damageTable = self:GetDamageTable()
			if proj and not proj:BeenDestroyed() then
				proj:PassDamageData(damageTable)
				local bp = self:GetBlueprint()

				if bp.NukeOuterRingDamage and bp.NukeOuterRingRadius and bp.NukeOuterRingTicks and bp.NukeOuterRingTotalTime and
					bp.NukeInnerRingDamage and bp.NukeInnerRingRadius and bp.NukeInnerRingTicks and bp.NukeInnerRingTotalTime then
					proj.InnerRing = NukeDamage()
					proj.InnerRing:OnCreate(bp.NukeInnerRingDamage, bp.NukeInnerRingRadius, bp.NukeInnerRingTicks, bp.NukeInnerRingTotalTime)
					proj.OuterRing = NukeDamage()
					proj.OuterRing:OnCreate(bp.NukeOuterRingDamage, bp.NukeOuterRingRadius, bp.NukeOuterRingTicks, bp.NukeOuterRingTotalTime)

					-- Need to store these three for later, in case the missile lands after the launcher dies
					proj.Launcher = self.unit
					proj.Army = self.unit:GetArmy()
					proj.Brain = self.unit:GetAIBrain()
				end
			end
			return proj
		end
    end,
}
---------------------------------------------------------------------------------------------------------------------------------------------------------