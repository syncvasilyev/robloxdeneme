--!strict
-- Shows a one-time "want to buy a Rainbow Stick?" popup the first time the player ever enters a
-- party (server decides "first time" via PlayerDataStore and only fires the event once — see
-- PartySystem's maybeOfferRainbowStick).

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Modules.Theme)
local GamepassIds = require(ReplicatedStorage.Modules.GamepassIds)
local Remotes = require(ReplicatedStorage.Modules.Remotes)

local RainbowStickOfferClient = {}

local rainbowStickOfferEvent = Remotes.getEvent("ShowRainbowStickOffer")

local function showOffer()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RainbowStickOfferGui"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 55
	screenGui.Parent = playerGui

	local card = Instance.new("Frame")
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.Size = UDim2.new(0, 320, 0, 200)
	card.BackgroundColor3 = Theme.Colors.Surface
	card.Parent = screenGui
	Theme.applyCorner(card, Theme.CornerRadius)
	Theme.applyGlass(card)
	Theme.popIn(card)

	local title = Instance.new("TextLabel")
	title.Position = UDim2.new(0, 16, 0, 16)
	title.Size = UDim2.new(1, -32, 0, 28)
	title.BackgroundTransparency = 1
	title.Font = Theme.FontBlack
	title.TextSize = 17
	title.TextColor3 = Theme.Colors.TextPrimary
	title.Text = "🌈 Rainbow Stick"
	title.Parent = card

	local body = Instance.new("TextLabel")
	body.Position = UDim2.new(0, 16, 0, 50)
	body.Size = UDim2.new(1, -32, 0, 70)
	body.BackgroundTransparency = 1
	body.Font = Theme.Font
	body.TextSize = 13
	body.TextWrapped = true
	body.TextColor3 = Theme.Colors.TextSecondary
	body.TextXAlignment = Enum.TextXAlignment.Left
	body.TextYAlignment = Enum.TextYAlignment.Top
	body.Text = "Disco'da elinde tutabileceğin, renk değiştiren ışıklı bir çubuk. Sadece parti alanında kullanılabilir. Almak ister misin? (50 Robux)"
	body.Parent = card

	local declineButton = Instance.new("TextButton")
	declineButton.Position = UDim2.new(0, 16, 1, -56)
	declineButton.Size = UDim2.new(0.48, -8, 0, 40)
	declineButton.BackgroundColor3 = Theme.Colors.SurfaceGlass
	declineButton.Font = Theme.Font
	declineButton.TextSize = 13
	declineButton.TextColor3 = Theme.Colors.TextSecondary
	declineButton.Text = "Hayır"
	declineButton.Parent = card
	Theme.applyCorner(declineButton, UDim.new(0, 8))

	local acceptButton = Instance.new("TextButton")
	acceptButton.Position = UDim2.new(0.52, 0, 1, -56)
	acceptButton.Size = UDim2.new(0.48, -8, 0, 40)
	acceptButton.BackgroundColor3 = Theme.Colors.AccentRed
	acceptButton.Font = Theme.FontBold
	acceptButton.TextSize = 13
	acceptButton.TextColor3 = Theme.Colors.TextPrimary
	acceptButton.Text = "Satın Al"
	acceptButton.Parent = card
	Theme.applyCorner(acceptButton, UDim.new(0, 8))

	local function close()
		Theme.popOut(card, function()
			screenGui:Destroy()
		end)
	end

	declineButton.MouseButton1Click:Connect(close)
	acceptButton.MouseButton1Click:Connect(function()
		if GamepassIds.RainbowStick ~= 0 then
			MarketplaceService:PromptGamePassPurchase(player, GamepassIds.RainbowStick)
		end
		close()
	end)
end

function RainbowStickOfferClient.init()
	rainbowStickOfferEvent.OnClientEvent:Connect(showOffer)
end

return RainbowStickOfferClient
