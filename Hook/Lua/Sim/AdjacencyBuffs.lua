--****************************************************************************
--**
--**  File     :  /lua/sim/AdjacencyBuffs.lua
--**
--**  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

local AdjBuffFuncs = import('/lua/sim/AdjacencyBuffFunctions.lua')

local adj = {         	    -- SIZE4     SIZE8   SIZE12    SIZE16   SIZE20
	T2EnergyStorage={
        EnergyProduction=   {0.1875, 0.09375, 0.0625, 0.046875, 0.0375},
    },
	T3EnergyStorage={
        EnergyProduction=   {0.25, 0.125, 0.083334, 0.0625, 0.005},
    },
	T2MassStorage={
        MassProduction=     {0.1875, 0.09375, 0.0625, 0.046875, 0.0375},
    },
    T3MassStorage={
        MassProduction=     {0.25, 0.125, 0.083334, 0.0625, 0.005},
    },
}
adj.Hydrocarbon = adj.T2PowerGenerator

for a, buffs in adj do
    _G[a .. 'AdjacencyBuffs'] = {}
    for t, sizes in buffs do
        for i, add in sizes do
            local size = i * 4
            local display_name = a .. t
            local name = display_name .. 'Size' .. size
            local category = 'STRUCTURE SIZE' .. size

            if t == 'RateOfFire' and size == 4 then
                category = category .. ' ARTILLERY'
            end

            BuffBlueprint {
                Name = name,
                DisplayName = display_name,
                BuffType = string.upper(t) .. 'BONUS',
                Stacks = 'ALWAYS',
                Duration = -1,
                EntityCategory = category,
                BuffCheckFunction = AdjBuffFuncs[t .. 'BuffCheck'],
                OnBuffAffect = AdjBuffFuncs.DefaultBuffAffect,
                OnBuffRemove = AdjBuffFuncs.DefaultBuffRemove,
                Affects = {[t]={Add=add, Mult=1}},
            }

            table.insert(_G[a .. 'AdjacencyBuffs'], name)
        end
    end
end