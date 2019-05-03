-- Alliance of Heroes
-- Imperial Troops
-- Franck83
-- Locked feature since version 135 because of performance issues.

local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local DifficultyMod = {['No Imperial Troops'] = 0, ['Low Trained Imperial Troops'] = 0.5, ['Trained Imperial Troops'] = 1, ['Well Trained Imperial Troops'] = 1.5, ['Elite Imperial Troops'] = 2}
local DifficultyRoll = {['No Imperial Troops'] = 3, ['Low Trained Imperial Troops'] = 1, ['Trained Imperial Troops'] = 0.75, ['Well Trained Imperial Troops'] = 0.6, ['Elite Imperial Troops'] = 0.5}

Troops = {
	['Ensign'] = {
		Conditions = function(unit, MassIncome, DifficultyScenario, DifficultyAI)
			if (MassIncome * DifficultyScenario) > (30 * DifficultyRoll[DifficultyAI]) and DifficultyAI != 'No Imperial Troops' then
				local bp = unit:GetBlueprint()
				if table.find(bp.Categories, 'TANK') or table.find(bp.Categories, 'BOT') or table.find(bp.Categories, 'SUBCOMMANDER') then
					return math.random(1, 1000) >= 950
				end
			end
		end,
		Recruit = function(unit, id, MassIncome, DifficultyScenario, DifficultyAI)
			local bp = unit:GetBlueprint()
			local roll = math.ceil((MassIncome/10 + DifficultyScenario + math.random(1, 5)) * DifficultyMod[DifficultyAI])
			DM.SetProperty(id, 'Upgrade_Armor_Heavy Armor', 30)
			DM.SetProperty(id, 'Upgrade_Armor_Health Increase', (roll * bp.Defense.MaxHealth * 0.10 + 500))
			DM.SetProperty(id, 'Upgrade_Armor_Regeneration Increase', 10)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Damage to All Units', 200)
			unit:AdjustHealth(unit, 100000)
			DM.SetProperty(id, 'AI_Champion', 1)
			unit:SetCustomName('Ensign ')
			DM.SetProperty(id, 'Imperial_Rank', roll)
		end,
	},
	['Lieutenant'] = {
		Conditions = function(unit, MassIncome, DifficultyScenario, DifficultyAI)
			if (MassIncome * DifficultyScenario) > (60 * DifficultyRoll[DifficultyAI]) and DifficultyAI != 'No Imperial Troops' then
				local bp = unit:GetBlueprint()
				if table.find(bp.Categories, 'TANK') or table.find(bp.Categories, 'BOT') or table.find(bp.Categories, 'SUBCOMMANDER') then
					return math.random(1, 1000) >= 970
				end
			end
		end,
		Recruit = function(unit, id, MassIncome, DifficultyScenario, DifficultyAI)
			local bp = unit:GetBlueprint()
			local roll = math.ceil((MassIncome/10 + DifficultyScenario + math.random(1, 5)) * DifficultyMod[DifficultyAI])
			DM.SetProperty(id, 'Upgrade_Armor_Heavy Armor', 50)
			DM.SetProperty(id, 'Upgrade_Armor_Health Increase', (roll * bp.Defense.MaxHealth * 0.10 + 1500))
			DM.SetProperty(id, 'Upgrade_Armor_Regeneration Increase', 15)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Damage to All Units', 300)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Range', 5)
			DM.SetProperty(id, 'AI_Champion', 1)
			unit:SetCustomName('Lieutenant * ')
			DM.SetProperty(id, 'Imperial_Rank', roll * 2)
			unit:AdjustHealth(unit, 100000)
		end,	
	},
	['Captain'] = {
		Conditions = function(unit, MassIncome, DifficultyScenario, DifficultyAI)
			if (MassIncome * DifficultyScenario) > (90 * DifficultyRoll[DifficultyAI]) and DifficultyAI != 'No Imperial Troops' then
				local bp = unit:GetBlueprint()
				if table.find(bp.Categories, 'TECH2') or table.find(bp.Categories, 'TECH3') then
					if table.find(bp.Categories, 'TANK') or table.find(bp.Categories, 'BOT') or table.find(bp.Categories, 'SUBCOMMANDER') then
						return math.random(1, 1000) >= 980
					end
				end
			end
		end,
		Recruit = function(unit, id, MassIncome, DifficultyScenario, DifficultyAI)
			local bp = unit:GetBlueprint()
			local roll = math.ceil((MassIncome/10 + DifficultyScenario + math.random(1, 5))  * DifficultyMod[DifficultyAI])
			DM.SetProperty(id, 'Upgrade_Armor_Heavy Armor', 60)
			DM.SetProperty(id, 'Upgrade_Armor_Health Increase', (roll * bp.Defense.MaxHealth * 0.10 + 5000))
			DM.SetProperty(id, 'Upgrade_Armor_Regeneration Increase', 30)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Damage to All Units', 500)
			DM.SetProperty(id, 'Upgrade_Weapon_2_Damage to All Units', 500)
			DM.SetProperty(id, 'AI_Champion', 1)
			unit:SetCustomName('Captain ** ')
			DM.SetProperty(id, 'Imperial_Rank', roll * 3)
			unit:AdjustHealth(unit, 100000)
		end,	
	},
	['Commander'] = {
		Conditions = function(unit, MassIncome, DifficultyScenario, DifficultyAI)
			if (MassIncome * DifficultyScenario) > (120 * DifficultyRoll[DifficultyAI]) and DifficultyAI != 'No Imperial Troops' then
				local bp = unit:GetBlueprint()
				if table.find(bp.Categories, 'TECH3') then
					if table.find(bp.Categories, 'TANK') or table.find(bp.Categories, 'BOT') or table.find(bp.Categories, 'SUBCOMMANDER') then
						return math.random(1, 1000) >= 990
					end
				end
			end
		end,
		Recruit = function(unit, id, MassIncome, DifficultyScenario, DifficultyAI)
			local bp = unit:GetBlueprint()
			local roll = math.ceil((MassIncome/10 + DifficultyScenario + math.random(1, 5)) * DifficultyMod[DifficultyAI])
			DM.SetProperty(id, 'Upgrade_Armor_Heavy Armor', 150)
			DM.SetProperty(id, 'Upgrade_Armor_Health Increase', (roll * bp.Defense.MaxHealth * 0.10 + 12000))
			DM.SetProperty(id, 'Upgrade_Armor_Regeneration Increase', 35)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Damage to All Units', 600)
			DM.SetProperty(id, 'Upgrade_Weapon_2_Damage to All Units', 600)
			DM.SetProperty(id, 'Upgrade_Weapon_3_Damage to All Units', 600)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Range', 10)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Armor Piercing', 40)
			DM.SetProperty(id, 'AI_Champion', 1)
			unit:SetCustomName('Commander *** ')
			DM.SetProperty(id, 'Imperial_Rank', roll * 4)
			unit:AdjustHealth(unit, 100000)
		end,	
	},
	['Commodore'] = {
		Conditions = function(unit, MassIncome, DifficultyScenario, DifficultyAI)
			if (MassIncome * DifficultyScenario) > (150 * DifficultyRoll[DifficultyAI]) and DifficultyAI != 'No Imperial Troops' then
				local bp = unit:GetBlueprint()
				if table.find(bp.Categories, 'TECH3') then
					if table.find(bp.Categories, 'TANK') or table.find(bp.Categories, 'BOT') or table.find(bp.Categories, 'SUBCOMMANDER') then
						return math.random(1, 1000) >= 995
					end
				end
			end
		end,
		Recruit = function(unit, id, MassIncome, DifficultyScenario, DifficultyAI)
			local bp = unit:GetBlueprint()
			local roll = math.ceil((MassIncome/10 + DifficultyScenario + math.random(1, 5)) * DifficultyMod[DifficultyAI])
			DM.SetProperty(id, 'Upgrade_Armor_Heavy Armor', 150)
			DM.SetProperty(id, 'Upgrade_Armor_Health Increase', (roll * bp.Defense.MaxHealth * 0.10 + 20000))
			DM.SetProperty(id, 'Upgrade_Armor_Regeneration Increase', 45)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Damage to All Units', 600)
			DM.SetProperty(id, 'Upgrade_Weapon_2_Damage to All Units', 600)
			DM.SetProperty(id, 'Upgrade_Weapon_3_Damage to All Units', 600)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Range', 15)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Armor Piercing', 40)
			DM.SetProperty(id, 'AI_Champion', 1)
			unit:SetCustomName('Commodore **** ')
			DM.SetProperty(id, 'Imperial_Rank', roll * 5)
			unit:AdjustHealth(unit, 100000)
		end,	
	},
	['Vice-Admiral '] = {
		Conditions = function(unit, MassIncome, DifficultyScenario, DifficultyAI)
			if (MassIncome * DifficultyScenario) > (210 * DifficultyRoll[DifficultyAI]) and DifficultyAI != 'No Imperial Troops' then
				local bp = unit:GetBlueprint()
				if table.find(bp.Categories, 'TECH3') then
					if table.find(bp.Categories, 'SUBCOMMANDER') then
						return math.random(1, 100) >= 950
					end
				end
			end
		end,
		Recruit = function(unit, id, MassIncome, DifficultyScenario, DifficultyAI)
			local bp = unit:GetBlueprint()
			local roll = math.ceil((MassIncome/10 + DifficultyScenario + math.random(1, 5)) * DifficultyMod[DifficultyAI])
			unit:ForcePromote(0, 0, 'Guardian')
			DM.SetProperty(id, 'Units Repair_AutoCast', 1)
			DM.SetProperty(id, 'StanceState', 'Offensive')
			DM.SetProperty(id, 'Upgrade_Armor_Heavy Armor', 150)
			DM.SetProperty(id, 'Upgrade_Armor_Health Increase', (roll * bp.Defense.MaxHealth * 0.10 + 20000))
			DM.SetProperty(id, 'Upgrade_Armor_Regeneration Increase', 45)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Damage to All Units', 600)
			DM.SetProperty(id, 'Upgrade_Weapon_2_Damage to All Units', 600)
			DM.SetProperty(id, 'Upgrade_Weapon_3_Damage to All Units', 600)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Range', 15)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Armor Piercing', 80)
			DM.SetProperty(id, 'AI_Champion', 1)
			unit:SetCustomName('Vice-Admiral ***** ')
			DM.SetProperty(id, 'Imperial_Rank', roll * 6)
			unit:AdjustHealth(unit, 100000)
		end,	
	},
}

Experimentals = {
	['Dreadnought Commodore'] = {
		Conditions = function(unit, MassIncome, DifficultyScenario, DifficultyAI, Logistics)
			if (MassIncome * DifficultyScenario) > (180 * DifficultyRoll[DifficultyAI]) and Logistics >= 8 and DifficultyAI != 'No Imperial Troops' then
				local bp = unit:GetBlueprint()
				if table.find(bp.Categories, 'EXPERIMENTAL') then
					return math.random(1, 100) >= 85
				end
			end
		end,
		Recruit = function(unit, id, MassIncome, DifficultyScenario, DifficultyAI)
			local bp = unit:GetBlueprint()
			local roll = math.ceil((MassIncome/10 + DifficultyScenario + math.random(1, 5)) * DifficultyMod[DifficultyAI] * 0.25)
			unit:ForcePromote(0, 0, 'Dreadnought')
			DM.SetProperty(id, 'Upgrade_Armor_Heavy Armor', math.min(roll*5, 100))
			DM.SetProperty(id, 'Upgrade_Armor_Health Increase', (roll * bp.Defense.MaxHealth * 0.05 + 50000))
			DM.SetProperty(id, 'Upgrade_Armor_Regeneration Increase', 50 + roll)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Damage to All Units', roll*3)
			DM.SetProperty(id, 'Upgrade_Weapon_2_Damage to All Units', roll*3)
			DM.SetProperty(id, 'Upgrade_Weapon_3_Damage to All Units', roll*3)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Armor Piercing', roll*2)
			DM.SetProperty(id, 'Challenge_AutoCast', 1)
			DM.SetProperty(id, 'Over Fire_AutoCast', 1)
			DM.SetProperty(id, 'StanceState', 'Offensive')
			DM.SetProperty(id, 'AI_Champion', 1)
			unit:SetCustomName('Dreadnought Commodore **** '..roll)
			DM.SetProperty(id, 'Imperial_Rank', roll * 10)
		end,	
	},
	['Guardian Commodore'] = {
		Conditions = function(unit, MassIncome, DifficultyScenario, DifficultyAI, Logistics)
			if (MassIncome * DifficultyScenario) > (180 * DifficultyRoll[DifficultyAI]) and Logistics >= 8 and DifficultyAI != 'No Imperial Troops' then
				local bp = unit:GetBlueprint()
				if table.find(bp.Categories, 'EXPERIMENTAL') then
					return math.random(1, 100) >= 85
				end
			end
		end,
		Recruit = function(unit, id, MassIncome, DifficultyScenario, DifficultyAI)
			local bp = unit:GetBlueprint()
			local roll = math.ceil((MassIncome/10 + DifficultyScenario + math.random(1, 5)) * DifficultyMod[DifficultyAI] * 0.25)
			unit:ForcePromote(0, 0, 'Guardian')
			DM.SetProperty(id, 'Upgrade_Armor_Heavy Armor', math.min(roll*5 + 50, 100))
			DM.SetProperty(id, 'Upgrade_Armor_Health Increase', (roll * bp.Defense.MaxHealth * 0.05 + 70000))
			DM.SetProperty(id, 'Upgrade_Armor_Regeneration Increase', 50 + roll)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Damage to All Units', roll*2)
			DM.SetProperty(id, 'Upgrade_Weapon_2_Damage to All Units', roll*2)
			DM.SetProperty(id, 'Upgrade_Weapon_3_Damage to All Units', roll*2)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Armor Piercing', roll*2)
			DM.SetProperty(id, 'Units Repair_AutoCast', 1)
			DM.SetProperty(id, 'Intelligence', 50)
			DM.SetProperty(id, 'StanceState', 'Offensive')
			DM.SetProperty(id, 'AI_Champion', 1)
			unit:SetCustomName('Guardian Commodore **** '..roll)
			DM.SetProperty(id, 'Imperial_Rank', roll * 10)
		end,	
	},
	['Dreadnought Vice-Admiral'] = {
		Conditions = function(unit, MassIncome, DifficultyScenario, DifficultyAI, Logistics)
			if (MassIncome * DifficultyScenario) > (210 * DifficultyRoll[DifficultyAI]) and Logistics >= 8  and DifficultyAI != 'No Imperial Troops' then
				local bp = unit:GetBlueprint()
				if table.find(bp.Categories, 'EXPERIMENTAL') then
					return math.random(1, 100) >= 95
				end
			end
		end,
		Recruit = function(unit, id, MassIncome, DifficultyScenario, DifficultyAI)
			local bp = unit:GetBlueprint()
			local roll = math.ceil((MassIncome/10 + DifficultyScenario + math.random(1, 10)) * DifficultyMod[DifficultyAI] * 0.25)
			unit:ForcePromote(0, 0, 'Dreadnought')
			DM.SetProperty(id, 'Upgrade_Armor_Heavy Armor', math.min(roll*5 + 50, 200))
			DM.SetProperty(id, 'Upgrade_Armor_Health Increase', (roll * bp.Defense.MaxHealth * 0.10 + 130000))
			DM.SetProperty(id, 'Upgrade_Armor_Regeneration Increase', 50 + roll)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Damage to All Units', roll*7)
			DM.SetProperty(id, 'Upgrade_Weapon_2_Damage to All Units', roll*7)
			DM.SetProperty(id, 'Upgrade_Weapon_3_Damage to All Units', roll*7)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Armor Piercing', roll*5)
			DM.SetProperty(id, 'Challenge_AutoCast', 1)
			DM.SetProperty(id, 'Over Fire_AutoCast', 1)
			DM.SetProperty(id, 'StanceState', 'Offensive')
			DM.SetProperty(id, 'AI_Champion', 1)
			unit:SetCustomName('Dreadnought Vice-Admiral ***** '..roll)
			DM.SetProperty(id, 'Imperial_Rank', roll * 20)
		end,	
	},
	['Guardian Vice-Admiral'] = {
		Conditions = function(unit, MassIncome, DifficultyScenario, DifficultyAI, Logistics)
			if (MassIncome * DifficultyScenario) > (210 * DifficultyRoll[DifficultyAI]) and Logistics >= 8 and DifficultyAI != 'No Imperial Troops' then
				local bp = unit:GetBlueprint()
				if table.find(bp.Categories, 'EXPERIMENTAL') then
					return math.random(1, 100) >= 90
				end
			end
		end,
		Recruit = function(unit, id, MassIncome, DifficultyScenario, DifficultyAI)
			local bp = unit:GetBlueprint()
			local roll = math.ceil((MassIncome/10 + DifficultyScenario + math.random(1, 10)) * DifficultyMod[DifficultyAI] * 0.25)
			unit:ForcePromote(0, 0, 'Guardian')
			DM.SetProperty(id, 'Upgrade_Armor_Heavy Armor', math.min(roll*5 + 50, 200))
			DM.SetProperty(id, 'Upgrade_Armor_Health Increase', (roll * bp.Defense.MaxHealth * 0.10 + 150000))
			DM.SetProperty(id, 'Upgrade_Armor_Regeneration Increase', 50 + roll)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Damage to All Units', roll*5)
			DM.SetProperty(id, 'Upgrade_Weapon_2_Damage to All Units', roll*5)
			DM.SetProperty(id, 'Upgrade_Weapon_3_Damage to All Units', roll*5)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Armor Piercing', roll*5)
			DM.SetProperty(id, 'Over Fire_AutoCast', 1)
			DM.SetProperty(id, 'Units Repair_AutoCast', 1)
			DM.SetProperty(id, 'Intelligence', 50)
			DM.SetProperty(id, 'StanceState', 'Offensive')
			DM.SetProperty(id, 'AI_Champion', 1)
			unit:SetCustomName('Guardian Vice-Admiral ****** '..roll)
			DM.SetProperty(id, 'Imperial_Rank', roll * 20)
		end,	
	},
	['Dreadnought Admiral'] = {
		Conditions = function(unit, MassIncome, DifficultyScenario, DifficultyAI, Logistics)
			if (MassIncome * DifficultyScenario) > (300 * DifficultyRoll[DifficultyAI]) and Logistics >= 8 and DifficultyAI != 'No Imperial Troops' then
				local bp = unit:GetBlueprint()
				if table.find(bp.Categories, 'EXPERIMENTAL') then
					return math.random(1, 100) >= 95
				end
			end
		end,
		Recruit = function(unit, id, MassIncome, DifficultyScenario, DifficultyAI)
			local bp = unit:GetBlueprint()
			local roll = math.ceil((MassIncome/10 + DifficultyScenario + math.random(1, 10)) * DifficultyMod[DifficultyAI] * 0.25)
			unit:ForcePromote(0, 0, 'Dreadnought')
			DM.SetProperty(id, 'Upgrade_Armor_Heavy Armor', math.min(roll*5 + 50, 250))
			DM.SetProperty(id, 'Upgrade_Armor_Health Increase', (roll * bp.Defense.MaxHealth * 0.15 + 250000))
			DM.SetProperty(id, 'Upgrade_Armor_Regeneration Increase', 50 + roll)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Damage to All Units', roll*15)
			DM.SetProperty(id, 'Upgrade_Weapon_2_Damage to All Units', roll*15)
			DM.SetProperty(id, 'Upgrade_Weapon_3_Damage to All Units', roll*15)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Armor Piercing', roll*5)
			DM.SetProperty(id, 'Challenge_AutoCast', 1)
			DM.SetProperty(id, 'Over Fire_AutoCast', 1)
			DM.SetProperty(id, 'StanceState', 'Offensive')
			DM.SetProperty(id, 'AI_Champion', 1)
			unit:SetCustomName('Dreadnought Vice-Admiral ****** '..roll)
			DM.SetProperty(id, 'Imperial_Rank', roll * 30)
		end,	
	},
	['Guardian Admiral'] = {
		Conditions = function(unit, MassIncome, DifficultyScenario, DifficultyAI, Logistics)
			if (MassIncome * DifficultyScenario) > (300 * DifficultyRoll[DifficultyAI]) and Logistics >= 8 and DifficultyAI != 'No Imperial Troops' then
				local bp = unit:GetBlueprint()
				if table.find(bp.Categories, 'EXPERIMENTAL') then
					return math.random(1, 100) >= 95
				end
			end
		end,
		Recruit = function(unit, id, MassIncome, DifficultyScenario, DifficultyAI)
			local bp = unit:GetBlueprint()
			local roll = math.ceil((MassIncome/10 + DifficultyScenario + math.random(1, 10)) * DifficultyMod[DifficultyAI] * 0.25)
			unit:ForcePromote(0, 0, 'Guardian')
			DM.SetProperty(id, 'Upgrade_Armor_Heavy Armor', math.min(roll*5 + 50, 250))
			DM.SetProperty(id, 'Upgrade_Armor_Health Increase', (roll * bp.Defense.MaxHealth * 0.15 + 300000))
			DM.SetProperty(id, 'Upgrade_Armor_Regeneration Increase', 50 + roll)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Damage to All Units', roll*10)
			DM.SetProperty(id, 'Upgrade_Weapon_2_Damage to All Units', roll*10)
			DM.SetProperty(id, 'Upgrade_Weapon_3_Damage to All Units', roll*10)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Armor Piercing', roll*5)
			DM.SetProperty(id, 'Over Fire_AutoCast', 1)
			DM.SetProperty(id, 'Units Repair_AutoCast', 1)
			DM.SetProperty(id, 'Intelligence', 100)
			DM.SetProperty(id, 'StanceState', 'Offensive')
			DM.SetProperty(id, 'AI_Champion', 1)
			unit:SetCustomName('Guardian Admiral ****** '..roll)
			DM.SetProperty(id, 'Imperial_Rank', roll * 30)
		end,	
	},
	['Bard High-Admiral'] = {
		Conditions = function(unit, MassIncome, DifficultyScenario, DifficultyAI, Logistics)
			if (MassIncome * DifficultyScenario) > (350 * DifficultyRoll[DifficultyAI]) and Logistics >= 8 and DifficultyAI != 'No Imperial Troops' then
				local bp = unit:GetBlueprint()
				if table.find(bp.Categories, 'EXPERIMENTAL') then
					return math.random(1, 100) >= 90
				end
			end
		end,
		Recruit = function(unit, id, MassIncome, DifficultyScenario, DifficultyAI)
			local bp = unit:GetBlueprint()
			local roll = math.ceil((MassIncome/10 + DifficultyScenario + math.random(1, 15)) * DifficultyMod[DifficultyAI] * 0.25)
			unit:ForcePromote(0, 0, 'Bard')
			DM.SetProperty(id, 'BaseClass', 'Rogue')
			DM.SetProperty(id, 'Upgrade_Armor_Light Armor', math.min(roll*5 + 50, 100))
			DM.SetProperty(id, 'Upgrade_Armor_Health Increase', (roll * bp.Defense.MaxHealth * 0.15 + 500000))
			DM.SetProperty(id, 'Upgrade_Armor_Regeneration Increase', 350 + roll)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Damage to All Units', roll*50)
			DM.SetProperty(id, 'Upgrade_Weapon_2_Damage to All Units', roll*50)
			DM.SetProperty(id, 'Upgrade_Weapon_3_Damage to All Units', roll*50)
			DM.SetProperty(id, 'Upgrade_Weapon_4_Damage to All Units', roll*50)
			DM.SetProperty(id, 'Upgrade_Weapon_5_Damage to All Units', roll*50)
			DM.SetProperty(id, 'Upgrade_Weapon_6_Damage to All Units', roll*50)
			DM.SetProperty(id, 'Upgrade_Weapon_7_Damage to All Units', roll*50)
			DM.SetProperty(id, 'Upgrade_Weapon_1_Armor Piercing', roll*5)
			DM.SetProperty(id, 'Over Fire_AutoCast', 1)
			DM.SetProperty(id, 'DreadDissonance_AutoCast', 1)
			unit:ExecutePower('LesserShield')
			DM.SetProperty(id, 'Intelligence', 200)
			DM.SetProperty(id, 'StanceState', 'Offensive')
			DM.SetProperty(id, 'AI_Champion', 1)
			unit:SetCustomName('High-Admiral ******* '..roll)
			DM.SetProperty(id, 'Imperial_Rank', roll * 50)
			local chants = {'GentleMelody', 'CalmingMelody', 'BattleSong', 'BalladoftheWind'}
			unit:ExecutePower(chants[math.ceil(math.random(1, 4))])
		end,	
	},
}
