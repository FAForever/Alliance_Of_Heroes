------------------------
-- Alliance of Heroes --
---- Land Tech Tree ----
---- Franck83 2018 -----
------------------------

local Buff = import('/lua/sim/buff.lua')
local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')

Modifiers = {
	['Improved Hull'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH1') then
				BuffBlueprint {
					Name = 'Improved Hull',
					DisplayName = 'Improved Hull',
					BuffType = 'HEALTHTECH',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						MaxHealth = {
							DoNoFill = true,
							Add = bp.Defense.MaxHealth * 1 * Level,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'Improved Hull')
			end
		end,
	},
	['Light Bots Hull'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH1') and table.find(bp.Categories, 'BOT') then
				BuffBlueprint {
					Name = 'Light Bots Hull',
					DisplayName = 'Light Bots Hull',
					BuffType = 'HEALTHBOTTECH',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						MaxHealth = {
							DoNoFill = true,
							Add = 125 * Level,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'Light Bots Hull')
			end
		end,
	},
	['Nano Repair'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH1') then
				BuffBlueprint {
					Name = 'Nano Repair',
					DisplayName = 'Nano Repair',
					BuffType = 'Nano Repair',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						Regen = {
							Add = 1 * Level,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'Nano Repair')
			end
		end,
	},
	['Improved Hull 2'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH2') then
				BuffBlueprint {
					Name = 'Improved Hull 2',
					DisplayName = 'Improved Hull 2',
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
				Buff.ApplyBuff(self, 'Improved Hull 2')
			end
		end,
	},
	['Anti-Air Advanced Hull'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH2') and table.find(bp.Categories, 'ANTIAIR') then
				BuffBlueprint {
					Name = 'Anti-Air Advanced Hull',
					DisplayName = 'Anti-Air Advanced Hull',
					BuffType = 'HEALTHTECH',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						MaxHealth = {
							DoNoFill = true,
							Add = bp.Defense.MaxHealth * 0.40 * Level,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'Anti-Air Advanced Hull')
			end
		end,
	},
	['Missile Advanced Hull'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH2') and table.find(bp.Categories, 'INDIRECTFIRE') then
				BuffBlueprint {
					Name = 'Missile Advanced Hull',
					DisplayName = 'Missile Advanced Hull',
					BuffType = 'HEALTHTECH',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						MaxHealth = {
							DoNoFill = true,
							Add = bp.Defense.MaxHealth * 0.40 * Level,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'Missile Advanced Hull')
			end
		end,
	},
	['Combat Advanced Hull'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH2') then
				if table.find(bp.Categories, 'TANK') or table.find(bp.Categories, 'BOT') then
					BuffBlueprint {
						Name = 'Combat Advanced Hull',
						DisplayName = 'Combat Advanced Hull',
						BuffType = 'HEALTHTECH',
						Stacks = 'REPLACE',
						Duration = -1,
						Affects = {
							MaxHealth = {
								DoNoFill = true,
								Add = bp.Defense.MaxHealth * 0.40 * Level,
								Mult = 1,
							},
						},
					}
					Buff.ApplyBuff(self, 'Combat Advanced Hull')
				end
			end
		end,
	},		
	['Nano Repair 2'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH2') then
				BuffBlueprint {
					Name = 'Nano Repair 2',
					DisplayName = 'Nano Repair 2',
					BuffType = 'Nano Repair 2',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						Regen = {
							Add = 2 * Level,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'Nano Repair 2')
			end
		end,
	},
	['Obsidian Tank Shield'] = {
		OnCreate = function(self, Level)
			local bp = self:GetBlueprint()
			if bp.BlueprintId == 'ual0202' then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_ShieldPower', Level * 0.2)
			end
		end,
	},
	['Harbinger Shield'] = {
		OnCreate = function(self, Level)
			local bp = self:GetBlueprint()
			if bp.BlueprintId == 'ual0303' then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_ShieldPower', Level * 0.2)
			end
		end,
	},
	['Mobile Tech 2 Shield'] = {
		OnCreate = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH2') and table.find(bp.Categories, 'SHIELD') and table.find(bp.Categories, 'DEFENSE') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_ShieldPower', Level * 0.8)
			end
		end,
	},
	['Mobile Tech 3 Shield'] = {
		OnCreate = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH3') and table.find(bp.Categories, 'SHIELD') and table.find(bp.Categories, 'DEFENSE') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_ShieldPower', Level * 0.8)
			end
		end,
	},
	['Improved Hull 3'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH3') or table.find(bp.Categories, 'COMMAND') then
				BuffBlueprint {
					Name = 'Improved Hull 3',
					DisplayName = 'Improved Hull 3',
					BuffType = 'HEALTHTECH',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						MaxHealth = {
							DoNoFill = true,
							Add = bp.Defense.MaxHealth * 0.20 * Level,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'Improved Hull 3')
			end
		end,
	},
	['Anti-Air Advanced Hull 2'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH3') and table.find(bp.Categories, 'ANTIAIR') then
				BuffBlueprint {
					Name = 'Anti-Air Advanced Hull',
					DisplayName = 'Anti-Air Advanced Hull',
					BuffType = 'HEALTHTECH',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						MaxHealth = {
							DoNoFill = true,
							Add = bp.Defense.MaxHealth * 0.40 * Level,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'Anti-Air Advanced Hull')
			end
		end,
	},
	['Artillery Advanced Hull'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH3') and table.find(bp.Categories, 'ARTILLERY') then
				BuffBlueprint {
					Name = 'Artillery Advanced Hull',
					DisplayName = 'Artillery Advanced Hull',
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
				Buff.ApplyBuff(self, 'Artillery Advanced Hull')
			end
		end,
	},
	['Combat Advanced Hull 2'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH3') or table.find(bp.Categories, 'COMMAND') then
				if table.find(bp.Categories, 'TANK') or table.find(bp.Categories, 'BOT') or table.find(bp.Categories, 'COMMAND') then
					BuffBlueprint {
						Name = 'Combat Advanced Hull 2',
						DisplayName = 'Combat Advanced Hull 2',
						BuffType = 'HEALTHTECH',
						Stacks = 'REPLACE',
						Duration = -1,
						Affects = {
							MaxHealth = {
								DoNoFill = true,
								Add = bp.Defense.MaxHealth * 0.40 * Level,
								Mult = 1,
							},
						},
					}
					Buff.ApplyBuff(self, 'Combat Advanced Hull 2')
				end
			end
		end,
	},		
		
	['Nano Repair 3'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH3') or table.find(bp.Categories, 'COMMAND') then
				BuffBlueprint {
					Name = 'Nano Repair 3',
					DisplayName = 'Nano Repair 3',
					BuffType = 'Nano Repair',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						Regen = {
							Add = 3 * Level,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'Nano Repair 3')
			end
		end,
	},
	['Armors'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH1') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Armor', Level * 5)
			end
		end,
	},
	['Armor Layers'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH1') or table.find(bp.Categories, 'TECH2') or table.find(bp.Categories, 'TECH3') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_ArmorLayers', Level * 1)
			end
		end,
	},
	['High Damage Reducer'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH1') or table.find(bp.Categories, 'TECH2') or table.find(bp.Categories, 'TECH3') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_High Damage Reducer', Level * 5 + 10)
			end
		end,
	},
	['Defense'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH1') or table.find(bp.Categories, 'TECH2') or table.find(bp.Categories, 'TECH3') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Defense', Level * 5)
			end
		end,
	},
	['Health Drain'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH1') or table.find(bp.Categories, 'TECH2') or table.find(bp.Categories, 'TECH3') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Health Drain', Level)
			end
		end,
	},
	['Armors 2'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH2') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Armor', Level * 5)
			end
		end,
	},
	['Armor Anti-Artillery Reinforcement'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH2') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Armor_Artillery', Level * 8)
			end
		end,
	},
	['Armor Anti-Bomb Reinforcement'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH2') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Armor_Bomb', Level * 8)
			end
		end,
	},
	['Armor Anti-Direct Fire Naval Reinforcement'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH2') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Armor_Direct Fire Naval', Level * 8)
			end
		end,
	},
	['Armor Anti-Missile Reinforcement'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH2') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Armor_Missile', Level * 8)
			end
		end,
	},
	['Armors 3'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH3') or table.find(bp.Categories, 'COMMAND') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Armor', Level * 5)
			end
		end,
	},
		['Armor Anti-Artillery Reinforcement 2'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH3') or table.find(bp.Categories, 'COMMAND') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Armor_Artillery', Level * 8)
			end
		end,
	},
	['Armor Anti-Bomb Reinforcement 2'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH3') or table.find(bp.Categories, 'COMMAND') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Armor_Bomb', Level * 8)
			end
		end,
	},
	['Armor Anti-Direct Fire Naval Reinforcement 2'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH3') or table.find(bp.Categories, 'COMMAND') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Armor_Direct Fire Naval', Level * 8)
			end
		end,
	},
	['Armor Anti-Missile Reinforcement 2'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH3') or table.find(bp.Categories, 'COMMAND') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Armor_Missile', Level * 8)
			end
		end,
	},
	['Armor Anti-Direct Fire Experimental'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH1') or table.find(bp.Categories, 'TECH2') or table.find(bp.Categories, 'TECH3') or table.find(bp.Categories, 'COMMAND') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Armor_Direct Fire Experimental', Level * 8)
			end
		end,
	},
	['Ammunitions'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH1') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Ammunitions', Level * 0.05)
			end
		end,
	},
	['Ammunitions High Velocity'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH1') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Ammunitions High Velocity', Level)
			end
		end,
	},
	['Improved Aiming Cumputer'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			local id = self:GetEntityId()
			DM.SetProperty(id, 'Tech_Improved Aiming Cumputer', Level * 5)
		end,
	},
	['AP Ammunitions'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			local id = self:GetEntityId()
			DM.SetProperty(id, 'Tech_Armor Piercing', Level * 2)
		end,
	},
	['Improved Weapon Barrel Cooling'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH1') or table.find(bp.Categories, 'TECH2') or table.find(bp.Categories, 'TECH3') or table.find(bp.Categories, 'COMMAND') then
				local id = self:GetEntityId()
				-- for i, wep in bp.Weapon do
					-- if wep.Label == 'DeathWeapon' or wep.Label == 'DeathImpact' or  bp.Weapon.TargetType == 'RULEWTT_Projectile' or wep.DisplayName == 'Teleport in' or wep.Label =='ChronoDampener' or wep.Label =='CollossusDeath' or wep.Label =='MegalithDeath' then
					-- else
						-- if wep.Damage > 0 then
							-- Weap = self:GetWeapon(i)
							-- local bpwp = Weap:GetBlueprint()
							-- Weap:ChangeRateOfFire(bpwp.RateOfFire * (1 + (Level * 0.03)))
						-- end
					-- end
				-- end
				DM.SetProperty(id, 'Tech_Rate Of Fire', Level * 0.03)
			end
		end,
	},
	['Long Weapon Barrel'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH1') or table.find(bp.Categories, 'TECH2') or table.find(bp.Categories, 'TECH3') or table.find(bp.Categories, 'COMMAND') then
				local id = self:GetEntityId()
				-- for i, wep in bp.Weapon do
					-- if wep.Label == 'DeathWeapon' or wep.Label == 'DeathImpact' or  bp.Weapon.TargetType == 'RULEWTT_Projectile' or wep.DisplayName == 'Teleport in' or wep.Label =='ChronoDampener' or wep.Label =='CollossusDeath' or wep.Label =='MegalithDeath' then
					-- else
						-- if wep.Damage > 0 then
							-- Weap = self:GetWeapon(i)
							-- local bpwp = Weap:GetBlueprint()
							-- Weap:ChangeMaxRadius(bpwp.MaxRadius + Level)
						-- end
					-- end
				-- end
				DM.SetProperty(id, 'Tech_Range', Level)
			end
		end,
	},
	['Ammunitions 2'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH2') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Ammunitions', Level * 0.05)
			end
		end,
	},
	['Ammunitions Anti-Bot'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH2') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Damage to Bots', Level * 0.12)
			end
		end,
	},
	['Ammunitions Anti-Tank'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH2') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Damage to Tanks', Level * 0.12)
			end
		end,
	},
	['Ammunitions Anti-Naval'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH2') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Damage to Navals', Level * 0.12)
			end
		end,
	},
	['Ammunitions Anti-SubCommander'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH2') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Damage to SubCommanders', Level * 0.12)
			end
		end,
	},
	['Ammunitions Anti-Structure'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH2') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Damage to Structures', Level * 0.12)
			end
		end,
	},
	['Ammunitions 3'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH3') or table.find(bp.Categories, 'COMMAND') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Ammunitions', Level * 0.05)
			end
		end,
	},
	['Ammunitions 2 Anti-Bot'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH3') or table.find(bp.Categories, 'COMMAND') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Damage to Bots', Level * 0.12)
			end
		end,
	},
	['Ammunitions 2 Anti-Tank'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH3') or table.find(bp.Categories, 'COMMAND') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Damage to Tanks', Level * 0.12)
			end
		end,
	},
	['Ammunitions 2 Anti-Naval'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH3') or table.find(bp.Categories, 'COMMAND') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Damage to Navals', Level * 0.12)
			end
		end,
	},
	['Ammunitions 2 Anti-SubCommander'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH3') or table.find(bp.Categories, 'COMMAND') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Damage to SubCommanders', Level * 0.12)
			end
		end,
	},
	['Ammunitions 2 Anti-Structure'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH3') or table.find(bp.Categories, 'COMMAND') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Damage to Structures', Level * 0.12)
			end
		end,
	},
	['Ammunitions Anti-Experimental'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH3') or table.find(bp.Categories, 'COMMAND') then
				local id = self:GetEntityId()
				DM.SetProperty(id, 'Tech_Damage to Experimentals', Level * 0.12)
			end
		end,
	},
	['Engineering Suite'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH1') and table.find(bp.Categories, 'ENGINEER') then
				BuffBlueprint {
					Name = 'Engineering Suite',
					DisplayName = 'Engineering Suite',
					BuffType = 'BuildrateTech',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						BuildRate = {
							Add = 1 * Level,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'Engineering Suite')
			end
		end,
	},
	['Engineering Suite 2'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH2') and table.find(bp.Categories, 'ENGINEER') then
				BuffBlueprint {
					Name = 'Engineering Suite 2',
					DisplayName = 'Engineering Suite 2',
					BuffType = 'BuildrateTech',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						BuildRate = {
							Add = 3 * Level,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'Engineering Suite 2')
			end
		end,
	},
	['Engineering Suite 3'] = {
		OnStopBeingBuilt = function(self, Level)
			local bp = self:GetBlueprint()
			if table.find(bp.Categories, 'TECH3') and table.find(bp.Categories, 'ENGINEER') then
				BuffBlueprint {
					Name = 'Engineering Suite 3',
					DisplayName = 'Engineering Suite 3',
					BuffType = 'BuildrateTech',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						BuildRate = {
							Add = 5 * Level,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'Engineering Suite 3')
			end
		end,
	},
}
	