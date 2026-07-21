--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Modules.Theme)

local ProfileTabUI = {}

local function createCorner(parent: Instance, radius: UDim)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius
	corner.Parent = parent
end

local function createLabel(parent: Instance, text: string, position: UDim2)
	local label = Instance.new("TextLabel")
	label.Position = position
	label.Size = UDim2.new(1, -32, 0, 20)
	label.BackgroundTransparency = 1
	label.Font = Theme.Font
	label.TextSize = 13
	label.TextColor3 = Theme.Colors.TextSecondary
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = text
	label.Parent = parent
	return label
end

local function createTextBox(parent: Instance, position: UDim2, height: number, placeholder: string, multiline: boolean)
	local box = Instance.new("TextBox")
	box.Position = position
	box.Size = UDim2.new(1, -32, 0, height)
	box.BackgroundColor3 = Theme.Colors.SurfaceGlass
	box.Font = Theme.Font
	box.TextSize = 15
	box.TextColor3 = Theme.Colors.TextPrimary
	box.PlaceholderText = placeholder
	box.PlaceholderColor3 = Theme.Colors.TextSecondary
	box.ClearTextOnFocus = false
	box.TextWrapped = multiline
	box.MultiLine = multiline
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.TextYAlignment = if multiline then Enum.TextYAlignment.Top else Enum.TextYAlignment.Center
	box.Parent = parent
	createCorner(box, UDim.new(0, 8))
	return box
end

function ProfileTabUI.build(parent: Frame, ProfileClient: any)
	createLabel(parent, "NICKNAME", UDim2.new(0, 16, 0, 16))
	local nicknameBox = createTextBox(parent, UDim2.new(0, 16, 0, 36), 40, "Nickname'ini yaz...", false)

	createLabel(parent, "BIO", UDim2.new(0, 16, 0, 92))
	local bioBox = createTextBox(parent, UDim2.new(0, 16, 0, 112), 100, "Kendinden bahset...", true)

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Position = UDim2.new(0, 16, 0, 222)
	statusLabel.Size = UDim2.new(1, -32, 0, 20)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Font = Theme.Font
	statusLabel.TextSize = 13
	statusLabel.TextColor3 = Theme.Colors.TextSecondary
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Text = ""
	statusLabel.Parent = parent

	local saveButton = Instance.new("TextButton")
	saveButton.Position = UDim2.new(0, 16, 0, 252)
	saveButton.Size = UDim2.new(1, -32, 0, 44)
	saveButton.BackgroundColor3 = Theme.Colors.AccentRed
	saveButton.Font = Theme.FontBold
	saveButton.TextSize = 15
	saveButton.TextColor3 = Theme.Colors.TextPrimary
	saveButton.Text = "Kaydet"
	saveButton.Parent = parent
	createCorner(saveButton, UDim.new(0, 8))

	saveButton.MouseButton1Click:Connect(function()
		statusLabel.Text = "Kaydediliyor..."
		local result = ProfileClient.updateProfile({
			nickname = nicknameBox.Text,
			bio = bioBox.Text,
		})
		if result and result.success then
			statusLabel.Text = "Kaydedildi."
			if result.profile then
				nicknameBox.Text = result.profile.nickname or nicknameBox.Text
				bioBox.Text = result.profile.bio or bioBox.Text
			end
		else
			statusLabel.Text = (result and result.error) or "Kaydedilemedi."
		end
	end)

	task.spawn(function()
		local profile = ProfileClient.getProfile()
		if profile then
			nicknameBox.Text = profile.nickname or ""
			bioBox.Text = profile.bio or ""
		end
	end)
end

return ProfileTabUI
