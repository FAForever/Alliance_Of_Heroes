local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Proj = import(ModPath..'Modules/ProjectilesId.lua')
local BCbp = import(ModPath..'Modules/ClassDefinitions.lua').BaseClassBlueprint

local OldShield = Shield
Shield = Class(OldShield, Entity) {

	OldOnCreate = Shield.OnCreate,
	OnCreate = function(self, spec)
		-- AOH Custom shield data
		-- modding specs
		local Tech_ShieldPower = DM.GetProperty(spec.Owner.EntityId, 'Tech_ShieldPower', 0)
		local Power_Shield_MaxHealth = DM.GetProperty(spec.Owner.EntityId, 'Power_Shield_MaxHealth', 0)
		local Power_Shield_RegenRate = DM.GetProperty(spec.Owner.EntityId, 'Power_Shield_RegenRate', 0)
		spec.ShieldMaxHealth = spec.ShieldMaxHealth * (1 +  Tech_ShieldPower)
		if Power_Shield_MaxHealth > 0 then spec.ShieldMaxHealth = spec.ShieldMaxHealth + Power_Shield_MaxHealth end
		if Power_Shield_RegenRate > 0 then spec.ShieldRegenRate = spec.ShieldRegenRate + Power_Shield_RegenRate end
		self.OldOnCreate(self, spec)
	end,

	OldOnDamage = Shield.OnDamage,
	OnDamage = function(self, instigator, amount, vector, ProjectileId)
		if instigator then 
			instigator.HasFired = true 
		end
		local id =  self.Owner:GetEntityId()
		if not self.Owner:GetTargetEntity() then
			if self.Owner.MissionState == 'Free' and DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 and DM.GetProperty(id, 'Behaviour', 'Standing') ~= 'Standing' then
				self.Owner.PreviousPosition = self.Owner:GetPosition()
				local bp = self.Owner:GetBlueprint()
				if instigator and CF.GetUnitLayerType(instigator) == 'LAND' and table.find(bp.Categories, 'DIRECTFIRE') then
					self.Owner.MissionState = 'InMission'
					self.Owner.PursueThread = self.Owner:ForkThread(self.Owner.PursueInstigator, instigator)
				end
			end
		end
		AmountMod = amount
		-- Beam damage modifiers
		-- Beams data are no refreshing at each hit, so we can't upload them in projectile data. So we need to mod them on target hit.
		local Projectile = Proj.Projectiles['ProjId'..ProjectileId]
		
		-- Shield Damage Modifier
		-- LOG(repr(Projectile.ShieldDamageMod))
		AmountMod = AmountMod * (Projectile.ShieldDamageMod or 1)
		
		if Projectile.WeaponNature == 'Beam' then
			if instigator then
				local idi = instigator:GetEntityId()
				local BaseClass =  DM.GetProperty(idi, 'BaseClass', 'Fighter')
				local PrestigeClass =  DM.GetProperty(idi, 'PrestigeClass', 'Elite')
				local DamageRating =  CF.GetDamageRating(instigator) or 0
				local DamageBuff = (AoHBuff.GetBuffValue(instigator, 'Damage', 'ALL') / 100) or 0
				local DamageClassMod = 0
				if DM.GetProperty(idi,'PrestigeClassPromoted') == 1 then
					if DM.GetProperty(idi, 'Stamina') > 5 then
						DamageClassMod = BCbp[BaseClass]['DamagePromotionModifier']
					end
				end
				AmountMod = AmountMod * (1 + DamageClassMod + DamageBuff + DamageRating)
				if Projectile.DisplayName == 'Cold Beam' then
					local ColdBeamDamMod = 1
					local BCMod = {Fighter = 1, Rogue = 0.75, Support = 0.25, Ardent = 0.25}
					local PCMod = {Elite = 0, Guardian = 0.25, Dreadnought = 0.75, Bard = 0}
					ColdBeamDamMod = (BCMod[BaseClass] or 0.25 + (BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
					AmountMod = AmountMod * ColdBeamDamMod
				end
			end
		end
		-- Shield Abs. Values
		local ShieldAbs = 1
		local WeaponCategoryList = {'Direct Fire', 'Direct Fire Naval', 'Direct Fire Experimental',  'Artillery', 'Bomb', 'Missile'}
		if DM.GetProperty(id, 'Upgrade_Armor_Shield Absorb') then
			ShieldAbs =  1 + DM.GetProperty(id, 'Upgrade_Armor_Shield Absorb', 0) / 100
		end
		if table.find(WeaponCategoryList, Projectile.WeaponCategory) then
			local ModWc = string.gsub(Projectile.WeaponCategory, 'Direct Fire', 'DF')
			ShieldAbs =  ShieldAbs + (DM.GetProperty(id, 'Upgrade_Armor_Shield Absorb '..ModWc, 0)) / 100
		end
		AmountMod = AmountMod / ShieldAbs
		self.OldOnDamage(self, instigator, AmountMod, vector, ProjectileId)
    end,

}

OldPersonalBubble = PersonalBubble
PersonalBubble = Class(OldPersonalBubble) {
	OnCreate = function(self, spec)
        OldShield.OnCreate(self, spec)

        -- Store off useful values from the blueprint
        local OwnerBp = self.Owner:GetBlueprint()

        self.SizeX = OwnerBp.SizeX
        self.SizeY = OwnerBp.SizeY
        self.SizeZ = OwnerBp.SizeZ

        self.ShieldSize = spec.ShieldSize

        -- Manually disable the bubble shield's collision sphere after its creation so it acts like the new personal shields
        self:SetCollisionShape('None')
        self:SetType('Personal')
	end,
}


OldPersonalShield = PersonalShield
PersonalShield = Class(OldPersonalShield) {
	OldOnCreate = PersonalShield.OnCreate,
    OnCreate = function(self, spec)
		-- AOH Custom shield data
		-- modding specs
		local Tech_ShieldPower = DM.GetProperty(spec.Owner.EntityId, 'Tech_ShieldPower', 0)
		spec.ShieldMaxHealth = spec.ShieldMaxHealth * (1 +  Tech_ShieldPower)
		self.OldOnCreate(self, spec)
    end,
}