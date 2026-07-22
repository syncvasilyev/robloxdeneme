--!strict
-- Discoverable spots with varying difficulty: an easy-to-stumble-into alley behind the plush
-- shop, and a genuinely tucked-away secret hideout behind the pond's tree line. (The rooftop
-- hangout — the map's third hidden spot — lives on the Cafeteria building itself.)

local HiddenAreas = {}

--- Easy find: just walk around the back of the plush shop.
function HiddenAreas.buildShopAlley(container: Instance, PropLibrary: any, shopOrigin: CFrame)
	local zone = Instance.new("Folder")
	zone.Name = "ShopAlley"
	zone.Parent = container

	local alleyOrigin = shopOrigin * CFrame.new(0, 0, -9)

	local alleyGround = Instance.new("Part")
	alleyGround.Name = "AlleyGround"
	alleyGround.Anchored = true
	alleyGround.Size = Vector3.new(10, 1, 8)
	alleyGround.CFrame = alleyOrigin * CFrame.new(0, 0.5, 0)
	alleyGround.Color = Color3.fromRGB(50, 48, 46)
	alleyGround.Material = Enum.Material.Concrete
	alleyGround.Parent = zone

	local backWall = Instance.new("Part")
	backWall.Name = "AlleyBackWall"
	backWall.Anchored = true
	backWall.Size = Vector3.new(12, 9, 0.6)
	backWall.CFrame = alleyOrigin * CFrame.new(0, 4.5, -3.6)
	backWall.Color = Color3.fromRGB(60, 54, 52)
	backWall.Material = Enum.Material.Brick
	backWall.Parent = zone

	-- A hand-painted mural — a small reward detail for players who bother to look back here.
	local mural = Instance.new("Part")
	mural.Name = "Mural"
	mural.Anchored = true
	mural.CanCollide = false
	mural.Size = Vector3.new(6, 4, 0.05)
	mural.CFrame = alleyOrigin * CFrame.new(0, 4, -3.3)
	mural.Color = Color3.fromRGB(200, 150, 170)
	mural.Material = Enum.Material.SmoothPlastic
	mural.Parent = zone
	local muralGui = Instance.new("SurfaceGui")
	muralGui.Face = Enum.NormalId.Front
	muralGui.Parent = mural
	local muralLabel = Instance.new("TextLabel")
	muralLabel.Size = UDim2.fromScale(1, 1)
	muralLabel.BackgroundTransparency = 1
	muralLabel.Font = Enum.Font.PermanentMarker
	muralLabel.TextScaled = true
	muralLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	muralLabel.Text = "sen de burayı buldun 💛"
	muralLabel.Parent = muralGui

	PropLibrary.bench(zone, alleyOrigin * CFrame.new(3, 0, 2) * CFrame.Angles(0, math.rad(180), 0), 1)
	PropLibrary.trashCan(zone, alleyOrigin * CFrame.new(-3.5, 0, 2.5))
	PropLibrary.trashCan(zone, alleyOrigin * CFrame.new(-2, 0, 2.5))
	PropLibrary.lanternPost(zone, alleyOrigin * CFrame.new(3.5, 0, -1))

	return zone
end

--- Hard find: tucked behind the pond's dense tree ring, no path leading to it.
function HiddenAreas.buildSecretHideout(container: Instance, PropLibrary: any, pondOrigin: CFrame)
	local zone = Instance.new("Folder")
	zone.Name = "SecretHideout"
	zone.Parent = container

	-- Sits just past the tree ring (radius ~38-41 in PondBridge), north-west corner.
	local hideoutOrigin = pondOrigin * CFrame.new(-46, 0, -40) * CFrame.Angles(0, math.rad(35), 0)

	local hut, doorCFrame = PropLibrary.buildingShell(
		zone,
		hideoutOrigin,
		Vector3.new(9, 6.5, 8),
		Color3.fromRGB(52, 58, 46),
		Color3.fromRGB(36, 40, 32)
	)
	hut.Name = "HideoutHut"

	-- Extra trees crowding right up to the walls so it doesn't read as a building from outside.
	for _, offset in ipairs({ Vector3.new(-6, 0, -5), Vector3.new(6, 0, -6), Vector3.new(-7, 0, 4), Vector3.new(7, 0, 5), Vector3.new(0, 0, -7) }) do
		PropLibrary.tree(zone, hideoutOrigin * CFrame.new(offset), 2)
	end
	PropLibrary.bush(zone, hideoutOrigin * CFrame.new(-3, 0, 4.5), 1.5)
	PropLibrary.bush(zone, hideoutOrigin * CFrame.new(3, 0, 4.5), 1.5)

	-- Cozy interior: a rug, floor cushions, a small table with a candle-lit glow, no lamps —
	-- deliberately dim and intimate compared to the rest of the map.
	local rug = Instance.new("Part")
	rug.Name = "Rug"
	rug.Anchored = true
	rug.CanCollide = false
	rug.Size = Vector3.new(6, 0.1, 5)
	rug.CFrame = hideoutOrigin * CFrame.new(0, 0.5, -1)
	rug.Color = Color3.fromRGB(120, 40, 50)
	rug.Material = Enum.Material.Fabric
	rug.Parent = zone

	for _, offset in ipairs({ Vector3.new(-1.8, 0, -2.2), Vector3.new(1.8, 0, -2.2), Vector3.new(0, 0, 0.8) }) do
		local cushion = Instance.new("Part")
		cushion.Name = "Cushion"
		cushion.Anchored = true
		cushion.CanCollide = false
		cushion.Shape = Enum.PartType.Cylinder
		cushion.Size = Vector3.new(0.6, 1.6, 1.6)
		cushion.CFrame = hideoutOrigin * CFrame.new(offset) * CFrame.new(0, 0.7, 0) * CFrame.Angles(0, 0, math.rad(90))
		cushion.Color = Color3.fromRGB(150, 60, 70)
		cushion.Material = Enum.Material.Fabric
		cushion.Parent = zone
	end

	local table_ = Instance.new("Part")
	table_.Name = "LowTable"
	table_.Anchored = true
	table_.Size = Vector3.new(2, 0.9, 2)
	table_.CFrame = hideoutOrigin * CFrame.new(0, 0.45, -1.6)
	table_.Color = Color3.fromRGB(70, 50, 34)
	table_.Material = Enum.Material.Wood
	table_.Parent = zone

	local candle = Instance.new("Part")
	candle.Name = "Candle"
	candle.Anchored = true
	candle.CanCollide = false
	candle.Shape = Enum.PartType.Cylinder
	candle.Size = Vector3.new(0.6, 0.25, 0.25)
	candle.CFrame = hideoutOrigin * CFrame.new(0, 1, -1.6) * CFrame.Angles(0, 0, math.rad(90))
	candle.Color = Color3.fromRGB(255, 200, 130)
	candle.Material = Enum.Material.Neon
	candle.Parent = zone
	local candleLight = Instance.new("PointLight")
	candleLight.Color = Color3.fromRGB(255, 190, 120)
	candleLight.Brightness = 1.2
	candleLight.Range = 10
	candleLight.Parent = candle

	-- A closed treasure-chest-style box in the corner — pure flavor, nothing to interact with yet.
	local chest = Instance.new("Part")
	chest.Name = "DecorativeChest"
	chest.Anchored = true
	chest.Size = Vector3.new(1.4, 1, 0.9)
	chest.CFrame = hideoutOrigin * CFrame.new(-3, 0.5, 2.8)
	chest.Color = Color3.fromRGB(80, 56, 30)
	chest.Material = Enum.Material.Wood
	chest.Parent = zone

	return zone
end

return HiddenAreas
