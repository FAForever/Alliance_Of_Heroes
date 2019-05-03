local EmitterProjectile = import('/lua/sim/defaultprojectiles.lua').EmitterProjectile
local ModPath = '/mods/Alliance_Of_Heroes/'
local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local EffectTemplate = import('/lua/EffectTemplates.lua')
local DefaultProjectileFile = import('/lua/sim/defaultprojectiles.lua')
local EmitterProjectile = import('/lua/sim/defaultprojectiles.lua').EmitterProjectile
local DM = import(ModPath..'Modules/DataManager.lua')
local Entity = import('/lua/sim/Entity.lua').Entity

EffectProtonAmbient01s = Class(EmitterProjectile) {
	OnCreate = function(self)
		EmitterProjectile.OnCreate(self)
		self:ForkThread(self.ProtonHitThread)
	end,

	ProtonHitThread = function(self)
        local army = self:GetArmy()
		local id = self:GetEntityId() 
        local pos = {DM.GetProperty(nil,'MousePosX'), DM.GetProperty(nil,'MousePosY'), DM.GetProperty(nil,'MousePosZ')}
		
		local TempEntity = Entity()
		TempEntity:SetPosition(pos, true)
		
		# Smoke ring, explosion effects
        CreateLightParticleIntel( TempEntity, -1, army, 5, 5, 'glow_02', 'ramp_red_12' )
     
		
		TempEntity:Destroy()
		WaitSeconds(0.25)
		DM.SetProperty(nil,'SimulatePower', nil)
	end,
  
	}
TypeClass = EffectProtonAmbient01s