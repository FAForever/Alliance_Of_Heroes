------------------------
-- Alliance of Heroes --
---- Land Tech Tree ----
---- Franck83 2018 -----
------------------------

local ModPath = '/mods/Alliance_Of_Heroes/'
local ModPathIcons = ModPath..'Graphics/Icons/'
local UiH = import(ModPath..'Modules/UiHeroesUtils.lua')
local DM = import(ModPath..'Modules/DataManager.lua')
local UnAvailable = ModPathIcons..'Techtrees/UnAvailable.dds'
local Untrained =  ModPathIcons..'Techtrees/Untrained.dds'
local Trained = ModPathIcons..'Techtrees/trained.dds'
local NonUpgradable =  ModPathIcons..'Techtrees/NonUpgradable.dds'
local Upgradable = ModPathIcons..'Techtrees/Upgradable.dds'
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Color = import(ModPath..'Modules/Colors.lua').Colors

Generic = {
	CreateNode = function(id, UiObject, Level, x, y, NodeName)
		local Bitmp = UiH.CreateButtonBitmap(UiObject, Untrained, Trained, 'AtLeftIn', UiObject, x, 'Below', UiObject, y, NodeName)
		local Tex = UiH.CreateText(UiObject, Level..' / '..Modifiers[NodeName].GetMaxLevel(id), 'AtLeftIn', UiObject, x + 9, 'Below', UiObject, y + 40, 11)
		local UiUp = UiH.CreateButtonBitmap(UiObject, NonUpgradable, Upgradable, 'AtLeftIn', UiObject, x - 20, 'Below', UiObject, y - 20, NodeName)
		UiUp:DisableHitTest(true)
		Tex:DisableHitTest(true)
		return Bitmp, Tex, UiUp
	end,
	UpdateNode = function(id, UiObject, UiText, UiUp, Level, MaxLevel, NodeName)
		if UiObject.Level > 0 then
			UiObject.SetTextureOnMouseExit(Trained)
			UiObject.SetTextureOnMouseEnter(Trained)
		else
			UiObject.SetTextureOnMouseExit(Untrained)
			UiObject.SetTextureOnMouseEnter(Trained)
		end
		if UiObject.Level >= 10 then -- Dealing with over level 10 text formatting
			LayoutHelpers.AtLeftIn(UiText, UiObject, 3)
		else
			if Modifiers[NodeName].GetMaxLevel(id) >= 10 then
				LayoutHelpers.AtLeftIn(UiText, UiObject, 6)
			else
				LayoutHelpers.AtLeftIn(UiText, UiObject, 9)
			end
		end
		UiText:SetText(UiObject.Level..' / '..MaxLevel)
		if UiObject.Upgradable == true then
			UiUp.SetTextureOnMouseExit(Upgradable)
		else
			UiUp.SetTextureOnMouseExit(NonUpgradable)
		end
		return UiObject, UiText, UiUp
	end
}

Modifiers = {
	['Improved Hull'] = {
		Description = function(id, Level)
			local Healthpercent = (Level) * 100
			local Title = 'Improved Hull'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..Healthpercent..'% base health to all tech 1 lands heroes units'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 20, -558, 'Improved Hull')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Hull'].GetMaxLevel(id), 'Improved Hull')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 4
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Improved Hull'].GetMaxLevel(id) > Level and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and Level > 0 and ProjetedNodeLevel['Light Bots Hull'] == 0 and ProjetedNodeLevel['Improved Hull 2'] == 0 and ProjetedNodeLevel['Nano Repair'] == 0  then
				return true
			else 
				return false
			end
		end,
	},
	['Light Bots Hull'] = {
		Description = function(id, Level)
			local Title = 'Light Bots Hull'
			local Body = 'Pre-requisite : Improved Hull Level 4'
			if Level > 0 then
				local HealthIncrease = (Level) * 125
				Body = '+'..HealthIncrease..' health to all tech 1 heroes light bots units'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 100, -558, 'Light Bots Hull')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Light Bots Hull'].GetMaxLevel(id), 'Light Bots Hull')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 3
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['Light Bots Hull'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Improved Hull'] == 4 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel then
				return true
			else return false
			end
		end,
	},
	['Nano Repair'] = {
		Description = function(id, Level)
			local Title = 'Nano Repair'
			local Body = 'Pre-requisite : Improved Hull Level 1'
			if Level > 0 then
				local Regen = (Level) * 1
				Body = '+'..Regen..' regen to all tech 1 heroes units.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 340, -558, 'Nano Repair')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Nano Repair'].GetMaxLevel(id), 'Nano Repair')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 3
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['Nano Repair'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Improved Hull'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel then
				return true
			else return false
			end
		end,
	},
	['Improved Hull 2'] = {
		Description = function(id, Level)
			local Healthpercent = (Level) * 25
			local Title = 'Improved Hull 2'
			local Body ='Pre-requisite : Improved Hull Level 1'
			if Level > 0 then
				Body = '+'..Healthpercent..'% health to all heroes tech 2 lands heroes units'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 420, -558, 'Improved Hull 2')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Hull 2'].GetMaxLevel(id),  'Improved Hull 2')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Improved Hull 2'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Improved Hull'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > 0 and ProjetedNodeLevel['Nano Repair 2'] == 0 then
				if Level > MinimumLevel then
					return true
				else
					return false
				end
			else return false
			end
		end,
	},
	['Anti-Air Advanced Hull'] = {
		Description = function(id, Level)
			local Healthpercent = (Level) * 40
			local Title = 'Anti-Air Advanced Hull'
			local Body ='Pre-requisite : Improved Hull Level 2'
			if Level > 0 then
				Body = '+'..Healthpercent..'% health to all heroes tech 2 anti-air units'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 500, -558, 'Anti-Air Advanced Hull')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Anti-Air Advanced Hull'].GetMaxLevel(id),  'Anti-Air Advanced Hull')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Anti-Air Advanced Hull'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Improved Hull 2'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > 0 then
				if Level > MinimumLevel then
					return true
				else
					return false
				end
			else return false
			end
		end,
	},
	['Missile Advanced Hull'] = {
		Description = function(id, Level)
			local Healthpercent = (Level) * 40
			local Title = 'Missile Advanced Hull'
			local Body ='Pre-requisite : Improved Hull Level 2'
			if Level > 0 then
				Body = '+'..Healthpercent..'% health to all heroes tech 2 Missile units'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 560, -558, 'Missile Advanced Hull')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Missile Advanced Hull'].GetMaxLevel(id),  'Missile Advanced Hull')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Missile Advanced Hull'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Improved Hull 2'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > 0 then
				if Level > MinimumLevel then
					return true
				else
					return false
				end
			else return false
			end
		end,
	},
	['Combat Advanced Hull'] = {
		Description = function(id, Level)
			local Healthpercent = (Level) * 40
			local Title = 'Combat Advanced Hull'
			local Body ='Pre-requisite : Improved Hull Level 2'
			if Level > 0 then
				Body = '+'..Healthpercent..'% health to all heroes tech 2 tank & bots units'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 620, -558, 'Combat Advanced Hull')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Combat Advanced Hull'].GetMaxLevel(id),  'Combat Advanced Hull')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Combat Advanced Hull'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Improved Hull 2'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > 0 then
				if Level > MinimumLevel then
					return true
				else
					return false
				end
			else return false
			end
		end,
	},
	['Nano Repair 2'] = {
		Description = function(id, Level)
			local Title = 'Nano Repair 2'
			local Body = 'Pre-requisite : Improved Hull 2 Level 1'
			if Level > 0 then
				local Regen = (Level) * 2
				Body = '+'..Regen..' regen to all heroes tech 2 units.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 740, -558, 'Nano Repair 2')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Nano Repair 2'].GetMaxLevel(id), 'Nano Repair 2')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 3
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['Nano Repair 2'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Improved Hull 2'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel then
				return true
			else return false
			end
		end,
	},
	['Obsidian Tank Shield'] = {
		Description = function(id, Level)
			local Title = 'Obsidian Tank Shield'
			local Body = 'Click to Upgrade. Only on Aeon Obsidian Tank.'
			if Level > 0 then
				local Shield = (Level) * 20
				Body = '+'..Shield..' % to heroes Obsidian Tank shield power. You will need to recast your obsidian hero shield.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 420, -478, 'Obsidian Tank Shield')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Obsidian Tank Shield'].GetMaxLevel(id), 'Obsidian Tank Shield')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['Obsidian Tank Shield'].GetMaxLevel(id) > Level and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel then
				return true
			else return false
			end
		end,
	},
	['Mobile Tech 2 Shield'] = {
		Description = function(id, Level)
			local Title = 'Mobile Tech 2 Shield'
			local Body = 'Click to Upgrade.'
			if Level > 0 then
				local Shield = (Level) * 80
				Body = '+'..Shield..' % to Mobile heroes Tech 2 shield power.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 740, -478, 'Mobile Tech 2 Shield')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Mobile Tech 2 Shield'].GetMaxLevel(id), 'Mobile Tech 2 Shield')
		end,
		IsAvailable = function(id)
			return false
		end,
		GetMaxLevel = function(id)
			return 12
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['Mobile Tech 2 Shield'].GetMaxLevel(id) > Level and TechPointsAvailable > SpentPoints then
				return false
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel then
				return true
			else return false
			end
		end,
	},
	['Mobile Tech 3 Shield'] = {
		Description = function(id, Level)
			local Title = 'Mobile Tech 3 Shield'
			local Body = 'Click to Upgrade.'
			if Level > 0 then
				local Shield = (Level) * 80
				Body = '+'..Shield..' % to Mobile heroes Tech 3 shield power.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 1140, -478, 'Mobile Tech 3 Shield')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Mobile Tech 3 Shield'].GetMaxLevel(id), 'Mobile Tech 3 Shield')
		end,
		IsAvailable = function(id)
			return false
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['Mobile Tech 3 Shield'].GetMaxLevel(id) > Level and TechPointsAvailable > SpentPoints then
				return false
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel then
				return true
			else return false
			end
		end,
	},
	['Harbinger Shield'] = {
		Description = function(id, Level)
			local Title = 'Harbinger Mark IV Shield'
			local Body = 'Pre-requisite : Obsidian Tank Shield Level 1.'
			if Level > 0 then
				local Shield = (Level) * 20
				Body = '+'..Shield..' % to heroes Harbinger shield power. You will need to recast your shield power to activated the upgrade.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 820, -478, 'Harbinger Shield')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Harbinger Shield'].GetMaxLevel(id), 'Harbinger Shield')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 16
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['Harbinger Shield'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Obsidian Tank Shield'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel then
				return true
			else return false
			end
		end,
	},	
	['Improved Hull 3'] = {
		Description = function(id, Level)
			local Healthpercent = (Level) * 20
			local Title = 'Improved Hull 3'
			local Body ='Pre-requisite : Improved Hull 2 Level 1'
			if Level > 0 then
				Body = '+'..Healthpercent..'% health to all heroes tech 3 lands units'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 820, -558, 'Improved Hull 3')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level,  Modifiers['Improved Hull 3'].GetMaxLevel(id), 'Improved Hull 3')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 12
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Improved Hull 3'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Improved Hull 2'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > 0 and ProjetedNodeLevel['Nano Repair 3'] == 0 then
				if Level > MinimumLevel then
					return true
				else
					return false
				end
			else return false
			end
		end,
	},
	['Anti-Air Advanced Hull 2'] = {
		Description = function(id, Level)
			local Healthpercent = (Level) * 40
			local Title = 'Anti-Air Advanced Hull 2'
			local Body ='Pre-requisite : Improved Hull Level 3'
			if Level > 0 then
				Body = '+'..Healthpercent..'% health to all heroes tech 3 anti-air units'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 900, -558, 'Anti-Air Advanced Hull 2')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Anti-Air Advanced Hull 2'].GetMaxLevel(id),  'Anti-Air Advanced Hull 2')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Anti-Air Advanced Hull 2'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Improved Hull 3'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > 0 then
				if Level > MinimumLevel then
					return true
				else
					return false
				end
			else return false
			end
		end,
	},
	['Artillery Advanced Hull'] = {
		Description = function(id, Level)
			local Healthpercent = (Level) * 25
			local Title = 'Artillery Advanced Hull'
			local Body ='Pre-requisite : Improved Hull Level 3'
			if Level > 0 then
				Body = '+'..Healthpercent..'% health to all heroes tech 3 Artillery units'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 960, -558, 'Artillery Advanced Hull')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Artillery Advanced Hull'].GetMaxLevel(id),  'Artillery Advanced Hull')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Artillery Advanced Hull'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Improved Hull 3'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > 0 then
				if Level > MinimumLevel then
					return true
				else
					return false
				end
			else return false
			end
		end,
	},
	['Combat Advanced Hull 2'] = {
		Description = function(id, Level)
			local Healthpercent = (Level) * 40
			local Title = 'Combat Advanced Hull 2'
			local Body ='Pre-requisite : Improved Hull Level 3'
			if Level > 0 then
				Body = '+'..Healthpercent..'% health to all heroes tech 3 tank & bots units'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 1020, -558, 'Combat Advanced Hull 2')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Combat Advanced Hull 2'].GetMaxLevel(id),  'Combat Advanced Hull 2')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Combat Advanced Hull 2'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Improved Hull 3'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > 0 then
				if Level > MinimumLevel then
					return true
				else
					return false
				end
			else return false
			end
		end,
	},
	['Nano Repair 3'] = {
		Description = function(id, Level)
			local Title = 'Nano Repair 3'
			local Body = 'Pre-requisite : Improved Hull 3 Level 1'
			if Level > 0 then
				local Regen = (Level) * 3
				Body = '+'..Regen..' regen to all heroes tech 3 units.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 1140, -558, 'Nano Repair 3')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Nano Repair 3'].GetMaxLevel(id), 'Nano Repair 3')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 3
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['Nano Repair 3'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Improved Hull 3'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel then
				return true
			else return false
			end
		end,
	},
	['Armors'] = {
		Description = function(id, Level)
			local Title = 'Armors'
			local Body = 'Click to upgrade'
			if Level > 0 then
				local Armor = (Level) * 5
				Body = '+'..Armor..' % armor efficiency to all heroes tech 1 units.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 20, -698, 'Armors')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Armors'].GetMaxLevel(id), 'Armors')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 16
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['Armors'].GetMaxLevel(id) > Level and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and ProjetedNodeLevel['Armors 2'] == 0 then
				return true
			else return false
			end
		end,
	},
	['Armor Layers'] = {
		Description = function(id, Level)
			local Title = 'Armor Layers'
			local Body = 'Pre-requisite : Armors Level 4'
			if Level > 0 then
				local layers = (Level) * 1
				Body = '-'..layers..' damage taken by all heroes land units.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 340, -638, 'Armor Layers')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Armor Layers'].GetMaxLevel(id), 'Armor Layers')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 4
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['Armor Layers'].GetMaxLevel(id) > Level and  ProjetedNodeLevel['Armors'] >= 4  and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and ProjetedNodeLevel['Health Drain'] == 0 and ProjetedNodeLevel['Defense'] == 0 then
				return true
			else return false
			end
		end,
	},
	['Defense'] = {
		Description = function(id, Level)
			local Title = 'Defense'
			local Body = 'Pre-requisite : Armors Layers 4'
			if Level > 0 then
				local Defense = (Level) * 5
				Body = '+'..Defense..' defense rating on all heroes land units. This gives better chance to dodge and negate damages.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 420, -638, 'Defense')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Defense'].GetMaxLevel(id), 'Defense')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 24
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['Defense'].GetMaxLevel(id) > Level and  ProjetedNodeLevel['Armor Layers'] >= 4  and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel then
				return true
			else return false
			end
		end,
	},
	['Health Drain'] = {
		Description = function(id, Level)
			local Title = 'Health Drain'
			local Body = 'Pre-requisite : Armors Layers level 1 & Nano Repair 2 level 4'
			if Level > 0 then
				local Drain = Level
				Body = '+'..Drain..' % health drain from damage done by all heroes land units.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 740, -638, 'Health Drain')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Health Drain'].GetMaxLevel(id), 'Health Drain')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 6
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['Health Drain'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Nano Repair 2'] >= 3  and ProjetedNodeLevel['Armor Layers'] >= 1  and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel then
				return true
			else return false
			end
		end,
	},
	['Armors 2'] = {
		Description = function(id, Level)
			local Title = 'Armors 2'
			local Body = 'Pre-requisite : Armors Level 1'
			if Level > 0 then
				local Armor = Level * 5
				Body = '+'..Armor..' % armor efficiency to all heroes tech 2 units.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 420, -698, 'Armors 2')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Armors 2'].GetMaxLevel(id), 'Armors 2')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 12
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['Armors 2'].GetMaxLevel(id) > Level and TechPointsAvailable > SpentPoints and ProjetedNodeLevel['Armors'] >= 1 then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and ProjetedNodeLevel['Armors 3'] == 0 and ProjetedNodeLevel['Armor Anti-Artillery Reinforcement'] == 0 and ProjetedNodeLevel['Armor Anti-Bomb Reinforcement'] == 0 and ProjetedNodeLevel['Armor Anti-Direct Fire Naval Reinforcement'] and  ProjetedNodeLevel['Armor Anti-Missile Reinforcement'] == 0 then
				return true
			else return false
			end
		end,
	},
	['Armor Anti-Artillery Reinforcement'] = {
		Description = function(id, Level)
			local Title = 'Armor Anti-Artillery Reinforcement'
			local Body = 'Pre-requisite : Armors 2 Level 12'
			if Level > 0 then
				local Armor = Level * 8
				Body = '+'..Armor..' % armor efficiency to all heroes tech 2 land units against artillery damages.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 500, -698, 'Armor Anti-Artillery Reinforcement')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Armor Anti-Artillery Reinforcement'].GetMaxLevel(id), 'Armor Anti-Artillery Reinforcement')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 7
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['Armor Anti-Artillery Reinforcement'].GetMaxLevel(id) > Level and TechPointsAvailable > SpentPoints and ProjetedNodeLevel['Armors 2'] == 12 then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel  then
				return true
			else return false
			end
		end,
	},
	['Armor Anti-Bomb Reinforcement'] = {
		Description = function(id, Level)
			local Title = 'Armor Anti-Bomb Reinforcement'
			local Body = 'Pre-requisite : Armors 2 Level 12'
			if Level > 0 then
				local Armor = Level * 8
				Body = '+'..Armor..' % armor efficiency to all heroes tech 2 land units against Bomb damages.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 560, -698, 'Armor Anti-Bomb Reinforcement')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Armor Anti-Bomb Reinforcement'].GetMaxLevel(id), 'Armor Anti-Bomb Reinforcement')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 7
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['Armor Anti-Bomb Reinforcement'].GetMaxLevel(id) > Level and TechPointsAvailable > SpentPoints and ProjetedNodeLevel['Armors 2'] == 12 then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel  then
				return true
			else return false
			end
		end,
	},
	['Armor Anti-Direct Fire Naval Reinforcement'] = {
		Description = function(id, Level)
			local Title = 'Armor Anti-Direct Fire Naval Reinforcement'
			local Body = 'Pre-requisite : Armors 2 Level 12'
			if Level > 0 then
				local Armor = Level * 8
				Body = '+'..Armor..' % armor efficiency to all tech 2 heroes land units against Direct Fire Naval damages.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 620, -698, 'Armor Anti-Direct Fire Naval Reinforcement')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Armor Anti-Direct Fire Naval Reinforcement'].GetMaxLevel(id), 'Armor Anti-Direct Fire Naval Reinforcement')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 7
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['Armor Anti-Direct Fire Naval Reinforcement'].GetMaxLevel(id) > Level and TechPointsAvailable > SpentPoints and ProjetedNodeLevel['Armors 2'] == 12 then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel  then
				return true
			else return false
			end
		end,
	},
	['Armor Anti-Missile Reinforcement'] = {
		Description = function(id, Level)
			local Title = 'Armor Anti-Missile Reinforcement'
			local Body = 'Pre-requisite : Armors 2 Level 12'
			if Level > 0 then
				local Armor = Level * 8
				Body = '+'..Armor..' % armor efficiency to all heroes tech 2 land units against Missile damages.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 680, -698, 'Armor Anti-Missile Reinforcement')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Armor Anti-Missile Reinforcement'].GetMaxLevel(id), 'Armor Anti-Missile Reinforcement')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 7
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['Armor Anti-Missile Reinforcement'].GetMaxLevel(id) > Level and TechPointsAvailable > SpentPoints and ProjetedNodeLevel['Armors 2'] == 12 then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel  then
				return true
			else return false
			end
		end,
	},
	['Armors 3'] = {
		Description = function(id, Level)
			local Title = 'Armors 3'
			local Body = 'Pre-requisite : Armors 2 Level 1'
			if Level > 0 then
				local Armor = (Level) * 5
				Body = '+'..Armor..' % armor efficiency to all heroes tech 3 units.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 820, -698, 'Armors 3')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Armors 3'].GetMaxLevel(id), 'Armors 3')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 12
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['Armors 3'].GetMaxLevel(id) > Level and TechPointsAvailable > SpentPoints and ProjetedNodeLevel['Armors 2'] >= 1 then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and ProjetedNodeLevel['Armor Anti-Artillery Reinforcement 2'] == 0 and ProjetedNodeLevel['Armor Anti-Bomb Reinforcement 2'] == 0 and ProjetedNodeLevel['Armor Anti-Direct Fire Naval Reinforcement 2'] and  ProjetedNodeLevel['Armor Anti-Missile Reinforcement 2'] == 0 then
				return true
			else return false
			end
		end,
	},
	['Armor Anti-Artillery Reinforcement 2'] = {
		Description = function(id, Level)
			local Title = 'Armor Anti-Artillery Reinforcement 2'
			local Body = 'Pre-requisite : Armors 3 Level 12'
			if Level > 0 then
				local Armor = Level * 8
				Body = '+'..Armor..' % armor efficiency to all tech 3 heroes land units against artillery damages.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 900, -698, 'Armor Anti-Artillery Reinforcement 2')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Armor Anti-Artillery Reinforcement 2'].GetMaxLevel(id), 'Armor Anti-Artillery Reinforcement 2')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 7
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['Armor Anti-Artillery Reinforcement 2'].GetMaxLevel(id) > Level and TechPointsAvailable > SpentPoints and ProjetedNodeLevel['Armors 3'] == 12 then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel  then
				return true
			else return false
			end
		end,
	},
	['Armor Anti-Bomb Reinforcement 2'] = {
		Description = function(id, Level)
			local Title = 'Armor Anti-Bomb Reinforcement 2'
			local Body = 'Pre-requisite : Armors 3 Level 12'
			if Level > 0 then
				local Armor = Level * 8
				Body = '+'..Armor..' % armor efficiency to all heroes tech 3 land units against Bomb damages.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 960, -698, 'Armor Anti-Bomb Reinforcement 2')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Armor Anti-Bomb Reinforcement 2'].GetMaxLevel(id), 'Armor Anti-Bomb Reinforcement 2')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 7
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['Armor Anti-Bomb Reinforcement 2'].GetMaxLevel(id) > Level and TechPointsAvailable > SpentPoints and ProjetedNodeLevel['Armors 3'] == 12 then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel  then
				return true
			else return false
			end
		end,
	},
	['Armor Anti-Direct Fire Naval Reinforcement 2'] = {
		Description = function(id, Level)
			local Title = 'Armor Anti-Direct Fire Naval Reinforcement 2'
			local Body = 'Pre-requisite : Armors 3 Level 12'
			if Level > 0 then
				local Armor = Level * 8
				Body = '+'..Armor..' % armor efficiency to all heroes tech 3 land units against Direct Fire Naval damages.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 1020, -698, 'Armor Anti-Direct Fire Naval Reinforcement 2')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Armor Anti-Direct Fire Naval Reinforcement 2'].GetMaxLevel(id), 'Armor Anti-Direct Fire Naval Reinforcement 2')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 7
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['Armor Anti-Direct Fire Naval Reinforcement 2'].GetMaxLevel(id) > Level and TechPointsAvailable > SpentPoints and ProjetedNodeLevel['Armors 3'] == 12 then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel  then
				return true
			else return false
			end
		end,
	},
	['Armor Anti-Missile Reinforcement 2'] = {
		Description = function(id, Level)
			local Title = 'Armor Anti-Missile Reinforcement 2'
			local Body = 'Pre-requisite : Armors 3 Level 12'
			if Level > 0 then
				local Armor = Level * 8
				Body = '+'..Armor..' % armor efficiency to all tech 3 heroes land units against Missile damages.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 1080, -698, 'Armor Anti-Missile Reinforcement 2')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Armor Anti-Missile Reinforcement 2'].GetMaxLevel(id), 'Armor Anti-Missile Reinforcement 2')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 7
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['Armor Anti-Missile Reinforcement 2'].GetMaxLevel(id) > Level and TechPointsAvailable > SpentPoints and ProjetedNodeLevel['Armors 3'] == 12 then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel  then
				return true
			else return false
			end
		end,
	},
	['Armor Anti-Direct Fire Experimental'] = {
		Description = function(id, Level)
			local Title = 'Armor Anti-Direct Fire Experimental'
			local Body = 'Pre-requisite : Armors 3 Level 12'
			if Level > 0 then
				local Armor = Level * 8
				Body = '+'..Armor..' % armor efficiency against Direct Fire Experimental damages for all heroes land units.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 1080, -638, 'Armor Anti-Direct Fire Experimental')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Armor Anti-Direct Fire Experimental'].GetMaxLevel(id), 'Armor Anti-Direct Fire Experimental')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 7
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['Armor Anti-Direct Fire Experimental'].GetMaxLevel(id) > Level and TechPointsAvailable > SpentPoints and ProjetedNodeLevel['Armors 3'] == 12 then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel  then
				return true
			else return false
			end
		end,
	},
	['High Damage Reducer'] = {
		Description = function(id, Level)
			local Title = 'High Damage Reducer'
			local Body = 'Pre-requisite : Armors 3 level 12 & Armor Layers level 4'
			if Level > 0 then
				local Reduction = Level * 5 + 10
				Body = '-'..Reduction..' % damage reduction taken by all heroes land units. Applied when the damage taken is over 20% of the unit max health.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 820, -638, 'High Damage Reducer')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['High Damage Reducer'].GetMaxLevel(id), 'High Damage Reducer')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			-- LOG('--'..Level..' '..ProjetedNodeLevel['Improved Hull'])
			if Modifiers['High Damage Reducer'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Armors 3'] == 12  and ProjetedNodeLevel['Armor Layers'] == 4  and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel then
				return true
			else return false
			end
		end,
	},
	['Ammunitions'] = {
		Description = function(id, Level)
			local Damagepercent = (Level) * 5
			local Title = 'Ammunitions'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..Damagepercent..'% damage done by all heroes tech 1 lands units'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 20, -398, 'Ammunitions')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Ammunitions'].GetMaxLevel(id), 'Ammunitions')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Ammunitions'].GetMaxLevel(id) > Level and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and Level > 0 and ProjetedNodeLevel['Ammunitions 2'] == 0  then
				return true
			else 
				return false
			end
		end,
	},
	['Ammunitions High Velocity'] = {
		Description = function(id, Level)
			local Damage = (Level) * 1
			local Title = 'Ammunitions High Velocity'
			local Body = 'Pre-requisite : Ammunitions Level 4'
			if Level > 0 then
				Body = '+'..Damage..' damage done by all heroes tech 1 lands units'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 340, -338, 'Ammunitions High Velocity')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Ammunitions High Velocity'].GetMaxLevel(id), 'Ammunitions High Velocity')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 4
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Ammunitions High Velocity'].GetMaxLevel(id) > Level and TechPointsAvailable > SpentPoints and ProjetedNodeLevel['Ammunitions'] >= 4 then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and Level > 0 then
				return true
			else 
				return false
			end
		end,
	},
	['Improved Aiming Cumputer'] = {
		Description = function(id, Level)
			local AttackRating = (Level) * 5
			local Title = 'Improved Aiming Cumputer'
			local Body = 'Pre-requisite : Ammunitions High Velocity Level 1'
			if Level > 0 then
				Body = '+'..AttackRating..' attack rating for all heroes lands units. This gives a better chance to hit targets.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 420, -338, 'Improved Aiming Cumputer')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Aiming Cumputer'].GetMaxLevel(id), 'Improved Aiming Cumputer')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 24
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Improved Aiming Cumputer'].GetMaxLevel(id) > Level and TechPointsAvailable > SpentPoints and ProjetedNodeLevel['Ammunitions High Velocity'] >= 1 then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and Level > 0 then
				return true
			else 
				return false
			end
		end,
	},
	['AP Ammunitions'] = {
		Description = function(id, Level)
			local AP = (Level) * 4
			local Title = 'AP Ammunitions'
			local Body = 'Pre-requisite : Ammunitions High Velocity Level 1'
			if Level > 0 then
				Body = '+'..AP..' Armor Piercing Ammunitions for all heroes lands units'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 500, -338, 'AP Ammunitions')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['AP Ammunitions'].GetMaxLevel(id), 'AP Ammunitions')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 50
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['AP Ammunitions'].GetMaxLevel(id) > Level and TechPointsAvailable > SpentPoints and ProjetedNodeLevel['Ammunitions High Velocity'] >= 1 then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and Level > 0 then
				return true
			else 
				return false
			end
		end,
	},
	['Improved Weapon Barrel Cooling'] = {
		Description = function(id, Level)
			local Rof = (Level) * 3
			local Title = 'Improved Weapon Barrel Cooling'
			local Body = 'Pre-requisite : Ammunitions High Velocity Level 1 & Ammunitions 3 Level 1'
			if Level > 0 then
				Body = '+'..Rof..' % Rate of Fire for all heroes lands units'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 820, -338, 'Improved Weapon Barrel Cooling')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Weapon Barrel Cooling'].GetMaxLevel(id), 'Improved Weapon Barrel Cooling')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 20
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Improved Weapon Barrel Cooling'].GetMaxLevel(id) > Level and TechPointsAvailable > SpentPoints and ProjetedNodeLevel['Ammunitions High Velocity'] >= 1 and ProjetedNodeLevel['Ammunitions 3'] >= 1 then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and Level > 0 then
				return true
			else 
				return false
			end
		end,
	},
	['Long Weapon Barrel'] = {
		Description = function(id, Level)
			local range = (Level) * 1
			local Title = 'Long Weapon Barrel'
			local Body = 'Pre-requisite : Improved Weapon Barrel Cooling Level 1'
			if Level > 0 then
				Body = '+'..range..' weapon range for all heroes lands units'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 900, -338, 'Long Weapon Barrel')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Long Weapon Barrel'].GetMaxLevel(id), 'Long Weapon Barrel')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 10
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Long Weapon Barrel'].GetMaxLevel(id) > Level and TechPointsAvailable > SpentPoints and ProjetedNodeLevel['Improved Weapon Barrel Cooling'] >= 1 then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and Level > 0 then
				return true
			else 
				return false
			end
		end,
	},
	['Ammunitions 2'] = {
		Description = function(id, Level)
			local Damagepercent = (Level) * 5
			local Title = 'Ammunitions 2'
			local Body = 'Pre-requisite : Ammunitions Level 1'
			if Level > 0 then
				Body = '+'..Damagepercent..'% damage done by all heroes tech 2 lands units'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 420, -398, 'Ammunitions 2')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Ammunitions 2'].GetMaxLevel(id), 'Ammunitions 2')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Ammunitions 2'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Ammunitions'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and Level > 0 and ProjetedNodeLevel['Ammunitions 3'] == 0  then
				return true
			else 
				return false
			end
		end,
	},
	['Ammunitions Anti-Bot'] = {
		Description = function(id, Level)
			local Damagepercent = (Level) * 12
			local Title = 'Ammunitions Anti-Bot'
			local Body = 'Pre-requisite : Ammunitions 2 Level 1'
			if Level > 0 then
				Body = '+'..Damagepercent..'% damage done by all tech 2 heroes land units vs Bots'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 500, -398, 'Ammunitions Anti-Bot')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Ammunitions Anti-Bot'].GetMaxLevel(id), 'Ammunitions Anti-Bot')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Ammunitions 2'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Ammunitions 2'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and Level > 0 then
				return true
			else 
				return false
			end
		end,
	},
	['Ammunitions Anti-Tank'] = {
		Description = function(id, Level)
			local Damagepercent = (Level) * 12
			local Title = 'Ammunitions Anti-Tank'
			local Body = 'Pre-requisite : Ammunitions 2 Level 1'
			if Level > 0 then
				Body = '+'..Damagepercent..'% damage done by all tech 2 heroes land units vs Tanks'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 560, -398, 'Ammunitions Anti-Tank')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Ammunitions Anti-Tank'].GetMaxLevel(id), 'Ammunitions Anti-Tank')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Ammunitions 2'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Ammunitions 2'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and Level > 0 then
				return true
			else 
				return false
			end
		end,
	},
	['Ammunitions Anti-Naval'] = {
		Description = function(id, Level)
			local Damagepercent = (Level) * 12
			local Title = 'Ammunitions Anti-Naval'
			local Body = 'Pre-requisite : Ammunitions 2 Level 1'
			if Level > 0 then
				Body = '+'..Damagepercent..'% damage done by all tech 2 heroes land units vs Naval'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 620, -398, 'Ammunitions Anti-Naval')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Ammunitions Anti-Naval'].GetMaxLevel(id), 'Ammunitions Anti-Naval')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 12
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Ammunitions 2'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Ammunitions 2'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and Level > 0 then
				return true
			else 
				return false
			end
		end,
	},
	['Ammunitions Anti-SubCommander'] = {
		Description = function(id, Level)
			local Damagepercent = (Level) * 12
			local Title = 'Ammunitions Anti-SubCommander'
			local Body = 'Pre-requisite : Ammunitions 2 Level 1'
			if Level > 0 then
				Body = '+'..Damagepercent..'% damage done by all tech 2 heroes land units vs SubCommander'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 680, -398, 'Ammunitions Anti-SubCommander')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Ammunitions Anti-SubCommander'].GetMaxLevel(id), 'Ammunitions Anti-SubCommander')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Ammunitions 2'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Ammunitions 2'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and Level > 0 then
				return true
			else 
				return false
			end
		end,
	},
	['Ammunitions Anti-Structure'] = {
		Description = function(id, Level)
			local Damagepercent = (Level) * 12
			local Title = 'Ammunitions Anti-Structure'
			local Body = 'Pre-requisite : Ammunitions 2 Level 1'
			if Level > 0 then
				Body = '+'..Damagepercent..'% damage done by all tech 2 heroes land units vs Structure'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 740, -398, 'Ammunitions Anti-Structure')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Ammunitions Anti-Structure'].GetMaxLevel(id), 'Ammunitions Anti-Structure')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Ammunitions 2'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Ammunitions 2'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and Level > 0 then
				return true
			else 
				return false
			end
		end,
	},
	['Ammunitions 3'] = {
		Description = function(id, Level)
			local Damagepercent = (Level) * 5
			local Title = 'Ammunitions 3'
			local Body = 'Pre-requisite : Ammunitions Level 2'
			if Level > 0 then
				Body = '+'..Damagepercent..'% damage done by all tech 3 heroes lands units'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 820, -398, 'Ammunitions 3')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Ammunitions 3'].GetMaxLevel(id), 'Ammunitions 3')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Ammunitions 3'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Ammunitions 2'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and Level > 0 then
				return true
			else 
				return false
			end
		end,
	},
	['Ammunitions 2 Anti-Bot'] = {
		Description = function(id, Level)
			local Damagepercent = (Level) * 12
			local Title = 'Ammunitions 2 Anti-Bot'
			local Body = 'Pre-requisite : Ammunitions 3 Level 1'
			if Level > 0 then
				Body = '+'..Damagepercent..'% damage done by all tech 3 heroes land units vs Bots'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 900, -398, 'Ammunitions 2 Anti-Bot')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Ammunitions 2 Anti-Bot'].GetMaxLevel(id), 'Ammunitions 2 Anti-Bot')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Ammunitions 3'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Ammunitions 3'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and Level > 0 then
				return true
			else 
				return false
			end
		end,
	},
	['Ammunitions 2 Anti-Tank'] = {
		Description = function(id, Level)
			local Damagepercent = (Level) * 12
			local Title = 'Ammunitions 2 Anti-Tank'
			local Body = 'Pre-requisite : Ammunitions 3 Level 1'
			if Level > 0 then
				Body = '+'..Damagepercent..'% damage done by all tech 3 heroes land units vs Tanks'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 960, -398, 'Ammunitions 2 Anti-Tank')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Ammunitions 2 Anti-Tank'].GetMaxLevel(id), 'Ammunitions 2 Anti-Tank')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Ammunitions 3'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Ammunitions 3'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and Level > 0 then
				return true
			else 
				return false
			end
		end,
	},
	['Ammunitions 2 Anti-Naval'] = {
		Description = function(id, Level)
			local Damagepercent = (Level) * 12
			local Title = 'Ammunitions 2 Anti-Naval'
			local Body = 'Pre-requisite : Ammunitions 3 Level 1'
			if Level > 0 then
				Body = '+'..Damagepercent..'% damage done by all tech 3 heroes land units vs Naval'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 1020, -398, 'Ammunitions 2 Anti-Naval')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Ammunitions 2 Anti-Naval'].GetMaxLevel(id), 'Ammunitions 2 Anti-Naval')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 12
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Ammunitions 2 Anti-Naval'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Ammunitions 3'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and Level > 0 then
				return true
			else 
				return false
			end
		end,
	},
	['Ammunitions 2 Anti-SubCommander'] = {
		Description = function(id, Level)
			local Damagepercent = (Level) * 12
			local Title = 'Ammunitions 2 Anti-SubCommander'
			local Body = 'Pre-requisite : Ammunitions 3 Level 1'
			if Level > 0 then
				Body = '+'..Damagepercent..'% damage done by all tech 3 heroes land units vs SubCommander'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 1080, -398, 'Ammunitions 2 Anti-SubCommander')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Ammunitions 2 Anti-SubCommander'].GetMaxLevel(id), 'Ammunitions 2 Anti-SubCommander')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Ammunitions 3'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Ammunitions 3'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and Level > 0 then
				return true
			else 
				return false
			end
		end,
	},
	['Ammunitions 2 Anti-Structure'] = {
		Description = function(id, Level)
			local Damagepercent = (Level) * 12
			local Title = 'Ammunitions 2 Anti-Structure'
			local Body = 'Pre-requisite : Ammunitions 3 Level 1'
			if Level > 0 then
				Body = '+'..Damagepercent..'% damage done by all tech 3 heroes land units vs Structure'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 1080, -338, 'Ammunitions 2 Anti-Structure')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Ammunitions 2 Anti-Structure'].GetMaxLevel(id), 'Ammunitions 2 Anti-Structure')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Ammunitions 3'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Ammunitions 3'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and Level > 0 then
				return true
			else 
				return false
			end
		end,
	},
	['Ammunitions Anti-Experimental'] = {
		Description = function(id, Level)
			local Damagepercent = (Level) * 12
			local Title = 'Ammunitions Anti-Experimental'
			local Body = 'Pre-requisite : Ammunitions 3 Level 1'
			if Level > 0 then
				Body = '+'..Damagepercent..'% damage done by all tech 3 heroes land units vs Experimentals'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 1140, -338, 'Ammunitions Anti-Experimental')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Ammunitions Anti-Experimental'].GetMaxLevel(id), 'Ammunitions Anti-Experimental')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Ammunitions 3'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Ammunitions 3'] >= 1 and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and Level > 0 then
				return true
			else 
				return false
			end
		end,
	},
	
	['Engineering Suite'] = {
		Description = function(id, Level)
			local BuildRate = (Level) * 1
			local Title = 'Engineering Suite'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..BuildRate..' build rate to all tech 1 engineers'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 20, -258, 'Engineering Suite')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Engineering Suite'].GetMaxLevel(id), 'Engineering Suite')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Engineering Suite'].GetMaxLevel(id) > Level and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and Level > 0 and ProjetedNodeLevel['Engineering Suite 2'] == 0  then
				return true
			else 
				return false
			end
		end,
	},
	['Engineering Suite 2'] = {
		Description = function(id, Level)
			local BuildRate = (Level) * 3
			local Title = 'Engineering Suite 2'
			local Body = 'Pre-requisite : Engineering Suite Level 1'
			if Level > 0 then
				Body = '+'..BuildRate..' build rate to all tech 2 engineers'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 420, -258, 'Engineering Suite 2')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Engineering Suite 2'].GetMaxLevel(id), 'Engineering Suite 2')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Engineering Suite 2'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Engineering Suite'] >= 1  and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and Level > 0 and ProjetedNodeLevel['Engineering Suite 3'] == 0  then
				return true
			else 
				return false
			end
		end,
	},
	['Engineering Suite 3'] = {
		Description = function(id, Level)
			local BuildRate = (Level) * 5
			local Title = 'Engineering Suite 3'
			local Body = 'Pre-requisite : Engineering Suite 2 Level 1'
			if Level > 0 then
				Body = '+'..BuildRate..' build rate to all tech 3 heroes engineers'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 820, -258, 'Engineering Suite 3')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Engineering Suite 3'].GetMaxLevel(id), 'Engineering Suite 3')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			if Modifiers['Engineering Suite 3'].GetMaxLevel(id) > Level and ProjetedNodeLevel['Engineering Suite 2'] >= 1  and TechPointsAvailable > SpentPoints then
				return true
			else return false
			end
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			if Level > MinimumLevel and Level > 0  then
				return true
			else 
				return false
			end
		end,
	},
}
	


