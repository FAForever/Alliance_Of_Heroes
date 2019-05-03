----------------------------
---- Alliance of Heroes ----
---- Buff System -----------
---- Franck83 12/2017-------
----------------------------
-- AoHBuffBlueprint = {
		-- Name = Name of the buff. 
		-- BuffFamily = 'BUFFFamilyName' Different Buff families stacks themselves.
		-- Stacks = 'REPLACE' or 'STACK'. REPLACE will always replace buff in same family. STACK will add the buff to the family
		-- StackRank = from 1 to x. STACKRANK will remplace same buff name only if the new stack rank is superior.
		-- Duration = Time before buff kills himself.
		-- Affects = {
			-- 	Damage = {
			--		ALL = {                    	-- We ll always add this bonus against all targets
			--			Add = 0,
			--			Mult = 1.25,
			--		},
			--		BOT = {						-- The buff will add this bonus against all bots
			--			Add = 5,
			--			Mult = 1,
			--		},
			-- 	},
		-- },
	--}
-- Please note that any kind of buff can be added, even non supported ones. But the affects will must be taken cared of in the mod engine code
----------------------------
----------------------------
-- List of Affects ---------
----------------------------
--------------------------------------------------------------	
-- Alliance of Heroes new affects
--- Armor (ALL + specializations : Direct Fire, Direct Fire Naval, Direct Fire Experimental, Artillery, Anti Air, Bomb, Missile, Nuclear, Overcharge) (Armor piercing damages are done by negative debuff)
--- Damage (ALL + specializations : BOT, TANK, AIR, HIGHALTAIR, NAVAL, DEFENSE, CIVILIAN, EXPERIMENTAL, SUBCOMMAND)
--- Conversion To Energy (ALL)
--- Conversion to Health (ALL)
--- AttackRating (ALL + specializations : BOT, TANK, AIR, HIGHALTAIR, NAVAL, DEFENSE, CIVILIAN, EXPERIMENTAL, SUBCOMMAND)
--- DefenseRating (ALL + specializations : BOT, TANK, AIR, HIGHALTAIR, NAVAL, DEFENSE, CIVILIAN, EXPERIMENTAL, SUBCOMMAND)
--- Puissance (ALL)
--- Dexterity (ALL)
--- Hull (ALL)
--- Intelligence (ALL)
--- Energy (ALL)
--- Weapon Skill (ALL)
--- Weapon Mastery (ALL)
--- Light Armor Mastery (ALL)
--- Medium Armor Mastery (ALL)
--- Heavy Armor Mastery (ALL)
--- Building (ALL)
--- Restoration (ALL)
--- Weapon Power Regen (ALL)
--- Capacitor Power Regen (ALL)

-- Vanilla affects :
--- Damage (ALL)
--- RateOfFire (ALL)
--- DamageRadius (ALL)
--- MaxRadius (ALL)
--- MoveMult (ALL)
--- WeaponsEnable (ALL)
--- VisionRadius (ALL)
--- RadarRadius (ALL)
--- OmniRadius (ALL)
--- BuildRate (ALL)
--- EnergyActive (ALL)
--- MassActive (ALL)
--- EnergyMaintenance (ALL)
--- EnergyProduction (ALL)
--- MassProduction (ALL)
--- EnergyWeapon (ALL)
--- Stun (ALL)
--- MaxHealth (ALL)
--- Health (ALL)
--- Regen (ALL)
--------------------------------------------------------------	

local ModPath = '/mods/Alliance_Of_Heroes/'	
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
	
ApplyBuff = function(unit, AoHBuffBlueprint)
	local BuffBp = AoHBuffBlueprint
	for Aff, Value in BuffBp.Affects do
		if unit.AoHBuffs[Aff] then
			if unit.AoHBuffs[Aff][BuffBp.BuffFamily] then
				if BuffBp.Stacks == 'REPLACE' then
					unit.AoHBuffs[Aff][BuffBp.BuffFamily] = {}
					unit.AoHBuffs[Aff][BuffBp.BuffFamily][BuffBp.Name] = Value
					unit.AoHBuffs[Aff][BuffBp.BuffFamily][BuffBp.Name]['StackRank'] = BuffBp.StackRank
					unit.RemoveBuffThread = unit:ForkThread(KillBuff, BuffBp.Duration, Aff, BuffBp.BuffFamily, BuffBp.Name)
					if table.find(unit.UndoRemoveBuffList, BuffBp.Name) then else table.insert(unit.UndoRemoveBuffList, BuffBp.Name) end
				elseif BuffBp.Stacks == 'STACK' then
					if unit.AoHBuffs[Aff][BuffBp.BuffFamily][BuffBp.Name] then
						if  BuffBp.StackRank >= unit.AoHBuffs[Aff][BuffBp.BuffFamily][BuffBp.Name]['StackRank'] then
							unit.AoHBuffs[Aff][BuffBp.BuffFamily][BuffBp.Name] = Value
							unit.AoHBuffs[Aff][BuffBp.BuffFamily][BuffBp.Name]['StackRank'] = BuffBp.StackRank
							unit.RemoveBuffThread = unit:ForkThread(KillBuff, BuffBp.Duration, Aff, BuffBp.BuffFamily, BuffBp.Name)
							if table.find(unit.UndoRemoveBuffList, BuffBp.Name) then else table.insert(unit.UndoRemoveBuffList, BuffBp.Name) end
						end
					else
						unit.AoHBuffs[Aff][BuffBp.BuffFamily][BuffBp.Name] = Value
						unit.AoHBuffs[Aff][BuffBp.BuffFamily][BuffBp.Name]['StackRank'] = BuffBp.StackRank
						unit.RemoveBuffThread = unit:ForkThread(KillBuff, BuffBp.Duration, Aff, BuffBp.BuffFamily, BuffBp.Name)
					end
				else 
					LOG('Wrong Stack Rule in AoH buff. Please Choose between REPLACE or STACK'..BuffBp.Name)
				end
			else
				unit.AoHBuffs[Aff][BuffBp.BuffFamily] = {}
				unit.AoHBuffs[Aff][BuffBp.BuffFamily][BuffBp.Name] = Value
				unit.AoHBuffs[Aff][BuffBp.BuffFamily][BuffBp.Name]['StackRank'] = BuffBp.StackRank
				unit.RemoveBuffThread = unit:ForkThread(KillBuff, BuffBp.Duration, Aff, BuffBp.BuffFamily, BuffBp.Name)
			end
		else
			unit.AoHBuffs[Aff] = {}
			unit.AoHBuffs[Aff][BuffBp.BuffFamily] = {}
			unit.AoHBuffs[Aff][BuffBp.BuffFamily][BuffBp.Name] = Value
			unit.AoHBuffs[Aff][BuffBp.BuffFamily][BuffBp.Name]['StackRank'] = BuffBp.StackRank
			unit.RemoveBuffThread = unit:ForkThread(KillBuff, BuffBp.Duration, Aff, BuffBp.BuffFamily, BuffBp.Name)
		end
	end
end

KillBuff = function(unit, Duration, Affect, BuffFamily, BuffName)
	WaitSeconds(Duration)
	-- LOG(repr(unit.UndoRemoveBuffList))
	if table.find(unit.UndoRemoveBuffList, BuffName) then
		for index, buff in unit.UndoRemoveBuffList do
			if buff == BuffName then unit.UndoRemoveBuffList[index] = nil end
		end
	else
		if unit.AoHBuffs[Affect][BuffFamily][BuffName] then
			unit.AoHBuffs[Affect][BuffFamily][BuffName] = nil
		end
		if unit.AoHBuffs[Affect][BuffFamily] and tablelength(unit.AoHBuffs[Affect][BuffFamily]) == 0 then
			unit.AoHBuffs[Affect][BuffFamily] = nil
		end
		if unit.AoHBuffs[Affect] and tablelength(unit.AoHBuffs[Affect]) == 0 then
			unit.AoHBuffs[Affect] = nil
		end
	end
end

GetBuffValue = function(unit, AffectName, Specialization)
	local AddValue = 0
	local MultValue = 1
	if unit.AoHBuffs[AffectName] then
		for Family,_ in unit.AoHBuffs[AffectName] do
			for Buff,_ in unit.AoHBuffs[AffectName][Family] do
				for CategoryName,_ in  unit.AoHBuffs[AffectName][Family][Buff] do
					if unit.AoHBuffs[AffectName][Family][Buff][CategoryName] and CategoryName == Specialization then
						if unit.AoHBuffs[AffectName][Family][Buff][CategoryName].Add then
							AddValue = AddValue + unit.AoHBuffs[AffectName][Family][Buff][CategoryName].Add
						end
						if unit.AoHBuffs[AffectName][Family][Buff][CategoryName].Mult then
							MultValue = MultValue + (unit.AoHBuffs[AffectName][Family][Buff][CategoryName].Mult - 1)
						end
					end
				end
			end
		end
	end
	return AddValue, MultValue
end

SyncBuffValue = function(_id, _AffectName, _Specialization)
	SimCallback ({Func='SyncValueFromUi', Args = {id = _id, AffectName = _AffectName, Specialization = _Specialization}})
end

function tablelength(T)
	if T then
		local count = 0
		for _ in pairs(T) do count = count + 1 end
		return count
	else
		return 0
	end
end