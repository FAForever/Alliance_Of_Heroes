local ALaserBotProjectile = import('/lua/aeonprojectiles.lua').ALaserBotProjectile
local EffectTemplate = import('/lua/EffectTemplates.lua')
EmtBpPath = '/Mods/Alliance_Of_Heroes/Modules/Projectiles/ADFOverCharge01/'

TDFOverCharge01 = Class(ALaserBotProjectile) {
    PolyTrail = EmtBpPath..'seraphim_ajellu_polytrail_01_emit.bp',
    FxTrails = {EmtBpPath .. 'aeon_commander_overcharge_01_emit.bp', 
	EmtBpPath .. 'aeon_commander_overcharge_02_emit.bp',},
    FxImpactUnit = EffectTemplate.CIridiumRocketProjectile,
    FxImpactProp = EffectTemplate.CIridiumRocketProjectile,
    FxImpactLand = EffectTemplate.CIridiumRocketProjectile,
}

TypeClass = TDFOverCharge01
