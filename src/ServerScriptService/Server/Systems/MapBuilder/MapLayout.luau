--!strict
-- Shared zone placement so builders never overlap. All CFrames are ground-level (Y=0), facing
-- the direction the zone's "front" should read from.

local MapLayout = {}

-- Zones pulled in close to the square — a stylized hangout cluster, not a spread-out city, with
-- each zone's own footprint (Park is 70x70, PondBridge's tree ring is ~44 radius, RainyNook's
-- pavilion is 9-radius) still clearing the main area's 38-stud radius with a path gap.
MapLayout.MainSquare = CFrame.new(0, 0, 0)
MapLayout.Park = CFrame.new(0, 0, 85)
MapLayout.RainyNook = CFrame.new(-70, 0, -40)
MapLayout.PlushShop = CFrame.new(-52, 0, 18) * CFrame.Angles(0, math.rad(115), 0)
MapLayout.Cafeteria = CFrame.new(52, 0, -18) * CFrame.Angles(0, math.rad(-65), 0)
MapLayout.PondBridge = CFrame.new(0, 0, -92)
MapLayout.GroundBounds = {
	minX = -150,
	maxX = 160,
	minZ = -150,
	maxZ = 130,
}

return MapLayout
