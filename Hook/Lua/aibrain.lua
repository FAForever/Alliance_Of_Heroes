-- Alliance of Heroes
local ModPath = '/mods/Alliance_Of_Heroes/'
local DM = import(ModPath..'Modules/DataManager.lua')
local CF = import(ModPath..'Modules/Calculate_Formula.lua')
local HeroesThread = false

function InitGlobalXPData (AiBrain)
	local ArmyIndex = AiBrain:GetArmyIndex()
	-- Global XP that can be spent to units during game
	if not DM.GetProperty('Global'..ArmyIndex, 'MilitaryXP') then
		DM.SetProperty('Global'..ArmyIndex, 'MilitaryXP', 0)
	end
	if not DM.GetProperty('Global'..ArmyIndex, 'CivilianXP') then
		DM.SetProperty('Global'..ArmyIndex, 'CivilianXP', 0)
	end
	if not DM.GetProperty('Global'..ArmyIndex, 'EnergyStorage') then
		DM.SetProperty('Global'..ArmyIndex, 'EnergyStorage', 0)
	end
	if not DM.GetProperty('Global'..ArmyIndex, 'Logistics') then
		DM.SetProperty('Global'..ArmyIndex, 'Logistics', 22)
	end
end

local OldAIBrain = AIBrain
AIBrain = Class(OldAIBrain) {

  -- HUMAN BRAIN FUNCTIONS HANDLED HERE
	OldOnCreateHuman = AIBrain.OnCreateHuman,
    OnCreateHuman = function(self, planName)
		self.OldOnCreateHuman(self, planName)
		-- Global XP that can be spent to units during game
		InitGlobalXPData(self)
		-- Adding HeroesList
		self.HeroesList = {}
		if HeroesThread == false then 
			-- self:ForkThread(self.RefreshingHeroList)
			HeroesThread = true
		end
    end,

	OldOnCreateAI = AIBrain.OnCreateAI,
    OnCreateAI = function(self, planName)
		self.OldOnCreateAI(self, planName)
		-- Global XP that can be spent to units during game
		InitGlobalXPData(self)
		-- Adding HeroesList
		self.HeroesList = {}
		if HeroesThread == false then 
			-- self:ForkThread(self.RefreshingHeroList)
			HeroesThread = true
		end
    end,
	
	RefreshingHeroList = function(self) -- This Thread refreshes heroes list and rank every 10 s (removed feature since mod version 135)
		-- repeat
			-- WaitSeconds(10)
			-- self.HeroesList = CF.SortDualHeroList()	
			-- local BaseClassList = {'Fighter', 'Rogue', 'Support', 'Ardent'}
			-- local TypeList = {'AIR', 'LAND', 'NAVAL'}
			-- Reset Armies bonuses
			-- for ArmyId,_ in ArmyBrains do
				-- for _, Class in BaseClassList do
					-- for _, type in TypeList do
						-- DM.SetProperty(ArmyId, 'AI_'..Class..'_'..type, 0)
					-- end
				-- end
			-- end
			-- for i = 1, 100 do
				-- DM.SetProperty('Hero_HallofFame',i..'id', nil)
				-- DM.SetProperty('Hero_HallofFame',i..'army', nil)
				-- DM.SetProperty('Hero_HallofFame',i..'Description', nil)
				-- DM.SetProperty('Hero_HallofFame',i..'Points', nil)
				-- DM.SetProperty('Hero_HallofFame',i..'MassKilled', nil)
				-- DM.SetProperty('Hero_HallofFame',i..'HpHealed', nil)
				-- DM.SetProperty('Hero_HallofFame',i..'MassKilledRank', nil)
				-- DM.SetProperty('Hero_HallofFame',i..'HpHealedRank', nil)
				-- DM.SetProperty('Hero_HallofFame',i..'Class&Level', nil)
			-- end
			-- for i, Hero in HeroesList do
				-- local id = Hero[1]
				-- local _Hero = GetUnitById(id)
				-- DM.SetProperty(id, 'HallofFame_Rank', nil)
				-- if _Hero.MassKilled > 0 or _Hero.HpHealed > 0 then
					-- local bp = _Hero:GetBlueprint()
					-- local army = _Hero:GetArmy()
					-- local BaseClass = DM.GetProperty(id, 'BaseClass', 'BaseClass not Found')
					-- local PrestigeClass = DM.GetProperty(id,'PrestigeClass','Prestige Class not Found')
					-- local description = LOC(bp.Description)
					-- local type = CF.GetUnitLayerTypeHero(_Hero)
					-- DM.SetProperty('Hero_HallofFame',i..'id', id)
					-- DM.SetProperty('Hero_HallofFame',i..'army', army)
					-- DM.SetProperty('Hero_HallofFame',i..'Description', description)
					-- DM.SetProperty('Hero_HallofFame',i..'Points', Hero[2])
					-- DM.SetProperty('Hero_HallofFame',i..'MassKilled', math.ceil(_Hero.MassKilled))
					-- DM.SetProperty('Hero_HallofFame',i..'HpHealed', math.ceil(_Hero.HpHealed))
					-- DM.SetProperty('Hero_HallofFame',i..'MassKilledRank', _Hero.MassKilledRank)
					-- DM.SetProperty('Hero_HallofFame',i..'HpHealedRank', _Hero.HpHealedRank)
					-- DM.SetProperty('Hero_HallofFame',i..'Class&Level', BaseClass..' '..PrestigeClass..' ['.. CF.GetUnitLevel(_Hero)..']')
					-- DM.SetProperty(id, 'HallofFame_Rank', i)
					-- DM.IncProperty(army, 'AI_'..BaseClass..'_'..type, Hero[2])
				-- end
			-- end
		-- until(self == nil)
	end,	
}


