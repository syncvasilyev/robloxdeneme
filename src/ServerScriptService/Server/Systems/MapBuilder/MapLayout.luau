--!strict
-- Shared zone placement so builders never overlap. All CFrames are ground-level (Y=0), facing
-- the direction the zone's "front" should read from.

local MapLayout = {}

-- Zones pulled in much closer to the square than the first pass — that version left 50-80 studs
-- of empty walking between areas, which read as "the map is huge and empty" rather than one
-- cohesive, walkable cluster. Distances below are chosen so each zone's own footprint (Park is
-- 70x70, PondBridge's tree ring is ~44 radius, RainyStreet is 74 long) still clears the main
-- plaza's 38-stud radius with a ~10-stud path gap, not overlapping it.
MapLayout.MainSquare = CFrame.new(0, 0, 0)
MapLayout.Park = CFrame.new(0, 0, 85)
MapLayout.RainyStreet = CFrame.new(90, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
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
