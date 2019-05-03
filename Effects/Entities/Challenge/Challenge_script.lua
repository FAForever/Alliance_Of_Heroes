#****************************************************************************
#**
#**  File     :  /effects/entities/UnitTeleport01/UnitTeleport01_script.lua
#**  Author(s):  Gordon Duclos
#**
#**  Summary  :  Unit Teleport effect entity
#**
#**  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local EffectTemplate = import('/lua/EffectTemplates.lua')

DreadnoughtStun = Class(NullShell) {

    OnCreate = function(self)
        NullShell.OnCreate(self)
        self:ForkThread(self.ChallengeEffectThread)
    end,

   ChallengeEffectThread = function(self)
        local army = self:GetArmy()
        local pos = self:GetPosition()
        pos[2] = GetSurfaceHeight(pos[1], pos[3]) - 2

        # Initial light flashs
        CreateLightParticleIntel( self, -1, army, 18, 4, 'flare_lens_add_02', 'ramp_red_13' )
        WaitSeconds(0.3)
        CreateLightParticleIntel( self, -1, army, 35, 10, 'flare_lens_add_02', 'ramp_red_13' )

        CreateLightParticleIntel( self, -1, army, 35, 10, 'glow_02', 'ramp_red_01' )
        DamageRing(self, pos, .1, 11, 25, 'Force', false, false)

        local decalOrient = RandomFloat(0,2*math.pi)
        CreateDecal(self:GetPosition(), decalOrient, 'nuke_scorch_002_albedo', '', 'Albedo', 28, 28, 500, 100, army)

		WaitSeconds(.1)
        DamageRing(self, pos, .1, 11, 25, 'Force', false, false)

		# Knockdown force rings
        WaitSeconds(0.39)
        DamageRing(self, pos, 11, 15, 1, 'Force', false, false)
        WaitSeconds(.1)
        DamageRing(self, pos, 11, 15, 1, 'Force', false, false)
        WaitSeconds(0.5)

        # Scorch decal and light some trees on fire
        WaitSeconds(0.3)
        DamageRing(self, pos, 15, 20, 1, 'Fire', false, false)
    end,



}

TypeClass = DreadnoughtStun

