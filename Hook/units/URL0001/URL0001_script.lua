-----------------------------------------------------------------------------------------
-- File     :  /cdimage/units/URL0001/URL0001_script.lua
-- Author(s):  John Comes, David Tomandl, Jessica St. Croix, Gordon Duclos, Andres Mendez
-- Summary  :  Cybran Commander Unit Script
-- Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------------------

local ACUUnit = import('/lua/defaultunits.lua').ACUUnit
local CCommandUnit = import('/lua/cybranunits.lua').CCommandUnit
local CWeapons = import('/lua/cybranweapons.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')
local CCannonMolecularWeapon = CWeapons.CCannonMolecularWeapon
local DeathNukeWeapon = import('/lua/sim/defaultweapons.lua').DeathNukeWeapon
local CDFHeavyMicrowaveLaserGeneratorCom = CWeapons.CDFHeavyMicrowaveLaserGeneratorCom
local CDFOverchargeWeapon = CWeapons.CDFOverchargeWeapon
local CANTorpedoLauncherWeapon = CWeapons.CANTorpedoLauncherWeapon
local Entity = import('/lua/sim/Entity.lua').Entity
-- Alliance of Heroes
local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local HeavyColdBeam = CWeapons.HeavyColdBeam
local SLandUnit = import('/lua/seraphimunits.lua').SLandUnit
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')
local CollisionBeam = import('/lua/sim/CollisionBeam.lua').CollisionBeam
local SCCollisionBeam = import('/lua/defaultcollisionbeams.lua').SCCollisionBeam
local ProjId = import(ModPath..'Modules/ProjectilesId.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')





local PhasonCollisionBeam = Class(SCCollisionBeam) {

    FxBeamStartPoint = {
        '/Effects/Emitters/seraphim_experimental_phasonproj_muzzle_flash_01_emit.bp',
        '/Effects/Emitters/seraphim_experimental_phasonproj_muzzle_flash_02_emit.bp',
        '/Effects/Emitters/seraphim_experimental_phasonproj_muzzle_flash_03_emit.bp',
        '/Effects/Emitters/seraphim_experimental_phasonproj_muzzle_flash_04_emit.bp',
        '/Effects/Emitters/seraphim_experimental_phasonproj_muzzle_flash_05_emit.bp',
        '/Effects/Emitters/seraphim_experimental_phasonproj_muzzle_flash_06_emit.bp',
        '/units/DSLK004/effects/seraphim_electricity_emit.bp'
    },
    FxBeam = {
        '/units/DSLK004/effects/seraphim_lightning_beam_01_emit.bp',
    },
    FxBeamEndPoint = {
        '/units/DSLK004/effects/seraphim_lightning_hit_01_emit.bp',
        '/units/DSLK004/effects/seraphim_lightning_hit_02_emit.bp',
        '/units/DSLK004/effects/seraphim_lightning_hit_03_emit.bp',
        '/units/DSLK004/effects/seraphim_lightning_hit_04_emit.bp',
    },


    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 0.2,
    SplatTexture = 'czar_mark01_albedo',
    ScorchSplatDropTime = 0.25,

    OnImpact = function(self, impactType, targetEntity)
        CollisionBeam.OnImpact(self, impactType, targetEntity)
    end,

    OnDisable = function(self)
        CollisionBeam.OnDisable(self)
        KillThread(self.Scorching)
        self.Scorching = nil
    end,

    PassTarget = function(self, entity, position)
        self.TargetEntity = entity
        self.TargetPosition = position
    end,

    PassOrigin = function(self, originUnit, originBone)
        self.OriginUnit = originUnit
        self.OriginBone = originBone
    end,

    DoDamage = function(self, instigator, damageData, targetEntity)

        if self.TargetEntity then
            targetEntity = self.TargetEntity
        end

        local damage = damageData.DamageAmount or 0

        if self.Weapon.DamageModifiers then
            local dmgmod = 1
            for k, v in self.Weapon.DamageModifiers do
                dmgmod = v * dmgmod
            end
            damage = damage * dmgmod
        end

        if damage <= 0 then return end

        if instigator then
            local radius = damageData.DamageRadius
            local BeamEndPos = self:GetPosition(1)
            if targetEntity and targetEntity.GetPosition then
                BeamEndPos = targetEntity:GetPosition()
            end


            if radius and radius > 0 then
                if not damageData.DoTTime or damageData.DoTTime <= 0 then
                    DamageArea(instigator, BeamEndPos, radius, damage, damageData.DamageType or 'Normal', damageData.DamageFriendly or false)
                else
                    ForkThread(DefaultDamage.AreaDoTThread, instigator, BeamEndPos, damageData.DoTPulses or 1, (damageData.DoTTime / (damageData.DoTPulses or 1)), radius, damage, damageData.DamageType, damageData.DamageFriendly)
                end
            elseif targetEntity then
                if not damageData.DoTTime or damageData.DoTTime <= 0 then
                    Damage(instigator, self:GetPosition(), targetEntity, damage, damageData.DamageType)
                else
                    ForkThread(DefaultDamage.UnitDoTThread, instigator, targetEntity, damageData.DoTPulses or 1, (damageData.DoTTime / (damageData.DoTPulses or 1)), damage, damageData.DamageType, damageData.DamageFriendly)
                end
            else
                DamageArea(instigator, BeamEndPos, 0.25, damage, damageData.DamageType, damageData.DamageFriendly)
            end
        else
            LOG('*ERROR: THERE IS NO INSTIGATOR FOR DAMAGE ON THIS COLLISIONBEAM = ', repr(damageData))
        end
    end,

    CreateBeamEffects = function(self)
        -- Destructively overwriting this function to make it use AttachBeamEntityToEntity()
        local army = self:GetArmy()
        for k, y in self.FxBeamStartPoint do
            local fx = CreateAttachedEmitter(self, 0, army, y):ScaleEmitter(self.FxBeamStartPointScale)
            table.insert(self.BeamEffectsBag, fx)
            self.Trash:Add(fx)
        end
        for k, y in self.FxBeamEndPoint do
            local fx = CreateAttachedEmitter(self, 1, army, y):ScaleEmitter(self.FxBeamEndPointScale)
            table.insert(self.BeamEffectsBag, fx)
            self.Trash:Add(fx)
        end
        if table.getn(self.FxBeam) ~= 0 then

            local fxBeam
            local bp = self.FxBeam[Random(1, table.getn(self.FxBeam))]
            if self.TargetEntity then
                fxBeam = AttachBeamEntityToEntity(self.OriginUnit, self.OriginBone, self.TargetEntity, 0, army, bp)
            else
                fxBeam = CreateBeamEmitter(bp, army)
                AttachBeamToEntity(fxBeam, self, 0, army)
            end

            -- collide on start if it's a continuous beam
            local weaponBlueprint = self.Weapon:GetBlueprint()
            local bCollideOnStart = weaponBlueprint.BeamLifetime <= 0
            self:SetBeamFx(fxBeam, bCollideOnStart)

            table.insert(self.BeamEffectsBag, fxBeam)
            self.Trash:Add(fxBeam)
        else
            LOG('*ERROR: THERE IS NO BEAM EMITTER DEFINED FOR THIS COLLISION BEAM ', repr(self.FxBeam))
        end
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
    end,
}

local PhasonCollisionBeam2 = Class(PhasonCollisionBeam) {
    FxBeam = { '/units/DSLK004/effects/seraphim_lightning_beam_02_emit.bp', },
    TerrainImpactScale = 0.1,

    OnImpact = function(self, impactType, targetEntity)
        if impactType == 'Terrain' then
            if self.Scorching == nil then
                self.Scorching = self:ForkThread(self.ScorchThread)
            end
        elseif not impactType == 'Unit' then
            KillThread(self.Scorching)
            self.Scorching = nil
        end
        PhasonCollisionBeam.OnImpact(self, impactType, targetEntity)
    end,

    OnDisable = function(self)
        PhasonCollisionBeam.OnDisable(self)
        KillThread(self.Scorching)
        self.Scorching = nil
    end,

    ScorchThread = function(self)
        local army = self:GetArmy()
        local size = 1 + (Random() * 1.1)
        local CurrentPosition = self:GetPosition(1)
        local LastPosition = Vector(0,0,0)
        local skipCount = 1
        local Util = import('/lua/utilities.lua')

        while true do
            if Util.GetDistanceBetweenTwoVectors(CurrentPosition, LastPosition) > 0.25 or skipCount > 100 then
                CreateSplat(CurrentPosition, Util.GetRandomFloat(0,2*math.pi), self.SplatTexture, size, size, 100, 100, army)
                LastPosition = CurrentPosition
                skipCount = 1
            else
                skipCount = skipCount + self.ScorchSplatDropTime
            end

            WaitSeconds(self.ScorchSplatDropTime)
            size = 1 + (Random() * 1.1)
            CurrentPosition = self:GetPosition(1)
        end
    end,
}

local PhasonBeam = Class(DefaultBeamWeapon) {
    BeamType = PhasonCollisionBeam,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},
    FxUpackingChargeEffects = EffectTemplate.CMicrowaveLaserCharge01,
    FxUpackingChargeEffectScale = 0.2,

    PlayFxBeamStart = function(self, muzzle)
        local beam
        for k, v in self.Beams do
            if v.Muzzle == muzzle then
                beam = v.Beam
                break
            end
        end
        if beam and not beam:IsEnabled() then
            beam:PassOrigin(self.unit, muzzle)
            beam:PassTarget(self:GetCurrentTarget(), self:GetCurrentTargetPos())
        end
        return DefaultBeamWeapon.PlayFxBeamStart(self, muzzle)
    end,
}

URL0001 = Class(ACUUnit, CCommandUnit) {
    Weapons = {
        DeathWeapon = Class(DeathNukeWeapon) {},
        RightRipper = Class(CCannonMolecularWeapon) {},
        Torpedo = Class(CANTorpedoLauncherWeapon) {},
        MLG = Class(CDFHeavyMicrowaveLaserGeneratorCom) {
            DisabledFiringBones = {'Turret_Muzzle_03'},

            SetOnTransport = function(self, transportstate)
                CDFHeavyMicrowaveLaserGeneratorCom.SetOnTransport(self, transportstate)
                self:ForkThread(self.OnTransportWatch)
            end,

            OnTransportWatch = function(self)
                while self:GetOnTransport() do
                    self:PlayFxBeamEnd()
                    self:SetWeaponEnabled(false)
                    WaitSeconds(0.3)
                end
            end,
        },

        OverCharge = Class(CDFOverchargeWeapon) {},
        AutoOverCharge = Class(CDFOverchargeWeapon) {},
		-- Alliance of Heroes weapons
		ColdBeam = Class(HeavyColdBeam) {
			OnWeaponFired = function(self)
               	local id = self.unit:GetEntityId()
				DM.IncProperty(id, 'Stamina', -1)
				if DM.GetProperty(id, 'Stamina') < 5  then
					self:SetWeaponEnabled(false)
					if DM.GetProperty(id, 'ColdBeam'..'_AutoCast') == 1 then
						self:ForkThread(self.OnWeaponCapacitorRegen)
					end
				end
            end,
			OnWeaponCapacitorRegen = function(self)
				-- LOG('inc thread')
				local id = self.unit:GetEntityId()
				while DM.GetProperty(id, 'Stamina') <= 20 do
                    self:SetWeaponEnabled(false)
                    WaitSeconds(0.3)
                end
				self:SetWeaponEnabled(true)
			end,
			OnDisableWeapon = function(self)
                if self.unit:BeenDestroyed() then return end
				-- LOG('Disabling')
            end,
            SetOnTransport = function(self, transportstate)
                HeavyColdBeam.SetOnTransport(self, transportstate)
                self:ForkThread(self.OnTransportWatch)
            end,
            OnTransportWatch = function(self)
                while self:GetOnTransport() do
                    self:PlayFxBeamEnd()
                    self:SetWeaponEnabled(false)
                    WaitSeconds(0.3)
                end
            end,
        },
		PhasonBeamAir = Class(PhasonBeam) {},
		--
    },

    __init = function(self)
        ACUUnit.__init(self, 'RightRipper')
    end,

    -- Creation
    OnCreate = function(self)
        ACUUnit.OnCreate(self)
        self:SetCapturable(false)
        self:HideBone('Back_Upgrade', true)
        self:HideBone('Right_Upgrade', true)
        if self:GetBlueprint().General.BuildBones then
            self:SetupBuildBones()
        end
        -- Restrict what enhancements will enable later
        self:AddBuildRestriction(categories.CYBRAN * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER))
        
        local wepBp = self:GetBlueprint().Weapon
        self.normalRange = 22
        self.torpRange = 60
        for k, v in wepBp do
            if v.Label == 'RightRipper' then
                self.normalRange = v.MaxRadius
            elseif v.Label == 'Torpedo' then
                self.torpRange = v.MaxRadius
            end
        end
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        ACUUnit.OnStopBeingBuilt(self, builder, layer)
        self:SetWeaponEnabledByLabel('RightRipper', true)
        self:SetWeaponEnabledByLabel('MLG', false)
		self:SetWeaponEnabledByLabel('ColdBeam', false) -- Alliance of Heroes Weapon
		self:SetWeaponEnabledByLabel('PhasonBeamAir', false) 
        self:SetWeaponEnabledByLabel('Torpedo', false)
        self:SetMaintenanceConsumptionInactive()
        -- Block enhancement-based Intel functions until enhancements are built
        self:DisableUnitIntel('Enhancement', 'RadarStealth')
        self:DisableUnitIntel('Enhancement', 'SonarStealth')
        self:DisableUnitIntel('Enhancement', 'Cloak')
        self:DisableUnitIntel('Enhancement', 'Sonar')
        self:HideBone('Back_Upgrade', true)
        self:HideBone('Right_Upgrade', true)
        self:ForkThread(self.GiveInitialResources)
    end,

    OnStartBuild = function(self, unitBeingBuilt, order)
        ACUUnit.OnStartBuild(self, unitBeingBuilt, order)
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true
    end,

    -- Build/Upgrade
    CreateBuildEffects = function(self, unitBeingBuilt, order)
        EffectUtil.SpawnBuildBots(self, unitBeingBuilt, self.BuildEffectsBag)
        EffectUtil.CreateCybranBuildBeams(self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag)
    end,

    CreateEnhancement = function(self, enh)
        ACUUnit.CreateEnhancement(self, enh)
        if enh == 'Teleporter' then
            self:AddCommandCap('RULEUCC_Teleport')
        elseif enh == 'TeleporterRemove' then
            RemoveUnitEnhancement(self, 'Teleporter')
            RemoveUnitEnhancement(self, 'TeleporterRemove')
            self:RemoveCommandCap('RULEUCC_Teleport')
        elseif enh == 'StealthGenerator' then
            self:AddToggleCap('RULEUTC_CloakToggle')
            if self.IntelEffectsBag then
                EffectUtil.CleanupEffectBag(self, 'IntelEffectsBag')
                self.IntelEffectsBag = nil
            end
            self.CloakEnh = false
            self.StealthEnh = true
            self:EnableUnitIntel('Enhancement', 'RadarStealth')
            self:EnableUnitIntel('Enhancement', 'SonarStealth')
        elseif enh == 'StealthGeneratorRemove' then
            self:RemoveToggleCap('RULEUTC_CloakToggle')
            self:DisableUnitIntel('Enhancement', 'RadarStealth')
            self:DisableUnitIntel('Enhancement', 'SonarStealth')
            self.StealthEnh = false
            self.CloakEnh = false
            self.StealthFieldEffects = false
            self.CloakingEffects = false
        elseif enh == 'ResourceAllocation' then
            local bp = self:GetBlueprint().Enhancements[enh]
            local bpEcon = self:GetBlueprint().Economy
            if not bp then return end
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
        elseif enh == 'ResourceAllocationRemove' then
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
        elseif enh == 'CloakingGenerator' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            self.StealthEnh = false
            self.CloakEnh = true
            self:EnableUnitIntel('Enhancement', 'Cloak')
            if not Buffs['CybranACUCloakBonus'] then
               BuffBlueprint {
                    Name = 'CybranACUCloakBonus',
                    DisplayName = 'CybranACUCloakBonus',
                    BuffType = 'ACUCLOAKBONUS',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            if Buff.HasBuff(self, 'CybranACUCloakBonus') then
                Buff.RemoveBuff(self, 'CybranACUCloakBonus')
            end
            Buff.ApplyBuff(self, 'CybranACUCloakBonus')
        elseif enh == 'CloakingGeneratorRemove' then
            self:RemoveToggleCap('RULEUTC_CloakToggle')
            self:DisableUnitIntel('Enhancement', 'Cloak')
            self.CloakEnh = false
            if Buff.HasBuff(self, 'CybranACUCloakBonus') then
                Buff.RemoveBuff(self, 'CybranACUCloakBonus')
            end
        -- T2 Engineering
        elseif enh =='AdvancedEngineering' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['CybranACUT2BuildRate'] then
                BuffBlueprint {
                    Name = 'CybranACUT2BuildRate',
                    DisplayName = 'CybranACUT2BuildRate',
                    BuffType = 'ACUBUILDRATE',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  bp.NewBuildRate - self:GetBlueprint().Economy.BuildRate,
                            Mult = 1,
                        },
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'CybranACUT2BuildRate')
            self:updateBuildRestrictions()
        elseif enh =='AdvancedEngineeringRemove' then
            local bp = self:GetBlueprint().Economy.BuildRate
            if not bp then return end
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction(categories.CYBRAN * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER))
            if Buff.HasBuff(self, 'CybranACUT2BuildRate') then
                Buff.RemoveBuff(self, 'CybranACUT2BuildRate')
            end
            self:updateBuildRestrictions()
        -- T3 Engineering
        elseif enh =='T3Engineering' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['CybranACUT3BuildRate'] then
                BuffBlueprint {
                    Name = 'CybranACUT3BuildRate',
                    DisplayName = 'CybranCUT3BuildRate',
                    BuffType = 'ACUBUILDRATE',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  bp.NewBuildRate - self:GetBlueprint().Economy.BuildRate,
                            Mult = 1,
                        },
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'CybranACUT3BuildRate')
            self:updateBuildRestrictions()
        elseif enh =='T3EngineeringRemove' then
            local bp = self:GetBlueprint().Economy.BuildRate
            if not bp then return end
            self:RestoreBuildRestrictions()
            if Buff.HasBuff(self, 'CybranACUT3BuildRate') then
                Buff.RemoveBuff(self, 'CybranACUT3BuildRate')
            end
            self:AddBuildRestriction(categories.CYBRAN * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER))
            self:updateBuildRestrictions()
        elseif enh =='CoolingUpgrade' then
            local bp = self:GetBlueprint().Enhancements[enh]
            local wep = self:GetWeaponByLabel('RightRipper')
            wep:ChangeMaxRadius(bp.NewMaxRadius or 30)
            self.normalRange = bp.NewMaxRadius or 30
            wep:ChangeRateOfFire(bp.NewRateOfFire or 2)
            local microwave = self:GetWeaponByLabel('MLG')
            microwave:ChangeMaxRadius(bp.NewMaxRadius or 30)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bp.NewMaxRadius or 30)
            local aoc = self:GetWeaponByLabel('AutoOverCharge')
            aoc:ChangeMaxRadius(bp.NewMaxRadius or 30)
            if not (self:GetCurrentLayer() == 'Seabed' and self:HasEnhancement('NaniteTorpedoTube')) then
                self:GetWeaponByLabel('DummyWeapon'):ChangeMaxRadius(self.normalRange)
            end
        elseif enh == 'CoolingUpgradeRemove' then
            local wep = self:GetWeaponByLabel('RightRipper')
            local wepBp = self:GetBlueprint().Weapon
            for k, v in wepBp do
                if v.Label == 'RightRipper' then
                    wep:ChangeRateOfFire(v.RateOfFire or 1)
                    wep:ChangeMaxRadius(v.MaxRadius or 22)
                    self.normalRange = v.MaxRadius or 22
                    self:GetWeaponByLabel('MLG'):ChangeMaxRadius(v.MaxRadius or 22)
                    self:GetWeaponByLabel('OverCharge'):ChangeMaxRadius(v.MaxRadius or 22)
                    self:GetWeaponByLabel('AutoOverCharge'):ChangeMaxRadius(v.MaxRadius or 22)
                    self.normalRange = v.MaxRadius or 22
                    if not (self:GetCurrentLayer() == 'Seabed' and self:HasEnhancement('NaniteTorpedoTube')) then
                        self:GetWeaponByLabel('DummyWeapon'):ChangeMaxRadius(self.normalRange)
                    end
                    break
                end
            end
		elseif enh == 'PhasonBeamAir' then
            self:SetWeaponEnabledByLabel('PhasonBeamAir', true)
        elseif enh == 'PhasonBeamAirRemove' then
			self:SetWeaponEnabledByLabel('PhasonBeamAir', false)
        elseif enh == 'MicrowaveLaserGenerator' then
            self:SetWeaponEnabledByLabel('MLG', true)
        elseif enh == 'MicrowaveLaserGeneratorRemove' then
            self:SetWeaponEnabledByLabel('MLG', false)
        elseif enh == 'NaniteTorpedoTube' then
            self:SetWeaponEnabledByLabel('Torpedo', true)
            self:EnableUnitIntel('Enhancement', 'Sonar')
            if self:GetCurrentLayer() == 'Seabed' then
                self:GetWeaponByLabel('DummyWeapon'):ChangeMaxRadius(self.torpRange)
            end
        elseif enh == 'NaniteTorpedoTubeRemove' then
            self:SetWeaponEnabledByLabel('Torpedo', false)
            self:DisableUnitIntel('Enhancement', 'Sonar')
            if self:GetCurrentLayer() == 'Seabed' then
                self:GetWeaponByLabel('DummyWeapon'):ChangeMaxRadius(self.normalRange)
            end
        end
    end,

    -- Intel
    IntelEffects = {
        Cloak = {
            {
                Bones = {
                    'Head',
                    'Right_Turret',
                    'Left_Turret',
                    'Right_Arm_B01',
                    'Left_Arm_B01',
                    'Chest_Right',
                    'Chest_Left',
                    'Left_Leg_B01',
                    'Left_Leg_B02',
                    'Left_Foot_B01',
                    'Right_Leg_B01',
                    'Right_Leg_B02',
                    'Right_Foot_B01',
                },
                Scale = 1.0,
                Type = 'Cloak01',
            },
        },
        Field = {
            {
                Bones = {
                    'Head',
                    'Right_Turret',
                    'Left_Turret',
                    'Right_Arm_B01',
                    'Left_Arm_B01',
                    'Chest_Right',
                    'Chest_Left',
                    'Left_Leg_B01',
                    'Left_Leg_B02',
                    'Left_Foot_B01',
                    'Right_Leg_B01',
                    'Right_Leg_B02',
                    'Right_Foot_B01',
                },
                Scale = 1.6,
                Type = 'Cloak01',
            },
        },
    },

    OnIntelEnabled = function(self)
        ACUUnit.OnIntelEnabled(self)
        if self.CloakEnh and self:IsIntelEnabled('Cloak') then
            self:SetEnergyMaintenanceConsumptionOverride(self:GetBlueprint().Enhancements['CloakingGenerator'].MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            if not self.IntelEffectsBag then
                self.IntelEffectsBag = {}
                self.CreateTerrainTypeEffects(self, self.IntelEffects.Cloak, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag)
            end
        elseif self.StealthEnh and self:IsIntelEnabled('RadarStealth') and self:IsIntelEnabled('SonarStealth') then
            self:SetEnergyMaintenanceConsumptionOverride(self:GetBlueprint().Enhancements['StealthGenerator'].MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            if not self.IntelEffectsBag then
                self.IntelEffectsBag = {}
                self.CreateTerrainTypeEffects(self, self.IntelEffects.Field, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag)
            end
        end
    end,

    OnIntelDisabled = function(self)
        ACUUnit.OnIntelDisabled(self)
        if self.IntelEffectsBag then
            EffectUtil.CleanupEffectBag(self, 'IntelEffectsBag')
            self.IntelEffectsBag = nil
        end
        if self.CloakEnh and not self:IsIntelEnabled('Cloak') then
            self:SetMaintenanceConsumptionInactive()
        elseif self.StealthEnh and not self:IsIntelEnabled('RadarStealth') and not self:IsIntelEnabled('SonarStealth') then
            self:SetMaintenanceConsumptionInactive()
        end
    end,

    -- Death
    OnKilled = function(self, instigator, type, overkillRatio)
        local bp
        for k, v in self:GetBlueprint().Buffs do
            if v.Add.OnDeath then
                bp = v
            end
        end
        -- If we could find a blueprint with v.Add.OnDeath, then add the buff
        if bp ~= nil then
            -- Apply Buff
            self:AddBuff(bp)
        end
        -- Otherwise, we should finish killing the unit
        ACUUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    OnLayerChange = function(self, new, old)
        ACUUnit.OnLayerChange(self, new, old)
        if self:GetWeaponByLabel('DummyWeapon') == nil then return end
        if new == "Seabed" and self:HasEnhancement('NaniteTorpedoTube') then
            self:GetWeaponByLabel('DummyWeapon'):ChangeMaxRadius(self.torpRange or 60)
        else
            self:GetWeaponByLabel('DummyWeapon'):ChangeMaxRadius(self.normalRange or 22)
        end
    end,
}

TypeClass = URL0001
