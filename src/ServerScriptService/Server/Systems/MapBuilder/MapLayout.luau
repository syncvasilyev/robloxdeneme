--!strict
-- Shared zone placement so builders never overlap. All CFrames are ground-level (Y=0), facing
-- the direction the zone's "front" should read from.

local MapLayout = {}

-- Main Square is now a large SQUARE covered hall (92x92, half-extent 46 on both axes — see
-- MainSquare.luau), bigger than the old circular plaza it replaced. Every other zone's offset
-- below was re-checked against that square footprint (not just a radius) so nothing clips into
-- the hall's pillars/floor.
MapLayout.MainSquare = CFrame.new(0, 0, 0)
MapLayout.Park = CFrame.new(0, 0, 90)
MapLayout.RainyNook = CFrame.new(-70, 0, -40)
MapLayout.PlushShop = CFrame.new(-64, 0, 20) * CFrame.Angles(0, math.rad(115), 0)
MapLayout.Cafeteria = CFrame.new(64, 0, -20) * CFrame.Angles(0, math.rad(-65), 0)
MapLayout.PondBridge = CFrame.new(0, 0, -100)
MapLayout.GroundBounds = {
	minX = -160,
	maxX = 170,
	minZ = -160,
	maxZ = 140,
}

return MapLayout
