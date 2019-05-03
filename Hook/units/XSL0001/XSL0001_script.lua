--****************************************************************************
--**
--**  File     :  /cdimage/units/XSL0001/XSL0001_script.lua
--**  Author(s):  Drew Staltman, Jessica St. Croix, Gordon Duclos
--**
--**  Summary  :  Seraphim Commander Script
--**
--**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local ACUUnit = import('/lua/defaultunits.lua').ACUUnit
local Buff = import('/lua/sim/Buff.lua')
local SWeapons = import('/lua/seraphimweapons.lua')
local SDFChronotronCannonWeapon = SWeapons.SDFChronotronCannonWeapon
local SDFChronotronOverChargeCannonWeapon = SWeapons.SDFChronotronCannonOverChargeWeapon
local DeathNukeWeapon = import('/lua/sim/defaultweapons.lua').DeathNukeWeapon
local EffectUtil = import('/lua/EffectUtilities.lua')
local SIFLaanseTacticalMissileLauncher = SWeapons.SIFLaanseTacticalMissileLauncher
local AIUtils = import('/lua/ai/aiutilities.lua')
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

XSL0001 = Class(ACUUnit) {
    Weapons = {
        DeathWeapon = Class(DeathNukeWeapon) {},
        ChronotronCannon = Class(SDFChronotronCannonWeapon) {},
        Missile = Class(SIFLaanseTacticalMissileLauncher) {
            OnCreate = function(self)
                SIFLaanseTacticalMissileLauncher.OnCreate(self)
                self:SetWeaponEnabled(false)
            end,
        },
        OverCharge = Class(SDFChronotronOverChargeCannonWeapon) {},
        AutoOverCharge = Class(SDFChronotronOverChargeCannonWeapon) {},
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
        ACUUnit.__init(self, 'ChronotronCannon')
    end,

    OnCreate = function(self)
        ACUUnit.OnCreate(self)
        self:SetCapturable(false)
        self:SetupBuildBones()
        self:HideBone('Back_Upgrade', true)
        self:HideBone('Right_Upgrade', true)
        self:HideBone('Left_Upgrade', true)
        -- Restrict what enhancements will enable later
        self:AddBuildRestriction(categories.SERAPHIM * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER))
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        ACUUnit.OnStopBeingBuilt(self,builder,layer)
        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
		self:SetWeaponEnabledByLabel('ColdBeam', false) -- Alliance of Heroes Weapons
		self:SetWeaponEnabledByLabel('PhasonBeamAir', false)
        self:ForkThread(self.GiveInitialResources)
        self.ShieldEffectsBag = {}
    end,

    CreateBuildEffects = function(self, unitBeingBuilt, order)
        EffectUtil.CreateSeraphimUnitEngineerBuildingEffects(self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag)
    end,

    GetUnitsToBuff = function(self, bp)
        local unitCat = ParseEntityCategory(bp.UnitCategory or 'BUILTBYTIER3FACTORY + BUILTBYQUANTUMGATE + NEEDMOBILEBUILD')
        local brain = self:GetAIBrain()
        local all = brain:GetUnitsAroundPoint(unitCat, self:GetPosition(), bp.Radius, 'Ally')
        local units = {}

        for _, u in all do
            if not u.Dead and not u:IsBeingBuilt() then
                table.insert(units, u)
            end
        end

        return units
    end,

    RegenBuffThread = function(self, type)
        local bp = self:GetBlueprint().Enhancements[type]
        local buff = 'SeraphimACU' .. type

        while not self.Dead do
            local units = self:GetUnitsToBuff(bp)
            for _,unit in units do
                Buff.ApplyBuff(unit, buff)
                unit:RequestRefreshUI()
            end
            WaitSeconds(5)
        end
    end,

    CreateEnhancement = function(self, enh)
        ACUUnit.CreateEnhancement(self, enh)

        local bp = self:GetBlueprint().Enhancements[enh]

        -- Regenerative Aura
        if enh == 'RegenAura' or enh == 'AdvancedRegenAura' then
            local buff
            local type

            buff = 'SeraphimACU' .. enh

            if not Buffs[buff] then
                local buff_bp = {
                    Name = buff,
                    DisplayName = buff,
                    BuffType = 'COMMANDERAURA_' .. enh,
                    Stacks = 'REPLACE',
                    Duration = 5,
                    Affects = {
                        Regen = {
                            Add = 0,
                            Mult = bp.RegenPerSecond,
                            Ceil = bp.RegenCeiling,
                        },
                    },
                }

                if enh == 'AdvancedRegenAura' then
                    buff_bp.Affects.MaxHealth = {
                        Add = 0,
                        Mult = bp.MaxHealthFactor,
                        DoNotFill = true,
                    }
                end

                BuffBlueprint(buff_bp)
            end

            buff2 = buff .. 'SelfBuff'

            if not Buffs[buff2] then   -- AURA SELF BUFF
                BuffBlueprint {
                    Name = buff2,
                    DisplayName = buff2,
                    BuffType = 'COMMANDERAURAFORSELF',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.ACUAddHealth,
                            Mult = 1,
                        },
                    },
                }
            end

            Buff.ApplyBuff(self, buff2)
            table.insert(self.ShieldEffectsBag, CreateAttachedEmitter(self, 'XSL0001', self:GetArmy(), '/effects/emitters/seraphim_regenerative_aura_01_emit.bp'))
            if self.RegenThreadHandle then
                KillThread(self.RegenThreadHandle)
                self.RegenThreadHandle = nil
            end

            self.RegenThreadHandle = self:ForkThread(self.RegenBuffThread, enh)
        elseif enh == 'RegenAuraRemove' or enh == 'AdvancedRegenAuraRemove' then
            if self.ShieldEffectsBag then
                for k, v in self.ShieldEffectsBag do
                    v:Destroy()
                end
                self.ShieldEffectsBag = {}
            end

            KillThread(self.RegenThreadHandle)
            self.RegenThreadHandle = nil
            for _, b in {'SeraphimACURegenAura', 'SeraphimACUAdvancedRegenAura'} do
                if Buff.HasBuff(self, b .. 'SelfBuff') then
                    Buff.RemoveBuff(self, b .. 'SelfBuff')
                end
            end
		elseif enh == 'PhasonBeamAir' then
            self:SetWeaponEnabledByLabel('PhasonBeamAir', true)
        elseif enh == 'PhasonBeamAirRemove' then
			self:SetWeaponEnabledByLabel('PhasonBeamAir', false)	
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
        elseif enh == 'ResourceAllocationAdvanced' then
            local bp = self:GetBlueprint().Enhancements[enh]
            local bpEcon = self:GetBlueprint().Economy
            if not bp then return end
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
        elseif enh == 'ResourceAllocationAdvancedRemove' then
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
        --Damage Stabilization
        elseif enh == 'DamageStabilization' then
            if not Buffs['SeraphimACUDamageStabilization'] then
               BuffBlueprint {
                    Name = 'SeraphimACUDamageStabilization',
                    DisplayName = 'SeraphimACUDamageStabilization',
                    BuffType = 'ACUUPGRADEDMG',
                    Stacks = 'ALWAYS',
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
            if Buff.HasBuff(self, 'SeraphimACUDamageStabilization') then
                Buff.RemoveBuff(self, 'SeraphimACUDamageStabilization')
            end
            Buff.ApplyBuff(self, 'SeraphimACUDamageStabilization')
          elseif enh == 'DamageStabilizationAdvanced' then
            if not Buffs['SeraphimACUDamageStabilizationAdv'] then
               BuffBlueprint {
                    Name = 'SeraphimACUDamageStabilizationAdv',
                    DisplayName = 'SeraphimACUDamageStabilizationAdv',
                    BuffType = 'ACUUPGRADEDMG',
                    Stacks = 'ALWAYS',
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
            if Buff.HasBuff(self, 'SeraphimACUDamageStabilizationAdv') then
                Buff.RemoveBuff(self, 'SeraphimACUDamageStabilizationAdv')
            end
            Buff.ApplyBuff(self, 'SeraphimACUDamageStabilizationAdv')
        elseif enh == 'DamageStabilizationAdvancedRemove' then
            -- since there's no way to just remove an upgrade anymore, if we're remove adv, were removing both
            if Buff.HasBuff(self, 'SeraphimACUDamageStabilizationAdv') then
                Buff.RemoveBuff(self, 'SeraphimACUDamageStabilizationAdv')
            end
            if Buff.HasBuff(self, 'SeraphimACUDamageStabilization') then
                Buff.RemoveBuff(self, 'SeraphimACUDamageStabilization')
            end
        elseif enh == 'DamageStabilizationRemove' then
            if Buff.HasBuff(self, 'SeraphimACUDamageStabilization') then
                Buff.RemoveBuff(self, 'SeraphimACUDamageStabilization')
            end
        --Teleporter
        elseif enh == 'Teleporter' then
            self:AddCommandCap('RULEUCC_Teleport')
        elseif enh == 'TeleporterRemove' then
            self:RemoveCommandCap('RULEUCC_Teleport')
        -- Tactical Missile
        elseif enh == 'Missile' then
            self:AddCommandCap('RULEUCC_Tactical')
            self:AddCommandCap('RULEUCC_SiloBuildTactical')
            self:SetWeaponEnabledByLabel('Missile', true)
        elseif enh == 'MissileRemove' then
            self:RemoveCommandCap('RULEUCC_Tactical')
            self:RemoveCommandCap('RULEUCC_SiloBuildTactical')
            self:SetWeaponEnabledByLabel('Missile', false)
        --T2 Engineering
        elseif enh =='AdvancedEngineering' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['SeraphimACUT2BuildRate'] then
                BuffBlueprint {
                    Name = 'SeraphimACUT2BuildRate',
                    DisplayName = 'SeraphimACUT2BuildRate',
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
            Buff.ApplyBuff(self, 'SeraphimACUT2BuildRate')
        -- Engymod addition: After fiddling with build restrictions, update engymod build restrictions
        self:updateBuildRestrictions()

        elseif enh =='AdvancedEngineeringRemove' then
            local bp = self:GetBlueprint().Economy.BuildRate
            if not bp then return end
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction(categories.SERAPHIM * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER))
            if Buff.HasBuff(self, 'SeraphimACUT2BuildRate') then
                Buff.RemoveBuff(self, 'SeraphimACUT2BuildRate')
         end
        -- Engymod addition: After fiddling with build restrictions, update engymod build restrictions
        self:updateBuildRestrictions()

        --T3 Engineering
        elseif enh =='T3Engineering' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['SeraphimACUT3BuildRate'] then
                BuffBlueprint {
                    Name = 'SeraphimACUT3BuildRate',
                    DisplayName = 'SeraphimCUT3BuildRate',
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
            Buff.ApplyBuff(self, 'SeraphimACUT3BuildRate')
        -- Engymod addition: After fiddling with build restrictions, update engymod build restrictions
        self:updateBuildRestrictions()
        elseif enh =='T3EngineeringRemove' then
            local bp = self:GetBlueprint().Economy.BuildRate
            if not bp then return end
            self:RestoreBuildRestrictions()
            if Buff.HasBuff(self, 'SeraphimACUT3BuildRate') then
                Buff.RemoveBuff(self, 'SeraphimACUT3BuildRate')
            end
            self:AddBuildRestriction(categories.SERAPHIM * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER))
        -- Engymod addition: After fiddling with build restrictions, update engymod build restrictions
        self:updateBuildRestrictions()
        --Blast Attack
        elseif enh == 'BlastAttack' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:AddDamageRadiusMod(bp.NewDamageRadius or 5)
            wep:AddDamageMod(bp.AdditionalDamage)
        elseif enh == 'BlastAttackRemove' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:AddDamageRadiusMod(-self:GetBlueprint().Enhancements['BlastAttack'].NewDamageRadius) -- unlimited AOE bug fix by brute51 [117]
            wep:AddDamageMod(-self:GetBlueprint().Enhancements['BlastAttack'].AdditionalDamage)
        --Heat Sink Augmentation
        elseif enh == 'RateOfFire' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:ChangeRateOfFire(bp.NewRateOfFire or 2)
            wep:ChangeMaxRadius(bp.NewMaxRadius or 44)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bp.NewMaxRadius or 44)
            local aoc = self:GetWeaponByLabel('AutoOverCharge')
            aoc:ChangeMaxRadius(bp.NewMaxRadius or 44)
        elseif enh == 'RateOfFireRemove' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            local bpDisrupt = self:GetBlueprint().Weapon[1].RateOfFire
            wep:ChangeRateOfFire(bpDisrupt or 1)
            bpDisrupt = self:GetBlueprint().Weapon[1].MaxRadius
            wep:ChangeMaxRadius(bpDisrupt or 22)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bpDisrupt or 22)
            local aoc = self:GetWeaponByLabel('AutoOverCharge')
            aoc:ChangeMaxRadius(bpDisrupt or 22)
        end
    end,
}

TypeClass = XSL0001
