--!strict
-- Shared Settings content, used by both the + menu's SETTINGS tab and the phone's Ayarlar app.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Theme = require(ReplicatedStorage.Modules.Theme)

local SettingsTabUI = {}

local function createCorner(parent: Instance, radius: UDim)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius
	corner.Parent = parent
end

--- closeHost: whichever UI shell hosts this content (MainMenuUI or PhoneUI) — must expose close().
function SettingsTabUI.build(parent: Frame, OnboardingClient: any, closeHost: any)
	local replayButton = Instance.new("TextButton")
	replayButton.Name = "ReplayOnboardingButton"
	replayButton.Position = UDim2.new(0, 16, 0, 16)
	replayButton.Size = UDim2.new(1, -32, 0, 44)
	replayButton.BackgroundColor3 = Theme.Colors.AccentRed
	replayButton.Font = Theme.FontBold
	replayButton.TextSize = 15
	replayButton.TextColor3 = Theme.Colors.TextPrimary
	replayButton.Text = "Onboarding'i Tekrar Gör"
	replayButton.Parent = parent
	createCorner(replayButton, UDim.new(0, 8))

	replayButton.MouseButton1Click:Connect(function()
		closeHost.close()
		OnboardingClient.replay()
	end)
end

return SettingsTabUI
