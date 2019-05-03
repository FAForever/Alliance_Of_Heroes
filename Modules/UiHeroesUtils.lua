------------------------------
-- Alliance of Heroes Mod ----
-- Franck83 [2016-2017] ------
------------------------------

local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Tooltip = import('/lua/ui/game/tooltip.lua')
local parent = import('/lua/ui/game/borders.lua').GetMapGroup()
local ModPath = '/mods/Alliance_Of_Heroes/'
local ModPathIcons = ModPath..'Graphics/Icons/'
local Group = import('/lua/maui/group.lua').Group
local Tooltip = import('/lua/ui/game/tooltip.lua')
local StatusBar = import('/lua/maui/statusbar.lua').StatusBar
local Popup = import('/lua/ui/controls/popups/popup.lua').Popup
local TextArea = import('/lua/ui/controls/textarea.lua').TextArea
local RadioButton = import('/lua/ui/controls/RadioButton.lua').RadioButton
local ItemList = import('/lua/maui/itemlist.lua').ItemList

function UiPos(uiobj, Content, keyx, keyobjx, x, keyy, keyobjy, y)
	if keyy == 'Below' then
		LayoutHelpers.Below(uiobj, keyobjy, y)
	elseif keyy == 'AtBottomIn' then
		LayoutHelpers.AtBottomIn(uiobj, Content, y)
	elseif keyy == 'AtVerticalCenterIn' then
		LayoutHelpers.AtVerticalCenterIn(uiobj, Content, y)
	end
	if keyx == 'AtLeftTopIn' or keyy == 'AtLeftTopIn' then
		LayoutHelpers.AtLeftTopIn(uiobj, Content, x,  y)
	elseif keyx == 'AtHorizontalCenterIn' then
		LayoutHelpers.AtHorizontalCenterIn(uiobj, Content, x)
	elseif keyx == 'AtLeftIn' then
		LayoutHelpers.AtLeftIn(uiobj, keyobjx or Content, x)
	end
end

function InitDialogContent(Width, Height, TitleText, FontSize)
	local function CreateDialogTitle(dialogContent, TitleText, FontSize)
		local title = UIUtil.CreateText(dialogContent, TitleText, FontSize or 14, UIUtil.titleFont)
		LayoutHelpers.AtTopIn(title, dialogContent, 5)
		LayoutHelpers.AtHorizontalCenterIn(title, dialogContent)
		return title
	end
	local dialogContent = Group(GetFrame(0))
	dialogContent.Width:Set(Width)
	dialogContent.Height:Set(Height)
	dialog = Popup(GetFrame(0), dialogContent)
	if TitleText then
		local title = CreateDialogTitle(dialogContent, TitleText, FontSize or 14)
		return dialogContent, title, dialog
	else
		return dialogContent, dialog
	end
end

function CreateText(Content, Text, keyx, keyobjx, x, keyy, keyobjy, y, FontSize, Font, Color)
	local uiobj = UIUtil.CreateText(Content, Text or '', FontSize or 12, Font or UIUtil.bodyFont)
	uiobj:SetColor(Color or UIUtil.fontColor)
	UiPos(uiobj, Content, keyx, keyobjx, x, keyy, keyobjy, y)
	return uiobj
end

function CreateTextWithTooltip(Content, Text, keyx, keyobjx, x, keyy, keyobjy, y, FontSize, Font, Color, ColorEnter)
	local uiobj = UIUtil.CreateText(Content, Text or '', FontSize or 12, Font or UIUtil.bodyFont)
	uiobj:SetColor(Color or UIUtil.fontColor)
	UiPos(uiobj, Content, keyx, keyobjx, x, keyy, keyobjy, y)
	local function HandleEvent(self, event)
		if event.Type == 'MouseEnter' then
			uiobj:SetColor(ColorEnter or UIUtil.fontColor)
				if uiobj.TooltipTitle != '' then
				local tooltip = {
					text = uiobj.TooltipTitle or '',
					body = uiobj.TooltipBody or ""
				}
				Tooltip.CreateMouseoverDisplay(self, tooltip, 0, true)
			end
			local sound = Sound({Bank = 'Interface', Cue = 'UI_Economy_Rollover'})
			PlaySound(sound)
			uiobj.OnMouseEnter = true
		end
		if event.Type == 'MouseExit' then
			uiobj:SetColor(Color or UIUtil.fontColor)
			if uiobj.TooltipTitle then
				Tooltip.DestroyMouseoverDisplay()
			end
			uiobj.OnMouseEnter = false
		end
	end
	local function SetTooltip(Title, Body)
		uiobj.TooltipTitle = Title
		uiobj.TooltipBody = Body
	end
	uiobj.SetTooltip = SetTooltip
	uiobj.HandleEvent = HandleEvent
	return uiobj
end

function CreateClickTextWithTooltip(Content, Text, keyx, keyobjx, x, keyy, keyobjy, y, FontSize, Font, Color, ColorEnter)
	local uiobj = UIUtil.CreateText(Content, Text or '', FontSize or 12, Font or UIUtil.bodyFont)
	uiobj:SetColor(Color or UIUtil.fontColor)
	UiPos(uiobj, Content, keyx, keyobjx, x, keyy, keyobjy, y)
	local function HandleEvent(self, event)
		if event.Type == 'ButtonPress'  and event.Modifiers.Left then
			uiobj.OnClickLeft()
		end
		if event.Type == 'ButtonPress'  and event.Modifiers.Right then	
			uiobj.OnClickRight()
		end
		if event.Type == 'MouseEnter' then
			uiobj:SetColor(ColorEnter or UIUtil.fontColor)
			if uiobj.TooltipTitle != '' then
				local tooltip = {
					text = uiobj.TooltipTitle or '',
					body = uiobj.TooltipBody or ""
				}
				Tooltip.CreateMouseoverDisplay(self, tooltip, 0, true)
			end
			local sound = Sound({Bank = 'Interface', Cue = 'UI_Economy_Rollover'})
			PlaySound(sound)
			uiobj.OnMouseEnter = true
		end
		if event.Type == 'MouseExit' then
			uiobj:SetColor(Color or UIUtil.fontColor)
			if uiobj.TooltipTitle then
				Tooltip.DestroyMouseoverDisplay()
			end
			uiobj.OnMouseEnter = false
		end
	end
	local function SetTooltip(Title, Body)
		uiobj.TooltipTitle = Title
		uiobj.TooltipBody = Body
	end
	uiobj.SetTooltip = SetTooltip
	uiobj.HandleEvent = HandleEvent
	return uiobj
end


function CreateClickTextWithTooltipBox(Content, Text, keyx, keyobjx, x, keyy, keyobjy, y, FontSize, Font, Color, ColorEnter, _iconpath, _iconpathMouseEnter, Width, Height, TextOffsetX, TextOffsetY)
	local uiobjbox = Bitmap(Content)
	local TooltipTitle, TooltipBody = ''
	local iconpath = _iconpath
	local iconpathMouseEnter = _iconpathMouseEnter
	uiobjbox:SetTexture(UIUtil.UIFile(iconpath))
	uiobjbox.Width:Set(Width)
	uiobjbox.Height:Set(Height)
	UiPos(uiobjbox, Content, keyx, keyobjx, x, keyy, keyobjy, y)
	local uiobjtext = UIUtil.CreateText(Content, Text or '', FontSize or 12, Font or UIUtil.bodyFont)
	uiobjtext:SetColor(Color or UIUtil.fontColor)
	UiPos(uiobjtext, Content, keyx, keyobjx, x + (TextOffsetX or 0), keyy, keyobjy, y + (TextOffsetY or 0))
	uiobjtext:DisableHitTest(true)
	local function HandleEvent(self, event)
		if event.Type == 'ButtonPress'  and event.Modifiers.Left then
			uiobjbox.OnClickLeft()
		end
		if event.Type == 'ButtonPress'  and event.Modifiers.Right then	
			uiobjbox.OnClickRight()
		end
		if event.Type == 'MouseEnter' then
			uiobjbox:SetTexture(UIUtil.UIFile(iconpathMouseEnter))
			uiobjtext:SetColor(ColorEnter or UIUtil.fontColor)
			if TooltipTitle != '' then
				local tooltip = {
					text = TooltipTitle or '',
					body = TooltipBody or ""
				}
				Tooltip.CreateMouseoverDisplay(self, tooltip, 0, true)
			end
			local sound = Sound({Bank = 'Interface', Cue = 'UI_Economy_Rollover'})
			PlaySound(sound)
			uiobjbox.OnMouseEnter = true
		end
		if event.Type == 'MouseExit' then
			uiobjbox:SetTexture(UIUtil.UIFile(iconpath))
			uiobjtext:SetColor(Color or UIUtil.fontColor)
			if TooltipTitle then
				Tooltip.DestroyMouseoverDisplay()
			end
			uiobjbox.OnMouseEnter = false
		end
	end
	local function SetTooltip(Title, Body)
		TooltipTitle = Title
		TooltipBody = Body
	end
	local function SetTextureOnMouseExit(Texturepath)
		uiobjbox:SetTexture(UIUtil.UIFile(Texturepath))
		iconpath = Texturepath
	end
	local function SetText(text)
		uiobjtext:SetText(text)
	end
	local function SetTextureOnMouseEnter(Texturepath)
		iconpathMouseEnter = Texturepath
	end
	local function SetPosition(Content, _keyx, _keyobjx, _x, _keyy, _keyobjy, _y)
		UiPos(uiobjbox, Content, _keyx, _keyobjx, _x or x, _keyy, _keyobjy, _y or y)
		UiPos(uiobjtext, Content, _keyx, _keyobjx, (_x or x) + (TextOffsetX or 0), _keyy, _keyobjy, (_y or y) + (TextOffsetY or 0))
	end
	uiobjbox.SetTextureOnMouseExit = SetTextureOnMouseExit
	uiobjbox.SetTextureOnMouseEnter = SetTextureOnMouseEnter
	uiobjbox.SetTooltip = SetTooltip
	uiobjbox.HandleEvent = HandleEvent
	uiobjbox.SetText = SetText
	uiobjbox.SetPosition = SetPosition
	return uiobjbox, uiobjtext
end


function CreateClickTextWithTooltipPersistant(Content, Text, keyx, keyobjx, x, keyy, keyobjy, y, FontSize, Font, Color, ColorEnter)
	local uiobj = UIUtil.CreateText(Content, Text or '', FontSize or 12, Font or UIUtil.bodyFont)
	uiobj:SetColor(Color or UIUtil.fontColor)
	UiPos(uiobj, Content, keyx, keyobjx, x, keyy, keyobjy, y)
	
	local function HandleEvent(self, event)
		if event.Type == 'ButtonPress'  and event.Modifiers.Left then
			uiobj.OnClickLeft()
		end
		if event.Type == 'ButtonPress'  and event.Modifiers.Right then	
			uiobj.OnClickRight()
		end
		if event.Type == 'MouseEnter' then
			uiobj:SetColor(ColorEnter or UIUtil.fontColor)
			if uiobj.TooltipTitle != '' then
				local tooltip = {
					text = uiobj.TooltipTitle or '',
					body = uiobj.TooltipBody or ""
				}
				Tooltip.CreateMouseoverDisplay(self, tooltip, 0, true)
			end
			local sound = Sound({Bank = 'Interface', Cue = 'UI_Economy_Rollover'})
			PlaySound(sound)
		end
		if event.Type == 'MouseExit' then
			if uiobj.RefreshOnMouseExit == true then
				uiobj:SetColor(Color or UIUtil.fontColor)
			end
			if uiobj.TooltipTitle then
				Tooltip.DestroyMouseoverDisplay()
			end
		end
	end
	local function SetTooltip(Title, Body)
		uiobj.TooltipTitle = Title
		uiobj.TooltipBody = Body
	end
	local function SetRefreshOnMouseExit(State)
		uiobj.RefreshOnMouseExit = State
	end
	uiobj.SetTooltip = SetTooltip
	uiobj.HandleEvent = HandleEvent
	uiobj.SetRefreshOnMouseExit = SetRefreshOnMouseExit
	return uiobj
end


function CreateTextArea(Content, sizex, sizey, Text, keyx, keyobjx, x, keyy, keyobjy, y, FontSize, Font, Color)
	local uiobj = TextArea(Content, sizex, sizey)
	uiobj:SetText(Text)
	uiobj:SetFont(Font or UIUtil.bodyFont, FontSize or 12)
	uiobj:SetColors(Color or UIUtil.fontColor, "000000C0", Color or UIUtil.fontColor,  "000000C0")
	UiPos(uiobj, Content, keyx, keyobjx, x, keyy, keyobjy, y)
	return uiobj
end

function CreateItemList(Content, NumberOfItems, Width, List, keyx, keyobjx, x, keyy, keyobjy, y, FontSize, Font, FontColor, HighLightColor, ShowMouseOverIt)
	local uiobj = ItemList(Content)
	uiobj:SetFont(Font or UIUtil.bodyFont, FontSize or 12)
	uiobj:SetColors(FontColor or UIUtil.fontColor, "000000C0", FontColor or UIUtil.fontColor,  HighLightColor or "4000FF00")
	uiobj:ShowMouseoverItem(ShowMouseOverIt)
	local height = NumberOfItems * uiobj:GetRowHeight()
	uiobj.Height:Set(height)
	uiobj.Width:Set(Width)
	UiPos(uiobj, Content, keyx, keyobjx, x, keyy, keyobjy, y)
	if List then
		for _, Item in List do
			uiobj:AddItem(Item)
		end
	end
	return uiobj
end

function CreateButton(Content, Model, Text, keyx, keyobjx, x, keyy, keyobjy, y)
	local uiobj = UIUtil.CreateButtonWithDropshadow(Content, Model, Text)
	UiPos(uiobj, Content, keyx, keyobjx, x, keyy, keyobjy, y)
	return uiobj
end

-- function CreateButtonBitmap(Content, _iconpath, _iconpathMouseEnter, keyx, keyobjx, x, keyy, keyobjy, y)
	-- local uiobj = Bitmap(Content)
	-- local TooltipTitle, TooltipBody = ''
	-- local iconpath = _iconpath
	-- local iconpathMouseEnter = _iconpathMouseEnter
	-- uiobj:SetTexture(UIUtil.UIFile(iconpath))
	-- UiPos(uiobj, Content, keyx, keyobjx, x, keyy, keyobjy, y)
	-- local function HandleEvent(self, event)
		-- if event.Type == 'ButtonPress'  and event.Modifiers.Left then
			-- uiobj.OnClickLeft()
		-- end
		-- if event.Type == 'ButtonPress'  and event.Modifiers.Right then	
			-- uiobj.OnClickRight()
		-- end
		-- if event.Type == 'MouseEnter' then
			-- uiobj:SetTexture(UIUtil.UIFile(iconpathMouseEnter))
			-- uiobj.OnMouseEnter = true
			-- if TooltipTitle != '' then
				-- local tooltip = {
					-- text = TooltipTitle or '',
					-- body = TooltipBody or ""
				-- }
				-- Tooltip.CreateMouseoverDisplay(self, tooltip, 0, true)
			-- end
			-- local sound = Sound({Bank = 'Interface', Cue = 'UI_Economy_Rollover'})
			-- PlaySound(sound)
		-- end
		-- if event.Type == 'MouseExit' then
			-- uiobj:SetTexture(UIUtil.UIFile(iconpath))
			-- uiobj.OnMouseEnter = false
			-- if TooltipTitle then
				-- Tooltip.DestroyMouseoverDisplay()
			-- end
		-- end
	-- end
	-- local function SetTooltip(Title, Body)
		-- TooltipTitle = Title
		-- TooltipBody = Body
	-- end
	-- local function SetTextureOnMouseExit(Texturepath)
		-- uiobj:SetTexture(UIUtil.UIFile(Texturepath))
		-- iconpath = Texturepath
	-- end
	-- local function SetTextureOnMouseEnter(Texturepath)
		-- iconpathMouseEnter = Texturepath
	-- end
	-- uiobj.SetTextureOnMouseExit = SetTextureOnMouseExit
	-- uiobj.SetTextureOnMouseEnter = SetTextureOnMouseEnter
	-- uiobj.SetTooltip = SetTooltip
	-- uiobj.HandleEvent = HandleEvent
	-- return uiobj
-- end

function CreateButtonBitmap(Content, _iconpath, _iconpathMouseEnter, keyx, keyobjx, x, keyy, keyobjy, y, ObjName)
	local uiobj = Bitmap(Content)
	local TooltipTitle, TooltipBody = ''
	local iconpath = _iconpath
	local iconpathMouseEnter = _iconpathMouseEnter
	uiobj:SetTexture(UIUtil.UIFile(iconpath))
	UiPos(uiobj, Content, keyx, keyobjx, x, keyy, keyobjy, y)
	local function RefreshTooltip(Title, Body, obj)
		TooltipTitle = Title
		TooltipBody = Body
		if TooltipTitle != '' then
				local tooltip = {
					text = TooltipTitle or '',
					body = TooltipBody or ""
				}
				Tooltip.CreateMouseoverDisplay(obj, tooltip, 0, true)
			end
		local sound = Sound({Bank = 'Interface', Cue = 'UI_Economy_Rollover'})
		PlaySound(sound)
	end
	local function HandleEvent(self, event)
		if event.Type == 'ButtonPress'  and event.Modifiers.Left then
			uiobj.OnClickLeft(ObjName)
		end
		if event.Type == 'ButtonPress'  and event.Modifiers.Right then	
			uiobj.OnClickRight(ObjName)
		end
		if event.Type == 'MouseEnter' then
			uiobj:SetTexture(UIUtil.UIFile(iconpathMouseEnter))
			uiobj.OnMouseEnter = true
			uiobj.OnMouse_Enter(ObjName)
			if TooltipTitle != '' then
				local tooltip = {
					text = TooltipTitle or '',
					body = TooltipBody or ""
				}
				-- Tooltip.CreateMouseoverDisplay(self, tooltip, 0, true)
				RefreshTooltip(TooltipTitle, TooltipBody, self)
			end
			local sound = Sound({Bank = 'Interface', Cue = 'UI_Economy_Rollover'})
			PlaySound(sound)
		end
		if event.Type == 'MouseExit' then
			uiobj:SetTexture(UIUtil.UIFile(iconpath))
			uiobj.OnMouseEnter = false
			if TooltipTitle then
				Tooltip.DestroyMouseoverDisplay()
			end
		end
	end
	local function SetTooltip(Title, Body)
		TooltipTitle = Title
		TooltipBody = Body
	end

	local function SetTextureOnMouseExit(Texturepath)
		uiobj:SetTexture(UIUtil.UIFile(Texturepath))
		iconpath = Texturepath
	end
	local function SetTextureOnMouseEnter(Texturepath)
		iconpathMouseEnter = Texturepath
	end
	uiobj.SetTextureOnMouseExit = SetTextureOnMouseExit
	uiobj.SetTextureOnMouseEnter = SetTextureOnMouseEnter
	uiobj.SetTooltip = SetTooltip
	uiobj.RefreshTooltip = RefreshTooltip
	uiobj.HandleEvent = HandleEvent
	uiobj.OnClickLeft = function(Name) end
	uiobj.OnClickRight = function(Name) end
	uiobj.OnMouse_Enter = function(Name) end
	return uiobj
end

function CreateHistogramBar(Content, keyx, keyobjx, x, keyy, keyobjy, y, _Height, _Width, _TexturePath)
	local Height = _Height
	local Width = _Width
	local TexturePath = _TexturePath
	local uiobj = Bitmap(Content, UIUtil.UIFile(TexturePath))
	uiobj.Height:Set(Height)
    uiobj.Width:Set(Width)
	UiPos(uiobj, Content, keyx, keyobjx, x, keyy, keyobjy, y)
	local function SetValueWidth(percent)
		uiobj.Width:Set(Width * percent)
	end
	local function SetValueHeight(percent)
		uiobj.Height:Set(-Height * percent)
	end
	local function SetTextures(TextureFile)
		uiobj:SetTexture(UIUtil.UIFile(TextureFile))	
	end
	uiobj.SetTextures = SetTextures
	uiobj.SetValueWidth = SetValueWidth
	uiobj.SetValueHeight = SetValueHeight
	return uiobj
end

function CreateHistogramBarBeforeAfter(Content, keyx, keyobjx, x, keyy, keyobjy, y, _Height, _Width, _TexturePathNeg, _TexturePathPos)
	local Histogram = CreateHistogramBar(Content, keyx, keyobjx, x, keyy, keyobjy, y, _Height, _Width, _TexturePathNeg)
	Histogram.SetValueWidth(1, 1)
	local TexturePathNeg = _TexturePathNeg
	local TexturePathPos = _TexturePathPos
	local function SetValues(Old, New)
		if Old >= New then
			UiPos(Histogram, Content, keyx, keyobjx, x - (1-New/Old) * _Width, keyy, keyobjy, y)
			Histogram.SetTextures(TexturePathNeg)
			Histogram.SetValueWidth(math.max(1-New/(Old+0.0001), -1))
		elseif New > Old then
			UiPos(Histogram, Content, keyx, keyobjx, x, keyy, keyobjy, y)
			Histogram.SetTextures(TexturePathPos)
			Histogram.SetValueWidth(math.min(New/(Old+0.00001)-1, 1))
		end
	end
	Histogram.SetValues = SetValues
	return Histogram
end


function CreateBackGround(Content, keyx, keyobjx, x, keyy, keyobjy, y, _Height, _Width, _TexturePath)
	local Height = _Height
	local Width = _Width
	local TexturePath = _TexturePath
	local uiobj = Bitmap(Content, UIUtil.UIFile(TexturePath))
	uiobj.Height:Set(Height)
    uiobj.Width:Set(Width)
	uiobj:DisableHitTest(true)
	UiPos(uiobj, Content, keyx, keyobjx, x, keyy, keyobjy, y)
	local function AddTitle(Text, keyx, keyobjx, x, keyy, keyobjy, y, FontSize, Font, Color, ColorEnter)
		local uiobjtext = CreateTextWithTooltip(uiobj, Text, keyx, keyobjx, x, keyy, keyobjy, y, FontSize, Font, Color, ColorEnter)
		return uiobjtext
	end
	uiobj.AddTitle = AddTitle
	return uiobj
end