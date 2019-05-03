local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local LandTech = import(ModPath..'Modules/LandTechSim.lua').Modifiers

BaseClassBlueprint = {
	Fighter = {
		Stance = {
			Normal = { 
				Damage_Mod = 1,
				Defense_Mod = 1,
				Defense_Add = 0,
				Attack_Mod = 1,
				Attack_Add = 0,
				Regen_Mod = 1,
				StaminaRegen_Mod = 1,
				Move_Mod = 1,
				RateOfFire_Mod = 1,
				PowerStrengh_Mod = 1,
				Plasma_Resist = 1,
			},
			Defensive = { 
				Defense_Mod = 1.50,
				Attack_Mod = 0.7,
				StaminaRegen_Mod = 2,
				Move_Mod = 0.8,
				RateOfFire_Mod = 0.8,
			},
			Offensive = { 
				Damage_Mod = 1.5,
				Defense_Mod = 0.25,
				Attack_Mod = 1,
				StaminaRegen_Mod = 0.6,
				RateOfFire_Mod = 1.34,
			},
			Precise = { 
				Attack_Mod = 1.7,
				RateOfFire_Mod = 0.75,
			},	
		},
		DamagePromotionModifier = 0.25,
		HealthGainModifier = 2,
		StaminaGainModifier = 1,
		CapacitorGainModifier = 1,
	},
	Support = {
		Stance = {
			Normal = { 
				Damage_Mod = 1,
				Defense_Mod = 1,
				Defense_Add = 0,
				Attack_Mod = 1,
				Attack_Add = 0,
				Regen_Mod = 1,
				StaminaRegen_Mod = 1,
				Move_Mod = 1,
				RateOfFire_Mod = 1,
				PowerStrengh_Mod = 1,
				Plasma_Resist = 1,
			},
			Defensive = { 
				Defense_Mod = 1.5,
				PowerStrengh_Mod = 0.66,
			},
			Offensive = { 
				Defense_Mod = 0.5,
				PowerStrengh_Mod = 1.5,
			},
			Precise = { 
				Attack_Mod = 1.5,
				PowerStrengh_Mod = 0.8,
			},	
		},
		DamagePromotionModifier = 0.25,
		HealthGainModifier = 1.2,
		StaminaGainModifier = 0.25,
		CapacitorGainModifier = 3,
	},
	Rogue = {
		Stance = {
			Normal = { 
				Damage_Mod = 1,
				Defense_Mod = 1,
				Defense_Add = 0,
				Attack_Mod = 1,
				Attack_Add = 0,
				Regen_Mod = 1,
				StaminaRegen_Mod = 1,
				Move_Mod = 1,
				RateOfFire_Mod = 1,
				PowerStrengh_Mod = 1,
				Plasma_Resist = 1,
			},
			Defensive = { 
				Defense_Mod = 1.50,
				Attack_Mod = 0.7,
				StaminaRegen_Mod = 1.7,
				Damage_Mod = 0.8,
			},
			Offensive = { 
				Defense_Mod = 0.25,
				Attack_Mod = 0.75,
				RateOfFire_Mod = 1.33,
			},
			Precise = { 
				Attack_Mod = 2,
				Damage_Mod = 0.75,
			},	
		},
		DamagePromotionModifier = 0.25,
		HealthGainModifier = 1.6,
		StaminaGainModifier = 1.25,
		CapacitorGainModifier = 1,
	},
	Ardent = {
		Stance = {
			Normal = { 
				Damage_Mod = 1,
				Defense_Mod = 1,
				Defense_Add = 0,
				Attack_Mod = 1,
				Attack_Add = 0,
				Regen_Mod = 1,
				StaminaRegen_Mod = 1,
				Move_Mod = 1,
				RateOfFire_Mod = 1,
				PowerStrengh_Mod = 1,
				Plasma_Resist = 1,
			},
			Defensive = {
				Plasma_Resist = 0.35,
				Defense_Mod = 1.5,
				PowerStrengh_Mod = 0.35,
				Attack_Mod = 0.88,
			},
			Offensive = { 
				PowerStrengh_Mod = 1.5,
			},
			Precise = { 
				Attack_Mod = 1.7,
			},			
		},
		DamagePromotionModifier = 0.25,
		HealthGainModifier = 1,
		StaminaGainModifier = 0.25,
		CapacitorGainModifier = 4,
	},
}

StanceRank = {
	Guardian = {
		Fighter = {
			Defensive = 1,
			Precise = 0.5,
			Offensive = 0.25,
			Normal = 1,
		},
		Support = {
			Defensive = 1,
			Precise = 0.5,
			Offensive = 0.25,
			Normal = 1,
		},
	},
	Dreadnought = {
		Fighter = {
			Defensive = 1,
			Precise = 1,
			Offensive = 1,
			Normal = 1,
		},
	},
	Ranger = {
		Fighter = {
			Defensive = 0.625,
			Precise = 0.875,
			Offensive = 0.5,
			Normal = 1,
		},
		Rogue = {
			Defensive = 0.625,
			Precise = 0.625,
			Offensive = 0.5,
			Normal = 1,
		},
	},
	Bard = {
		Ardent = {
			Defensive = 0.875,
			Precise = 0.625,
			Offensive = 0.5,
			Normal = 1,
		},
		Rogue = {
			Defensive = 0.875,
			Precise = 0.625,
			Offensive = 0.625,
			Normal = 1,
		},
	},
	Restorer = {
		Support = {
			Defensive = 1,
			Precise = 1,
			Offensive = 1,
			Normal = 1,
		},
	},
}	
	
		

PrestigeClass = {
	['Fighter Guardian'] = {
		IsAvailable = function(id)
			if DM.GetProperty(id,'Military') == true then return true end
		end,
		StanceLevel = function(stance, BaseClass)
			return StanceRank.Guardian[BaseClass][stance] or 1
		end,
		PromoteCostModifier = function(id)
			return  0.7
		end,
		OnPromote = function(id)
			local unit = GetUnitById(id)
			DM.SetProperty(id, 'BaseClass', 'Fighter')
			if not DM.GetProperty(id, 'Restoration') then DM.SetProperty(id, 'Restoration', 0) DM.SetProperty(id, 'Restoration_TrainingWeight', 50) end
			if not DM.GetProperty(id, 'Medium Armor Mastery') then DM.SetProperty(id, 'Medium Armor Mastery', 0) end
			if not DM.GetProperty(id, 'Heavy Armor Mastery') then DM.SetProperty(id, 'Heavy Armor Mastery', 0) DM.SetProperty(id, 'Heavy Armor Mastery_TrainingWeight', 50) end
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			if BaseClass == 'Fighter' then 
				if not DM.GetProperty(id, 'Medium Armor Mastery') then DM.SetProperty(id, 'Medium Armor Mastery', 0) end
			end
			DM.SetProperty(id, 'Weapon Skill_TrainingWeight', 20)
			OnPromoteGlobal(id)
		end,
		Description = function(id)
			local desc = 'The Fighter Guardian is a balanced class. He protects and repairs defense buildings.'
			return desc
		end,
		MaxHealthMod = 0.48,
	},
	['Support Guardian'] = {
		IsAvailable = function(id)
			if DM.GetProperty(id,'Military') == true then return true end
		end,
		StanceLevel = function(stance, BaseClass)
			return StanceRank.Guardian[BaseClass][stance] or 1
		end,
		PromoteCostModifier = function(id)
			return  0.7
		end,
		OnPromote = function(id)
			local unit = GetUnitById(id)
			DM.SetProperty(id, 'BaseClass', 'Support')
			if not DM.GetProperty(id, 'Restoration') then DM.SetProperty(id, 'Restoration', 0) DM.SetProperty(id, 'Restoration_TrainingWeight', 50) end
			if not DM.GetProperty(id, 'Light Armor Mastery') then DM.SetProperty(id, 'Light Armor Mastery', 0) end
			if not DM.GetProperty(id, 'Medium Armor Mastery') then DM.SetProperty(id, 'Medium Armor Mastery', 0) end
			local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
			DM.SetProperty(id, 'Weapon Skill_TrainingWeight', 20)
			OnPromoteGlobal(id)
		end,
		Description = function(id)
			local desc = 'The Support Guardian is a defensive class. He protects and repairs defense buildings. He got a huge energy storage and energy to mass converter.'
			return desc
		end,
		MaxHealthMod = 0.45,
	},
	['Fighter Dreadnought'] = {
		IsAvailable = function(id)
			if DM.GetProperty(id,'Military') == true then return true end
		end,
		StanceLevel = function(stance, BaseClass)
			return StanceRank.Dreadnought[BaseClass][stance] or 1
		end,
		PromoteCostModifier = function(id)
			if DM.GetProperty(id,'Military') == true then	
				return  0.7
			end
		end,
		OnPromote = function(id)
			DM.SetProperty(id, 'BaseClass', 'Fighter')
			if not DM.GetProperty(id, 'Heavy Armor Mastery') then DM.SetProperty(id, 'Heavy Armor Mastery', 0) end
			if not DM.GetProperty(id, 'Medium Armor Mastery') then DM.SetProperty(id, 'Medium Armor Mastery', 0) end
			OnPromoteGlobal(id)
		end,
		Description = function(id)
			local desc = 'An Dreadnought is a strong combat class. ..............'
			return desc
		end,
		MaxHealthMod = 0.60,
	},
	['Fighter Ranger'] = {
		IsAvailable = function(id)
			if DM.GetProperty(id,'Military') == true then return true end
		end,
		StanceLevel = function(stance, BaseClass)
			return StanceRank.Ranger[BaseClass][stance] or 1
		end,
		PromoteCostModifier = function(id)
			if DM.GetProperty(id,'Military') == true then	
				return  0.7
			end
		end,
		OnPromote = function(id)
			DM.SetProperty(id, 'BaseClass', 'Fighter')
			if not DM.GetProperty(id, 'Medium Armor Mastery') then DM.SetProperty(id, 'Medium Armor Mastery', 0) end
			if not DM.GetProperty(id, 'Rangercraft') then DM.SetProperty(id, 'Rangercraft', 0) end
			OnPromoteGlobal(id)
		end,
		Description = function(id)
			local desc = 'A Fighter Ranger is a good self-sufficient offensive class ....'
			return desc
		end,
		MaxHealthMod = 0.45,
	},
	[ 'Rogue Ranger'] = {
		IsAvailable = function(id)
			if DM.GetProperty(id,'Military') == true then return true end
		end,
		StanceLevel = function(stance, BaseClass)
			return StanceRank.Ranger[BaseClass][stance] or 1
		end,
		PromoteCostModifier = function(id)
			if DM.GetProperty(id,'Military') == true then	
				return  0.7
			end
		end,
		OnPromote = function(id)
			DM.SetProperty(id, 'BaseClass', 'Rogue')
			if not DM.GetProperty(id, 'Light Armor Mastery') then DM.SetProperty(id, 'Light Armor Mastery', 0) end
			if not DM.GetProperty(id, 'Rangercraft') then DM.SetProperty(id, 'Rangercraft', 0) end
			OnPromoteGlobal(id)
		end,
		Description = function(id)
			local desc = 'A Rogue Ranger is a fast self-sufficient harassing class ....'
			return desc
		end,
		MaxHealthMod = 0.38,
	},
	Elite = {
		IsAvailable = function(id)
			return false
		end,
		StanceLevel = function(stance, BaseClass)
			if stance == 'Defensive' then
				return 0.25
			elseif stance == 'Precise' then
				return 0.25
			elseif stance == 'Offensive' then
				return 0.25
			else
				return 1
			end
		end,
		PromoteCostModifier = function(id)
			if DM.GetProperty(id,'Military') == true then	
				return 0.35
			else
				return 0.2
			end
		end,
		OnPromote = function(id)
			local unit = GetUnitById(id)
			unit:ExecutePower('LesserShield')
			DM.SetProperty(id, 'Over Fire_AutoCast', 1)
			DM.SetProperty(id, 'Upgrade_Armor_Shield Absorb DF', 40)
			DM.SetProperty(id, 'Upgrade_Armor_Shield Absorb DF_Level', 2)
			DM.SetProperty(id, 'Upgrade_Armor_Shield Absorb DF Experimental', 75)
			DM.SetProperty(id, 'Upgrade_Armor_Shield Absorb DF Experimental_Level', 3)
			DM.SetProperty(id, 'Upgrade_Armor_Shield Absorb Bomb', 120)
			DM.SetProperty(id, 'Upgrade_Armor_Shield Absorb Bomb_Level', 3)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Armor Piercing', 82)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Armor Piercing_Level', 2)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Damage to All Units', 20)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Damage to All Units_Level', 1)
			DM.SetProperty(id, 'StanceState', 'Offensive')
			OnPromoteGlobal(id)
		end,
		Description = function(id)
			local desc = 'An Elite is a cheaper and lesser Hero. It has a inferior number of powers and upgrades and relies essentially on shield to survive.....'
			return desc
		end,
		MaxHealthMod = 0.25,
	},
	['Rogue Bard'] = {
		IsAvailable = function(id)
			if DM.GetProperty(id,'Military') == true then return true end
		end,
		StanceLevel = function(stance, BaseClass)
			return StanceRank.Bard[BaseClass][stance] or 1
		end,
		PromoteCostModifier = function(id)
			return 0.7
		end,
		OnPromote = function(id)
			DM.SetProperty(id, 'BaseClass', 'Rogue')
			if not DM.GetProperty(id, 'Bardsong') then DM.SetProperty(id, 'Bardsong', 0) end
			if not DM.GetProperty(id, 'CurrentBardsong') then DM.SetProperty(id, 'CurrentBardsong', 'None') end
			if not DM.GetProperty(id, 'Light Armor Mastery') then DM.SetProperty(id, 'Light Armor Mastery', 0) end
			local unit = GetUnitById(id)
			unit:ExecutePower('GentleMelody')
			OnPromoteGlobal(id)
		end,
		Description = function(id)
			local desc = 'The Rogue Bard is a jack all trades class. His chants can buff the eco, heal units, damage/speed/regen boost...... '
			return desc
		end,
		MaxHealthMod = 0.35,
	},
	['Ardent Bard'] = {
		IsAvailable = function(id)
			if DM.GetProperty(id,'Military') == true then return true end
		end,
		StanceLevel = function(stance, BaseClass)
			return StanceRank.Bard[BaseClass][stance] or 1
		end,
		PromoteCostModifier = function(id)
			return 0.7
		end,
		OnPromote = function(id)
			DM.SetProperty(id, 'BaseClass', 'Ardent')
			if not DM.GetProperty(id, 'Bardsong') then DM.SetProperty(id, 'Bardsong', 0) end
			if not DM.GetProperty(id, 'CurrentBardsong') then DM.SetProperty(id, 'CurrentBardsong', 'None') end
			local unit = GetUnitById(id)
			unit:ExecutePower('GentleMelody')
			OnPromoteGlobal(id)
		end,
		Description = function(id)
			local desc = 'The Ardent Bard is a support class with a strong dread disonnance power. His chants can buff the eco, heal units, damage/speed/regen boost...... '
			return desc
		end,
		MaxHealthMod = 0.35,
	},
	['Support Restorer'] = {
		IsAvailable = function(id)
			if DM.GetProperty(id,'Military') == true then return true end
		end,
		StanceLevel = function(stance, BaseClass)
			return StanceRank.Restorer[BaseClass][stance] or 1
		end,
		PromoteCostModifier = function(id)
			return 0.7
		end,
		OnPromote = function(id)
			DM.SetProperty(id, 'BaseClass', 'Support')
			if not DM.GetProperty(id, 'Restoration') then DM.SetProperty(id, 'Restoration', 0) end
			if not DM.GetProperty(id, 'Benediction') then DM.SetProperty(id, 'Benediction', 0) end
			if not DM.GetProperty(id, 'Medium Armor Mastery') then DM.SetProperty(id, 'Medium Armor Mastery', 0) end
			local unit = GetUnitById(id)
			local bp = unit:GetBlueprint()
			if table.find(bp.Categories,'COMMAND') then
				DM.SetProperty(id, 'BaseClass', 'Support')
			end
			OnPromoteGlobal(id)
		end,
		Description = function(id)
			local desc = 'The Restorer is a support Class. It mainly restoreS shields and health at very high efficiency. He got a huge energy storage. On the combat side, the Restorer got the longest stun of all classes.'
			return desc
		end,
		MaxHealthMod = 1,
	},
}

-- OnPromoteGlobal (Global Callback on each promotion)
OnPromoteGlobal = function(id)
	local unit = GetUnitById(id)
	local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
	local bp = unit:GetBlueprint()	
	if table.find(bp.Categories,'COMMAND') then else
		-- Dynamic Range feature
		unit.RangeFromHillBonusThread = unit:ForkThread(unit.RangeFromHillBonus)
		-- Dynamic data update
		unit.UpdateActivityThread = unit:ForkThread(unit.UpdateActivity)
	end
		-- Storage feature
	if BaseClass == 'Support' then
		DM.IncProperty(id, 'Restoration', 70)
		if not DM.GetProperty('Global'..unit:GetArmy(), 'EnergyStorage') then
			DM.SetProperty('Global'..unit:GetArmy(), 'EnergyStorage', 0)
		end
		local Power = math.ceil(math.pow(bp.Economy.BuildCostMass, 0.9))
		local CurrentStorage = DM.GetProperty('Global'..unit:GetArmy(), 'EnergyStorage')
		unit:GetAIBrain():GiveStorage('Energy', CurrentStorage + Power * 2000)
		DM.SetProperty('Global'..unit:GetArmy(), 'EnergyStorage', CurrentStorage + Power * 2000)
		DM.IncProperty(id, 'Dexterity', -10)
		DM.IncProperty(id, 'Hull', 5)
		DM.IncProperty(id, 'Energy', 5)
	elseif 	BaseClass == 'Rogue' then
		DM.IncProperty(id, 'Dexterity', 5)
		DM.IncProperty(id, 'Intelligence', 5)
		DM.IncProperty(id, 'Energy', -10)
	elseif 	BaseClass == 'Fighter' then
		DM.IncProperty(id, 'Puissance', 5)
		DM.IncProperty(id, 'Intelligence', -10)
		DM.IncProperty(id, 'Hull', 5)	
	elseif 	BaseClass == 'Ardent' then
		DM.IncProperty(id, 'Puissance', -10)
		DM.IncProperty(id, 'Intelligence', 10)
		DM.IncProperty(id, 'Energy', 5)	
	end
	-- Tech feature applied on promotion
	local HeroesList = CF.GetPlayerHeroesList(unit:GetAIBrain())
	for _,Hero in HeroesList do
		local bp = Hero:GetBlueprint()
		if table.find(bp.Categories, 'LAND') and table.find(bp.Categories, 'MOBILE') then
			if table.find(bp.Categories, 'EXPERIMENTAL') then
			else
				for tech, _ in LandTech do
					if DM.GetProperty('Global'..unit:GetArmy(), 'LandMobileTech'..tech) then	
						local level = DM.GetProperty('Global'..unit:GetArmy(), 'LandMobileTech'..tech)
						if LandTech[tech].OnStopBeingBuilt then
							LandTech[tech].OnStopBeingBuilt(unit, level) -- Executing Tech tree node script
						end
						if LandTech[tech].OnCreate then
							LandTech[tech].OnCreate(unit, level) -- Executing Tech tree node script
						end
						
					end
				end
			end
		end
	end
	unit:UpdateUnitData(nil, 0, false)
end
