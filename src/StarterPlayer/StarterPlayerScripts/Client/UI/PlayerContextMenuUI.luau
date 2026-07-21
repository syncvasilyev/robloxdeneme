--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Modules.Theme)

local PlayerContextMenuUI = {}

local VOLUME_STEP = 0.1

local function createCorner(parent: Instance, radius: UDim)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius
	corner.Parent = parent
end

function PlayerContextMenuUI.show(target: Player, PlayerVoiceVolumeClient: any, ReportClient: any)
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local existing = playerGui:FindFirstChild("PlayerContextMenuGui")
	if existing then
		existing:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PlayerContextMenuGui"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 50
	screenGui.Parent = playerGui

	local backdrop = Instance.new("TextButton")
	backdrop.Name = "Backdrop"
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundTransparency = 1
	backdrop.Text = ""
	backdrop.AutoButtonColor = false
	backdrop.Parent = screenGui
	backdrop.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)

	local card = Instance.new("Frame")
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.Size = UDim2.new(0, 300, 0, 220)
	card.BackgroundColor3 = Theme.Colors.Surface
	card.Parent = screenGui
	createCorner(card, Theme.CornerRadius)

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Position = UDim2.new(0, 16, 0, 16)
	nameLabel.Size = UDim2.new(1, -32, 0, 24)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Theme.FontBold
	nameLabel.TextSize = 16
	nameLabel.TextColor3 = Theme.Colors.TextPrimary
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = target.Name
	nameLabel.Parent = card

	local volumeLabel = Instance.new("TextLabel")
	volumeLabel.Position = UDim2.new(0, 16, 0, 48)
	volumeLabel.Size = UDim2.new(1, -32, 0, 20)
	volumeLabel.BackgroundTransparency = 1
	volumeLabel.Font = Theme.Font
	volumeLabel.TextSize = 13
	volumeLabel.TextColor3 = Theme.Colors.TextSecondary
	volumeLabel.TextXAlignment = Enum.TextXAlignment.Left
	volumeLabel.Parent = card

	local function currentVolumePercent(): number
		return math.round(PlayerVoiceVolumeClient.getVolume(target) * 100)
	end
	volumeLabel.Text = ("Ses: %d%%"):format(currentVolumePercent())

	local volumeRow = Instance.new("Frame")
	volumeRow.Position = UDim2.new(0, 16, 0, 76)
	volumeRow.Size = UDim2.new(1, -32, 0, 40)
	volumeRow.BackgroundTransparency = 1
	volumeRow.Parent = card

	local decreaseButton = Instance.new("TextButton")
	decreaseButton.Size = UDim2.new(0.48, -4, 1, 0)
	decreaseButton.BackgroundColor3 = Theme.Colors.SurfaceGlass
	decreaseButton.Font = Theme.FontBold
	decreaseButton.TextSize = 18
	decreaseButton.TextColor3 = Theme.Colors.TextPrimary
	decreaseButton.Text = "🔉 Azalt"
	decreaseButton.Parent = volumeRow
	createCorner(decreaseButton, UDim.new(0, 8))

	local increaseButton = Instance.new("TextButton")
	increaseButton.AnchorPoint = Vector2.new(1, 0)
	increaseButton.Position = UDim2.new(1, 0, 0, 0)
	increaseButton.Size = UDim2.new(0.48, -4, 1, 0)
	increaseButton.BackgroundColor3 = Theme.Colors.SurfaceGlass
	increaseButton.Font = Theme.FontBold
	increaseButton.TextSize = 18
	increaseButton.TextColor3 = Theme.Colors.TextPrimary
	increaseButton.Text = "🔊 Yükselt"
	increaseButton.Parent = volumeRow
	createCorner(increaseButton, UDim.new(0, 8))

	local function nudgeVolume(delta: number)
		local newVolume = math.clamp(PlayerVoiceVolumeClient.getVolume(target) + delta, 0, 1)
		PlayerVoiceVolumeClient.setVolume(target, newVolume)
		volumeLabel.Text = ("Ses: %d%%"):format(currentVolumePercent())
	end
	decreaseButton.MouseButton1Click:Connect(function()
		nudgeVolume(-VOLUME_STEP)
	end)
	increaseButton.MouseButton1Click:Connect(function()
		nudgeVolume(VOLUME_STEP)
	end)

	local reportButton = Instance.new("TextButton")
	reportButton.Position = UDim2.new(0, 16, 0, 132)
	reportButton.Size = UDim2.new(1, -32, 0, 40)
	reportButton.BackgroundColor3 = Theme.Colors.AccentRed
	reportButton.Font = Theme.FontBold
	reportButton.TextSize = 14
	reportButton.TextColor3 = Theme.Colors.TextPrimary
	reportButton.Text = "🚨 Rapor Et"
	reportButton.Parent = card
	createCorner(reportButton, UDim.new(0, 8))

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Position = UDim2.new(0, 16, 0, 180)
	statusLabel.Size = UDim2.new(1, -32, 0, 24)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Font = Theme.Font
	statusLabel.TextSize = 12
	statusLabel.TextColor3 = Theme.Colors.TextSecondary
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Text = ""
	statusLabel.Parent = card

	reportButton.MouseButton1Click:Connect(function()
		ReportClient.report(target, "Uygunsuz davranış")
		statusLabel.Text = "Rapor gönderildi."
		reportButton.Active = false
		reportButton.BackgroundColor3 = Theme.Colors.Surface
	end)
end

return PlayerContextMenuUI
