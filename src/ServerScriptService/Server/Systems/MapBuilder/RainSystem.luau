--!strict
-- A localized rain effect: an invisible high-altitude emitter plate rains down over a specific
-- footprint only, so weather can differ per map zone instead of applying globally.

local RainSystem = {}

--- Rains over an areaSize (X = width, Z = depth) footprint centered under `centerCFrame`.
function RainSystem.createRainRegion(container: Instance, centerCFrame: CFrame, areaSize: Vector2)
	local plate = Instance.new("Part")
	plate.Name = "RainEmitterPlate"
	plate.Anchored = true
	plate.CanCollide = false
	plate.CanQuery = false
	plate.Transparency = 1
	plate.Size = Vector3.new(areaSize.X, 1, areaSize.Y)
	plate.CFrame = centerCFrame * CFrame.new(0, 45, 0)
	plate.Parent = container

	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "Rain"
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Color = ColorSequence.new(Color3.fromRGB(200, 210, 230))
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.55),
		NumberSequenceKeypoint.new(1, 0.75),
	})
	emitter.Size = NumberSequence.new(0.12)
	emitter.Rotation = NumberRange.new(0, 0)
	emitter.Speed = NumberRange.new(0, 0)
	emitter.Lifetime = NumberRange.new(1.6, 1.7)
	emitter.Acceleration = Vector3.new(0, -120, 0)
	emitter.Rate = math.floor(areaSize.X * areaSize.Y * 0.2)
	emitter.SpreadAngle = Vector2.new(0, 0)
	emitter.Shape = Enum.ParticleEmitterShape.Box
	emitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
	emitter.EmissionDirection = Enum.NormalId.Bottom
	emitter.LightEmission = 0
	emitter.Parent = plate

	return plate
end

--- Darkens + slightly reflects a ground/pavement part so it reads as rain-wet.
function RainSystem.wetten(part: BasePart)
	part.Reflectance = 0.18
	part.Color = part.Color:Lerp(Color3.new(0, 0, 0), 0.15)
end

return RainSystem
