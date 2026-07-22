--!strict
-- A small cafeteria across the square from the plush shop, warm-lit indoor seating. Its flat
-- roof (reached by the exterior staircase on the back wall) doubles as a quiet rooftop hangout —
-- see HiddenAreas.luau for the other secret spots.

local Cafeteria = {}

function Cafeteria.build(container: Instance, PropLibrary: any, origin: CFrame)
	local zone = Instance.new("Folder")
	zone.Name = "Cafeteria"
	zone.Parent = container

	local building, doorCFrame = PropLibrary.buildingShell(
		zone,
		origin,
		Vector3.new(18, 10, 15),
		Color3.fromRGB(80, 66, 54),
		Color3.fromRGB(50, 38, 30)
	)
	building.Name = "CafeteriaBuilding"

	for _, xOffset in ipairs({ -6, 6 }) do
		PropLibrary.windowLight(zone, doorCFrame * CFrame.new(xOffset, -0.5, 0.25), Vector3.new(3, 2.8, 0.2))
	end

	local signBoard = Instance.new("Part")
	signBoard.Name = "SignBoard"
	signBoard.Anchored = true
	signBoard.CanCollide = false
	signBoard.Size = Vector3.new(7, 1.6, 0.3)
	signBoard.CFrame = doorCFrame * CFrame.new(0, 3.8, 0.4)
	signBoard.Color = Color3.fromRGB(255, 235, 200)
	signBoard.Material = Enum.Material.Neon
	signBoard.Parent = zone
	local signGui = Instance.new("SurfaceGui")
	signGui.Face = Enum.NormalId.Front
	signGui.Parent = signBoard
	local signLabel = Instance.new("TextLabel")
	signLabel.Size = UDim2.fromScale(1, 1)
	signLabel.BackgroundTransparency = 1
	signLabel.Font = Enum.Font.Merriweather
	signLabel.TextScaled = true
	signLabel.TextColor3 = Color3.fromRGB(70, 44, 24)
	signLabel.Text = "☕ KÖŞE KAFETERYA"
	signLabel.Parent = signGui

	local interiorOrigin = origin * CFrame.new(0, 0, -3)
	local tableSpots = { Vector3.new(-5, 0, -3), Vector3.new(5, 0, -3), Vector3.new(-5, 0, 2), Vector3.new(5, 0, 2) }
	for _, spot in ipairs(tableSpots) do
		PropLibrary.smallCafeTable(zone, interiorOrigin * CFrame.new(spot))
	end

	-- Serving counter along the back wall.
	local counter = Instance.new("Part")
	counter.Name = "ServingCounter"
	counter.Anchored = true
	counter.Size = Vector3.new(10, 2.4, 1.6)
	counter.CFrame = interiorOrigin * CFrame.new(0, 1.2, -5.8)
	counter.Color = Color3.fromRGB(60, 44, 34)
	counter.Material = Enum.Material.Wood
	counter.Parent = zone
	for _, x in ipairs({ -3, 0, 3 }) do
		local jar = Instance.new("Part")
		jar.Name = "Jar"
		jar.Anchored = true
		jar.CanCollide = false
		jar.Shape = Enum.PartType.Cylinder
		jar.Size = Vector3.new(1, 0.6, 0.6)
		jar.CFrame = interiorOrigin * CFrame.new(x, 2.6, -5.8) * CFrame.Angles(0, 0, math.rad(90))
		jar.Color = Color3.fromRGB(200, 170, 120)
		jar.Material = Enum.Material.Glass
		jar.Transparency = 0.3
		jar.Parent = zone
	end

	PropLibrary.lanternPost(zone, doorCFrame * CFrame.new(-9.5, 0, 2))
	PropLibrary.lanternPost(zone, doorCFrame * CFrame.new(9.5, 0, 2))

	-- Exterior staircase up the back wall to the roof.
	local stairCount = 9
	for i = 1, stairCount do
		local step = Instance.new("Part")
		step.Name = "Step"
		step.Anchored = true
		step.Size = Vector3.new(4, 0.4, 1.6)
		step.CFrame = origin * CFrame.new(10.5, i * 1.05, -6.5 + i * 0.9)
		step.Color = Color3.fromRGB(60, 58, 56)
		step.Material = Enum.Material.Metal
		step.Parent = zone
	end
	local railing = Instance.new("Part")
	railing.Name = "StairRail"
	railing.Anchored = true
	railing.CanCollide = false
	railing.Size = Vector3.new(0.2, 4, 10)
	railing.CFrame = origin * CFrame.new(12.4, 5, -1)
	railing.Color = Color3.fromRGB(40, 40, 42)
	railing.Material = Enum.Material.Metal
	railing.Transparency = 0.4
	railing.Parent = zone

	-- Rooftop hangout.
	local roofFloor = Instance.new("Part")
	roofFloor.Name = "RoofFloor"
	roofFloor.Anchored = true
	roofFloor.Size = Vector3.new(18.6, 0.4, 15.6)
	roofFloor.CFrame = origin * CFrame.new(0, 10.2, 0)
	roofFloor.Color = Color3.fromRGB(60, 56, 52)
	roofFloor.Material = Enum.Material.Concrete
	roofFloor.Parent = zone
	for _, offset in ipairs({ Vector3.new(-9.1, 1, 0), Vector3.new(9.1, 1, 0), Vector3.new(0, 1, -7.6), Vector3.new(0, 1, 7.6) }) do
		local edge = Instance.new("Part")
		edge.Name = "RoofEdge"
		edge.Anchored = true
		edge.Size = if offset.X ~= 0 then Vector3.new(0.4, 2, 15.6) else Vector3.new(18.6, 2, 0.4)
		edge.CFrame = origin * CFrame.new(0, 10.4, 0) * CFrame.new(offset)
		edge.Color = Color3.fromRGB(50, 48, 46)
		edge.Material = Enum.Material.Concrete
		edge.Parent = zone
	end
	PropLibrary.bench(zone, origin * CFrame.new(-4, 10.4, 0) * CFrame.Angles(0, math.rad(90), 0), 2)
	PropLibrary.bench(zone, origin * CFrame.new(4, 10.4, 0) * CFrame.Angles(0, math.rad(-90), 0), 2)
	PropLibrary.lanternPost(zone, origin * CFrame.new(0, 10.4, -5))
	local roofLight = Instance.new("PointLight")
	roofLight.Color = Color3.fromRGB(180, 190, 230)
	roofLight.Brightness = 1
	roofLight.Range = 20
	local ambientPost = Instance.new("Part")
	ambientPost.Name = "RoofAmbientGlow"
	ambientPost.Anchored = true
	ambientPost.CanCollide = false
	ambientPost.Transparency = 1
	ambientPost.Size = Vector3.new(1, 1, 1)
	ambientPost.CFrame = origin * CFrame.new(0, 12, 0)
	ambientPost.Parent = zone
	roofLight.Parent = ambientPost

	return zone
end

return Cafeteria
