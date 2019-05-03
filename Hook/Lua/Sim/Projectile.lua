local V = import('/lua/Utilities.lua')

local oldprojectile = Projectile
Projectile = Class(oldprojectile) {
    oldPassDamageData = Projectile.PassDamageData,
	PassDamageData = function(self, DamageData)
		-- Ready for hooking
		Projectile.oldPassDamageData(self, DamageData)
    end,
	
	oldOnImpact = Projectile.OnImpact, 
	OnImpact = function(self, targetType, targetEntity)
		if targetEntity and self then
			local qx, qy, qz, qw = unpack(targetEntity:GetOrientation())
			local a = math.atan2(2.0*(qx*qz + qw*qy), qw*qw + qx*qx - qz*qz - qy*qy)
			local current_yaw = math.floor(a * (180 / math.pi) + 0.5) + 180		
			qx2, qy2, qz2, qw2 = unpack(self:GetOrientation())
			a2 = math.atan2(2.0*(qx2*qz2 + qw2*qy2), qw2*qw2 + qx2*qx2 - qz2*qz2 - qy2*qy2)
			current_yaw2 = math.floor(a2 * (180 / math.pi) + 0.5) + 180	
			local Angle = math.abs(math.floor(current_yaw2 - current_yaw))	
			if  self.DamageData.DamageAmount then
				if Angle < 30 or Angle > 330 then 
					self.DamageData.DamageAmount = self.DamageData.DamageAmount * 1.10 -- + 10% damage on rear 
				elseif Angle > 70 and Angle < 110 then
					self.DamageData.DamageAmount = self.DamageData.DamageAmount * 1.05 -- + 5% damage on side
				elseif Angle > 250 and Angle < 290 then
					self.DamageData.DamageAmount = self.DamageData.DamageAmount * 1.05 -- + 5% damage on side
				elseif Angle > 150 and Angle < 210 then
					self.DamageData.DamageAmount = self.DamageData.DamageAmount * 0.95 -- - 5 % damage on front
				end
			end
		end
		Projectile.oldOnImpact(self, targetType, targetEntity)
	end,
	
	OldDoDamage = Projectile.DoDamage,
	DoDamage = function(self, instigator, DamageData, targetEntity)	
		-- Ready for hooking
		Projectile.OldDoDamage(self, instigator, DamageData, targetEntity)
    end,

	OldOnCollisionCheck = Projectile.OnCollisionCheck,
	OnCollisionCheck = function(self, other)
		local id = other:GetEntityId()

		-- If we return false the thing hitting us has no idea that it came into contact with us.
		-- By default, anything hitting us should know about it so we return true.

		if self:GetArmy() == other:GetArmy() then return false end

		local dnc_cats = categories.TORPEDO + categories.MISSILE + categories.DIRECTFIRE
		if EntityCategoryContains(dnc_cats, self) and EntityCategoryContains(dnc_cats, other) then
			return false
		end

		if other:GetBlueprint().Physics.HitAssignedTarget and other:GetTrackingTarget() ~= self then
			return false
		end

		local dnc
		for _, p in {{self, other}, {other, self}} do
			dnc = p[1]:GetBlueprint().DoNotCollideList
			if dnc then
				for k, v in dnc do
					if EntityCategoryContains(ParseEntityCategory(v), p[2]) then
						return false
					end
				end
			end
		end

		return true
    end,
}
