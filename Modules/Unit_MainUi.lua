------------------------------
-- Alliance of Heroes Mod ----
-- Franck83 [2016-2018] -----------
-- Main UI -------------------
------------------------------

-- This Ui architecture contains old and new ui tools. So it needs a complete rework for a well suited code.
-- It needs a lot of time, that why i pushed it for later because it will add not functionality.
-- But, i know that it impacts code visibility...

local GameMain = import('/lua/ui/game/gamemain.lua')
local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Tooltip = import('/lua/ui/game/tooltip.lua')
local parent = import('/lua/ui/game/borders.lua').GetMapGroup()

local Group = import('/lua/maui/group.lua').Group
local Tooltip = import('/lua/ui/game/tooltip.lua')
local StatusBar = import('/lua/maui/statusbar.lua').StatusBar
local Popup = import('/lua/ui/controls/popups/popup.lua').Popup
local TextArea = import('/lua/ui/controls/textarea.lua').TextArea
local RadioButton = import('/lua/ui/controls/RadioButton.lua').RadioButton
local ItemList = import('/lua/maui/itemlist.lua').ItemList
local Slider = import('/lua/maui/slider.lua').Slider

local ModPath = '/mods/Alliance_Of_Heroes/'
local ModPathIcons = ModPath..'Graphics/Icons/'

local UmUi = {} -- list of Ui objects7
local UiH = import(ModPath..'Modules/UiHeroesUtils.lua')
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local PC = import(ModPath..'Modules/ClassDefinitions.lua').PrestigeClass
local Powers = import(ModPath..'Modules/Powers.lua').Powers
local Skills = import(ModPath..'Modules/Skills.lua').Skills
local Color = import(ModPath..'Modules/Colors.lua').Colors
local WeaponModifiers =  import(ModPath..'Modules/WeaponModifiers.lua')
local ArmorModifiers =  import(ModPath..'Modules/ArmorModifiers.lua')
local LandTechTreeModifiers = import(ModPath..'Modules/LandTechUi.lua').Modifiers
local AoHBuff = import(ModPath..'Modules/AoHBuff.lua')
local BCbp = import(ModPath..'Modules/ClassDefinitions.lua').BaseClassBlueprint


-- Templates
local UnitGeneralTemplates = {}
local WeaponTemplates = {}
local WeaponTemplatesLevels = {}
local ArmorTemplates = {}
local ArmorTemplatesLevels = {}
local infoTextb = {}

local DialogScreen = {}
DialogScreen.Show = 0
DialogScreen.Template = ''
local CurrentActiveid = 0
local LastCurrentActiveid = 0
local LastWeaponOnMouseEnter = 0
local TemplateUiTimer = 0
local PromotionUiTimer = 0
local LockTimer = false
local LastTooltipTarget = ''
local EnhTtipTimer = 2
local AIDifficultyChange = 0

function CreatePropertyText(UI, PropertyName, TextIndex, TextPosX, TextPosY, Refresh)
	local StaticText = UIUtil.CreateText(UI, '', 11, UIUtil.bodyFont)
	LayoutHelpers.AtLeftTopIn(StaticText,UI,TextPosX,TextPosY)
	UmUi['Text_'..TextIndex..PropertyName] = StaticText
	UmUi['Text_'..TextIndex..PropertyName]:SetColor('ffffffaa')
	if Refresh then
		StaticText.Refresh = Refresh
		StaticText.RefreshArg = PropertyName
	else
		StaticText:SetText(PropertyName)
	end
end

function CreateIcon(UI, PropertyName, xFromParent, yFromParent, OnClickCallback, Refresh, OnClickCallback2)
	local staticIcon = Bitmap(UI)
	local iconpath = ModPathIcons..PropertyName..'.dds'
	local iconpathMouseEnter = ModPathIcons..PropertyName..'_MouseEnter'..'.dds'
	
	UmUi['Icon_' .. PropertyName] = staticIcon
	if Refresh then
		staticIcon.Refresh = Refresh
		staticIcon.RefreshArg = PropertyName
	else
		staticIcon:Show()
	end
	
	local function UmUiHandleEvent(self, event)
		if self.OnClickCallback and event.Type == 'ButtonPress'  and event.Modifiers.Right then
			local unit = GetSelectedUnits()
			if unit then
				local _id = unit[1]:GetEntityId()
				local _objectname = self.PropertyName
				local _OnClickCallback = self.OnClickCallback
				-- SimCallback	({Func=_OnClickCallback, Args = {id = _id, focus = _objectname}})
				DialogScreen.Show = 1
				DialogScreen.UpgradeType = _objectname
			end
		end	
		if self.OnClickCallback2 and event.Type == 'ButtonPress' and event.Modifiers.Left then
			local unit = GetSelectedUnits()
			if unit then
				local _id = unit[1]:GetEntityId()
				local _objectname = self.PropertyName
				local _OnClickCallback2 = self.OnClickCallback2
				-- SimCallback	({Func=_OnClickCallback2, Args = {id = _id, focus = _objectname}})
				DialogScreen.Show = 1
				DialogScreen.UpgradeType = _objectname
			end
		end	
		if event.Type == 'MouseEnter' then
			self:SetTexture(UIUtil.UIFile(self.iconpathMouseEnter))
			local tooltip = {
				text = PropertyName,
				body = "Click to equip upgrades"
			}
			Tooltip.CreateMouseoverDisplay(self, tooltip, 0, true)
			local sound = Sound({Bank = 'Interface', Cue = 'UI_Economy_Rollover'})
			PlaySound(sound)
			
		end
		if event.Type == 'MouseExit' then
			self:SetTexture(UIUtil.UIFile(self.iconpath))
			Tooltip.DestroyMouseoverDisplay()
		end
	end
	
	staticIcon:SetTexture(UIUtil.UIFile(iconpath))
	LayoutHelpers.AtLeftTopIn(staticIcon, UI, xFromParent,  yFromParent)
	UmUi['Icon_' .. PropertyName] = staticIcon
	UmUi['Icon_' .. PropertyName].PropertyName = PropertyName
	UmUi['Icon_' .. PropertyName].iconpath = iconpath
	if iconpathMouseEnter then
		UmUi['Icon_' .. PropertyName].iconpathMouseEnter = iconpathMouseEnter
	end
	UmUi['Icon_' .. PropertyName].iconpathMouseEnter = iconpathMouseEnter
	if OnClickCallback then
		UmUi['Icon_' .. PropertyName].OnClickCallback = OnClickCallback
	end
	if OnClickCallback2 then
		UmUi['Icon_' .. PropertyName].OnClickCallback2 = OnClickCallback2
	end
	if UmUiHandleEvent then
		UmUi['Icon_' .. PropertyName].HandleEvent = UmUiHandleEvent
	end
end

function CreateClickBox(UI, BoxNumber, BoxPath, BoxPathMouseEnter, xFromParent, yFromParent, OnClickCallback, Refresh, SizeHeight, SizeWidth)
	-- box
	local StaticBox = Bitmap(UI)
	UmUi['Box_' .. BoxNumber] = StaticBox
	UmUi['Box_' .. BoxNumber].Height:Set(SizeHeight or 25)
	UmUi['Box_' .. BoxNumber].Width:Set(SizeWidth or 90)
	UmUi['Box_' .. BoxNumber].OnMouseEnter = false
	-- text
	local StaticText = UIUtil.CreateText(UI, '', 11, UIUtil.bodyFont)
	LayoutHelpers.AtLeftTopIn(StaticText,UI,xFromParent+10,yFromParent+6)
	-- Storing the StaticBox
	UmUi['TextBox_' .. BoxNumber] = StaticText
	UmUi['TextBox_' .. BoxNumber]:SetColor('ffffffaa')
	if Refresh then
		StaticBox.Refresh = Refresh
		StaticBox.RefreshArg = BoxNumber
		StaticText.Refresh = Refresh
		StaticText.RefreshArg = BoxNumber	
	else
		StaticText:SetText(BoxNumber)
		StaticText:Hide()
		StaticBox:Hide()	
	end

	local function UmUiHandleEvent(self, event)
		if self.OnClickCallback and event.Type == 'ButtonPress' and event.Modifiers.Left then
			local unit = GetSelectedUnits()
			local _Allids = {}		
			if unit then
				for _,eachunit in unit do
					table.insert(_Allids, eachunit:GetEntityId())		
				end
				local bp = unit[1]:GetBlueprint()
				local _id = unit[1]:GetEntityId()
				local UnitLevel, UnitLevelP =  CF.GetUnitLevel(unit[1])
				local PromoteList = CF.GetAvailablePromoteList(_id)
				local PromoteClass = PromoteList[BoxNumber]
				local BaseClasses = {'Fighter', 'Rogue', 'Support', 'Ardent'}
				local PrestigeClasses = {'Guardian', 'Dreadnought', 'Ranger', 'Bard', 'Restorer'}
				local BClass = ''
				local PClass = ''
				for _, class in BaseClasses do
					if string.find(PromoteClass, class) then
						BClass = class
					end
				end
				for _, class in PrestigeClasses do
					if string.find(PromoteClass, class) then
						PClass = class
					end
				end
				LOG(BClass..' '..PClass)
				local CostModifier = PC[PromoteClass].PromoteCostModifier(_id)
				
				if table.find(bp.Categories, 'EXPERIMENTAL') then
					CostModifier = CostModifier * 2
				end
				local PromotingCostMalus =  math.max(4 - (GameTime()/100), 1)
				local _objectname = self.BoxNumber
				local _OnClickCallback = self.OnClickCallback	
				local _MassCost = math.ceil((100 + math.pow(bp.Economy.BuildCostMass, 0.7) * 40 * (math.pow(0.90, UnitLevel))) * CostModifier * PromotingCostMalus)
				local _EnergyCost = math.ceil((500 + math.pow(bp.Economy.BuildCostEnergy, 0.7) * 105 * (math.pow(0.90, UnitLevel))) * CostModifier * PromotingCostMalus)
				if table.find(bp.Categories, 'COMMAND') then _EnergyCost = math.ceil(_EnergyCost * 0.02) end	
				SimCallback	({Func=_OnClickCallback, Args = {id = _id, ability = _objectname, Allids = _Allids, Click =  0, MassCost = _MassCost, EnergyCost = _EnergyCost, PrestigeClass = PClass, BaseClass = BClass}})
			end
		end
		if self.OnClickCallback and event.Type == 'ButtonPress' and event.Modifiers.Right then
		end	
		if event.Type == 'MouseEnter' then -- and event.Modifiers.Shift
			self:SetTexture(UIUtil.UIFile(BoxPathMouseEnter))
			if OnClickCallback == 'OnChoosePromotion' then
				local unit = GetSelectedUnits()
				local id = unit[1]:GetEntityId()
				local bp = unit[1]:GetBlueprint()
				local PromoteList = CF.GetAvailablePromoteList(id)
				local PromoteClass = PromoteList[BoxNumber]
				local CostModifier = PC[PromoteClass].PromoteCostModifier(id)
				if table.find(bp.Categories, 'EXPERIMENTAL') then
					CostModifier = CostModifier * 2
				end
				local PromotingCostMalus =  math.max(4 - (GameTime()/100), 1)
				local UnitLevel, UnitLevelP =  CF.GetUnitLevel(unit[1])
				local _MassCost = math.ceil((100 + math.pow(bp.Economy.BuildCostMass, 0.7) * 40 * (math.pow(0.90, UnitLevel))) * CostModifier * PromotingCostMalus)
				local _EnergyCost = math.ceil((500 + math.pow(bp.Economy.BuildCostEnergy, 0.7) * 105 * (math.pow(0.90, UnitLevel))) * CostModifier * PromotingCostMalus)
				if table.find(bp.Categories, 'COMMAND') then _EnergyCost = math.ceil(_EnergyCost * 0.02) end				
				local tooltip = {
									text ='Promote to '..PromoteClass,
									body = PC[PromoteClass].Description(id)..'.........................  Mass cost ( '.._MassCost..' ) ............  Energy cost ( '.._EnergyCost..' )'
								}
				Tooltip.CreateMouseoverDisplay(self, tooltip, 0, true)
			end	
			local sound = Sound({Bank = 'Interface', Cue = 'UI_Economy_Rollover'})
			PlaySound(sound)
			UmUi['Box_' .. BoxNumber].OnMouseEnter = true
		end
		if event.Type == 'MouseExit' then
			self:SetTexture(UIUtil.UIFile(BoxPath))
			Tooltip.DestroyMouseoverDisplay()
			UmUi['Box_' .. BoxNumber].OnMouseEnter = false
		end
	end
	StaticBox:SetTexture(UIUtil.UIFile(BoxPath))
	LayoutHelpers.AtLeftTopIn(StaticBox, UI, xFromParent,  yFromParent)
	UmUi['Box_' .. BoxNumber] = StaticBox
	UmUi['Box_' .. BoxNumber].BoxNumber = BoxNumber
	UmUi['Box_' .. BoxNumber].BoxPath = BoxPath
	if BoxPathMouseEnter then
		UmUi['Box_' .. BoxNumber].iconpathMouseEnter = BoxPathMouseEnter
	end
	UmUi['Box_' .. BoxNumber].iconpathMouseEnter = BoxPathMouseEnter
	if OnClickCallback then
		UmUi['Box_' .. BoxNumber].OnClickCallback = OnClickCallback
	end
	if UmUiHandleEvent then
		UmUi['Box_' .. BoxNumber].HandleEvent = UmUiHandleEvent
	end
end

function TechTree_LandsUnits(id)
	DialogScreen.Show = 0
	local TechUi = {}
	local unit = GetUnitById(id)
	local Army = unit:GetArmy()
	local dialogContent, title, dialog = UiH.InitDialogContent(1200, 780, "Upgrade your land units Heroes")
	local Tree = LandTechTreeModifiers
	local XP = DM.GetProperty('Global'..unit:GetArmy(), 'LandMobileXP', 0)
	local TechPointsAvailable =  math.floor(math.floor(XP/250) - DM.GetProperty('Global'..unit:GetArmy(), 'LandMobileXPSpentPoints', 0))
	local SpentPoints = 0
	local ProjectTrains = {}
	TechUi['LTree'] = UiH.CreateButtonBitmap(dialogContent, ModPathIcons..'Techtrees/Landunits.dds', ModPathIcons..'Techtrees/Landunits.dds', 'AtLeftIn', dialogContent, 0, 'Below', dialogContent, -740)
	TechUi['LTree']:DisableHitTest(true)
	
	infoTextb['TechPoints'] = UiH.CreateTextArea(dialogContent, 900, 45, '', 'AtLeftIn' , dialogContent, 50, 'AtBottomIn', dialogContent, 120, nil, nil, nil)
	infoTextb['TechPoints']:SetText("Research Points (spent / available) : "..SpentPoints.." / "..TechPointsAvailable)
	infoTextb['XP'] = UiH.CreateTextArea(dialogContent, 900, 45, '', 'AtLeftIn' , dialogContent, 50, 'AtBottomIn', dialogContent, 105, nil, nil, Color.PURPLE2)
	infoTextb['XP']:SetText('Total Experience Earned by land units : '..XP)
	
	infoTextb['Help'] = UiH.CreateTextArea(dialogContent, 900, 45, '', 'AtLeftIn' , dialogContent, 50, 'AtBottomIn', dialogContent, 90, nil, nil, Color.GREY_LIGHT)
	infoTextb['Help']:SetText('Earn Research Points in battle involving your mobile lands units. Research upgrades will apply instantly on all your lands units heroes. Tech 3 upgrades will be applied instantly to your hero Armored Command Unit.')
		
	function Refresh(obj, NName)
		RecordTrains()
		for NodeName, NodeFunction in Tree do
			TNode = 'LTree'..NodeName
			if Tree[NodeName].CanTechUp(id, TechUi[TNode].Level, ProjectTrains, SpentPoints, TechPointsAvailable)  == true then
				TechUi[TNode].Upgradable = true
			else
				TechUi[TNode].Upgradable = false
			end
			TechUi[TNode], TechUi[TNode..'Text'], TechUi[TNode..'Up'] = NodeFunction.UpdateNode(id, TechUi[TNode], TechUi[TNode..'Text'], TechUi[TNode..'Up'], obj.Level)
			if NName then 
				text, body = Tree[NName].Description(id, obj.Level)
				TechUi[TNode].RefreshTooltip(text, body, obj)	
			end
		end
		infoTextb['TechPoints']:SetText("Research Points (spent / available) : "..SpentPoints.." / "..TechPointsAvailable)
	end
	
	function RecordTrains()
		ProjectTrains = {}
		for NodeName, NodeFunction in Tree do
			TNode = 'LTree'..NodeName
			ProjectTrains[NodeName] =  TechUi[TNode].Level
		end
	end
	
	for NodeName, NodeFunction in Tree do
		TNode = 'LTree'..NodeName
		local level = 0
		local Army = unit:GetArmy()
		if DM.GetProperty('Global'..Army, 'LandMobileTech'..NodeName) then level =  DM.GetProperty('Global'..Army, 'LandMobileTech'..NodeName) end
		TechUi[TNode], TechUi[TNode..'Text'], TechUi[TNode..'Up'] = NodeFunction.CreateNode(id, TechUi['LTree'], level)
		text, body = NodeFunction.Description(id, level)
		TechUi[TNode].SetTooltip(text, body)
		TechUi[TNode].Level = level
		TechUi[TNode], TechUi[TNode..'Text'] = NodeFunction.UpdateNode(id, TechUi[TNode], TechUi[TNode..'Text'], TechUi[TNode..'Up'], level)
		TechUi['LTree'..NodeName].OnClickLeft = function(NName)
			RecordTrains()
			if Tree[NName].CanTechUp(id, TechUi['LTree'..NName].Level, ProjectTrains, SpentPoints, TechPointsAvailable)  == true then
				TechUi['LTree'..NName].Level = TechUi['LTree'..NName].Level + 1
				SpentPoints = SpentPoints + 1
				Refresh(TechUi['LTree'..NName], NName, ProjectTrains, SpentPoints, TechPointsAvailable)
			end
		end
		TechUi['LTree'..NodeName].OnClickRight = function(NName)
			RecordTrains()
			local MinimumLevel = 0
			local Army = unit:GetArmy()
			if DM.GetProperty('Global'..Army, 'LandMobileTech'..NName) then MinimumLevel =  DM.GetProperty('Global'..Army, 'LandMobileTech'..NName) end
			if Tree[NName].CanTechDown(id, TechUi['LTree'..NName].Level, ProjectTrains, MinimumLevel) == true then
				TechUi['LTree'..NName].Level = TechUi['LTree'..NName].Level - 1
				SpentPoints = SpentPoints - 1
				Refresh(TechUi['LTree'..NName], NName, ProjectTrains, SpentPoints, TechPointsAvailable)
			end
		end
		TechUi['LTree'..NodeName].OnMouse_Enter = function(NName)
			Refresh(TechUi['LTree'..NName], NName)
		end
	end
	Refresh()
	
	local okBtn = UiH.CreateButton(dialogContent,'/BUTTON/large/', 'Confirm changes', 'AtHorizontalCenterIn', dialogContent, nil, 'AtBottomIn', dialogContent, 5)
	okBtn.OnClick = function(self)
		local UpdatedDataTechs = {}
		for NodeName, NodeFunction in Tree do
			TNode = 'LTree'..NodeName
			if TechUi[TNode].Level > 0 then
				UpdatedDataTechs[NodeName] =  TechUi[TNode].Level
			end
		end
		SimCallback	({Func= 'UpdateDataTechs', Args = {Unitid = id, Techs = UpdatedDataTechs, TechPoints = SpentPoints, Player = Army}})
		dialog:Close()
	end
end

function HallOfHeroes_Dialog(id)
	DialogScreen.Show = 0
	local unit = GetUnitById(id)
	local dialogContent, title, dialog = UiH.InitDialogContent(1175, 661, "Hall of Heroes")
	UmUi['HallofFame'] = UiH.CreateButtonBitmap(dialogContent, ModPathIcons..'HallofFame.dds', ModPathIcons..'HallofFame.dds', 'AtLeftIn', dialogContent, 0, 'Below', dialogContent, -661)
	UmUi['HallofFame']:DisableHitTest(true)
	local Stats = {'army',  'Points', 'Description', 'Class&Level', 'MassKilled', 'MassKilledRank', 'HpHealed', 'HpHealedRank'}
	local allArmies = GetArmiesTable().armiesTable
	local PlayersData = {}
	for i = 1, 10 do
		PlayersData[i] = {}
		for _, Type in Stats do
			if DM.GetProperty('Hero_HallofFame', i..Type, nil) then
				-- LOG(DM.GetProperty('Hero_HallofFame', i..Type, ''))
				PlayersData[i][Type] = DM.GetProperty('Hero_HallofFame', i..Type, '')
				if Type == 'army' then 
					for armyID, army in allArmies do 
						if armyID == DM.GetProperty('Hero_HallofFame', i..'army') then
							PlayersData[i].PlayerName = army.nickname
						end
					end
				end
			end
		end
	end
	infoTextb['Description'] = UiH.CreateTextArea(dialogContent, 900, 45, '', 'AtLeftIn' , dialogContent, 200, 'Below', title, 30, nil, nil, nil)
	infoTextb['Description']:SetText("Best heroes give inspiration to all your Army !   Bonuses are depending of unit rank, base classes and type (air, land, naval).")
	
	-- LOG(repr(PlayersData))
	local Stats = {'Global Rank', 'Fame points', 'Player', 'Description', 'Class & Level', 'Mass Killed', 'Mass Killed Rank', 'Hp Healed', 'Hp Healed Rank'}
	infoTextb['Title'..'Global Rank'] = UiH.CreateTextArea(dialogContent, 520, 45, '', 'AtLeftIn' , dialogContent, -55 + 1 * 110, 'Below', title, 80, nil, 'Arial Gras', nil)
	infoTextb['Title'..'Global Rank']:SetText('Global Rank')
	infoTextb['Title'..'Fame points'] = UiH.CreateTextArea(dialogContent, 520, 45, '', 'AtLeftIn' , dialogContent, -55 + 190, 'Below', title, 80, nil, 'Arial Gras', nil)
	infoTextb['Title'..'Fame points']:SetText('Fame points')
	infoTextb['Title'..'Player'] = UiH.CreateTextArea(dialogContent, 520, 45, '', 'AtLeftIn' , dialogContent, -55 + 280, 'Below', title, 80, nil, 'Arial Gras', nil)
	infoTextb['Title'..'Player']:SetText('Player')
	infoTextb['Title'..'Description'] = UiH.CreateTextArea(dialogContent, 520, 45, '', 'AtLeftIn' , dialogContent, -55 + 440, 'Below', title, 80, nil, 'Arial Gras', nil)
	infoTextb['Title'..'Description']:SetText('Description')
	infoTextb['Title'..'Class & Level'] = UiH.CreateTextArea(dialogContent, 520, 45, '', 'AtLeftIn' , dialogContent, -55 + 600, 'Below', title, 80, nil, 'Arial Gras', nil)
	infoTextb['Title'..'Class & Level']:SetText('Class & Level')
	infoTextb['Title'..'Mass Killed'] = UiH.CreateTextArea(dialogContent, 520, 45, '', 'AtLeftIn' , dialogContent, -55 + 760, 'Below', title, 80, nil, 'Arial Gras', nil)
	infoTextb['Title'..'Mass Killed']:SetText('Mass Killed')
	infoTextb['Title'..'Mass Killed Rank'] = UiH.CreateTextArea(dialogContent, 520, 45, '', 'AtLeftIn' , dialogContent, -55 + 850, 'Below', title, 80, nil, 'Arial Gras', nil)
	infoTextb['Title'..'Mass Killed Rank']:SetText('Mass Killed Rank')
	infoTextb['Title'..'Hp Healed'] = UiH.CreateTextArea(dialogContent, 520, 45, '', 'AtLeftIn' , dialogContent, -55 + 960, 'Below', title, 80, nil, 'Arial Gras', nil)
	infoTextb['Title'..'Hp Healed']:SetText('Hp Healed')
	infoTextb['Title'..'Hp Healed Rank'] = UiH.CreateTextArea(dialogContent, 520, 45, '', 'AtLeftIn' , dialogContent, -55 + 1050, 'Below', title, 80, nil, 'Arial Gras', nil)
	infoTextb['Title'..'Hp Healed Rank']:SetText('Hp Healed Rank')
	
	local armies = GetArmiesTable()
	for j, Hero in PlayersData do
		if Hero.PlayerName != nil then
			local colorplayer = Color.GREY_LIGHT
			if armies.focusArmy == Hero.army then 
				colorplayer = Color.AEON
			else
				colorplayer = Color.CYBRAN
			end
			infoTextb['Player'..j..'Global Rank'] = UiH.CreateTextArea(dialogContent, 520, 45 , '-', 'AtLeftIn' , dialogContent, -55 + 1 * 140, 'Below', title, 75 + j*35, nil, nil, colorplayer)
			infoTextb['Player'..j..'Global Rank']:SetText(j)
			infoTextb['Player'..j..'Fame points'] = UiH.CreateTextArea(dialogContent, 520, 45 , '-', 'AtLeftIn' , dialogContent, -55 + 220, 'Below', title, 75 + j*35, nil, nil, colorplayer)
			infoTextb['Player'..j..'Fame points']:SetText(tostring(Hero.Points))
			infoTextb['Player'..j..'Player'] = UiH.CreateTextArea(dialogContent, 150, 30 , '-', 'AtLeftIn' , dialogContent, -55 + 280, 'Below', title, 75 + j*35, nil, nil, colorplayer)
			infoTextb['Player'..j..'Player']:SetText(tostring(Hero.PlayerName))
			infoTextb['Player'..j..'Description'] = UiH.CreateTextArea(dialogContent, 150, 30 , '-', 'AtLeftIn' , dialogContent, -55 + 440, 'Below', title, 75 + j*35, nil, nil, colorplayer)
			infoTextb['Player'..j..'Description']:SetText(tostring(Hero.Description))
			infoTextb['Player'..j..'Class & Level'] = UiH.CreateTextArea(dialogContent, 520, 45 , '-', 'AtLeftIn' , dialogContent, -55 + 600, 'Below', title, 75 + j*35, nil, nil, colorplayer)
			infoTextb['Player'..j..'Class & Level']:SetText(tostring(Hero['Class&Level']))
			infoTextb['Player'..j..'Mass Killed'] = UiH.CreateTextArea(dialogContent, 520, 45 , '-', 'AtLeftIn' , dialogContent, -55 + 760, 'Below', title, 75 + j*35, nil, nil, colorplayer)
			infoTextb['Player'..j..'Mass Killed']:SetText(tostring(Hero['MassKilled']))
			infoTextb['Player'..j..'Mass Killed Rank'] = UiH.CreateTextArea(dialogContent, 520, 45 , '-', 'AtLeftIn' , dialogContent, -55 + 880, 'Below', title, 75 + j*35, nil, nil, colorplayer)
			infoTextb['Player'..j..'Mass Killed Rank']:SetText(tostring(Hero['MassKilledRank']))
			infoTextb['Player'..j..'Hp Healed'] = UiH.CreateTextArea(dialogContent, 520, 45 , '-', 'AtLeftIn' , dialogContent, -55 + 960, 'Below', title, 75 + j*35, nil, nil, colorplayer)
			infoTextb['Player'..j..'Hp Healed']:SetText(tostring(Hero['HpHealed']))
			infoTextb['Player'..j..'Hp Healed Rank'] = UiH.CreateTextArea(dialogContent, 520, 45 , '-', 'AtLeftIn' , dialogContent, - 55 + 1080, 'Below', title, 75 + j*35, nil, nil, colorplayer)
			infoTextb['Player'..j..'Hp Healed Rank']:SetText(tostring(Hero['HpHealedRank']))
			if Hero['MassKilledRank'] == 999 then
				infoTextb['Player'..j..'Mass Killed Rank']:SetText('-')
			end
			if Hero['HpHealedRank'] == 999 then
				infoTextb['Player'..j..'Hp Healed Rank']:SetText('-')
			end
		end
	end
		
	infoTextb['LAND'..'FighterBonus'] = UiH.CreateClickTextWithTooltipBox(dialogContent, '', 'AtLeftIn', dialogContent, 305, 'Below', dialogContent, -123, 11, 'Arial Gras', Color.AEON, 'ff00ff00', ModPath.."Graphics/ProgressBar_Blank.dds", ModPath.."Graphics/ProgressBar_GreenDark.dds", 125, 15, 5, 0)
	infoTextb['LAND'..'RogueBonus'] = UiH.CreateClickTextWithTooltipBox(dialogContent, '', 'AtLeftIn', dialogContent, 305, 'Below', dialogContent, -98, 11, 'Arial Gras', Color.AEON, 'ff00ff00', ModPath.."Graphics/ProgressBar_Blank.dds", ModPath.."Graphics/ProgressBar_GreenDark.dds", 125, 15, 5, 0)
	infoTextb['LAND'..'SupportBonus'] = UiH.CreateClickTextWithTooltipBox(dialogContent, '', 'AtLeftIn', dialogContent, 305, 'Below', dialogContent, -73, 11, 'Arial Gras', Color.AEON, 'ff00ff00', ModPath.."Graphics/ProgressBar_Blank.dds", ModPath.."Graphics/ProgressBar_GreenDark.dds", 125, 15, 5, 0)
	infoTextb['LAND'..'ArdentBonus'] = UiH.CreateClickTextWithTooltipBox(dialogContent, '', 'AtLeftIn', dialogContent, 305, 'Below', dialogContent, -48, 11, 'Arial Gras', Color.AEON, 'ff00ff00', ModPath.."Graphics/ProgressBar_Blank.dds", ModPath.."Graphics/ProgressBar_GreenDark.dds", 125, 15, 5, 0)
	
	infoTextb['NAVAL'..'FighterBonus'] = UiH.CreateClickTextWithTooltipBox(dialogContent, '', 'AtLeftIn', dialogContent, 630, 'Below', dialogContent, -123, 11, 'Arial Gras', Color.AEON, 'ff00ff00', ModPath.."Graphics/ProgressBar_Blank.dds", ModPath.."Graphics/ProgressBar_GreenDark.dds", 125, 15, 5, 0)
	infoTextb['NAVAL'..'RogueBonus'] = UiH.CreateClickTextWithTooltipBox(dialogContent, '', 'AtLeftIn', dialogContent, 630, 'Below', dialogContent, -98, 11, 'Arial Gras', Color.AEON, 'ff00ff00', ModPath.."Graphics/ProgressBar_Blank.dds", ModPath.."Graphics/ProgressBar_GreenDark.dds", 125, 15, 5, 0)
	infoTextb['NAVAL'..'SupportBonus'] = UiH.CreateClickTextWithTooltipBox(dialogContent, '', 'AtLeftIn', dialogContent, 630, 'Below', dialogContent, -73, 11, 'Arial Gras', Color.AEON, 'ff00ff00', ModPath.."Graphics/ProgressBar_Blank.dds", ModPath.."Graphics/ProgressBar_GreenDark.dds", 125, 15, 5, 0)
	infoTextb['NAVAL'..'ArdentBonus'] = UiH.CreateClickTextWithTooltipBox(dialogContent, '', 'AtLeftIn', dialogContent, 630, 'Below', dialogContent, -48, 11, 'Arial Gras', Color.AEON, 'ff00ff00', ModPath.."Graphics/ProgressBar_Blank.dds", ModPath.."Graphics/ProgressBar_GreenDark.dds", 125, 15, 5, 0)
	
	infoTextb['AIR'..'FighterBonus'] = UiH.CreateClickTextWithTooltipBox(dialogContent, '', 'AtLeftIn', dialogContent, 955, 'Below', dialogContent, -123, 11, 'Arial Gras', Color.AEON, 'ff00ff00', ModPath.."Graphics/ProgressBar_Blank.dds", ModPath.."Graphics/ProgressBar_GreenDark.dds", 125, 15, 5, 0)
	infoTextb['AIR'..'RogueBonus'] = UiH.CreateClickTextWithTooltipBox(dialogContent, '', 'AtLeftIn', dialogContent, 955, 'Below', dialogContent, -98, 11, 'Arial Gras', Color.AEON, 'ff00ff00', ModPath.."Graphics/ProgressBar_Blank.dds", ModPath.."Graphics/ProgressBar_GreenDark.dds", 125, 15, 5, 0)
	infoTextb['AIR'..'SupportBonus'] = UiH.CreateClickTextWithTooltipBox(dialogContent, '', 'AtLeftIn', dialogContent, 955, 'Below', dialogContent, -73, 11, 'Arial Gras', Color.AEON, 'ff00ff00', ModPath.."Graphics/ProgressBar_Blank.dds", ModPath.."Graphics/ProgressBar_GreenDark.dds", 125, 15, 5, 0)
	infoTextb['AIR'..'ArdentBonus'] = UiH.CreateClickTextWithTooltipBox(dialogContent, '', 'AtLeftIn', dialogContent, 955, 'Below', dialogContent, -48, 11, 'Arial Gras', Color.AEON, 'ff00ff00', ModPath.."Graphics/ProgressBar_Blank.dds", ModPath.."Graphics/ProgressBar_GreenDark.dds", 125, 15, 5, 0)
	
	local BaseClassList = {'Fighter', 'Rogue', 'Support', 'Ardent'}
	local TypeList = {'AIR', 'LAND', 'NAVAL'}
	local ConvertBonus = {Fighter = '%  Damage', Rogue = '%  Dodge', Support = ' Regen /tech level', Ardent = '%  Damage converted to Health'}
	for _, Class in BaseClassList do
		for _, type in TypeList do
			if DM.GetProperty(armies.focusArmy, 'AI_'..Class..'_'..type) then
				local valuebonus = DM.GetProperty(armies.focusArmy, 'AI_'..Class..'_'..type, 0)
				if valuebonus > 0 then
					infoTextb[type..Class..'Bonus'].SetText('+ '..CF.Calculate_HallofFameBonus(valuebonus, Class)..' '..ConvertBonus[Class])
				else
					infoTextb[type..Class..'Bonus'].SetText('')
				end
			end
		end
	end
end

function ArmorUpgrades_Dialog(_id)
	DialogScreen.Show = 0
	local unit = GetUnitById(_id)
	local bp = unit:GetBlueprint()
	local BaseClass = DM.GetProperty(_id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(_id,'PrestigeClass','Dreadnought')	
	local description = LOC(bp.Description)
	local UnitLevel, UnitLevelP =  CF.GetUnitLevel(unit)
	local dialogContent, title, dialog = UiH.InitDialogContent(1175, 445, "Upgrading Armor")
	local UnitName = UiH.CreateText(dialogContent, '', 'AtLeftIn' , dialogContent, 30, 'Below', title, 15, nil, nil,'ffffffaa')
	local infoText = UiH.CreateTextArea(dialogContent, 520, 60, '', 'AtLeftIn' , dialogContent, 45, 'Below', UnitName, 15, nil, nil, nil)
	local MassCostTitle = UiH.CreateText(dialogContent, 'Mass cost :', 'AtLeftIn', UnitName, 0, 'Below', title, 35)
	local MassCost = UiH.CreateText(dialogContent, '', 'AtLeftIn', MassCostTitle, 68, 'Below', title, 35, nil, nil, 'ffffffaa')
	local EnergyCostTitle = UiH.CreateText(dialogContent, 'Energy cost :', 'AtLeftIn' , UnitName, 0, 'Below', title, 51)
	local EnergyCost = UiH.CreateText(dialogContent, '', 'AtLeftIn', EnergyCostTitle, 74, 'Below', title, 51, nil, nil, 'ffffffaa')
	local SpaceTitle = UiH.CreateText(dialogContent, 'Space used :', 'AtLeftIn' , UnitName, 0, 'Below', title, 67)
	local Space = UiH.CreateText(dialogContent, '', 'AtLeftIn', SpaceTitle, 80, 'Below', title, 67, nil, nil, 'ffffffaa')

	local SpecializationList = {}
	local SpecializationKeys = {}
	local ProgressBar = {}
	local DiffText = {}
	local CurrentUpgradeOnUnit = {}
	local CurrentUpgradeOnUnitLevels = {}
	local NewUpgradeOnUnit = {}
	local NewUpgradeOnUnitLevels = {}
	local ActiveTemplateName = ''
	local ActiveTemplateRow = 0
	local AvailableTemplateList = CF.GetAvailableArmorTemplate(_id, ArmorTemplates)
	local AvailableTemplateListLevels = {}
	local EnergyCostModifier = 1
	local MassCostModifier = 1
	
	if table.find(bp.Categories, 'COMMAND') then 
		EnergyCostModifier = 0.002
		MassCostModifier = 1
	end
	-- LOG(repr(DM.MyData[_id]))
	-- Get current upgrade on unit
	for _, modifier in ArmorModifiers.RefView do
		if DM.GetProperty(_id, 'Upgrade_Armor_'..modifier) then
			CurrentUpgradeOnUnit[modifier] = DM.GetProperty(_id, 'Upgrade_Armor_'..modifier)
			CurrentUpgradeOnUnitLevels[modifier] = math.ceil(DM.GetProperty(_id, 'Upgrade_Armor_'..modifier..'_Level'))
		end
	end
	if table.getn(CF.ExtractKeys(CurrentUpgradeOnUnit)) > 0 then
		AvailableTemplateList['Current upgrade'] = {}
		AvailableTemplateListLevels['Current upgrade'] = {}
		for modifier, value in CurrentUpgradeOnUnit do
			AvailableTemplateList['Current upgrade'][modifier] = value
			AvailableTemplateListLevels['Current upgrade'][modifier] = CurrentUpgradeOnUnitLevels[modifier]
		end
		ActiveTemplateName = 'Current upgrade'
	end

	if PrestigeClass == 'NeedPromote' then PrestigeClass = '' end
	UnitName:SetText(description..' '..BaseClass..' '..PrestigeClass..' [ Level '..UnitLevel..' ]')

	-- Checking all units and weapon category modifiers that can be used
	for ModifierKey, ModifierData in ArmorModifiers.Modifiers do
		if ModifierData.IsAvailable(_id) == true then
			table.insert(SpecializationList, ModifierData.Name)
			table.insert(SpecializationKeys, ModifierKey)
		end
	end
	--- Sorting all modifiers for friendly view
	SpecializationList = CF.SortTable(SpecializationList, ArmorModifiers.RefView)
	SpecializationKeys = CF.SortTable(SpecializationKeys, ArmorModifiers.RefRank)
	
	--Creating ui lists
	local TemplateList = UiH.CreateItemList(dialogContent, 15, 200, nil, 'AtLeftIn', dialogContent, 40, 'Below', infoText, 40, nil, nil, 'ffffffaa', nil, true)
	local TemplateBackG = UiH.CreateBackGround(dialogContent, 'AtLeftIn' , dialogContent, 30, 'Below', infoText, 20 , 150, 230, ModPathIcons.."RedBackGround.dds")
	local TemplateBackGTitle = TemplateBackG.AddTitle('Templates list', 'AtLeftTopIn' , TemplateBackG, 0, 'AtLeftTopIn', TemplateBackG, 0)
	TemplateBackGTitle.SetTooltip('', '')
	local ModifiersItemList = UiH.CreateItemList(dialogContent, 15, 200,  nil, 'AtLeftIn', dialogContent, 280, 'Below', infoText, 40, nil, nil, 'ffffffaa', "000000C0", false)
	local ModifiersValueList = UiH.CreateItemList(dialogContent, 15, 90,   nil, 'AtLeftIn', dialogContent, 472, 'Below', infoText, 40, nil, nil, 'ffffffaa', "000000C0", false)
	local ModifiersBackG = UiH.CreateBackGround(dialogContent, 'AtLeftIn' , dialogContent, 270, 'Below', infoText, 20, 90, 400, ModPathIcons.."WhiteBackGround.dds")
	local ModifiersTitle = ModifiersBackG.AddTitle('Armor stats', 'AtLeftTopIn' , ModifiersBackG, 0, 'AtLeftTopIn', ModifiersBackG, 0)
	ModifiersTitle.SetTooltip('', '')

	-- Creating ProgressBar
	local function CreatingProgressBar()
		-- Creating progress bars
		TableDiff, ValuesOld, ValuesNew = CF.GetDiffTable(CurrentUpgradeOnUnit,  NewUpgradeOnUnit)
		-- Reset values
		for pb,_ in ProgressBar do
			ProgressBar[pb].SetValues(0,0)
			DiffText[pb]:SetText('')
		end	
		-- Getting all values
		--- Progress bar need to be feed with simple key and value lists
		for i, key in CF.SortTable(CF.ExtractKeys(TableDiff), ArmorModifiers.RefView) do
			ProgressBar[key] = UiH.CreateHistogramBarBeforeAfter(dialogContent, 'AtLeftIn', ModifiersValueList, 115, 'Below', infoText, 41 + i*15 - 15, 13, 50, ModPath.."Graphics/ProgressBar_Red.dds", ModPath.."Graphics/ProgressBar_Green.dds")
			ProgressBar[key].SetValues(ValuesOld[key], ValuesNew[key])
			if ValuesNew[key] >= ValuesOld[key] then
				DiffText[key] = UiH.CreateText(dialogContent, '', 'AtLeftIn', ModifiersValueList, 125, 'Below', ProgressBar[key], -13, 11, nil, 'ff00ff00')
				DiffText[key]:SetText('+ '..ValuesNew[key] - ValuesOld[key])
			elseif ValuesNew[key] < ValuesOld[key] then
				DiffText[key] = UiH.CreateText(dialogContent, '', 'AtLeftIn', ModifiersValueList, 90, 'Below', ProgressBar[key], -13, 11, nil, 'ffff7070')
				DiffText[key]:SetText('- '..ValuesOld[key] - ValuesNew[key])
			end		
		end
	end
	
	local SpaceAvailable = CF.GetAvailableSpace(unit)
	SpaceUsed = CF.GetSpaceUsedByArmor(unit)
	CostMass = 0
	CostEnergy = 0
	
	local function RefreshUi()
		ModifiersItemList:DeleteAllItems()
		ModifiersValueList:DeleteAllItems()
		TemplateList:DeleteAllItems()
		CreatingProgressBar()
		for i, key in CF.SortTable(CF.ExtractKeys(TableDiff), ArmorModifiers.RefView) do				
			ModifiersItemList:AddItem(key)
			ModifiersValueList:AddItem(ArmorModifiers.GetPrefix(key)..ValuesNew[key]..ArmorModifiers.GetSuffix(key))	
		end
		ModifiersBackG.Height:Set(table.getn(CF.ExtractKeys(TableDiff)) * 15 + 25)
		for i, key in CF.ExtractKeys(AvailableTemplateList) do
			if CF.GetSpaceUsedByArmor(unit, key, ArmorTemplatesLevels) <= CF.GetAvailableSpace(unit) then
				TemplateList:AddItem(key)
			else
				TemplateList:AddItem(key..'  ( more space needed )')
			end
		end
		TemplateList:SetSelection(ActiveTemplateRow)
		Space:SetText(SpaceUsed..' / '..SpaceAvailable)
		MassCost:SetText(CostMass)
		EnergyCost:SetText(CostEnergy)
	end

	-- Creating Specializations
	local SpecializationListBackG = UiH.CreateBackGround(dialogContent, 'AtLeftIn' , dialogContent, 680, 'Below', infoText, 20 , 240, 460, ModPathIcons.."BlueBackGround.dds")
	local SpecializationListBackGTitle = SpecializationListBackG.AddTitle('Specializations', 'AtLeftTopIn' , SpecializationListBackG, 0, 'AtLeftTopIn', SpecializationListBackG, 0)
	SpecializationListBackGTitle.SetTooltip('', '')	
	local SpecializationSlot = {}
	---- Refresh Specialization function : each time we add or clear specializations we need to update the Weapon stats
	local function RefreshSpecializations()
		NewUpgradeOnUnit = {}
		NewUpgradeOnUnitLevels = {}
		for _, SpeName in SpecializationList do
			if SpecializationSlot[SpeName].RefreshOnMouseExit == false then
				NewUpgradeOnUnitLevels[SpeName] = SpecializationSlot[SpeName].Level
				NewUpgradeOnUnit[SpeName] = ArmorModifiers['Modifiers'][ArmorModifiers.GetInternalKey(SpeName)].Calculate(_id) * (NewUpgradeOnUnitLevels[SpeName] or AvailableTemplateListLevels[ActiveTemplateName][SpeName] or SpecializationSlot[SpeName].Level or 0)
				SpecializationSlot[SpeName]:SetColor('ff00ff00')
				if SpecializationSlot[SpeName].Level > 0 then
					SpecializationSlot[SpeName]:SetText(SpecializationSlot[SpeName].Name..' ['..SpecializationSlot[SpeName].Level..']')
				end
			else
				SpecializationSlot[SpeName]:SetColor('ffaaaa66')
				SpecializationSlot[SpeName]:SetText(SpecializationSlot[SpeName].Name)
			end
		end
		RefreshUi()
	end
	
	-- RefreshCost
	local function RefreshCost()
		SpaceUsed = 0
		CostMass = 0
		CostEnergy = 0
		for i, key in CF.SortTable(CF.ExtractKeys(NewUpgradeOnUnit), ArmorModifiers.RefView) do
			SpaceUsed = math.ceil(SpaceUsed + ArmorModifiers.Modifiers[ArmorModifiers.GetInternalKey(key)].Space * ((NewUpgradeOnUnitLevels[key] or AvailableTemplateListLevels[ActiveTemplateName][key]) or ArmorTemplatesLevels[ActiveTemplateName][key] or 0))
			CostMass = math.ceil(CostMass + bp.Economy.BuildCostMass * MassCostModifier * ArmorModifiers.Modifiers[ArmorModifiers.GetInternalKey(key)].Cost(_id) * ((NewUpgradeOnUnitLevels[key] or AvailableTemplateListLevels[ActiveTemplateName][key]) or ArmorTemplatesLevels[ActiveTemplateName][key] or 0))
			CostEnergy = math.ceil(CostEnergy + bp.Economy.BuildCostEnergy * EnergyCostModifier * ArmorModifiers.Modifiers[ArmorModifiers.GetInternalKey(key)].Cost(_id) * ((NewUpgradeOnUnitLevels[key] or AvailableTemplateListLevels[ActiveTemplateName][key]) or ArmorTemplatesLevels[ActiveTemplateName][key] or 0))
		end
		RefreshUi()
	end
	
	---- Clear specialization button
	local ClearSpecialization = UiH.CreateClickTextWithTooltip(dialogContent, '[ Clear specialization ]', 'AtLeftIn' , SpecializationListBackGTitle, 340, 'Below', SpecializationListBackGTitle, -30, 12, nil, 'ffaaaa66', 'ff00ff00')
	ClearSpecialization.SetTooltip('','')
	ClearSpecialization.OnClickLeft = function(self)
		for _, SpeName in SpecializationList do
			SpecializationSlot[SpeName].RefreshOnMouseExit = true
			SpecializationSlot[SpeName].Level = 0
		end 
		RefreshSpecializations()
		RefreshCost()
	end
	ClearSpecialization.OnClickRight = function(self)
	end
	---- Specialization List Ui
	local XPosition = 15
	local YPosition = -10
	for i, SpeName in SpecializationList do
		if i >= 14 then XPosition = 250 YPosition = -207 end
		local Specialization = UiH.CreateClickTextWithTooltipPersistant(dialogContent, SpeName, 'AtLeftIn' , SpecializationListBackGTitle, XPosition, 'Below', SpecializationListBackGTitle, YPosition + (i * 15), 12, nil, 'ffaaaa66', 'ff00ff00')
		Specialization.RefreshOnMouseExit = true
		Specialization.Level = 0
		Specialization.Name = SpeName
		Specialization.SetTooltip('', '')
		Specialization.OnClickLeft = function(self)
			local SpaceTest = SpaceUsed + ArmorModifiers.Modifiers[ArmorModifiers.GetInternalKey(Specialization.Name)].Space
			if SpaceTest <= SpaceAvailable then 
				if Specialization.RefreshOnMouseExit == true then
					Specialization.RefreshOnMouseExit = false
				end
				Specialization.Level = Specialization.Level + 1
			end
			RefreshSpecializations()
			RefreshCost()
		end
		Specialization.OnClickRight = function(self)
			if Specialization.RefreshOnMouseExit == false and Specialization.Level > 0 then
				Specialization.Level = Specialization.Level - 1
				if Specialization.Level == 0 then Specialization.RefreshOnMouseExit = true end
			end
			RefreshSpecializations()
			RefreshCost()
		end
		SpecializationSlot[SpeName] = Specialization
	end
	
	---- Create Template 
	local CreateTemplate = UiH.CreateClickTextWithTooltip(dialogContent, '[ Save to template ]', 'AtLeftIn' , TemplateBackGTitle, 537, 'Below', TemplateBackGTitle, -30, 12, nil, 'ffaaaa66', 'ff00ff00')
	CreateTemplate.SetTooltip('','')
	CreateTemplate.OnClickLeft = function(self)
		UIUtil.CreateInputDialog(dialogContent, "Choose a template name :", function(self, Name) 
			AvailableTemplateList[Name] = {}
			AvailableTemplateListLevels[Name] = {}
			ArmorTemplates[Name] = {}
			ArmorTemplatesLevels[Name] = {}	
			if CurrentUpgradeOnUnit != nil then
				for i, key in CF.SortTable(CF.ExtractKeys(CurrentUpgradeOnUnit), ArmorModifiers.RefView) do
					AvailableTemplateList['Current upgrade'][key] = CurrentUpgradeOnUnit[key]
				end
			end
			for i, key in CF.SortTable(CF.ExtractKeys(NewUpgradeOnUnit), ArmorModifiers.RefView) do
				ArmorTemplates[Name][key] = ValuesNew[key]
				ArmorTemplatesLevels[Name][key] = SpecializationSlot[key].Level
				AvailableTemplateList[Name][key] = ValuesNew[key]
				AvailableTemplateListLevels[Name][key] = SpecializationSlot[key].Level
			end
			ActiveTemplateName = Name
			ActiveTemplateRow = CF.ExtractRankFromKey(AvailableTemplateList, Name) - 1
			RefreshSpecializations()
			RefreshCost()
		end, nil, nil)
		
	end
	CreateTemplate.OnClickRight = function(self)
	end
	
	---- Delete Template 
	local DeleteTemplate = UiH.CreateClickTextWithTooltip(dialogContent, '[ Delete template ]', 'AtLeftIn' , TemplateBackGTitle, 130, 'Below', TemplateBackGTitle, -30, 12, nil, 'ffaaaa66', 'ff00ff00')
	DeleteTemplate.SetTooltip('','')
	DeleteTemplate.OnClickLeft = function(self)
		UIUtil.CreateInputDialog(dialogContent, "Confirm Template Name to Delete :", function(self, Name) 
			if table.find(CF.ExtractKeys(AvailableTemplateList), Name) then
				AvailableTemplateList[Name] = nil
				ArmorTemplates[Name] = nil
				ArmorTemplatesLevels[Name] = nil
				RefreshUi()
			end
		end, nil, nil)
	end
	DeleteTemplate.OnClickRight = function(self)
	end

	function SyncSpecialization(selectedrow)
		ActiveTemplateRow = 0
		if selectedrow then ActiveTemplateRow = selectedrow end
		ActiveTemplateName = CF.ExtractKeyFromRank(AvailableTemplateList, ActiveTemplateRow + 1)
		-- Clearing Specialisations
		for _, SpeName in SpecializationList do
			SpecializationSlot[SpeName].RefreshOnMouseExit = true
			SpecializationSlot[SpeName].Level = 0
		end
		-- Adding template specializations
		if ActiveTemplateName then
			for SpeName,_ in AvailableTemplateList[ActiveTemplateName] do
				if SpecializationSlot[SpeName] then
					SpecializationSlot[SpeName].RefreshOnMouseExit = false
					SpecializationSlot[SpeName].Level = AvailableTemplateListLevels[ActiveTemplateName][SpeName] or ArmorTemplatesLevels[ActiveTemplateName][SpeName] or 0
				end
			end
		end
	end
	
	TemplateList.OnClick = function(self, row)
		TemplateList:SetSelection(row)
		SyncSpecialization(row)
		RefreshSpecializations()
		RefreshCost()
	end
	
	-- Initializing current upgrade at start
	if table.getn(CF.ExtractKeys(CurrentUpgradeOnUnit)) > 0 then
		-- Adding template specializations
		for SpeName,_ in AvailableTemplateList[ActiveTemplateName] do
			if SpecializationSlot[SpeName] then
				SpecializationSlot[SpeName].RefreshOnMouseExit = false -- to correct
				SpecializationSlot[SpeName].Level = AvailableTemplateListLevels[ActiveTemplateName][SpeName]
			end
		end
		ActiveTemplateRow = CF.ExtractRankFromKey(AvailableTemplateList, 'Current upgrade') - 1
		RefreshSpecializations()
	end
	
	SyncSpecialization()
	RefreshSpecializations()
	RefreshCost()
	
	local okBtn = UiH.CreateButton(dialogContent,'/BUTTON/medium/', 'UPGRADING', 'AtHorizontalCenterIn', dialogContent, nil, 'AtBottomIn', dialogContent, 5)
	local Warning = UiH.CreateText(dialogContent, '', 'AtHorizontalCenterIn' , UnitName, 0, 'Below', title, 75)
	okBtn.OnClick = function(self, modifiers)
		-- Erasing previous Armor modifiers
		local locking = false
		if NewUpgradeOnUnit['Light Armor'] and NewUpgradeOnUnit['Medium Armor'] then locking = true Warning:SetText('You have to choose between Light, Medium or Heavy armor') end -- we cannot cumulate light, medium and heavy armors
		if NewUpgradeOnUnit['Heavy Armor'] and NewUpgradeOnUnit['Medium Armor']  then locking = true Warning:SetText('You have to choose between Light, Medium or Heavy armor') end
		if NewUpgradeOnUnit['Light Armor'] and NewUpgradeOnUnit['Heavy Armor'] then locking = true Warning:SetText('You have to choose between Light, Medium or Heavy armor') end
		if NewUpgradeOnUnit['Armor for Direct Fire'] or NewUpgradeOnUnit['Armor for Direct Fire Naval'] or NewUpgradeOnUnit['Armor for Direct Fire Experimental'] or  NewUpgradeOnUnit['Armor for Overcharge'] or NewUpgradeOnUnit['Armor for Artillery'] or NewUpgradeOnUnit['Armor for Anti Air']
		or NewUpgradeOnUnit['Armor for bomb'] or NewUpgradeOnUnit['Armor for Missile'] or NewUpgradeOnUnit['Armor for Nuclear'] then
			if NewUpgradeOnUnit['Light Armor'] or NewUpgradeOnUnit['Medium Armor'] or NewUpgradeOnUnit['Heavy Armor'] then 
			else 
				locking = true
				Warning:SetText('You have to choose between Light, Medium or Heavy armor before adding a specialization')	
			end
		end
		local SpaceUsed = 0
		for i, key in CF.SortTable(CF.ExtractKeys(NewUpgradeOnUnit), ArmorModifiers.RefView) do
			SpaceUsed = math.ceil(SpaceUsed + ArmorModifiers.Modifiers[ArmorModifiers.GetInternalKey(key)].Space * ((NewUpgradeOnUnitLevels[key] or AvailableTemplateListLevels[ActiveTemplateName][key]) or ArmorTemplatesLevels[ActiveTemplateName][key] or 0))
		end
		if SpaceUsed <= SpaceAvailable and locking == false then 
			local _SetArmor = {}
			for i, key in CF.SortTable(CF.ExtractKeys(NewUpgradeOnUnit), ArmorModifiers.RefView) do
				_SetArmor['Upgrade_Armor_'..key] =  ValuesNew[key]
				_SetArmor['Upgrade_Armor_'..key..'_Level'] =  SpecializationSlot[key].Level
			end
			SimCallback	({Func= 'EcoEvent', Args = {id = _id, Upgrade = 'Weapon', EnergyCost = CostEnergy, MassCost = CostMass, TimeStress = 5, EventName = 'UpgradingArmor', SetArmor = _SetArmor}})
			AvailableTemplateList['CurrentUpgrade'] = nil
			DM.SaveTemplates('Armors', ArmorTemplates, ArmorTemplatesLevels)
			-- LOG(repr(ArmorTemplates))
			dialog:Close()
		end
		if SpaceUsed > SpaceAvailable then
			Warning:SetText('Not enough space. Increase Hull or remove some weapon upgrades.')
		end
	end
end

function WeaponUpgrades_Dialog(_id)
	DialogScreen.Show = 0
	local unit = GetUnitById(_id)
	local bp = unit:GetBlueprint()
	local BaseClass = DM.GetProperty(_id,'BaseClass','Fighter')
	local PrestigeClass = DM.GetProperty(_id,'PrestigeClass','Dreadnought')	
	local description = LOC(bp.Description)
	local UnitLevel, UnitLevelP =  CF.GetUnitLevel(unit)
	local WeaponCategory = bp.Weapon[DialogScreen.WeaponIndex].WeaponCategory
	local dialogContent, title, dialog = UiH.InitDialogContent(1175, 445, "Upgrading "..bp.Weapon[DialogScreen.WeaponIndex].DisplayName)
	local UnitName = UiH.CreateText(dialogContent, '', 'AtLeftIn' , dialogContent, 30, 'Below', title, 15, nil, nil,'ffffffaa')
	local infoText = UiH.CreateTextArea(dialogContent, 520, 60, '', 'AtLeftIn' , dialogContent, 45, 'Below', UnitName, 15, nil, nil, nil)
	local MassCostTitle = UiH.CreateText(dialogContent, 'Mass cost :', 'AtLeftIn', UnitName, 0, 'Below', title, 35)
	local MassCost = UiH.CreateText(dialogContent, '', 'AtLeftIn', MassCostTitle, 68, 'Below', title, 35, nil, nil, 'ffffffaa')
	local EnergyCostTitle = UiH.CreateText(dialogContent, 'Energy cost :', 'AtLeftIn' , UnitName, 0, 'Below', title, 51)
	local EnergyCost = UiH.CreateText(dialogContent, '', 'AtLeftIn', EnergyCostTitle, 74, 'Below', title, 51, nil, nil, 'ffffffaa')
	local SpaceTitle = UiH.CreateText(dialogContent, 'Space used :', 'AtLeftIn' , UnitName, 0, 'Below', title, 67)
	local Space = UiH.CreateText(dialogContent, '', 'AtLeftIn', SpaceTitle, 80, 'Below', title, 67, nil, nil, 'ffffffaa')
	local SpecializationList = {}
	local SpecializationKeys = {}
	local ProgressBar = {}
	local DiffText = {}
	local CurrentUpgradeOnUnit = {}
	local CurrentUpgradeOnUnitLevels = {}
	local NewUpgradeOnUnit = {}
	local NewUpgradeOnUnitLevels = {}
	local ActiveTemplateName = ''
	local ActiveTemplateRow = 0
	local AvailableTemplateList = CF.GetAvailableWeaponTemplateFull(_id, WeaponTemplates, WeaponCategory)
	local AvailableTemplateListLevels = {}
	-- LOG(repr(AvailableTemplateList))
	local EnergyCostModifier = 1
	local MassCostModifier = 1
	
	if table.find(bp.Categories, 'COMMAND') then 
		EnergyCostModifier = 0.002
		MassCostModifier = 1
	end
	
	-- Get current upgrade on unit
	for _, modifier in WeaponModifiers.RefView do
		if DM.GetProperty(_id, 'Upgrade_Weapon_'..DialogScreen.WeaponIndex..'_'..modifier) then
			CurrentUpgradeOnUnit[modifier] = DM.GetProperty(_id, 'Upgrade_Weapon_'..DialogScreen.WeaponIndex..'_'..modifier)
			CurrentUpgradeOnUnitLevels[modifier] = DM.GetProperty(_id, 'Upgrade_Weapon_'..DialogScreen.WeaponIndex..'_'..modifier..'_Level')
		end
	end
	if table.getn(CF.ExtractKeys(CurrentUpgradeOnUnit)) > 0 then
		AvailableTemplateList['Current upgrade'] = {}
		AvailableTemplateListLevels['Current upgrade'] = {}
		for modifier, value in CurrentUpgradeOnUnit do
			AvailableTemplateList['Current upgrade'][modifier] = value
			AvailableTemplateListLevels['Current upgrade'][modifier] = CurrentUpgradeOnUnitLevels[modifier]
		end
		ActiveTemplateName = 'Current upgrade'
	end

	if PrestigeClass == 'NeedPromote' then PrestigeClass = '' end
	UnitName:SetText(description..' '..BaseClass..' '..PrestigeClass..' [ Level '..UnitLevel..' ]')

	-- Checking all units and weapon category modifiers that can be used
	for ModifierKey, ModifierData in WeaponModifiers.Modifiers do
		if ModifierData.IsAvailable(_id, WeaponCategory, DialogScreen.WeaponIndex) == true then
			table.insert(SpecializationList, ModifierData.Name)
			table.insert(SpecializationKeys, ModifierKey)
		end
	end
	--- Sorting all modifiers for friendly view
	SpecializationList = CF.SortTable(SpecializationList, WeaponModifiers.RefView)
	SpecializationKeys = CF.SortTable(SpecializationKeys, WeaponModifiers.RefRank)
	
	--Creating ui lists
	local TemplateList = UiH.CreateItemList(dialogContent, 15, 200, nil, 'AtLeftIn', dialogContent, 40, 'Below', infoText, 40, nil, nil, 'ffffffaa', nil, true)
	local TemplateBackG = UiH.CreateBackGround(dialogContent, 'AtLeftIn' , dialogContent, 30, 'Below', infoText, 20 , 150, 230, ModPathIcons.."RedBackGround.dds")
	local TemplateBackGTitle = TemplateBackG.AddTitle('Templates list', 'AtLeftTopIn' , TemplateBackG, 0, 'AtLeftTopIn', TemplateBackG, 0)
	TemplateBackGTitle.SetTooltip('', '')
	local ModifiersItemList = UiH.CreateItemList(dialogContent, 15, 200,  nil, 'AtLeftIn', dialogContent, 280, 'Below', infoText, 40, nil, nil, 'ffffffaa', "000000C0", false)
	local ModifiersValueList = UiH.CreateItemList(dialogContent, 15, 90,   nil, 'AtLeftIn', dialogContent, 495, 'Below', infoText, 40, nil, nil, 'ffffffaa', "000000C0", false)
	local ModifiersBackG = UiH.CreateBackGround(dialogContent, 'AtLeftIn' , dialogContent, 270, 'Below', infoText, 20, 90, 400, ModPathIcons.."WhiteBackGround.dds")
	local ModifiersTitle = ModifiersBackG.AddTitle('Weapon stats', 'AtLeftTopIn' , ModifiersBackG, 0, 'AtLeftTopIn', ModifiersBackG, 0)
	ModifiersTitle.SetTooltip('', '')

	-- Creating ProgressBar
	local function CreatingProgressBar()
		-- Creating progress bars
		TableDiff, ValuesOld, ValuesNew = CF.GetDiffTable(CurrentUpgradeOnUnit,  NewUpgradeOnUnit)
		-- Reset values
		for pb,_ in ProgressBar do
			ProgressBar[pb].SetValues(0,0)
			DiffText[pb]:SetText('')
		end	
		-- Getting all values
		--- Progress bar need to be feed with simple key and value lists
		for i, key in CF.SortTable(CF.ExtractKeys(TableDiff), WeaponModifiers.RefView) do
			ProgressBar[key] = UiH.CreateHistogramBarBeforeAfter(dialogContent, 'AtLeftIn', ModifiersValueList, 115, 'Below', infoText, 41 + i*15 - 15, 13, 50, ModPath.."Graphics/ProgressBar_Red.dds", ModPath.."Graphics/ProgressBar_Green.dds")
			ProgressBar[key].SetValues(ValuesOld[key], ValuesNew[key])
			if ValuesNew[key] >= ValuesOld[key] then
				DiffText[key] = UiH.CreateText(dialogContent, '', 'AtLeftIn', ModifiersValueList, 125, 'Below', ProgressBar[key], -13, 11, nil, 'ff00ff00')
				DiffText[key]:SetText('+ '..ValuesNew[key] - ValuesOld[key])
			elseif ValuesNew[key] < ValuesOld[key] then
				DiffText[key] = UiH.CreateText(dialogContent, '', 'AtLeftIn', ModifiersValueList, 90, 'Below', ProgressBar[key], -13, 11, nil, 'ffff7070')
				DiffText[key]:SetText('- '..ValuesOld[key] - ValuesNew[key])
			end		
		end
	end
	
	local SpaceAvailable = CF.GetAvailableSpace(unit) + CF.GetSpaceUsedByWeapon(unit, DialogScreen.WeaponIndex)
	SpaceUsed = CF.GetSpaceUsedByWeapon(unit, DialogScreen.WeaponIndex) + CF.GetSpaceUsedByArmor(unit)
	CostMass = 0
	CostEnergy = 0
	
	local function RefreshUi()
		ModifiersItemList:DeleteAllItems()
		ModifiersValueList:DeleteAllItems()
		TemplateList:DeleteAllItems()
		CreatingProgressBar()
		for i, key in CF.SortTable(CF.ExtractKeys(TableDiff), WeaponModifiers.RefView) do				
			ModifiersItemList:AddItem(key)
			ModifiersValueList:AddItem(WeaponModifiers.GetPrefix(key)..ValuesNew[key]..WeaponModifiers.GetSuffix(key))	
		end
		ModifiersBackG.Height:Set(table.getn(CF.ExtractKeys(TableDiff)) * 15 + 25)
		for i, key in CF.ExtractKeys(AvailableTemplateList) do
			TemplateList:AddItem(key)
		end
		TemplateList:SetSelection(ActiveTemplateRow)
		Space:SetText(SpaceUsed..' / '..SpaceAvailable)
		MassCost:SetText(CostMass)
		EnergyCost:SetText(CostEnergy)
	end

	-- Creating Specializations
	local SpecializationListBackG = UiH.CreateBackGround(dialogContent, 'AtLeftIn' , dialogContent, 680, 'Below', infoText, 20 , 240, 460, ModPathIcons.."BlueBackGround.dds")
	local SpecializationListBackGTitle = SpecializationListBackG.AddTitle('Specializations', 'AtLeftTopIn' , SpecializationListBackG, 0, 'AtLeftTopIn', SpecializationListBackG, 0)
	SpecializationListBackGTitle.SetTooltip('', '')	
	local SpecializationSlot = {}
	---- Refresh Specialization function : each time we add or clear specializations we need to update the Weapon stats
	local function RefreshSpecializations()
		NewUpgradeOnUnit = {}
		NewUpgradeOnUnitLevels = {}
		for _, SpeName in SpecializationList do
			if SpecializationSlot[SpeName].RefreshOnMouseExit == false then
				NewUpgradeOnUnitLevels[SpeName] = SpecializationSlot[SpeName].Level
				NewUpgradeOnUnit[SpeName] = WeaponModifiers['Modifiers'][WeaponModifiers.GetInternalKey(SpeName)].Calculate(_id, DialogScreen.WeaponIndex) * (NewUpgradeOnUnitLevels[SpeName] or AvailableTemplateListLevels[ActiveTemplateName][SpeName] or SpecializationSlot[SpeName].Level or 0)
				SpecializationSlot[SpeName]:SetColor('ff00ff00')
				if SpecializationSlot[SpeName].Level > 0 then
					SpecializationSlot[SpeName]:SetText(SpecializationSlot[SpeName].Name..' ['..SpecializationSlot[SpeName].Level..']')
				end
			else
				SpecializationSlot[SpeName]:SetColor('ffaaaa66')
				SpecializationSlot[SpeName]:SetText(SpecializationSlot[SpeName].Name)
			end
		end
		RefreshUi()
	end
	
	-- RefreshCost
	local function RefreshCost()
		SpaceUsed =  CF.GetSpaceUsedByArmor(unit)
		CostMass = 0
		CostEnergy = 0
		for i, key in CF.SortTable(CF.ExtractKeys(NewUpgradeOnUnit), WeaponModifiers.RefView) do
			SpaceUsed = math.ceil(SpaceUsed + WeaponModifiers.Modifiers[WeaponModifiers.GetInternalKey(key)].Space * ((NewUpgradeOnUnitLevels[key] or AvailableTemplateListLevels[ActiveTemplateName][key]) or WeaponTemplatesLevels[ActiveTemplateName][key] or 0))
			CostMass = math.ceil(CostMass + bp.Economy.BuildCostMass * WeaponModifiers.Modifiers[WeaponModifiers.GetInternalKey(key)].Cost(_id) * ((NewUpgradeOnUnitLevels[key] * MassCostModifier or AvailableTemplateListLevels[ActiveTemplateName][key]) or WeaponTemplatesLevels[ActiveTemplateName][key] or 0))
			CostEnergy = math.ceil(CostEnergy + bp.Economy.BuildCostEnergy * WeaponModifiers.Modifiers[WeaponModifiers.GetInternalKey(key)].Cost(_id) * ((NewUpgradeOnUnitLevels[key] * EnergyCostModifier or AvailableTemplateListLevels[ActiveTemplateName][key]) or WeaponTemplatesLevels[ActiveTemplateName][key] or 0))
		end
		RefreshUi()
	end
	
	---- Clear specialization button
	local ClearSpecialization = UiH.CreateClickTextWithTooltip(dialogContent, '[ Clear specialization ]', 'AtLeftIn' , SpecializationListBackGTitle, 340, 'Below', SpecializationListBackGTitle, -30, 12, nil, 'ffaaaa66', 'ff00ff00')
	ClearSpecialization.SetTooltip('','')
	ClearSpecialization.OnClickLeft = function(self)
		for _, SpeName in SpecializationList do
			SpecializationSlot[SpeName].RefreshOnMouseExit = true
			SpecializationSlot[SpeName].Level = 0
		end 
		RefreshSpecializations()
		RefreshCost()
	end
	ClearSpecialization.OnClickRight = function(self)
	end
	---- Specialization List Ui
	local XPosition = 15
	local YPosition = -10
	for i, SpeName in SpecializationList do
		if i >= 14 then XPosition = 250 YPosition = -207 end
		local Specialization = UiH.CreateClickTextWithTooltipPersistant(dialogContent, SpeName, 'AtLeftIn' , SpecializationListBackGTitle, XPosition, 'Below', SpecializationListBackGTitle, YPosition + (i * 15), 12, nil, 'ffaaaa66', 'ff00ff00')
		Specialization.RefreshOnMouseExit = true
		Specialization.Level = 0
		Specialization.Name = SpeName
		Specialization.SetTooltip('', '')
		Specialization.OnClickLeft = function(self)
			local SpaceTest = SpaceUsed + WeaponModifiers.Modifiers[WeaponModifiers.GetInternalKey(Specialization.Name)].Space
			if SpaceTest <= SpaceAvailable then 
				if Specialization.RefreshOnMouseExit == true then
					Specialization.RefreshOnMouseExit = false
				end
				Specialization.Level = Specialization.Level + 1
			end
			RefreshSpecializations()
			RefreshCost()
		end
		Specialization.OnClickRight = function(self)
			if Specialization.RefreshOnMouseExit == false and Specialization.Level > 0 then
				Specialization.Level = Specialization.Level - 1
				if Specialization.Level == 0 then Specialization.RefreshOnMouseExit = true end
			end
			RefreshSpecializations()
			RefreshCost()
		end
		SpecializationSlot[SpeName] = Specialization
	end
	
	---- Create Template 
	local CreateTemplate = UiH.CreateClickTextWithTooltip(dialogContent, '[ Save to template ]', 'AtLeftIn' , TemplateBackGTitle, 537, 'Below', TemplateBackGTitle, -30, 12, nil, 'ffaaaa66', 'ff00ff00')
	CreateTemplate.SetTooltip('','')
	CreateTemplate.OnClickLeft = function(self)
		UIUtil.CreateInputDialog(dialogContent, "Choose a template name :", function(self, Name) 
			AvailableTemplateList[Name] = {}
			AvailableTemplateListLevels[Name] = {}
			WeaponTemplates[Name] = {}
			WeaponTemplatesLevels[Name] = {}	
			if CurrentUpgradeOnUnit != nil then
				for i, key in CF.SortTable(CF.ExtractKeys(CurrentUpgradeOnUnit), WeaponModifiers.RefView) do
					AvailableTemplateList['Current upgrade'][key] = CurrentUpgradeOnUnit[key]
				end
			end
			for i, key in CF.SortTable(CF.ExtractKeys(NewUpgradeOnUnit), WeaponModifiers.RefView) do
				WeaponTemplates[Name][key] = ValuesNew[key]
				WeaponTemplatesLevels[Name][key] = SpecializationSlot[key].Level
				AvailableTemplateList[Name][key] = ValuesNew[key]
				AvailableTemplateListLevels[Name][key] = SpecializationSlot[key].Level
			end
			ActiveTemplateName = Name
			ActiveTemplateRow = CF.ExtractRankFromKey(AvailableTemplateList, Name) - 1
			RefreshSpecializations()
			RefreshCost()
		end, nil, nil)
	end
	CreateTemplate.OnClickRight = function(self)
	end
	
	---- Delete Template 
	local DeleteTemplate = UiH.CreateClickTextWithTooltip(dialogContent, '[ Delete template ]', 'AtLeftIn' , TemplateBackGTitle, 130, 'Below', TemplateBackGTitle, -30, 12, nil, 'ffaaaa66', 'ff00ff00')
	DeleteTemplate.SetTooltip('','')
	DeleteTemplate.OnClickLeft = function(self)
		UIUtil.CreateInputDialog(dialogContent, "Confirm Template Name to Delete :", function(self, Name) 
			if table.find(CF.ExtractKeys(AvailableTemplateList), Name) then
				AvailableTemplateList[Name] = nil
				WeaponTemplates[Name] = nil
				WeaponTemplatesLevels[Name] = nil
				RefreshUi()
			end
		end, nil, nil)
	end
	DeleteTemplate.OnClickRight = function(self)
	end

	function SyncSpecialization(selectedrow)
		ActiveTemplateRow = 0
		if selectedrow then ActiveTemplateRow = selectedrow end
		ActiveTemplateName = CF.ExtractKeyFromRank(AvailableTemplateList, ActiveTemplateRow + 1)
		-- Clearing Specialisations
		for _, SpeName in SpecializationList do
			SpecializationSlot[SpeName].RefreshOnMouseExit = true
			SpecializationSlot[SpeName].Level = 0
		end
		-- Adding template specializations
		if ActiveTemplateName then
			for SpeName,_ in AvailableTemplateList[ActiveTemplateName] do
				SpecializationSlot[SpeName].RefreshOnMouseExit = false
				SpecializationSlot[SpeName].Level = AvailableTemplateListLevels[ActiveTemplateName][SpeName] or WeaponTemplatesLevels[ActiveTemplateName][SpeName] or 0
			end
		end
	end
	
	TemplateList.OnClick = function(self, row)
		TemplateList:SetSelection(row)
		SyncSpecialization(row)
		RefreshSpecializations()
		RefreshCost()
	end
	
	-- Initializing current upgrade at start
	if table.getn(CF.ExtractKeys(CurrentUpgradeOnUnit)) > 0 then
		-- Adding template specializations
		for SpeName,_ in AvailableTemplateList[ActiveTemplateName] do
			SpecializationSlot[SpeName].RefreshOnMouseExit = false
			SpecializationSlot[SpeName].Level = AvailableTemplateListLevels[ActiveTemplateName][SpeName]
		end
		ActiveTemplateRow = CF.ExtractRankFromKey(AvailableTemplateList, 'Current upgrade') - 1
		RefreshSpecializations()
	end
	
	SyncSpecialization()
	RefreshSpecializations()
	RefreshCost()
	
	local okBtn = UiH.CreateButton(dialogContent,'/BUTTON/medium/', 'UPGRADING', 'AtHorizontalCenterIn', dialogContent, nil, 'AtBottomIn', dialogContent, 5)
	local Warning = UiH.CreateText(dialogContent, '', 'AtHorizontalCenterIn' , UnitName, 0, 'Below', title, 75)
	okBtn.OnClick = function(self, modifiers)
		local econData = GetEconomyTotals()
		if SpaceUsed <= SpaceAvailable  then
			local _WeaponToSet = {}
			for i, key in CF.SortTable(CF.ExtractKeys(NewUpgradeOnUnit), WeaponModifiers.RefView) do		
				_WeaponToSet['Upgrade_Weapon_'..DialogScreen.WeaponIndex..'_'..key] = ValuesNew[key]
				_WeaponToSet['Upgrade_Weapon_'..DialogScreen.WeaponIndex..'_'..key..'_Level'] = SpecializationSlot[key].Level
			end
			SimCallback	({Func= 'EcoEvent', Args = {id = _id, Upgrade = 'Weapon', EnergyCost = CostEnergy, MassCost = CostMass, TimeStress = 5, EventName = 'UpgradingWeapon', nil, WeaponIndex = DialogScreen.WeaponIndex, SetWeapon= _WeaponToSet}})
			AvailableTemplateList['CurrentUpgrade'] = nil
			DM.SaveTemplates('Weapons', WeaponTemplates, WeaponTemplatesLevels)
			dialog:Close()
		else
			Warning:SetText('Not enough space.')
		end
	end
end

function EngineerConsolidationBonus_Dialog(_id)
	local Ui = {}
	DialogScreen.Show = 0
	local dialogContent, title, dialog = UiH.InitDialogContent(360, 150, "New Building Rate")
	local okBtn = UiH.CreateButton(dialogContent,'/BUTTON/medium/', ' APPLY ', 'AtHorizontalCenterIn', dialogContent, nil, 'AtBottomIn', dialogContent, 5)
	local MaxBuildingspeed = DM.GetProperty(_id,'EngineerConsolidationBonus', 0)
	local ActualBuildingspeed = DM.GetProperty(_id,'SetBuildingSpeed', 0)
	local unit = GetUnitById(_id)
	local bp = unit:GetBlueprint()
	
	Ui['Ec_Slider'] = Slider(dialogContent, false, 0, MaxBuildingspeed, UIUtil.SkinnableFile('/slider02/slider_btn_up.dds'), UIUtil.SkinnableFile('/slider02/slider_btn_over.dds'), UIUtil.SkinnableFile('/slider02/slider_btn_down.dds'), UIUtil.SkinnableFile('/slider02/slider-back_bmp.dds'))
	LayoutHelpers.AtLeftTopIn(Ui['Ec_Slider'], dialogContent, 75, 40)
	
	Ui['Buildingspeed'] = UiH.CreateTextWithTooltip(dialogContent, ActualBuildingspeed, 'AtLeftIn' , Ui['Ec_Slider'], 100, 'Below', Ui['Ec_Slider'], 10, nil, nil, 'ffffffaa', 'ff00ff00')
	Ui['Buildingspeed'].SetTooltip('New buildrate consolidation Bonus Value','')
	Ui['Ec_Slider']:SetValue(ActualBuildingspeed)
	
	local function RefreshUi()
		Ui['Buildingspeed']:SetText(tostring(ActualBuildingspeed + math.floor(CF.GetSkillCurrent(_id, 'Building') / 5) - 1 + bp.Economy.BuildRate))
		Ui['Buildingspeed'].SetTooltip('Engineer Consolidation Bonus : '..ActualBuildingspeed,'')
	end
	RefreshUi()
	
	Ui['Ec_Slider'].OnValueChanged = function(self, newValue)
		ActualBuildingspeed = math.ceil(newValue)
		RefreshUi()
	end

	okBtn.OnClick = function(self)
		SimCallback	({Func= 'SetBuildingSpeed', Args = {id = _id, BuildingRate = ActualBuildingspeed}})
		dialog:Close()
	end
end

function Training_Dialog(id)
	local Ui = {}
	DialogScreen.Show = 0
	local u = DM.GetUnitBp(nil, id)
	local Skills = CF.GetUnitSkills(id)
	local unit = GetUnitById(id)
	local bp = unit:GetBlueprint()
	local description = LOC(bp.Description)
	local dialogContent, title, dialog = UiH.InitDialogContent(660, 345 + table.getn(Skills) * 20, "Training Center")
	local okBtn = UiH.CreateButton(dialogContent,'/BUTTON/medium/', '  Train  ', 'AtHorizontalCenterIn', dialogContent, nil, 'AtBottomIn', dialogContent, 5)
	local infoText = UiH.CreateTextArea(dialogContent, 520, 45, '', 'AtLeftIn' , dialogContent, 45, 'Below', title, 25, nil, nil, nil)
	infoText:SetText("Welcome in the Training Center. Please choose your "..description.."'s training priorities. Please note that Attributes (PUISSANCE, HULL...) will train following theses priorities but Skills (Weapon Skills...) will train automatically")
	local Abilities = {'Puissance', 'Dexterity', 'Hull', 'Intelligence', 'Energy'}
	local Ttip = {
	'Puissance increases weapons damage, weapon powers and heavy armor efficiency.', 
	'Dexterity is the skill for adroitness. It increases minimum damages, Defense and Attack rating so the unit can dodge and hit easier.', 
	'Hull enforces hits points, regen speed and weapon capacitor power regen and maximum cap.', 
	'Intelligence is the AI assistance. It increases powers effiency, power capacitor regen and increases all skills maximum cap', 
	'Energy is the main focus for increasing all powers minimum efficiency and power capacitor maximum cap.'}
	local TotalTrainingWeight = 0
	local TotalTrainingWeightSkill = 0
	local function RefreshUi()
		TotalTrainingWeight = 0
		TotalTrainingWeightSkill = 0
		for i, Ability in Abilities do
			TotalTrainingWeight = TotalTrainingWeight + Ui[Ability..'_TrainingWeight']
		end		
		for i, Ability in Abilities do
			Ui[Ability..'HistogramTraining'].SetValueWidth(Ui[Ability..'_TrainingWeight'] / TotalTrainingWeight)
			Ui[Ability..'TrainingText']:SetText(tostring(math.floor(Ui[Ability..'_TrainingWeight'] / TotalTrainingWeight * 100))..' %')
		end
	end
	local AbitlitiesBackG = UiH.CreateBackGround(dialogContent, 'AtLeftIn' , dialogContent, 45, 'Below', infoText, 20 , table.getn(Abilities) * 20 + 5, 560, ModPathIcons.."RedBackGround.dds")
	for i, Ability in Abilities do
		TotalTrainingWeight = TotalTrainingWeight + DM.GetProperty(id, Ability..'_TrainingWeight')
	end
	for i, Ability in Abilities do
		Ui[Ability] = UiH.CreateTextWithTooltip(dialogContent, string.upper(Ability), 'AtLeftIn' , dialogContent, 50, 'Below', infoText, (i-1) * 20 + 25, nil, nil, 'ffffffaa', 'ff00ff00')
		Ui[Ability].SetTooltip(string.upper(Ability), Ttip[i])
		local AbilityValue =  math.floor(DM.GetProperty(id, Ability))
		Ui[Ability..'Value'] = UiH.CreateTextWithTooltip(dialogContent, AbilityValue, 'AtLeftIn' , dialogContent, 220, 'Below', infoText, (i-1) * 20 + 25, nil, nil, 'ffffffaa', 'ff00ff00')
		Ui[Ability..'Value'].SetTooltip(Ability, 'Current value')
		local AbilityMax = DM.GetProperty(id, Ability..'_Max', 0.01)
		Ui[Ability..'Max'] = UiH.CreateTextWithTooltip(dialogContent, AbilityMax, 'AtLeftIn' , Ui[Ability..'Value'], 75, 'Below', infoText, (i-1) * 20 + 25, nil, nil, 'ffffffaa', 'ff00ff00')
		Ui[Ability..'Max'].SetTooltip(Ability, 'Max value')
		local HistogramColor = ModPath.."Graphics/ProgressBar_Red.dds"
		if AbilityValue / AbilityMax > 0.33 then HistogramColor = ModPath.."Graphics/ProgressBar_Yellow.dds" end
		if AbilityValue / AbilityMax > 0.66 then HistogramColor = ModPath.."Graphics/ProgressBar_Green.dds" end
		Ui[Ability..'Histogram'] = UiH.CreateHistogramBar(dialogContent, 'AtLeftIn' , Ui[Ability..'Value'], 25, 'Below', infoText, (i-1) * 20 + 25, 15, 45, HistogramColor)
		Ui[Ability..'Histogram'].SetValueWidth(AbilityValue / AbilityMax)
		Ui[Ability..'Slider'] = Slider(dialogContent, false, 0.01, 100, UIUtil.SkinnableFile('/slider02/slider_btn_up.dds'), UIUtil.SkinnableFile('/slider02/slider_btn_over.dds'), UIUtil.SkinnableFile('/slider02/slider_btn_down.dds'), UIUtil.SkinnableFile('/slider02/slider-back_bmp.dds')) LayoutHelpers.AtLeftTopIn(Ui[Ability..'Slider'], Ui[Ability..'Max'], 50, 0)
		Ui[Ability..'_TrainingWeight'] = DM.GetProperty(id, Ability..'_TrainingWeight')
		Ui[Ability..'Slider']:SetValue(Ui[Ability..'_TrainingWeight'])
		Ui[Ability..'HistogramTraining'] = UiH.CreateHistogramBar(dialogContent, 'AtLeftIn' , Ui[Ability..'Slider'], 210, 'Below', infoText, (i-1) * 20 + 25, 15, 45, ModPath.."Graphics/ProgressBar_Yellow.dds")
		Ui[Ability..'HistogramTraining'].SetValueWidth(Ui[Ability..'_TrainingWeight'] / TotalTrainingWeight)
		Ui[Ability..'TrainingText'] = UiH.CreateTextWithTooltip(dialogContent, tostring(math.floor(Ui[Ability..'_TrainingWeight'] / TotalTrainingWeight * 100))..' %', 'AtLeftIn' , Ui[Ability..'HistogramTraining'], 0, 'Below', infoText, (i-1) * 20 + 25, nil, nil, 'ffffffaa', 'ff00ff00')
		Ui[Ability..'TrainingText'].SetTooltip('Training weight', 'Percent of XP that goes in this ability')
		Ui[Ability..'Slider'].AbilityName = Ability
		Ui[Ability..'Slider'].OnValueChanged = function(self, newValue)
			Ui[self.AbilityName..'_TrainingWeight'] = newValue
			RefreshUi()
		end
	end
	local SkillsBackG = UiH.CreateBackGround(dialogContent, 'AtLeftIn' , dialogContent, 45, 'Below', infoText, table.getn(Abilities) * 20 + 40 , (table.getn(Skills)) * 20 + 5, 280, ModPathIcons.."YellowBackGround.dds")
	for i, Skill in Skills do
		if not DM.GetProperty(id, Skill..'_TrainingWeight') then DM.SetProperty(id, Skill..'_TrainingWeight', 0.01) end
		TotalTrainingWeightSkill = TotalTrainingWeightSkill + DM.GetProperty(id, Skill..'_TrainingWeight')
	end
	for i, Skill in Skills do
		Ui[Skill] = UiH.CreateTextWithTooltip(dialogContent, string.upper(Skill), 'AtLeftIn' , dialogContent, 50, 'Below', infoText, (table.getn(Abilities) + i) * 20 + 25, nil, nil, 'ffffffaa', 'ff00ff00')
		Ui[Skill].SetTooltip(string.upper(Skill), CF.GetSkillDescription(Skill))
		local SkillValue =  CF.GetSkillCurrent(id, Skill)
		Ui[Skill..'Value'] = UiH.CreateTextWithTooltip(dialogContent, SkillValue, 'AtLeftIn' , dialogContent, 220, 'Below', infoText, (table.getn(Abilities) + i) * 20 + 25, nil, nil, 'ffffffaa', 'ff00ff00')
		Ui[Skill..'Value'].SetTooltip(Skill, 'Current value')
		local SkillMax = CF.GetSkillMax(id, Skill)
		Ui[Skill..'Max'] = UiH.CreateTextWithTooltip(dialogContent, SkillMax, 'AtLeftIn' , Ui[Skill..'Value'], 75, 'Below', infoText, (table.getn(Abilities) + i) * 20 + 25, nil, nil, 'ffffffaa', 'ff00ff00')
		Ui[Skill..'Max'].SetTooltip(Skill, 'Max value')
		local HistogramColor = ModPath.."Graphics/ProgressBar_Red.dds"
		if SkillValue / SkillMax > 0.33 then HistogramColor = ModPath.."Graphics/ProgressBar_Yellow.dds" end
		if SkillValue / SkillMax > 0.66 then HistogramColor = ModPath.."Graphics/ProgressBar_Green.dds" end
		Ui[Skill..'Histogram'] = UiH.CreateHistogramBar(dialogContent, 'AtLeftIn' , Ui[Skill..'Value'], 25, 'Below', infoText, (table.getn(Abilities) + i) * 20 + 25, 15, 45, HistogramColor)
		Ui[Skill..'Histogram'].SetValueWidth(SkillValue / SkillMax)
	end
	
	okBtn.OnClick = function(self)
			for i, Ability in Abilities do
				SimCallback	({Func= 'OnTraining', Args = {Id = id, ability = Ability, weight =  Ui[Ability..'_TrainingWeight']}})
			end
		dialog:Close()
	end
end

function CreateProgressBar(Name, xpos, ypos, Height, Width, TexturePath)
	local StaticBar = Bitmap(UI, UIUtil.UIFile(TexturePath))
    StaticBar.Height:Set(Height)
    StaticBar.Width:Set(Width)
    LayoutHelpers.AtLeftTopIn(StaticBar, UI, xpos, ypos)
	UmUi['ProgressBar_'..Name] = StaticBar
	UmUi['ProgressBar_'..Name]._Width = Width
	UmUi['ProgressBar_'..Name]:DisableHitTest(true)
end

function SetProgressBar(unit, Name, percent)
	local Width = UmUi['ProgressBar_'..Name]._Width * (percent / 100)
	UmUi['ProgressBar_'..Name].Width:Set(Width)
end


function CreateUnitUi()
	ArmorTemplates, ArmorTemplatesLevels, UnitGeneralTemplates = DM.GetTemplates('Armors') -- Loading templates
	WeaponTemplates, WeaponTemplatesLevels = DM.GetTemplates('Weapons')
	
	-- Adding custom template to a wide range of units
	SettingTemplates()
	
	-- Enhanced Tooltip UI
	UmUi['EnhancedTooltipUi'] = Bitmap(parent, UIUtil.UIFile(ModPath.."Modules/Graphics/FullBlack.dds"))
    UmUi['EnhancedTooltipUi'].Height:Set(82)
    UmUi['EnhancedTooltipUi'].Width:Set(280)
    LayoutHelpers.AtLeftTopIn(UmUi['EnhancedTooltipUi'], parent, 10, 450)
	UmUi['EnhancedTooltipUi']:SetAlpha(0.7, true)
	local titleoffset = 5
	local function TtipHandleEvent(self, event)
		if event.Type == 'MouseEnter' then
			EnhTtipTimer = 0
			LockTimer = true
			local sound = Sound({Bank = 'Interface', Cue = 'UI_Economy_Rollover'})
			PlaySound(sound)
		end
		if event.Type == 'MouseExit' then
			LockTimer = false
		end
	end
	UmUi['EnhancedTooltipUi'].HandleEvent = TtipHandleEvent
	UmUi['EnhancedTooltipUi']:Hide()
	for i = 1, 32 do
		if i == 1 then titleoffset = 0 else titleoffset = 5 end
		local EnhTtipSlotId = 'EnhancedTooltipUi'..i
		local EhtTtipBox, EhtTtipText = UiH.CreateClickTextWithTooltipBox(UmUi['EnhancedTooltipUi'], 'Line '..i, 'AtLeftIn', UmUi['EnhancedTooltipUi'], 5, 'AtLeftTopIn',  UmUi['EnhancedTooltipUi'], i*17 -10 + titleoffset, 12 , nil , 'ffffffaa', 'ff00ff00', ModPath.."Graphics/ProgressBar_Blank.dds", ModPath.."Graphics/ProgressBar_SoftYellow.dds", 100, 15, 5, 0)
		EhtTtipBox.Id = i
		EhtTtipText.Id = i
		EhtTtipBox.OnClickLeft = function(self)
			local _PowerName = UmUi['EnhancedTooltipUi'..EhtTtipBox.Id..'Box'].PowerCastName
			local UnitId = UmUi['EnhancedTooltipUi'..EhtTtipBox.Id..'Box'].UnitId
			local TtipChoice = UmUi['EnhancedTooltipUi'..EhtTtipBox.Id..'Box'].TtipChoice
			local unit = GetUnitById(UnitId)
			local PowersList = CF.GetUnitPowers(UnitId)
			local len = table.getn(PowersList)
			for i = 1, len do
				for _, power in Powers do
					if _PowerName == PowersList[i] then
						local Power = CF.GetUnitPower(UnitId, _PowerName)
						if Power.CanCast(unit) == true then
							SimCallback	({Func= 'CallPower', Args = {id = UnitId, PowerName = _PowerName, Choice = TtipChoice}})
						end
					end
				end
			end
		end
		EhtTtipBox.OnClickRight = function(self)
		end
		UmUi[EnhTtipSlotId..'Box'] = EhtTtipBox
		UmUi[EnhTtipSlotId..'Text'] = EhtTtipText
		UmUi[EnhTtipSlotId..'Box']:Hide()
		UmUi[EnhTtipSlotId..'Text']:Hide()
		UmUi[EnhTtipSlotId..'Box']:DisableHitTest(false)
		UmUi[EnhTtipSlotId..'Text']:DisableHitTest(false)
	end
	
	
	-- Creating UnitUi
	UnitUi = Bitmap(parent, UIUtil.UIFile(ModPath.."Modules/Graphics/50Transp.dds"))
	UnitUi.Height:Set(200)
    UnitUi.Width:Set(200)
	LayoutHelpers.AtBottomIn(UnitUi, parent, 320)
	LayoutHelpers.AtLeftIn(UnitUi, parent, 10)
	UnitUi:DisableHitTest(true)
		
	-- BaseClass and Prestige Class Icon
	UmUi['BaseClass'] = UiH.CreateButtonBitmap(UnitUi, ModPathIcons..'Fighter.dds', ModPathIcons..'Fighter.dds', 'AtLeftIn', UnitUi, 0, 'Below', UnitUi, -20)
	UmUi['PrestigeClass'] = UiH.CreateButtonBitmap(UnitUi, ModPathIcons..'PromoteVoid.dds', ModPathIcons..'PromoteVoid.dds', 'AtLeftIn', UnitUi, 0, 'Below', UnitUi, -75)
	UmUi['PrestigeClassText'] = UiH.CreateTextWithTooltip(UmUi['PrestigeClass'], 'PROMOTE', 'AtLeftIn' , UmUi['PrestigeClass'], 0, 'Below', UmUi['PrestigeClass'], -40, 11, nil, 'ffffffaa', 'ff00ff00')
	UmUi['PrestigeClassText2'] = UiH.CreateTextWithTooltip(UmUi['PrestigeClass'], 'HERE', 'AtLeftIn' , UmUi['PrestigeClass'], 10, 'Below', UmUi['PrestigeClass'], -20, 11, nil, 'ffffffaa', 'ff00ff00')
	UmUi['PrestigeClassText']:DisableHitTest(false)
	UmUi['PrestigeClassText2']:DisableHitTest(false)
	UmUi['UnitLevel'] = UiH.CreateTextWithTooltip(UnitUi, 1, 'AtLeftIn' , UnitUi, 35, 'Below', UnitUi, 10, 14, nil, 'ffffffaa', 'ff00ff00')
	UmUi['UnitLevel']:DisableHitTest(false)
	UmUi['BaseClass'].OnClickLeft = function(self)
		local unit = GetSelectedUnits()
		local id = unit[1]:GetEntityId()
		Training_Dialog(id)
	end
	UmUi['BaseClass'].OnClickRight = function(self)
		local unit = GetSelectedUnits()
		local _id = unit[1]:GetEntityId()
		local bp = unit[1]:GetBlueprint()
		local Power = math.floor(math.pow(bp.Economy.BuildCostMass, 0.5))
		if table.find(bp.Categories, 'COMMAND') then Power = Power * 5 end
		local UnitLevel, UnitLevelP =  CF.GetUnitLevel(unit[1])		
		if CF.IsMilitary(unit[1]) == true and UnitLevel < 75 and DM.GetProperty('Global'..unit[1]:GetArmy(), 'MilitaryXP') and DM.GetProperty('Global'..unit[1]:GetArmy(), 'MilitaryXP') / Power > 500 then
			local XPPoints = DM.GetProperty('Global'..unit[1]:GetArmy(), 'MilitaryXP') / Power		
			local XPAdded = math.min(XPPoints, 100)
			SimCallback	({Func= 'OnGivingXP', Args = {id = _id, xp = XPAdded, type = 'MilitaryXP'}})
		elseif CF.IsMilitary(unit[1]) == false and UnitLevel < 75 and DM.GetProperty('Global'..unit[1]:GetArmy(), 'CivilianXP') and DM.GetProperty('Global'..unit[1]:GetArmy(), 'CivilianXP') / Power > 500 then
			local XPPoints = DM.GetProperty('Global'..unit[1]:GetArmy(), 'CivilianXP') / Power
			local XPAdded = math.min(XPPoints, 100)
			SimCallback	({Func= 'OnGivingXP', Args = {id = _id, xp = XPAdded, type = 'CivilianXP'}})
		end
	end
	UmUi['PrestigeClass'].OnClickLeft = function(self)
		local unit = GetSelectedUnits()
		local id = unit[1]:GetEntityId()
		if DM.GetProperty(id,'PrestigeClass') ~= 'NeedPromote' then
			DialogScreen.Show = 1
			DialogScreen.UpgradeType = 'ArmorUpgrade'
			DialogScreen.Template = 'ArmorTemplate'
		end
	end
	UmUi['PrestigeClass'].OnClickRight = function(self)
	end
	UmUi['ArmorResist'] = UiH.CreateTextWithTooltip(UnitUi, 1, 'AtLeftIn' , UnitUi, 2, 'Below', UnitUi, 11, 11, nil, 'ffffffaa', 'ff00ff00')
	UmUi['DodgeChance'] = UiH.CreateTextWithTooltip(UnitUi, 1, 'AtLeftIn' , UnitUi, 2, 'Below', UnitUi, -19, 11, nil, 'ffffffaa', 'ff00ff00')
	UmUi['ArmorUpgradingProgress'] = UiH.CreateTextWithTooltip(UnitUi, 1, 'AtLeftIn' , UnitUi, 11, 'Below', UnitUi, -59, 11, nil, 'ffffffaa', 'ff00ff00')
	UmUi['ArmorResist']:DisableHitTest(false)
	UmUi['DodgeChance']:DisableHitTest(false)
	UmUi['ArmorUpgradingProgress']:DisableHitTest(false)
	
	-- Capacitors bars
	StaminaHistogram = UiH.CreateHistogramBar(UnitUi, 'AtLeftIn' , UmUi['BaseClass'], 585, 'Below', UmUi['BaseClass'], 90, 25, 120, ModPath.."Graphics/ProgressBar_Orange.dds")
	StaminaHistogram.SetValueWidth(1)
	StaminaText = UiH.CreateText(StaminaHistogram, '', 'AtLeftIn', StaminaHistogram, 20, 'Below', StaminaHistogram, -20, 11, nil, Color.WHITE)
	StaminaText:DisableHitTest(true)
	CapacitorHistogram =  UiH.CreateHistogramBar(UnitUi, 'AtLeftIn' , UmUi['BaseClass'], 585, 'Below', UmUi['BaseClass'], 120, 25, 120, ModPath.."Graphics/ProgressBar_BlueFull.dds")
	CapacitorHistogram.SetValueWidth(1)
	CapacitorText = UiH.CreateText(CapacitorHistogram, '', 'AtLeftIn', CapacitorHistogram, 20, 'Below', CapacitorHistogram, -20, 11, nil, Color.WHITE)
	CapacitorText:DisableHitTest(true)
	LevelHistogram = UiH.CreateHistogramBar(UnitUi, 'AtLeftIn' , UmUi['BaseClass'], 3, 'Below', UmUi['BaseClass'], 1, 4, 40, ModPath.."Graphics/ProgressBar_Purple.dds")
	LevelHistogram.SetValueWidth(1)
	
	-- Capacitor background
	Capacitors_BackG = Bitmap(parent, UIUtil.UIFile(ModPath.."/Graphics/Capacitors_Background.dds"))
	LayoutHelpers.AtBottomIn(Capacitors_BackG, parent, 114)
	LayoutHelpers.AtLeftIn(Capacitors_BackG, parent, 485)
	Capacitors_BackG:Hide()

	-- Hero Level
	HeroText = UiH.CreateText(StaminaHistogram, '', 'AtLeftIn', StaminaHistogram, 0, 'Below', StaminaHistogram, -48, 11, nil, Color.GOLD)
	
	-- template and space
	UiSpaceAvailable, UiSpaceAvailableText  = UiH.CreateClickTextWithTooltipBox(UnitUi, 'Space used : ', 'AtLeftIn', UmUi['BaseClass'], 0, 'Below', UmUi['BaseClass'], 10, 11, nil, 'ffffffaa', 'ff00ff00', ModPath.."Graphics/ProgressBar_Brown75.dds", ModPath.."Graphics/ProgressBar_GreenDark.dds", 150, 15, 5, 2)
	UiSpaceAvailable.OnClickLeft = function(self)
		local unit = GetSelectedUnits()
		local id = unit[1]:GetEntityId()
		if DM.GetProperty(id, 'PrestigeClassPromoted') == 1 then
			UIUtil.CreateInputDialog(parent, "Save template. Choose a template name :", function(self, Name) 
				local UnitCatId = unit[1]:GetUnitId()
				if not UnitGeneralTemplates[UnitCatId] then
					UnitGeneralTemplates[UnitCatId] = {}
				end
				local BaseClass = DM.GetProperty(id, 'BaseClass')
				if not UnitGeneralTemplates[UnitCatId][BaseClass] then
					UnitGeneralTemplates[UnitCatId][BaseClass] = {}
				end
				local PrestigeClass = DM.GetProperty(id, 'PrestigeClass')
				if not UnitGeneralTemplates[UnitCatId][BaseClass][PrestigeClass]  then
					UnitGeneralTemplates[UnitCatId][BaseClass][PrestigeClass] = {}
				end
				UnitGeneralTemplates[UnitCatId][BaseClass][PrestigeClass][Name] = nil
				UnitGeneralTemplates[UnitCatId][BaseClass][PrestigeClass][Name] = {}

				-- Saving TrainingWeight
				local TrainingWeight = {'Puissance', 'Dexterity', 'Hull', 'Intelligence', 'Energy'}
				for _,Abilities in TrainingWeight do
					UnitGeneralTemplates[UnitCatId][BaseClass][PrestigeClass][Name][Abilities] = DM.GetProperty(id, Abilities..'_TrainingWeight', 0.01)
				end
				-- Saving Armor and Weapons
				for _, Modifier in ArmorModifiers.RefView do
					if DM.GetProperty(id, 'Upgrade_Armor_'..Modifier..'_Level') then
						UnitGeneralTemplates[UnitCatId][BaseClass][PrestigeClass][Name]['Upgrade_Armor_'..Modifier..'_Level'] = DM.GetProperty(id, 'Upgrade_Armor_'..Modifier..'_Level')
					end
				end
				for WeaponIndex = 1, 30 do
					for _, Modifier in WeaponModifiers.RefView do
						if DM.GetProperty(id, 'Upgrade_Weapon_'..WeaponIndex..'_'..Modifier..'_Level') then
							UnitGeneralTemplates[UnitCatId][BaseClass][PrestigeClass][Name]['Upgrade_Weapon_'..WeaponIndex..'_'..Modifier..'_Level'] = DM.GetProperty(id, 'Upgrade_Weapon_'..WeaponIndex..'_'..Modifier..'_Level')
						end
					end
				end
				DM.SaveTemplates(nil, nil,nil, UnitGeneralTemplates)
				-- LOG(repr(UnitGeneralTemplates))
			end, nil, nil)
		end
	end
	UiSpaceAvailable.OnClickRight = function(self)
		local unit = GetSelectedUnits()
		local id = unit[1]:GetEntityId()
		if DM.GetProperty(id, 'PrestigeClassPromoted') == 1 then
			UIUtil.CreateInputDialog(parent, "Delete template. Choose a template name :", function(self, Name) 
				local UnitCatId = unit[1]:GetUnitId()
				local BaseClass = DM.GetProperty(id, 'BaseClass')
				local PrestigeClass = DM.GetProperty(id, 'PrestigeClass')
				if UnitGeneralTemplates[UnitCatId][BaseClass][PrestigeClass][Name] then
					UnitGeneralTemplates[UnitCatId][BaseClass][PrestigeClass][Name] = nil
				end
				DM.SaveTemplates(nil, nil,nil, UnitGeneralTemplates)
			end, nil, nil)
		end
	end
	
	-- Creating Promotion Boxes
	UIPromotion = Bitmap(parent, UIUtil.UIFile(ModPath.."Modules/Graphics/50Transp.dds"))
    UIPromotion.Height:Set(400)
    UIPromotion.Width:Set(400)
	LayoutHelpers.AtLeftTopIn(UIPromotion, UmUi['PrestigeClass'], -100, 0)
	local z = 1
	local y = 170
	for i = 1,32 do
		if i == 5 then y = 300 z = 1 end
		CreateClickBox(UIPromotion, i, ModPath.."Graphics/ProgressBar_back.dds", ModPath.."Graphics/ProgressBar_Yellow.dds", y, (z*25)-25, "OnChoosePromotion", RefreshPromotion, nil, 120)
		z = z+1
	end
	PromotionUiTimer = 1
	--
	
	-- Creating Power boxes
	UIPower = Bitmap(parent, UIUtil.UIFile(ModPath.."Modules/Graphics/50Transp.dds"))
	UIPower.Height:Set(200)
    UIPower.Width:Set(800)
	LayoutHelpers.AtBottomIn(UIPower, parent, 160)
	LayoutHelpers.AtLeftIn(UIPower, parent, 790)
	UIPower:DisableHitTest(true)
	local x = -100
	local y = 0
	for i = 1, 80 do
		UmUi['PowerBox_'..i] = UiH.CreateButtonBitmap(UIPower, ModPathIcons..'PowerVoid.dds', ModPathIcons..'PowerVoid.dds', 'AtLeftIn', UIPower, x + i*42, 'Below', UIPower, y)
		UmUi['PowerBoxText_'..i] = UiH.CreateText(UmUi['PowerBox_'..i], '', 'AtHorizontalCenterIn', UmUi['PowerBox_'..i], 0, 'AtVerticalCenterIn', UmUi['PowerBox_'..i], 0, 18 , nil , 'ffff3030')
		UmUi['PowerBoxText_'..i]:DisableHitTest(true)
		
		if i >= 20 then y = -44 x = -840 end
		if i >= 40 then y = -88 x = -1680 end
		if i >= 60 then y = -132 x = -2520 end
	end
	
	-- Creating Stances boxes
	UIStances = Bitmap(parent, UIUtil.UIFile(ModPath.."Modules/Graphics/50Transp.dds"))
	UIStances.Height:Set(200)
    UIStances.Width:Set(200)
	LayoutHelpers.AtBottomIn(UIStances, parent, 183)
	LayoutHelpers.AtLeftIn(UIStances, parent, 500)
	UIStances:DisableHitTest(true)
	UmUi['Stance_Normal'] = UiH.CreateButtonBitmap(UIStances, ModPathIcons..'Stance_Normal.dds', ModPathIcons..'Stance_Normal_Selected.dds', 'AtLeftIn', UIStances, 0, 'Below', UIStances, 0)
	UmUi['Stance_Normal'].OnClickLeft = function(self)
		local unit = GetSelectedUnits()
		local _id = unit[1]:GetEntityId()
		SimCallback	({Func= 'OnChangeStance', Args = {id = _id, Stance = 'Normal'}}) 
	end
	UmUi['Stance_Normal'].OnClickRight = function(self)
	end
	UmUi['Stance_Defensive'] = UiH.CreateButtonBitmap(UIStances, ModPathIcons..'Stance_Defensive.dds', ModPathIcons..'Stance_Defensive_Selected.dds', 'AtLeftIn', UIStances, 45, 'Below', UIStances, 0)
	UmUi['Stance_Defensive'].OnClickLeft = function(self)
		local unit = GetSelectedUnits()
		local _id = unit[1]:GetEntityId()
		SimCallback	({Func= 'OnChangeStance', Args = {id = _id, Stance = 'Defensive'}}) 
	end
	UmUi['Stance_Defensive'].OnClickRight = function(self)
	end
	UmUi['Stance_Offensive'] = UiH.CreateButtonBitmap(UIStances, ModPathIcons..'Stance_Offensive.dds', ModPathIcons..'Stance_Offensive_Selected.dds', 'AtLeftIn', UIStances, 0, 'Below', UIStances, -45)
	UmUi['Stance_Offensive'].OnClickLeft = function(self)
		local unit = GetSelectedUnits()
		local _id = unit[1]:GetEntityId()
		SimCallback	({Func= 'OnChangeStance', Args = {id = _id, Stance = 'Offensive'}}) 
	end
	UmUi['Stance_Offensive'].OnClickRight = function(self)
	end
	UmUi['Stance_Precise'] = UiH.CreateButtonBitmap(UIStances, ModPathIcons..'Stance_Precise.dds', ModPathIcons..'Stance_Precise_Selected.dds', 'AtLeftIn', UIStances, 45, 'Below', UIStances, -45)
	UmUi['Stance_Precise'].OnClickLeft = function(self)
		local unit = GetSelectedUnits()
		local _id = unit[1]:GetEntityId()
		SimCallback	({Func= 'OnChangeStance', Args = {id = _id, Stance = 'Precise'}}) 
	end
	UmUi['Stance_Precise'].OnClickRight = function(self)
	end
	
	-- WeaponUpgrades
	for i = 1, 30 do
		local WeaponSlotId = 'WeaponSlot_'..i
		-- local WeaponSlot = UiH.CreateClickTextWithTooltip(UI, WeaponSlotId, 'AtLeftIn' , UI, 10, 'Below', UI, -740 + (i * 20), 11, nil, 'ffffffaa', 'ff00ff00')
		local WeaponSlot, WeaponSlotText  = UiH.CreateClickTextWithTooltipBox(UnitUi, WeaponSlotId, 'AtLeftIn', UmUi['BaseClass'], 0, 'Below', UmUi['BaseClass'], -170 - (i * 20), 11, nil, 'ffffffaa', 'ff00ff00', ModPath.."Graphics/ProgressBar_Brown75.dds", ModPath.."Graphics/ProgressBar_GreenDark.dds", 150, 20, 5, 2)
		WeaponSlot.WeaponSlot = i
		WeaponSlot.SetTooltip('', '')
		WeaponSlot.OnClickLeft = function(self)	
			local unit = GetSelectedUnits()
			if unit then
				local id = unit[1]:GetEntityId()
				if DM.GetProperty(id,'PrestigeClass') ~= 'NeedPromote' then
					DialogScreen.Show = 1
					DialogScreen.UpgradeType = 'WeaponUpgrade'
					DialogScreen.WeaponIndex = WeaponSlot.WeaponIndex
				end
			end
		end
		WeaponSlot.OnClickRight = function(self)
			DialogScreen.Template = 'WeaponTemplate'
			DialogScreen.WeaponIndex = WeaponSlot.WeaponIndex
			DialogScreen.WeaponCategory = WeaponSlot.WeaponCategory
		end
		UmUi[WeaponSlotId] = WeaponSlot
		UmUi[WeaponSlotId..'Text'] = WeaponSlotText
	end
	
	-- Templates
	local XPos = 160
	local YPos = 25
	for i = 1, 75 do
		if i > 25 then XPos = 260 YPos = 400 end
		if i > 50 then XPos = 360 YPos = 725 end
		local TemplateSlotId = 'TemplateSlot_'..i
		local TemplateSlot, TemplateSlotText  = UiH.CreateClickTextWithTooltipBox(UnitUi, TemplateSlotId, 'AtLeftIn',  UmUi['BaseClass'], XPos, 'Below',  UmUi['BaseClass'], YPos - (i * 15), 11, nil, 'ffffffaa', 'ff00ff00', ModPath.."Graphics/ProgressBar_Brown75.dds", ModPath.."Graphics/ProgressBar_GreenDark.dds", 120, 15, 10, 1)
		TemplateSlot.Slot = i
		TemplateSlot.SetTooltip('', '')
		TemplateSlot.OnClickLeft = function(self)
			local ACUTimer = math.floor(300 - GameTime())
			local unit = GetSelectedUnits()
			if unit then
				local id = unit[1]:GetEntityId()
				local bp = unit[1]:GetBlueprint()
				if table.find(bp.Categories, 'COMMAND') and ACUTimer > 0 then else -- locking ACU templates at game start
					if DM.GetProperty(id,'EcoEventProgress_'..'UpgradingArmor') or DM.GetProperty(id,'EcoEventProgress_'..'UpgradingWeapon') or DM.GetProperty(id,'EcoEventProgress_'..'ApplyingTemplate') then else
						if UmUi['TemplateSlot_'..TemplateSlot.Slot].ClassToPromote then
							DialogScreen.Show = 0
							local _TemplateName = UmUi['TemplateSlot_'..TemplateSlot.Slot].TemplateName
							DialogScreen.Template = ''
							local unit = GetSelectedUnits()
							if (DM.GetProperty('Global'..unit[1]:GetArmy(), 'Logistics', 0) - CF.GetUnitTech(unit[1]) >= 0) or table.find(bp.Categories, 'COMMAND') then
								local _id = unit[1]:GetEntityId()
								local bp = unit[1]:GetBlueprint()
								local UnitLevel, UnitLevelP =  CF.GetUnitLevel(unit[1])
								local PromoteClass =  UmUi['TemplateSlot_'..TemplateSlot.Slot].ClassToPromote
								local CostModifier = PC[PromoteClass].PromoteCostModifier(_id)
								local _MassCost = math.ceil(CF.GetTemplateCost(_id, _TemplateName, UnitGeneralTemplates, PromoteClass) * bp.Economy.BuildCostMass) + math.ceil((100 + math.pow(bp.Economy.BuildCostMass, 0.7) * 30 * (math.pow(0.90, UnitLevel))) * CostModifier)
								local _EnergyCost = math.ceil(CF.GetTemplateCost(_id, _TemplateName, UnitGeneralTemplates, PromoteClass) * bp.Economy.BuildCostEnergy) + math.ceil((500 + math.pow(bp.Economy.BuildCostEnergy, 0.7) * 30 * (math.pow(0.90, UnitLevel))) * CostModifier)
								if table.find(bp.Categories, 'COMMAND') then _EnergyCost = _EnergyCost * 0.01 end
								local UnitCatId = unit[1]:GetUnitId()
								local BaseClass = DM.GetProperty(_id, 'BaseClass')
								local ClToPromote =  UmUi['TemplateSlot_'..TemplateSlot.Slot].ClassToPromote
								SimCallback	({Func='OnChoosePromotion', Args = {id = _id, MassCost = _MassCost, EnergyCost = _EnergyCost, PrestigeClass = PromoteClass, Template = _TemplateName, Modifiers = UnitGeneralTemplates[UnitCatId][BaseClass][PromoteClass][_TemplateName]}})
							end
						elseif UmUi['TemplateSlot_'..TemplateSlot.Slot].TemplateName then
							DialogScreen.Show = 0
							local _TemplateName = UmUi['TemplateSlot_'..TemplateSlot.Slot].TemplateName
							-- LOG(_TemplateName)
							DialogScreen.Template = ''
							local unit = GetSelectedUnits()
							local _id = unit[1]:GetEntityId()
							local bp = unit[1]:GetBlueprint()
							local _MassCost = math.ceil(CF.GetTemplateCost(_id, _TemplateName, UnitGeneralTemplates) * bp.Economy.BuildCostMass)
							local _EnergyCost = math.ceil(CF.GetTemplateCost(_id, _TemplateName, UnitGeneralTemplates) * bp.Economy.BuildCostEnergy)
							if table.find(bp.Categories, 'COMMAND') then _EnergyCost = _EnergyCost * 0.01 end
							local UnitCatId = unit[1]:GetUnitId()
							local BaseClass = DM.GetProperty(_id, 'BaseClass')
							local PrestigeClass = DM.GetProperty(_id, 'PrestigeClass')
							-- LOG(repr(UnitGeneralTemplates[UnitCatId][BaseClass][PrestigeClass][_TemplateName]))
							SimCallback	({Func= 'EcoEvent', Args = {id = _id, EnergyCost = _EnergyCost, MassCost = _MassCost, TimeStress = 5, EventName = 'ApplyingTemplate', TemplateName = _TemplateName, Modifiers = UnitGeneralTemplates[UnitCatId][BaseClass][PrestigeClass][_TemplateName]}})
						end
					end
				end
			end
		end
		TemplateSlot.OnClickRight = function(self)
		end
		UmUi[TemplateSlotId] = TemplateSlot
		UmUi[TemplateSlotId..'Text'] = TemplateSlotText
	end
	
	-- Logistic Points
	UmUi['Logistic'], UmUi['Logistictext']  = UiH.CreateClickTextWithTooltipBox(UnitUi, 'Logistic points :', 'AtLeftIn', UmUi['BaseClass'], 0, 'Below', UmUi['BaseClass'], -130, 11, nil, 'ffffffaa', 'ff00ff00', ModPath.."Graphics/ProgressBar_Brown75.dds", ModPath.."Graphics/ProgressBar_GreenDark.dds", 150, 20, 5, 2)
	UmUi['Logistic'].OnClickLeft = function(self)
		-- local unit = GetSelectedUnits() -- Locked Feature since version 135
		-- local id = unit[1]:GetEntityId()
		-- HallOfHeroes_Dialog(id)
	end
	UmUi['Logistic'].OnClickRight = function(self)
		-- local unit = GetSelectedUnits()  -- Locked Feature since version 135
		-- local id = unit[1]:GetEntityId()
		-- HallOfHeroes_Dialog(id)
	end
	
	-- Landtech Research
	UmUi['LandTech'], UmUi['LandTechtext']  = UiH.CreateClickTextWithTooltipBox(UnitUi, 'Land heroes Research', 'AtLeftIn', UmUi['BaseClass'], 0, 'Below', UmUi['BaseClass'], -160, 11, nil, 'ffffffaa', 'ff00ff00', ModPath.."Graphics/ProgressBar_Brown75.dds", ModPath.."Graphics/ProgressBar_GreenDark.dds", 150, 20, 5, 2)
	UmUi['LandTech'].OnClickLeft = function(self)
		local unit = GetSelectedUnits()
		if unit then
			local id = unit[1]:GetEntityId()
			TechTree_LandsUnits(id)
		end
	end
	UmUi['LandTech'].OnClickRight = function(self)
		local unit = GetSelectedUnits()
		if unit then
			local id = unit[1]:GetEntityId()
			TechTree_LandsUnits(id)
		end
	end

	-- Upgrade infoText
	UmUi['Upgradeinfotext'] = UiH.CreateText(UnitUi, '<<< [ Click to upgrade armor ] ', 'AtLeftIn', UmUi['BaseClass'], 55, 'Below', UmUi['BaseClass'], -105, 11, nil, Color.AEON)
	UmUi['Upgradeinfotext2'] = UiH.CreateText(UnitUi, '<<< [ Click to upgrade weapon ] ', 'AtLeftIn', UmUi['BaseClass'], 155, 'Below', UmUi['BaseClass'], -185, 11, nil, Color.AEON)
	UmUi['Regeninfotext'] = UiH.CreateText(UnitUi, "No enough energy storage or income to regen your hero's capacitors", 'AtLeftIn', UmUi['BaseClass'], 725, 'Below', UmUi['BaseClass'], 112, 11, nil, Color.CYBRAN)
		
	-- Promotion infoText
	UmUi['PromotionLockInfotext1'] = UiH.CreateText(UnitUi, '', 'AtLeftIn', UmUi['BaseClass'], 55, 'Below', UmUi['BaseClass'], -90, 11, nil, Color.CYBRAN)
	UmUi['PromotionLockInfotext2'] = UiH.CreateText(UnitUi, '', 'AtLeftIn', UmUi['BaseClass'], 100, 'Below', UmUi['BaseClass'], -75, 11, nil, Color.CYBRAN)
	UmUi['PromotionLockInfotext1']:DisableHitTest(true)
	UmUi['PromotionLockInfotext2']:DisableHitTest(true)
	UmUi['PromotionChangingDifficultyInfoText'] = UiH.CreateText(UnitUi, 'WARNING : AI difficulty changed to', 'AtLeftIn', parent, 500, 'Below', parent, -600, 18, nil, Color.CYBRAN)
	UmUi['PromotionChangingDifficultyInfoText']:DisableHitTest(true)
	
end

function TickShow()
	local unit = GetSelectedUnits()
	-- Hiding power Boxes
	for i = 1, 80 do
		UmUi['PowerBox_' .. i]:Hide()
	end
	if unit then
		local id = unit[1]:GetEntityId()
		local bp = unit[1]:GetBlueprint()
		
		UnitUi:Show()
		-- Refresh templateUi on changing id
		if id != LastCurrentActiveid then
			TemplateEditing = ''
			DialogScreen.Template = ''
			LastCurrentActiveid = id
		end
		local function ShowPowerBoxes()
			local PowersList = CF.GetUnitPowers(id)
			local len = table.getn(PowersList)
			for i = 1, len do
				UmUi['PowerBox_' .. i]:Show()
			end
		end
		if CF.IsMilitary(unit[1]) then
			local WeaponIndexList = CF.GetWeaponIndexList(unit[1])
			local len = table.getn(WeaponIndexList)
			for i = 1, len do
				-- UmUi['WeaponSlot_' .. i]:Show()
			end
		end
		for _,UiObj in UmUi do
			if UiObj.Refresh then
				UiObj.Refresh(id, UiObj.RefreshArg)
			end
		end
		ShowPowerBoxes()
		local UnitLevel, UnitLevelP =  CF.GetUnitLevel(unit[1])
		if DM.GetProperty(id, 'PrestigeClassPromoted') == 1 and DM.GetProperty(id, 'Military') == true then UIStances:Show() else UIStances:Hide() end 
		if DM.GetProperty(id, 'PrestigeClassPromoted') == 1 then 
			UmUi['PrestigeClassText']:Hide()
			UmUi['PrestigeClassText2']:Hide()
			StaminaHistogram:Show()
			CapacitorHistogram:Show()
			Capacitors_BackG:Show()
			HeroText:Show()
		else
			UmUi['PrestigeClassText']:Show()
			UmUi['PrestigeClassText2']:Show()
			StaminaHistogram:Hide()
			CapacitorHistogram:Hide()
			Capacitors_BackG:Hide()
			HeroText:Hide()
		end
			
		if DM.GetProperty(id,'EcoEventProgress_'..'UpgradingArmor') or DM.GetProperty(id,'EcoEventProgress_'..'UpgradingWeapon') or DM.GetProperty(id,'EcoEventProgress_'..'ApplyingTemplate') then -- blocking Ui upgrades when upgrading
			DialogScreen.Show = 0
		else
			if DialogScreen.Show == 1 and DialogScreen.UpgradeType == 'ArmorUpgrade'  then
				ArmorUpgrades_Dialog(id)
			end
			if DialogScreen.Show == 1 and DialogScreen.UpgradeType == 'WeaponUpgrade'  then
				WeaponUpgrades_Dialog(id)
			end
			if DialogScreen.Show == 1 and DialogScreen.UpgradeType == 'SaveTemplate' then
				ArmorUpgrades_Dialog(id)
			end
		end
		--- Custom refresh functions
		RefreshUnitUi(id)
		RefreshPowers(id)
		RefreshCapacitor(id)
		RefreshArmor(id)
		RefreshWeaponSlots(id)
		RefreshTemplates(id)
		RefreshPromotionBox(id)
		RefreshSpaceAvailable(id)
		RefreshStance(id)
		RefreshLogistic(id)
		RefreshUpgradeHelp(id)
		RefreshLandResearch(id)
		RefreshPromotionLock(id)
		ResfreshAIDifficulty()
		--- Sync buff values to show them in Ui
		AoHBuff.SyncBuffValue(id, 'PowerDamage', 'ALL')
		AoHBuff.SyncBuffValue(id, 'Defense', 'ALL')
		AoHBuff.SyncBuffValue(id, 'Attack', 'ALL')
		AoHBuff.SyncBuffValue(id, 'Damage', 'ALL')
		AoHBuff.SyncBuffValue(id, 'HealthRecovery', 'ALL')
		AoHBuff.SyncBuffValue(id, 'PowerCapacitorRecovery', 'ALL')
		AoHBuff.SyncBuffValue(id, 'WeaponCapacitorRecovery', 'ALL')
		AoHBuff.SyncBuffValue(id, 'ArmorPerc', 'ALL')
		AoHBuff.SyncBuffValue(id, 'Armor', 'ALL')
	else
		Capacitors_BackG:Hide()
		UnitUi:Hide()
		EnhTtipTimer = 2
		UmUi['EnhancedTooltipUi']:Hide()
		UIStances:Hide()
		-- Hiding promote Boxes
		for i = 1, 32 do
			UmUi['TextBox_' .. i]:Hide()
			UmUi['Box_' .. i]:Hide()
		end
	end
end

function ResfreshAIDifficulty()
	if (GameTime() - DM.GetProperty('Global','LastAIDifficultyChange', 0)) < 0 then -- locked feature since mod version 135
		UmUi['PromotionChangingDifficultyInfoText']:SetText('INFO : AI difficulty set to : '..DM.GetProperty('Global','AI_Difficulty', 'Low Trained Imperial Troops'))
	else
		UmUi['PromotionChangingDifficultyInfoText']:SetText('')
		UmUi['PromotionChangingDifficultyInfoText']:Hide()
	end
end



function RefreshUnitUi(id)
	local unit = GetUnitById(id)
	if DM.GetProperty(id, 'PrestigeClassPromoted') ~= 1 then
		UmUi['PrestigeClass']:SetTexture(UIUtil.UIFile(ModPath..'Graphics/Icons/PromoteVoid.dds'))
		if UmUi['PrestigeClass'].OnMouseEnter  then
			UmUi['PrestigeClass']:SetTexture(UIUtil.UIFile(ModPath..'Graphics/Icons/PromoteVoid_OnMouseEnter.dds'))
		end
	else
		local PrestigeClass = DM.GetProperty(id, 'PrestigeClass')
		UmUi['PrestigeClass']:SetTexture(UIUtil.UIFile(ModPath..'Graphics/Icons/'..PrestigeClass..'.dds'))
		if UmUi['PrestigeClass'].OnMouseEnter  then
			UmUi['PrestigeClass']:SetTexture(UIUtil.UIFile(ModPath..'Graphics/Icons/'..PrestigeClass..'.dds'))
		end
	end
	local BaseClass = DM.GetProperty(id, 'BaseClass', 'Fighter')
	UmUi['BaseClass']:SetTexture(UIUtil.UIFile(ModPath..'Graphics/Icons/'..BaseClass..'.dds'))
	-- Unit level
	local UnitLevel, UnitLevelP =  CF.GetUnitLevel(unit)
	UmUi['UnitLevel']:SetText(UnitLevel)
	if UnitLevel >= 10 then
		LayoutHelpers.AtLeftIn(UmUi['UnitLevel'], UnitUi, 28)
	end
	--Dodging chance
	local _, ChanceToDodge = CF.IsDefenseDodge(unit)
	UmUi['DodgeChance']:SetText(ChanceToDodge..' %')
	if ChanceToDodge > 66 then
		UmUi['DodgeChance']:SetColor('ff70ff70')
	elseif ChanceToDodge < 33 then
		UmUi['DodgeChance']:SetColor('ffff7070')
	else
		UmUi['DodgeChance']:SetColor('ffffffaa')
	end
	-- Base Armor Resists
	local BaseArmor = DM.GetProperty(id, 'Tech_Armor', 0) -- effiency bonus
	local Armorlist = {'Light', 'Medium', 'Heavy'}
	for _,Armor in Armorlist do
		if DM.GetProperty(id, 'Upgrade_Armor_'..Armor..' Armor') then
			BaseArmor =  DM.GetProperty(id, 'Upgrade_Armor_'..Armor..' Armor', 0) * (1 + BaseArmor/100)
		end
	end
	local DamageAbsorbtion =  math.min(math.floor(100 * (1 - math.pow(0.9, BaseArmor/10))), 75)
	UmUi['ArmorResist']:SetText(DamageAbsorbtion..' %')
	local percent = math.floor((UnitLevelP - UnitLevel) * 100)
	LevelHistogram.SetValueWidth(percent/100)
end

function RefreshLogistic(id)
	local unit = GetUnitById(id)
	
	UmUi['Logistictext']:SetText('Logistic Points Left :  '..DM.GetProperty('Global'..unit:GetArmy(), 'Logistics', 0))
	-- Locked feature since version 135
	-- if UmUi['Logistic'].OnMouseEnter  then	
		-- EnhTtipTimer = 0
		-- LastTooltipTarget = 'LogisticsUi'
		-- local Tp = {} Tp.Line = {} Tp.Width = 240 Tp.OffSetX = 180 Tp.OffSetY = 40
		-- if DM.GetProperty(id, 'HallofFame_Rank') then
			-- local UnitRank = DM.GetProperty(id, 'HallofFame_Rank', nil)
			-- table.insert(Tp.Line, {'Your unit rank : '..UnitRank,  Color.AEON})
			-- table.insert(Tp.Line, {''})
		-- end
		-- table.insert(Tp.Line, {'[Left Click]  Go to Heroes - Hall of Fame -'})
		-- SetEnhancedTooltip(UmUi['Logistic'], Tp, '', '')
	-- end
end

function RefreshLandResearch(id)
	local unit = GetUnitById(id)
	local bp = unit:GetBlueprint()
	local XP = DM.GetProperty('Global'..unit:GetArmy(), 'LandMobileXP', 0)
	if DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 and table.find(bp.Categories, 'LAND') and table.find(bp.Categories, 'MOBILE') then 
		local TechPointsAvailable =  math.floor(math.floor(XP/250) - DM.GetProperty('Global'..unit:GetArmy(), 'LandMobileXPSpentPoints', 0))
		UmUi['LandTech']:Show()
		UmUi['LandTechtext']:Show()
		UmUi['LandTechtext']:SetText('Heroes tech tree  [ '..TechPointsAvailable..' ]')
	else
		UmUi['LandTech']:Hide()
		UmUi['LandTechtext']:Hide()
	end
	if UmUi['LandTech'].OnMouseEnter  then	
		EnhTtipTimer = 0
		LastTooltipTarget = 'LandTechUi'
		local Tp = {} Tp.Line = {} Tp.Width = 240 Tp.OffSetX = 180 Tp.OffSetY = 40
		table.insert(Tp.Line, {'[Left Click]  Go to Land Units Research'})
		SetEnhancedTooltip(UmUi['LandTech'], Tp, '', '')
	end
end

	
function RefreshPromotionBox(id)
	PromotionUiTimer = PromotionUiTimer + 0.025
	local unit = GetUnitById(id)
	local BoxHitTest = false
	-- Hiding promote Boxes
	for i = 1, 32 do
		UmUi['TextBox_' .. i]:Hide()
		UmUi['Box_' .. i]:Hide()
	end
	local function ShowPromoteBoxes(unit)
		local bp = unit:GetBlueprint()
		local LogisticPoints = 0
		if table.find(bp.Categories, 'STRUCTURE') then 
			LogisticPoints = DM.GetProperty('Global'..unit:GetArmy(), 'Logistics', 0) - CF.GetUnitTech(unit)
		else
			LogisticPoints = DM.GetProperty('Global'..unit:GetArmy(), 'Logistics', 0) - 2 * CF.GetUnitTech(unit)
		end
		local LockingACUPromotion = false
		if GameTime() < 300 and table.find(bp.Categories, 'COMMAND') then LockingACUPromotion = true end
		if LogisticPoints >= 0 and LockingACUPromotion == false then
			local PromoteList = CF.GetAvailablePromoteList(id)
			local len = table.getn(PromoteList)
			UmUi['TextBox_' .. 1]:SetColor('ffffffaa')
			for i = 1, len do
				UmUi['TextBox_' .. i]:Show()
				UmUi['Box_' .. i]:Show()
				if 	UmUi['Box_' .. i].OnMouseEnter == true then BoxHitTest = true end
			end
		else
			if LockingACUPromotion == false then
				PromoteList = {}
				UmUi['TextBox_' .. 1]:Show()
				UmUi['TextBox_' .. 1]:SetColor('ffff7070')
				UmUi['TextBox_' .. 1]:SetText("You don't have enough logistic points")
			else
				local PromotingCostTimeLock =  math.floor(300 - GameTime())
				UmUi['TextBox_' .. 1]:Show()
				UmUi['TextBox_' .. 1]:SetColor('ffff7070')
				UmUi['TextBox_' .. 1]:SetText("ACU Promotion will be unlocked in "..PromotingCostTimeLock.." s")
			end
		end
	end
	if PromotionUiTimer < 0.5 then
		if DM.GetProperty(id,'EcoEventProgress_'..'Promoting') then else
			if DM.GetProperty(id,'PrestigeClass') == 'NeedPromote' and DM.GetProperty(id, 'IsBuilt', false) then ShowPromoteBoxes(unit) end
		end
	end
	if UmUi['PrestigeClass'].OnMouseEnter == true or BoxHitTest == true then PromotionUiTimer = 0 end
	if DM.GetProperty(id,'EcoEventProgress_'..'Promoting') then
		UmUi['PrestigeClassText']:SetText('Promoting')
		UmUi['PrestigeClassText2']:SetText(math.min(math.ceil(DM.GetProperty(id,'EcoEventProgress_'..'Promoting', 0) * 0.1), 100)..' %')
	else
		if DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 then
			UmUi['PrestigeClassText']:SetText('')
			UmUi['PrestigeClassText2']:SetText('')
		else
			UmUi['PrestigeClassText']:SetText('  CREATE')
			UmUi['PrestigeClassText2']:SetText('HERO')
		end
	end
end

function RefreshUpgradeHelp(id)
	local unit = GetUnitById(id)
	local SpaceUsed = CF.GetSpaceUsedByWeapons(unit) + CF.GetSpaceUsedByArmor(unit)
	local MaxSpace = CF.GetAvailableMaxSpace(unit)
	local MaxSpace = CF.GetAvailableMaxSpace(unit)
	local SpaceAv = MaxSpace - SpaceUsed
	if DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 and SpaceAv > 20 and EnhTtipTimer > 2 then 
		UmUi['Upgradeinfotext']:Show()
		UmUi['Upgradeinfotext2']:Show()
	else
		UmUi['Upgradeinfotext']:Hide()
		UmUi['Upgradeinfotext2']:Hide()
	end
	local econData = GetEconomyTotals()
	local bp = unit:GetBlueprint()
	if DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 and econData.stored.ENERGY <= (4000 + bp.Economy.BuildCostMass) then
		UmUi['Regeninfotext']:Show()
	else
		UmUi['Regeninfotext']:Hide()
	end
	
end

function RefreshPromotionLock(id)
	local unit = GetUnitById(id)
	local bp = unit:GetBlueprint()
	local PromotingCostTimeLock =  math.floor(300 - GameTime())
	local PromotingCostMalus =  math.max(4 - (GameTime()/100), 1)
	PromotingCostMalus = string.format("%.2f", PromotingCostMalus, Color.CYBRAN)
	if table.find(bp.Categories, 'COMMAND') and PromotingCostTimeLock > 0 and EnhTtipTimer > 5 then
		UmUi['PromotionLockInfotext1']:Show()
		UmUi['PromotionLockInfotext1']:SetText('ACU Promotion unlocked in ')
		UmUi['PromotionLockInfotext2']:Show()
		UmUi['PromotionLockInfotext2']:SetText(PromotingCostTimeLock..' s')
	elseif (not table.find(bp.Categories, 'COMMAND')) and PromotingCostTimeLock > 0 and DM.GetProperty(id, 'PrestigeClassPromoted') != 1 and DM.GetProperty(id, 'Military') == true and EnhTtipTimer > 5 then
		UmUi['PromotionLockInfotext1']:Show()
		UmUi['PromotionLockInfotext1']:SetText('Promotion cost starting Malus ')
		UmUi['PromotionLockInfotext2']:Show()
		UmUi['PromotionLockInfotext2']:SetText(PromotingCostMalus..'x')
	else
		UmUi['PromotionLockInfotext1']:SetText('')
		UmUi['PromotionLockInfotext1']:Hide()
		UmUi['PromotionLockInfotext2']:SetText('')
		UmUi['PromotionLockInfotext2']:Hide()
	end
end

function RefreshSpaceAvailable(id)
	TemplateUiTimer = TemplateUiTimer + 0.075
	if id and DM.GetProperty(id, 'PrestigeClassPromoted') == 1 then 
		local unit = GetUnitById(id)
		local bp = unit:GetBlueprint()
		UiSpaceAvailableText:Show()
		UiSpaceAvailable:Show()
		local SpaceUsed = CF.GetSpaceUsedByWeapons(unit) + CF.GetSpaceUsedByArmor(unit)
		local MaxSpace = CF.GetAvailableMaxSpace(unit)
		local UpgradingProgress = ''
		if DM.GetProperty(id, 'Unit_TemplateName') then 
			UiSpaceAvailableText:SetText(DM.GetProperty(id, 'Unit_TemplateName')..'  '..SpaceUsed..' / '..MaxSpace)
		else
			UiSpaceAvailableText:SetText('No Template : '..SpaceUsed..' / '..MaxSpace)
		end
		if DM.GetProperty(id, 'EcoEventProgress_ApplyingTemplate') then
			UiSpaceAvailableText:SetText('Upgrading to template ['..math.ceil(DM.GetProperty(id, 'EcoEventProgress_ApplyingTemplate') * 0.1)..' %]')
		end
		if UiSpaceAvailable.OnMouseEnter == true then
			DialogScreen.Template = 'Template'
			TemplateUiTimer = 0
		end
		if TemplateUiTimer > 1 then 
			TemplateEditing = ''
			DialogScreen.Template = ''
		end
	else
		UiSpaceAvailableText:Hide()
		UiSpaceAvailable:Hide()
	end
end

function RefreshWeaponSlots(id)
	local unit = GetUnitById(id)
	local bp = unit:GetBlueprint()
	for i = 1, 30 do
		UmUi['WeaponSlot_'..i]:Hide()
		UmUi['WeaponSlot_'..i..'Text']:Hide()
	end
	if CF.IsMilitary(unit) and DM.GetProperty(id, 'PrestigeClassPromoted') == 1 then 
		local mindamagemod = 1 - (math.pow(0.9, (DM.GetProperty(id, 'Dexterity', 0) - 20)/5) * 0.35)
		local WeaponIndexList, WeaponCategoriesList = CF.GetWeaponIndexList(unit)
		local len = table.getn(WeaponIndexList)
		for i, wi in WeaponIndexList do
			local CheckRangeBonus = false
			local RangeHillBonus = DM.GetProperty(id, 'RangeHillBonus'..'_Weapon_'..wi, 0)
			if not table.find(bp.Categories, 'AIR') or not table.find(bp.Categories, 'NAVAL') or not table.find(bp.Categories, 'HIGHALTAIR') then
				CheckRangeBonus = true
			end
			local lenm = 1 -- number of Muzzles 
			if UmUi['WeaponSlot_' .. i].OnMouseEnter == true then
				LastWeaponOnMouseEnter = wi
				DialogScreen.WeaponIndex = wi
				DialogScreen.WeaponCategory = WeaponCategoriesList[i]
				local Tp = {} Tp.Line = {} Tp.Width = 340 Tp.OffSetX = 180 Tp.OffSetY = -20
				table.insert(Tp.Line, {'Weapons stats'})
				table.insert(Tp.Line, {'  '..bp.Weapon[WeaponIndexList[i]].WeaponCategory, Color.PURPLE})
				local MinRadius = bp.Weapon[WeaponIndexList[i]].MinRadius or 0
				local MaxRadius = bp.Weapon[WeaponIndexList[i]].MaxRadius or 0
				table.insert(Tp.Line, {'  Range  : '..MinRadius..' - '..MaxRadius, Color.GREY_LIGHT})
				local distfromtarget = DM.GetProperty(id, 'DistanceFromTarget'..'_Weapon_'..wi) or 'No Target'
				local AttackRatingUpgrade = DM.GetProperty(id, 'Upgrade_Weapon_'..wi..'_Attack Rating') or 0
				if distfromtarget != 'No Target' then
					table.insert(Tp.Line, {''})
					table.insert(Tp.Line, {'Target'})
					local DamageRadius = bp.Weapon[WeaponIndexList[i]].DamageRadius or 0
					local AttackRating = (CF.GetAttackRating(unit) + AttackRatingUpgrade) * math.pow(0.75, distfromtarget / 10) * (math.pow(DamageRadius, 0.2) + 1)
					table.insert(Tp.Line, {'  '..'Attack Rating : '..math.ceil(AttackRating), Color.WHITE})
					if DM.GetProperty(id, 'Accuracy'..'_Weapon_'..wi) then
						table.insert(Tp.Line, {'  '..'Accuracy : '..math.ceil(DM.GetProperty(id, 'Accuracy'..'_Weapon_'..wi))..' %', Color.WHITE})
					end
				end
				table.insert(Tp.Line, {''})
				table.insert(Tp.Line, {'Damage stats  : '})
				local projtype = 'Projectile'
				if bp.Weapon[WeaponIndexList[i]].ContinuousBeam then
					projtype = 'Continuous Beam'
				end
				if bp.Weapon[WeaponIndexList[i]].Damage > 200 then
					table.insert(Tp.Line, {'  '..projtype..' base damage  : '..bp.Weapon[WeaponIndexList[i]].Damage, Color.AEON})
				elseif bp.Weapon[WeaponIndexList[i]].Damage >= 100 then
					table.insert(Tp.Line, {'  '..projtype..' base damage  : '..bp.Weapon[WeaponIndexList[i]].Damage, Color.GREY_LIGHT})
				else
					table.insert(Tp.Line, {'  '..projtype..' base damage  : '..bp.Weapon[WeaponIndexList[i]].Damage, Color.CYBRAN})
				end
				local DamageBuff = math.ceil(CF.GetDamageRating(unit) * 100) + DM.GetProperty(id, 'Buff_Damage_ALL_Add', 0)
				if DamageBuff >= 0 then
					table.insert(Tp.Line, {'  '..'Damage bonus : +'..DamageBuff..' %', Color.AEON})
				else
					table.insert(Tp.Line, {'  '..'Damage bonus : '..DamageBuff..' %', Color.CYBRAN})
				end
				local DamageClassMod = 1
				
				local BaseClass =  DM.GetProperty(id, 'BaseClass', 'Fighter')
				local PrestigeClass = DM.GetProperty(id, 'PrestigeClass')
				if DM.GetProperty(id,'PrestigeClassPromoted') == 1 and DM.GetProperty(id, 'Stamina') > 5 then
					DamageClassMod = BCbp[BaseClass]['DamagePromotionModifier'] * 100
					if bp.Weapon[WeaponIndexList[i]].DisplayName == 'Heavy Microwave Laser' then
						DamageClassMod = -50
						table.insert(Tp.Line, {'  '..'Beam Instability Malus : '..DamageClassMod..' %', Color.CYBRAN})
					else
						table.insert(Tp.Line, {'  '..'Weapon Capacitor Damage bonus : +'..DamageClassMod..' %', Color.AEON})
					end
				end
				if bp.Weapon[WeaponIndexList[i]].ProjectilesPerOnFire and bp.Weapon[WeaponIndexList[i]].ProjectilesPerOnFire > 1 then
					table.insert(Tp.Line, {'    x '..bp.Weapon[WeaponIndexList[i]].ProjectilesPerOnFire ..' projectiles', Color.AEON})
				end
				if bp.Weapon[WeaponIndexList[i]].RackBones[1].MuzzleBones then
					lenm = table.getn(bp.Weapon[WeaponIndexList[i]].RackBones[1].MuzzleBones)
					if lenm > 1 then table.insert(Tp.Line, {'    x '..lenm..' muzzles', Color.AEON}) end
				end
				if bp.Weapon[WeaponIndexList[i]].MuzzleSalvoSize and bp.Weapon[WeaponIndexList[i]].MuzzleSalvoSize > 1 then
					table.insert(Tp.Line, {'    x '..bp.Weapon[WeaponIndexList[i]].MuzzleSalvoSize..' (salvo size) every '..math.floor(1/bp.Weapon[WeaponIndexList[i]].MuzzleSalvoDelay)..' s', Color.AEON})
				end
				if bp.Weapon[WeaponIndexList[i]].DamageRadius > 0 then
					table.insert(Tp.Line, {'  Damage Radius  : '..string.format("%.2f", bp.Weapon[WeaponIndexList[i]].DamageRadius), Color.AEON})
				else
					table.insert(Tp.Line, {'  Damage Radius  : '..string.format("%.2f", bp.Weapon[WeaponIndexList[i]].DamageRadius), Color.GREY_LIGHT})
				end
				if bp.Weapon[WeaponIndexList[i]].RateOfFire > 2 then
					table.insert(Tp.Line, {'  Rate of Fire  : '..string.format("%.2f", bp.Weapon[WeaponIndexList[i]].RateOfFire)..' / s', Color.AEON})
				elseif bp.Weapon[WeaponIndexList[i]].RateOfFire >= 1 then 
					table.insert(Tp.Line, {'  Rate of Fire  : '..string.format("%.2f", bp.Weapon[WeaponIndexList[i]].RateOfFire)..' / s', Color.GREY_LIGHT})
				else
					table.insert(Tp.Line, {'  Rate of Fire  : '..string.format("%.2f", bp.Weapon[WeaponIndexList[i]].RateOfFire)..' / s', Color.CYBRAN})
				end
				table.insert(Tp.Line, {''})
				table.insert(Tp.Line, {'Upgrades  : '})
				local UpgradeSpotted = false
				for si, modifier in WeaponModifiers.RefView do
					if DM.GetProperty(id, 'Upgrade_Weapon_'..wi..'_'..modifier) then
						UpgradeSpotted = true
						table.insert(Tp.Line, {'  '..modifier..' +'..math.ceil(DM.GetProperty(id, 'Upgrade_Weapon_'..wi..'_'..modifier))..WeaponModifiers.GetSuffix(modifier), Color.AEON})
					end
				end
				if UpgradeSpotted == false then table.insert(Tp.Line, {'  No upgrade detected', Color.CYBRAN}) end
				table.insert(Tp.Line, {''})
				if PrestigeClass == 'NeedPromote' then
					table.insert(Tp.Line, {'Promote your unit to upgrade your weapon !'})
				else
					table.insert(Tp.Line, {'[Left Click] to upgrade your weapon', Color.WHITE})
				end
				SetEnhancedTooltip(UmUi['WeaponSlot_' .. i], Tp, '', '')
			end
			local UpgradeDpsBonus = 1 + (DM.GetProperty(id, 'Upgrade_Weapon_'..wi..'_Damage to All Units', 0) / 100) + (DM.GetProperty(id, 'Upgrade_Weapon_'..wi..'_Rate Of Fire', 0) / 100)
			UmUi['WeaponSlot_'..i]:Show()
			UmUi['WeaponSlot_'..i..'Text']:Show()
			local UpgradingProgress = ''
			if DM.GetProperty(id,'EcoEventProgress_UpgradingWeapon') then 
				UpgradingProgress = UpgradingProgress..' ['..math.ceil(DM.GetProperty(id,'EcoEventProgress_UpgradingWeapon') * 0.1)..' %]' 
			end
			if bp.Weapon[WeaponIndexList[i]].WeaponCategory == 'Direct Fire' then
				if CheckRangeBonus == true and RangeHillBonus > 0 then
					local wptext = bp.Weapon[WeaponIndexList[i]].DisplayName..TemplateEditing
					local post = ''
					if string.len(wptext) > 15 then post = '.' end
					wptext = string.sub(wptext, 1, 15)..post
					UmUi['WeaponSlot_'..i..'Text']:SetText(wptext..' R.+'..RangeHillBonus..' '..UpgradingProgress)
				else
					local wptext = bp.Weapon[WeaponIndexList[i]].DisplayName..TemplateEditing
					local post = ''
					if string.len(wptext) > 15 then post = '.' end
					wptext = string.sub(wptext, 1, 15)..post
					UmUi['WeaponSlot_'..i..'Text']:SetText(wptext..' '..UpgradingProgress)
				end
			else
				if CheckRangeBonus == true and RangeHillBonus > 0 then
					local wptext = bp.Weapon[WeaponIndexList[i]].DisplayName..TemplateEditing
					local post = ''
					if string.len(wptext) > 15 then post = '.' end
					wptext = string.sub(wptext, 1, 15)..post
					UmUi['WeaponSlot_'..i..'Text']:SetText(wptext..' R.+'..RangeHillBonus..' '..UpgradingProgress)
				else
					local wptext = bp.Weapon[WeaponIndexList[i]].DisplayName..TemplateEditing
					local post = ''
					if string.len(wptext) > 15 then post = '.' end
					wptext = string.sub(wptext, 1, 15)..post
					UmUi['WeaponSlot_'..i..'Text']:SetText(wptext..' '..UpgradingProgress)
				end
			end
			UmUi['WeaponSlot_' .. i].WeaponIndex = wi
			UmUi['WeaponSlot_' .. i].WeaponCategory = WeaponCategoriesList[i]
		end
	else
	end
end

function RefreshTemplates(id)
	local unit = GetUnitById(id)
	local bp = unit:GetBlueprint()
	local UnitCatId = unit:GetUnitId()
	local UnitLevel, UnitLevelP =  CF.GetUnitLevel(unit)
	local BaseClass = DM.GetProperty(id, 'BaseClass', 'Fighter')
	local AvailableTemplateList = {}
	local PrestigeClassList = {}
	local CostModifier = 0
	if UnitGeneralTemplates[UnitCatId] then
		if DM.GetProperty(id, 'PrestigeClassPromoted') == 1 then
			AvailableTemplateList = CF.GetGeneralTemplateList(unit, UnitGeneralTemplates[UnitCatId])
		elseif DM.GetProperty(id,'EcoEventProgress_'..'Promoting') == nil then
			AvailableTemplateList, PrestigeClassList = CF.GetPromotionTemplateList(unit, UnitGeneralTemplates[UnitCatId])
		end
	end
	for i = 1, 75 do
		UmUi['TemplateSlot_'..i]:Hide()
		UmUi['TemplateSlot_'..i..'Text']:Hide()
		if AvailableTemplateList[i] then
			UmUi['TemplateSlot_'..i].TemplateName = AvailableTemplateList[i]
			UmUi['TemplateSlot_'..i].ClassToPromote = PrestigeClassList[i]
		end
		if UmUi['TemplateSlot_'..i].OnMouseEnter == true and DM.GetProperty(id,'EcoEventProgress_'..'Promoting') == nil and DM.GetProperty(id, 'PrestigeClassPromoted') == nil then	
			local templatename = AvailableTemplateList[i]
			local PrestigeClass = ''
			PrestigeClass = PrestigeClassList[i]
			CostModifier = PC[PrestigeClass].PromoteCostModifier(id)
			local PromotingCostMalus =  math.max(4 - (GameTime()/100), 1)
			local MassCost = math.ceil(CF.GetTemplateCost(id, templatename, UnitGeneralTemplates, PrestigeClass) * bp.Economy.BuildCostMass) + math.ceil((100 + math.pow(bp.Economy.BuildCostMass, 0.7) * 30 * (math.pow(0.90, UnitLevel))) * CostModifier * PromotingCostMalus)
			local EnergyCost = math.ceil(CF.GetTemplateCost(id, templatename, UnitGeneralTemplates, PrestigeClass) * bp.Economy.BuildCostEnergy) + math.ceil((500 + math.pow(bp.Economy.BuildCostEnergy, 0.7) * 30 * (math.pow(0.90, UnitLevel))) * CostModifier * PromotingCostMalus)
			if table.find(bp.Categories, 'COMMAND') then EnergyCost = math.ceil(EnergyCost * 0.01) end
			DialogScreen.Template = 'Template'
			local Tp = {} Tp.Line = {} Tp.Width = 390 Tp.OffSetX = 130 Tp.OffSetY = -40
			table.insert(Tp.Line, {'[Left Click] to Promote & upgrade by using template'})
			table.insert(Tp.Line, {'  Template name : '..templatename, Color.YELLOW1})
			table.insert(Tp.Line, {''})
			table.insert(Tp.Line, {'Will promote to : '..PrestigeClass, Color.WHITE})
			table.insert(Tp.Line, {'  Mass Cost : '..MassCost, Color.CYBRAN})
			table.insert(Tp.Line, {'  Energy Cost : '..EnergyCost, Color.CYBRAN})
			table.insert(Tp.Line, {''})
			table.insert(Tp.Line, {'Will add theses upgrades : ', Color.WHITE})
			local Modifiers = UnitGeneralTemplates[UnitCatId][BaseClass][PrestigeClass][templatename]
			local TrainingWeight = {'Puissance', 'Dexterity', 'Hull', 'Intelligence', 'Energy'}
			for _, modifier in ArmorModifiers.RefView do
				for mod, value in Modifiers do
					local _mod = mod
					_mod = string.gsub(_mod, 'Upgrade_Armor_', '') 
					_mod = string.gsub(_mod, '_Level', '') 
					_mod = string.gsub(_mod, '_', ' ') 
					if modifier == _mod then
						local InternalKay = ArmorModifiers.GetInternalKey(modifier)
						local _value = math.ceil(ArmorModifiers.Modifiers[InternalKay].Calculate(id) * value)
						table.insert(Tp.Line, {'  '.._mod..' '..ArmorModifiers.GetPrefix(modifier).._value..ArmorModifiers.GetSuffix(modifier), Color.AEON})
					end
				end
			end
			for _, modifier in WeaponModifiers.RefView do
				for mod, value in Modifiers do
					local _mod = mod
					local WeaponIndex = 1
					if value < 10 then
						WeaponIndex = string.sub(_mod, 16, 16)
						_mod = string.sub(_mod, 18) 
					else
						WeaponIndex = string.sub(_mod, 16, 17)
						_mod = string.sub(_mod, 19) 
					end
					_mod = string.gsub(_mod, 'Upgrade_Weapon_', '')
					_mod = string.gsub(_mod, '_Level', '') 
					_mod = string.gsub(_mod, '_', ' ')
					if modifier == _mod then
						local InternalKay = WeaponModifiers.GetInternalKey(modifier)
						local _value = math.ceil(WeaponModifiers.Modifiers[InternalKay].Calculate(id) * value)
						local WeaponName = bp.Weapon[tonumber(WeaponIndex)].DisplayName or ''
						table.insert(Tp.Line, {'  '..WeaponName..' : '.._mod..' '..WeaponModifiers.GetPrefix(modifier).._value..WeaponModifiers.GetSuffix(modifier), Color.AEON})
					end
				end
			end
			EnhTtipTimer = 0
			LastTooltipTarget = 'TemplateSlot_'..i
			if EnhTtipTimer < 1 and LastTooltipTarget ==  'TemplateSlot_'..i then
				SetEnhancedTooltip(UmUi['TemplateSlot_'..i], Tp, '', '')
			end
		elseif UmUi['TemplateSlot_'..i].OnMouseEnter == true and DM.GetProperty(id, 'PrestigeClassPromoted') == 1 and AvailableTemplateList[i] then
			local PrestigeClass = DM.GetProperty(id, 'PrestigeClass')
			local templatename = AvailableTemplateList[i]
			local MassCost = math.ceil(CF.GetTemplateCost(id, templatename, UnitGeneralTemplates) * bp.Economy.BuildCostMass)
			local EnergyCost = math.ceil(CF.GetTemplateCost(id, templatename, UnitGeneralTemplates) * bp.Economy.BuildCostEnergy)
			if table.find(bp.Categories, 'COMMAND') then EnergyCost = math.ceil(EnergyCost * 0.01) end
			DialogScreen.Template = 'Template'
			local Tp = {} Tp.Line = {} Tp.Width = 390 Tp.OffSetX = 100 Tp.OffSetY = -40
			table.insert(Tp.Line, {'[Left Click] to upgrade by using template'})
			table.insert(Tp.Line, {'Template name : '..templatename, Color.YELLOW1})
			table.insert(Tp.Line, {'  Mass Cost : '..MassCost, Color.CYBRAN})
			table.insert(Tp.Line, {'  Energy Cost : '..EnergyCost, Color.CYBRAN})
			table.insert(Tp.Line, {''})
			table.insert(Tp.Line, {'Will equip with theses upgrades : ', Color.WHITE})
			local Modifiers = UnitGeneralTemplates[UnitCatId][BaseClass][PrestigeClass][templatename]
			local TrainingWeight = {'Puissance', 'Dexterity', 'Hull', 'Intelligence', 'Energy'}
			for _, modifier in ArmorModifiers.RefView do
				for mod, value in Modifiers do
					local _mod = mod
					_mod = string.gsub(_mod, 'Upgrade_Armor_', '') 
					_mod = string.gsub(_mod, '_Level', '') 
					_mod = string.gsub(_mod, '_', ' ') 
					if modifier == _mod then
						local InternalKay = ArmorModifiers.GetInternalKey(modifier)
						local _value = math.ceil(ArmorModifiers.Modifiers[InternalKay].Calculate(id) * value)
						table.insert(Tp.Line, {'  '.._mod..' '..ArmorModifiers.GetPrefix(modifier).._value..ArmorModifiers.GetSuffix(modifier), Color.AEON})
					end
				end
			end
			for _, modifier in WeaponModifiers.RefView do
				for mod, value in Modifiers do
					local _mod = mod
					local WeaponIndex = 0
					if value < 10 then
						WeaponIndex = string.sub(_mod, 16, 16)
						_mod = string.sub(_mod, 18) 
					else
						WeaponIndex = string.sub(_mod, 16, 17)
						_mod = string.sub(_mod, 19) 
					end
					_mod = string.gsub(_mod, 'Upgrade_Weapon_', '')
					_mod = string.gsub(_mod, '_Level', '') 
					_mod = string.gsub(_mod, '_', ' ')
					if modifier == _mod then
						local InternalKay = WeaponModifiers.GetInternalKey(modifier)
						local _value = math.ceil(WeaponModifiers.Modifiers[InternalKay].Calculate(id) * value)
						local WeaponName = bp.Weapon[tonumber(WeaponIndex)].DisplayName or ''
						table.insert(Tp.Line, {'  '..WeaponName..' : '.._mod..' '..WeaponModifiers.GetPrefix(modifier).._value..WeaponModifiers.GetSuffix(modifier), Color.AEON})
					end
				end
			end
			EnhTtipTimer = 0
			LastTooltipTarget = 'TemplateSlot_'..i
			if EnhTtipTimer < 1 and LastTooltipTarget ==  'TemplateSlot_'..i then
				SetEnhancedTooltip(UmUi['TemplateSlot_'..i], Tp, '', '')
			end
		end
	end
	if DialogScreen.Template == 'Template' and DM.GetProperty(id, 'PrestigeClassPromoted') == 1 then
		for i, template in AvailableTemplateList do
			UmUi['TemplateSlot_'..i]:Show()
			UmUi['TemplateSlot_'..i..'Text']:Show()
			UmUi['TemplateSlot_'..i].SetText(template)
		end
	elseif DialogScreen.Template == 'Template'  then
		for i, template in AvailableTemplateList do
			UmUi['TemplateSlot_'..i]:Show()
			UmUi['TemplateSlot_'..i..'Text']:Show()
			UmUi['TemplateSlot_'..i].SetText('['..string.sub(PrestigeClassList[i], 1, 2)..'] '..template)
		end
	end
end

function RefreshPowers(_id)
	if LockTimer == false then EnhTtipTimer = EnhTtipTimer + 0.1 end
	local PowersList = CF.GetUnitPowers(_id)
	local len = table.getn(PowersList)
	local unit = GetUnitById(_id)
	UmUi['EnhancedTooltipUi']:Hide()
	for i = 1, len do
		for _, power in Powers do
			if power.Name() == PowersList[i] then	
				local PowerBoxUI = UmUi['PowerBox_'..i]
				PowerBoxUI.Name = power.Name()
				local Power = CF.GetUnitPower(_id, power.Name())
				UmUi['PowerBoxText_'..i]:SetText(Power.ReCastTime(unit))
				if PowerBoxUI.OnMouseEnter == true then
					SetEnhancedTooltip(PowerBoxUI, Power.Description(unit), power.Name(), _id)
					EnhTtipTimer = 0
					LastTooltipTarget = 'PowerUi'..i
				end
				if EnhTtipTimer < 1 and LastTooltipTarget == 'PowerUi'..i then
					SetEnhancedTooltip(PowerBoxUI, Power.Description(unit), power.Name(), _id)
				end
				if DM.GetProperty(_id, 'CastTime_'..power.Name()) or Power.CanCast(unit) == false then
					PowerBoxUI:SetTexture(power.IconPathBusy)
				elseif PowerBoxUI.OnMouseEnter == true then
					PowerBoxUI:SetTexture(power.IconPathSelected)
				else
					PowerBoxUI:SetTexture(power.IconPathReady)
				end
				PowerBoxUI.OnClickLeft = function(self)
					local PowerName = PowerBoxUI.Name
					local Power = CF.GetUnitPower(_id, PowerName)
					local unit = GetUnitById(_id)
					if Power.CanCast(unit) == true then
						SimCallback	({Func= 'CallPower', Args = {id = _id, PowerName = PowerBoxUI.Name}})
					end
				end
				PowerBoxUI.OnClickRight = function(self)
					local PowerName = PowerBoxUI.Name
					if PowerName == 'Engineers Consolidation' then
						EngineerConsolidationBonus_Dialog(_id)
					else	
						if DM.GetProperty(_id, PowerName..'_AutoCast') then
							SimCallback	({Func= 'SetAutoCast', Args = {id = _id, PowerName = PowerBoxUI.Name, Value = nil}})
						else
							SimCallback	({Func= 'SetAutoCast', Args = {id = _id, PowerName = PowerBoxUI.Name, Value = 1}})
						end
					end
				end
			end
		end
	end
end

function RefreshPromotion(id)
	local unit = GetSelectedUnits()
	local PromoteList = CF.GetAvailablePromoteList(id)
	if DM.GetProperty('Global'..unit[1]:GetArmy(), 'Logistics', 0) - CF.GetUnitTech(unit[1]) >= 0 then
		local len = table.getn(PromoteList)
		for i = 1, len do
			UmUi['TextBox_' .. i]:SetText(PromoteList[i])
		end
	else
		PromoteList = {}
		UmUi['TextBox_' .. 1]:SetText("You don't have any logistic points left")
	end
end

function RefreshStance(id)
	local unit = GetUnitById(id)
	local Stance = DM.GetProperty(id,'StanceState')
	local Stances = {'Normal', 'Offensive', 'Defensive', 'Precise'}
	for _, _Stance in Stances do
		UmUi['Stance_'.._Stance]:SetTexture(UIUtil.UIFile( ModPathIcons..'Stance_'.._Stance..'_Busy.dds'))
		if Stance == _Stance then
			UmUi['Stance_'.._Stance]:SetTexture(UIUtil.UIFile( ModPathIcons..'Stance_'.._Stance..'.dds'))
		end
		if UmUi['Stance_'.._Stance].OnMouseEnter then
			UmUi['Stance_'.._Stance]:SetTexture(UIUtil.UIFile( ModPathIcons..'Stance_'.._Stance..'_Selected.dds'))
			local Tp = {} Tp.Line = {} Tp.Width = 205 Tp.OffSetX = 0 Tp.OffSetY = -50
			table.insert(Tp.Line, {_Stance..' stance'})
			table.insert(Tp.Line, {'Stance Rank : '..CF.GetStanceRank(unit, _Stance), Color.WHITE})
			local COLOR = Color.AEON
			local PowerModifier = math.ceil(CF.GetStanceModifier(unit, 'PowerStrengh_Mod', _Stance) * 100) - 100
			if PowerModifier ~= 0 then
				local Modifier = ''
				if PowerModifier > 0 then Modifier = '+' COLOR =  Color.AEON else  COLOR =  Color.CYBRAN end
				table.insert(Tp.Line, {'Power : '..Modifier..PowerModifier..' %', COLOR})
			end
			PowerModifier = math.ceil(CF.GetStanceModifier(unit, 'Damage_Mod', _Stance) * 100) - 100
			if PowerModifier ~= 0 then
				local Modifier = ''
				if PowerModifier > 0 then Modifier = '+' COLOR =  Color.AEON else COLOR =  Color.CYBRAN end
				table.insert(Tp.Line, {'Damage : '..Modifier..PowerModifier..' %',COLOR})
			end
			PowerModifier = math.ceil(CF.GetStanceModifier(unit, 'RateOfFire_Mod', _Stance) * 100) - 100
			if PowerModifier ~= 0 then
				local Modifier = ''
				if PowerModifier > 0 then Modifier = '+' COLOR =  Color.AEON else  COLOR =  Color.CYBRAN end
				table.insert(Tp.Line, {'Rate of Fire : '..Modifier..PowerModifier..' %', COLOR})
			end
			PowerModifier = math.ceil(CF.GetStanceModifier(unit, 'Attack_Mod', _Stance) * 100) - 100
			if PowerModifier ~= 0 then
				local Modifier = ''
				if PowerModifier > 0 then Modifier = '+' COLOR =  Color.AEON else  COLOR =  Color.CYBRAN end
				table.insert(Tp.Line, {'Attack Rating : '..Modifier..PowerModifier..' %', COLOR})
			end
			PowerModifier = math.ceil(CF.GetStanceModifier(unit, 'Defense_Mod', _Stance) * 100) - 100
			if PowerModifier ~= 0 then
				local Modifier = ''
				if PowerModifier > 0 then Modifier = '+' COLOR =  Color.AEON else  COLOR =  Color.CYBRAN end
				table.insert(Tp.Line, {'Defense Rating : '..Modifier..PowerModifier..' %', COLOR})
			end
			PowerModifier = math.ceil(CF.GetStanceModifier(unit, 'StaminaRegen_Mod', _Stance) * 100) - 100
			if PowerModifier ~= 0 then
				local Modifier = ''
				if PowerModifier > 0 then Modifier = '+' COLOR =  Color.AEON else  COLOR =  Color.CYBRAN end
				table.insert(Tp.Line, {'Weapon Cap Regen rate : '..Modifier..PowerModifier..' %', COLOR})
			end
			PowerModifier = math.ceil(CF.GetStanceModifier(unit, 'Move_Mod', _Stance) * 100) - 100
			if PowerModifier ~= 0 then
				local Modifier = ''
				if PowerModifier > 0 then Modifier = '+' COLOR =  Color.AEON else  COLOR =  Color.CYBRAN end
				table.insert(Tp.Line, {'Moving speed : '..Modifier..PowerModifier..' %', COLOR})
			end
			PowerModifier = math.ceil(CF.GetStanceModifier(unit, 'Plasma_Resist', _Stance) * 100) - 100
			if PowerModifier ~= 0 then
				local Modifier = ''
				if PowerModifier > 0 then Modifier = '+' COLOR =  Color.CYBRAN else  COLOR =  Color.AEON end
				table.insert(Tp.Line, {'[ Resist ] Plasma : '..Modifier..PowerModifier..' %', COLOR})
			end
			SetEnhancedTooltip(UmUi['Stance_'.._Stance], Tp, '', '')
		end
	end
end

function RefreshCapacitor(id, PropertyName)
	local unit = GetUnitById(id)
	local bp = unit:GetBlueprint()
	local WeaponCapStanceMod = CF.GetStanceModifier(unit,  'StaminaRegen_Mod')
	local Hull = DM.GetProperty(id, 'Hull', 25)
	local Intelligence = DM.GetProperty(id, 'Intelligence', 25)
	local WeaponCapacitorRecoveryBuff = 1 +  DM.GetProperty(id, 'Buff_WeaponCapacitorRecovery_ALL_Add', 0) / 100
	local wcregen =  string.format("%.1f", (0.8 * Hull / 30 * WeaponCapStanceMod) * WeaponCapacitorRecoveryBuff)
	local Currentwc = math.ceil(DM.GetProperty(id, 'Stamina'))
	local PowerCapacitorRecoveryBuff =  1 + (DM.GetProperty(id, 'Buff_PowerCapacitorRecovery_ALL_Add', 0) / 100)
	local pwregen =  string.format("%.1f", 2 * Intelligence / 25 * PowerCapacitorRecoveryBuff)
	local Currentpc = math.ceil(DM.GetProperty(id, 'Capacitor'))
	local econData = GetEconomyTotals()
	if DM.GetProperty(id,'PrestigeClassPromoted', nil) == 1 and econData.stored.ENERGY <= (4000 + bp.Economy.BuildCostMass) then
		pwregen = 0
		wcregen = 0
	end
	StaminaHistogram.SetValueWidth(Currentwc/DM.GetProperty(id, 'Stamina_Max'))
	StaminaText:SetText(Currentwc..' / '..DM.GetProperty(id, 'Stamina_Max')..'  +'..wcregen..' /s')
	CapacitorHistogram.SetValueWidth(Currentpc/DM.GetProperty(id, 'Capacitor_Max'))
	CapacitorText:SetText(Currentpc..' / '..DM.GetProperty(id, 'Capacitor_Max')..'  +'..pwregen..' /s')
	HeroText:SetText(DM.GetProperty(id, 'BaseClass', 'Fighter')..' '..DM.GetProperty(id, 'PrestigeClass', 'Dreadnought')..' level '..CF.GetUnitLevel(unit))
end

function RefreshDamage(id, PropertyName)
	local unit = GetUnitById(id)
	local bp = unit:GetBlueprint()
	SetProgressBar(unit,'Damage', 0)
	local c = 0
	for i = 1,7 do
		UmUi['Text_'..i..PropertyName]:SetText('')
	end
	if bp.Weapon then
		for _,wep in bp.Weapon do
			if wep.Label ~= 'DeathWeapon' and wep.Label ~= 'DeathImpact' and wep.Damage > 0 then
				c = c + 1
				UmUi['Text_'..c..PropertyName]:SetText(wep.DisplayName)
			end
		end
	end
end

function RefreshArmor(id)
	local unit = GetUnitById(id)
	local Classid = unit:GetUnitId()
	local army = unit:GetArmy()
	local bp = unit:GetBlueprint()
	-- Enhanced Ui Damage resists
	if UmUi['PrestigeClass'].OnMouseEnter then
		LastTooltipTarget = 'ArmorUi'
		EnhTtipTimer = 0
		local Armorfound = true
		local Tp = {} Tp.Line = {} Tp.Width = 270 Tp.OffSetX = 180 Tp.OffSetY = -80
		table.insert(Tp.Line, {'Armor type :'})
		if DM.GetProperty(id, 'Upgrade_Armor_Light Armor') then table.insert(Tp.Line, {'  Light Armor...'..DM.GetProperty(id, 'Upgrade_Armor_Light Armor'), Color.NOMADS})
		elseif DM.GetProperty(id, 'Upgrade_Armor_Medium Armor') then table.insert(Tp.Line, {'  Medium Armor...'..DM.GetProperty(id, 'Upgrade_Armor_Medium Armor'), Color.SERAPHIM})
		elseif DM.GetProperty(id, 'Upgrade_Armor_Heavy Armor') then table.insert(Tp.Line, {'  Heavy Armor...'..DM.GetProperty(id, 'Upgrade_Armor_Heavy Armor'), Color.AEON})
		else table.insert(Tp.Line, {'  No Armor', Color.CYBRAN}) Armorfound = false
		end
		if Armorfound == false and DM.GetProperty(id, 'Buff_Armor_ALL_Add', 0) == 0 then else
			table.insert(Tp.Line, {' '})
			table.insert(Tp.Line, {'Damage resists from armor :'})
			local excludelist = {'Health Increase','Regeneration Increase','Light Armor','Medium Armor','Heavy Armor', 'Plasma damages Resist', 'Shield Absorb DF', 'Shield Absorb DF Naval', 'Shield Absorb DF Experimental', 'Shield Absorb Artillery', 'Shield Absorb Bomb', 'Shield Absorb Missile', 'Build Rate Increase', 'Plasma damages Absorb', 'Shield Absorb', 'Mass Production Increase', 'Energy Production Increase'}
			for _, modifier in ArmorModifiers.RefView do
				if table.find(excludelist, modifier) then
				else
					local ModModifier = string.gsub(modifier, 'Armor for ','')
					local SpeDamageAbsorbtion = 0
					SpeDamageAbsorbtion = CF.GetArmorAbsorptionUi(id, string.gsub(modifier, 'Armor for ','')) + DM.GetProperty(id, 'Buff_ArmorPerc_ALL_Add', 0)
					if SpeDamageAbsorbtion >= 75 then
						Tp.OffSetY = Tp.OffSetY + 10
						table.insert(Tp.Line, {'  '..ModModifier..'...'..SpeDamageAbsorbtion..' %', Color.AEON})
					elseif SpeDamageAbsorbtion >= 50 then
						Tp.OffSetY = Tp.OffSetY + 10
						table.insert(Tp.Line, {'  '..ModModifier..'...'..SpeDamageAbsorbtion..' %', Color.SERAPHIM})
					elseif SpeDamageAbsorbtion >= 25 then	
						Tp.OffSetY = Tp.OffSetY + 10
						table.insert(Tp.Line, {'  '..ModModifier..'...'..SpeDamageAbsorbtion..' %', Color.NOMADS})
					elseif SpeDamageAbsorbtion > 0 then
						Tp.OffSetY = Tp.OffSetY + 10
						table.insert(Tp.Line, {'  '..ModModifier..'...'..SpeDamageAbsorbtion..' %', Color.CYBRAN})
					end
				end
			end
		end
		-- Shield Resists
		local ShieldSpeFound = false
		local ShieldUpgrades = 
		{
			'Shield Absorb',
			'Shield Absorb DF',
			'Shield Absorb DF Naval',
			'Shield Absorb DF Experimental',
			'Shield Absorb Artillery',
			'Shield Absorb Bomb',
			'Shield Absorb Missile'
		}
		for _, modifier in ShieldUpgrades do
			if DM.GetProperty(id, 'Upgrade_Armor_'..modifier, 0) ~= 0  then
				ShieldSpeFound = true
			end
		end
		if ShieldSpeFound == true then
			table.insert(Tp.Line, {' '})
			table.insert(Tp.Line, {'Shield Strengh :'})
			for _, modifier in ShieldUpgrades do
				local SMod = string.gsub(modifier, 'Shield Absorb ', '')
				local ShieldResist = math.floor(DM.GetProperty(id, 'Upgrade_Armor_'..modifier, 0))
				if ShieldResist ~=  0 then
					Tp.OffSetY = Tp.OffSetY + 10
					table.insert(Tp.Line, {'  '..SMod..' : + '..ShieldResist..' %', Color.AEON})
				end
			end
		end
		
		-- Special Resists
		for _, modifier in ArmorModifiers.RefView do
			if modifier == 'Plasma damages Resist' then
				local Plasma_Resist = math.floor(CF.GetArmorAbsorption(id, 'Plasma damages Resist', 0, 'Plasma') * 100)
				if Plasma_Resist ~=  0 then
					table.insert(Tp.Line, {' '})
					table.insert(Tp.Line, {'Special resists :'})
					Tp.OffSetY = Tp.OffSetY + 10
					table.insert(Tp.Line, {'  '..'Plasma'..'...'..Plasma_Resist..' %', Color.AEON})
				end
			end
		end
		
		if DM.GetProperty(id, 'Upgrade_Armor_Health Increase') or DM.GetProperty(id, 'Upgrade_Armor_Regeneration Increase') then 
			table.insert(Tp.Line, {' '})
			table.insert(Tp.Line, {'Other Upgrades :'})
			if DM.GetProperty(id, 'Upgrade_Armor_Health Increase') then 
				table.insert(Tp.Line, {'  '..'Max Health...+'..DM.GetProperty(id, 'Upgrade_Armor_Health Increase'), Color.AEON})
			end
			if DM.GetProperty(id, 'Upgrade_Armor_Regeneration Increase') then 
				table.insert(Tp.Line, {'  '..'Regeneration...+'..DM.GetProperty(id, 'Upgrade_Armor_Regeneration Increase')..' HP /s', Color.AEON})
			end
		end
		table.insert(Tp.Line, {''})
		local Stance = DM.GetProperty(id,'StanceState')
		table.insert(Tp.Line, {'Defense Rating '..'( '..Stance..' Stance ) : '..CF.GetDefenseRating(unit)})
		
		table.insert(Tp.Line, {''})
		if  DM.GetProperty(id, 'PrestigeClassPromoted') == 1 then
			table.insert(Tp.Line, {'[ Left Click ] to upgrade Armor', Color.WHITE})
		else
			table.insert(Tp.Line, {"Promote to upgrade Armor !", Color.WHITE})
		end
		SetEnhancedTooltip(UmUi['PrestigeClass'], Tp, '', '')
	end
	UmUi['ArmorUpgradingProgress']:SetText('')
	if  DM.GetProperty(id,'EcoEventProgress_'..'UpgradingArmor') then	UmUi['ArmorUpgradingProgress']:SetText(math.ceil(DM.GetProperty(id,'EcoEventProgress_'..'UpgradingArmor', 0) * 0.1)..' %') end
	if UmUi['BaseClass'].OnMouseEnter == true then
		local Power = math.floor(math.pow(bp.Economy.BuildCostMass, 0.5)) or 1
		if table.find(bp.Categories, 'COMMAND') then Power = Power * 5 end
		local XPPoints = 0
		local type = ''
		if CF.IsMilitary(unit) == true then
			XPPoints = DM.GetProperty('Global'..unit:GetArmy(), 'MilitaryXP') / Power or 0
			type = 'Military Training'
		else
			XPPoints = DM.GetProperty('Global'..unit:GetArmy(), 'CivilianXP') / Power or 0
			type = 'Civilian Training'
		end
		LastTooltipTarget = 'ArmorUi'
		EnhTtipTimer = 0
		local Tp = {} Tp.Line = {} Tp.Width = 270 Tp.OffSetX = 180 Tp.OffSetY = - 20
		local MaxH = math.ceil(unit:GetMaxHealth())
		table.insert(Tp.Line, {'Current level : '..CF.GetUnitLevel(unit)})
		local NextLevelHealth = MaxH + CF.GetGainPerLevel(unit, 'Health')
		table.insert(Tp.Line, {'  Health Max (Next Level) : '..MaxH..' ('..NextLevelHealth..')', Color.AEON})
			-- Capacitors Ui
		local WeaponCapStanceMod = CF.GetStanceModifier(unit,  'StaminaRegen_Mod')
		local Hull = DM.GetProperty(id, 'Hull', 25)
		local Intelligence = DM.GetProperty(id, 'Intelligence', 25)
		local wcregen =  string.format("%.1f", (0.8 * Hull / 30 * WeaponCapStanceMod))
		local Currentwc = math.ceil(DM.GetProperty(id, 'Stamina'))
		table.insert(Tp.Line, {'  Weapon Capacitor : '..Currentwc..' / '..DM.GetProperty(id,'Stamina_Max')..'  +'..wcregen..'/s', Color.ORANGE_LIGHT})
		local PowerCapacitorRecoveryBuff =  1 + (DM.GetProperty(id, 'Buff_PowerCapacitorRecovery_ALL_Add', 0) / 100)
		local pwregen =  string.format("%.1f", 2 * Intelligence / 25 * PowerCapacitorRecoveryBuff)
		local Currentpc = math.ceil(DM.GetProperty(id, 'Capacitor'))
		table.insert(Tp.Line, {'  Power Capacitor : '..Currentpc..' / '..DM.GetProperty(id, 'Capacitor_Max')..'  +'..pwregen..'/s', Color.UEF})
		table.insert(Tp.Line, {''})
		-- Classes 
		local BaseClass = DM.GetProperty(id, 'BaseClass')
		table.insert(Tp.Line, {'Base Class : '..BaseClass})
		if  DM.GetProperty(id, 'PrestigeClassPromoted') == 1 then
			if BaseClass == 'Fighter' then
				table.insert(Tp.Line, {'  Puissance + 5', Color.AEON})
				table.insert(Tp.Line, {'  Hull + 5', Color.AEON})
				table.insert(Tp.Line, {'  Intelligence - 10', Color.CYBRAN})
				table.insert(Tp.Line, {'  Moving Speed + 15 %', Color.AEON})
				table.insert(Tp.Line, {'  Vision Radius + 25 %', Color.AEON})
			elseif BaseClass == 'Rogue' then
				table.insert(Tp.Line, {'  Dexterity + 5', Color.AEON})
				table.insert(Tp.Line, {'  Intelligence + 5', Color.AEON})
				table.insert(Tp.Line, {'  Energy - 10', Color.CYBRAN})
				table.insert(Tp.Line, {'  Moving Speed + 30 %', Color.AEON})
				table.insert(Tp.Line, {'  Vision Radius + 100 %', Color.AEON})
				table.insert(Tp.Line, {''})
				table.insert(Tp.Line, {'Passive powers :'})

				Tp.Width = 340
			elseif BaseClass == 'Support' then
				table.insert(Tp.Line, {'  Dexterity - 10', Color.CYBRAN})
				table.insert(Tp.Line, {'  Hull + 5', Color.AEON})
				table.insert(Tp.Line, {'  Energy + 5', Color.AEON})
				table.insert(Tp.Line, {'  Moving Speed + 15 %', Color.AEON})
				table.insert(Tp.Line, {'  Vision Radius + 25 %', Color.AEON})
				table.insert(Tp.Line, {''})
				table.insert(Tp.Line, {'Passive powers :'})
				table.insert(Tp.Line, {'  10 s immobility grants overtime insta-repair', Color.AEON})
				table.insert(Tp.Line, {'    unit must not fire, take damages or move', Color.AEON})
				table.insert(Tp.Line, {'    Capacitor must be over 50%',  Color.AEON})
				table.insert(Tp.Line, {'    use capacitor power',  Color.AEON})
				-- Energy storage
				local Power = math.ceil(math.pow(bp.Economy.BuildCostMass, 0.9)) 
				local energysto = Power * 2000
				table.insert(Tp.Line, {'  Energy Storage + '..energysto,  Color.AEON})
				Tp.Width = 310
			elseif BaseClass == 'Ardent' then
				local army = unit:GetArmy()
				local HealthAbsorp = math.ceil(CF.GetHealthAbsorptionUi(id) + DM.GetProperty(army, 'AI_'..'Ardent'..'_'..CF.GetUnitLayerTypeHero(unit), 0))
				local EnergyAbso = math.ceil(CF.GetEnergyAbsorptionUi(id))
				table.insert(Tp.Line, {'  Puissance - 10', Color.CYBRAN})
				table.insert(Tp.Line, {'  Intelligence + 10', Color.AEON})
				table.insert(Tp.Line, {'  Energy + 5', Color.AEON})
				table.insert(Tp.Line, {'  Moving Speed + 15 %', Color.AEON})
				table.insert(Tp.Line, {'  Vision Radius + 35 %', Color.AEON})
				table.insert(Tp.Line, {''})
				table.insert(Tp.Line, {'Passive powers :'})
				table.insert(Tp.Line, {'  '..HealthAbsorp..' % damages converted to health', Color.AEON})
				table.insert(Tp.Line, {'  '..EnergyAbso..' % damages converted to energy', Color.AEON})
				Tp.Width = 300
			end
		else
			if BaseClass == 'Fighter' then
				table.insert(Tp.Line, {'  Puissance + 5', Color.AEON})
				table.insert(Tp.Line, {'  Hull + 5', Color.AEON})
				table.insert(Tp.Line, {'  Intelligence - 10', Color.CYBRAN})
			elseif BaseClass == 'Rogue' then
				table.insert(Tp.Line, {'  Dexterity + 5', Color.AEON})
				table.insert(Tp.Line, {'  Intelligence + 5', Color.AEON})
				table.insert(Tp.Line, {'  Energy - 10', Color.CYBRAN})
				table.insert(Tp.Line, {'  Moving Speed + 15 %', Color.AEON})
				table.insert(Tp.Line, {'  Vision Radius + 25 %', Color.AEON})
				table.insert(Tp.Line, {''})
				table.insert(Tp.Line, {'Passive powers :'})
				table.insert(Tp.Line, {'    Radar stealth', Color.AEON})
				Tp.Width = 340
			elseif BaseClass == 'Support' then
				table.insert(Tp.Line, {'  Dexterity - 10', Color.CYBRAN})
				table.insert(Tp.Line, {'  Hull + 5', Color.AEON})
				table.insert(Tp.Line, {'  Energy + 5', Color.AEON})
				table.insert(Tp.Line, {''})
				table.insert(Tp.Line, {'Passive powers :'})
				table.insert(Tp.Line, {'  10 s immobility grants insta-repair', Color.AEON})
				table.insert(Tp.Line, {'    unit must not fire, take damages or move', Color.AEON})
				table.insert(Tp.Line, {'    Capacitor must be over 50%',  Color.AEON})
				table.insert(Tp.Line, {'    use capacitor power',  Color.AEON})
				Tp.Width = 310
			elseif BaseClass == 'Ardent' then
				local army = unit:GetArmy()
				local HealthAbsorp = math.ceil(CF.GetHealthAbsorptionUi(id) + DM.GetProperty(army, 'AI_'..'Ardent'..'_'..CF.GetUnitLayerTypeHero(unit), 0))
				local EnergyAbso = math.ceil(CF.GetEnergyAbsorptionUi(id))
				table.insert(Tp.Line, {'  Puissance - 10', Color.CYBRAN})
				table.insert(Tp.Line, {'  Intelligence + 10', Color.AEON})
				table.insert(Tp.Line, {'  Energy + 5', Color.AEON})
				table.insert(Tp.Line, {''})
				table.insert(Tp.Line, {'Passive powers :'})
				table.insert(Tp.Line, {'  '..HealthAbsorp..' % damages converted to health', Color.AEON})
				table.insert(Tp.Line, {'  '..EnergyAbso..' % damages converted to energy', Color.AEON})
				Tp.Width = 300
			end
		end	
		local PrestigeClass = DM.GetProperty(id, 'PrestigeClass')
		table.insert(Tp.Line, {''})
		if PrestigeClass == 'NeedPromote' then
			table.insert(Tp.Line, {'Prestige Class : '..'not yet promoted'})
		else
			table.insert(Tp.Line, {'Prestige Class : '..PrestigeClass})
		end
		table.insert(Tp.Line, {''})
		table.insert(Tp.Line, {'[Left Click] to set training priorities', Color.WHITE})
		table.insert(Tp.Line, {''})
		table.insert(Tp.Line, {'[Right Click] to spend Global XP to the unit', Color.WHITE})
		if XPPoints > 500 then
			table.insert(Tp.Line, {type..' XP points : '..math.ceil(XPPoints - 500), Color.GREY_LIGHT})
		else
			table.insert(Tp.Line, {type..' : not enough XP for training', Color.GREY_LIGHT})
		end
		table.insert(Tp.Line, {''})
		SetEnhancedTooltip(UmUi['BaseClass'], Tp, '', '')
	end
end

function RefreshShield(id, PropertyName)
	-- StaticText = UmUi['Text_1' .. PropertyName]
	-- StaticText2 = UmUi['Text_2' .. PropertyName]
	-- local unit = GetUnitById(id)
	-- local Classid = unit:GetUnitId()
	-- local army = unit:GetArmy()
	-- local bp = unit:GetBlueprint()
	-- local ShieldBonusTech = 0
	-- SetProgressBar(unit,'Shield', 0)
	-- local ShieldHealth = math.floor(DM.GetProperty(id, 'MyShieldMaxHealth', 0))
	-- local bpShield = bp.Defense.Shield
	-- if (bpShield ~= nil and bpShield.ShieldSize ~= 0) or unit:GetShieldRatio() > 0 then
		-- local ShieldRatio = unit:GetShieldRatio()
		-- ShieldHealth = math.floor(ShieldHealth * ShieldRatio)
		-- if ShieldRatio >= 0.70 then StaticText:SetColor('ff70ff70')
		-- elseif ShieldRatio >= 0.33 then StaticText:SetColor('ffffffaa')
		-- else  StaticText:SetColor('ffff7070')
		-- end	
		-- ShieldBonusTech = math.floor(ShieldBonusTech)
		-- StaticText:SetText(ShieldHealth)
	-- else
		-- ShieldBonusTech = math.floor(ShieldBonusTech)
	-- end
end

function SetEnhancedTooltip(targetUi, DescriptionTtip, PowerName, UnitId)
	UmUi['EnhancedTooltipUi'].Width:Set(DescriptionTtip.Width)
	local c = 0
	for i = 1, 32 do
		if DescriptionTtip.Line[i] then
			c = c+1
			UmUi['EnhancedTooltipUi'..i..'Text']:SetText(DescriptionTtip.Line[i][1])
			UmUi['EnhancedTooltipUi'..i..'Text']:SetColor(DescriptionTtip.Line[i][2] or 'ffffffaa')
			UmUi['EnhancedTooltipUi'..i..'Text']:DisableHitTest(true)
			UmUi['EnhancedTooltipUi'..i..'Text']:Show()
			UmUi['EnhancedTooltipUi'..i..'Text'].PowerCastName = PowerName
			if DescriptionTtip.Line[i][3] != nil then
				UmUi['EnhancedTooltipUi'..i..'Box']:EnableHitTest(true)
				UmUi['EnhancedTooltipUi'..i..'Box'].Width:Set(DescriptionTtip.Width - 20)
				UmUi['EnhancedTooltipUi'..i..'Box']:Show()
				UmUi['EnhancedTooltipUi'..i..'Box'].PowerCastName = PowerName
				UmUi['EnhancedTooltipUi'..i..'Box'].TtipChoice = DescriptionTtip.Line[i][3]
				UmUi['EnhancedTooltipUi'..i..'Box'].UnitId = UnitId
			else
				UmUi['EnhancedTooltipUi'..i..'Box']:DisableHitTest(true)
			end
		else
			UmUi['EnhancedTooltipUi'..i..'Text']:SetText('')
			UmUi['EnhancedTooltipUi'..i..'Text']:DisableHitTest(true)
			UmUi['EnhancedTooltipUi'..i..'Box']:DisableHitTest(true)
			UmUi['EnhancedTooltipUi'..i..'Box']:Hide()
		end
	end
	UmUi['EnhancedTooltipUi'].Height:Set(c * 17 + 18)
	LayoutHelpers.AtLeftTopIn(UmUi['EnhancedTooltipUi'], targetUi, DescriptionTtip.OffSetX or 0, - (c * 15 + 30) + (DescriptionTtip.OffSetY or 0))
	UmUi['EnhancedTooltipUi']:Show()
end

function SettingTemplates()

	local TemplatesBp =
	{ 
		TemplateName = 'Combat',
		Models = {'ual0001', 'uel0001','xsl0001', 'ual0301', 'uel0301','url0301','xsl0301','ual0106', 'uel0106','url0106', 'url0107', 'xsl0201','uel0201','del0204', 'uel0202', 'uel0203', 'uel0303', 'xel0305', 'drl0204', 'url0202', 'url0303', 'xrl0305', 'ual0201', 'ual0202', 'xal0203', 'ual0303', 'xal0305', 'xsl0202', 'xsl0203', 'xsl0303', 'xsl0305', 'dslk004', 'uaa0203', 'uea0203', 'uea0305', 'ura0203', 'xra0305', 'xsa0203',},
		BaseClasses = {'Fighter',},
		PrestigeClass = {'Guardian', 'Dreadnought',},
		ArmorModifiers = {
			ArmorHeavy = 3,
			ArmorDirectFire = 1,
			RegenerationIncrease = 1,
		},
		WeaponIndex = 1,
		WeaponModifiers = {
			MaxRadius = 1,
			DamageBot = 1,
			DamageTank = 1,
		},
		Puissance = 10,
		Dexterity = 5,
		Hull = 15,
		Intelligence = 5,
		Energy = 5,
	}
	UnitGeneralTemplates = CF.AddTemplate(TemplatesBp, UnitGeneralTemplates)

	TemplatesBp =
	{ 
		TemplateName = 'Combat',
		Models = {'url0001',},
		BaseClasses = {'Fighter',},
		PrestigeClass = {'Guardian', 'Dreadnought',},
		ArmorModifiers = {
			ArmorHeavy = 3,
			ArmorDirectFire = 2,
			RegenerationIncrease = 1,
		},
		WeaponIndex = 2,
		WeaponModifiers = {
			MaxRadius = 2,
			Damage = 1,
		},
		Puissance = 10,
		Dexterity = 5,
		Hull = 15,
		Intelligence = 5,
		Energy = 5,
	}
	UnitGeneralTemplates = CF.AddTemplate(TemplatesBp, UnitGeneralTemplates)
	
	local TemplatesBp2 =
	{ 
		TemplateName = 'DPS',
		Models = {'url0001',},
		BaseClasses = {'Fighter',},
		PrestigeClass = {'Guardian', 'Dreadnought', 'Elite',},
		ArmorModifiers = {
			RegenerationIncrease = 2,
		},
		WeaponIndex = 2,
		WeaponModifiers = {
			Damage = 2,
			DamageBot = 2,
			DamageTank = 2,
		},
		Puissance = 10,
		Dexterity = 5,
		Hull = 15,
		Intelligence = 5,
		Energy = 5,
	}
	UnitGeneralTemplates = CF.AddTemplate(TemplatesBp2, UnitGeneralTemplates)
	
	 TemplatesBp2 =
	{ 
		TemplateName = 'DPS',
		Models = {'ual0001', 'uel0001','xsl0001', 'ual0301', 'uel0301','url0301','xsl0301','ual0106', 'uel0106','url0106', 'url0107', 'xsl0201','uel0201','del0204', 'uel0202', 'uel0203', 'uel0303', 'xel0305', 'drl0204', 'url0202', 'url0303', 'xrl0305', 'ual0201', 'ual0202', 'xal0203', 'ual0303', 'xal0305', 'xsl0202', 'xsl0203', 'xsl0303', 'xsl0305', 'dslk004', 'uaa0203', 'uea0203', 'uea0305', 'ura0203', 'xra0305', 'xsa0203',},
		BaseClasses = {'Fighter','Rogue', 'Ardent', 'Support',},
		PrestigeClass = {'Guardian', 'Dreadnought', 'Elite', 'Bard',},
		ArmorModifiers = {
			RegenerationIncrease = 2,
		},
		WeaponIndex = 1,
		WeaponModifiers = {
			Damage = 1,
			DamageBot = 2,
			DamageTank = 2,
		},
		Puissance = 10,
		Dexterity = 5,
		Hull = 15,
		Intelligence = 5,
		Energy = 5,
	}
	UnitGeneralTemplates = CF.AddTemplate(TemplatesBp2, UnitGeneralTemplates)
	
	TemplatesBp2 =
	{ 
		TemplateName = 'Long Range',
		Models = {'ual0001', 'uel0001','xsl0001', 'ual0301', 'uel0301','url0301','xsl0301','ual0106', 'uel0106','url0106', 'url0107', 'xsl0201',},
		BaseClasses = {'Fighter','Rogue',},
		PrestigeClass = {'Guardian', 'Dreadnought', 'Elite', 'Bard',},
		ArmorModifiers = {
			RegenerationIncrease = 1,
		},
		WeaponIndex = 1,
		WeaponModifiers = {
			MaxRadius = 7,
		},
		Puissance = 10,
		Dexterity = 5,
		Hull = 15,
		Intelligence = 5,
		Energy = 5,
	}
	UnitGeneralTemplates = CF.AddTemplate(TemplatesBp2, UnitGeneralTemplates)
	
	TemplatesBp2 =
	{ 
		TemplateName = 'Long Range',
		Models = {'url0001',},
		BaseClasses = {'Fighter','Rogue',},
		PrestigeClass = {'Guardian', 'Dreadnought', 'Elite',},
		ArmorModifiers = {
			RegenerationIncrease = 1,
		},
		WeaponIndex = 2,
		WeaponModifiers = {
			MaxRadius = 7,
		},
		Puissance = 10,
		Dexterity = 5,
		Hull = 15,
		Intelligence = 5,
		Energy = 5,
	}
	UnitGeneralTemplates = CF.AddTemplate(TemplatesBp2, UnitGeneralTemplates)
	
	TemplatesBp2 =
	{ 
		TemplateName = 'Exp Hunter',
		Models = {'ual0301', 'uel0301','url0301','xsl0301', 'uel0303', 'xel0305', 'drl0204', 'url0202', 'url0303', 'xrl0305', 'ual0201', 'ual0202', 'xal0203', 'ual0303', 'xal0305', 'xsl0202', 'xsl0203', 'xsl0303', 'xsl0305', 'dslk004', 'uaa0203', 'uea0203', 'uea0305', 'ura0203', 'xra0305', 'xsa0203', 'xel0305'},
		BaseClasses = {'Fighter','Rogue',},
		PrestigeClass = {'Guardian', 'Dreadnought', 'Elite', 'Bard',},
		ArmorModifiers = {
		},
		WeaponIndex = 1,
		WeaponModifiers = {
			MaxRadius = 1,
			DamageExperimental = 6,
		},
		Puissance = 10,
		Dexterity = 5,
		Hull = 15,
		Intelligence = 5,
		Energy = 5,
	}
	UnitGeneralTemplates = CF.AddTemplate(TemplatesBp2, UnitGeneralTemplates)
	
	TemplatesBp2 =
	{ 
		TemplateName = 'Adv. Interceptor',
		Models = {'uaa0102','uea0102','ura0102', 'xsa0102','dea0202','dra0202', 'xaa0202', 'xsa0202', 'uaa0303', 'uea0303', 'ura0303', 'xsa0303'},
		BaseClasses = {'Fighter','Rogue',},
		PrestigeClass = {'Guardian', 'Dreadnought', 'Elite', 'Bard',},
		ArmorModifiers = {
			RegenerationIncrease = 1,
		},
		WeaponIndex = 1,
		WeaponModifiers = {
			DamageHighAltAir = 6,
		},
		Puissance = 10,
		Dexterity = 5,
		Hull = 15,
		Intelligence = 5,
		Energy = 5,
	}
	UnitGeneralTemplates = CF.AddTemplate(TemplatesBp2, UnitGeneralTemplates)
	
	TemplatesBp2 =
	{ 
		TemplateName = 'High Survivability',
		Models = {'uaa0102','uea0102','ura0102', 'xsa0102','dea0202','dra0202', 'xaa0202', 'xsa0202', 'uaa0303', 'uea0303', 'ura0303', 'xsa0303', 'uaa0302', 'uea0302', 'ura0302', 'xsa0302', 'uaa0203', 'uea0203', 'ura0203', 'xsa0203'},
		BaseClasses = {'Fighter'},
		PrestigeClass = {'Guardian', 'Dreadnought',},
		ArmorModifiers = {
			ArmorHeavy = 3,
			RegenerationIncrease = 2,
			ArmorAntiAir = 4,
			
		},
		WeaponIndex = 1,
		WeaponModifiers = {
		},
		Puissance = 10,
		Dexterity = 5,
		Hull = 15,
		Intelligence = 5,
		Energy = 5,
	}
	UnitGeneralTemplates = CF.AddTemplate(TemplatesBp2, UnitGeneralTemplates)

	TemplatesBp2 =
	{ 
		TemplateName = 'Deep Regen',
		Models = {'url0001','ual0001', 'uel0001','xsl0001','ual0301', 'uel0301','url0301','xsl0301', 'uel0303', 'xel0305', 'drl0204', 'url0202', 'url0303', 'xrl0305', 'ual0201', 'ual0202', 'xal0203', 'ual0303', 'xal0305', 'xsl0202', 'xsl0203', 'xsl0303', 'xsl0305', 'dslk004', 'uaa0203', 'uea0203', 'uea0305', 'ura0203', 'xra0305', 'xsa0203', 'xel0305'},
		BaseClasses = {'Fighter','Rogue',},
		PrestigeClass = {'Guardian', 'Dreadnought', 'Elite', 'Bard',},
		ArmorModifiers = {
			RegenerationIncrease = 7,
		},
		WeaponIndex = 1,
		WeaponModifiers = {
		},
		Puissance = 10,
		Dexterity = 5,
		Hull = 15,
		Intelligence = 5,
		Energy = 5,
	}
	UnitGeneralTemplates = CF.AddTemplate(TemplatesBp2, UnitGeneralTemplates)
end


