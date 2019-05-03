local EmitterProjectile = import('/lua/sim/defaultprojectiles.lua').EmitterProjectile
local ModPath = '/mods/Alliance_Of_Heroes/'
local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local EffectTemplate = import('/lua/EffectTemplates.lua')
local DefaultProjectileFile = import('/lua/sim/defaultprojectiles.lua')
local EmitterProjectile = import('/lua/sim/defaultprojectiles.lua').EmitterProjectile
local DM = import(ModPath..'Modules/DataManager.lua')
local Entity = import('/lua/sim/Entity.lua').Entity

EffectProtonAmbient01 = Class(EmitterProjectile) {
	OnCreate = function(self)
		EmitterProjectile.OnCreate(self)
		self:ForkThread(self.ProtonHitThread)
	end,

	ProtonHitThread = function(self)
        local army = self:GetArmy()
		local id = self:GetEntityId() 
        local pos = {DM.GetProperty(nil,'MousePosX'), DM.GetProperty(nil,'MousePosY'), DM.GetProperty(nil,'MousePosZ')}
		for k, v in EffectTemplate.CommanderQuantumGateInEnergy do
            CreateEmitterOnEntity( self, army, v )
        end
		
		local TempEntity = Entity()
		TempEntity:SetPosition(pos, true)
		
		FxTrails = {ModPath..'effects/emitters/proton_bomb_hit_03_emit.bp',},
        # Smoke ring, explosion effects
        CreateLightParticleIntel( TempEntity, -1, army, 35, 10, 'glow_02', 'ramp_blue_13' )
        DamageRing(self, pos, .1, 11, 100, 'Force', false, false)

		for k, v in EffectTemplate.CommanderTeleport01 do
            CreateEmitterOnEntity( TempEntity, army, v )
        end
		
        local decalOrient = RandomFloat(0,2*math.pi)
        CreateDecal(TempEntity:GetPosition(), decalOrient, 'nuke_scorch_002_albedo', '', 'Albedo', 28, 28, 500, 10, army)
        CreateDecal(TempEntity:GetPosition(), decalOrient, 'Crater05_normals', '', 'Normals', 28, 28, 500, 10, army)
        CreateDecal(TempEntity:GetPosition(), decalOrient, 'Crater05_normals', '', 'Normals', 12, 12, 500, 10, army)

		# Knockdown force rings
        WaitSeconds(0.39)
        DamageRing(self, pos, 11, 20, 1, 'Force', false, false)
        WaitSeconds(.1)
        DamageRing(self, pos, 11, 20, 1, 'Force', false, false)
        WaitSeconds(0.5)
		WaitSeconds(.1)
        DamageRing(self, pos, .01, 25, 2400, 'Crusader', false, false)
       
	   # Scorch decal and light some trees on fire
        WaitSeconds(0.3)
        DamageRing(self, pos, 20, 27, 1, 'Fire', false, false)
		
		TempEntity:Destroy()
	end,
}
TypeClass = EffectProtonAmbient01