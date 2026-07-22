--!strict
-- A grassy park north of the main square: mixed seating (benches, picnic tables), flower beds,
-- and a denser tree line at the far edge that quietly leads into the pond/woods zone's mood.

local Park = {}

function Park.build(container: Instance, PropLibrary: any, origin: CFrame)
	local zone = Instance.new("Folder")
	zone.Name = "Park"
	zone.Parent = container

	local grass = Instance.new("Part")
	grass.Name = "ParkGround"
	grass.Anchored = true
	grass.Size = Vector3.new(70, 1, 70)
	grass.CFrame = origin * CFrame.new(0, 0.5, 0)
	grass.Color = Color3.fromRGB(44, 68, 42)
	grass.Material = Enum.Material.Grass
	grass.Parent = zone

	-- A winding-feeling path made of a few offset pavers rather than one straight strip.
	local pathOffsets = { -30, -18, -6, 6, 18, 30 }
	for i, z in ipairs(pathOffsets) do
		local wiggle = math.sin(i) * 3
		local paver = Instance.new("Part")
		paver.Name = "Paver"
		paver.Anchored = true
		paver.Size = Vector3.new(6, 0.2, 13)
		paver.CFrame = origin * CFrame.new(wiggle, 1.05, z)
		paver.Color = Color3.fromRGB(120, 112, 100)
		paver.Material = Enum.Material.Concrete
		paver.Parent = zone
	end

	-- Picnic cluster.
	PropLibrary.picnicTable(zone, origin * CFrame.new(-18, 0, -10))
	PropLibrary.picnicTable(zone, origin * CFrame.new(-22, 0, 4) * CFrame.Angles(0, math.rad(30), 0))

	-- Bench + flower reading nook.
	PropLibrary.bench(zone, origin * CFrame.new(16, 0, -14) * CFrame.Angles(0, math.rad(160), 0), 1)
	PropLibrary.bench(zone, origin * CFrame.new(20, 0, -8) * CFrame.Angles(0, math.rad(200), 0), 1)
	PropLibrary.flowerBed(zone, origin * CFrame.new(18, 0, -18), Vector2.new(5, 3))

	-- A quieter corner near the tree line for smaller groups to sit and talk.
	PropLibrary.bench(zone, origin * CFrame.new(-14, 0, 26) * CFrame.Angles(0, math.rad(0), 0), 2)
	PropLibrary.lanternPost(zone, origin * CFrame.new(-14, 0, 22))
	PropLibrary.lanternPost(zone, origin * CFrame.new(-14, 0, 30))

	-- Tree line + scattered bushes around the park's edge.
	for i = 0, 9 do
		local angle = (i / 10) * math.pi * 2
		local radius = 31
		local point = origin * CFrame.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		PropLibrary.tree(zone, point, (i % 2) + 1)
		if i % 2 == 0 then
			PropLibrary.bush(zone, point * CFrame.new(2, 0, 2), 1.2)
		end
	end

	PropLibrary.streetLamp(zone, origin * CFrame.new(-8, 0, 0), 2)
	PropLibrary.streetLamp(zone, origin * CFrame.new(8, 0, 12), 2)
	PropLibrary.trashCan(zone, origin * CFrame.new(-16, 0, -8))

	return zone
end

return Park
