--!strict
-- Cinematic night mood: blue/purple sky, soft far-reaching fog (never hides the map), warm
-- practical lights doing most of the actual illumination so it reads as lit, not just dark.

local Lighting = game:GetService("Lighting")

local AtmosphereSetup = {}

function AtmosphereSetup.apply()
	Lighting.ClockTime = 21.5
	Lighting.GeographicLatitude = 0
	Lighting.Brightness = 2.1
	Lighting.Ambient = Color3.fromRGB(40, 44, 58)
	Lighting.OutdoorAmbient = Color3.fromRGB(48, 52, 70)
	Lighting.ColorShift_Top = Color3.fromRGB(70, 80, 120)
	Lighting.ColorShift_Bottom = Color3.fromRGB(20, 18, 30)
	Lighting.EnvironmentDiffuseScale = 0.4
	Lighting.EnvironmentSpecularScale = 0.3
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.35
	Lighting.ExposureCompensation = 0.15

	local sky = Instance.new("Sky")
	sky.Name = "NightSky"
	sky.StarCount = 3000
	sky.CelestialBodiesShown = true
	sky.MoonAngularSize = 14
	sky.SunAngularSize = 0
	sky.Parent = Lighting

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Name = "NightAtmosphere"
	atmosphere.Density = 0.32
	atmosphere.Offset = 0.15
	atmosphere.Color = Color3.fromRGB(150, 160, 200)
	atmosphere.Decay = Color3.fromRGB(65, 55, 90)
	atmosphere.Glare = 0.15
	atmosphere.Haze = 0.9
	atmosphere.Parent = Lighting

	local colorCorrection = Instance.new("ColorCorrectionEffect")
	colorCorrection.Name = "NightGrade"
	colorCorrection.TintColor = Color3.fromRGB(225, 232, 255)
	colorCorrection.Contrast = 0.08
	colorCorrection.Saturation = 0.05
	colorCorrection.Brightness = 0.02
	colorCorrection.Parent = Lighting

	local bloom = Instance.new("BloomEffect")
	bloom.Name = "SoftBloom"
	bloom.Intensity = 0.55
	bloom.Size = 24
	bloom.Threshold = 1.3
	bloom.Parent = Lighting

	local depthOfField = Instance.new("DepthOfFieldEffect")
	depthOfField.Name = "SubtleDepth"
	depthOfField.FarIntensity = 0.08
	depthOfField.FocusDistance = 60
	depthOfField.InFocusRadius = 40
	depthOfField.NearIntensity = 0
	depthOfField.Parent = Lighting
end

return AtmosphereSetup
