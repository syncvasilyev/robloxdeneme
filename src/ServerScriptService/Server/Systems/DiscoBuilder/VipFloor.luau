--!strict
-- A glass-edged staircase up one side wall to an upper VIP balcony overlooking the dance floor,
-- with glass railings and premium lounge seating clusters in the corners.

local VipFloor = {}

local BALCONY_Y = 11

local function buildLoungeSeat(parent: Instance, cframe: CFrame)
	local seatModel = Instance.new("Model")
	seatModel.Name = "LoungeSeat"
	seatModel.Parent = parent

	local base = Instance.new("Part")
	base.Name = "Base"
	base.Anchored = true
	base.Size = Vector3.new(4.4, 1.4, 2)
	base.CFrame = cframe * CFrame.new(0, 0.7, 0)
	base.Color = Color3.fromRGB(30, 22, 28)
	base.Material = Enum.Material.Fabric
	base.Parent = seatModel

	local backrest = Instance.new("Part")
	backrest.Name = "Backrest"
	backrest.Anchored = true
	backrest.Size = Vector3.new(4.4, 1.6, 0.5)
	backrest.CFrame = cframe * CFrame.new(0, 1.9, -0.75)
	backrest.Color = Color3.fromRGB(60, 20, 46)
	backrest.Material = Enum.Material.Fabric
	backrest.Parent = seatModel

	local trim = Instance.new("Part")
	trim.Name = "Trim"
	trim.Anchored = true
	trim.CanCollide = false
	trim.Size = Vector3.new(4.5, 0.08, 0.08)
	trim.CFrame = cframe * CFrame.new(0, 1.42, 1.02)
	trim.Color = Color3.fromRGB(220, 170, 90)
	trim.Material = Enum.Material.Neon
	trim.Parent = seatModel

	local table_ = Instance.new("Part")
	table_.Name = "Table"
	table_.Anchored = true
	table_.Shape = Enum.PartType.Cylinder
	table_.Size = Vector3.new(0.1, 1.6, 1.6)
	table_.CFrame = cframe * CFrame.new(0, 1.1, 1.8) * CFrame.Angles(0, 0, math.rad(90))
	table_.Color = Color3.fromRGB(20, 20, 22)
	table_.Material = Enum.Material.Glass
	table_.Transparency = 0.2
	table_.Parent = seatModel

	return seatModel
end

--- roomSize: same Vector3 ClubShell.build returned, so the staircase/balcony fit the room.
function VipFloor.build(container: Instance, roomSize: Vector3)
	local zone = Instance.new("Folder")
	zone.Name = "VipFloor"
	zone.Parent = container

	local stairX = -roomSize.X / 2 + 4
	local stairStartZ = roomSize.Z / 2 - 6
	local stepCount = 14
	local stepRun = 1.4

	for i = 1, stepCount do
		local step = Instance.new("Part")
		step.Name = "GlassStep"
		step.Anchored = true
		step.Size = Vector3.new(7, 0.4, stepRun)
		step.CFrame = CFrame.new(stairX, i * (BALCONY_Y / stepCount), stairStartZ - i * stepRun)
		step.Color = Color3.fromRGB(150, 200, 230)
		step.Material = Enum.Material.Glass
		step.Transparency = 0.35
		step.Parent = zone

		local stepEdge = Instance.new("Part")
		stepEdge.Name = "StepEdge"
		stepEdge.Anchored = true
		stepEdge.CanCollide = false
		stepEdge.Size = Vector3.new(7.1, 0.06, 0.1)
		stepEdge.CFrame = step.CFrame * CFrame.new(0, 0.22, stepRun / 2)
		stepEdge.Color = Color3.fromRGB(120, 60, 220)
		stepEdge.Material = Enum.Material.Neon
		stepEdge.Parent = zone
	end

	-- Glass railing running alongside the staircase.
	for _, xSign in ipairs({ -1, 1 }) do
		local railing = Instance.new("Part")
		railing.Name = "StairRailing"
		railing.Anchored = true
		railing.CanCollide = false
		railing.Size = Vector3.new(0.15, BALCONY_Y + 2, stepCount * stepRun)
		railing.CFrame = CFrame.new(stairX + xSign * 3.4, BALCONY_Y / 2 + 1, stairStartZ - (stepCount * stepRun) / 2)
			* CFrame.Angles(math.atan2(BALCONY_Y, stepCount * stepRun), 0, 0)
		railing.Color = Color3.fromRGB(150, 200, 230)
		railing.Material = Enum.Material.Glass
		railing.Transparency = 0.55
		railing.Parent = zone
	end

	-- Balcony platform along the back third of the room, overlooking the dance floor.
	local balconyDepth = 16
	local balconyZ = roomSize.Z / 2 - balconyDepth / 2 - 2
	local balconyFloor = Instance.new("Part")
	balconyFloor.Name = "BalconyFloor"
	balconyFloor.Anchored = true
	balconyFloor.Size = Vector3.new(roomSize.X - 4, 0.6, balconyDepth)
	balconyFloor.CFrame = CFrame.new(0, BALCONY_Y, balconyZ)
	balconyFloor.Color = Color3.fromRGB(22, 18, 22)
	balconyFloor.Material = Enum.Material.Marble
	balconyFloor.Parent = zone

	-- Glass railing along the balcony's inner (dance-floor-facing) edge.
	local innerRailing = Instance.new("Part")
	innerRailing.Name = "BalconyRailing"
	innerRailing.Anchored = true
	innerRailing.CanCollide = false
	innerRailing.Size = Vector3.new(roomSize.X - 4, 3.2, 0.2)
	innerRailing.CFrame = CFrame.new(0, BALCONY_Y + 1.9, balconyZ - balconyDepth / 2)
	innerRailing.Color = Color3.fromRGB(150, 200, 230)
	innerRailing.Material = Enum.Material.Glass
	innerRailing.Transparency = 0.5
	innerRailing.Parent = zone
	local railingTrim = Instance.new("Part")
	railingTrim.Name = "BalconyRailingTrim"
	railingTrim.Anchored = true
	railingTrim.CanCollide = false
	railingTrim.Size = Vector3.new(roomSize.X - 4, 0.1, 0.1)
	railingTrim.CFrame = CFrame.new(0, BALCONY_Y + 3.4, balconyZ - balconyDepth / 2)
	railingTrim.Color = Color3.fromRGB(220, 170, 90)
	railingTrim.Material = Enum.Material.Neon
	railingTrim.Parent = zone

	-- Premium lounge seating clusters in the two back corners, each with a glass-walled nook.
	for _, xSign in ipairs({ -1, 1 }) do
		local corner = CFrame.new(xSign * (roomSize.X / 2 - 8), BALCONY_Y + 0.3, balconyZ + balconyDepth / 2 - 3)
			* CFrame.Angles(0, math.rad(xSign * 30), 0)
		buildLoungeSeat(zone, corner)
		buildLoungeSeat(zone, corner * CFrame.new(0, 0, -5) * CFrame.Angles(0, math.rad(180), 0))

		local glassWall = Instance.new("Part")
		glassWall.Name = "NookGlassWall"
		glassWall.Anchored = true
		glassWall.CanCollide = false
		glassWall.Size = Vector3.new(0.15, 4, 7)
		glassWall.CFrame = corner * CFrame.new(xSign * 4, 2.3, -2.5)
		glassWall.Color = Color3.fromRGB(150, 200, 230)
		glassWall.Material = Enum.Material.Glass
		glassWall.Transparency = 0.6
		glassWall.Parent = zone
	end

	return zone
end

return VipFloor
