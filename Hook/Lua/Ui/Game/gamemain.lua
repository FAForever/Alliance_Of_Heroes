
local oldCreateUI = CreateUI 
function CreateUI(isReplay) 
    oldCreateUI(isReplay)
	import('/mods/Alliance_Of_Heroes/Modules/Unit_MainUi.lua')
	-- We start the Ui detection trigger thread
	ForkThread(import('/mods/Alliance_Of_Heroes/Modules/Ui_Triggers.lua').Unit_MainUi_Loop_entry)
end