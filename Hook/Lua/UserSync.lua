local DM = import('/Mods/Alliance_Of_Heroes/Modules/DataManager.lua')

local oldOnSync = OnSync
function OnSync()
	oldOnSync()
	if Sync.Data then
		DM.SetSync(Sync.Data)
	end
end
