--!strict
-- The open social hub: a colorful pastel plaza (not a gray city square) with a magical glowing
-- centerpiece, ringed by benches/lamps/trees, and the PublicMapSpawn marker OnboardingSystem
-- looks for (see findPublicMapSpawn in OnboardingSystem).

local MainSquare = {}

local PETAL_COLORS = {
	Color3.fromRGB(235, 180, 210),
	Color3.fromRGB(200, 180, 235),
	Color3.fromRGB(255, 210, 180),
	Color3.fromRGB(180, 220, 235),
}

function MainSquare.build(container: Instance, PropLibrary: any, origin: CFrame)
	local zone = Instance.new("Folder")
	zone.Name = "MainSquare"
	zone.Parent = container

	local plaza = Instance.new("Part")
	plaza.Name = "PlazaGround"
	plaza.Anchored = true
	plaza.Shape = Enum.PartType.Cylinder
	plaza.Size = Vector3.new(1, 76, 76)
	plaza.CFrame = origin * CFrame.new(0, 0.5, 0) * CFrame.Angles(0, 0, math.rad(90))
	plaza.Color = Color3.fromRGB(225, 205, 232)
	plaza.Material = Enum.Material.SmoothPlastic
	plaza.Parent = zone

	-- A ring of soft pastel "petal" accent tiles around the centerpiece — reads as a flower/
	-- mandala pattern from above instead of flat gray pavement.
	for i = 0, 15 do
		local angle = (i / 16) * math.pi * 2
		local petalRadius = 22
		local petal = Instance.new("Part")
		petal.Name = "PetalTile"
		petal.Anchored = true
		petal.CanCollide = false
		petal.Shape = Enum.PartType.Cylinder
		petal.Size = Vector3.new(0.1, 4.2, 2.6)
		petal.CFrame = origin
			* CFrame.new(math.cos(angle) * petalRadius, 1.05, math.sin(angle) * petalRadius)
			* CFrame.Angles(0, -angle, math.rad(90))
		petal.Color = PETAL_COLORS[(i % #PETAL_COLORS) + 1]
		petal.Material = Enum.Material.Neon
		petal.Transparency = 0.25
		petal.Parent = zone
	end

	local spawnMarker = Instance.new("Part")
	spawnMarker.Name = "PublicMapSpawn"
	spawnMarker.Anchored = true
	spawnMarker.CanCollide = false
	spawnMarker.Transparency = 1
	spawnMarker.Size = Vector3.new(6, 1, 6)
	spawnMarker.CFrame = origin * CFrame.new(0, 1, 10)
	spawnMarker.Parent = zone

	-- Centerpiece: a pastel pedestal with a magical glowing core and a ring of tiny orbiting
	-- lights, readable from a distance as "the middle" without looking like a city fountain.
	local centerBase = Instance.new("Part")
	centerBase.Name = "CenterpieceBase"
	centerBase.Anchored = true
	centerBase.Shape = Enum.PartType.Cylinder
	centerBase.Size = Vector3.new(1.2, 10, 10)
	centerBase.CFrame = origin * CFrame.new(0, 0.6, 0) * CFrame.Angles(0, 0, math.rad(90))
	centerBase.Color = Color3.fromRGB(200, 175, 220)
	centerBase.Material = Enum.Material.SmoothPlastic
	centerBase.Parent = zone

	local glowCore = Instance.new("Part")
	glowCore.Name = "GlowCore"
	glowCore.Anchored = true
	glowCore.CanCollide = false
	glowCore.Shape = Enum.PartType.Ball
	glowCore.Size = Vector3.new(2.6, 2.6, 2.6)
	glowCore.CFrame = origin * CFrame.new(0, 2.2, 0)
	glowCore.Color = Color3.fromRGB(255, 210, 235)
	glowCore.Material = Enum.Material.Neon
	glowCore.Parent = zone
	local coreLight = Instance.new("PointLight")
	coreLight.Color = Color3.fromRGB(255, 200, 235)
	coreLight.Brightness = 3
	coreLight.Range = 32
	coreLight.Parent = glowCore

	for i = 0, 7 do
		local angle = (i / 8) * math.pi * 2
		local sparkle = Instance.new("Part")
		sparkle.Name = "Sparkle"
		sparkle.Anchored = true
		sparkle.CanCollide = false
		sparkle.Shape = Enum.PartType.Ball
		sparkle.Size = Vector3.new(0.4, 0.4, 0.4)
		sparkle.CFrame = origin * CFrame.new(math.cos(angle) * 3.6, 2.2 + math.sin(angle * 2) * 0.6, math.sin(angle) * 3.6)
		sparkle.Color = PETAL_COLORS[(i % #PETAL_COLORS) + 1]
		sparkle.Material = Enum.Material.Neon
		sparkle.Parent = zone
	end

	-- Ring of lamps and trees around the plaza edge.
	local ringRadius = 33
	for i = 0, 11 do
		local angle = (i / 12) * math.pi * 2
		local point = origin * CFrame.new(math.cos(angle) * ringRadius, 0, math.sin(angle) * ringRadius)
		if i % 3 == 0 then
			PropLibrary.streetLamp(zone, point, 1)
		elseif i % 3 == 1 then
			PropLibrary.tree(zone, point, 1)
		else
			local benchCFrame = point * CFrame.Angles(0, angle + math.pi, 0)
			PropLibrary.bench(zone, benchCFrame, (i % 3) + 1)
			PropLibrary.trashCan(zone, point * CFrame.new(1.5, 0, 1.5))
		end
	end

	-- Inner ring: smaller seating clusters closer to the centerpiece for groups to gather —
	-- alternating benches and colorful couches so it's not all one shape.
	for i = 0, 5 do
		local angle = (i / 6) * math.pi * 2 + math.pi / 6
		local point = origin * CFrame.new(math.cos(angle) * 16, 0, math.sin(angle) * 16)
		local seatCFrame = point * CFrame.Angles(0, angle + math.pi, 0)
		if i % 2 == 0 then
			PropLibrary.couch(zone, seatCFrame, i + 1)
		else
			PropLibrary.bench(zone, seatCFrame, (i % 3) + 1)
		end
		PropLibrary.heartLight(zone, point * CFrame.new(-2, 0, 0))
	end

	-- Flower beds + a photo spot flanking the main path toward the park (+Z).
	PropLibrary.flowerBed(zone, origin * CFrame.new(-6, 0, 34), Vector2.new(3, 6))
	PropLibrary.flowerBed(zone, origin * CFrame.new(6, 0, 34), Vector2.new(3, 6))
	PropLibrary.photoSpot(zone, origin * CFrame.new(0, 0, 28))
	PropLibrary.neonEmoji(zone, origin * CFrame.new(-3.5, 3, 28.2) * CFrame.Angles(0, math.rad(180), 0), "✨")
	PropLibrary.neonEmoji(zone, origin * CFrame.new(3.5, 3, 28.2) * CFrame.Angles(0, math.rad(180), 0), "⭐")

	return zone
end

return MainSquare
