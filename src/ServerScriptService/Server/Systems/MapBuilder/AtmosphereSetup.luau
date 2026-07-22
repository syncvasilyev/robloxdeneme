--!strict
-- Cinematic night mood: blue/purple sky, soft far-reaching fog (never hides the map), warm
-- practical lights doing most of the actual illumination so it reads as lit, not just dark.

local Lighting = game:GetService("Lighting")

local AtmosphereSetup = {}

function AtmosphereSetup.apply()
	Lighting.ClockTime = 21.5
	Lighting.GeographicLatitude = 0
	Lighting.Brightness = 3
	-- Ambient/OutdoorAmbient carry most of the base visibility (fixtures shouldn't be the only
	-- thing keeping the map from going black) — brighter than a typical "night" preset on
	-- purpose, per "gözü yormayacak kadar karanlık olsun".
	Lighting.Ambient = Color3.fromRGB(95, 100, 128)
	Lighting.OutdoorAmbient = Color3.fromRGB(105, 112, 138)
	Lighting.ColorShift_Top = Color3.fromRGB(90, 100, 135)
	Lighting.ColorShift_Bottom = Color3.fromRGB(40, 38, 55)
	Lighting.EnvironmentDiffuseScale = 0.6
	Lighting.EnvironmentSpecularScale = 0.4
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.35
	Lighting.ExposureCompensation = 0.25

	local sky = Instance.new("Sky")
	sky.Name = "NightSky"
	sky.StarCount = 3000
	sky.CelestialBodiesShown = true
	sky.MoonAngularSize = 14
	sky.SunAngularSize = 0
	sky.Parent = Lighting

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Name = "NightAtmosphere"
	atmosphere.Density = 0.12
	atmosphere.Offset = 0.1
	atmosphere.Color = Color3.fromRGB(170, 180, 210)
	atmosphere.Decay = Color3.fromRGB(100, 95, 130)
	atmosphere.Glare = 0.1
	atmosphere.Haze = 0.2
	atmosphere.Parent = Lighting

	local colorCorrection = Instance.new("ColorCorrectionEffect")
	colorCorrection.Name = "NightGrade"
	colorCorrection.TintColor = Color3.fromRGB(230, 236, 255)
	colorCorrection.Contrast = 0.04
	colorCorrection.Saturation = 0.05
	colorCorrection.Brightness = 0.06
	colorCorrection.Parent = Lighting

	local bloom = Instance.new("BloomEffect")
	bloom.Name = "SoftBloom"
	bloom.Intensity = 0.45
	bloom.Size = 20
	bloom.Threshold = 1.4
	bloom.Parent = Lighting

	local depthOfField = Instance.new("DepthOfFieldEffect")
	depthOfField.Name = "SubtleDepth"
	depthOfField.FarIntensity = 0.02
	depthOfField.FocusDistance = 80
	depthOfField.InFocusRadius = 60
	depthOfField.NearIntensity = 0
	depthOfField.Parent = Lighting
end

return AtmosphereSetup
