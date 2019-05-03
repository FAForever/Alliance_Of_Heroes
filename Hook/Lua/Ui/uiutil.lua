local version = string.gsub(GetVersion(), '1.5.', '')
version = string.gsub(version, '1.6.', '') -- steam

if version < '3652' then -- All versions below 3652 don't have buildin global icon support, so we need to insert the icons by our own function
	LOG('MoStorage7: [uiutil.lua '..debug.getinfo(1).currentline..'] - Gameversion is older then 3652. Hooking "UIFile" to add our own unit icons')

   local MyUnitIdTable = {
      sab2105=true,
      sab2106=true,
      sab3105=true,
      sab3106=true,
      seb2105=true,
      seb2106=true,
      seb3105=true,
      seb3106=true,
      srb2105=true,
      srb2106=true,
      srb3105=true,
      srb3106=true,
      ssb2105=true,
      ssb2106=true,
      ssb3105=true,
      ssb3106=true,
   }
   #unit icon must be in /icons/units/. Put the full path to the /icons/ folder in here - note no / on the end!
   local IconPath = "/mods/Alliance_Of_Heroes"
   local oldUIFile = UIFile
   function UIFile(filespec)
      for i, v in MyUnitIdTable do
         if string.find(filespec, v .. '_icon') then
            local curfile =  MyIconPath .. filespec
            if DiskGetFileInfo(curfile) then
               return curfile
            else
               WARN('Blueprint icon for unit '.. control.Data.id ..' could not be found, check your file path and icon names!')
            end
         end
      end
      return oldUIFile(filespec)
   end
else
	LOG('MoStorage7: [uiutil.lua '..debug.getinfo(1).currentline..'] - Gameversion is 3652 or newer. No need to insert the unit icons by our own function.')
end -- All versions below 3652 don't have buildin global icon support, so we need to insert the icons by our own function