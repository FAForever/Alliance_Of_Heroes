-----------------------------------------------------------------
-- File     :  /cdimage/units/XSL0301/XSL0301_script.lua
-- Author(s):  Jessica St. Croix, Gordon Duclos
-- Summary  :  Seraphim Sub Commander Script
-- Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local CommandUnit = import('/lua/defaultunits.lua').CommandUnit
local SWeapons = import('/lua/seraphimweapons.lua')
local Buff = import('/lua/sim/Buff.lua')
local SCUDeathWeapon = import('/lua/sim/defaultweapons.lua').SCUDeathWeapon
local EffectUtil = import('/lua/EffectUtilities.lua')
local SDFLightChronotronCannonWeapon = SWeapons.SDFLightChronotronCannonWeapon
local SDFOverChargeWeapon = SWeapons.SDFLightChronotronCannonOverchargeWeapon
local SIFLaanseTacticalMissileLauncher = SWeapons.SIFLaanseTacticalMissileLauncher

-- Alliance of Heroes
local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CWeapons = import('/lua/cybranweapons.lua')
local HeavyColdBeam = CWeapons.HeavyColdBeam


XSL0301 = Class(CommandUnit) {
    Weapons = {
        LightChronatronCannon = Class(SDFLightChronotronCannonWeapon) {},
        DeathWeapon = Class(SCUDeathWeapon) {},
        OverCharge = Class(SDFOverChargeWeapon) {},
        AutoOverCharge = Class(SDFOverChargeWeapon) {},
        Missile = Class(SIFLaanseTacticalMissileLauncher) {
            OnCreate = function(self)
                SIFLaanseTacticalMissileLauncher.OnCreate(self)
                self:SetWeaponEnabled(false)
            end,
        },
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
				LOG('inc thread')
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
		--
    },
	

    __init = function(self)
        CommandUnit.__init(self, 'LightChronatronCannon')
    end,

    OnCreate = function(self)
        CommandUnit.OnCreate(self)
        self:SetCapturable(false)
        self:HideBone('Back_Upgrade', true)
        self:SetupBuildBones()
        self:GetWeaponByLabel('OverCharge').NeedsUpgrade = true
        self:GetWeaponByLabel('AutoOverCharge').NeedsUpgrade = true
		self:SetWeaponEnabledByLabel('ColdBeam', false) -- Alliance of Heroes Weapons
    end,

	OnStopBeingBuilt = function(self, builder, layer)
        CommandUnit.OnStopBeingBuilt(self, builder, layer)
		self:SetWeaponEnabledByLabel('ColdBeam', false) -- Alliance of Heroes Weapons
    end,
	
    CreateBuildEffects = function(self, unitBeingBuilt, order)
        EffectUtil.CreateSeraphimUnitEngineerBuildingEffects(self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag)
    end,

    CreateEnhancement = function(self, enh)
        CommandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        -- Teleporter
        if enh == 'Teleporter' then
            self:AddCommandCap('RULEUCC_Teleport')
        elseif enh == 'TeleporterRemove' then
            self:RemoveCommandCap('RULEUCC_Teleport')
        -- Missile
        elseif enh == 'Missile' then
            self:AddCommandCap('RULEUCC_Tactical')
            self:AddCommandCap('RULEUCC_SiloBuildTactical')
            self:SetWeaponEnabledByLabel('Missile', true)
        elseif enh == 'MissileRemove' then
            self:RemoveCommandCap('RULEUCC_Tactical')
            self:RemoveCommandCap('RULEUCC_SiloBuildTactical')
            self:SetWeaponEnabledByLabel('Missile', false)
        -- Shields
        elseif enh == 'Shield' then
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            self:CreateShield(bp)
        elseif enh == 'ShieldRemove' then
            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
        -- Overcharge
        elseif enh == 'Overcharge' then
            self:AddCommandCap('RULEUCC_Overcharge')
            self:GetWeaponByLabel('OverCharge').NeedsUpgrade = false
            self:GetWeaponByLabel('AutoOverCharge').NeedsUpgrade = false
        elseif enh == 'OverchargeRemove' then
            self:RemoveCommandCap('RULEUCC_Overcharge')
            self:SetWeaponEnabledByLabel('OverCharge', false)
            self:SetWeaponEnabledByLabel('AutoOverCharge', false)
            self:GetWeaponByLabel('OverCharge').NeedsUpgrade = true
            self:GetWeaponByLabel('AutoOverCharge').NeedsUpgrade = true
        -- Engineering Throughput Upgrade
        elseif enh =='EngineeringThroughput' then
            if not Buffs['SeraphimSCUBuildRate'] then
                BuffBlueprint {
                    Name = 'SeraphimSCUBuildRate',
                    DisplayName = 'SeraphimSCUBuildRate',
                    BuffType = 'SCUBUILDRATE',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  bp.NewBuildRate - self:GetBlueprint().Economy.BuildRate,
                            Mult = 1,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'SeraphimSCUBuildRate')
        elseif enh == 'EngineeringThroughputRemove' then
            if Buff.HasBuff(self, 'SeraphimSCUBuildRate') then
                Buff.RemoveBuff(self, 'SeraphimSCUBuildRate')
            end
        -- Damage Stabilization
        elseif enh == 'DamageStabilization' then
            if not Buffs['SeraphimSCUDamageStabilization'] then
               BuffBlueprint {
                    Name = 'SeraphimSCUDamageStabilization',
                    DisplayName = 'SeraphimSCUDamageStabilization',
                    BuffType = 'SCUUPGRADEDMG',
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
            if Buff.HasBuff(self, 'SeraphimSCUDamageStabilization') then
                Buff.RemoveBuff(self, 'SeraphimSCUDamageStabilization')
            end
            Buff.ApplyBuff(self, 'SeraphimSCUDamageStabilization')
          elseif enh == 'DamageStabilizationRemove' then
            if Buff.HasBuff(self, 'SeraphimSCUDamageStabilization') then
                Buff.RemoveBuff(self, 'SeraphimSCUDamageStabilization')
            end
        -- Enhanced Sensor Systems
        elseif enh == 'EnhancedSensors' then
            self:SetIntelRadius('Vision', bp.NewVisionRadius or 104)
            self:SetIntelRadius('Omni', bp.NewOmniRadius or 104)
            local wep = self:GetWeaponByLabel('LightChronatronCannon')
            wep:ChangeMaxRadius(bp.NewMaxRadius or 35)
            local wep = self:GetWeaponByLabel('OverCharge')
            wep:ChangeMaxRadius(35)
            local aoc = self:GetWeaponByLabel('AutoOverCharge')
            aoc:ChangeMaxRadius(35)
        elseif enh == 'EnhancedSensorsRemove' then
            local bpIntel = self:GetBlueprint().Intel
            self:SetIntelRadius('Vision', bpIntel.VisionRadius or 26)
            self:SetIntelRadius('Omni', bpIntel.OmniRadius or 16)
            local wep = self:GetWeaponByLabel('LightChronatronCannon')
            wep:ChangeMaxRadius(bp.NewMaxRadius or 25)
            local wep = self:GetWeaponByLabel('OverCharge')
            wep:ChangeMaxRadius(bp.NewMaxRadius or 25)
            local aoc = self:GetWeaponByLabel('AutoOverCharge')
            aoc:ChangeMaxRadius(bp.NewMaxRadius or 25)
        end
    end,
}

TypeClass = XSL0301
