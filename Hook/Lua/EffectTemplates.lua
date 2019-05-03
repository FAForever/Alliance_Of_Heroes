-- ****************************************************************************
-- **
-- **  File     :  /data/lua/EffectTemplates.lua
-- **  Author(s):  Gordon Duclos, Greg Kohne, Matt Vainio, Aaron Lundquist
-- **
-- **  Summary  :  Generic templates for commonly used effects
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
EmtBpPath = '/effects/emitters/'
EmitterTempEmtBpPath = '/effects/emitters/temp/'
local ModPath = '/mods/Alliance_Of_Heroes/Graphics/Emitters/'


UnitTeleportSteam01 = {
    EmtBpPath .. 'teleport_commander_mist_01_emit.bp',
}

ColdwaveLaserMuzzle01 = {
    ModPath .. 'Coldwave_laser_flash_01_emit.bp',
    -- ModPath .. 'Coldwave_laser_muzzle_01_emit.bp',
}

ColdwaveLaserCharge01 = {
    ModPath .. 'Coldwave_laser_charge_01_emit.bp',
    -- ModPath .. 'Coldwave_laser_charge_02_emit.bp',
}

ColdwaveLaserEndPoint01 = {
    ModPath .. 'Coldwave_laser_end_01_emit.bp',
    -- ModPath .. 'Coldwave_laser_end_02_emit.bp',
    -- ModPath .. 'Coldwave_laser_end_03_emit.bp',
    -- ModPath .. 'Coldwave_laser_end_04_emit.bp',
    -- ModPath .. 'Coldwave_laser_end_05_emit.bp',
    -- ModPath .. 'Coldwave_laser_end_06_emit.bp',
}