--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Modules.Theme)

local GroupTabUI = {}

local COLOR_PRESETS = {
	Color3.fromRGB(245, 245, 245),
	Color3.fromRGB(220, 20, 60),
	Color3.fromRGB(255, 165, 0),
	Color3.fromRGB(50, 205, 50),
	Color3.fromRGB(30, 144, 255),
	Color3.fromRGB(186, 85, 211),
}

local function createCorner(parent: Instance, radius: UDim)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius
	corner.Parent = parent
end

function GroupTabUI.build(parent: Frame, GroupClient: any)
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Position = UDim2.new(0, 16, 0, 16)
	statusLabel.Size = UDim2.new(1, -32, 0, 60)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Font = Theme.Font
	statusLabel.TextSize = 14
	statusLabel.TextWrapped = true
	statusLabel.TextColor3 = Theme.Colors.TextSecondary
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.TextYAlignment = Enum.TextYAlignment.Top
	statusLabel.Text = "Bir gruba ait değilsin."
	statusLabel.Parent = parent

	local createButton = Instance.new("TextButton")
	createButton.Position = UDim2.new(0, 16, 0, 84)
	createButton.Size = UDim2.new(1, -32, 0, 40)
	createButton.BackgroundColor3 = Theme.Colors.AccentRed
	createButton.Font = Theme.FontBold
	createButton.TextSize = 14
	createButton.TextColor3 = Theme.Colors.TextPrimary
	createButton.Text = "Grup Oluştur"
	createButton.Parent = parent
	createCorner(createButton, UDim.new(0, 8))
	createButton.MouseButton1Click:Connect(function()
		GroupClient.create()
	end)

	local codeBox = Instance.new("TextBox")
	codeBox.Position = UDim2.new(0, 16, 0, 134)
	codeBox.Size = UDim2.new(1, -108, 0, 40)
	codeBox.BackgroundColor3 = Theme.Colors.SurfaceGlass
	codeBox.Font = Theme.Font
	codeBox.TextSize = 14
	codeBox.TextColor3 = Theme.Colors.TextPrimary
	codeBox.PlaceholderText = "Kod Gir"
	codeBox.PlaceholderColor3 = Theme.Colors.TextSecondary
	codeBox.ClearTextOnFocus = false
	codeBox.Parent = parent
	createCorner(codeBox, UDim.new(0, 8))

	local joinButton = Instance.new("TextButton")
	joinButton.Position = UDim2.new(1, -84, 0, 134)
	joinButton.Size = UDim2.new(0, 68, 0, 40)
	joinButton.BackgroundColor3 = Theme.Colors.Surface
	joinButton.Font = Theme.FontBold
	joinButton.TextSize = 13
	joinButton.TextColor3 = Theme.Colors.TextPrimary
	joinButton.Text = "Katıl"
	joinButton.Parent = parent
	createCorner(joinButton, UDim.new(0, 8))
	joinButton.MouseButton1Click:Connect(function()
		if codeBox.Text ~= "" then
			GroupClient.join(codeBox.Text)
		end
	end)

	local leaveButton = Instance.new("TextButton")
	leaveButton.Position = UDim2.new(0, 16, 0, 184)
	leaveButton.Size = UDim2.new(1, -32, 0, 36)
	leaveButton.BackgroundColor3 = Theme.Colors.Surface
	leaveButton.Font = Theme.Font
	leaveButton.TextSize = 13
	leaveButton.TextColor3 = Theme.Colors.TextSecondary
	leaveButton.Text = "Gruptan Ayrıl"
	leaveButton.Parent = parent
	createCorner(leaveButton, UDim.new(0, 8))
	leaveButton.MouseButton1Click:Connect(function()
		GroupClient.leave()
	end)

	local colorLabel = Instance.new("TextLabel")
	colorLabel.Position = UDim2.new(0, 16, 0, 234)
	colorLabel.Size = UDim2.new(1, -32, 0, 20)
	colorLabel.BackgroundTransparency = 1
	colorLabel.Font = Theme.Font
	colorLabel.TextSize = 13
	colorLabel.TextColor3 = Theme.Colors.TextSecondary
	colorLabel.TextXAlignment = Enum.TextXAlignment.Left
	colorLabel.Text = "Grup Rengi (her değişim 20 Robux)"
	colorLabel.Parent = parent

	local colorRow = Instance.new("Frame")
	colorRow.Position = UDim2.new(0, 16, 0, 258)
	colorRow.Size = UDim2.new(1, -32, 0, 32)
	colorRow.BackgroundTransparency = 1
	colorRow.Parent = parent

	local colorLayout = Instance.new("UIListLayout")
	colorLayout.FillDirection = Enum.FillDirection.Horizontal
	colorLayout.Padding = UDim.new(0, 8)
	colorLayout.Parent = colorRow

	for _, color in ipairs(COLOR_PRESETS) do
		local swatch = Instance.new("TextButton")
		swatch.Size = UDim2.fromOffset(32, 32)
		swatch.BackgroundColor3 = color
		swatch.Text = ""
		swatch.Parent = colorRow
		createCorner(swatch, UDim.new(1, 0))
		swatch.MouseButton1Click:Connect(function()
			GroupClient.requestColorChange(color)
		end)
	end

	GroupClient.onStateChanged(function(state)
		if not state then
			statusLabel.Text = "Bir gruba ait değilsin."
			return
		end
		if state.error then
			statusLabel.Text = state.error
			return
		end
		statusLabel.Text = ("Grup Kodu: %s\nÜyeler: %s"):format(state.code, table.concat(state.members, ", "))
	end)
end

return GroupTabUI
