--!strict
-- A raised DJ booth facing the dance floor: desk with turntables/mixer, two glowing screens,
-- flanking speaker stacks. Purely a stage prop — the actual song-ID system lives in the Party
-- tab UI (see PartyTabUI/PartySystem), gated by per-party DJ permission.

local DjBooth = {}

function DjBooth.build(container: Instance, boothCFrame: CFrame)
	local zone = Instance.new("Folder")
	zone.Name = "DjBooth"
	zone.Parent = container

	local platform = Instance.new("Part")
	platform.Name = "Platform"
	platform.Anchored = true
	platform.Size = Vector3.new(16, 1.2, 6)
	platform.CFrame = boothCFrame * CFrame.new(0, 0.6, 0)
	platform.Color = Color3.fromRGB(18, 16, 18)
	platform.Material = Enum.Material.Metal
	platform.Parent = zone

	local desk = Instance.new("Part")
	desk.Name = "Desk"
	desk.Anchored = true
	desk.Size = Vector3.new(12, 2.6, 2)
	desk.CFrame = boothCFrame * CFrame.new(0, 2.5, 1.6)
	desk.Color = Color3.fromRGB(24, 20, 24)
	desk.Material = Enum.Material.Metal
	desk.Parent = zone

	local deskTrim = Instance.new("Part")
	deskTrim.Name = "DeskTrim"
	deskTrim.Anchored = true
	deskTrim.CanCollide = false
	deskTrim.Size = Vector3.new(12.2, 0.15, 0.15)
	deskTrim.CFrame = boothCFrame * CFrame.new(0, 3.75, 2.55)
	deskTrim.Color = Color3.fromRGB(230, 40, 160)
	deskTrim.Material = Enum.Material.Neon
	deskTrim.Parent = zone

	for _, xOffset in ipairs({ -2.6, 2.6 }) do
		local turntable = Instance.new("Part")
		turntable.Name = "Turntable"
		turntable.Anchored = true
		turntable.Shape = Enum.PartType.Cylinder
		turntable.Size = Vector3.new(0.3, 1.6, 1.6)
		turntable.CFrame = boothCFrame * CFrame.new(xOffset, 3.85, 0.9) * CFrame.Angles(0, 0, math.rad(90))
		turntable.Color = Color3.fromRGB(10, 10, 10)
		turntable.Material = Enum.Material.SmoothPlastic
		turntable.Parent = zone
		local record = Instance.new("Part")
		record.Name = "Record"
		record.Anchored = true
		record.CanCollide = false
		record.Shape = Enum.PartType.Cylinder
		record.Size = Vector3.new(0.05, 1.3, 1.3)
		record.CFrame = turntable.CFrame * CFrame.new(0, 0.18, 0)
		record.Color = Color3.fromRGB(200, 60, 90)
		record.Material = Enum.Material.Neon
		record.Parent = zone
	end

	local mixer = Instance.new("Part")
	mixer.Name = "Mixer"
	mixer.Anchored = true
	mixer.Size = Vector3.new(2.4, 0.3, 1.4)
	mixer.CFrame = boothCFrame * CFrame.new(0, 3.9, 0.9)
	mixer.Color = Color3.fromRGB(14, 12, 14)
	mixer.Material = Enum.Material.Metal
	mixer.Parent = zone
	for i = -2, 2 do
		local fader = Instance.new("Part")
		fader.Name = "Fader"
		fader.Anchored = true
		fader.CanCollide = false
		fader.Size = Vector3.new(0.15, 0.1, 0.5)
		fader.CFrame = mixer.CFrame * CFrame.new(i * 0.4, 0.2, 0)
		fader.Color = if i % 2 == 0 then Color3.fromRGB(230, 40, 160) else Color3.fromRGB(40, 200, 230)
		fader.Material = Enum.Material.Neon
		fader.Parent = zone
	end

	-- Screens above the desk.
	for _, xOffset in ipairs({ -3.2, 3.2 }) do
		local screen = Instance.new("Part")
		screen.Name = "Screen"
		screen.Anchored = true
		screen.CanCollide = false
		screen.Size = Vector3.new(3, 2, 0.15)
		screen.CFrame = boothCFrame * CFrame.new(xOffset, 6.3, 2.5) * CFrame.Angles(0, 0, 0)
		screen.Color = Color3.fromRGB(120, 20, 160)
		screen.Material = Enum.Material.Neon
		screen.Parent = zone
		local screenGui = Instance.new("SurfaceGui")
		screenGui.Face = Enum.NormalId.Front
		screenGui.Parent = screen
		local waveLabel = Instance.new("TextLabel")
		waveLabel.Size = UDim2.fromScale(1, 1)
		waveLabel.BackgroundTransparency = 1
		waveLabel.Font = Enum.Font.GothamBlack
		waveLabel.TextScaled = true
		waveLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		waveLabel.Text = "♪ ♫ ♪"
		waveLabel.Parent = screenGui
	end

	-- Flanking speaker stacks.
	for _, xOffset in ipairs({ -9, 9 }) do
		for _, stack in ipairs({ 0, 1 }) do
			local speaker = Instance.new("Part")
			speaker.Name = "SpeakerBox"
			speaker.Anchored = true
			speaker.Size = Vector3.new(2.4, 2.6, 2.4)
			speaker.CFrame = boothCFrame * CFrame.new(xOffset, 1.3 + stack * 2.7, 0)
			speaker.Color = Color3.fromRGB(12, 12, 12)
			speaker.Material = Enum.Material.Fabric
			speaker.Parent = zone
			local woofer = Instance.new("Part")
			woofer.Name = "Woofer"
			woofer.Anchored = true
			woofer.CanCollide = false
			woofer.Shape = Enum.PartType.Cylinder
			woofer.Size = Vector3.new(0.15, 1.7, 1.7)
			woofer.CFrame = speaker.CFrame * CFrame.new(0, 0, 1.2) * CFrame.Angles(0, math.rad(90), 0)
			woofer.Color = Color3.fromRGB(30, 30, 32)
			woofer.Material = Enum.Material.Metal
			woofer.Parent = zone
		end
	end

	local boothLight = Instance.new("Part")
	boothLight.Name = "BoothGlow"
	boothLight.Anchored = true
	boothLight.CanCollide = false
	boothLight.Transparency = 1
	boothLight.Size = Vector3.new(1, 1, 1)
	boothLight.CFrame = boothCFrame * CFrame.new(0, 5, 0)
	boothLight.Parent = zone
	local pointLight = Instance.new("PointLight")
	pointLight.Color = Color3.fromRGB(200, 40, 200)
	pointLight.Brightness = 3
	pointLight.Range = 22
	pointLight.Parent = boothLight

	return zone
end

return DjBooth
