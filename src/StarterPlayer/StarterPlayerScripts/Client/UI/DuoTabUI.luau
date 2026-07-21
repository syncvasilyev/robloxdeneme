--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Modules.Theme)
local DuoInterests = require(ReplicatedStorage.Modules.DuoInterests)

local DuoTabUI = {}

local MAX_INTERESTS = 5

local function createCorner(parent: Instance, radius: UDim)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius
	corner.Parent = parent
end

function DuoTabUI.build(parent: Frame, DuoClient: any)
	local optIn = false
	local selectedInterests: { [string]: boolean } = {}

	local optInButton = Instance.new("TextButton")
	optInButton.Position = UDim2.new(0, 16, 0, 16)
	optInButton.Size = UDim2.new(1, -32, 0, 40)
	optInButton.BackgroundColor3 = Theme.Colors.Surface
	optInButton.Font = Theme.FontBold
	optInButton.TextSize = 14
	optInButton.TextColor3 = Theme.Colors.TextPrimary
	optInButton.Text = "Duo Bulmaya Kapalı (aç)"
	optInButton.Parent = parent
	createCorner(optInButton, UDim.new(0, 8))

	local interestsLabel = Instance.new("TextLabel")
	interestsLabel.Position = UDim2.new(0, 16, 0, 68)
	interestsLabel.Size = UDim2.new(1, -32, 0, 20)
	interestsLabel.BackgroundTransparency = 1
	interestsLabel.Font = Theme.Font
	interestsLabel.TextSize = 13
	interestsLabel.TextColor3 = Theme.Colors.TextSecondary
	interestsLabel.TextXAlignment = Enum.TextXAlignment.Left
	interestsLabel.Text = "İlgi Alanların (en fazla 5)"
	interestsLabel.Parent = parent

	-- Horizontally scrolling instead of wrapping: UIListLayout's wrap support isn't available
	-- on every Studio version, so this avoids depending on it.
	local tagsFrame = Instance.new("ScrollingFrame")
	tagsFrame.Position = UDim2.new(0, 16, 0, 92)
	tagsFrame.Size = UDim2.new(1, -32, 0, 40)
	tagsFrame.BackgroundTransparency = 1
	tagsFrame.BorderSizePixel = 0
	tagsFrame.ScrollingDirection = Enum.ScrollingDirection.X
	tagsFrame.ScrollBarThickness = 4
	tagsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	tagsFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
	tagsFrame.Parent = parent

	local tagsLayout = Instance.new("UIListLayout")
	tagsLayout.FillDirection = Enum.FillDirection.Horizontal
	tagsLayout.Padding = UDim.new(0, 6)
	tagsLayout.Parent = tagsFrame

	local function saveProfile()
		local interests = {}
		for tag in pairs(selectedInterests) do
			table.insert(interests, tag)
		end
		DuoClient.setProfile(optIn, interests)
	end

	for _, tag in ipairs(DuoInterests) do
		local tagButton = Instance.new("TextButton")
		tagButton.AutomaticSize = Enum.AutomaticSize.X
		tagButton.Size = UDim2.new(0, 0, 0, 28)
		tagButton.BackgroundColor3 = Theme.Colors.SurfaceGlass
		tagButton.Font = Theme.Font
		tagButton.TextSize = 12
		tagButton.TextColor3 = Theme.Colors.TextSecondary
		tagButton.Text = "  " .. tag .. "  "
		tagButton.Parent = tagsFrame
		createCorner(tagButton, UDim.new(0, 14))

		tagButton.MouseButton1Click:Connect(function()
			if selectedInterests[tag] then
				selectedInterests[tag] = nil
				tagButton.BackgroundColor3 = Theme.Colors.SurfaceGlass
				tagButton.TextColor3 = Theme.Colors.TextSecondary
			else
				local count = 0
				for _ in pairs(selectedInterests) do
					count += 1
				end
				if count >= MAX_INTERESTS then
					return
				end
				selectedInterests[tag] = true
				tagButton.BackgroundColor3 = Theme.Colors.AccentRed
				tagButton.TextColor3 = Theme.Colors.TextPrimary
			end
			saveProfile()
		end)
	end

	optInButton.MouseButton1Click:Connect(function()
		optIn = not optIn
		optInButton.Text = if optIn then "Duo Bulmaya Açık (kapat)" else "Duo Bulmaya Kapalı (aç)"
		saveProfile()
	end)

	local listLabel = Instance.new("TextLabel")
	listLabel.Position = UDim2.new(0, 16, 0, 160)
	listLabel.Size = UDim2.new(1, -100, 0, 20)
	listLabel.BackgroundTransparency = 1
	listLabel.Font = Theme.Font
	listLabel.TextSize = 13
	listLabel.TextColor3 = Theme.Colors.TextSecondary
	listLabel.TextXAlignment = Enum.TextXAlignment.Left
	listLabel.Text = "Duo Bulmaya Açık Oyuncular"
	listLabel.Parent = parent

	local refreshButton = Instance.new("TextButton")
	refreshButton.AnchorPoint = Vector2.new(1, 0)
	refreshButton.Position = UDim2.new(1, -16, 0, 156)
	refreshButton.Size = UDim2.new(0, 70, 0, 28)
	refreshButton.BackgroundColor3 = Theme.Colors.Surface
	refreshButton.Font = Theme.Font
	refreshButton.TextSize = 12
	refreshButton.TextColor3 = Theme.Colors.TextPrimary
	refreshButton.Text = "Yenile"
	refreshButton.Parent = parent
	createCorner(refreshButton, UDim.new(0, 8))

	local list = Instance.new("ScrollingFrame")
	list.Position = UDim2.new(0, 16, 0, 188)
	list.Size = UDim2.new(1, -32, 1, -204)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 4
	list.CanvasSize = UDim2.new(0, 0, 0, 0)
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.Parent = parent

	local function refreshList()
		list:ClearAllChildren()
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 6)
		layout.Parent = list

		local results = DuoClient.listPlayers()
		for _, entry in ipairs(results) do
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 48)
			row.BackgroundColor3 = Theme.Colors.SurfaceGlass
			row.Parent = list
			createCorner(row, UDim.new(0, 8))

			local nameLabel = Instance.new("TextLabel")
			nameLabel.Position = UDim2.new(0, 12, 0, 0)
			nameLabel.Size = UDim2.new(1, -100, 1, 0)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Font = Theme.Font
			nameLabel.TextSize = 12
			nameLabel.TextColor3 = Theme.Colors.TextPrimary
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.TextWrapped = true
			nameLabel.Text = ("%s\n%s"):format(entry.name, table.concat(entry.interests, ", "))
			nameLabel.Parent = row

			local inviteButton = Instance.new("TextButton")
			inviteButton.AnchorPoint = Vector2.new(1, 0.5)
			inviteButton.Position = UDim2.new(1, -8, 0.5, 0)
			inviteButton.Size = UDim2.new(0, 76, 0, 32)
			inviteButton.BackgroundColor3 = Theme.Colors.AccentRed
			inviteButton.Font = Theme.FontBold
			inviteButton.TextSize = 12
			inviteButton.TextColor3 = Theme.Colors.TextPrimary
			inviteButton.Text = "Davet Et"
			inviteButton.Parent = row
			createCorner(inviteButton, UDim.new(0, 6))
			inviteButton.MouseButton1Click:Connect(function()
				DuoClient.sendInvite(entry.name)
				inviteButton.Text = "Gönderildi"
				inviteButton.Active = false
			end)
		end
	end

	refreshButton.MouseButton1Click:Connect(refreshList)
	refreshList()
end

return DuoTabUI
