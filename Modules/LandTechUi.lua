------------------------
-- Alliance of Heroes --
---- Land Tech Tree ----
---- Franck83 2018 -----
------------------------

local ModPath = '/mods/Alliance_Of_Heroes/'
local ModPathIcons = ModPath..'Graphics/Icons/'
local UiH = import(ModPath..'Modules/UiHeroesUtils.lua')
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
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
		local Tex = UiH.CreateText(UiObject, Level..' / '..Modifiers[NodeName].GetMaxLevel(id), 'AtLeftIn', UiObject, x-10, 'Below', UiObject, y + 30, 10)
		local UiUp = UiH.CreateButtonBitmap(UiObject, NonUpgradable, Upgradable, 'AtLeftIn', UiObject, x - 15, 'Below', UiObject, y - 15, NodeName)
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
			LayoutHelpers.AtLeftIn(UiText, UiObject, -2)
		else
			if Modifiers[NodeName].GetMaxLevel(id) >= 10 then
				LayoutHelpers.AtLeftIn(UiText, UiObject, 1)
			else
				LayoutHelpers.AtLeftIn(UiText, UiObject, 4)
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
	['Improved Hull Building'] = {
		Description = function(id, Level)
			local Healthpercent = (Level) * 25
			local Title = 'Improve all buildings maximum health'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..Healthpercent..'% base max health to all buildings.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 390, -314, 'Improved Hull Building')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Hull Building'].GetMaxLevel(id), 'Improved Hull Building')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 400 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Hull Building'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Hull Aircraft'] = {
		Description = function(id, Level)
			local Healthpercent = (Level) * 10
			local Title = 'Improve all aircrafts (up to tech 3) maximum health'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..Healthpercent..'% base max health to all aircrafts up to tech 3.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 330, -314, 'Improved Hull Aircraft')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Hull Aircraft'].GetMaxLevel(id), 'Improved Hull Aircraft')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 400 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Hull Aircraft'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Hull Land units'] = {
		Description = function(id, Level)
			local Healthpercent = (Level) * 15
			local Title = 'Improve land units (up to tech 3) maximum health'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..Healthpercent..'% base max health to land units up to tech 3.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 330, -374, 'Improved Hull Land units')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Hull Land units'].GetMaxLevel(id), 'Improved Hull Land units')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 400 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Hull Land units'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Hull Light Bots'] = {
		Description = function(id, Level)
			local Health = (Level) * 25
			local Title = 'Improve light bots maximum health'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..Health..' base max health to lights bots.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 330, -434, 'Improved Hull Light Bots')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Hull Light Bots'].GetMaxLevel(id), 'Improved Hull Light Bots')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 4
		end,
		GetMassCost = function(id, Level)
			return math.ceil(100 * (1 + Level / 2))
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Hull Light Bots'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Hull Naval units'] = {
		Description = function(id, Level)
			local Healthpercent = (Level) * 10
			local Title = 'Improve all Naval units (up to tech 3) maximum health'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..Healthpercent..'% base max health to all naval units up to tech 3.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 390, -374, 'Improved Hull Naval units')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Hull Naval units'].GetMaxLevel(id), 'Improved Hull Naval units')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 800 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Hull Naval units'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Hull Experimental units'] = {
		Description = function(id, Level)
			local Healthpercent = (Level) * 10
			local Title = 'Improve all Experimentals maximum health'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..Healthpercent..'% base max health to all Experimentals.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 270, -314, 'Improved Hull Experimental units')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Hull Experimental units'].GetMaxLevel(id), 'Improved Hull Experimental units')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 1600 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Hull Experimental units'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Regen'] = {
		Description = function(id, Level)
			local Regen = (Level) * 2
			local Title = 'Improved health regen'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..Regen..' health regen to all units.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 270, -374, 'Improved Regen')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Regen'].GetMaxLevel(id), 'Improved Regen')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 400 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Regen'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Shield Power'] = {
		Description = function(id, Level)
			local ShieldPower = (Level) * 15
			local Title = 'Improved Shield Power'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..ShieldPower..' % to all shields power.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 210, -374, 'Improved Shield Power')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Shield Power'].GetMaxLevel(id), 'Improved Shield Power')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 400 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Shield Power'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Shield Regen'] = {
		Description = function(id, Level)
			local ShieldRegen = (Level) * 12
			local Title = 'Improved Shield Regen'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..ShieldRegen..' to all shields regen.'
				-- Body = 'Currently inactivated for bug fixing'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 210, -434, 'Improved Shield Regen')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Shield Regen'].GetMaxLevel(id), 'Improved Shield Regen')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 400 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Shield Regen'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Energy Drain'] = {
		Description = function(id, Level)
			local EnergyDrain = (Level) * 8
			local Title = 'Energy drain'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = EnergyDrain..'% energy drained from damages to shields.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 150, -434, 'Energy Drain')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Energy Drain'].GetMaxLevel(id), 'Energy Drain')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 100 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Energy Drain'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Engineers Buildate'] = {
		Description = function(id, Level)
			local unit = GetUnitById(id)
			local UnitTech = CF.GetUnitTech(unit)
			local BuildRate = (Level) * UnitTech
			local Title = 'Improved Engineers Buildate'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..BuildRate..' Buildrate per tech level.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 390, -224, 'Improved Engineers Buildate')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Engineers Buildate'].GetMaxLevel(id), 'Improved Engineers Buildate')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 200 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Engineers Buildate'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Factory Buildate'] = {
		Description = function(id, Level)
			local unit = GetUnitById(id)
			local UnitTech = CF.GetUnitTech(unit)
			local BuildRate = Level * UnitTech * 4
			local Title = 'Improved Factory Buildate'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..BuildRate..' Buildrate per tech level.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 390, -164, 'Improved Factory Buildate')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Factory Buildate'].GetMaxLevel(id), 'Improved Factory Buildate')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 200 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Factory Buildate'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Engineer Station Buildate'] = {
		Description = function(id, Level)
			local unit = GetUnitById(id)
			local UnitTech = CF.GetUnitTech(unit)
			local BuildRate = Level * UnitTech * 12
			local Title = 'Improved Engineer Station Buildate'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..BuildRate..' Buildrate.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 330, -224, 'Improved Engineer Station Buildate')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Engineer Station Buildate'].GetMaxLevel(id), 'Improved Engineer Station Buildate')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 400 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Engineer Station Buildate'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Commanders and SubCommanders Buildate'] = {
		Description = function(id, Level)
			local unit = GetUnitById(id)
			local UnitTech = CF.GetUnitTech(unit)
			local BuildRate = Level * 8
			local Title = 'Improved Commanders and SubCommanders Buildate'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..BuildRate..' Buildrate.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 330, -164, 'Improved Commanders and SubCommanders Buildate')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Commanders and SubCommanders Buildate'].GetMaxLevel(id), 'Improved Commanders and SubCommanders Buildate')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 400 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Commanders and SubCommanders Buildate'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved ACU Mass & Energy Production'] = {
		Description = function(id, Level)
			local unit = GetUnitById(id)
			local UnitTech = CF.GetUnitTech(unit)
			local Mass = Level 
			local Energy = Level * 40
			local Title = 'Improved ACU Mass & Energy Production'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..Mass..' Mass  '..'+'..Energy..' Energy Production.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 330, -104, 'Improved ACU Mass & Energy Production')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved ACU Mass & Energy Production'].GetMaxLevel(id), 'Improved ACU Mass & Energy Production')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 200
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved ACU Mass & Energy Production'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Energy Production'] = {
		Description = function(id, Level)
			local unit = GetUnitById(id)
			local UnitTech = CF.GetUnitTech(unit)
			local EnergyP = Level * 5
			local Title = 'Improved Energy Production'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..EnergyP..' % energy production from power generators.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 390, -104, 'Improved Energy Production')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Energy Production'].GetMaxLevel(id), 'Improved Energy Production')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 200 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Energy Production'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Energy Storage'] = {
		Description = function(id, Level)
			local unit = GetUnitById(id)
			local EnergyS =  Level * 4000
			local Title = 'Improved ACU Energy Storage'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..EnergyS.." to ACU's energy storage capacity."
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 270, -164, 'Improved Energy Storage')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Energy Storage'].GetMaxLevel(id), 'Improved Energy Storage')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 400
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Energy Storage'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Structures Armor'] = {
		Description = function(id, Level)
			local unit = GetUnitById(id)
			local UnitTech = CF.GetUnitTech(unit)
			local Armor = (Level) * 5
			local Title = 'Improved Structures Armor'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..Armor..' Armor to all structures.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 480, -224, 'Improved Structures Armor')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Structures Armor'].GetMaxLevel(id), 'Improved Structures Armor')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 200 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Structures Armor'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Naval Armor'] = {
		Description = function(id, Level)
			local unit = GetUnitById(id)
			local UnitTech = CF.GetUnitTech(unit)
			local Armor = (Level) * 5
			local Title = 'Improved Naval Armor'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..Armor..' Armor to all naval units.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 540, -224, 'Improved Naval Armor')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Naval Armor'].GetMaxLevel(id), 'Improved Naval Armor')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 400 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Naval Armor'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Aircraft Armor'] = {
		Description = function(id, Level)
			local unit = GetUnitById(id)
			local UnitTech = CF.GetUnitTech(unit)
			local Armor = (Level) * 5
			local Title = 'Improved Aircraft Armor'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..Armor..' Armor to all aircraft units.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 480, -164, 'Improved Aircraft Armor')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Aircraft Armor'].GetMaxLevel(id), 'Improved Aircraft Armor')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 4
		end,
		GetMassCost = function(id, Level)
			return 400 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Aircraft Armor'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Land Units Armor'] = {
		Description = function(id, Level)
			local unit = GetUnitById(id)
			local UnitTech = CF.GetUnitTech(unit)
			local Armor = (Level) * 5
			local Title = 'Improved Land Units Armor (up to tech 3)'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..Armor..' Armor to all land units.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 540, -164, 'Improved Land Units Armor')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Land Units Armor'].GetMaxLevel(id), 'Improved Land Units Armor')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 400 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Land Units Armor'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Experimental Armor'] = {
		Description = function(id, Level)
			local unit = GetUnitById(id)
			local UnitTech = CF.GetUnitTech(unit)
			local Armor = (Level) * 5
			local Title = 'Improved Experimental Armor'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..Armor..' Armor to all Experimental units.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 480, -104, 'Improved Experimental Armor')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Experimental Armor'].GetMaxLevel(id), 'Improved Experimental Armor')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 1600 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Experimental Armor'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['High Damage Reducer'] = {
		Description = function(id, Level)
			local unit = GetUnitById(id)
			local UnitTech = CF.GetUnitTech(unit)
			local DamageReduction = (Level) * 5
			local Title = 'High Damage Reducer'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = "Reduce high damages taken (> 20 % of a unit's health) by "..DamageReduction.."%."
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 540, -104, 'High Damage Reducer')
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
		GetMassCost = function(id, Level)
			return 400 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['High Damage Reducer'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Defense'] = {
		Description = function(id, Level)
			local unit = GetUnitById(id)
			local UnitTech = CF.GetUnitTech(unit)
			local Defense = (Level) * 15
			local Title = 'Improved Defense'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..Defense..' defense to all units. So it increases dodge chance.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 600, -164, 'Improved Defense')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Defense'].GetMaxLevel(id), 'Improved Defense')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 16
		end,
		GetMassCost = function(id, Level)
			return 200 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Defense'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Turrets Damage'] = {
		Description = function(id, Level)
			local Damagepercent = (Level) * 25
			local Title = 'Improve all turrets damage'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..Damagepercent..'% base damage done by all turrets.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 480, -314, 'Improved Turrets Damage')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Turrets Damage'].GetMaxLevel(id), 'Improved Turrets Damage')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 400 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Turrets Damage'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Aircrafts Damage'] = {
		Description = function(id, Level)
			local Damagepercent = (Level) * 10
			local Title = 'Improve all aircrafts damage'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..Damagepercent..'% base damage done by all aircrafts (up to to tech 3).'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 540, -314, 'Improved Aircrafts Damage')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Aircrafts Damage'].GetMaxLevel(id), 'Improved Aircrafts Damage')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 400 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Aircrafts Damage'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Naval Damage'] = {
		Description = function(id, Level)
			local Damagepercent = (Level) * 10
			local Title = 'Improve all naval ships damage'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..Damagepercent..'% base damage done by all ships (up to to tech 3).'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 480, -374, 'Improved Naval Damage')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Naval Damage'].GetMaxLevel(id), 'Improved Naval Damage')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 800 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Naval Damage'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Land Units Damage'] = {
		Description = function(id, Level)
			local Damagepercent = (Level) * 15
			local Title = 'Improve all land units damage'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..Damagepercent..'% base damage done by all land units (up to to tech 3).'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 540, -374, 'Improved Land Units Damage')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Land Units Damage'].GetMaxLevel(id), 'Improved Land Units Damage')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 400 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Land Units Damage'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Experimentals Damage'] = {
		Description = function(id, Level)
			local Damagepercent = (Level) * 10
			local Title = 'Improve all experimentals damage'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..Damagepercent..'% base damage done by all experimentals units.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 600, -314, 'Improved Experimentals Damage')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Experimentals Damage'].GetMaxLevel(id), 'Improved Experimentals Damage')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 1600 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Experimentals Damage'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Rate of Fire'] = {
		Description = function(id, Level)
			local rof = (Level) * 5
			local Title = 'Improve rate of fire'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..rof..'% rate of fire done by all units (up to to tech 3) and the ACU.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 600, -374, 'Improved Rate of Fire')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Rate of Fire'].GetMaxLevel(id), 'Improved Rate of Fire')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 400 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Rate of Fire'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Armor Piercing'] = {
		Description = function(id, Level)
			local AP = (Level) * 5
			local Title = 'Improve armor piercing'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..AP..' armor piercing to all units.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 660, -374, 'Improved Armor Piercing')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Armor Piercing'].GetMaxLevel(id), 'Improved Armor Piercing')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 400 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Armor Piercing'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Accuracy'] = {
		Description = function(id, Level)
			local AC = (Level) * 15
			local Title = 'Improve accuracy'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..AC..' accuracy to all units.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 540, -434, 'Improved Accuracy')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Accuracy'].GetMaxLevel(id), 'Improved Accuracy')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 16
		end,
		GetMassCost = function(id, Level)
			return 200 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Accuracy'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Improved Range'] = {
		Description = function(id, Level)
			local Range = (Level) * 1
			local Title = 'Improve range'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = '+'..Range..' weapons range for all units.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 540, -494, 'Improved Range')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Improved Range'].GetMaxLevel(id), 'Improved Range')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 400 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Improved Range'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
	['Health Drain'] = {
		Description = function(id, Level)
			local Drain = Level * 2
			local Title = 'Health Drain'
			local Body = 'Click to Upgrade'
			if Level > 0 then
				Body = Drain..' % of the damage done converted in health for all units.'
			end
			return Title, Body
		end,
		CreateNode = function(id, UiObject, Level)
			return Generic.CreateNode(id, UiObject, Level, 480, -494, 'Health Drain')
		end,
		UpdateNode = function(id, UiObject, UiText, UiUp, Level)
			return  Generic.UpdateNode(id, UiObject, UiText, UiUp, Level, Modifiers['Health Drain'].GetMaxLevel(id), 'Health Drain')
		end,
		IsAvailable = function(id)
			return true
		end,
		GetMaxLevel = function(id)
			return 8
		end,
		GetMassCost = function(id, Level)
			return 400 * Level
		end,
		CanTechUp = function(id, Level, ProjetedNodeLevel, SpentPoints, TechPointsAvailable)
			return (Level <  Modifiers['Health Drain'].GetMaxLevel(id))
		end,
		CanTechDown = function(id, Level, ProjetedNodeLevel, MinimumLevel)
			return (Level > MinimumLevel and Level > 0) 
		end,
	},
}
	


