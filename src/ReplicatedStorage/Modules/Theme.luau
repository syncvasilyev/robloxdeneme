--!strict
-- Shared visual theme constants (premium dark red / black / gray / white palette).

local Theme = {
	Colors = {
		Background = Color3.fromRGB(18, 16, 17),
		Surface = Color3.fromRGB(28, 24, 25),
		SurfaceGlass = Color3.fromRGB(35, 30, 31),
		AccentRed = Color3.fromRGB(139, 0, 0),
		AccentRedBright = Color3.fromRGB(180, 20, 20),
		TextPrimary = Color3.fromRGB(245, 245, 245),
		TextSecondary = Color3.fromRGB(170, 170, 170),
		Divider = Color3.fromRGB(60, 55, 56),
	},
	Font = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold,
	CornerRadius = UDim.new(0, 12),
}

return Theme
