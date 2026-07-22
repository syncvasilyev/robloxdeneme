--!strict
-- Reusable street-furniture / greenery / building-shell constructors, built from plain Parts.
-- Every constructor takes (parent: Instance, cframe: CFrame, ...) and returns the Model it built,
-- positioned so `cframe` is where the prop "stands" (its base, facing +Z by convention).

local PropLibrary = {}

local function newPart(config: {
	Size: Vector3,
	CFrame: CFrame,
	Color: Color3,
	Material: Enum.Material?,
	Shape: Enum.PartType?,
	CanCollide: boolean?,
	Transparency: number?,
	Name: string?,
}): Part
	local part = Instance.new("Part")
	part.Anchored = true
	part.Size = config.Size
	part.CFrame = config.CFrame
	part.Color = config.Color
	part.Material = config.Material or Enum.Material.SmoothPlastic
	part.Shape = config.Shape or Enum.PartType.Block
	part.CanCollide = if config.CanCollide == nil then true else config.CanCollide
	part.Transparency = config.Transparency or 0
	part.Name = config.Name or "Part"
	return part
end

local function newModel(parent: Instance, name: string, pivot: CFrame): Model
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	model:PivotTo(pivot)
	return model
end

--- A park bench. styleIndex (1-3) picks wood/metal/stone so rows of benches don't look identical.
function PropLibrary.bench(parent: Instance, cframe: CFrame, styleIndex: number?): Model
	local style = styleIndex or 1
	local palettes = {
		{ frame = Color3.fromRGB(58, 42, 30), seat = Color3.fromRGB(120, 84, 52), material = Enum.Material.Wood },
		{ frame = Color3.fromRGB(40, 40, 44), seat = Color3.fromRGB(60, 60, 66), material = Enum.Material.Metal },
		{ frame = Color3.fromRGB(90, 88, 84), seat = Color3.fromRGB(120, 118, 112), material = Enum.Material.Concrete },
	}
	local palette = palettes[((style - 1) % #palettes) + 1]

	local model = newModel(parent, "Bench", cframe)
	local seat = newPart({
		Size = Vector3.new(5, 0.25, 1.6),
		CFrame = cframe * CFrame.new(0, 1.5, 0),
		Color = palette.seat,
		Material = palette.material,
		Name = "Seat",
	})
	seat.Parent = model
	local back = newPart({
		Size = Vector3.new(5, 1.1, 0.2),
		CFrame = cframe * CFrame.new(0, 2.15, -0.7),
		Color = palette.seat,
		Material = palette.material,
		Name = "Backrest",
	})
	back.Parent = model
	for _, xOffset in ipairs({ -2.1, 2.1 }) do
		local leg = newPart({
			Size = Vector3.new(0.2, 1.5, 1.6),
			CFrame = cframe * CFrame.new(xOffset, 0.75, 0),
			Color = palette.frame,
			Material = Enum.Material.Metal,
			Name = "Leg",
		})
		leg.Parent = model
	end
	model.PrimaryPart = seat
	return model
end

--- A picnic table (bench seats attached to the table).
function PropLibrary.picnicTable(parent: Instance, cframe: CFrame): Model
	local model = newModel(parent, "PicnicTable", cframe)
	local top = newPart({
		Size = Vector3.new(2.8, 0.2, 5.5),
		CFrame = cframe * CFrame.new(0, 1.6, 0),
		Color = Color3.fromRGB(110, 78, 48),
		Material = Enum.Material.Wood,
		Name = "Top",
	})
	top.Parent = model
	for _, xOffset in ipairs({ -1.6, 1.6 }) do
		local seat = newPart({
			Size = Vector3.new(1.4, 0.2, 5.5),
			CFrame = cframe * CFrame.new(xOffset, 1.05, 0),
			Color = Color3.fromRGB(96, 66, 40),
			Material = Enum.Material.Wood,
			Name = "Seat",
		})
		seat.Parent = model
	end
	for _, zOffset in ipairs({ -2.2, 2.2 }) do
		local frameLeg = newPart({
			Size = Vector3.new(2.6, 1.5, 0.2),
			CFrame = cframe * CFrame.new(0, 0.8, zOffset) * CFrame.Angles(0, 0, math.rad(20)),
			Color = Color3.fromRGB(60, 42, 26),
			Material = Enum.Material.Wood,
			Name = "TrestleLeg",
		})
		frameLeg.Parent = model
	end
	model.PrimaryPart = top
	return model
end

--- A small round café table with two chairs, for the cafeteria and shop-front nooks.
function PropLibrary.smallCafeTable(parent: Instance, cframe: CFrame): Model
	local model = newModel(parent, "CafeTable", cframe)
	local pole = newPart({
		Size = Vector3.new(0.3, 1.7, 0.3),
		CFrame = cframe * CFrame.new(0, 0.85, 0),
		Color = Color3.fromRGB(30, 30, 32),
		Material = Enum.Material.Metal,
		Name = "Pole",
	})
	pole.Parent = model
	local top = newPart({
		Size = Vector3.new(0.15, 2.2, 2.2),
		CFrame = cframe * CFrame.new(0, 1.75, 0) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(60, 44, 34),
		Material = Enum.Material.Wood,
		Shape = Enum.PartType.Cylinder,
		Name = "Top",
	})
	top.Parent = model
	for _, angle in ipairs({ 60, 240 }) do
		local chairCFrame = cframe * CFrame.new(0, 0, 1.5) * CFrame.Angles(0, math.rad(angle), 0) * CFrame.new(0, 0, 1.3)
		local chairSeat = newPart({
			Size = Vector3.new(1.2, 0.15, 1.2),
			CFrame = chairCFrame * CFrame.new(0, 1.1, 0),
			Color = Color3.fromRGB(40, 40, 44),
			Material = Enum.Material.Metal,
			Name = "ChairSeat",
		})
		chairSeat.Parent = model
		local chairBack = newPart({
			Size = Vector3.new(1.2, 1, 0.15),
			CFrame = chairCFrame * CFrame.new(0, 1.7, 0.55),
			Color = Color3.fromRGB(40, 40, 44),
			Material = Enum.Material.Metal,
			Name = "ChairBack",
		})
		chairBack.Parent = model
	end
	model.PrimaryPart = pole
	return model
end

--- A working street lamp. styleIndex 1 = modern boxy, 2 = classic curved lantern post.
function PropLibrary.streetLamp(parent: Instance, cframe: CFrame, styleIndex: number?): Model
	local style = styleIndex or 1
	local model = newModel(parent, "StreetLamp", cframe)
	local pole = newPart({
		Size = Vector3.new(0.35, 9, 0.35),
		CFrame = cframe * CFrame.new(0, 4.5, 0),
		Color = Color3.fromRGB(28, 28, 30),
		Material = Enum.Material.Metal,
		Name = "Pole",
	})
	pole.Parent = model

	local headCFrame = cframe * CFrame.new(0, 9, 0)
	local headSize = if style == 1 then Vector3.new(1, 0.6, 1) else Vector3.new(0.9, 0.9, 0.9)
	local head = newPart({
		Size = headSize,
		CFrame = headCFrame,
		Color = Color3.fromRGB(20, 20, 22),
		Material = Enum.Material.Metal,
		Shape = if style == 1 then Enum.PartType.Block else Enum.PartType.Ball,
		Name = "Head",
	})
	head.Parent = model

	local bulb = newPart({
		Size = headSize * 0.6,
		CFrame = headCFrame,
		Color = Color3.fromRGB(255, 214, 150),
		Material = Enum.Material.Neon,
		CanCollide = false,
		Name = "Bulb",
	})
	bulb.Parent = model

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 205, 140)
	light.Brightness = 2.2
	light.Range = 22
	light.Shadows = true
	light.Parent = bulb

	model.PrimaryPart = pole
	return model
end

--- A standing decorative lantern for quiet corners/gardens (warmer, dimmer than street lamps).
function PropLibrary.lanternPost(parent: Instance, cframe: CFrame): Model
	local model = newModel(parent, "LanternPost", cframe)
	local pole = newPart({
		Size = Vector3.new(0.25, 4.5, 0.25),
		CFrame = cframe * CFrame.new(0, 2.25, 0),
		Color = Color3.fromRGB(35, 30, 26),
		Material = Enum.Material.Wood,
		Name = "Pole",
	})
	pole.Parent = model
	local lantern = newPart({
		Size = Vector3.new(0.7, 0.9, 0.7),
		CFrame = cframe * CFrame.new(0, 4.6, 0),
		Color = Color3.fromRGB(255, 196, 120),
		Material = Enum.Material.Glass,
		CanCollide = false,
		Name = "LanternGlass",
	})
	lantern.Parent = model
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 190, 110)
	light.Brightness = 1.4
	light.Range = 14
	light.Parent = lantern
	model.PrimaryPart = pole
	return model
end

function PropLibrary.trashCan(parent: Instance, cframe: CFrame): Model
	local model = newModel(parent, "TrashCan", cframe)
	local body = newPart({
		Size = Vector3.new(1.4, 2.2, 1.4),
		CFrame = cframe * CFrame.new(0, 1.1, 0),
		Color = Color3.fromRGB(46, 56, 48),
		Material = Enum.Material.DiamondPlate,
		Shape = Enum.PartType.Cylinder,
		Name = "Body",
	})
	body.CFrame = cframe * CFrame.new(0, 1.1, 0) * CFrame.Angles(0, 0, math.rad(90))
	body.Size = Vector3.new(2.2, 1.4, 1.4)
	body.Parent = model
	local lid = newPart({
		Size = Vector3.new(1.5, 0.15, 1.5),
		CFrame = cframe * CFrame.new(0, 2.25, 0),
		Color = Color3.fromRGB(30, 38, 32),
		Material = Enum.Material.Metal,
		Name = "Lid",
	})
	lid.Parent = model
	model.PrimaryPart = body
	return model
end

--- A tree. variant 1 = round leafy canopy, 2 = tall pine.
function PropLibrary.tree(parent: Instance, cframe: CFrame, variant: number?): Model
	local kind = variant or 1
	local model = newModel(parent, "Tree", cframe)
	local trunkHeight = if kind == 1 then 5 else 7
	local trunk = newPart({
		Size = Vector3.new(0.9, trunkHeight, 0.9),
		CFrame = cframe * CFrame.new(0, trunkHeight / 2, 0),
		Color = Color3.fromRGB(58, 40, 26),
		Material = Enum.Material.Bark,
		Name = "Trunk",
	})
	trunk.Parent = model

	if kind == 1 then
		for i, offset in ipairs({ Vector3.new(0, 0, 0), Vector3.new(1.2, 0.6, 0.4), Vector3.new(-1, 0.4, -0.6) }) do
			local canopy = newPart({
				Size = Vector3.new(4.2, 4, 4.2) - Vector3.new(1, 1, 1) * (i - 1) * 0.4,
				CFrame = cframe * CFrame.new(offset) * CFrame.new(0, trunkHeight + 1.6, 0),
				Color = Color3.fromRGB(38 + i * 4, 74 + i * 3, 42),
				Material = Enum.Material.Grass,
				Shape = Enum.PartType.Ball,
				CanCollide = false,
				Name = "Canopy",
			})
			canopy.Parent = model
		end
	else
		for tier = 1, 4 do
			local size = 4.4 - tier * 0.8
			local cone = newPart({
				Size = Vector3.new(size, 1.8, size),
				CFrame = cframe * CFrame.new(0, trunkHeight - 1 + tier * 1.5, 0),
				Color = Color3.fromRGB(30, 62, 40),
				Material = Enum.Material.Grass,
				CanCollide = false,
				Name = "Tier",
			})
			cone.Parent = model
		end
	end
	model.PrimaryPart = trunk
	return model
end

function PropLibrary.bush(parent: Instance, cframe: CFrame, radius: number?): Model
	local r = radius or 1.4
	local model = newModel(parent, "Bush", cframe)
	for _, offset in ipairs({ Vector3.new(0, 0, 0), Vector3.new(r * 0.5, 0.2, r * 0.3), Vector3.new(-r * 0.4, 0.1, -r * 0.4) }) do
		local clump = newPart({
			Size = Vector3.new(r * 1.6, r * 1.3, r * 1.6),
			CFrame = cframe * CFrame.new(offset) * CFrame.new(0, r * 0.6, 0),
			Color = Color3.fromRGB(36, 70, 40),
			Material = Enum.Material.Grass,
			Shape = Enum.PartType.Ball,
			CanCollide = false,
			Name = "Clump",
		})
		clump.Parent = model
	end
	return model
end

function PropLibrary.flowerBed(parent: Instance, cframe: CFrame, size: Vector2?): Model
	local dims = size or Vector2.new(3, 2)
	local model = newModel(parent, "FlowerBed", cframe)
	local soil = newPart({
		Size = Vector3.new(dims.X, 0.4, dims.Y),
		CFrame = cframe * CFrame.new(0, 0.2, 0),
		Color = Color3.fromRGB(54, 38, 28),
		Material = Enum.Material.Ground,
		Name = "Soil",
	})
	soil.Parent = model
	local flowerColors = {
		Color3.fromRGB(220, 90, 120),
		Color3.fromRGB(240, 200, 80),
		Color3.fromRGB(180, 120, 220),
		Color3.fromRGB(230, 230, 240),
	}
	local count = math.floor(dims.X * dims.Y * 1.6)
	for i = 1, count do
		local x = (math.random() - 0.5) * (dims.X - 0.4)
		local z = (math.random() - 0.5) * (dims.Y - 0.4)
		local flower = newPart({
			Size = Vector3.new(0.25, 0.5, 0.25),
			CFrame = cframe * CFrame.new(x, 0.6, z),
			Color = flowerColors[(i % #flowerColors) + 1],
			Material = Enum.Material.Neon,
			CanCollide = false,
			Name = "Flower",
		})
		flower.Parent = model
	end
	model.PrimaryPart = soil
	return model
end

function PropLibrary.streetSign(parent: Instance, cframe: CFrame, text: string): Model
	local model = newModel(parent, "StreetSign", cframe)
	local pole = newPart({
		Size = Vector3.new(0.2, 6, 0.2),
		CFrame = cframe * CFrame.new(0, 3, 0),
		Color = Color3.fromRGB(60, 60, 64),
		Material = Enum.Material.Metal,
		Name = "Pole",
	})
	pole.Parent = model
	local sign = newPart({
		Size = Vector3.new(3, 0.7, 0.1),
		CFrame = cframe * CFrame.new(0, 5.6, 0),
		Color = Color3.fromRGB(20, 60, 40),
		Material = Enum.Material.Metal,
		CanCollide = false,
		Name = "Sign",
	})
	sign.Parent = model
	local surface = Instance.new("SurfaceGui")
	surface.Face = Enum.NormalId.Front
	surface.Parent = sign
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(245, 245, 245)
	label.Text = text
	label.Parent = surface
	model.PrimaryPart = pole
	return model
end

--- A glowing window pane, meant to be sunk into a building wall. Purely decorative light source.
function PropLibrary.windowLight(parent: Instance, cframe: CFrame, size: Vector3): Part
	local pane = newPart({
		Size = size,
		CFrame = cframe,
		Color = Color3.fromRGB(255, 214, 150),
		Material = Enum.Material.Neon,
		CanCollide = false,
		Name = "WindowLight",
		Transparency = 0.1,
	})
	pane.Parent = parent
	return pane
end

--- A simple box building shell: floor, four walls with a door gap, flat roof. Returns the model
--- plus the door CFrame (world space, at the opening) so callers can add interior dressing.
function PropLibrary.buildingShell(
	parent: Instance,
	cframe: CFrame,
	size: Vector3,
	wallColor: Color3,
	roofColor: Color3
): (Model, CFrame)
	local model = newModel(parent, "Building", cframe)
	local halfX, halfY, halfZ = size.X / 2, size.Y / 2, size.Z / 2

	local floor = newPart({
		Size = Vector3.new(size.X, 0.4, size.Z),
		CFrame = cframe * CFrame.new(0, 0.2, 0),
		Color = Color3.fromRGB(70, 66, 60),
		Material = Enum.Material.WoodPlanks,
		Name = "Floor",
	})
	floor.Parent = model

	local roof = newPart({
		Size = Vector3.new(size.X + 0.6, 0.5, size.Z + 0.6),
		CFrame = cframe * CFrame.new(0, size.Y, 0),
		Color = roofColor,
		Material = Enum.Material.Slate,
		Name = "Roof",
	})
	roof.Parent = model

	local doorWidth = 4
	-- Front wall (split around a door gap).
	local leftWidth = (size.X - doorWidth) / 2
	local frontLeft = newPart({
		Size = Vector3.new(leftWidth, size.Y, 0.4),
		CFrame = cframe * CFrame.new(-halfX + leftWidth / 2, size.Y / 2, halfZ),
		Color = wallColor,
		Material = Enum.Material.Brick,
		Name = "FrontWallLeft",
	})
	frontLeft.Parent = model
	local frontRight = newPart({
		Size = Vector3.new(leftWidth, size.Y, 0.4),
		CFrame = cframe * CFrame.new(halfX - leftWidth / 2, size.Y / 2, halfZ),
		Color = wallColor,
		Material = Enum.Material.Brick,
		Name = "FrontWallRight",
	})
	frontRight.Parent = model
	local lintel = newPart({
		Size = Vector3.new(doorWidth, size.Y - 6.5, 0.4),
		CFrame = cframe * CFrame.new(0, size.Y - (size.Y - 6.5) / 2, halfZ),
		Color = wallColor,
		Material = Enum.Material.Brick,
		Name = "DoorLintel",
	})
	lintel.Parent = model

	local back = newPart({
		Size = Vector3.new(size.X, size.Y, 0.4),
		CFrame = cframe * CFrame.new(0, size.Y / 2, -halfZ),
		Color = wallColor,
		Material = Enum.Material.Brick,
		Name = "BackWall",
	})
	back.Parent = model
	local left = newPart({
		Size = Vector3.new(0.4, size.Y, size.Z),
		CFrame = cframe * CFrame.new(-halfX, size.Y / 2, 0),
		Color = wallColor,
		Material = Enum.Material.Brick,
		Name = "LeftWall",
	})
	left.Parent = model
	local right = newPart({
		Size = Vector3.new(0.4, size.Y, size.Z),
		CFrame = cframe * CFrame.new(halfX, size.Y / 2, 0),
		Color = wallColor,
		Material = Enum.Material.Brick,
		Name = "RightWall",
	})
	right.Parent = model

	model.PrimaryPart = floor
	local doorCFrame = cframe * CFrame.new(0, 3.25, halfZ)
	return model, doorCFrame
end

return PropLibrary
