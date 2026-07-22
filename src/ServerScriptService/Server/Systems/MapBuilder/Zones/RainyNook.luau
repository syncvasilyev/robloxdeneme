--!strict
-- A small, cozy rain-listening nook — NOT a city street. A round glass-walled pavilion with a
-- colorful peaked roof, string lights, and plush cushion seating, with a gentle rain effect
-- confined to just this little footprint (see RainSystem.createRainRegion).

local RainyNook = {}

local PAVILION_RADIUS = 9

local function buildCushionSeat(parent: Instance, cframe: CFrame, color: Color3)
	local cushion = Instance.new("Part")
	cushion.Name = "Cushion"
	cushion.Anchored = true
	cushion.Shape = Enum.PartType.Cylinder
	cushion.Size = Vector3.new(1.1, 3, 3)
	cushion.CFrame = cframe * CFrame.new(0, 0.55, 0) * CFrame.Angles(0, 0, math.rad(90))
	cushion.Color = color
	cushion.Material = Enum.Material.Fabric
	cushion.Parent = parent

	local backCushion = Instance.new("Part")
	backCushion.Name = "BackCushion"
	backCushion.Anchored = true
	backCushion.CanCollide = false
	backCushion.Shape = Enum.PartType.Ball
	backCushion.Size = Vector3.new(3.2, 1.6, 1.2)
	backCushion.CFrame = cframe * CFrame.new(0, 1.5, -1.2)
	backCushion.Color = color
	backCushion.Material = Enum.Material.Fabric
	backCushion.Parent = parent
end

function RainyNook.build(container: Instance, PropLibrary: any, RainSystem: any, origin: CFrame)
	local zone = Instance.new("Folder")
	zone.Name = "RainyNook"
	zone.Parent = container

	-- Small round wooden deck the pavilion sits on, raised slightly off the grass around it.
	local deck = Instance.new("Part")
	deck.Name = "Deck"
	deck.Anchored = true
	deck.Shape = Enum.PartType.Cylinder
	deck.Size = Vector3.new(1, PAVILION_RADIUS * 2, PAVILION_RADIUS * 2)
	deck.CFrame = origin * CFrame.new(0, 0.5, 0) * CFrame.Angles(0, 0, math.rad(90))
	deck.Color = Color3.fromRGB(150, 110, 130)
	deck.Material = Enum.Material.WoodPlanks
	deck.Parent = zone
	RainSystem.wetten(deck)

	-- Slim glass wall panels ringing most of the pavilion (open gaps for walking in/out).
	local panelCount = 8
	for i = 0, panelCount - 1 do
		if i ~= 0 and i ~= 4 then -- leave two open gaps as entrances
			local angle = (i / panelCount) * math.pi * 2
			local point = origin * CFrame.new(math.cos(angle) * (PAVILION_RADIUS - 0.5), 2.2, math.sin(angle) * (PAVILION_RADIUS - 0.5))
				* CFrame.Angles(0, -angle, 0)
			local panel = Instance.new("Part")
			panel.Name = "GlassPanel"
			panel.Anchored = true
			panel.CanCollide = false
			panel.Size = Vector3.new(6.6, 4.4, 0.15)
			panel.CFrame = point
			panel.Color = Color3.fromRGB(230, 200, 240)
			panel.Material = Enum.Material.Glass
			panel.Transparency = 0.55
			panel.Parent = zone
		end
	end

	-- Peaked colorful roof.
	local roofBase = Instance.new("Part")
	roofBase.Name = "RoofBase"
	roofBase.Anchored = true
	roofBase.CanCollide = false
	roofBase.Shape = Enum.PartType.Cylinder
	roofBase.Size = Vector3.new(0.6, (PAVILION_RADIUS + 1) * 2, (PAVILION_RADIUS + 1) * 2)
	roofBase.CFrame = origin * CFrame.new(0, 5, 0) * CFrame.Angles(0, 0, math.rad(90))
	roofBase.Color = Color3.fromRGB(180, 90, 150)
	roofBase.Material = Enum.Material.Neon
	roofBase.Parent = zone
	local roofPeak = Instance.new("Part")
	roofPeak.Name = "RoofPeak"
	roofPeak.Anchored = true
	roofPeak.CanCollide = false
	roofPeak.Shape = Enum.PartType.Ball
	roofPeak.Size = Vector3.new(2.2, 2.6, 2.2)
	roofPeak.CFrame = origin * CFrame.new(0, 6.6, 0)
	roofPeak.Color = Color3.fromRGB(255, 210, 235)
	roofPeak.Material = Enum.Material.Neon
	roofPeak.Parent = zone
	local peakLight = Instance.new("PointLight")
	peakLight.Color = Color3.fromRGB(255, 190, 230)
	peakLight.Brightness = 2
	peakLight.Range = 20
	peakLight.Parent = roofPeak

	for _, post in ipairs({ 0, 1, 2, 3, 5, 6, 7 }) do
		local angle = (post / panelCount) * math.pi * 2
		local pole = Instance.new("Part")
		pole.Name = "RoofPost"
		pole.Anchored = true
		pole.Size = Vector3.new(0.3, 4.6, 0.3)
		pole.CFrame = origin * CFrame.new(math.cos(angle) * (PAVILION_RADIUS - 0.5), 2.4, math.sin(angle) * (PAVILION_RADIUS - 0.5))
		pole.Color = Color3.fromRGB(230, 200, 235)
		pole.Material = Enum.Material.Neon
		pole.Parent = zone
	end

	-- Plush cushion seating clusters inside, facing the middle.
	local seatColors = { Color3.fromRGB(230, 120, 170), Color3.fromRGB(140, 120, 220), Color3.fromRGB(240, 170, 100) }
	for i, angle in ipairs({ 0.6, 2.6, 4.3 }) do
		local seatCFrame = origin * CFrame.new(math.cos(angle) * 4, 0, math.sin(angle) * 4) * CFrame.Angles(0, -angle + math.pi, 0)
		buildCushionSeat(zone, seatCFrame, seatColors[((i - 1) % #seatColors) + 1])
	end

	-- A little rug + low table in the middle to tie the seating cluster together.
	local rug = Instance.new("Part")
	rug.Name = "Rug"
	rug.Anchored = true
	rug.CanCollide = false
	rug.Shape = Enum.PartType.Cylinder
	rug.Size = Vector3.new(0.15, 6, 6)
	rug.CFrame = origin * CFrame.new(0, 0.6, 0) * CFrame.Angles(0, 0, math.rad(90))
	rug.Color = Color3.fromRGB(210, 160, 220)
	rug.Material = Enum.Material.Fabric
	rug.Parent = zone

	-- Gentle rain confined to just the pavilion's footprint — this is the whole point of the
	-- nook, not a citywide weather system.
	RainSystem.createRainRegion(zone, origin, Vector2.new(PAVILION_RADIUS * 2, PAVILION_RADIUS * 2))

	-- String-light glow around the deck's edge and a couple of lanterns just outside.
	for i = 0, 7 do
		local angle = (i / 8) * math.pi * 2
		local bulb = Instance.new("Part")
		bulb.Name = "StringLightBulb"
		bulb.Anchored = true
		bulb.CanCollide = false
		bulb.Shape = Enum.PartType.Ball
		bulb.Size = Vector3.new(0.35, 0.35, 0.35)
		bulb.CFrame = origin * CFrame.new(math.cos(angle) * (PAVILION_RADIUS - 0.5), 4.6, math.sin(angle) * (PAVILION_RADIUS - 0.5))
		bulb.Color = if i % 2 == 0 then Color3.fromRGB(255, 190, 230) else Color3.fromRGB(200, 180, 255)
		bulb.Material = Enum.Material.Neon
		bulb.Parent = zone
	end

	PropLibrary.lanternPost(zone, origin * CFrame.new(PAVILION_RADIUS + 3, 0, 0))
	PropLibrary.lanternPost(zone, origin * CFrame.new(-(PAVILION_RADIUS + 3), 0, 0))
	PropLibrary.flowerBed(zone, origin * CFrame.new(0, 0, PAVILION_RADIUS + 4), Vector2.new(5, 2.5))

	return zone
end

return RainyNook
