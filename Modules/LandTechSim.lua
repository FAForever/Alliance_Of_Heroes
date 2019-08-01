------------------------
-- Alliance of Heroes --
---- Land Tech Tree ----
---- Franck83 2018 -----
------------------------

local Buff = import('/lua/sim/buff.lua')
local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local LesserShield = import(ModPath..'Modules/Powers/LesserShield.lua')

Modifiers = {
	['Improved Logistics'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			DM.SetProperty('Global'..self:GetArmy(), 'Logistics_Tech', Level * 25)
		end,
	},	
	['Improved Hull Building'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'STRUCTURE') then
				BuffBlueprint {
					Name = 'Improved Hull Building',
					DisplayName = 'Improved Hull Building',
					BuffType = 'HEALTHTECH',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						MaxHealth = {
							DoNoFill = true,
							Add = bp.Defense.MaxHealth * 0.25 * Level,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'Improved Hull Building')
				self:AdjustHealth(self,bp.Defense.MaxHealth * 0.25 * (Level-PreviousLevel))
			end
		end,
	},
	['Improved Hull Aircraft'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'AIR') and (not table.find(bp.Categories, 'EXPERIMENTAL')) then
				BuffBlueprint {
					Name = 'Improved Hull Aircraft',
					DisplayName = 'Improved Hull Aircraft',
					BuffType = 'HEALTHTECH',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						MaxHealth = {
							DoNoFill = true,
							Add = bp.Defense.MaxHealth * 0.10 * Level,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'Improved Hull Aircraft')
				self:AdjustHealth(self,bp.Defense.MaxHealth * 0.10 * (Level-PreviousLevel))
			end
		end,
	},
	['Improved Hull Land units'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'LAND') and (not table.find(bp.Categories, 'EXPERIMENTAL')) then
				BuffBlueprint {
					Name = 'Improved Hull Land units',
					DisplayName = 'Improved Hull Land units',
					BuffType = 'HEALTHTECH',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						MaxHealth = {
							DoNoFill = true,
							Add = bp.Defense.MaxHealth * 0.15 * Level,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'Improved Hull Land units')
				self:AdjustHealth(self,bp.Defense.MaxHealth * 0.15 * (Level-PreviousLevel))
			end
		end,
	},
	['Improved Hull Light Bots'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			if bp.Defense.MaxHealth < 100 then
				BuffBlueprint {
					Name = 'Improved Hull Light Bots',
					DisplayName = 'Improved Hull Light Bots',
					BuffType = 'HEALTHBOTTECH',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						MaxHealth = {
							DoNoFill = true,
							Add = 25 * Level,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'Improved Hull Light Bots')
				self:AdjustHealth(self, 25 * (Level-PreviousLevel))
			end
		end,
	},
	['Improved Hull Naval units'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'NAVAL') and (not table.find(bp.Categories, 'EXPERIMENTAL')) then
				BuffBlueprint {
					Name = 'Improved Hull Naval units',
					DisplayName = 'Improved Hull Naval units',
					BuffType = 'HEALTHTECH',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						MaxHealth = {
							DoNoFill = true,
							Add = bp.Defense.MaxHealth * 0.10 * Level,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'Improved Hull Naval units')
				self:AdjustHealth(self,bp.Defense.MaxHealth * 0.10 * (Level-PreviousLevel))
			end
		end,
	},
	['Improved Hull Experimental units'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'EXPERIMENTAL') then
				BuffBlueprint {
					Name = 'Improved Hull Experimental units',
					DisplayName = 'Improved Hull Experimental units',
					BuffType = 'HEALTHTECH',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						MaxHealth = {
							DoNoFill = true,
							Add = bp.Defense.MaxHealth * 0.10 * Level,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'Improved Hull Experimental units')
				self:AdjustHealth(self,bp.Defense.MaxHealth * 0.10 * (Level-PreviousLevel))
			end
		end,
	},
	['Improved Regen'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			BuffBlueprint {
				Name = 'Improved Regen',
				DisplayName = 'Improved Regen',
				BuffType = 'REGENTECH',
				Stacks = 'REPLACE',
				Duration = -1,
				Affects = {
					Regen = {
						Add = 2 * Level,
						Mult = 1,
					},
				},
			}
			Buff.ApplyBuff(self, 'Improved Regen')
		end,
	},
	['Improved Shield Power'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			local id = self:GetEntityId()
			DM.SetProperty(id, 'Tech_Shield_MaxHealth_Bonus', Level * 0.15)
			local _ShieldMaxHealth = 0
			if bp.Enhancements.Shield.ShieldMaxHealth then
				_ShieldMaxHealth = bp.Enhancements.Shield.ShieldMaxHealth + bp.Enhancements.Shield.ShieldMaxHealth * Level * 0.15
				DM.SetProperty(id, 'Tech_Shield_MaxHealth', _ShieldMaxHealth)
				if self.MyShield then
					self.MyShield:SetMaxHealth(_ShieldMaxHealth)
					self.MyShield:AdjustHealth(self, bp.Enhancements.Shield.ShieldMaxHealth * Level * 0.15) 
				end
			end
			if bp.Defense.Shield.ShieldMaxHealth then
				_ShieldMaxHealth = bp.Defense.Shield.ShieldMaxHealth + bp.Defense.Shield.ShieldMaxHealth * Level * 0.15
				DM.SetProperty(id, 'Tech_Shield_MaxHealth', bp.Defense.Shield.ShieldMaxHealth * Level * 0.15)
				if self.MyShield then
					self.MyShield:SetMaxHealth(_ShieldMaxHealth)
					self.MyShield:AdjustHealth(self, bp.Defense.Shield.ShieldMaxHealth * Level * 0.15)
				end	
			end
			if self.MyShield and DM.GetProperty(id,'PrestigeClassPromoted') == 1 then
				_ShieldMaxHealth = _ShieldMaxHealth + LesserShield.GetShieldPower(self, true)
				self.MyShield:SetMaxHealth(_ShieldMaxHealth)
				self.MyShield:AdjustHealth(self, _ShieldMaxHealth * (1 + (Level-PreviousLevel) * 0.15))
			end
		end,
	},
	['Improved Shield Regen'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			local id = self:GetEntityId()
			local ShieldRegenRate = 0
			DM.SetProperty(id, 'Tech_Shield_RegenRate_Bonus', Level * 8)
			if bp.Enhancements.Shield.ShieldRegenRate then
				ShieldRegenRate = bp.Enhancements.Shield.ShieldRegenRate + Level * 8
				DM.SetProperty(id, 'Tech_Shield_RegenRate', Level * 8)
				if self.MyShield then
					self.MyShield:SetShieldRegenRate(ShieldRegenRate)
				end
			end
			if bp.Defense.Shield.ShieldRegenRate then
				ShieldRegenRate = bp.Defense.Shield.ShieldRegenRate + Level * 8
				DM.SetProperty(id, 'Tech_Shield_RegenRate', Level * 8)
				if self.MyShield then
					self.MyShield:SetShieldRegenRate(ShieldRegenRate)
				end	
			end
			if self.MyShield and DM.GetProperty(id,'PrestigeClassPromoted') == 1 then
				DM.SetProperty(id, 'Tech_Shield_RegenRate', Level * 8)
				-- LOG('My Shield')
				if ShieldRegenRate == 0 then
					-- LOG('No natural shield')
					LesserShield.GetShieldPower(self, true)
					ShieldRegenRate = ShieldRegenRate + Level * 8 + DM.GetProperty(id, 'Power_Shield_RegenRate', 0)
				else
					-- LOG('Natural shield')
					LesserShield.GetShieldPower(self, true)
					ShieldRegenRate = ShieldRegenRate + DM.GetProperty(id, 'Power_Shield_RegenRate', 0)
				end
				self.MyShield:SetShieldRegenRate(ShieldRegenRate)
			end
			
		end,
	},
	['Energy Drain'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			DM.SetProperty('Global'..self:GetArmy(), 'Energy Drain', Level * 8)
		end,
	},		
	['Improved Engineers Buildate'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'ENGINEER') then
				if table.find(bp.Categories, 'COMMAND') or table.find(bp.Categories, 'SUBCOMMANDER') then else
					local UnitTech = CF.GetUnitTech(self)
					local BuildRate = Level * UnitTech
					BuffBlueprint {
						Name = 'Improved Engineers Buildate',
						DisplayName = 'Improved Engineers Buildate',
						BuffType = 'BUILDRATETECH',
						Stacks = 'REPLACE',
						Duration = -1,
						Affects = {
							BuildRate = {
								Add = BuildRate,
								Mult = 1,
							},
						},
					}
					Buff.ApplyBuff(self, 'Improved Engineers Buildate')
				end
			end
		end,
	},
	['Improved Factory Buildate'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'FACTORY')  then
				local UnitTech = CF.GetUnitTech(self)
				local BuildRate = Level * UnitTech * 4
				BuffBlueprint {
					Name = 'Improved Factory Buildate',
					DisplayName = 'Improved Factory Buildate',
					BuffType = 'BUILDRATEFACTTECH',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						BuildRate = {
							Add = BuildRate,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'Improved Factory Buildate')
			end
		end,
	},
	['Improved Engineer Station Buildate'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'ENGINEERSTATION') or table.find(bp.Categories, 'STATIONASSISTPOD') then
				local UnitTech = CF.GetUnitTech(self)
				local BuildRate = Level * 12
				BuffBlueprint {
					Name = 'Improved Engineer Station Buildate',
					DisplayName = 'Improved Engineer Station Buildate',
					BuffType = 'BUILDRATEESTTECH',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						BuildRate = {
							Add = BuildRate,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'Improved Engineer Station Buildate')
			end
		end,
	},
	['Improved Commanders and SubCommanders Buildate'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') or table.find(bp.Categories, 'SUBCOMMANDER')  then
				local BuildRate = Level * 8
				BuffBlueprint {
					Name = 'Improved Com Buildate',
					DisplayName = 'Improved Com Buildate',
					BuffType = 'BUILDRATECOMTTECH',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						BuildRate = {
							Add = BuildRate,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'Improved Com Buildate')
			end
		end,
	},
	['Improved ACU Mass & Energy Production'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				local Mass = Level * 1
				local Energy = Level * 2
				BuffBlueprint {
					Name = 'Improved ACU Mass & Energy Production',
					DisplayName = 'Improved ACU Mass & Energy Production',
					BuffType = 'MASSENERGYPRODCOMTECH',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						EnergyProduction = {
							Add = Energy,
							Mult = 1,
						},
						MassProduction = {
							Add = Mass,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'Improved ACU Mass & Energy Production')
			end
		end,
	},
	['Improved Energy Production'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'ENERGYPRODUCTION') and table.find(bp.Categories, 'STRUCTURE') then
				local Energy = Level * 0.05
				BuffBlueprint {
					Name = 'Improved Energy Production',
					DisplayName = 'Improved Energy Production',
					BuffType = 'ENERGYPRODCOMTECH',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						EnergyProduction = {
							Add = Energy,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'Improved Energy Production')
			end
		end,
	},
	['Improved Energy Storage'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'COMMAND') then
				local EnergyS = (Level-PreviousLevel) * 4000
				local CurrentStorage = DM.GetProperty('Global'..self:GetArmy(), 'EnergyStorage')
				self:GetAIBrain():GiveStorage('Energy', CurrentStorage + EnergyS)
				DM.SetProperty('Global'..self:GetArmy(), 'EnergyStorage', CurrentStorage + EnergyS)
				DM.SetProperty('Global'..self:GetArmy(), 'EnergyStorageTechLevel', Level)
			end
		end,
	},
	['Improved Structures Armor'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			local id = self:GetEntityId()
			if table.find(bp.Categories, 'STRUCTURE') then
				DM.SetProperty(id, 'TechArmor', 5 * Level)
				DM.SetProperty(id, 'TechArmorLevel', Level)
			end
		end,
	},
	['Improved Naval Armor'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			local id = self:GetEntityId()
			if table.find(bp.Categories, 'NAVAL') then
				DM.SetProperty(id, 'TechArmor', 5 * Level)
				DM.SetProperty(id, 'TechArmorLevel', Level)
			end
		end,
	},
	['Improved Aircraft Armor'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			local id = self:GetEntityId()
			if table.find(bp.Categories, 'AIR') then
				DM.SetProperty(id, 'TechArmor', 5 * Level)
				DM.SetProperty(id, 'TechArmorLevel', Level)
			end
		end,
	},
	['Improved Land Units Armor'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			local id = self:GetEntityId()
			if table.find(bp.Categories, 'LAND') and (not table.find(bp.Categories, 'EXPERIMENTAL')) then
				DM.SetProperty(id, 'TechArmor', 5 * Level)
				DM.SetProperty(id, 'TechArmorLevel', Level)
			end
		end,
	},
	['Improved Experimental Armor'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			local id = self:GetEntityId()
			if table.find(bp.Categories, 'EXPERIMENTAL') then
				DM.SetProperty(id, 'TechArmor', 5 * Level)
				DM.SetProperty(id, 'TechArmorLevel', Level)
			end
		end,
	},
	['High Damage Reducer'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local id = self:GetEntityId()
			DM.SetProperty(id, 'Tech_High Damage Reducer', 5 * Level)
		end,
	},
	['Improved Defense'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local id = self:GetEntityId()
			DM.SetProperty(id, 'Tech_Defense', 15 * Level)
		end,
	},
	['Improved Turrets Damage'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'DEFENSE') and table.find(bp.Categories, 'STRUCTURE') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Damage', 25 * Level)
			end
		end,
	},
	['Improved Aircrafts Damage'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'AIR') and (not table.find(bp.Categories, 'EXPERIMENTAL')) then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Damage', 10 * Level)
			end
		end,
	},
	['Improved Naval Damage'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'NAVAL') and (not table.find(bp.Categories, 'EXPERIMENTAL')) then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Damage', 10 * Level)
			end
		end,
	},
	['Improved Land Units Damage'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'LAND') and (not table.find(bp.Categories, 'EXPERIMENTAL')) then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Damage', 15 * Level)
			end
		end,
	},
	['Improved Experimentals Damage'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'EXPERIMENTAL') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Damage', 10 * Level)
			end
		end,
	},
	['Improved Rate of Fire'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local bp = self:GetBlueprint()
			local id = self:GetEntityId()
			if not table.find(bp.Categories, 'EXPERIMENTAL') then
				DM.SetProperty(id, 'Tech_Rate Of Fire', Level * 0.05)
				local rof = 1 - Level * 0.05
				BuffBlueprint {
					Name = 'Improved rof',
					DisplayName = 'Improved rof',
					BuffType = 'DAMAGETECH',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						RateOfFire = {
							Add = 0,
							Mult = rof,
						},
					},
				}
				Buff.ApplyBuff(self, 'Improved rof')
			end
		end,
	},
	['Improved Armor Piercing'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local id = self:GetEntityId()
			DM.SetProperty(id, 'Tech_AP', 5 * Level)
		end,
	},
	['Improved Accuracy'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local id = self:GetEntityId()
			DM.SetProperty(id, 'Tech_Accuracy', 15 * Level)
		end,
	},
	['Improved Range'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local id = self:GetEntityId()
			local bp = self:GetBlueprint()
			DM.SetProperty(id, 'Tech_Range', 1 * Level)
			if bp.Weapon != nil then
				for i, wep in bp.Weapon do
					if wep.Label == 'DeathWeapon' or wep.Label == 'DeathImpact' or  bp.Weapon.TargetType == 'RULEWTT_Projectile' or wep.DisplayName == 'Teleport in' or wep.Label =='ChronoDampener' or wep.Label =='CollossusDeath' or wep.Label =='MegalithDeath' then
					else
						if wep.Damage > 0 then
							Weap = self:GetWeapon(i)
							local RangeUpgrade = DM.GetProperty(id, 'Upgrade_Weapon_'..i..'_'..'Range', 0) or 0
							local EnhRangeBonus = 0 -- Range increase from AOC vanilla upgrades
							local TechRange = DM.GetProperty(id, 'Tech_Range', 0)
							if self:HasEnhancement('CrysalisBeam') or self:HasEnhancement('HeavyAntiMatterCannon') or  self:HasEnhancement('CoolingUpgrade') or  self:HasEnhancement('RateOfFire') or  self:HasEnhancement('PhasonBeamAir') then EnhRangeBonus =  22 end -- ACU range enh compatibility 
							local TotalRadius = wep.MaxRadius + RangeUpgrade + EnhRangeBonus + TechRange
							Weap:ChangeMaxRadius(TotalRadius)
						end
					end
				end
			end
		end,
	},
	['Health Drain'] = {
		InstantUpgrade = function(self, Level, PreviousLevel)
			local id = self:GetEntityId()
			DM.SetProperty(id, 'Tech_Health Drain', 2 * Level)
		end,
	},
}

	