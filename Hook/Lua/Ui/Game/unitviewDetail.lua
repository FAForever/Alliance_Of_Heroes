-- Franck 83 ---
-- Hooking to show heroes and shield upgrades

OldShow = Show
function Show(bp, buildingUnit, bpID)
	local Modbp = table.copy(bp)
	-- AOH Custom shield data
	-- Modbp.Defense.Shield = {
		-- ImpactEffects = 'UEFShieldHit01',
		-- ImpactMesh = '/effects/entities/ShieldSection01/ShieldSection01_mesh',
		-- Mesh = '/effects/entities/Shield01/Shield01_mesh',
		-- MeshZ = '/effects/entities/Shield01/Shield01z_mesh',
		-- RegenAssistMult = 60,
		-- ShieldEnergyDrainRechargeTime = 5,
		-- ShieldMaxHealth = 50000,
		-- ShieldRechargeTime = 24,
		-- ShieldRegenRate = 55,
		-- ShieldRegenStartTime = 3,
		-- ShieldSize = 17,
		-- ShieldSpillOverDamageMod = 0.15,
		-- ShieldVerticalOffset = -3,
	-- }
	OldShow(Modbp, buildingUnit, bpID)
end

OldShowEnhancement = ShowEnhancement
function ShowEnhancement(bp, bpID, iconID, iconPrefix, userUnit)
	local Modbp = table.copy(bp)
	-- AOH Custom shield data
	-- Modbp.Defense.Shield = {
		-- ImpactEffects = 'UEFShieldHit01',
		-- ImpactMesh = '/effects/entities/ShieldSection01/ShieldSection01_mesh',
		-- Mesh = '/effects/entities/Shield01/Shield01_mesh',
		-- MeshZ = '/effects/entities/Shield01/Shield01z_mesh',
		-- RegenAssistMult = 60,
		-- ShieldEnergyDrainRechargeTime = 5,
		-- ShieldMaxHealth = 50000,
		-- ShieldRechargeTime = 24,
		-- ShieldRegenRate = 55,
		-- ShieldRegenStartTime = 3,
		-- ShieldSize = 17,
		-- ShieldSpillOverDamageMod = 0.15,
		-- ShieldVerticalOffset = -3,
	-- }
	OldShowEnhancement(Modbp, bpID, iconID, iconPrefix, userUnit)
end