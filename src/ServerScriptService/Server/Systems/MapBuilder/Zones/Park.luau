--!strict
-- A secondary lounge hall north of the main hub — same dark-metal/quality-facility language as
-- Main Square, but smaller, dimmer, and blue-accented instead of red, so it reads as a distinct
-- room rather than a copy. Replaces the old outdoor grass park, which clashed with the rest of
-- the map's indoor-facility direction.

local Park = {}

local HALL_SIZE = Vector3.new(64, 14, 64)

function Park.build(container: Instance, PropLibrary: any, origin: CFrame)
	local zone = Instance.new("Folder")
	zone.Name = "Park"
	zone.Parent = container

	local floor = Instance.new("Part")
	floor.Name = "LoungeFloor"
	floor.Anchored = true
	floor.Size = Vector3.new(HALL_SIZE.X, 1, HALL_SIZE.Z)
	floor.CFrame = origin * CFrame.new(0, 0.5, 0)
	floor.Color = Color3.fromRGB(36, 38, 46)
	floor.Material = Enum.Material.Metal
	floor.Parent = zone

	local ceiling = Instance.new("Part")
	ceiling.Name = "LoungeCeiling"
	ceiling.Anchored = true
	ceiling.CanCollide = false
	ceiling.Size = Vector3.new(HALL_SIZE.X, 1, HALL_SIZE.Z)
	ceiling.CFrame = origin * CFrame.new(0, HALL_SIZE.Y, 0)
	ceiling.Color = Color3.fromRGB(20, 21, 26)
	ceiling.Material = Enum.Material.Metal
	ceiling.Parent = zone

	local pillarSpots = { Vector3.new(-1, -1), Vector3.new(1, -1), Vector3.new(-1, 1), Vector3.new(1, 1) }
	for _, spot in ipairs(pillarSpots) do
		local pillar = Instance.new("Part")
		pillar.Name = "Pillar"
		pillar.Anchored = true
		pillar.Size = Vector3.new(1.8, HALL_SIZE.Y, 1.8)
		pillar.CFrame = origin * CFrame.new(spot.X * (HALL_SIZE.X / 2 - 2), HALL_SIZE.Y / 2, spot.Y * (HALL_SIZE.Z / 2 - 2))
		pillar.Color = Color3.fromRGB(28, 28, 32)
		pillar.Material = Enum.Material.Metal
		pillar.Parent = zone

		local accentStrip = Instance.new("Part")
		accentStrip.Name = "PillarAccent"
		accentStrip.Anchored = true
		accentStrip.CanCollide = false
		accentStrip.Size = Vector3.new(0.15, HALL_SIZE.Y - 2, 1.9)
		accentStrip.CFrame = pillar.CFrame * CFrame.new(0.95, 0, 0)
		accentStrip.Color = Color3.fromRGB(50, 110, 210)
		accentStrip.Material = Enum.Material.Neon
		accentStrip.Parent = zone
	end

	-- Cool blue ceiling light panels (hung just below the ceiling — see MainSquare's note on
	-- avoiding flat-surface overlap).
	for row = -1, 1 do
		for col = -1, 1 do
			local fixture = Instance.new("Part")
			fixture.Name = "CeilingLightPanel"
			fixture.Anchored = true
			fixture.CanCollide = false
			fixture.Size = Vector3.new(5, 0.3, 2)
			fixture.CFrame = origin * CFrame.new(row * 14, HALL_SIZE.Y - 0.8, col * 14)
			fixture.Color = Color3.fromRGB(150, 190, 230)
			fixture.Material = Enum.Material.Neon
			fixture.Transparency = 0.1
			fixture.Parent = zone
			local light = Instance.new("SpotLight")
			light.Face = Enum.NormalId.Bottom
			light.Color = Color3.fromRGB(140, 185, 230)
			light.Brightness = 3
			light.Range = 24
			light.Angle = 75
			light.Parent = fixture
		end
	end

	-- Blue carpet cross, same idea as Main Square's red one, sitting flush on the floor.
	for _, dir in ipairs({ Vector3.new(0, 1), Vector3.new(1, 0) }) do
		local carpet = Instance.new("Part")
		carpet.Name = "CarpetStripe"
		carpet.Anchored = true
		carpet.CanCollide = false
		carpet.Size = if dir.X ~= 0 then Vector3.new(HALL_SIZE.X - 10, 0.15, 7) else Vector3.new(7, 0.15, HALL_SIZE.Z - 10)
		carpet.CFrame = origin * CFrame.new(0, 1.08, 0)
		carpet.Color = Color3.fromRGB(25, 55, 110)
		carpet.Material = Enum.Material.Fabric
		carpet.Parent = zone
	end

	-- Lounge seating clusters: mixed couches/benches around low tables, facing each other for
	-- conversation rather than all facing one direction.
	local clusterSpots = {
		{ pos = Vector3.new(-18, 0, -14), angle = 40 },
		{ pos = Vector3.new(18, 0, -14), angle = -40 },
		{ pos = Vector3.new(-18, 0, 14), angle = 140 },
		{ pos = Vector3.new(18, 0, 14), angle = -140 },
	}
	for i, cluster in ipairs(clusterSpots) do
		local clusterCFrame = origin * CFrame.new(cluster.pos) * CFrame.Angles(0, math.rad(cluster.angle), 0)
		PropLibrary.couch(zone, clusterCFrame, i)
		PropLibrary.smallCafeTable(zone, clusterCFrame * CFrame.new(0, 0, 3.5) * CFrame.Angles(0, math.rad(180), 0))
	end

	PropLibrary.bench(zone, origin * CFrame.new(0, 0, -24) * CFrame.Angles(0, math.rad(180), 0), 2)
	PropLibrary.bench(zone, origin * CFrame.new(0, 0, 24), 2)
	PropLibrary.trashCan(zone, origin * CFrame.new(-26, 0, -26))
	PropLibrary.trashCan(zone, origin * CFrame.new(26, 0, 26))

	return zone
end

return Park
