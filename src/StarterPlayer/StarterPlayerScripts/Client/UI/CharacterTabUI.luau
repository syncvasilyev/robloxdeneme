--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Modules.Theme)
local CosmeticPresets = require(ReplicatedStorage.Modules.CosmeticPresets)

local CharacterTabUI = {}

local function createCorner(parent: Instance, radius: UDim)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius
	corner.Parent = parent
end

local function sectionLabel(parent: Instance, text: string, y: number)
	local label = Instance.new("TextLabel")
	label.Position = UDim2.new(0, 16, 0, y)
	label.Size = UDim2.new(1, -32, 0, 20)
	label.BackgroundTransparency = 1
	label.Font = Theme.Font
	label.TextSize = 13
	label.TextColor3 = Theme.Colors.TextSecondary
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = text
	label.Parent = parent
end

function CharacterTabUI.build(parent: Frame, CosmeticsClient: any)
	sectionLabel(parent, "R6 MOD (72 Robux Gamepass)", 16)
	local r6Button = Instance.new("TextButton")
	r6Button.Position = UDim2.new(0, 16, 0, 40)
	r6Button.Size = UDim2.new(1, -32, 0, 36)
	r6Button.BackgroundColor3 = Theme.Colors.Surface
	r6Button.Font = Theme.Font
	r6Button.TextSize = 13
	r6Button.TextColor3 = Theme.Colors.TextPrimary
	r6Button.Text = "R6 / R15 Aç-Kapat"
	r6Button.Parent = parent
	createCorner(r6Button, UDim.new(0, 8))
	local r6Enabled = false
	r6Button.MouseButton1Click:Connect(function()
		r6Enabled = not r6Enabled
		CosmeticsClient.setR6Mode(r6Enabled)
	end)

	sectionLabel(parent, "TRAIL", 92)
	local trailRow = Instance.new("ScrollingFrame")
	trailRow.Position = UDim2.new(0, 16, 0, 116)
	trailRow.Size = UDim2.new(1, -32, 0, 36)
	trailRow.BackgroundTransparency = 1
	trailRow.BorderSizePixel = 0
	trailRow.ScrollingDirection = Enum.ScrollingDirection.X
	trailRow.ScrollBarThickness = 4
	trailRow.CanvasSize = UDim2.new(0, 0, 0, 0)
	trailRow.AutomaticCanvasSize = Enum.AutomaticSize.X
	trailRow.Parent = parent
	local trailLayout = Instance.new("UIListLayout")
	trailLayout.FillDirection = Enum.FillDirection.Horizontal
	trailLayout.Padding = UDim.new(0, 8)
	trailLayout.Parent = trailRow

	local trailOptions = { { id = "None", name = "Kapalı" }, { id = "Normal", name = "Normal (220 R$)" }, { id = "Flying", name = "Flying (320 R$)" } }
	for _, option in ipairs(trailOptions) do
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(0, 120, 1, 0)
		button.BackgroundColor3 = Theme.Colors.SurfaceGlass
		button.Font = Theme.Font
		button.TextSize = 12
		button.TextColor3 = Theme.Colors.TextPrimary
		button.Text = option.name
		button.Parent = trailRow
		createCorner(button, UDim.new(0, 8))
		button.MouseButton1Click:Connect(function()
			CosmeticsClient.setTrail(option.id)
		end)
	end

	sectionLabel(parent, "LARP (900 Robux Gamepass)", 168)
	local larpRow = Instance.new("ScrollingFrame")
	larpRow.Position = UDim2.new(0, 16, 0, 192)
	larpRow.Size = UDim2.new(1, -32, 0, 36)
	larpRow.BackgroundTransparency = 1
	larpRow.BorderSizePixel = 0
	larpRow.ScrollingDirection = Enum.ScrollingDirection.X
	larpRow.ScrollBarThickness = 4
	larpRow.CanvasSize = UDim2.new(0, 0, 0, 0)
	larpRow.AutomaticCanvasSize = Enum.AutomaticSize.X
	larpRow.Parent = parent
	local larpLayout = Instance.new("UIListLayout")
	larpLayout.FillDirection = Enum.FillDirection.Horizontal
	larpLayout.Padding = UDim.new(0, 8)
	larpLayout.Parent = larpRow

	for _, outfit in ipairs(CosmeticPresets.LarpOutfits) do
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(0, 120, 1, 0)
		button.BackgroundColor3 = Theme.Colors.SurfaceGlass
		button.Font = Theme.Font
		button.TextSize = 12
		button.TextColor3 = Theme.Colors.TextPrimary
		button.Text = outfit.name
		button.Parent = larpRow
		createCorner(button, UDim.new(0, 8))
		button.MouseButton1Click:Connect(function()
			CosmeticsClient.setLarpOutfit(outfit.id)
		end)
	end

	local larpOffButton = Instance.new("TextButton")
	larpOffButton.Position = UDim2.new(0, 16, 0, 236)
	larpOffButton.Size = UDim2.new(1, -32, 0, 32)
	larpOffButton.BackgroundColor3 = Theme.Colors.Surface
	larpOffButton.Font = Theme.Font
	larpOffButton.TextSize = 12
	larpOffButton.TextColor3 = Theme.Colors.TextSecondary
	larpOffButton.Text = "LARP Görünümünü Kapat"
	larpOffButton.Parent = parent
	createCorner(larpOffButton, UDim.new(0, 8))
	larpOffButton.MouseButton1Click:Connect(function()
		CosmeticsClient.setLarpOutfit(nil)
	end)
end

return CharacterTabUI
