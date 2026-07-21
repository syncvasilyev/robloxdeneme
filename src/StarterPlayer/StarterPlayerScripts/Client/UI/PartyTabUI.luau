--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Modules.Theme)
local PartyTracks = require(ReplicatedStorage.Modules.PartyTracks)

local PartyTabUI = {}

local function createCorner(parent: Instance, radius: UDim)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius
	corner.Parent = parent
end

function PartyTabUI.build(parent: Frame, PartyClient: any)
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Position = UDim2.new(0, 16, 0, 16)
	statusLabel.Size = UDim2.new(1, -32, 0, 60)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Font = Theme.Font
	statusLabel.TextSize = 13
	statusLabel.TextWrapped = true
	statusLabel.TextColor3 = Theme.Colors.TextSecondary
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.TextYAlignment = Enum.TextYAlignment.Top
	statusLabel.Text = "Bir partide değilsin. (Parti kurmak için Party Gamepass gerekiyor.)"
	statusLabel.Parent = parent

	local createButton = Instance.new("TextButton")
	createButton.Position = UDim2.new(0, 16, 0, 84)
	createButton.Size = UDim2.new(1, -32, 0, 40)
	createButton.BackgroundColor3 = Theme.Colors.AccentRed
	createButton.Font = Theme.FontBold
	createButton.TextSize = 14
	createButton.TextColor3 = Theme.Colors.TextPrimary
	createButton.Text = "Parti Oluştur (max 23)"
	createButton.Parent = parent
	createCorner(createButton, UDim.new(0, 8))
	createButton.MouseButton1Click:Connect(function()
		PartyClient.create(23)
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
			PartyClient.join(codeBox.Text)
		end
	end)

	local leaveButton = Instance.new("TextButton")
	leaveButton.Position = UDim2.new(0, 16, 0, 184)
	leaveButton.Size = UDim2.new(0.48, -8, 0, 36)
	leaveButton.BackgroundColor3 = Theme.Colors.Surface
	leaveButton.Font = Theme.Font
	leaveButton.TextSize = 13
	leaveButton.TextColor3 = Theme.Colors.TextSecondary
	leaveButton.Text = "Ayrıl"
	leaveButton.Parent = parent
	createCorner(leaveButton, UDim.new(0, 8))
	leaveButton.MouseButton1Click:Connect(function()
		PartyClient.leave()
	end)

	local closeButton = Instance.new("TextButton")
	closeButton.Position = UDim2.new(0.52, 0, 0, 184)
	closeButton.Size = UDim2.new(0.48, -8, 0, 36)
	closeButton.BackgroundColor3 = Theme.Colors.Surface
	closeButton.Font = Theme.Font
	closeButton.TextSize = 13
	closeButton.TextColor3 = Theme.Colors.TextSecondary
	closeButton.Text = "Partiyi Kapat (Host)"
	closeButton.Parent = parent
	createCorner(closeButton, UDim.new(0, 8))
	closeButton.MouseButton1Click:Connect(function()
		PartyClient.close()
	end)

	local friendsOnlyState = false
	local friendsOnlyButton = Instance.new("TextButton")
	friendsOnlyButton.Position = UDim2.new(0, 16, 0, 228)
	friendsOnlyButton.Size = UDim2.new(1, -32, 0, 32)
	friendsOnlyButton.BackgroundColor3 = Theme.Colors.Surface
	friendsOnlyButton.Font = Theme.Font
	friendsOnlyButton.TextSize = 13
	friendsOnlyButton.TextColor3 = Theme.Colors.TextSecondary
	friendsOnlyButton.Text = "Sadece Arkadaşlara Açık: Kapalı (Host - değiştir)"
	friendsOnlyButton.Parent = parent
	createCorner(friendsOnlyButton, UDim.new(0, 8))
	friendsOnlyButton.MouseButton1Click:Connect(function()
		friendsOnlyState = not friendsOnlyState
		PartyClient.setFriendsOnly(friendsOnlyState)
	end)

	local musicLabel = Instance.new("TextLabel")
	musicLabel.Position = UDim2.new(0, 16, 0, 272)
	musicLabel.Size = UDim2.new(1, -32, 0, 20)
	musicLabel.BackgroundTransparency = 1
	musicLabel.Font = Theme.Font
	musicLabel.TextSize = 13
	musicLabel.TextColor3 = Theme.Colors.TextSecondary
	musicLabel.TextXAlignment = Enum.TextXAlignment.Left
	musicLabel.Text = "Disco Müziği (DJ yetkisi gerekir)"
	musicLabel.Parent = parent

	local trackRow = Instance.new("Frame")
	trackRow.Position = UDim2.new(0, 16, 0, 296)
	trackRow.Size = UDim2.new(1, -32, 0, 36)
	trackRow.BackgroundTransparency = 1
	trackRow.Parent = parent

	local trackLayout = Instance.new("UIListLayout")
	trackLayout.FillDirection = Enum.FillDirection.Horizontal
	trackLayout.Padding = UDim.new(0, 8)
	trackLayout.Parent = trackRow

	for _, track in ipairs(PartyTracks) do
		local trackButton = Instance.new("TextButton")
		trackButton.Size = UDim2.new(0, 100, 1, 0)
		trackButton.BackgroundColor3 = Theme.Colors.SurfaceGlass
		trackButton.Font = Theme.Font
		trackButton.TextSize = 12
		trackButton.TextColor3 = Theme.Colors.TextPrimary
		trackButton.Text = track.name
		trackButton.Parent = trackRow
		createCorner(trackButton, UDim.new(0, 8))
		trackButton.MouseButton1Click:Connect(function()
			PartyClient.playTrack(track.id)
		end)
	end

	local stopMusicButton = Instance.new("TextButton")
	stopMusicButton.Position = UDim2.new(0, 16, 0, 340)
	stopMusicButton.Size = UDim2.new(1, -32, 0, 32)
	stopMusicButton.BackgroundColor3 = Theme.Colors.Surface
	stopMusicButton.Font = Theme.Font
	stopMusicButton.TextSize = 13
	stopMusicButton.TextColor3 = Theme.Colors.TextSecondary
	stopMusicButton.Text = "Müziği Durdur"
	stopMusicButton.Parent = parent
	createCorner(stopMusicButton, UDim.new(0, 8))
	stopMusicButton.MouseButton1Click:Connect(function()
		PartyClient.stopTrack()
	end)

	PartyClient.onStateChanged(function(state)
		if not state then
			statusLabel.Text = "Bir partide değilsin. (Parti kurmak için Party Gamepass gerekiyor.)"
			return
		end
		if state.error then
			statusLabel.Text = state.error
			return
		end
		statusLabel.Text = ("Kod: %s | Host: %s | Üye: %d/%d\nÜyeler: %s"):format(
			state.code,
			state.host,
			#state.members,
			state.maxSize,
			table.concat(state.members, ", ")
		)
		friendsOnlyState = state.friendsOnly
		friendsOnlyButton.Text = if state.friendsOnly
			then "Sadece Arkadaşlara Açık: Açık (Host - değiştir)"
			else "Sadece Arkadaşlara Açık: Kapalı (Host - değiştir)"
	end)
end

return PartyTabUI
