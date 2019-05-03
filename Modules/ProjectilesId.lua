local ProjId = 0
Projectiles = {}

Register = function(DamageData)
	ProjId = ProjId + 1
	Projectiles['ProjId'..ProjId] = {}
	Projectiles['ProjId'..ProjId] = DamageData
	if ProjId > 4000 then -- id table storing only 4000 last id.
		local Erasingid = ProjId - 4000
		Projectiles['ProjId'..Erasingid] = nil
	end
	return ProjId
end