-----------------------------------------------------------------
-- File     :  /cdimage/units/UEL0001/UEL0001_script.lua
-- Author(s):  John Comes, David Tomandl, Jessica St. Croix
-- Summary  :  UEF Commander Script
-- Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local Shield = import('/lua/shield.lua').Shield
local ACUUnit = import('/lua/defaultunits.lua').ACUUnit
local TerranWeaponFile = import('/lua/terranweapons.lua')
local TDFZephyrCannonWeapon = TerranWeaponFile.TDFZephyrCannonWeapon
local DeathNukeWeapon = import('/lua/sim/defaultweapons.lua').DeathNukeWeapon
local TIFCruiseMissileLauncher = TerranWeaponFile.TIFCruiseMissileLauncher
local TDFOverchargeWeapon = TerranWeaponFile.TDFOverchargeWeapon
local EffectUtil = import('/lua/EffectUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')
-- Alliance of Heroes
local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CWeapons = import('/lua/cybranweapons.lua')
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

UEL0001 = Class(ACUUnit) {
    Weapons = {
        DeathWeapon = Class(DeathNukeWeapon) {},
        RightZephyr = Class(TDFZephyrCannonWeapon) {},
        OverCharge = Class(TDFOverchargeWeapon) {},
        AutoOverCharge = Class(TDFOverchargeWeapon) {},
        TacMissile = Class(TIFCruiseMissileLauncher) {},
        TacNukeMissile = Class(TIFCruiseMissileLauncher) {},
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
				LOG('Disabling')
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
        ACUUnit.__init(self, 'RightZephyr')
    end,

    OnCreate = function(self)
        ACUUnit.OnCreate(self)
        self:SetCapturable(false)
        self:HideBone('Right_Upgrade', true)
        self:HideBone('Left_Upgrade', true)
        self:HideBone('Back_Upgrade_B01', true)
        self:SetupBuildBones()
        self.HasLeftPod = false
        self.HasRightPod = false
        -- Restrict what enhancements will enable later
        self:AddBuildRestriction(categories.UEF * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER))
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        ACUUnit.OnStopBeingBuilt(self, builder, layer)
        if self:BeenDestroyed() then return end
        self.Animator = CreateAnimator(self)
        self.Animator:SetPrecedence(0)
        if self.IdleAnim then
            self.Animator:PlayAnim(self:GetBlueprint().Display.AnimationIdle, true)
            for k, v in self.DisabledBones do
                self.Animator:SetBoneEnabled(v, false)
            end
        end
        self:BuildManipulatorSetEnabled(false)
        self:SetWeaponEnabledByLabel('RightZephyr', true)
        self:SetWeaponEnabledByLabel('TacMissile', false)
        self:SetWeaponEnabledByLabel('TacNukeMissile', false)
		self:SetWeaponEnabledByLabel('ColdBeam', false) -- Alliance of Heroes Weapons
		self:SetWeaponEnabledByLabel('PhasonBeamAir', false)
        self:ForkThread(self.GiveInitialResources)
    end,

    OnStartBuild = function(self, unitBeingBuilt, order)
        ACUUnit.OnStartBuild(self, unitBeingBuilt, order)
        if self.Animator then
            self.Animator:SetRate(0)
        end
    end,

    CreateBuildEffects = function(self, unitBeingBuilt, order)
        local UpgradesFrom = unitBeingBuilt:GetBlueprint().General.UpgradesFrom
        -- If we are assisting an upgrading unit, or repairing a unit, play separate effects
        if (order == 'Repair' and not unitBeingBuilt:IsBeingBuilt()) or (UpgradesFrom and UpgradesFrom ~= 'none' and self:IsUnitState('Guarding'))then
            EffectUtil.CreateDefaultBuildBeams(self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag)
        else
            EffectUtil.CreateUEFCommanderBuildSliceBeams(self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag)
        end
    end,

    RebuildPod = function(self, PodNumber)
        if PodNumber == 1 then
            -- Force pod rebuilds to queue up
            if self.RebuildingPod2 ~= nil then
                WaitFor(self.RebuildingPod2)
            end
            if self.HasLeftPod == true then
                self.RebuildingPod = CreateEconomyEvent(self, 1600, 160, 10, self.SetWorkProgress)
                self:RequestRefreshUI()
                WaitFor(self.RebuildingPod)
                self:SetWorkProgress(0.0)
                RemoveEconomyEvent(self, self.RebuildingPod)
                self.RebuildingPod = nil
                local location = self:GetPosition('AttachSpecial02')
                local pod = CreateUnitHPR('UEA0001', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
                pod:SetParent(self, 'LeftPod')
                pod:SetCreator(self)
                self.Trash:Add(pod)
                self.LeftPod = pod
            end
        elseif PodNumber == 2 then
            -- Force pod rebuilds to queue up
            if self.RebuildingPod ~= nil then
                WaitFor(self.RebuildingPod)
            end
            if self.HasRightPod == true then
                self.RebuildingPod2 = CreateEconomyEvent(self, 1600, 160, 10, self.SetWorkProgress)
                self:RequestRefreshUI()
                WaitFor(self.RebuildingPod2)
                self:SetWorkProgress(0.0)
                RemoveEconomyEvent(self, self.RebuildingPod2)
                self.RebuildingPod2 = nil
                local location = self:GetPosition('AttachSpecial01')
                local pod = CreateUnitHPR('UEA0001', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
                pod:SetParent(self, 'RightPod')
                pod:SetCreator(self)
                self.Trash:Add(pod)
                self.RightPod = pod
            end
        end
        self:RequestRefreshUI()
    end,

    NotifyOfPodDeath = function(self, pod, rebuildDrone)
        if rebuildDrone == true then
            if pod == 'LeftPod' then
                if self.HasLeftPod == true then
                    self.RebuildThread = self:ForkThread(self.RebuildPod, 1)
                end
            elseif pod == 'RightPod' then
                if self.HasRightPod == true then
                    self.RebuildThread2 = self:ForkThread(self.RebuildPod, 2)
                end
            end
        else
            self:CreateEnhancement(pod..'Remove')
        end
    end,

    CreateEnhancement = function(self, enh)
        ACUUnit.CreateEnhancement(self, enh)

        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        if enh == 'LeftPod' then
            local location = self:GetPosition('AttachSpecial02')
            local pod = CreateUnitHPR('UEA0001', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
            pod:SetParent(self, 'LeftPod')
            pod:SetCreator(self)
            self.Trash:Add(pod)
            self.HasLeftPod = true
            self.LeftPod = pod
        elseif enh == 'RightPod' then
            local location = self:GetPosition('AttachSpecial01')
            local pod = CreateUnitHPR('UEA0001', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
            pod:SetParent(self, 'RightPod')
            pod:SetCreator(self)
            self.Trash:Add(pod)
            self.HasRightPod = true
            self.RightPod = pod
        elseif enh == 'LeftPodRemove' or enh == 'RightPodRemove' then
            if self.HasLeftPod == true then
                self.HasLeftPod = false
                if self.LeftPod and not self.LeftPod.Dead then
                    self.LeftPod:Kill()
                    self.LeftPod = nil
                end
                if self.RebuildingPod ~= nil then
                    RemoveEconomyEvent(self, self.RebuildingPod)
                    self.RebuildingPod = nil
                end
            end
            if self.HasRightPod == true then
                self.HasRightPod = false
                if self.RightPod and not self.RightPod.Dead then
                    self.RightPod:Kill()
                    self.RightPod = nil
                end
                if self.RebuildingPod2 ~= nil then
                    RemoveEconomyEvent(self, self.RebuildingPod2)
                    self.RebuildingPod2 = nil
                end
            end
            KillThread(self.RebuildThread)
            KillThread(self.RebuildThread2)
        elseif enh == 'Teleporter' then
            self:AddCommandCap('RULEUCC_Teleport')
        elseif enh == 'TeleporterRemove' then
            self:RemoveCommandCap('RULEUCC_Teleport')
        elseif enh == 'Shield' then
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:CreateShield(bp)
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
        elseif enh == 'ShieldRemove' then
            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            RemoveUnitEnhancement(self, 'ShieldRemove')
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
        elseif enh == 'ShieldGeneratorField' then
            self:DestroyShield()
            ForkThread(function()
                WaitTicks(1)
                self:CreateShield(bp)
                self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
                self:SetMaintenanceConsumptionActive()
            end)
        elseif enh == 'ShieldGeneratorFieldRemove' then
            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
        elseif enh =='AdvancedEngineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['UEFACUT2BuildRate'] then
                BuffBlueprint {
                    Name = 'UEFACUT2BuildRate',
                    DisplayName = 'UEFACUT2BuildRate',
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
            Buff.ApplyBuff(self, 'UEFACUT2BuildRate')
            -- Engymod addition: After fiddling with build restrictions, update engymod build restrictions
            self:updateBuildRestrictions()
        elseif enh =='AdvancedEngineeringRemove' then
            local bp = self:GetBlueprint().Economy.BuildRate
            if not bp then return end
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction(categories.UEF * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER))
            self:AddBuildRestriction(categories.UEF * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER))
            if Buff.HasBuff(self, 'UEFACUT2BuildRate') then
                Buff.RemoveBuff(self, 'UEFACUT2BuildRate')
            end
            -- Engymod addition: After fiddling with build restrictions, update engymod build restrictions
            self:updateBuildRestrictions()
		elseif enh == 'PhasonBeamAir' then
            self:SetWeaponEnabledByLabel('PhasonBeamAir', true)
        elseif enh == 'PhasonBeamAirRemove' then
			self:SetWeaponEnabledByLabel('PhasonBeamAir', false)	
        elseif enh =='T3Engineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['UEFACUT3BuildRate'] then
                BuffBlueprint {
                    Name = 'UEFACUT3BuildRate',
                    DisplayName = 'UEFCUT3BuildRate',
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
            Buff.ApplyBuff(self, 'UEFACUT3BuildRate')
            -- Engymod addition: After fiddling with build restrictions, update engymod build restrictions
            self:updateBuildRestrictions()
        elseif enh =='T3EngineeringRemove' then
            local bp = self:GetBlueprint().Economy.BuildRate
            if not bp then return end
            self:RestoreBuildRestrictions()
            if Buff.HasBuff(self, 'UEFACUT3BuildRate') then
                Buff.RemoveBuff(self, 'UEFACUT3BuildRate')
            end
            self:AddBuildRestriction(categories.UEF * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER))
            -- Engymod addition: After fiddling with build restrictions, update engymod build restrictions
            self:updateBuildRestrictions()
        elseif enh =='DamageStabilization' then
            if not Buffs['UEFACUDamageStabilization'] then
                BuffBlueprint {
                    Name = 'UEFACUDamageStabilization',
                    DisplayName = 'UEFACUDamageStabilization',
                    BuffType = 'DamageStabilization',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
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
            Buff.ApplyBuff(self, 'UEFACUDamageStabilization')
        elseif enh =='DamageStabilizationRemove' then
            if Buff.HasBuff(self, 'UEFACUDamageStabilization') then
                Buff.RemoveBuff(self, 'UEFACUDamageStabilization')
            end
        elseif enh =='HeavyAntiMatterCannon' then
            local wep = self:GetWeaponByLabel('RightZephyr')
            wep:AddDamageMod(bp.ZephyrDamageMod)
            wep:ChangeMaxRadius(bp.NewMaxRadius or 44)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bp.NewMaxRadius or 44)
            local aoc = self:GetWeaponByLabel('AutoOverCharge')
            aoc:ChangeMaxRadius(bp.NewMaxRadius or 44)
        elseif enh =='HeavyAntiMatterCannonRemove' then
            local bp = self:GetBlueprint().Enhancements['HeavyAntiMatterCannon']
            if not bp then return end
            local wep = self:GetWeaponByLabel('RightZephyr')
            wep:AddDamageMod(-bp.ZephyrDamageMod)
            local bpDisrupt = self:GetBlueprint().Weapon[1].MaxRadius
            wep:ChangeMaxRadius(bpDisrupt or 22)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bpDisrupt or 22)
            local aoc = self:GetWeaponByLabel('AutoOverCharge')
            aoc:ChangeMaxRadius(bpDisrupt or 22)
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
        elseif enh =='TacticalMissile' then
            self:AddCommandCap('RULEUCC_Tactical')
            self:AddCommandCap('RULEUCC_SiloBuildTactical')
            self:SetWeaponEnabledByLabel('TacMissile', true)
        elseif enh =='TacticalNukeMissile' then
            self:RemoveCommandCap('RULEUCC_Tactical')
            self:RemoveCommandCap('RULEUCC_SiloBuildTactical')
            self:AddCommandCap('RULEUCC_Nuke')
            self:AddCommandCap('RULEUCC_SiloBuildNuke')
            self:SetWeaponEnabledByLabel('TacMissile', false)
            self:SetWeaponEnabledByLabel('TacNukeMissile', true)
            local amt = self:GetTacticalSiloAmmoCount()
            self:RemoveTacticalSiloAmmo(amt or 0)
            self:StopSiloBuild()
        elseif enh == 'TacticalMissileRemove' or enh == 'TacticalNukeMissileRemove' then
            self:RemoveCommandCap('RULEUCC_Nuke')
            self:RemoveCommandCap('RULEUCC_SiloBuildNuke')
            self:RemoveCommandCap('RULEUCC_Tactical')
            self:RemoveCommandCap('RULEUCC_SiloBuildTactical')
            self:SetWeaponEnabledByLabel('TacMissile', false)
            self:SetWeaponEnabledByLabel('TacNukeMissile', false)
            local amt = self:GetTacticalSiloAmmoCount()
            self:RemoveTacticalSiloAmmo(amt or 0)
            local amt = self:GetNukeSiloAmmoCount()
            self:RemoveNukeSiloAmmo(amt or 0)
            self:StopSiloBuild()
        end
    end,
}

TypeClass = UEL0001
