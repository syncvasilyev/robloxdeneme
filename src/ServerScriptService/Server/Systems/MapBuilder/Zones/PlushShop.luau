--!strict
-- A small, cozy plush shop near the main square — purely decorative, no real purchasing. Uses
-- original bear/rabbit/fox-style plush designs (not FNAF character copies) to keep the same
-- "cute animatronic plushie shelf" vibe without a copyright risk.

local PlushShop = {}

local PLUSH_COLORS = {
	{ body = Color3.fromRGB(180, 90, 60), accent = Color3.fromRGB(235, 210, 180) },
	{ body = Color3.fromRGB(90, 140, 170), accent = Color3.fromRGB(230, 230, 235) },
	{ body = Color3.fromRGB(160, 80, 150), accent = Color3.fromRGB(240, 210, 230) },
	{ body = Color3.fromRGB(210, 180, 70), accent = Color3.fromRGB(90, 60, 40) },
}

local function buildPlush(parent: Instance, cframe: CFrame, paletteIndex: number)
	local palette = PLUSH_COLORS[((paletteIndex - 1) % #PLUSH_COLORS) + 1]
	local model = Instance.new("Model")
	model.Name = "Plushie"
	model.Parent = parent

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Anchored = true
	body.CanCollide = false
	body.Shape = Enum.PartType.Ball
	body.Size = Vector3.new(1.1, 1.3, 1.1)
	body.CFrame = cframe * CFrame.new(0, 0.65, 0)
	body.Color = palette.body
	body.Material = Enum.Material.Fabric
	body.Parent = model

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Anchored = true
	head.CanCollide = false
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(0.85, 0.85, 0.85)
	head.CFrame = cframe * CFrame.new(0, 1.45, 0)
	head.Color = palette.body
	head.Material = Enum.Material.Fabric
	head.Parent = model

	for _, xOffset in ipairs({ -0.32, 0.32 }) do
		local ear = Instance.new("Part")
		ear.Name = "Ear"
		ear.Anchored = true
		ear.CanCollide = false
		ear.Shape = Enum.PartType.Ball
		ear.Size = Vector3.new(0.3, 0.3, 0.3)
		ear.CFrame = cframe * CFrame.new(xOffset, 1.85, 0)
		ear.Color = palette.body
		ear.Material = Enum.Material.Fabric
		ear.Parent = model
	end

	for _, xOffset in ipairs({ -0.2, 0.2 }) do
		local eye = Instance.new("Part")
		eye.Name = "Eye"
		eye.Anchored = true
		eye.CanCollide = false
		eye.Shape = Enum.PartType.Ball
		eye.Size = Vector3.new(0.14, 0.14, 0.14)
		eye.CFrame = cframe * CFrame.new(xOffset, 1.5, -0.38)
		eye.Color = Color3.fromRGB(20, 18, 18)
		eye.Material = Enum.Material.SmoothPlastic
		eye.Parent = model
	end

	local belly = Instance.new("Part")
	belly.Name = "Belly"
	belly.Anchored = true
	belly.CanCollide = false
	belly.Shape = Enum.PartType.Ball
	belly.Size = Vector3.new(0.6, 0.7, 0.35)
	belly.CFrame = cframe * CFrame.new(0, 0.6, -0.42)
	belly.Color = palette.accent
	belly.Material = Enum.Material.Fabric
	belly.Parent = model
end

function PlushShop.build(container: Instance, PropLibrary: any, origin: CFrame)
	local zone = Instance.new("Folder")
	zone.Name = "PlushShop"
	zone.Parent = container

	local building, doorCFrame = PropLibrary.buildingShell(
		zone,
		origin,
		Vector3.new(16, 11, 14),
		Color3.fromRGB(150, 70, 90),
		Color3.fromRGB(70, 30, 40)
	)
	building.Name = "ShopBuilding"

	-- Storefront sign, lit from below.
	local signBoard = Instance.new("Part")
	signBoard.Name = "SignBoard"
	signBoard.Anchored = true
	signBoard.CanCollide = false
	signBoard.Size = Vector3.new(8, 2, 0.3)
	signBoard.CFrame = doorCFrame * CFrame.new(0, 4.3, 0.4)
	signBoard.Color = Color3.fromRGB(255, 225, 235)
	signBoard.Material = Enum.Material.Neon
	signBoard.Parent = zone
	local signGui = Instance.new("SurfaceGui")
	signGui.Face = Enum.NormalId.Front
	signGui.Parent = signBoard
	local signLabel = Instance.new("TextLabel")
	signLabel.Size = UDim2.fromScale(1, 1)
	signLabel.BackgroundTransparency = 1
	signLabel.Font = Enum.Font.FredokaOne
	signLabel.TextScaled = true
	signLabel.TextColor3 = Color3.fromRGB(120, 30, 60)
	signLabel.Text = "🧸 PATİLİ DOSTLAR"
	signLabel.Parent = signGui
	local signLight = Instance.new("PointLight")
	signLight.Color = Color3.fromRGB(255, 200, 220)
	signLight.Brightness = 2
	signLight.Range = 14
	signLight.Parent = signBoard

	-- Two big display windows flanking the door, warm-lit from inside.
	for _, xOffset in ipairs({ -5.5, 5.5 }) do
		PropLibrary.windowLight(zone, doorCFrame * CFrame.new(xOffset, -0.7, 0.25), Vector3.new(2.6, 2.6, 0.2))
	end

	-- Interior shelving with plush rows, set back from the door.
	local interiorOrigin = origin * CFrame.new(0, 0, -3.5)
	for shelfIndex, y in ipairs({ 1.4, 2.6, 3.8 }) do
		local shelf = Instance.new("Part")
		shelf.Name = "Shelf"
		shelf.Anchored = true
		shelf.Size = Vector3.new(11, 0.15, 1.4)
		shelf.CFrame = interiorOrigin * CFrame.new(0, y, -3.6)
		shelf.Color = Color3.fromRGB(90, 60, 40)
		shelf.Material = Enum.Material.Wood
		shelf.Parent = zone

		for i = -4, 4, 2 do
			buildPlush(zone, interiorOrigin * CFrame.new(i, y, -3.6), shelfIndex + i)
		end
	end

	-- Decorative counter with a register and a couple of "for display only" plushies.
	local counter = Instance.new("Part")
	counter.Name = "Counter"
	counter.Anchored = true
	counter.Size = Vector3.new(4, 2.2, 1.4)
	counter.CFrame = interiorOrigin * CFrame.new(-4.5, 1.1, 2)
	counter.Color = Color3.fromRGB(120, 70, 60)
	counter.Material = Enum.Material.Wood
	counter.Parent = zone
	local register = Instance.new("Part")
	register.Name = "Register"
	register.Anchored = true
	register.Size = Vector3.new(0.8, 0.6, 0.6)
	register.CFrame = interiorOrigin * CFrame.new(-4.5, 2.5, 2)
	register.Color = Color3.fromRGB(40, 40, 44)
	register.Material = Enum.Material.Metal
	register.Parent = zone
	buildPlush(zone, interiorOrigin * CFrame.new(-3, 2.55, 2), 2)

	-- Price-tag decorations near the window display.
	local priceTag = Instance.new("Part")
	priceTag.Name = "PriceTag"
	priceTag.Anchored = true
	priceTag.CanCollide = false
	priceTag.Size = Vector3.new(0.6, 0.4, 0.05)
	priceTag.CFrame = interiorOrigin * CFrame.new(4.5, 1.5, -3.6) * CFrame.Angles(0, 0, math.rad(15))
	priceTag.Color = Color3.fromRGB(250, 240, 200)
	priceTag.Material = Enum.Material.SmoothPlastic
	priceTag.Parent = zone

	PropLibrary.lanternPost(zone, doorCFrame * CFrame.new(-8.5, 0, 2))
	PropLibrary.lanternPost(zone, doorCFrame * CFrame.new(8.5, 0, 2))
	PropLibrary.flowerBed(zone, doorCFrame * CFrame.new(-6, 0, 3), Vector2.new(2, 1.5))
	PropLibrary.flowerBed(zone, doorCFrame * CFrame.new(6, 0, 3), Vector2.new(2, 1.5))

	return zone
end

return PlushShop
