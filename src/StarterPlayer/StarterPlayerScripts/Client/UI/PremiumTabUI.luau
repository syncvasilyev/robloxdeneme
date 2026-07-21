--!strict
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Modules.Theme)
local GamepassIds = require(ReplicatedStorage.Modules.GamepassIds)

local PremiumTabUI = {}

local function createCorner(parent: Instance, radius: UDim)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius
	corner.Parent = parent
end

local GAMEPASS_LIST = {
	{ key = "RainbowNickname", name = "Rainbow Nickname", price = "70 Robux" },
	{ key = "R6Mode", name = "R6 Mod", price = "72 Robux" },
	{ key = "Party", name = "Party (Parti Kurma)", price = "97 Robux" },
	{ key = "TrailNormal", name = "Trail (Normal)", price = "220 Robux" },
	{ key = "ProfilePhoto", name = "Profil Fotoğrafı", price = "230 Robux" },
	{ key = "TrailFlying", name = "Trail (Flying)", price = "320 Robux" },
	{ key = "Mod", name = "Mod", price = "460 Robux" },
	{ key = "Larp", name = "LARP", price = "900 Robux" },
}

function PremiumTabUI.build(parent: Frame)
	local list = Instance.new("ScrollingFrame")
	list.Position = UDim2.new(0, 16, 0, 16)
	list.Size = UDim2.new(1, -32, 1, -32)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 4
	list.CanvasSize = UDim2.new(0, 0, 0, 0)
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.Parent = parent

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = list

	for _, entry in ipairs(GAMEPASS_LIST) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 48)
		row.BackgroundColor3 = Theme.Colors.SurfaceGlass
		row.Parent = list
		createCorner(row, UDim.new(0, 8))

		local label = Instance.new("TextLabel")
		label.Position = UDim2.new(0, 12, 0, 0)
		label.Size = UDim2.new(1, -108, 1, 0)
		label.BackgroundTransparency = 1
		label.Font = Theme.Font
		label.TextSize = 13
		label.TextColor3 = Theme.Colors.TextPrimary
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Text = ("%s\n%s"):format(entry.name, entry.price)
		label.TextWrapped = true
		label.Parent = row

		local buyButton = Instance.new("TextButton")
		buyButton.AnchorPoint = Vector2.new(1, 0.5)
		buyButton.Position = UDim2.new(1, -12, 0.5, 0)
		buyButton.Size = UDim2.new(0, 80, 0, 32)
		buyButton.BackgroundColor3 = Theme.Colors.AccentRed
		buyButton.Font = Theme.FontBold
		buyButton.TextSize = 12
		buyButton.TextColor3 = Theme.Colors.TextPrimary
		buyButton.Text = "Satın Al"
		buyButton.Parent = row
		createCorner(buyButton, UDim.new(0, 6))

		buyButton.MouseButton1Click:Connect(function()
			local gamepassId = (GamepassIds :: any)[entry.key]
			if gamepassId == 0 then
				warn(("PremiumTabUI: %s gamepass id not configured yet."):format(entry.key))
				return
			end
			MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, gamepassId)
		end)
	end
end

return PremiumTabUI
