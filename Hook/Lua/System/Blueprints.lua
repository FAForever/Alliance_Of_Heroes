-- #Alliance of Heroes. Range modifications.
-- Franck83 (2017)
do
    local overridden = ModBlueprints

    function ModBlueprints(blueprints)
	    overridden(blueprints)	
        for id,bp in blueprints.Unit do
			-- if table.find(bp.Categories, 'SELECTABLE') and table.find(bp.Categories, 'LAND') and table.find(bp.Categories, 'MOBILE') and bp.Intel and bp.Display then -- adding potential cloaking on every unit.
				-- bp.Intel.Cloak = true
				-- bp.Intel.RadarStealth = true
				-- if not bp.Display.Abilities then
					-- bp.Display.Abilities = {'<LOC ability_cloak>Cloaking',}
				-- elseif not table.find(bp.Display.Abilities,'<LOC ability_cloak>Cloaking') then
					-- table.insert(bp.Display.Abilities,'<LOC ability_cloak>Cloaking')
				-- end
			-- end
			if table.find(bp.Categories, 'COMMAND') and table.find(bp.Categories, 'SERAPHIM') then bp.Weapon[1].MuzzleChargeDelay = 0.1 end -- Rate of fire upgrade compatibility
			if table.find(bp.Categories, 'AIR') or table.find(bp.Categories, 'HIGHAIR') or table.find(bp.Categories, 'NAVAL') then
			else
				for i = 1, 30 do
					if bp.Weapon[i] then 
						if	bp.Weapon[i].ProjectileLifetimeUsesMultiplier  then 
							bp.Weapon[i].ProjectileLifetimeUsesMultiplier  =  math.max(4, bp.Weapon[i].ProjectileLifetimeUsesMultiplier)
						else
							bp.Weapon[i].ProjectileLifetimeUsesMultiplier = 6 -- We need to increase projectile life because of Range increase.
						end
						-- if bp.Weapon[i].TrackingRadius then 
							-- bp.Weapon[i].TrackingRadius =  math.min(1.15, bp.Weapon[i].TrackingRadius)
						-- else
							-- if bp.Weapon[i].MaxRadius then -- We need to add a tracking radius to all weapons for range hill bonus
								-- bp.Weapon[i].TrackingRadius = 1.15
								-- if not bp.Weapon[i].TargetCheckInterval then
									-- bp.Weapon[i].TargetCheckInterval = 0.1
								-- end
							-- end
						-- end
						if table.find(bp.Categories, 'ARTILLERY') and table.find(bp.Categories, 'TECH3') then -- Muzzle velocity increase break tech 3 artillery.
						else
							if bp.Weapon[i].MuzzleVelocity then
								bp.Weapon[i].MuzzleVelocity = bp.Weapon[i].MuzzleVelocity * 1.3 -- we need to increase Muzzle velocity to match the range increase. TO DO : applying muzzle velocity increase only on high arc projectiles (artillery...)
							end
						end
					end	
				end
			end
        end
    end
end

