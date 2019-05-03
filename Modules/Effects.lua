local ModPath = '/mods/Alliance_Of_Heroes/'
local Entity = import('/lua/sim/Entity.lua').Entity

function DrawNumbers(Unit, Amount, Color)
	if Amount == 0 then return end
	Amount = math.ceil(Amount)
	local TempEntity = Entity()
	local EntityPos = Unit:GetPosition()
	TempEntity:SetPosition(EntityPos, true)
	local AmountStr = repr(Amount)
	local AmountTable = {}
	AmountStr:gsub(".", function(c) table.insert(AmountTable, c) end)
	
	local function DDraw() -- Making function for futher purposes
		local Lifetime = 6
		local Velocity = math.random(25, 35) / 100 -- we don't want numbers to hide themselves
		if Amount >= 75 and Amount <= 100 then 
			Lifetime = 8
			Velocity = math.random(20, 25) / 100
		elseif Amount <= 200 then
			Lifetime = 12
			Velocity = math.random(15, 20) / 100
		elseif Amount <= 400 then
			Lifetime = 17
			Velocity = math.random(10, 15) / 100
		else
			Lifetime = math.pow(Amount, 0.5)
			Velocity = math.min(10/math.pow(Amount, 0.7), 0.15)
		end
		local YOffset = 2
		local XOffset = 0
		for _,numbers in AmountTable do		
			CreateEmitterAtEntity(TempEntity, Unit:GetArmy(),ModPath..'Graphics/Emitters/'..numbers..'_'..Color..'.bp'):OffsetEmitter(XOffset, YOffset, 0):ScaleEmitter(0.75):SetEmitterCurveParam('LIFETIME_CURVE', Lifetime, 0):SetEmitterCurveParam('VELOCITY_CURVE', Velocity, 0)
			YOffset = YOffset - 0.0001
			XOffset = XOffset + 0.35
		end	
	end
	DDraw()
	TempEntity:Destroy()
end

function DrawMiss(Unit)
	local EntityPos = Unit:GetPosition()
	local TempEntity = Entity()
	TempEntity:SetPosition(EntityPos, true)
	CreateEmitterAtEntity(TempEntity, Unit:GetArmy(),ModPath..'Graphics/Emitters/Miss.bp')
	TempEntity:Destroy()
end