--!strict
-- A quiet wooded pond south of the main square: a wooden bridge crossing the water, a small
-- dock for photos, and secluded single/double benches tucked among dense trees.

local PondBridge = {}

function PondBridge.build(container: Instance, PropLibrary: any, origin: CFrame)
	local zone = Instance.new("Folder")
	zone.Name = "PondBridge"
	zone.Parent = container

	local groundBase = Instance.new("Part")
	groundBase.Name = "WoodsGround"
	groundBase.Anchored = true
	groundBase.Size = Vector3.new(90, 1, 90)
	groundBase.CFrame = origin * CFrame.new(0, 0.5, 0)
	groundBase.Color = Color3.fromRGB(36, 56, 38)
	groundBase.Material = Enum.Material.LeafyGrass
	groundBase.Parent = zone

	local pond = Instance.new("Part")
	pond.Name = "Pond"
	pond.Anchored = true
	pond.CanCollide = false
	pond.Shape = Enum.PartType.Cylinder
	pond.Size = Vector3.new(1.4, 26, 26)
	pond.CFrame = origin * CFrame.new(0, 0.9, 0) * CFrame.Angles(0, 0, math.rad(90))
	pond.Color = Color3.fromRGB(30, 60, 80)
	pond.Material = Enum.Material.Water
	pond.Transparency = 0.15
	pond.Parent = zone

	local pondBank = Instance.new("Part")
	pondBank.Name = "PondBank"
	pondBank.Anchored = true
	pondBank.Shape = Enum.PartType.Cylinder
	pondBank.Size = Vector3.new(0.8, 29, 29)
	pondBank.CFrame = origin * CFrame.new(0, 0.7, 0) * CFrame.Angles(0, 0, math.rad(90))
	pondBank.Color = Color3.fromRGB(70, 62, 48)
	pondBank.Material = Enum.Material.Sand
	pondBank.Parent = zone

	-- Wooden bridge crossing the pond, west to east.
	local bridgeDeck = Instance.new("Part")
	bridgeDeck.Name = "BridgeDeck"
	bridgeDeck.Anchored = true
	bridgeDeck.Size = Vector3.new(30, 0.6, 5)
	bridgeDeck.CFrame = origin * CFrame.new(0, 1.5, 0)
	bridgeDeck.Color = Color3.fromRGB(96, 68, 44)
	bridgeDeck.Material = Enum.Material.WoodPlanks
	bridgeDeck.Parent = zone
	for _, zOffset in ipairs({ -2.4, 2.4 }) do
		local rail = Instance.new("Part")
		rail.Name = "BridgeRail"
		rail.Anchored = true
		rail.CanCollide = false
		rail.Size = Vector3.new(30, 1.4, 0.2)
		rail.CFrame = origin * CFrame.new(0, 2.5, zOffset)
		rail.Color = Color3.fromRGB(80, 56, 36)
		rail.Material = Enum.Material.Wood
		rail.Parent = zone
	end
	local bridgeLight = Instance.new("PointLight")
	bridgeLight.Color = Color3.fromRGB(255, 210, 150)
	bridgeLight.Brightness = 1.6
	bridgeLight.Range = 16
	local bridgeLampPost = Instance.new("Part")
	bridgeLampPost.Name = "BridgeLampGlow"
	bridgeLampPost.Anchored = true
	bridgeLampPost.CanCollide = false
	bridgeLampPost.Transparency = 1
	bridgeLampPost.Size = Vector3.new(0.2, 0.2, 0.2)
	bridgeLampPost.CFrame = origin * CFrame.new(0, 3, 0)
	bridgeLampPost.Parent = zone
	bridgeLight.Parent = bridgeLampPost

	-- A small wooden dock jutting into the pond — the map's best "photo spot".
	local dock = Instance.new("Part")
	dock.Name = "PhotoDock"
	dock.Anchored = true
	dock.Size = Vector3.new(5, 0.5, 12)
	dock.CFrame = origin * CFrame.new(-20, 1, 6) * CFrame.Angles(0, math.rad(20), 0)
	dock.Color = Color3.fromRGB(88, 62, 40)
	dock.Material = Enum.Material.WoodPlanks
	dock.Parent = zone
	PropLibrary.bench(zone, origin * CFrame.new(-20, 1.5, 10) * CFrame.Angles(0, math.rad(20 + 90), 0), 1)
	PropLibrary.lanternPost(zone, origin * CFrame.new(-18, 1, 3))

	-- Secluded single/double benches tucked around the far bank, spaced apart for privacy.
	local seclusionSpots = {
		{ pos = Vector3.new(24, 0, -14), angle = -140 },
		{ pos = Vector3.new(-26, 0, -18), angle = 60 },
		{ pos = Vector3.new(16, 0, 24), angle = -20 },
	}
	for _, spot in ipairs(seclusionSpots) do
		PropLibrary.bench(zone, origin * CFrame.new(spot.pos) * CFrame.Angles(0, math.rad(spot.angle), 0), 3)
		PropLibrary.lanternPost(zone, origin * CFrame.new(spot.pos) * CFrame.new(2, 0, -1))
	end

	-- Dense tree ring making this read as "woods" rather than an open lawn.
	for i = 0, 17 do
		local angle = (i / 18) * math.pi * 2
		local radius = 38 + (i % 3) * 3
		local point = origin * CFrame.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		PropLibrary.tree(zone, point, (i % 2) + 1)
	end
	for i = 0, 5 do
		local angle = (i / 6) * math.pi * 2 + 0.4
		local point = origin * CFrame.new(math.cos(angle) * 32, 0, math.sin(angle) * 32)
		PropLibrary.bush(zone, point, 1.6)
	end

	return zone
end

return PondBridge
