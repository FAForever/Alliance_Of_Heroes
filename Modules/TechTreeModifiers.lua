-- Alliance of Heroes --
-- Tech Tree -----------
-- 2018 ----------------
------------------------

Modifiers = {
	HealthIncrease = {
		Name = 'Health Increase',
		Description = function(id, ids)
			return nil
		end,
		DrawData = {
			ACUTechTree = {100, 100, IconPath},
		},
		IsAvailable = function(id, ids)
			return true
		end,
		Cost = function(id, ids, type)
			return 1
		end,
		GetLevel = function(id, ids)
			return 0
		end,
		GetMaxLevel = function(id, ids)
			return 1
		end,
		CanTechUp = function(id, ids)
			return true
		end,
		OnTechUp = function(id, ids)
			-- Tech up script
		end,
		OnDamage = function()
			-- Script
		end,
		OnTakeDamage = function()
			-- Script
		end,
		OnDamageShield = function()
			-- Script
		end,
		OnKilled = function()
			-- Script
		end,
		OnFireProjectile = function()
			-- Script
		end,
		OnFireBeam = function()
			-- Script
		end,
	}
}