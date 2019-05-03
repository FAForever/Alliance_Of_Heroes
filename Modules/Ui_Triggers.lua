function Unit_MainUi_Loop_entry()
	-- Create Unit Ui
	WaitSeconds(3)
	import('/mods/Alliance_Of_Heroes/Modules/Unit_MainUi.lua').CreateUnitUi()
	repeat
		import('/mods/Alliance_Of_Heroes/Modules/Unit_MainUi.lua').TickShow()
		WaitSeconds(0.1)
	until (false)
end

