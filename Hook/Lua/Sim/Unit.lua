------------------------------
-- Alliance of Heroes Mod ----
-- Franck83 [2017-2018] ------
------------------------------

local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local FX = import(ModPath..'Modules/Effects.lua')
local BCbp = import(ModPath..'Modules/ClassDefinitions.lua').BaseClassBlueprint
local PC = import(ModPath..'Modules/ClassDefinitions.lua').PrestigeClass
local util = import(ModPath..'Hook/lua/utilities.lua')
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local Training = import(ModPath..'Modules/Training.lua')
local Proj = import(ModPath..'Modules/ProjectilesId.lua')
local ArmorModifiers =  import(ModPath..'Modules/ArmorModifiers.lua')
local WeaponModifiers =  import(ModPath..'Modules/WeaponModifiers.lua')
local LandTech = import(ModPath..'Modules/LandTechSim.lua').Modifiers
local Powers = import(ModPath..'Modules/Powers.lua').Powers
local FxId = 0
local Event = {}
local Imperial_Troops = import(ModPath..'Modules/Imperial_Troops.lua').Troops
local Imperial_Experimentals = import(ModPath..'Modules/Imperial_Troops.lua').Experimentals
-- ColdBeam damage is different depending of classes
local ColdBeamBCMod = import(ModPath..'Modules/Powers/ColdBeam.lua').BCMod
local ColdBeamPCMod = import(ModPath..'Modules/Powers/ColdBeam.lua').PCMod

local OldUnit = Unit
Unit = Class(OldUnit) {
	OldOnCreate = Unit.OnCreate,
	OnCreate = function(Unit)
		Unit.OldOnCreate(Unit)
		if not Unit then return end
		local bp = Unit:GetBlueprint()
		if table.find(bp.Categories, 'SELECTABLE') and Unit.Dead == false then
			local id = Unit:GetEntityId()
			Unit.InstigatorsData = {} -- We record Instigators that hit the unit
			Unit.GlobalInstigatorAtr = 0	-- Here we store the combined Attack rating from unit that are currently firing the unit. The unit will harder dodge several opponents.
			Unit.AoHBuffs = {} -- Extended AOH Buffs and debuffs Applied to the unit.
			Unit.UndoRemoveBuffList = {} -- Internal use for aoh buff system
			Unit.WeaponBuffs = {} --  Extended AOH Buffs and debuffs that will be load and executed on next weapon fire against opponents.
			Unit.Dodge = 0
			Unit.PreviousPosition = Unit:GetPosition()
			Unit.MissionState = 'Free'
			Unit.MassKilled = 0
			Unit.HpHealed = 0
			Unit.MassKilledRank = 0
			Unit.HpHealedRank = 0
			Unit.FamePoints = 0
			Unit.HasFired = false -- we add a property to determinate if the unit fired (set to true on each fire. Use for XP)
			DM.SetProperty(id, 'Promoting', 0)
			DM.SetProperty(id, 'HasATarget', false)
			DM.SetProperty(id, 'XP', 0)
			DM.SetProperty(id, 'Imperial_Rank', 1)
			DM.SetProperty(id, 'CumulAttackRating', 0)
			DM.SetProperty(id, 'RangeHillBonus', 0)		
			DM.SetProperty(id, 'Stamina', 40)
			DM.SetProperty(id, 'Capacitor', 80)
			DM.SetProperty(id, 'Stamina_Max', 40)
			DM.SetProperty(id, 'Capacitor_Max', 80)
			DM.SetProperty(id, 'StanceState', 'Normal')
			DM.SetProperty(id, 'PrestigeClass', 'NeedPromote')
			DM.SetProperty(id, 'PrestigeClassPromoted', 0)
			DM.SetProperty(id, 'BaseClass', 'Fighter')
			-- Setting training weight layouts
			local TrainingWeight = {'Puissance', 'Dexterity', 'Hull', 'Intelligence', 'Energy'}
			for _, Tw in TrainingWeight do
				DM.SetProperty(id, Tw, 25)
				DM.SetProperty(id, Tw..'_Max', 200)
				DM.SetProperty(id, Tw..'_TrainingWeight', 10)
			end
			for _, Skill in CF.GetUnitSkills(id) do -- DEPRECATED Because of automatic training. Need to fix it properly.
				DM.SetProperty(id, Skill, 0)
				DM.SetProperty(id, Skill..'_TrainingWeight', 5)
			end
			-- Setting baseclass modifiers
			unit = DM.GetUnitBp(Unit)
			for Category, _ in Training.BaseClass do
				if Category == unit.BaseClass then
					for Skill, Value in Training.BaseClass[Category] do
						DM.IncProperty(id, Skill, Value)
					end
				end
			end	
			-- ACU Command specific properties
			if table.find(bp.Categories, 'COMMAND') then
				Unit.HasFired = false -- we add a property to determinate if the unit fired (set to true on each fire. Use for XP)
				Unit.RangeFromHillBonusThread = Unit:ForkThread(Unit.RangeFromHillBonus)
				Unit.UpdateActivityThread = Unit:ForkThread(Unit.UpdateActivity)
				Unit.IsBuilt = true
				DM.SetProperty(id, 'IsBuilt', true)
				-- Setting bard hero on game start
				local aiBrain = GetArmyBrain(Unit:GetArmy())
				if aiBrain.BrainType == 'Human' then
					local posX, posY = aiBrain:GetArmyStartPos()
					local unit = aiBrain:CreateUnitNearSpot('URL0107', posX+2, posY-5)
					local SupId = unit:GetEntityId()
					DM.SetProperty(SupId, 'BaseClass', 'Rogue')
					unit:ForcePromote(0, 0, 'Bard', 'Rogue')
					DM.SetProperty(SupId, 'Upgrade_Armor_Light Armor', 15)
					DM.SetProperty(SupId, 'Upgrade_Armor_Light Armor_Level', 3)
					DM.SetProperty(SupId, 'Upgrade_Armor_Armor for Direct Fire', 100)
					DM.SetProperty(SupId, 'Upgrade_Armor_Armor for Direct Fire_Level', 2)
					DM.SetProperty(SupId, 'Upgrade_Armor_Armor for Bomb', 150)
					DM.SetProperty(SupId, 'Upgrade_Armor_Armor for Bomb_Level', 2)
					DM.SetProperty(SupId, 'Upgrade_Armor_Health Increase', 700)
					DM.SetProperty(SupId, 'Upgrade_Armor_Health Increase_Level', 2)
					DM.SetProperty(SupId, 'Upgrade_Weapon_1_Range', 8)
					DM.SetProperty(SupId, 'Upgrade_Weapon_1_Range_Level', 2)
					DM.SetProperty(SupId, 'Upgrade_Weapon_1_Attack Rating', 50)
					DM.SetProperty(SupId, 'Upgrade_Weapon_1_Attack Rating_Level', 1)
					DM.SetProperty(SupId, 'StanceState', 'Offensive')
					DM.SetProperty(SupId, 'Intelligence'..'_TrainingWeight', 25)
					DM.SetProperty(SupId, 'Hull'..'_TrainingWeight', 15)
					DM.SetProperty(SupId, 'Energy'..'_TrainingWeight', 10)
					unit:ExecutePower('LesserShield')
					unit:AdjustHealth(unit, 2500)
				end
			end
		end
	end,

	OldOnStopBeingBuilt = Unit.OnStopBeingBuilt,
	OnStopBeingBuilt = function(Unit, builder, layer)
		Unit.OldOnStopBeingBuilt(Unit, builder, layer)
		if Unit then
			local id = Unit:GetEntityId()
			local bp = Unit:GetBlueprint()
			local bpShield = bp.Defense.Shield
			DM.SetProperty(id, 'Promoting', 0)
			if table.find(bp.Categories, 'SELECTABLE') then
				DM.SetProperty(id, 'XP', 0)
				if not Unit.InstigatorsData then Unit.InstigatorsData = {} end
				if not Unit.GlobalInstigatorAtr then Unit.GlobalInstigatorAtr = 0 end
				if not Unit.AoHBuffs then Unit.AoHBuffs = {} end
				DM.SetProperty(id, 'CumulAttackRating', 0)
				DM.SetProperty(id, 'RangeHillBonus', 0)
				DM.SetProperty(id, 'Stamina', 40)
				DM.SetProperty(id, 'Capacitor', 80)
				DM.SetProperty(id, 'Stamina_Max', 40)
				DM.SetProperty(id, 'Capacitor_Max', 80)
				DM.SetProperty(id, 'StanceState', 'Normal')
				DM.SetProperty(id, 'PrestigeClass', 'NeedPromote')
				DM.SetProperty(id, 'PrestigeClassPromoted', 0)
				DM.SetProperty(id, 'BaseClass', 'Fighter')
				-- Setting training weight layouts
				local TrainingWeight = {'Puissance', 'Dexterity', 'Hull', 'Intelligence', 'Energy'}
				for _, Tw in TrainingWeight do
					DM.SetProperty(id, Tw, 25)
					DM.SetProperty(id, Tw..'_Max', 200)
					DM.SetProperty(id, Tw..'_TrainingWeight', 10)
				end
				DM.SetProperty(id, 'Intelligence', 30)
				#Defaut production
				if table.find(bp.Categories, 'FACTORY') or table.find(bp.Categories, 'ENGINEER') or table.find(bp.Categories, 'COMMAND') then
					DM.SetProperty(id,'Active_Production', DM.GetProperty(id,'Active_Production', 'Fighter'))
					DM.SetProperty(id, 'Building', 0)
				end
				if table.find(bp.Categories, 'FACTORY') then
					DM.SetProperty(id, 'EngineerConsolidationBonus', 0)
					DM.SetProperty(id,'Active_Production', 'Fighter')
					DM.SetProperty(id,'IsFactoryActive', true)
					-- Unit:SetCustomName('Production : '..'Fighter')
				end
				local Stamina = DM.GetProperty(id, 'Hull')
				DM.SetProperty(id, 'Stamina_Max', Stamina)
				local Capacitor = DM.GetProperty(id, 'Energy') * 4.5
				DM.SetProperty(id, 'Capacitor_Max', Capacitor)
				if Unit.originalBuilder then
					local Creator = Unit.originalBuilder
					local Active_Production = 'Fighter'
					if Creator then
						local bpc = Creator:GetBlueprint()
						local idc = Creator:GetEntityId()
						Active_Production = DM.GetProperty(idc,'Active_Production', 'Fighter')
						DM.SetProperty(id,'BaseClass', Active_Production)
						if table.find(bp.Categories, 'FACTORY')  then
							DM.SetProperty(id,'EngineerConsolidationBonus', 0)
							if table.find(bpc.Categories, 'FACTORY') then -- Give the EngineerConsolidationBonus when upgrading factories
								DM.SetProperty(id,'EngineerConsolidationBonus', math.ceil(DM.GetProperty(idc,'EngineerConsolidationBonus', 0)))
								DM.SetProperty(id,'SetBuildingSpeed', math.ceil(DM.GetProperty(idc,'SetBuildingSpeed', 0)))
								Unit.UpdateUnitData(Unit, nil, 0, false)
							end
						end
						for _, Skill in CF.GetUnitSkills(id) do  
							DM.SetProperty(id, Skill, 0)
							DM.SetProperty(id, Skill..'_TrainingWeight', 5)
						end
					else
						DM.SetProperty(id,'BaseClass', Active_Production)
					end
				end
				-- EnergyStorage feature
				if bp.Economy.StorageEnergy then
					local CurrentStorage = DM.GetProperty('Global'..Unit:GetArmy(), 'EnergyStorage')
					DM.SetProperty('Global'..Unit:GetArmy(), 'EnergyStorageM', CurrentStorage + bp.Economy.StorageEnergy)
				end
				-- Setting baseclass modifiers
				unit = DM.GetUnitBp(Unit)
				for Category, _ in Training.BaseClass do
					if Category == unit.BaseClass then
						for Skill, Value in Training.BaseClass[Category] do
							DM.IncProperty(id, Skill, Value)
						end
					end
				end					
				-- Rogue class buff
				if DM.GetProperty(id, 'BaseClass', 0) == 'Rogue' then
					BuffBlueprint {
						Name = 'RogueBuff',
						DisplayName = 'RogueBuff',
						BuffType = 'Rogue',
						Stacks = 'REPLACE',
						Duration = -1,
						Affects = {
							VisionRadius = {
								Add = 0,
								Mult = 1.25,
							},
							MoveMult = {
								Add = 0,
								Mult = 1.15,
							},
						},
					}
					Buff.ApplyBuff(Unit, 'RogueBuff')
				end
				if CF.IsMilitary(Unit) == true then
					DM.SetProperty(id, 'Military', true)
					Unit.HasFired = false
				end
				-- Set promotion if there is just one	
				-- AI HERO
				local aiBrain = GetArmyBrain(Unit:GetArmy())				
				if table.find(bp.Categories, 'COMMAND') and aiBrain.BrainType != 'Human' then
					local Difficulty = ScenarioInfo.Options.Difficulty or 1
					local roll = math.ceil(math.random(Difficulty, 7))
					local Rank = {'Ensign', 'Lieutenant *', 'Captain **', 'Commander ***', 'Commodore ****', 'Vice-Admiral *****', 'Admiral ******'}
					DM.SetProperty(id, 'Upgrade_Armor_Health Increase', roll * 50000)
					DM.SetProperty(id, 'Upgrade_Armor_Regeneration Increase', roll * 50)
					DM.SetProperty(id, 'Upgrade_Armor_Heavy Armor', roll * 40)
					DM.SetProperty(id, 'AI_Champion', Rank[roll])
					if table.find(bp.Categories, 'CYBRAN') then
						DM.SetProperty(id, 'Upgrade_Weapon_2_Armor Piercing', roll * 25)
						DM.SetProperty(id, 'Upgrade_Weapon_2_Damage to All Units', roll*75)
						DM.SetProperty(id, 'Upgrade_Weapon_2_Range', 35 + roll)
						DM.SetProperty(id, 'Upgrade_Weapon_3_Range', 35 + roll)
					else
						DM.SetProperty(id, 'Upgrade_Weapon_1_Armor Piercing', roll * 25)
						DM.SetProperty(id, 'Upgrade_Weapon_1_Damage to All Units', roll*75)
						DM.SetProperty(id, 'Upgrade_Weapon_1_Range', 35 + roll)
						DM.SetProperty(id, 'Upgrade_Weapon_2_Range', 35 + roll)			
					end
				end
				-- AI BOSS units
				local TechLevel = CF.GetUnitTech(Unit)
				local Time = GetGameTimeSeconds()
				if math.random(1, 100) > (100 - math.min(Time/300, 25))  and TechLevel > 1 and aiBrain.BrainType != 'Human' and CF.IsMilitary(Unit) then
					if table.find(bp.Categories, 'INDIRECTFIRE') then else
						if table.find(bp.Categories, 'DEFENSE') or table.find(bp.Categories, 'MOBILE') or table.find(bp.Categories, 'ANTIAIR') then 
							local Time = GetGameTimeSeconds()
							if Time > 900 then
								local AIRmodifier = 1
								local NAVALmodifier = 1
								if table.find(bp.Categories, 'HIGHALTAIR') or table.find(bp.Categories, 'AIR')  then
									AIRmodifier = 0.25
								end
								if table.find(bp.Categories, 'NAVAL') then
									NAVALmodifier = 0.5
								end
								local MassIncome = 0
								local MassIncomeAI = 0
								local TotalHumanPlayers = 0
								for i, brain in ArmyBrains do
									if brain.BrainType == 'Human' then
										TotalHumanPlayers = TotalHumanPlayers + 1
										MassIncome = MassIncome + brain:GetEconomyIncome('MASS')
									else	
										MassIncomeAI = MassIncomeAI + brain:GetEconomyIncome('MASS')
									end
								end
								local TimeMod = Time / 2
								local EcoRatio = math.min(MassIncome / MassIncomeAI, 10)
								BuffBlueprint {
									Name = 'AIBoss',
									DisplayName = 'AIBoss',
									BuffType = 'Boss',
									Stacks = 'REPLACE',
									Duration = -1,
									Affects = {
										RateOfFire = {
											Add = 0,
											Mult = 0.25 / math.max(EcoRatio, 1),
										},
										Damage = {
											Add = TimeMod / 20 * AIRmodifier * NAVALmodifier,
										},
										MaxHealth = {
											DoNoFill = false,
											Add = ((Time - 900) * 20 * TechLevel) * AIRmodifier * NAVALmodifier,
										},
										Regen = {
											Add = TimeMod / 50 * AIRmodifier * NAVALmodifier,
										},
										MoveMult = {
											Mult = 0.5,
										},
									},
								}
								Buff.ApplyBuff(Unit, 'AIBoss')
								local Level = math.max(math.ceil(EcoRatio + (Time-900) / 400, 1))
								local Name = 'Elite rank '
								Unit:SetCustomName(Name..Level)
								DM.SetProperty(id, 'Type', 'Elite')
								DM.SetProperty(id, 'EliteLevel', Level)
							end
						end
					end
				end
				Unit.IsBuilt = true
				DM.SetProperty(id, 'IsBuilt', true)
				Unit:UpdateUnitData(0, 0)
			end
		end
	end,

	OldOnDamage = Unit.OnDamage,
	OnDamage = function(Unit, instigator, amount, vector, ProjectileId)
		if instigator then 
			instigator.HasFired = true 
		end
		local id = Unit:GetEntityId()
		if not Unit:GetTargetEntity() then
			local id = Unit:GetEntityId()
			if Unit.MissionState == 'Free' and DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 and DM.GetProperty(id, 'Behaviour', 'Standing') ~= 'Standing' then
				Unit.PreviousPosition = Unit:GetPosition()
				local bp = Unit:GetBlueprint()
				if instigator and CF.GetUnitLayerType(instigator) == 'LAND' and table.find(bp.Categories, 'DIRECTFIRE') then
					Unit.MissionState = 'InMission'
					Unit.PursueThread = Unit:ForkThread(Unit.PursueInstigator, instigator)
				end
			end
		end
		AmountMod = amount
		if Unit:GetShieldType() == 'Personal' and Unit:ShieldIsOn() then
			local ShieldAbs = 1
			local Projectile = Proj.Projectiles['ProjId'..ProjectileId]
			AmountMod = AmountMod * (Projectile.ShieldDamageMod or 1)
			local WeaponCategoryList = {'Direct Fire', 'Direct Fire Naval', 'Direct Fire Experimental',  'Artillery', 'Bomb', 'Missile'}
			if DM.GetProperty(id, 'Upgrade_Armor_Shield Absorb') then
				ShieldAbs =  1 + DM.GetProperty(id, 'Upgrade_Armor_Shield Absorb', 0) / 100
			end
			if table.find(WeaponCategoryList, Projectile.WeaponCategory) then
				local ModWc = string.gsub(Projectile.WeaponCategory, 'Direct Fire', 'DF')
				ShieldAbs =  1 + (DM.GetProperty(id, 'Upgrade_Armor_Shield Absorb '..ModWc, 0)) / 100
			end
			AmountMod = AmountMod / ShieldAbs
		end
		Unit.OldOnDamage(Unit, instigator, AmountMod, vector, ProjectileId)
    end,

	OldDoTakeDamage = Unit.DoTakeDamage,
	DoTakeDamage = function(Unit, instigator, amount, vector, ProjectileId)
		local excludelist = {'Force', 'Nuke', 'Deathnuke', 'Reclaimed'}
		local amountmod = amount
		Unit.HasTakenDamage = true
		-- Most of damage data are passed thru ProjectileId for specific features (weaponbuffs, resists, bonuses...) but some very specific ones are not supported.
		if table.find(excludelist, ProjectileId) then
			Unit.OldDoTakeDamage(Unit, instigator, amountmod, vector, ProjectileId or 'Normal') 
		else
			local Projectile = Proj.Projectiles['ProjId'..ProjectileId]
			-- LOG(repr(Projectile))
			if Unit then
				local id = Unit:GetEntityId()
				local bp = Unit:GetBlueprint()
				local Promoted = DM.GetProperty(id,'PrestigeClassPromoted', 0)
				-- High Damage Reducer
				if DM.GetProperty(id, 'Tech_High Damage Reducer') then
					local DamageReduction = DM.GetProperty(id, 'Tech_High Damage Reducer', 0)
					if amountmod > (Unit:GetMaxHealth() * 0.20) and DamageReduction > 0 then
						amountmod = amountmod * (1 - DamageReduction/100)
					end
				end
				--- Armor layers feature
				if DM.GetProperty(id, 'Tech_ArmorLayers') then amountmod = amountmod - DM.GetProperty(id, 'Tech_ArmorLayers') end
				------------------------------------------------------------------------------------
				-- Beams data are no refreshing at each hit. So we need to mod them on target hit.
				------------------------------------------------------------------------------------
				if Projectile.WeaponNature == 'Beam' then
					-- We need to record instigator data to stack all attack rating (since there is no collision detection for beam weapons)
					local CurrentInstigatorsAttackRating = 0
					local distfromtarget = DM.GetProperty(id, 'DistanceFromTarget'..'_Weapon_'..Projectile.WeaponIndex) or 0
					local AttackRatingUpgrade = DM.GetProperty(id, 'Upgrade_Weapon_'..Projectile.WeaponIndex..'_Attack Rating') or 0
					local AttackRating =  (CF.GetAttackRating(Unit) + AttackRatingUpgrade) * math.pow(0.75, distfromtarget / 10) * (1 + Projectile.DamageRadius * 2)
					Unit.InstigatorsData[Projectile.InstigatorId] = AttackRating
					for ids, Atr in Unit.InstigatorsData do
						if ids != Projectile.InstigatorId then
							CurrentInstigatorsAttackRating = CurrentInstigatorsAttackRating + Atr
						else
							CurrentInstigatorsAttackRating = CurrentInstigatorsAttackRating + AttackRating
						end
					end
					Unit.GlobalInstigatorAtr = CurrentInstigatorsAttackRating
					if CF.IsDefenseDodge(Unit, Unit.GlobalInstigatorAtr, Projectile.Stance or 'Normal') then
						amountmod = 0
					else
						if instigator then
							local idi = instigator:GetEntityId()
							local bpi = instigator:GetBlueprint()
							local PromotedInst = DM.GetProperty(idi,'PrestigeClassPromoted', 0)
							local BaseClass =  DM.GetProperty(idi, 'BaseClass', 'Fighter')
							local PrestigeClass =  DM.GetProperty(idi, 'PrestigeClass', 'Elite')
							local DamageRating =  CF.GetDamageRating(instigator) or 0
							local DamageBuff = (AoHBuff.GetBuffValue(instigator, 'Damage', 'ALL') / 100) or 0
							local DamageClassMod = 0
							local DamageTech = DM.GetProperty(idi, 'Tech_Ammunitions', 0)
							if Projectile.DisplayName == 'Heavy Microwave Laser' and PromotedInst == 1 then
								amountmod = amountmod * 0.5
							end
							if PromotedInst == 1 then
								if DM.GetProperty(idi, 'Stamina') > 5 then
									DamageClassMod = BCbp[BaseClass]['DamagePromotionModifier']
								end
							end
							amountmod = amountmod * (1 + DamageClassMod + DamageBuff + DamageRating + DamageTech)
							if Projectile.DisplayName == 'Cold Beam' then
								local ColdBeamDamMod = 1
								ColdBeamDamMod = (ColdBeamBCMod[BaseClass] or 0.25 + ColdBeam(BCMod[BaseClass] or 0.25) +( PCMod[PrestigeClass] or 0.25)) / 2
								local Int = DM.GetProperty(idi, 'Intelligence')
								local PowerModifier = CF.GetStanceModifier(instigator, 'PowerStrengh_Mod') + (DM.GetProperty(idi, 'Buff_PowerDamage_ALL_Add', 0) / 100)
								local Power = math.ceil(math.pow(bpi.Economy.BuildCostMass, 0.7) * (2 + Int/25) * PowerModifier * 2)
								amountmod = amountmod * ColdBeamDamMod  * (1 + Power/1000)
							end
						end
					end
				end
				-- LOG('after dodging : '..amountmod)
				-- Damage specialization section. Logically, if the damage general is applied to shields, that 's not the case for damage specializations. So we need to hit the unit first.
				local DamageSpeMod = 1
				local ApplySpeToCat = {EXPERIMENTAL = 'Damage to Experimentals', SUBCOMMANDER = 'Damage to SubCommanders', HIGHALTAIR = 'Damage to High Aircrafts', AIR = 'Damage to Ground Aircrafts', DEFENSE = 'Damage to Defenses', NAVAL = 'Damage to Navals', BOT = 'Damage to Bots', TANK = 'Damage to Tanks', STRUCTURE = 'Damage to Structures'}
				for Category, Spe in ApplySpeToCat do
					if table.find(bp.Categories, Category) and Projectile.DamageSpecialization[Spe] then
						DamageSpeMod = DamageSpeMod + (Projectile.DamageSpecialization[Spe] / 100)
					end
				end
				amountmod = amountmod * DamageSpeMod
				-- LOG('after aply specialization : '..amountmod)
				-- Weapon Buffs execution
				if Projectile.ExecuteWeaponBuff and instigator then
					instigator:ExecuteWeaponPower(Projectile.ExecuteWeaponBuff, Unit)
				end
				
				-- Vanilla Armor definition compatibility : we need to match the previous armor definitions
				if table.find(bp.Categories, 'COMMAND') and Projectile.DamType == 'Overcharge' then
					amountmod = amountmod * 0.033333
				elseif table.find(bp.Categories, 'STRUCTURE') and Projectile.DamType == 'Overcharge' then
					amountmod = amountmod * 0.066666
				elseif  Projectile.DamType == 'CzarBeam' and table.find(bp.Categories, 'HIGHALTAIR') then
					amountmod = amountmod * 0.25
				elseif Projectile.DamType == 'OtheTacticalBomb' and table.find(bp.Categories, 'HIGHALTAIR') then
					amountmod = amountmod * 0.25
				elseif Projectile.DamType == 'ExperimentalFootfall' and table.find(bp.Categories, 'EXPERIMENTAL') then
					amountmod = amountmod * 0
				elseif Projectile.DamType == 'FireBeetleExplosion' and table.find(bp.Categories, 'FIREBEETLE') then
					amountmod = amountmod * 0
				end
				-- LOG('After Vanilla armor compatibility : '..amountmod)
				-- Armor Absorb
				if Promoted == 1 then
					if instigator then
						local idi = instigator:GetEntityId()
						local ArmorPiercing = (Projectile.ArmorPiercing or 0)
						local armorabs = CF.GetArmorAbsorption(id, Projectile.WeaponCategory, ArmorPiercing, Projectile.DamType) / 100
						local ArmorDebuff = AoHBuff.GetBuffValue(Unit, 'ArmorPerc', 'ALL')
						ArmorDebuff = math.max(ArmorDebuff, -200)
						armorabs = armorabs * (1 - ArmorDebuff/100)
						amountmod = amountmod * (1 - armorabs)
					end
				end
				-- LOG('after armor : '..amountmod)
				-- min & max damages
				local mindamagemod = 1 - (math.pow(0.9, (DM.GetProperty(id, 'Dexterity', 0) - 20)/5) * 0.35) -- higher dexterity give more min damage.
				amountmod = math.ceil(math.random(amountmod * mindamagemod, amountmod * 1.10))
				-- LOG('min max : '..amountmod)
				-- Damage numbers effect
				if instigator then
					local idi = instigator:GetEntityId()
					local bpi = instigator:GetBlueprint()
					local PromotedInst = DM.GetProperty(idi,'PrestigeClassPromoted', 0)
					if PromotedInst == 1 or table.find(bpi.Categories, 'COMMAND') or table.find(bp.Categories, 'COMMAND') then
						if amountmod >= 200 and not table.find(bp.Categories, 'WALL') then
							FX.DrawNumbers(Unit, amountmod, 'Red')  -- We draw the damage amount over the unit.
						end
					end
				end
				-- health and energy absorb feature
				if table.find(bp.categories, 'WALL') then else -- if not table.find doesn't work ?
					if instigator then
						local idi = instigator:GetEntityId()
						local level = CF.GetUnitLevel(instigator)
						-- Tech Drain Feature
						local Drain = DM.GetProperty(idi, 'Tech_Health Drain', 0)
						local healthAbso = amountmod * (Drain /100)
						instigator:AdjustHealth(instigator, healthAbso)
						if DM.GetProperty(idi, 'BaseClass', 0) == 'Ardent' then -- Ardent Health Absorption Bonus
							local intelligence = DM.GetProperty(idi, 'Intelligence') or 0
							local healthAbso = amountmod * (math.min(0.01 * level * intelligence/40, 0.4) + Projectile.ConversionToHealth / 100)
							instigator:AdjustHealth(instigator, healthAbso)
						end
						if DM.GetProperty(idi, 'BaseClass', 0) == 'Ardent' then -- Ardent Energy Absorption Bonus
							local intelligence = DM.GetProperty(idi, 'Intelligence') or 0
							local EnergyAbso =  amountmod * (math.min(0.05 * level * intelligence/40, 1.5)+ Projectile.ConversionToEnergy / 100)
							instigator:GetAIBrain():GiveResource('Energy', EnergyAbso)
						end
						local army = instigator:GetArmy()
						if DM.GetProperty(army, 'AI_'..'Ardent'..'_'..CF.GetUnitLayerTypeHero(instigator)) > 0 then
							local HealthAbsHallofFameBonus = CF.Calculate_HallofFameBonus(DM.GetProperty(army, 'AI_'..'Ardent'..'_'..CF.GetUnitLayerTypeHero(instigator)), 'Ardent') / 100
							local healthAbso = amountmod * HealthAbsHallofFameBonus
							instigator:AdjustHealth(instigator, healthAbso)
						end
					end
				end
			end
			-- LOG('end : '..amountmod)
			Unit.OldDoTakeDamage(Unit,instigator, amountmod, vector, Projectile.DamType or 'Normal') -- No destructive action on damage type values :)			
		end
	end,
	
	PursueInstigator = function(self, instigator)
		-- local units = self:GetAIBrain():GetUnitsAroundPoint(categories.LAND + categories.MOBILE + categories.DIRECTFIRE, self:GetPosition(), 1, 'Ally')
		local id = self:GetEntityId()	
		if instigator then
			local selfpos =  self:GetPosition()
			local instpos =  instigator:GetPosition()
			local distfromtarget = VDist3(selfpos, instpos)
			local Behaviour = DM.GetProperty(id, 'Behaviour', 'Standing')
			local RangeRatio = distfromtarget / (20 * CF.GetUnitTech(self))
			if Behaviour == 'Defensive' and distfromtarget > 50 then KillThread(Unit.PursueThread) end
			if Behaviour == 'Normal' and distfromtarget > 100 then  KillThread(Unit.PursueThread) end
			if Behaviour == 'Aggressive' and distfromtarget > 100 then  KillThread(Unit.PursueThread) end
			if Behaviour == 'Aggressive' then RangeRatio = RangeRatio * 10 end
			local Atpos = {(selfpos[1] + (1 + RangeRatio) * instpos[1]) /(2 + RangeRatio), (selfpos[2] + (1 + RangeRatio) * instpos[2]) / (2 + RangeRatio), (selfpos[3] + (1 + RangeRatio) * instpos[3]) / (2 + RangeRatio)}
			if DM.GetProperty(id, 'Behaviour', 'Standing') == 'Normal' or DM.GetProperty(id, 'Behaviour', 'Standing') == 'Aggressive' then
				IssueAggressiveMove({self}, Atpos)
			elseif DM.GetProperty(id, 'Behaviour', 'Standing') == 'Defensive' then
				IssueAttack({self}, instigator)
			end
		end
		repeat
			if not self:GetTargetEntity() then
				IssueMove({self}, self.PreviousPosition)
				WaitSeconds(30)
				self.MissionState = 'Free'
				break
			end
			WaitSeconds(1)
		until(self.Dead == true)
	end,

	ForcePromote = function(self, EnergyCost, MassCost, PrestigeClass, BaseClass) -- Order promotion when call by UI
		local level = CF.GetUnitLevel(self)
		local id = self:GetEntityId()
		DM.SetProperty(id,'PrestigeClassPromoted', 1)
		DM.SetProperty(id,'PrestigeClass', PrestigeClass)
		self:SetCustomName(PrestigeClass..' ['..level..']')
		if PC[BaseClass..' '..PrestigeClass].OnPromote(id) then PC[BaseClass..' '..PrestigeClass].OnPromote(id) end
		self:GetAIBrain():TakeResource('Mass', MassCost)
		self:GetAIBrain():TakeResource('Energy', EnergyCost)
		local ApplyVRtoClass = {Fighter = 1.25, Rogue = 1.75, Support = 1.25, Ardent = 1.35}
		local ApplyMRtoClass = {Fighter = 1.15, Rogue = 1.30, Support = 1.15, Ardent = 1.15}
		local VRBonus = ApplyVRtoClass[BaseClass]
		local MRBonus = ApplyMRtoClass[BaseClass]
		-- All promoted units grants Vision Radius and mouvement rate bonus
		BuffBlueprint {
			Name = 'PromotionBonus',
			DisplayName = 'PromotionBonus',
			BuffType = 'Promotion',
			Stacks = 'REPLACE',
			Duration = -1,
			Affects = {
				VisionRadius = {
					Add = 0,
					Mult = VRBonus,
				},
				MoveMult = {
					Add = 0,
					Mult = MRBonus,
				},
			},
		}
		-- if DM.GetProperty(id, 'BaseClass', 0) == 'Rogue' then
			-- self.RogueRadarInvisibilityThread = self:ForkThread(self.RogueRadarInvisibility)
		-- end	
		Buff.ApplyBuff(self, 'PromotionBonus')	
		local aiBrain = GetArmyBrain(self:GetArmy())
		table.insert(aiBrain.HeroesList, self)
		self.UpdateUnitData(self, 0, false)
	end,
	
	OrderPromote = function(self, EnergyCost, MassCost, PrestigeClass, BaseClass, Template, Modifiers) -- Order promotion when call by UI
		local level = CF.GetUnitLevel(self)
		local id = self:GetEntityId()
		local bp = self:GetBlueprint()
		-- Register Hero to Herolist and Refreshing promoting points
		DM.SetProperty(id, 'Promoting', 1)
		local aiBrain = GetArmyBrain(self:GetArmy())
		table.insert(aiBrain.HeroesList, self)
		local army = self:GetArmy()
		local ArmyBrain = GetArmyBrain(army)
		DM.SetProperty('Global'..army, 'Logistics', CF.GetLogisticAvailable(ArmyBrain))
		-- LOG('Heroes Number : '..table.getn(aiBrain.HeroesList))
		repeat
			if DM.GetProperty(id,'EcoEventProgress_'..'Promoting', 0) >= 1000 then
				DM.SetProperty(id,'PrestigeClass', PrestigeClass)
				if PC[BaseClass..' '..PrestigeClass].OnPromote(id) then PC[BaseClass..' '..PrestigeClass].OnPromote(id) end
				DM.SetProperty(id,'EcoEventProgress_'..'Promoting', 'Done')
				
				DM.SetProperty(id,'PrestigeClassPromoted', 1)
				self:SetCustomName(PrestigeClass..' ['..level..']')
				local BaseClass = DM.GetProperty(id, 'BaseClass')
				local ApplyVRtoClass = {Fighter = 1.25, Rogue = 1.75, Support = 1.25, Ardent = 1.35}
				local ApplyMRtoClass = {Fighter = 1.15, Rogue = 1.30, Support = 1.15, Ardent = 1.15}
				local VRBonus = ApplyVRtoClass[BaseClass]
				local MRBonus = ApplyMRtoClass[BaseClass]
				-- All promoted units grants Vision Radius and mouvement rate bonus
				BuffBlueprint {
					Name = 'PromotionBonus',
					DisplayName = 'PromotionBonus',
					BuffType = 'Promotion',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						VisionRadius = {
							Add = 0,
							Mult = VRBonus,
						},
						MoveMult = {
							Add = 0,
							Mult = MRBonus,
						},
					},
				}
				Buff.ApplyBuff(self, 'PromotionBonus')		
				self.UpdateUnitData(self, 0, false)
				DM.SetProperty(id,'EcoEventProgress_'..'Promoting',nil)
				
				BuffBlueprint {
					Name = 'PromotionRegen',
					DisplayName = 'PromotionRegen',
					BuffType = 'HEROESPromotion',
					Stacks = 'REPLACE',
					Duration = 180,
					Affects = {
						Regen = {
							Add = (self:GetMaxHealth() - self:GetHealth()) / 180,
							Mult = 1,
						},
					},
				}
				Buff.ApplyBuff(self, 'PromotionRegen')

				if Template then
					DM.SetProperty(id,'EcoEventProgress_ApplyingTemplate', 1000)
					self:ApplyTemplate(0, 0, Template, Modifiers)
				else
				-- self:ApplyTemplate(0, 0, 'Defaut', DefautTemplate)
				end
				-- if DM.GetProperty(id, 'BaseClass', 0) == 'Rogue' then
					-- self.RogueRadarInvisibilityThread = self:ForkThread(self.RogueRadarInvisibility)
				-- end	
			else
				WaitSeconds(1)
			end
		until(DM.GetProperty(id,'EcoEventProgress_'..'Promoting') == 'Done')
		DM.SetProperty(id, 'Promoting', 0)
	end,
	
	CreateEcoEvent = function(self, Energy, Mass, Timestress, EventName, ArmorToSet, WeaponIndex, WeaponToSet, TemplateName, Modifiers)
		local id = self:GetEntityId()
		local bp = self:GetBlueprint()
		DM.SetProperty(id,'EcoEventProgress_'..EventName, 0)
		local ApplySpeedMod = {Pause = 0, Slow = 8, Average = 32, Fast = 64, Faster = 256}
		local SpeedModifier = ApplySpeedMod[DM.GetProperty(id,'PromotingUpgradingSpeed', 'Average')] / (CF.GetUnitTech(self) * 8)
		Event['Event'..id] = CreateEconomyEvent(self, 0, SpeedModifier*Timestress*Mass/1000, 0.1)
		local c = 10
		repeat
			SpeedModifier = ApplySpeedMod[DM.GetProperty(id,'PromotingUpgradingSpeed', 'Average')] / (CF.GetUnitTech(self) * 8)
			local brain = self:GetAIBrain()
			if brain:GetEconomyStored('MASS') > 500 and brain:GetEconomyStored('ENERGY') > 3000 then 
				SpeedModifier = ApplySpeedMod['Faster'] / (CF.GetUnitTech(self) * 8)
			else
				SpeedModifier = ApplySpeedMod['Slow'] / (CF.GetUnitTech(self) * 8)
			end
			if EconomyEventIsDone(Event['Event'..id]) == false then
			else
				DM.IncProperty(id,'EcoEventProgress_'..EventName, SpeedModifier*Timestress*1)
				Event['Event'..id] = CreateEconomyEvent(self, SpeedModifier*Timestress*Energy/1000, SpeedModifier*Timestress*Mass/1000, 0.1)
				if DM.GetProperty(id,'EcoEventProgress_'..EventName) >= 1000 then break end
			end
			c = c + 0.1
			if c > 1 then
				local size = math.pow(bp.SizeX * bp.SizeZ, 0.5)
				self['Eco'] = CreateAttachedEmitter(self, 0, self:GetArmy(),  ModPath..'Graphics/Emitters/Upgrading.bp'):ScaleEmitter(size)
				self:CreateFx(ModPath..'Graphics/Emitters/promoting1.bp', 0, 1, 1, 'CreateFxOnBones')
				c = 0
			end
			WaitSeconds(0.1)
		until(DM.GetProperty(id,'EcoEventProgress_'..EventName) >= 1000)
		if ArmorToSet then 
			DM.SetProperty(id,'EcoEventProgress_'..'UpgradingArmor', nil)
			self:UpgradeArmor(ArmorToSet)
		end
		if WeaponToSet then
			DM.SetProperty(id,'EcoEventProgress_'..'UpgradingWeapon', nil)
			self:UpgradeWeapon(WeaponIndex, WeaponToSet)
		end
		if EventName == 'ApplyingTemplate' then
			self:ApplyTemplate(0,0, TemplateName, Modifiers)
		end
	end,
	
	UpgradeArmor = function(self, ArmorToSet)
		local id = self:GetEntityId()
		-- Removing previous armor
		for i, key in ArmorModifiers.RefView do		
			DM.SetProperty(id, 'Upgrade_Armor_'..key, nil)
			DM.SetProperty(id, 'Upgrade_Armor_'..key..'_Level', nil)
		end
		-- Set new one
		for value, level in ArmorToSet do
			DM.SetProperty(id, value, level)
		end
		self:UpdateUnitData(0, 0)
	end,
	
	UpgradeWeapon = function(self, WeaponIndex, SetWeapon)
		local id = self:GetEntityId()
		-- Removing previous weapon upgrades
		for i, key in WeaponModifiers.RefView do		
			DM.SetProperty(id, 'Upgrade_Weapon_'..WeaponIndex..'_'..key, nil)
			DM.SetProperty(id, 'Upgrade_Weapon_'..WeaponIndex..'_'..key..'_Level', nil)
		end
		-- Set new one
		for value, level in SetWeapon do
			DM.SetProperty(id, value, level)
		end
		self:UpdateUnitData(0, 0)
	end,
		
	ApplyTemplate = function(self, Mass, Energy, TemplateName, ModifiersTable)
		local id = self:GetEntityId()
		for _, Modifiers in ArmorModifiers.RefView do
			DM.SetProperty(id, 'Upgrade_Armor_'..Modifiers..'_Level', nil)
			DM.SetProperty(id, 'Upgrade_Armor_'..Modifiers, nil)
		end
		for weaponindex = 1, 30 do
			for _, Modifiers in WeaponModifiers.RefView do
				DM.SetProperty(id, 'Upgrade_Weapon_'..weaponindex..Modifiers..'_Level', nil)
				DM.SetProperty(id, 'Upgrade_Weapon_'..weaponindex..'_'..Modifiers, nil)
			end
		end
		for Modifier, Value in ModifiersTable do
			local TrainingWeight = {'Puissance', 'Dexterity', 'Hull', 'Intelligence', 'Energy'}	
			if table.find(TrainingWeight, Modifier) then
				DM.SetProperty(id, Modifier..'_TrainingWeight', Value)
			end
			local cutmodifier = string.gsub(Modifier, '_Level', "")
			cutmodifier = string.gsub(cutmodifier, 'Upgrade_Armor_', "")
			if table.find(ArmorModifiers.RefView, cutmodifier) then
				DM.SetProperty(id, 'Upgrade_Armor_'..cutmodifier..'_Level', Value)
				DM.SetProperty(id, 'Upgrade_Armor_'..cutmodifier, ArmorModifiers.Modifiers[ArmorModifiers.GetInternalKey(cutmodifier)].Calculate(id) * Value)
			end
			for weaponindex = 1, 30 do
				cutmodifier = string.gsub(cutmodifier, 'Upgrade_Weapon_'..weaponindex..'_', "")
				if table.find(WeaponModifiers.RefView, cutmodifier) and Modifier == 'Upgrade_Weapon_'..weaponindex..'_'..cutmodifier..'_Level' then
					DM.SetProperty(id, 'Upgrade_Weapon_'..weaponindex..'_'..cutmodifier..'_Level', Value)
					DM.SetProperty(id, 'Upgrade_Weapon_'..weaponindex..'_'..cutmodifier, WeaponModifiers.Modifiers[WeaponModifiers.GetInternalKey(cutmodifier)].Calculate(id) * Value)
				end
			end
		end
		DM.SetProperty(id, 'Unit_TemplateName', TemplateName)
		self:UpdateUnitData(0, 0)
		DM.SetProperty(id,'EcoEventProgress_ApplyingTemplate', nil)
	end,
	
	ApplyDefautTemplateAlternate = function(BaseClass, PrestigeClass, TrainingWeight, Modifiers, Levels)
	
	end,

	RangeFromHillBonus = function(self) -- Height difference grants range bonus
		local id = self:GetEntityId()
		local bp = self:GetBlueprint()
		local TotalRadius = 0
		repeat
			DM.SetProperty(id, 'RangeHillBonus', 0)
			if self then
				for i, wep in bp.Weapon do
					if wep.Label == 'DeathWeapon' or wep.Label == 'DeathImpact' or  bp.Weapon.TargetType == 'RULEWTT_Projectile' or wep.DisplayName == 'Teleport in' or wep.Label =='ChronoDampener' or wep.Label =='CollossusDeath' or wep.Label =='MegalithDeath' then
					else
						if wep.Damage > 0 then
							Weap = self:GetWeapon(i)
							DM.SetProperty(id, 'RangeHillBonus'..'_Weapon_'..i, 0)
							-- local Range_Bonus = 0
							DM.SetProperty(id, 'DistanceFromTarget'..'_Weapon_'..i, nil)
							DM.SetProperty(id, 'TargetId'..'_Weapon_'..i, nil)
							DM.SetProperty(id, 'Accuracy'..'_Weapon_'..i, nil)
							if Weap:WeaponHasTarget() == true then
								local UnitPos = self:GetPosition()
								local TargetPos = Weap:GetCurrentTargetPos()
								if TargetPos[2] then
									-- if table.find(bp.Categories, 'AIR') or table.find(bp.Categories, 'NAVAL') or table.find(bp.Categories, 'HIGHALTAIR') then -- We exclude air, naval and highaltair from range bonus
										-- DM.SetProperty(id, 'RangeHillBonus'..'_Weapon_'..i, 0) -- Sync value for Ui
									-- else
										-- local HeighDiff = UnitPos[2] - TargetPos[2] or 0 
										-- Range_Bonus = math.min(math.ceil(HeighDiff * 2), math.ceil(bp.Weapon[i].MaxRadius / 2.5)) -- Range Bonus from hill capped to +40%
										-- local cap = math.max(bp.Weapon[i].MaxRadius/5, 50) -- Range Bonus from hill capped to +50
										-- Range_Bonus = math.min(Range_Bonus, cap)
										-- Range_Bonus = math.max(Range_Bonus, 0)
										-- DM.SetProperty(id, 'RangeHillBonus'..'_Weapon_'..i, Range_Bonus) -- Sync value for Ui
									-- end
									-- Calculating Weapon Accuracy
									local distfromtarget = VDist3(UnitPos, TargetPos)
									-- DM.SetProperty(id, 'DistanceFromTarget'..'_Weapon_'..i, distfromtarget) -- Sync value for Ui
									local DamageRadius = wep.DamageRadius or 0
									local AttackRatingUpgrade = DM.GetProperty(id, 'Upgrade_Weapon_'..i..'_Attack Rating') or 0
									local AttackRating = (CF.GetAttackRating(self) + AttackRatingUpgrade) * math.pow(0.75, distfromtarget / 10) * (DamageRadius * 2 + 1) * (1 + wep.Damage/4000)
									local Target = Weap:GetCurrentTarget() or nil
									if Target then
										local _,ChanceToDodge = CF.IsDefenseDodge(Target, AttackRating)
										DM.SetProperty(id, 'Accuracy'..'_Weapon_'..i, 100 - ChanceToDodge)
									end
								end
							end
							local RangeUpgrade = DM.GetProperty(id, 'Upgrade_Weapon_'..i..'_'..'Range', 0) or 0 -- we need to add Range increase from AOH weapon upgrade
							local EnhRangeBonus = 0 -- Range increase from AOC vanilla upgrades
							local TechRange = DM.GetProperty(id, 'Tech_Range', 0)
							if self:HasEnhancement('CrysalisBeam') or self:HasEnhancement('HeavyAntiMatterCannon') or  self:HasEnhancement('CoolingUpgrade') or  self:HasEnhancement('RateOfFire') or  self:HasEnhancement('PhasonBeamAir') then EnhRangeBonus =  22 end -- ACU range enh compatibility 
							if TotalRadius != wep.MaxRadius + RangeUpgrade + EnhRangeBonus + TechRange then
								Weap:ChangeMaxRadius(wep.MaxRadius + RangeUpgrade + EnhRangeBonus + TechRange)
								TotalRadius = wep.MaxRadius + RangeUpgrade + EnhRangeBonus + TechRange
							end
						end
					end
				end
			end
			if self:IsMoving() then DM.SetProperty(id, 'IsMoving', 1) else DM.SetProperty(id, 'IsMoving', 0) end
			WaitSeconds(3)			
		until(self.Dead == true)
	end,
	
	-- Locked feature because of CPU power cost (1 thread per rogue unit) -- Maybe will do 1 thread only
	-- RogueRadarInvisibility = function(self)
		-- local c = 0
		-- repeat
			-- self:EnableUnitIntel('ToggleBit5', 'RadarStealth')
			-- if c > (math.max(math.max(3, 11-CF.GetUnitLevel(self)), 0)) then self:EnableUnitIntel('ToggleBit8', 'Cloak') else self:DisableUnitIntel('ToggleBit8', 'Cloak') end
			-- WaitSeconds(0.5)
			-- if self.HasTakenDamage == true or self:IsMoving() or self.HasFired == true then c = 0 end
			-- c=c+0.5
		-- until(self.Dead == true)
	-- end,
	
	ExecuteConsolidation = function(self)
		local id = self:GetEntityId()
		local units = AIUtils.GetOwnUnitsAroundPoint(self:GetAIBrain(), categories.ENGINEER, self:GetPosition(), 10)
		local BR = 0
		local NeedtoUpdate = false
		local ActualBR = 0
		for i, unit in units do
			local idu = unit:GetEntityId()
			local bpu = unit:GetBlueprint()
			if table.find(bpu.Categories, 'COMMAND') or table.find(bpu.Categories, 'SUBCOMMANDER') or DM.GetProperty(idu,'PrestigeClassPromoted') == 1 then
			else
				ActualBR = DM.GetProperty(id,'EngineerConsolidationBonus', 0) or 0
				BR = unit:GetBuildRate()
				if (ActualBR + BR) < 5001 then
					CreateLightParticleIntel(unit, -1, self:GetArmy(), 5, 50, 'glow_02', 'ramp_blue_01' )
					unit:Destroy()
					DM.IncProperty(id,'EngineerConsolidationBonus', math.floor(BR))
					NeedtoUpdate = true
				end
			end
		end
		if NeedtoUpdate == true then
			DM.SetProperty(id,'EngineerConsolidation', 2)
			CreateLightParticleIntel(self, -1, self:GetArmy(), 10, 150, 'glow_02', 'ramp_blue_01' )
			DM.SetProperty(id,'SetBuildingSpeed', DM.GetProperty(id,'EngineerConsolidationBonus', 0))
			self.UpdateUnitData(self, 0, false)
		end
		
	end,
	
	UpdateActivity = function(self)
		if not self then return end
		local id = self:GetEntityId()
		local level = CF.GetUnitLevel(self) 
		local bp = self:GetBlueprint()
		local aiBrain = GetArmyBrain(self:GetArmy())
		local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
		local sc = 0
		local compteur = 0
		local compteur2 = 0
		local selfpos = {1,1,1}
		repeat
			DM.SetProperty(id, 'CumulAttackRating', self.GlobalInstigatorAtr)
			self.GlobalInstigatorAtr = 0
			self.InstigatorsData = {}
			-- AutoCast Powers
			if DM.GetProperty(id,'PrestigeClassPromoted') == 1 then
				local PowersList = CF.GetUnitPowers(id)
				local len = table.getn(PowersList)
				for i = 1, len do
					for _, power in Powers do
						if power.Name() == PowersList[i] and power.AutoCast == true and DM.GetProperty(id, PowersList[i]..'_AutoCast') == 1 and power.CanCast(self, true) then
							self:ExecutePower(PowersList[i])
						end
						-- if power.Name() == 'Guardian Transformation' and aiBrain.BrainType != 'Human' and (self:GetHealth() / self:GetMaxHealth()) < 0.20 and power.CanCast(self, true) then
							-- self:ExecutePower( power.Name())
						-- end
					end
				end
				-- local AIDiff = DM.GetProperty('Global', 'AI_Difficulty', 'Low Trained Imperial Troops')
				-- local DifficultyMod = {['No Imperial Troops'] = 1, ['Low Trained Imperial Troops'] = 2, ['Trained Imperial Troops'] = 3, ['Well Trained Imperial Troops'] = 4, ['Elite Imperial Troops'] = 5}
				-- local GuardsBirth = DM.GetProperty(id, 'Guards_Casted', 0)
				if table.find(bp.Categories, 'COMMAND') and aiBrain.BrainType != 'Human' then
					local Time =  math.min(GetGameTimeSeconds(), 7000)
					DM.SetProperty(id, 'Upgrade_Armor_Health Increase', 5000 * (1 + Time/500))
					DM.SetProperty(id, 'Upgrade_Armor_Regeneration Increase', Time/50)
					if table.find(bp.Categories, 'CYBRAN') then
						DM.SetProperty(id, 'Upgrade_Weapon_2_Armor Piercing', 25)
						DM.SetProperty(id, 'Upgrade_Weapon_2_Damage to All Units', 25 * (1 + Time/1000))
					else
						DM.SetProperty(id, 'Upgrade_Weapon_1_Armor Piercing', 50)
						DM.SetProperty(id, 'Upgrade_Weapon_1_Damage to All Units', 25 * (1 + Time/1000))
					end
				end
				-- if table.find(bp.Categories, 'COMMAND') and (self:GetHealth() / self:GetMaxHealth()) < 0.40 and aiBrain.BrainType != 'Human' and DifficultyMod[AIDiff] >= 3  and (GetGameTimeSeconds() - GuardsBirth) > (60 - DifficultyMod[AIDiff] * 8)  and GetGameTimeSeconds() > 240 then
					-- self:SetWeaponEnabledByLabel('ColdBeam', true)
						-- DM.SetProperty(id, 'StanceState', 'Offensive')
					-- DM.SetProperty(id, 'ColdBeam_AutoCast', 1)
					-- Setting rescue AI ACU guards
					-- local Rank = {['Ensign'] = 1, ['Lieutenant *'] = 2, ['Captain **'] = 3, ['Commander ***'] = 4, ['Commodore ****'] = 5, ['Vice-Admiral *****'] = 6, ['Admiral ******'] = 7}
					-- local AI_Champion = DM.GetProperty(id, 'AI_Champion')
					-- local AI_ACU_Rank = Rank[AI_Champion]
					-- local c = 0
					-- local pos = self:GetPosition()
					-- repeat
						-- local Model = {'XEL0305', 'XAA0305', 'dslk004'}
						-- local ModelRoll = Model[math.ceil(math.random(1, 3))]
						-- local unit = aiBrain:CreateUnitNearSpot(ModelRoll, pos[1]+2, pos[3]-5)
						-- local SupId = unit:GetEntityId()
						-- DM.SetProperty(SupId, 'BaseClass', 'Rogue')
						-- unit:ForcePromote(0, 0, 'Bard')
						-- if ModelRoll == 'XAA0305' then
							-- DM.SetProperty(SupId, 'Upgrade_Armor_Light Armor', 25)
							-- DM.SetProperty(SupId, 'Upgrade_Armor_Light Armor_Level', 5)
							-- DM.SetProperty(SupId, 'Upgrade_Armor_Armor for Direct Fire', 100)
							-- DM.SetProperty(SupId, 'Upgrade_Armor_Armor for Direct Fire_Level', 1)
							-- DM.SetProperty(SupId, 'Upgrade_Armor_Armor for Anti Air', 100)
							-- DM.SetProperty(SupId, 'Upgrade_Armor_Armor for Anti Air', 1)
							-- DM.SetProperty(SupId, 'Upgrade_Armor_Health Increase', 4000)
							-- DM.SetProperty(SupId, 'Upgrade_Armor_Health Increase_Level', 1)
							-- DM.SetProperty(SupId, 'Upgrade_Armor_Regeneration Increase', 6)
							-- DM.SetProperty(SupId, 'Upgrade_Armor_Regeneration Increase_Level', 1)
						-- elseif ModelRoll == 'XEL0305' or 'dslk004' then
							-- DM.SetProperty(SupId, 'Upgrade_Armor_Light Armor', 35)
							-- DM.SetProperty(SupId, 'Upgrade_Armor_Light Armor_Level', 5)
							-- DM.SetProperty(SupId, 'Upgrade_Armor_Armor for Direct Fire', 100)
							-- DM.SetProperty(SupId, 'Upgrade_Armor_Armor for Direct Fire_Level', 1)
							-- DM.SetProperty(SupId, 'Upgrade_Armor_Health Increase', 12000)
							-- DM.SetProperty(SupId, 'Upgrade_Armor_Health Increase_Level', 1)
							-- DM.SetProperty(SupId, 'Upgrade_Armor_Regeneration Increase', 25)
							-- DM.SetProperty(SupId, 'Upgrade_Armor_Regeneration Increase_Level', 1)
							-- DM.SetProperty(id, 'StanceState', 'Offensive')
						-- end
						-- DM.SetProperty(SupId, 'Upgrade_Weapon_1_Armor Piercing', 82)
						-- DM.SetProperty(SupId, 'Upgrade_Weapon_1_Armor Piercing_Level', 1)
						-- unit:ExecutePower('LesserShield')
						-- local chants = {'GentleMelody', 'CalmingMelody', 'BattleSong', 'BalladoftheWind'}
						-- unit:ExecutePower(chants[math.ceil(math.random(1, 4))])
						-- unit:AdjustHealth(unit, 100000)
						-- DM.SetProperty(SupId, 'DreadDissonance_AutoCast', 1)
						-- unit:SetCustomName('Imperial Guard')
						-- c = c+1
					-- until(c > (DifficultyMod[AIDiff] + AI_ACU_Rank))
					-- if AI_ACU_Rank >= 5 and DifficultyMod[AIDiff] >= 3 then
						-- local unit = aiBrain:CreateUnitNearSpot('url0402', pos[1]+2, pos[3]-5)
						-- unit:SetCustomName('Imperial Guard')
					-- end
					-- if AI_ACU_Rank >= 6 and DifficultyMod[AIDiff] >= 4 then
						-- local unit = aiBrain:CreateUnitNearSpot('xrl0403', pos[1]+2, pos[3]-5)
						-- unit:SetCustomName('Imperial Guard')
					-- end
					-- if AI_ACU_Rank >= 7 and DifficultyMod[AIDiff] >= 5 then
						-- local unit = aiBrain:CreateUnitNearSpot('xsl0401', pos[1]+2, pos[3]-5)
						-- unit:SetCustomName('Imperial Guard')
					-- end
					-- DM.SetProperty(id, 'Guards_Casted', GetGameTimeSeconds())
				-- end
				-- if table.find(bp.Categories, 'SUBCOMMANDER') and aiBrain.BrainType != 'Human' then
					-- self:SetWeaponEnabledByLabel('ColdBeam', true)
				-- end
				if CF.HasATargetOnWeapon(self) == true then
					DM.SetProperty(id, 'HasATarget', true)
				else
					DM.SetProperty(id, 'HasATarget', false)
				end
			end
			-- Auto training skills
			if DM.GetProperty(id, 'Weapon Skill') and self.HasFired == true then
				local Attenuate = math.min(CF.GetSkillCurrent(id, 'Weapon Skill')/10, 10)
				local Gain = math.pow(0.90, Attenuate)
				DM.IncProperty(id, 'Weapon Skill', Gain)
			end
			if DM.GetProperty(id, 'Weapon Skill Mastery') and CF.GetSkillCurrent(id, 'Weapon Skill') >= 100  and self.HasFired == true then
				local Attenuate = math.min(CF.GetSkillCurrent(id, 'Weapon Skill')/10, 10)
				local Gain = math.pow(0.90, Attenuate)
				DM.IncProperty(id, 'Weapon Skill', Gain)
			end
			if DM.GetProperty(id, 'Upgrade_Armor_Light Armor') and self.HasTakenDamage == true then -- We need to find an upgrade to train it.
				local Attenuate = math.min(CF.GetSkillCurrent(id, 'Light Armor Mastery')/10, 10)
				local Gain =math.pow(0.90, Attenuate)
				DM.IncProperty(id, 'Light Armor Mastery', Gain)
			elseif  DM.GetProperty(id, 'Upgrade_Armor_Medium Armor') and self.HasTakenDamage == true then
				local Attenuate = math.min(CF.GetSkillCurrent(id, 'Medium Armor Mastery')/10, 10)
				local Gain =math.pow(0.90, Attenuate)
				DM.IncProperty(id, 'Medium Armor Mastery', Gain)
			elseif  DM.GetProperty(id, 'Upgrade_Armor_Heavy Armor') and self.HasTakenDamage == true then
				local Attenuate = math.min(CF.GetSkillCurrent(id, 'Heavy Armor Mastery')/10, 10)
				local Gain = math.pow(0.90, Attenuate)
				DM.IncProperty(id, 'Heavy Armor Mastery', Gain)
			end
			if DM.GetProperty(id, 'UpdateUnit') and DM.GetProperty(id, 'UpdateUnit') ~= 0 then
				self.UpdateUnitData(self, DM.GetProperty(id, 'UpdateUnit'))
				DM.SetProperty(id,'UpdateUnit', 0)
			end
			-- Setting Power Capacitor and Weapon Capacitor gain (stamina). 
			if DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 then
				if self.HasFired == true then 
					DM.IncProperty(id, 'Stamina', -1)
					DM.SetProperty(id, 'Stamina', math.max(DM.GetProperty(id, 'Stamina'), 0))
				end
				if DM.GetProperty(id, 'Stamina_Max') > DM.GetProperty(id, 'Stamina') then
					local brain = self:GetAIBrain()
					local Hull = DM.GetProperty(id, 'Hull', 25)
					local WeaponCapStanceMod = CF.GetStanceModifier(self,  'StaminaRegen_Mod')
					local WeaponCapacitorRecoveryBuff = 1 + AoHBuff.GetBuffValue(self, 'WeaponCapacitorRecovery', 'ALL') / 100
					local Stamina = 0.8 * Hull / 30 * WeaponCapStanceMod * (1 + level/50) * WeaponCapacitorRecoveryBuff
					local CostMod = math.pow(bp.Economy.BuildCostMass, 0.5)
					if brain:GetEconomyStored('ENERGY')  > (4000 + CostMod * Stamina * 6) then
						DM.IncProperty(id, 'Stamina', Stamina)
						DM.SetProperty(id, 'Stamina', math.min(DM.GetProperty(id, 'Stamina_Max'), DM.GetProperty(id, 'Stamina')))
						DM.SetProperty(id, 'RefreshPowers',1)
						Event['StaminaRegen'..id] = CreateEconomyEvent(self, 6 * CostMod * Stamina, 0, 1)
					end
				end
				if DM.GetProperty(id, 'Capacitor_Max') > DM.GetProperty(id, 'Capacitor') then
					local brain = self:GetAIBrain()
					local Intelligence = DM.GetProperty(id, 'Intelligence', 25)
					local PowerCapacitorRecoveryBuff = 1 + AoHBuff.GetBuffValue(self, 'PowerCapacitorRecovery', 'ALL') / 100
					local Capacitor =  2 * Intelligence / 25 * PowerCapacitorRecoveryBuff * (1 + level/50)
					local CostMod = math.pow(bp.Economy.BuildCostMass, 0.5)
					if brain:GetEconomyStored('ENERGY')  > (4000 + 6 * CostMod * Capacitor) then
						DM.IncProperty(id, 'Capacitor', Capacitor)
						DM.SetProperty(id, 'Capacitor', math.min(DM.GetProperty(id, 'Capacitor_Max'), DM.GetProperty(id, 'Capacitor')))
						DM.SetProperty(id, 'RefreshPowers',1)
						Event['PowerCapacitorRegen'..id] = CreateEconomyEvent(self, 6 * CostMod * Capacitor, 0, 1)
					end
				end
			end
			-- Rate of fire mod
			for i, wep in bp.Weapon do
				if wep.Label == 'DeathWeapon' or wep.Label == 'DeathImpact' or  bp.Weapon.TargetType == 'RULEWTT_Projectile' or wep.DisplayName == 'Teleport in' or wep.Label =='ChronoDampener' or wep.Label =='CollossusDeath' or wep.Label =='MegalithDeath' then
				else
					if wep.Damage > 0 then
						Weap = self:GetWeapon(i)
						local bpwp = Weap:GetBlueprint()
						local RofStance = CF.GetRateOfFireRating(self)
						local ROfUp = (DM.GetProperty(id, 'Upgrade_Weapon_'..i..'_'..'Rate Of Fire', 0) or 0) / 100
						local RofEnh = 0
						local RofBuff = AoHBuff.GetBuffValue(self, 'RateOfFire', 'ALL') / 100
						local RofTech = DM.GetProperty(id, 'Tech_Rate Of Fire', 0)
						if self:HasEnhancement('CrysalisBeam') or self:HasEnhancement('HeavyAntiMatterCannon') or  self:HasEnhancement('CoolingUpgrade') or self:HasEnhancement('RateOfFire') then RofEnh = 1 end -- ACU range enh compatibility 
						Weap:ChangeRateOfFire((bpwp.RateOfFire + RofTech + RofBuff + ROfUp + RofEnh) * RofStance)
					end
				end
			end
			-- Moving stance Mod
			BuffBlueprint {
				Name = 'Stance',
				DisplayName = 'Stance',
				BuffType = 'Stance',
				Stacks = 'REPLACE',
				Duration = -1,
				Affects = {
						MoveMult = {
							Add = 0,
							Mult = CF.GetStanceModifier(self,'Move_Mod'),
						},
				},
			}
			Buff.ApplyBuff(self, 'Stance')
			-- Auto Move state
			-- local Behaviour = DM.GetProperty(id, 'Behaviour', 'Standing')
			-- compteur = compteur + 2
			-- compteur2 = compteur2 + 2
			-- if DM.GetProperty(id, 'InitMove', 0) == 1 then
				-- selfpos =  self:GetPosition()
				-- DM.SetProperty(id, 'InitMove', nil)
			-- else
				-- if DM.GetProperty(id, 'ChangingBehaviour', 0) == 1 then
					-- IssueClearCommands({self})
					-- DM.SetProperty(id,'ChangingBehaviour', nil)
				-- end
			-- end
			-- if Behaviour == 'Auto Move' then
				-- if compteur2 > 20 then
					-- IssueClearCommands({self})
					-- compteur2 = 0
				-- end
				-- local position = {selfpos[1] + math.sin(compteur) * 3, selfpos[2], selfpos[3] + math.cos(compteur) * 3}
				-- IssueMove({self}, position)
			-- end
			-- Support Regen Thread
			-- if BaseClass == 'Support' then
				-- if self.HasTakenDamage == true or self.HasFired == true or self:IsMoving() then
					-- sc = 0
				-- else
					-- if (self:GetHealth() < self:GetMaxHealth()) and sc > 10 and (DM.GetProperty(id, 'Capacitor') > (DM.GetProperty(id, 'Capacitor_Max') / 2)) then
						-- local army = self:GetArmy()
						-- local intelligence = DM.GetProperty(id, 'Intelligence', 15)
						-- local Restoration = DM.GetProperty(id, 'Restoration', 15)
						-- local level = CF.GetUnitLevel(self) 
						-- local HealAmount = (bp.Defense.MaxHealth + CF.GetGainPerLevel(self, 'Health') * (level - 1)) * 0.003 * (1 + intelligence / 50) * (1 + Restoration / 100)
						-- self:AdjustHealth(self, HealAmount)
						-- DM.IncProperty(id, 'Capacitor', - 2)
					-- end
					-- sc = sc + 1
				-- end
			-- end
			-- Vision Radius 
			if table.find(bp.Categories, 'COMMAND') and self:HasEnhancement('EnhancedSensors') then
				self:SetIntelRadius('Vision', bp.NewVisionRadius or 104)
				self:SetIntelRadius('Omni', bp.NewOmniRadius or 104)
			end
			self.HasTakenDamage = false
			self.HasFired = false
			-- Ressources production
			-- Mass and Energyproduction upgrade
			if table.find(bp.Categories, 'COMMAND') or table.find(bp.Categories, 'SUBCOMMANDER') then
				local RessourceMassAlloc = 0
				local RessourceEnergyAlloc = 0
				local MassProduction = DM.GetProperty(id,'Upgrade_Armor_Mass Production Increase', 0)
				local EnergyProduction = DM.GetProperty(id,'Upgrade_Armor_Energy Production Increase', 0) / 20
				if table.find(bp.Categories, 'SUBCOMMANDER') and table.find(bp.Categories, 'SERAPHIM') then
					MassProduction = MassProduction / 2
					EnergyProduction = EnergyProduction / 10
				end
				if self:HasEnhancement('ResourceAllocation') then	
					if table.find(bp.Categories, 'SUBCOMMANDER') then
						RessourceMassAlloc = 10
						RessourceEnergyAlloc = 50
					elseif table.find(bp.Categories, 'COMMAND') then
						RessourceMassAlloc = 16
						RessourceEnergyAlloc = 100
					end
				end
				if self:HasEnhancement('ResourceAllocationAdvanced') then
					RessourceMassAlloc = 32
					RessourceEnergyAlloc = 200
				end
				BuffBlueprint {
					Name = 'UpgradeProduction',
					DisplayName = 'UpgradeProduction',
					BuffType = 'UpgradeProduction',
					Stacks = 'REPLACE',
					Duration = -1,
					Affects = {
						EnergyProduction = {
							Add = RessourceEnergyAlloc + EnergyProduction,
						},
						MassProduction = {
							Add = RessourceMassAlloc + MassProduction,
						},
					},
				}
				Buff.ApplyBuff(self, 'UpgradeProduction')
			end
			WaitSeconds(1)
		until(self.Dead == true)
	end,
	
	UpdateHeroesEffect = function(self,id)
	-- Code here for permanent Heroes Fx 
	end,

	KillMarker = function(self, Marker, Time, Type)
		local id = self:GetEntityId()
		WaitSeconds(Time)
		if self.Dead == false then
			DM.SetProperty(id, Marker, nil)
			if Type == 'Heal' then
				DM.IncProperty(id, 'HealedStack', -1)
			end
		end
	end,
	
	ExecutePower = function(self, OrderName, Option)
		local id = self:GetEntityId()
		local PowersList = CF.GetUnitPowers(id)
		for _, PowerName in PowersList do -- TO DO we need to recode this for direct access power without checking list (better CPU performance)
			if OrderName == PowerName then
				local power = CF.GetUnitPower(id, PowerName)
				local TempEntity = Entity()
				power.OnCast(self, TempEntity, Option)
			end
		end
	end,
	
	ExecuteWeaponPower = function(instigator, OrderName, target)
		if instigator then
			local idi = instigator:GetEntityId()
			local PowersList = CF.GetUnitPowers(idi)
			for _, PowerName in PowersList do -- TO DO we need to recode this for direct access power without checking list (better CPU performance)
				if OrderName == PowerName then
					local power = CF.GetUnitPower(idi, PowerName)
					power.OnWeaponHit(target, instigator)
				end
			end
		end
	end,
	
	GetStrikeData = function(self, OrderName)
		local id = self:GetEntityId()
		local PowersList = CF.GetUnitPowers(id)
		for _, PowerName in PowersList do -- TO DO we need to recode this for direct access power without checking list (better CPU performance)
			if OrderName == PowerName then
				local power = CF.GetUnitPower(id, PowerName)
				return power.StrikeData(self)
			end
		end
	end,
	

	-----------------------------DESTRUCTIVE HOOKING -- inactivating Default buffs veterancy for Alliance of Heroes Veterancy
    SetVeteranLevel = function(self, level)
        self:GetAIBrain():OnBrainUnitVeterancyLevel(self, level)
        self:DoUnitCallbacks('OnVeteran')
    end,
	
	VeterancyDispersal = function(self, suicide)
        local bp = self:GetBlueprint()
        local mass = self:GetVeterancyValue()
        -- Adjust mass based on current health when a unit is self destructed
        if suicide then
            mass = mass * (1 - self:GetHealth() / self:GetMaxHealth())
        end

        for _, data in self.Instigators do
            local unit = data.unit
            -- Make sure the unit is something which can vet, and is not maxed
            if unit and not unit.Dead then -- and unit.gainsVeterancy and unit.Sync.VeteranLevel < 5 then -- Franck : Unlocking XP after level 5 veterancy
                -- Find the proportion of yourself that each instigator killed
                local massKilled = math.floor(mass * (data.damage / self.totalDamageTaken))
                unit:OnKilledUnit(self, massKilled)
            end
        end
    end,
	---------------------------------------------------

	OldOnKilledUnit = Unit.OnKilledUnit,
	OnKilledUnit = function(self, unitKilled, massKilled)
		local idk = unitKilled:GetEntityId()
		if not self then return end
		local id = self:GetEntityId()
		if not massKilled or massKilled == 0 then return end -- Make sure engine calls aren't passed with massKilled == 0
        if IsAlly(self:GetArmy(), unitKilled:GetArmy()) then return end -- No XP for friendly fire...
		local bp = self:GetBlueprint()
		local ACUXPMod = 1
		if table.find(bp.Categories, 'COMMAND') then ACUXPMod = 2.5 end -- We mod the Mass value of the ACU for more realistic XP
		-- We take care of level difference between units and the hero status
		local LevelMod = 1
		local SelfLevel = (CF.GetUnitLevel(self) + DM.GetProperty(id, 'Imperial_Rank', 0)) * CF.GetUnitTech(self)
		local UnitKilledLevel = (CF.GetUnitLevel(unitKilled) + DM.GetProperty(idk, 'Imperial_Rank', 0)) * CF.GetUnitTech(unitKilled)
		if SelfLevel > UnitKilledLevel then
			LevelMod = math.pow(0.95, SelfLevel - UnitKilledLevel)
		elseif SelfLevel < UnitKilledLevel then
			LevelMod = (UnitKilledLevel - SelfLevel) * 1.3
		else
			LevelMod = 1
		end
		local HeroXPMod = 1
		if DM.GetProperty(idk,'PrestigeClassPromoted', nil) == 1 then
			HeroXPMod = 4
		end
		local EliteXPMod = 1
		if DM.GetProperty(idk, 'Type', nil) == 'Elite' then
			local EliteLevel = DM.GetProperty(idk, 'EliteLevel', 1)
			EliteXPMod = 200 * EliteLevel
		end
		local feat = 1
		if massKilled / bp.Economy.BuildCostMass > 1 then feat = math.pow(massKilled / bp.Economy.BuildCostMass, 0.5) end
		self.MassKilled = self.MassKilled + massKilled -- Saving Mass Killed by unit
		local XPEarn = math.ceil(math.pow(massKilled, 0.5) * LevelMod * ACUXPMod * HeroXPMod * feat * 0.3 * EliteXPMod)
		Unit.UpdateUnitData(self, XPEarn)
		Unit.OldOnKilledUnit(self, unitKilled, massKilled)
    end,
	
	OldOnKilled = Unit.OnKilled,
	OnKilled = function(self, instigator, type, overkillRatio)
		local idk = self:GetEntityId()
		local bp = self:GetBlueprint()
		if DM.GetProperty(idk,'PrestigeClassPromoted', nil) == 1 then
			-- Giveback ressource storage at unit death
			local BaseClass = DM.GetProperty(idk,'BaseClass','Fighter')
			if BaseClass == 'Support' then
				local Power = math.ceil(math.pow(bp.Economy.BuildCostMass, 0.9))
				local CurrentStorage = DM.GetProperty('Global'..self:GetArmy(), 'EnergyStorage')
				CurrentStorage = CurrentStorage - Power * 2000
				self:GetAIBrain():GiveStorage('Energy', CurrentStorage)
				DM.SetProperty('Global'..self:GetArmy(), 'EnergyStorage', CurrentStorage)
			end
			-- Refreshing Logistics
			local army = self:GetArmy()
			local ArmyBrain = GetArmyBrain(self:GetArmy())
			DM.SetProperty('Global'..army, 'Logistics', CF.GetLogisticAvailable(ArmyBrain))
		end
		Unit.OldOnKilled(self, instigator, type, overkillRatio)
	end,
	
	--- Called at the end of the destruction thread: create the wreckage and Destroy this unit.
	OldDestroyUnit = Unit.DestroyUnit,
	DestroyUnit = function(self, overkillRatio)
		local idk = self:GetEntityId()
		if DM.GetProperty(idk,'PrestigeClassPromoted', nil) == 1 then -- Refreshing logistics
			local army = self:GetArmy()
			local ArmyBrain = GetArmyBrain(self:GetArmy())
			DM.SetProperty('Global'..army, 'Logistics', CF.GetLogisticAvailable(ArmyBrain))
			DM.RemoveId(idk)
		end
		Unit.OldDestroyUnit(self, overkillRatio)
	end,
	
	-----------------------------------------------------------------------------------------------------------------------------------
	-- DESTRUCTIVE HOOKING (seems that it can only be done with destructive) - Adding Defense Rating Dodging - Full projectile dodge.--
	-----------------------------------------------------------------------------------------------------------------------------------
    OnCollisionCheck = function(self, other, firingWeapon)
        if self.DisallowCollisions then
            return false
        end
        if EntityCategoryContains(categories.PROJECTILE, other) then
            if self:GetArmy() == other:GetArmy() then
                return other.CollideFriendly
            end
        end
        --Check for specific non-collisions
        local bp = other:GetBlueprint()
        if bp.DoNotCollideList then
            for k, v in pairs(bp.DoNotCollideList) do
                if EntityCategoryContains(ParseEntityCategory(v), self) then
                    return false
                end
            end
        end
        bp = self:GetBlueprint()
        if bp.DoNotCollideList then
            for k, v in pairs(bp.DoNotCollideList) do
                if EntityCategoryContains(ParseEntityCategory(v), other) then
                    return false
                end
            end
        end
		if other.DamageData.DamageType then -- this has a double function : add any unknown instigatorid to the table and calculate the actual instigators global atr
			local ProjData = Proj.Projectiles['ProjId'..other.DamageData.DamageType]
			local CurrentInstigatorsAttackRating = 0
			self.InstigatorsData[ProjData.InstigatorId] = ProjData.AttackRating
			local c = 0
			for ids, Atr in self.InstigatorsData do
				c = c + 1
				if ids != ProjData.InstigatorId then
					if c == 1 then
						CurrentInstigatorsAttackRating = CurrentInstigatorsAttackRating + Atr
					else
						CurrentInstigatorsAttackRating = CurrentInstigatorsAttackRating + Atr/4
					end
				else
					if c == 1 then
						CurrentInstigatorsAttackRating = CurrentInstigatorsAttackRating + ProjData.AttackRating
					else
						CurrentInstigatorsAttackRating = CurrentInstigatorsAttackRating + ProjData.AttackRating/4
					end
				end
			end
			self.GlobalInstigatorAtr = CurrentInstigatorsAttackRating
			if CF.IsDefenseDodge(self, CurrentInstigatorsAttackRating,  ProjData.Stance or 'Normal') then
				return false
			end
		end
		return true
    end,
------------------------------------------------------------------------------------------------------------
		
	UpdateUnitData = function(self, XP, GenerateGlobalXP)
		if not self or self.Dead == true then return end
		local id = self:GetEntityId()
		local Classid = self:GetUnitId()
		local bp = self:GetBlueprint()
		local army = self:GetArmy()
		local level = CF.GetUnitLevel(self)
		local BaseClass = DM.GetProperty(id,'BaseClass','Fighter')
		local PrestigeClass = DM.GetProperty(id,'PrestigeClass')
		local Promoted = false
		if DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 then 
			Promoted = true 
			if DM.GetProperty(id,'PrestigeClass') == 'NeedPromote'  -- Fixing weird bug
				then DM.SetProperty(id,'PrestigeClassPromoted', 0)
				Promoted = false 
			end
		end
		-- Promotion points update
		if Promoted == true then
			local ArmyBrain = GetArmyBrain(self:GetArmy())
			-- LOG('Heroes table '..repr(CF.SortDualHeroList()))
			DM.SetProperty('Global'..army, 'Logistics', CF.GetLogisticAvailable(ArmyBrain))
		end
	
		if XP then 	
			XP = math.min(XP * 6 / CF.GetUnitTech(self), 200) -- we cap the xp to 200 (about 2-3 levels)
			-- XP global
			DM.IncProperty(id, 'XP', XP)
			local XPDrawn = math.floor(XP)
			if DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 and XPDrawn > 10 then
				FX.DrawNumbers(self, XPDrawn, 'Purple') -- Let us drawing XP over unit.
			end
			-- Adding part of the XP to the global pool
			if GenerateGlobalXP != false then
				local Power = math.floor(math.pow(bp.Economy.BuildCostMass, 0.5))
				DM.IncProperty('Global'..self:GetArmy(), 'MilitaryXP', XP * 0.25 * Power)
				-- Adding XP for tech tree features
				if table.find(bp.Categories, 'LAND') and table.find(bp.Categories, 'MOBILE') then
					if DM.GetProperty('Global'..self:GetArmy(), 'LandMobileXP')  then
						DM.IncProperty('Global'..self:GetArmy(), 'LandMobileXP', XP * 0.5)
					else
						DM.SetProperty('Global'..self:GetArmy(), 'LandMobileXP', 0)
						DM.IncProperty('Global'..self:GetArmy(), 'LandMobileXP', XP * 0.5)
					end
					-- LOG(DM.GetProperty('Global'..self:GetArmy(), 'LandMobileXP')..' +'..XP)
				end
			end
			-- LOG(DM.GetProperty('Global'..self:GetArmy(), 'LandMobileXP', 0))
			-- Xp training Abilities
			local TotalTrainingWeight = 0.001
			local Abilities = {'Puissance', 'Dexterity', 'Hull', 'Intelligence', 'Energy'}
			for i, Ability in Abilities do
				if DM.GetProperty(id, Ability) < DM.GetProperty(id, Ability..'_Max') then
					TotalTrainingWeight = TotalTrainingWeight + DM.GetProperty(id, Ability..'_TrainingWeight')
				else
					DM.SetProperty(id, Ability..'_TrainingWeight', 0.001)
				end
			end
			for i, Ability in Abilities do
				if DM.GetProperty(id, Ability) <= DM.GetProperty(id, Ability..'_Max') then
					local Gain = XP/30 * (DM.GetProperty(id, Ability..'_TrainingWeight') / TotalTrainingWeight)
					DM.SetProperty(id, Ability,  math.min(DM.GetProperty(id, Ability) + Gain, DM.GetProperty(id, Ability..'_Max')))
				end
			end
		end
		level = CF.GetUnitLevel(self) -- We need to recast level after XP
		
		-- Capacitor and Stamina
		if Promoted == true then
			local Stamina =  50 + CF.GetGainPerLevel(self, 'Weapon Capacitor') * level
			DM.SetProperty(id, 'Stamina_Max', Stamina)
			local Capacitor = 100 + CF.GetGainPerLevel(self, 'Power Capacitor') * level
			DM.SetProperty(id, 'Capacitor_Max', Capacitor)
		end		
		-- Name
		if level >= 2 and Promoted == true and DM.GetProperty(id, 'AI_Champion', 0) == 0  then
			self:SetCustomName(PrestigeClass..' ['..level..']')
		end
		local aiBrain = GetArmyBrain(self:GetArmy())	
		
		if table.find(bp.Categories, 'COMMAND') and aiBrain.BrainType != 'Human' then
			local Name = DM.GetProperty(id, 'AI_Champion', '')
			self:SetCustomName(Name)
		end		

		-- Veterancy bonuses
		local Building = 0
		local Power = math.floor(math.pow(bp.Economy.BuildCostMass, 0.5))
		if table.find(bp.Categories, 'COMMAND') then
			if level <= 5 then
				Building = 0
			else
				Building = (Power / 7 * CF.GetSkillCurrent(id, 'Building') / 5) - 7
			end
		elseif table.find(bp.Categories, 'CONSTRUCTION') or table.find(bp.Categories, 'ENGINEER') or table.find(bp.Categories, 'FACTORY') then
			Building = (Power / 7 * CF.GetSkillCurrent(id, 'Building') / 5) - 1 + math.min(DM.GetProperty(id, 'EngineerConsolidationBonus', 0), DM.GetProperty(id, 'SetBuildingSpeed', DM.GetProperty(id, 'EngineerConsolidationBonus', 0))) +  DM.GetProperty(id, 'Upgrade_Armor_Build Rate Increase', 0)
		end
		-- MaxHealth 
		-- Upgrade
		local ArmorUGMaxHealth = DM.GetProperty(id,'Upgrade_Armor_Health Increase', 0)
		local PrestigeClassHealthBonus = 0
		local PrestigeClassModifier = 1
		if Promoted == true then
			PrestigeClassHealthBonus = CF.GetGainPerLevel(self, 'Health') * 20
			PrestigeClassModifier =  PC[BaseClass..' '..PrestigeClass]['MaxHealthMod'] or 1
		end
		
		-- BaseClass Health Modifier
		local BCHealthMod = 0
		local Hull = DM.GetProperty(id, 'Hull', 25)
		if Hull < 30 then
			BCHealthMod = math.ceil((30-Hull)/30 * bp.Defense.MaxHealth)
		end
		
		-- Range
	
		if Promoted == true then
			if table.find(bp.Categories, 'AIR') or table.find(bp.Categories, 'NAVAL') or table.find(bp.Categories, 'HIGHALTAIR') or table.find(bp.Categories, 'COMMAND') then
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
		end
		
		BuffBlueprint {
			Name = 'HeroesXP',
			DisplayName = 'HeroesXP',
			BuffType = 'HEROES',
			Stacks = 'REPLACE',
			Duration = -1,
			Affects = {
				MaxHealth = {
					DoNoFill = true,
					Add = PrestigeClassHealthBonus + ArmorUGMaxHealth + CF.GetGainPerLevel(self, 'Health') * (level - 1) - BCHealthMod,
					Mult = PrestigeClassModifier or 1,
				},
				Regen = {
					Add = CF.GetUnitRegen(self),
					Mult = 1,
				},
				BuildRate = {
					Add = Building or 0,
					Mult = 1,
				},
				MoveMult = {
					Add = 0,
					Mult = 1,
				},
			},
		}
		Buff.ApplyBuff(self, 'HeroesXP')
	end,
	
	CreateFx = function(self, FxPath, WaitStart, Duration, SizeModifier, bone) -- called from individual power scripts
		if bone == nil then
			FxId = FxId + 1	
			self.FxThread = self:ForkThread(self.FxExecuter, FxPath, WaitStart, Duration, SizeModifier, nil, FxId)
		else
			local totalBones = self:GetBoneCount() - 1
			for _bone = 1, totalBones do
				self.FxThread = self:ForkThread(self.FxExecuter, FxPath, WaitStart, Duration, SizeModifier, _bone, FxId)
			end
		end
	end,
	
	FxExecuter = function(self, FxPath, WaitStart, Duration, SizeModifier, bone, _FxId)
		WaitSeconds(WaitStart)
		local bp = self:GetBlueprint()
		local size = math.pow(bp.SizeX * bp.SizeZ, 0.5) * 0.5
		self['FX'.._FxId] = CreateAttachedEmitter(self, bone or 0, self:GetArmy(), FxPath):ScaleEmitter(size * SizeModifier)--:OffsetEmitter(0,  bp.SizeY/4, 0):SetEmitterCurveParam('LIFETIME_CURVE', 10, 0))
		WaitSeconds(Duration)
		if self then self['FX'.._FxId]:Destroy() end
	end,	
	
}
