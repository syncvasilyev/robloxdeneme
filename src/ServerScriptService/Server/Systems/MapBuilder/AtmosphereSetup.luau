--!strict
-- Dreamy stylized-hangout night mood: navy/purple/soft-pink sky, not a realistic/cool-toned
-- night. Fully bright enough to see the whole map — this is meant to read as "cozy and magical",
-- never dark or moody.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local AtmosphereSetup = {}

local CLOUD_SPECS = {
	{ position = Vector3.new(-60, 340, 40), size = Vector3.new(140, 6, 70), color = Color3.fromRGB(255, 210, 235) },
	{ position = Vector3.new(90, 360, -50), size = Vector3.new(120, 6, 60), color = Color3.fromRGB(210, 190, 255) },
	{ position = Vector3.new(10, 380, 120), size = Vector3.new(160, 6, 80), color = Color3.fromRGB(230, 220, 255) },
	{ position = Vector3.new(-40, 350, -140), size = Vector3.new(130, 6, 65), color = Color3.fromRGB(255, 225, 240) },
}

local function buildSoftClouds()
	local folder = Instance.new("Folder")
	folder.Name = "SoftClouds"
	folder.Parent = Workspace

	for i, spec in ipairs(CLOUD_SPECS) do
		local cloud = Instance.new("Part")
		cloud.Name = "Cloud" .. i
		cloud.Anchored = true
		cloud.CanCollide = false
		cloud.CanQuery = false
		cloud.Shape = Enum.PartType.Ball
		cloud.Size = spec.size
		cloud.Position = spec.position
		cloud.Color = spec.color
		cloud.Material = Enum.Material.Neon
		cloud.Transparency = 0.75
		cloud.Parent = folder
	end
end

function AtmosphereSetup.apply()
	Lighting.ClockTime = 21.5
	Lighting.GeographicLatitude = 0
	Lighting.Brightness = 4
	-- Ambient/OutdoorAmbient carry most of the base visibility (fixtures shouldn't be the only
	-- thing keeping the map from going black) — brighter than a typical "night" preset, and
	-- tinted purple/pink rather than cool blue-grey for the "dreamy" mood.
	Lighting.Ambient = Color3.fromRGB(150, 130, 175)
	Lighting.OutdoorAmbient = Color3.fromRGB(160, 142, 188)
	Lighting.ColorShift_Top = Color3.fromRGB(120, 95, 165)
	Lighting.ColorShift_Bottom = Color3.fromRGB(70, 50, 90)
	Lighting.EnvironmentDiffuseScale = 0.6
	Lighting.EnvironmentSpecularScale = 0.4
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.35
	Lighting.ExposureCompensation = 0.25

	local sky = Instance.new("Sky")
	sky.Name = "DreamySky"
	sky.StarCount = 3500
	sky.CelestialBodiesShown = true
	sky.MoonAngularSize = 16
	sky.SunAngularSize = 0
	sky.Parent = Lighting

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Name = "DreamyAtmosphere"
	atmosphere.Density = 0.1
	atmosphere.Offset = 0.1
	atmosphere.Color = Color3.fromRGB(225, 190, 230)
	atmosphere.Decay = Color3.fromRGB(110, 80, 140)
	atmosphere.Glare = 0.12
	atmosphere.Haze = 0.18
	atmosphere.Parent = Lighting

	local colorCorrection = Instance.new("ColorCorrectionEffect")
	colorCorrection.Name = "DreamyGrade"
	colorCorrection.TintColor = Color3.fromRGB(255, 225, 245)
	colorCorrection.Contrast = 0.06
	colorCorrection.Saturation = 0.18
	colorCorrection.Brightness = 0.07
	colorCorrection.Parent = Lighting

	local bloom = Instance.new("BloomEffect")
	bloom.Name = "SoftBloom"
	bloom.Intensity = 0.5
	bloom.Size = 22
	bloom.Threshold = 1.35
	bloom.Parent = Lighting

	local depthOfField = Instance.new("DepthOfFieldEffect")
	depthOfField.Name = "SubtleDepth"
	depthOfField.FarIntensity = 0.02
	depthOfField.FocusDistance = 80
	depthOfField.InFocusRadius = 60
	depthOfField.NearIntensity = 0
	depthOfField.Parent = Lighting

	buildSoftClouds()
end

return AtmosphereSetup
