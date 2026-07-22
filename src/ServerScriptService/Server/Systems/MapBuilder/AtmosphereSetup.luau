--!strict
-- Moody-but-visible facility night mood: cooler and dimmer than the first "dreamy pink" pass
-- (that read as too bright/washed out) — still fully visible, just less glaring, closer to the
-- quality indoor-hall reference the map's main hub is now built around.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local AtmosphereSetup = {}

local CLOUD_SPECS = {
	{ position = Vector3.new(-60, 340, 40), size = Vector3.new(140, 6, 70), color = Color3.fromRGB(190, 195, 210) },
	{ position = Vector3.new(90, 360, -50), size = Vector3.new(120, 6, 60), color = Color3.fromRGB(175, 180, 200) },
	{ position = Vector3.new(10, 380, 120), size = Vector3.new(160, 6, 80), color = Color3.fromRGB(200, 205, 220) },
	{ position = Vector3.new(-40, 350, -140), size = Vector3.new(130, 6, 65), color = Color3.fromRGB(185, 190, 205) },
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
	Lighting.Brightness = 1.8
	-- Darker base than before on purpose — per the reference (sparse fixtures, dramatic colored
	-- glow pools, dark ceiling/corners), fixtures and accent lights should carry the drama rather
	-- than everything being evenly lit.
	Lighting.Ambient = Color3.fromRGB(45, 46, 54)
	Lighting.OutdoorAmbient = Color3.fromRGB(50, 52, 60)
	Lighting.ColorShift_Top = Color3.fromRGB(50, 52, 68)
	Lighting.ColorShift_Bottom = Color3.fromRGB(20, 18, 26)
	Lighting.EnvironmentDiffuseScale = 0.5
	Lighting.EnvironmentSpecularScale = 0.35
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.25
	Lighting.ExposureCompensation = 0.15

	local sky = Instance.new("Sky")
	sky.Name = "FacilitySky"
	sky.StarCount = 3500
	sky.CelestialBodiesShown = true
	sky.MoonAngularSize = 16
	sky.SunAngularSize = 0
	sky.Parent = Lighting

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Name = "FacilityAtmosphere"
	atmosphere.Density = 0.1
	atmosphere.Offset = 0.1
	atmosphere.Color = Color3.fromRGB(180, 190, 205)
	atmosphere.Decay = Color3.fromRGB(70, 75, 95)
	atmosphere.Glare = 0.08
	atmosphere.Haze = 0.15
	atmosphere.Parent = Lighting

	local colorCorrection = Instance.new("ColorCorrectionEffect")
	colorCorrection.Name = "FacilityGrade"
	colorCorrection.TintColor = Color3.fromRGB(235, 238, 245)
	colorCorrection.Contrast = 0.16
	colorCorrection.Saturation = 0.05
	colorCorrection.Brightness = -0.02
	colorCorrection.Parent = Lighting

	local bloom = Instance.new("BloomEffect")
	bloom.Name = "SoftBloom"
	bloom.Intensity = 0.5
	bloom.Size = 20
	bloom.Threshold = 1.2
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
