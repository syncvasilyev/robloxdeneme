--!strict
-- A small, cozy plush shop near the main square — purely decorative, no real purchasing. Four
-- original "stage mascot" characters (bear/bunny/chick/fox), each with its own silhouette and
-- costume prop, deliberately evoking a friendly animatronic-band gift shop without copying any
-- specific existing character's design.

local PlushShop = {}

local CHARACTERS = {
	{ kind = "bear", body = Color3.fromRGB(150, 95, 55), accent = Color3.fromRGB(235, 210, 180) },
	{ kind = "bunny", body = Color3.fromRGB(70, 130, 150), accent = Color3.fromRGB(230, 230, 235) },
	{ kind = "chick", body = Color3.fromRGB(225, 195, 60), accent = Color3.fromRGB(235, 150, 60) },
	{ kind = "fox", body = Color3.fromRGB(195, 100, 55), accent = Color3.fromRGB(250, 235, 220) },
}

local function buildPlush(parent: Instance, cframe: CFrame, characterIndex: number)
	local character = CHARACTERS[((characterIndex - 1) % #CHARACTERS) + 1]
	local model = Instance.new("Model")
	model.Name = "Plushie_" .. character.kind
	model.Parent = parent

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Anchored = true
	body.CanCollide = false
	body.Shape = Enum.PartType.Ball
	body.Size = Vector3.new(1.1, 1.3, 1.1)
	body.CFrame = cframe * CFrame.new(0, 0.65, 0)
	body.Color = character.body
	body.Material = Enum.Material.Fabric
	body.Parent = model

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Anchored = true
	head.CanCollide = false
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(0.85, 0.85, 0.85)
	head.CFrame = cframe * CFrame.new(0, 1.45, 0)
	head.Color = character.body
	head.Material = Enum.Material.Fabric
	head.Parent = model

	-- Ears: the main silhouette read for each character (round / tall / small+tufted / pointed).
	if character.kind == "bunny" then
		for _, xOffset in ipairs({ -0.28, 0.28 }) do
			local ear = Instance.new("Part")
			ear.Name = "Ear"
			ear.Anchored = true
			ear.CanCollide = false
			ear.Shape = Enum.PartType.Cylinder
			ear.Size = Vector3.new(0.85, 0.26, 0.16)
			ear.CFrame = cframe * CFrame.new(xOffset, 2.15, 0.05) * CFrame.Angles(0, 0, math.rad(90) + (xOffset > 0 and math.rad(-8) or math.rad(8)))
			ear.Color = character.body
			ear.Material = Enum.Material.Fabric
			ear.Parent = model
			local innerEar = Instance.new("Part")
			innerEar.Name = "InnerEar"
			innerEar.Anchored = true
			innerEar.CanCollide = false
			innerEar.Shape = Enum.PartType.Cylinder
			innerEar.Size = Vector3.new(0.55, 0.14, 0.05)
			innerEar.CFrame = ear.CFrame
			innerEar.Color = character.accent
			innerEar.Material = Enum.Material.Fabric
			innerEar.Parent = model
		end
	elseif character.kind == "fox" then
		for _, xOffset in ipairs({ -0.34, 0.34 }) do
			local ear = Instance.new("Part")
			ear.Name = "Ear"
			ear.Anchored = true
			ear.CanCollide = false
			ear.Shape = Enum.PartType.Ball
			ear.Size = Vector3.new(0.4, 0.5, 0.22)
			ear.CFrame = cframe * CFrame.new(xOffset, 1.92, 0) * CFrame.Angles(0, 0, math.rad(xOffset > 0 and -12 or 12))
			ear.Color = character.body
			ear.Material = Enum.Material.Fabric
			ear.Parent = model
		end
	elseif character.kind == "chick" then
		local tuft = Instance.new("Part")
		tuft.Name = "Tuft"
		tuft.Anchored = true
		tuft.CanCollide = false
		tuft.Shape = Enum.PartType.Ball
		tuft.Size = Vector3.new(0.18, 0.3, 0.18)
		tuft.CFrame = cframe * CFrame.new(0, 2.02, 0.1)
		tuft.Color = character.accent
		tuft.Material = Enum.Material.Fabric
		tuft.Parent = model
		local beak = Instance.new("WedgePart")
		beak.Name = "Beak"
		beak.Anchored = true
		beak.CanCollide = false
		beak.Size = Vector3.new(0.18, 0.22, 0.3)
		beak.CFrame = cframe * CFrame.new(0, 1.42, -0.5) * CFrame.Angles(0, math.rad(180), math.rad(90))
		beak.Color = character.accent
		beak.Material = Enum.Material.SmoothPlastic
		beak.Parent = model
	else
		for _, xOffset in ipairs({ -0.32, 0.32 }) do
			local ear = Instance.new("Part")
			ear.Name = "Ear"
			ear.Anchored = true
			ear.CanCollide = false
			ear.Shape = Enum.PartType.Ball
			ear.Size = Vector3.new(0.34, 0.34, 0.34)
			ear.CFrame = cframe * CFrame.new(xOffset, 1.88, 0)
			ear.Color = character.body
			ear.Material = Enum.Material.Fabric
			ear.Parent = model
		end
	end

	for _, xOffset in ipairs({ -0.2, 0.2 }) do
		local eye = Instance.new("Part")
		eye.Name = "Eye"
		eye.Anchored = true
		eye.CanCollide = false
		eye.Shape = Enum.PartType.Ball
		eye.Size = Vector3.new(0.16, 0.16, 0.16)
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
	belly.Color = character.accent
	belly.Material = Enum.Material.Fabric
	belly.Parent = model

	-- Costume prop: each character gets one distinct "stage outfit" accessory instead of
	-- copying any real character's exact design.
	if character.kind == "bear" then
		local hat = Instance.new("Part")
		hat.Name = "TopHat"
		hat.Anchored = true
		hat.CanCollide = false
		hat.Shape = Enum.PartType.Cylinder
		hat.Size = Vector3.new(0.5, 0.34, 0.34)
		hat.CFrame = cframe * CFrame.new(0, 2.05, 0) * CFrame.Angles(0, 0, math.rad(90))
		hat.Color = Color3.fromRGB(25, 22, 20)
		hat.Material = Enum.Material.Fabric
		hat.Parent = model
		local brim = Instance.new("Part")
		brim.Name = "HatBrim"
		brim.Anchored = true
		brim.CanCollide = false
		brim.Shape = Enum.PartType.Cylinder
		brim.Size = Vector3.new(0.08, 0.55, 0.55)
		brim.CFrame = cframe * CFrame.new(0, 1.86, 0) * CFrame.Angles(0, 0, math.rad(90))
		brim.Color = Color3.fromRGB(25, 22, 20)
		brim.Material = Enum.Material.Fabric
		brim.Parent = model
	elseif character.kind == "bunny" or character.kind == "fox" then
		local bowtie = Instance.new("Part")
		bowtie.Name = "Bowtie"
		bowtie.Anchored = true
		bowtie.CanCollide = false
		bowtie.Size = Vector3.new(0.36, 0.2, 0.14)
		bowtie.CFrame = cframe * CFrame.new(0, 1.02, -0.5)
		bowtie.Color = Color3.fromRGB(150, 25, 30)
		bowtie.Material = Enum.Material.Fabric
		bowtie.Parent = model
	else
		local bib = Instance.new("Part")
		bib.Name = "Bib"
		bib.Anchored = true
		bib.CanCollide = false
		bib.Shape = Enum.PartType.Ball
		bib.Size = Vector3.new(0.4, 0.3, 0.15)
		bib.CFrame = cframe * CFrame.new(0, 0.95, -0.5)
		bib.Color = Color3.fromRGB(230, 230, 235)
		bib.Material = Enum.Material.Fabric
		bib.Parent = model
	end
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

	-- Storefront sign: a retro light-bulb marquee (dark backing frame, ring of bulb lights,
	-- star accents, a little mascot perched on top) — the classic "family pizzeria arcade sign"
	-- look, but with our own name/text so it isn't a copy of anyone's actual logo.
	local marqueeFrame = Instance.new("Part")
	marqueeFrame.Name = "MarqueeFrame"
	marqueeFrame.Anchored = true
	marqueeFrame.CanCollide = false
	marqueeFrame.Size = Vector3.new(9.4, 3, 0.4)
	marqueeFrame.CFrame = doorCFrame * CFrame.new(0, 4.3, 0.35)
	marqueeFrame.Color = Color3.fromRGB(30, 22, 26)
	marqueeFrame.Material = Enum.Material.Metal
	marqueeFrame.Parent = zone

	local signBoard = Instance.new("Part")
	signBoard.Name = "SignBoard"
	signBoard.Anchored = true
	signBoard.CanCollide = false
	signBoard.Size = Vector3.new(8, 2, 0.3)
	signBoard.CFrame = marqueeFrame.CFrame * CFrame.new(0, 0, 0.15)
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

	-- Ring of marquee bulbs around the frame's border, alternating warm colors.
	local bulbColors = { Color3.fromRGB(255, 210, 90), Color3.fromRGB(255, 110, 120) }
	local halfWidth, halfHeight = 4.5, 1.3
	local bulbSpots: { Vector3 } = {}
	for x = -halfWidth, halfWidth, 1.1 do
		table.insert(bulbSpots, Vector3.new(x, halfHeight, 0))
		table.insert(bulbSpots, Vector3.new(x, -halfHeight, 0))
	end
	for y = -halfHeight + 1.1, halfHeight - 1.1, 1.1 do
		table.insert(bulbSpots, Vector3.new(-halfWidth, y, 0))
		table.insert(bulbSpots, Vector3.new(halfWidth, y, 0))
	end
	for i, spot in ipairs(bulbSpots) do
		local bulb = Instance.new("Part")
		bulb.Name = "MarqueeBulb"
		bulb.Anchored = true
		bulb.CanCollide = false
		bulb.Shape = Enum.PartType.Ball
		bulb.Size = Vector3.new(0.22, 0.22, 0.22)
		bulb.CFrame = marqueeFrame.CFrame * CFrame.new(spot + Vector3.new(0, 0, 0.3))
		bulb.Color = bulbColors[(i % #bulbColors) + 1]
		bulb.Material = Enum.Material.Neon
		bulb.Parent = zone
	end

	-- A small star accent and a tiny bear-mascot silhouette perched on top of the frame.
	local star = Instance.new("Part")
	star.Name = "MarqueeStar"
	star.Anchored = true
	star.CanCollide = false
	star.Shape = Enum.PartType.Ball
	star.Size = Vector3.new(0.5, 0.5, 0.5)
	star.CFrame = marqueeFrame.CFrame * CFrame.new(-4.9, 0, 0.3)
	star.Color = Color3.fromRGB(255, 225, 120)
	star.Material = Enum.Material.Neon
	star.Parent = zone

	local mascotHead = Instance.new("Part")
	mascotHead.Name = "MascotHead"
	mascotHead.Anchored = true
	mascotHead.CanCollide = false
	mascotHead.Shape = Enum.PartType.Ball
	mascotHead.Size = Vector3.new(1.1, 1.1, 1.1)
	mascotHead.CFrame = marqueeFrame.CFrame * CFrame.new(4.3, 2.1, 0)
	mascotHead.Color = Color3.fromRGB(150, 95, 55)
	mascotHead.Material = Enum.Material.Fabric
	mascotHead.Parent = zone
	for _, xOffset in ipairs({ -0.4, 0.4 }) do
		local mascotEar = Instance.new("Part")
		mascotEar.Name = "MascotEar"
		mascotEar.Anchored = true
		mascotEar.CanCollide = false
		mascotEar.Shape = Enum.PartType.Ball
		mascotEar.Size = Vector3.new(0.4, 0.4, 0.4)
		mascotEar.CFrame = mascotHead.CFrame * CFrame.new(xOffset, 0.6, 0)
		mascotEar.Color = Color3.fromRGB(150, 95, 55)
		mascotEar.Material = Enum.Material.Fabric
		mascotEar.Parent = zone
	end

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
