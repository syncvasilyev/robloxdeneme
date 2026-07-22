--!strict
-- The social hub: a cobblestone plaza with a centerpiece, ringed by benches/lamps/trees, and the
-- PublicMapSpawn marker OnboardingSystem looks for (see findPublicMapSpawn in OnboardingSystem).

local MainSquare = {}

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
	plaza.Color = Color3.fromRGB(96, 92, 88)
	plaza.Material = Enum.Material.Cobblestone
	plaza.Parent = zone

	local spawnMarker = Instance.new("Part")
	spawnMarker.Name = "PublicMapSpawn"
	spawnMarker.Anchored = true
	spawnMarker.CanCollide = false
	spawnMarker.Transparency = 1
	spawnMarker.Size = Vector3.new(6, 1, 6)
	spawnMarker.CFrame = origin * CFrame.new(0, 1, 10)
	spawnMarker.Parent = zone

	-- Centerpiece: a raised ring with a soft glowing core, readable from a distance as "the middle".
	local centerBase = Instance.new("Part")
	centerBase.Name = "CenterpieceBase"
	centerBase.Anchored = true
	centerBase.Shape = Enum.PartType.Cylinder
	centerBase.Size = Vector3.new(1.2, 10, 10)
	centerBase.CFrame = origin * CFrame.new(0, 0.6, 0) * CFrame.Angles(0, 0, math.rad(90))
	centerBase.Color = Color3.fromRGB(70, 66, 62)
	centerBase.Material = Enum.Material.Slate
	centerBase.Parent = zone

	local glowCore = Instance.new("Part")
	glowCore.Name = "GlowCore"
	glowCore.Anchored = true
	glowCore.CanCollide = false
	glowCore.Shape = Enum.PartType.Ball
	glowCore.Size = Vector3.new(2.4, 2.4, 2.4)
	glowCore.CFrame = origin * CFrame.new(0, 2, 0)
	glowCore.Color = Color3.fromRGB(255, 205, 140)
	glowCore.Material = Enum.Material.Neon
	glowCore.Parent = zone
	local coreLight = Instance.new("PointLight")
	coreLight.Color = Color3.fromRGB(255, 200, 140)
	coreLight.Brightness = 3
	coreLight.Range = 30
	coreLight.Parent = glowCore

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

	-- Inner ring: smaller seating clusters closer to the centerpiece for groups to gather.
	for i = 0, 5 do
		local angle = (i / 6) * math.pi * 2 + math.pi / 6
		local point = origin * CFrame.new(math.cos(angle) * 16, 0, math.sin(angle) * 16)
		PropLibrary.bench(zone, point * CFrame.Angles(0, angle + math.pi, 0), (i % 3) + 1)
	end

	-- Flower beds flanking the main path toward the park (+Z).
	PropLibrary.flowerBed(zone, origin * CFrame.new(-6, 0, 34), Vector2.new(3, 6))
	PropLibrary.flowerBed(zone, origin * CFrame.new(6, 0, 34), Vector2.new(3, 6))

	return zone
end

return MainSquare
