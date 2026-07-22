--!strict
-- Shared zone placement so builders never overlap. All CFrames are ground-level (Y=0), facing
-- the direction the zone's "front" should read from.

local MapLayout = {}

MapLayout.MainSquare = CFrame.new(0, 0, 0)
MapLayout.Park = CFrame.new(0, 0, 100)
MapLayout.RainyStreet = CFrame.new(125, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
MapLayout.PlushShop = CFrame.new(-52, 0, 18) * CFrame.Angles(0, math.rad(115), 0)
MapLayout.Cafeteria = CFrame.new(52, 0, -18) * CFrame.Angles(0, math.rad(-65), 0)
MapLayout.PondBridge = CFrame.new(0, 0, -115)
MapLayout.GroundBounds = {
	minX = -180,
	maxX = 200,
	minZ = -180,
	maxZ = 160,
}

return MapLayout
