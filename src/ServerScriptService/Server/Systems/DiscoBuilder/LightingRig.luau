--!strict
-- Ceiling spotlights over the dance floor + wall strip lights, all colour-cycled by
-- LightingAnimator.server.luau (see ServerStorage.DiscoAssets) once cloned into a live instance.

local ServerStorage = game:GetService("ServerStorage")

local LightingRig = {}

function LightingRig.build(container: Instance, roomSize: Vector3)
	local zone = Instance.new("Folder")
	zone.Name = "LightingRig"
	zone.Parent = container

	local fixturesFolder = Instance.new("Folder")
	fixturesFolder.Name = "Fixtures"
	fixturesFolder.Parent = zone

	-- Ceiling spotlights in a grid over the dance floor.
	for row = -1, 1 do
		for col = -1, 1 do
			local fixture = Instance.new("Part")
			fixture.Name = "CeilingFixture"
			fixture.Anchored = true
			fixture.CanCollide = false
			fixture.Shape = Enum.PartType.Cylinder
			fixture.Size = Vector3.new(0.6, 0.9, 0.9)
			fixture.CFrame = CFrame.new(col * 9, roomSize.Y - 0.6, row * 9) * CFrame.Angles(0, 0, math.rad(90))
			fixture.Color = Color3.fromRGB(200, 40, 160)
			fixture.Material = Enum.Material.Neon
			fixture.Parent = fixturesFolder

			local spotlight = Instance.new("SpotLight")
			spotlight.Face = Enum.NormalId.Bottom
			spotlight.Color = Color3.fromRGB(200, 40, 160)
			spotlight.Brightness = 4
			spotlight.Range = 30
			spotlight.Angle = 80
			spotlight.Parent = fixture
		end
	end

	-- Wall strip lights running low along the side walls.
	for _, xSign in ipairs({ -1, 1 }) do
		for zOffset = -30, 30, 15 do
			local strip = Instance.new("Part")
			strip.Name = "WallStrip"
			strip.Anchored = true
			strip.CanCollide = false
			strip.Size = Vector3.new(0.1, 0.3, 6)
			strip.CFrame = CFrame.new(xSign * (roomSize.X / 2 - 0.6), 3, zOffset)
			strip.Color = Color3.fromRGB(40, 90, 230)
			strip.Material = Enum.Material.Neon
			strip.Parent = fixturesFolder

			local pointLight = Instance.new("PointLight")
			pointLight.Color = Color3.fromRGB(40, 90, 230)
			pointLight.Brightness = 1.5
			pointLight.Range = 12
			pointLight.Parent = strip
		end
	end

	local animatorTemplate = ServerStorage.DiscoAssets:FindFirstChild("LightingAnimator")
	if animatorTemplate then
		local animator = animatorTemplate:Clone()
		animator.Parent = fixturesFolder
	end

	return zone
end

return LightingRig
