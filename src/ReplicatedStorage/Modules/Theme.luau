--!strict
-- Shared visual theme constants (premium dark red / black / gray / white palette).

local Theme = {
	Colors = {
		Background = Color3.fromRGB(14, 12, 13),
		Surface = Color3.fromRGB(26, 22, 23),
		SurfaceGlass = Color3.fromRGB(34, 29, 30),
		AccentRed = Color3.fromRGB(150, 12, 20),
		AccentRedBright = Color3.fromRGB(200, 30, 38),
		AccentGold = Color3.fromRGB(214, 176, 110),
		TextPrimary = Color3.fromRGB(248, 248, 248),
		TextSecondary = Color3.fromRGB(178, 172, 173),
		Divider = Color3.fromRGB(64, 57, 58),
		StrokeGlass = Color3.fromRGB(90, 78, 80),
	},
	Font = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold,
	FontBlack = Enum.Font.GothamBlack,
	CornerRadius = UDim.new(0, 16),
}

--- Rounded corner, matching Theme.CornerRadius unless overridden.
function Theme.applyCorner(instance: Instance, radius: UDim?)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius or Theme.CornerRadius
	corner.Parent = instance
	return corner
end

--- A soft 1px edge highlight + faint top-to-bottom gradient, for the "glass panel" look the
--- design brief calls for (see madde 25: cam efektleri, soft glow).
function Theme.applyGlass(instance: GuiObject)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Colors.StrokeGlass
	stroke.Thickness = 1
	stroke.Transparency = 0.5
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = instance

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200)),
	})
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.94),
		NumberSequenceKeypoint.new(1, 1),
	})
	gradient.Rotation = 90
	gradient.Parent = instance

	return stroke, gradient
end

return Theme
