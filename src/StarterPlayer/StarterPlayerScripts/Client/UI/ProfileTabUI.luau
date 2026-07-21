--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Modules.Theme)
local CosmeticPresets = require(ReplicatedStorage.Modules.CosmeticPresets)

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

function ProfileTabUI.build(parent: Frame, ProfileClient: any, CosmeticsClient: any)
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

	createLabel(parent, "RAINBOW NICKNAME (70 Robux Gamepass)", UDim2.new(0, 16, 0, 306))
	local rainbowButton = Instance.new("TextButton")
	rainbowButton.Position = UDim2.new(0, 16, 0, 328)
	rainbowButton.Size = UDim2.new(1, -32, 0, 36)
	rainbowButton.BackgroundColor3 = Theme.Colors.Surface
	rainbowButton.Font = Theme.Font
	rainbowButton.TextSize = 13
	rainbowButton.TextColor3 = Theme.Colors.TextPrimary
	rainbowButton.Text = "Rainbow Nickname Aç-Kapat"
	rainbowButton.Parent = parent
	createCorner(rainbowButton, UDim.new(0, 8))
	local rainbowEnabled = false
	rainbowButton.MouseButton1Click:Connect(function()
		rainbowEnabled = not rainbowEnabled
		CosmeticsClient.setRainbowNickname(rainbowEnabled)
	end)

	createLabel(parent, "PROFİL FOTOĞRAFI (230 Robux Gamepass)", UDim2.new(0, 16, 0, 376))
	local photoRow = Instance.new("Frame")
	photoRow.Position = UDim2.new(0, 16, 0, 398)
	photoRow.Size = UDim2.new(1, -32, 0, 36)
	photoRow.BackgroundTransparency = 1
	photoRow.Parent = parent
	local photoLayout = Instance.new("UIListLayout")
	photoLayout.FillDirection = Enum.FillDirection.Horizontal
	photoLayout.Padding = UDim.new(0, 8)
	photoLayout.Parent = photoRow

	for _, photo in ipairs(CosmeticPresets.ProfilePhotos) do
		local photoButton = Instance.new("TextButton")
		photoButton.Size = UDim2.new(0, 100, 1, 0)
		photoButton.BackgroundColor3 = Theme.Colors.SurfaceGlass
		photoButton.Font = Theme.Font
		photoButton.TextSize = 12
		photoButton.TextColor3 = Theme.Colors.TextPrimary
		photoButton.Text = photo.name
		photoButton.Parent = photoRow
		createCorner(photoButton, UDim.new(0, 8))
		photoButton.MouseButton1Click:Connect(function()
			local result = CosmeticsClient.setProfilePhoto(photo.id)
			statusLabel.Text = if result and result.success then "Profil fotoğrafı güncellendi." else (result and result.error) or "Güncellenemedi."
		end)
	end
end

return ProfileTabUI
