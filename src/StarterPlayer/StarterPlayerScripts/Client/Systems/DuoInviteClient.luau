--!strict
-- Shows a small accept/decline popup when another player sends a Duo invite.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Modules.Theme)
local DuoClient = require(script.Parent.DuoClient)

local DuoInviteClient = {}

local function createCorner(parent: Instance, radius: UDim)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius
	corner.Parent = parent
end

local function showInvitePopup(fromName: string)
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local existing = playerGui:FindFirstChild("DuoInviteGui")
	if existing then
		existing:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DuoInviteGui"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 60
	screenGui.Parent = playerGui

	local card = Instance.new("Frame")
	card.AnchorPoint = Vector2.new(0.5, 0)
	card.Position = UDim2.new(0.5, 0, 0, 24)
	card.Size = UDim2.new(0, 320, 0, 100)
	card.BackgroundColor3 = Theme.Colors.Surface
	card.Parent = screenGui
	createCorner(card, Theme.CornerRadius)

	local label = Instance.new("TextLabel")
	label.Position = UDim2.new(0, 16, 0, 12)
	label.Size = UDim2.new(1, -32, 0, 32)
	label.BackgroundTransparency = 1
	label.Font = Theme.Font
	label.TextSize = 14
	label.TextWrapped = true
	label.TextColor3 = Theme.Colors.TextPrimary
	label.Text = ("%s seni Duo bulmaya davet etti."):format(fromName)
	label.Parent = card

	local acceptButton = Instance.new("TextButton")
	acceptButton.Position = UDim2.new(0, 16, 0, 52)
	acceptButton.Size = UDim2.new(0.48, -8, 0, 34)
	acceptButton.BackgroundColor3 = Theme.Colors.AccentRed
	acceptButton.Font = Theme.FontBold
	acceptButton.TextSize = 13
	acceptButton.TextColor3 = Theme.Colors.TextPrimary
	acceptButton.Text = "Kabul Et"
	acceptButton.Parent = card
	createCorner(acceptButton, UDim.new(0, 8))

	local declineButton = Instance.new("TextButton")
	declineButton.AnchorPoint = Vector2.new(1, 0)
	declineButton.Position = UDim2.new(1, -16, 0, 52)
	declineButton.Size = UDim2.new(0.48, -8, 0, 34)
	declineButton.BackgroundColor3 = Theme.Colors.SurfaceGlass
	declineButton.Font = Theme.Font
	declineButton.TextSize = 13
	declineButton.TextColor3 = Theme.Colors.TextPrimary
	declineButton.Text = "Reddet"
	declineButton.Parent = card
	createCorner(declineButton, UDim.new(0, 8))

	acceptButton.MouseButton1Click:Connect(function()
		DuoClient.respondInvite(fromName, true)
		screenGui:Destroy()
	end)
	declineButton.MouseButton1Click:Connect(function()
		DuoClient.respondInvite(fromName, false)
		screenGui:Destroy()
	end)
end

function DuoInviteClient.init()
	DuoClient.onInviteReceived(function(payload)
		if payload and type(payload.fromName) == "string" then
			showInvitePopup(payload.fromName)
		end
	end)
end

return DuoInviteClient
