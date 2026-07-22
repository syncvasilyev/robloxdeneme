--!strict
-- The main hub: a large covered dark-metal hall (not an outdoor plaza) — dark floor/ceiling,
-- support pillars, a red carpet path, cool ceiling light panels, and the PublicMapSpawn marker
-- OnboardingSystem looks for (see findPublicMapSpawn in OnboardingSystem). Open on all sides
-- (no enclosing walls) so it still reads as the map's big open social area, just under a proper
-- covered structure instead of open sky.

local MainSquare = {}

local HALL_SIZE = Vector3.new(92, 17, 92)

local function buildCeilingLight(zone: Instance, position: Vector3)
	local fixture = Instance.new("Part")
	fixture.Name = "CeilingLightPanel"
	fixture.Anchored = true
	fixture.CanCollide = false
	fixture.Size = Vector3.new(6, 0.3, 2.4)
	-- Hangs just below the ceiling surface rather than centered on it, so the thin panel
	-- doesn't poke into/overlap the ceiling part (the earlier version's z-fighting cause).
	fixture.Position = position - Vector3.new(0, 0.3, 0)
	fixture.Color = Color3.fromRGB(210, 225, 240)
	fixture.Material = Enum.Material.Neon
	fixture.Transparency = 0.1
	fixture.Parent = zone

	local light = Instance.new("SpotLight")
	light.Face = Enum.NormalId.Bottom
	light.Color = Color3.fromRGB(200, 220, 245)
	light.Brightness = 3.5
	light.Range = 28
	light.Angle = 75
	light.Parent = fixture
end

function MainSquare.build(container: Instance, PropLibrary: any, origin: CFrame)
	local zone = Instance.new("Folder")
	zone.Name = "MainSquare"
	zone.Parent = container

	local floor = Instance.new("Part")
	floor.Name = "HallFloor"
	floor.Anchored = true
	floor.Size = Vector3.new(HALL_SIZE.X, 1, HALL_SIZE.Z)
	floor.CFrame = origin * CFrame.new(0, 0.5, 0)
	floor.Color = Color3.fromRGB(40, 41, 46)
	floor.Material = Enum.Material.DiamondPlate
	floor.Parent = zone

	local ceiling = Instance.new("Part")
	ceiling.Name = "HallCeiling"
	ceiling.Anchored = true
	ceiling.CanCollide = false
	ceiling.Size = Vector3.new(HALL_SIZE.X, 1, HALL_SIZE.Z)
	ceiling.CFrame = origin * CFrame.new(0, HALL_SIZE.Y, 0)
	ceiling.Color = Color3.fromRGB(24, 25, 28)
	ceiling.Material = Enum.Material.Metal
	ceiling.Parent = zone

	-- Corner + mid-edge support pillars instead of full walls — keeps the hall open/walkable
	-- from every direction while still reading as a real covered structure.
	local pillarSpots = {
		Vector3.new(-1, -1),
		Vector3.new(1, -1),
		Vector3.new(-1, 1),
		Vector3.new(1, 1),
		Vector3.new(-1, 0),
		Vector3.new(1, 0),
		Vector3.new(0, -1),
		Vector3.new(0, 1),
	}
	for _, spot in ipairs(pillarSpots) do
		local pillar = Instance.new("Part")
		pillar.Name = "Pillar"
		pillar.Anchored = true
		pillar.Size = Vector3.new(2, HALL_SIZE.Y, 2)
		pillar.CFrame = origin * CFrame.new(spot.X * (HALL_SIZE.X / 2 - 2), HALL_SIZE.Y / 2, spot.Y * (HALL_SIZE.Z / 2 - 2))
		pillar.Color = Color3.fromRGB(30, 30, 34)
		pillar.Material = Enum.Material.Metal
		pillar.Parent = zone

		local accentStrip = Instance.new("Part")
		accentStrip.Name = "PillarAccent"
		accentStrip.Anchored = true
		accentStrip.CanCollide = false
		accentStrip.Size = Vector3.new(0.15, HALL_SIZE.Y - 2, 2.2)
		accentStrip.CFrame = pillar.CFrame * CFrame.new(1.1, 0, 0)
		accentStrip.Color = Color3.fromRGB(150, 40, 60)
		accentStrip.Material = Enum.Material.Neon
		accentStrip.Parent = zone
	end

	-- Grid of ceiling light panels.
	for row = -2, 2, 2 do
		for col = -2, 2, 2 do
			buildCeilingLight(zone, (origin * CFrame.new(row * 9, HALL_SIZE.Y - 0.5, col * 9)).Position)
		end
	end

	-- Glowing colored floor pools near the corners — dramatic accent light against the dark
	-- base, same idea as the reference's glowing floor patch, in the hall's red.
	for _, spot in ipairs({ Vector3.new(-30, -30), Vector3.new(30, -30), Vector3.new(-30, 30), Vector3.new(30, 30) }) do
		local glowPool = Instance.new("Part")
		glowPool.Name = "FloorGlowPool"
		glowPool.Anchored = true
		glowPool.CanCollide = false
		glowPool.Shape = Enum.PartType.Cylinder
		glowPool.Size = Vector3.new(0.1, 9, 9)
		glowPool.CFrame = origin * CFrame.new(spot.X, 1.06, spot.Y) * CFrame.Angles(0, 0, math.rad(90))
		glowPool.Color = Color3.fromRGB(180, 30, 50)
		glowPool.Material = Enum.Material.Neon
		glowPool.Transparency = 0.35
		glowPool.Parent = zone
		local poolLight = Instance.new("PointLight")
		poolLight.Color = Color3.fromRGB(200, 40, 60)
		poolLight.Brightness = 2.5
		poolLight.Range = 18
		poolLight.Parent = glowPool
	end

	-- Red carpet paths radiating from the center toward the spawn point and the main exits.
	local carpetDirections = { Vector3.new(0, 1), Vector3.new(0, -1), Vector3.new(1, 0), Vector3.new(-1, 0) }
	for _, dir in ipairs(carpetDirections) do
		local carpet = Instance.new("Part")
		carpet.Name = "CarpetStripe"
		carpet.Anchored = true
		carpet.CanCollide = false
		carpet.Size = Vector3.new(if dir.X ~= 0 then 40 else 8, 0.15, if dir.X ~= 0 then 8 else 40)
		carpet.CFrame = origin * CFrame.new(dir.X * 20, 1.08, dir.Y * 20)
		carpet.Color = Color3.fromRGB(120, 20, 30)
		carpet.Material = Enum.Material.Fabric
		carpet.Parent = zone
	end

	local spawnMarker = Instance.new("Part")
	spawnMarker.Name = "PublicMapSpawn"
	spawnMarker.Anchored = true
	spawnMarker.CanCollide = false
	spawnMarker.Transparency = 1
	spawnMarker.Size = Vector3.new(6, 1, 6)
	spawnMarker.CFrame = origin * CFrame.new(0, 1.5, 14)
	spawnMarker.Parent = zone

	-- Centerpiece: a raised dark dais with a cool glowing edge ring — a hub marker, not a
	-- fountain or a cute sculpture.
	-- Floor's top surface is at Y=1 (see HallFloor above) — the dais sits flush on top of it,
	-- not embedded in it, to avoid the flat-surface z-fighting from the previous version.
	local dais = Instance.new("Part")
	dais.Name = "CenterDais"
	dais.Anchored = true
	dais.Shape = Enum.PartType.Cylinder
	dais.Size = Vector3.new(1.2, 11, 11)
	dais.CFrame = origin * CFrame.new(0, 1.6, 0) * CFrame.Angles(0, 0, math.rad(90))
	dais.Color = Color3.fromRGB(32, 33, 38)
	dais.Material = Enum.Material.Metal
	dais.Parent = zone

	local daisRing = Instance.new("Part")
	daisRing.Name = "DaisRing"
	daisRing.Anchored = true
	daisRing.CanCollide = false
	daisRing.Shape = Enum.PartType.Cylinder
	daisRing.Size = Vector3.new(0.3, 11.4, 11.4)
	daisRing.CFrame = origin * CFrame.new(0, 2.35, 0) * CFrame.Angles(0, 0, math.rad(90))
	daisRing.Color = Color3.fromRGB(210, 225, 245)
	daisRing.Material = Enum.Material.Neon
	daisRing.Transparency = 0.2
	daisRing.Parent = zone
	local daisLight = Instance.new("PointLight")
	daisLight.Color = Color3.fromRGB(200, 220, 245)
	daisLight.Brightness = 2
	daisLight.Range = 26
	daisLight.Parent = daisRing

	-- Ring of large chunky benches around the dais, facing in.
	local benchRadius = 20
	for i = 0, 9 do
		local angle = (i / 10) * math.pi * 2
		local point = origin * CFrame.new(math.cos(angle) * benchRadius, 0, math.sin(angle) * benchRadius)
		if i % 2 == 0 then
			PropLibrary.bench(zone, point * CFrame.Angles(0, angle + math.pi, 0), 2)
		else
			PropLibrary.couch(zone, point * CFrame.Angles(0, angle + math.pi, 0), (i % 4) + 1)
		end
	end

	-- Wider outer ring of seating clusters + trash cans nearer the pillars.
	for i = 0, 7 do
		local angle = (i / 8) * math.pi * 2 + math.pi / 8
		local point = origin * CFrame.new(math.cos(angle) * 34, 0, math.sin(angle) * 34)
		PropLibrary.bench(zone, point * CFrame.Angles(0, angle + math.pi, 0), (i % 3) + 1)
		PropLibrary.trashCan(zone, point * CFrame.new(2, 0, 2))
	end

	return zone
end

return MainSquare
