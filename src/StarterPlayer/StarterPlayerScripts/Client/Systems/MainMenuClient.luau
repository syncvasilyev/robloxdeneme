--!strict
-- Registers the + menu's default tabs. Each future system (Profile, Group, Party, ...) will
-- eventually own its tab's build function; for now unbuilt ones show a placeholder.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Modules.Theme)
local MainMenuUI = require(script.Parent.Parent.UI.MainMenu.MainMenuUI)
local OnboardingClient = require(script.Parent.OnboardingClient)
local ProfileClient = require(script.Parent.ProfileClient)
local ProfileTabUI = require(script.Parent.Parent.UI.ProfileTabUI)
local GroupClient = require(script.Parent.GroupClient)
local GroupTabUI = require(script.Parent.Parent.UI.GroupTabUI)
local PartyClient = require(script.Parent.PartyClient)
local PartyTabUI = require(script.Parent.Parent.UI.PartyTabUI)
local AmbientMusicClient = require(script.Parent.AmbientMusicClient)
local AudioTabUI = require(script.Parent.Parent.UI.AudioTabUI)
local CosmeticsClient = require(script.Parent.CosmeticsClient)
local CharacterTabUI = require(script.Parent.Parent.UI.CharacterTabUI)
local PremiumTabUI = require(script.Parent.Parent.UI.PremiumTabUI)

local MainMenuClient = {}

local function buildPlaceholder(text: string): (Frame) -> ()
	return function(parent: Frame)
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -32, 1, -32)
		label.Position = UDim2.new(0, 16, 0, 16)
		label.BackgroundTransparency = 1
		label.Font = Theme.Font
		label.TextSize = 16
		label.TextColor3 = Theme.Colors.TextSecondary
		label.TextWrapped = true
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Top
		label.Text = text
		label.Parent = parent
	end
end

local function buildSettingsTab(parent: Frame)
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

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = replayButton

	replayButton.MouseButton1Click:Connect(function()
		MainMenuUI.close()
		OnboardingClient.replay()
	end)
end

function MainMenuClient.init()
	MainMenuUI.init()

	MainMenuUI.registerTab("PROFILE", "Profil", function(parent: Frame)
		ProfileTabUI.build(parent, ProfileClient, CosmeticsClient)
	end)
	MainMenuUI.registerTab("CHARACTER", "Karakter", function(parent: Frame)
		CharacterTabUI.build(parent, CosmeticsClient)
	end)
	MainMenuUI.registerTab("GROUP", "Grup", function(parent: Frame)
		GroupTabUI.build(parent, GroupClient)
	end)
	MainMenuUI.registerTab("DUO", "Duo", buildPlaceholder("Duo bulma sistemi yakında burada olacak."))
	MainMenuUI.registerTab("PARTY", "Parti", function(parent: Frame)
		PartyTabUI.build(parent, PartyClient)
	end)
	MainMenuUI.registerTab("AUDIO", "Ses", function(parent: Frame)
		AudioTabUI.build(parent, AmbientMusicClient)
	end)
	MainMenuUI.registerTab("PREMIUM", "Premium", function(parent: Frame)
		PremiumTabUI.build(parent)
	end)
	MainMenuUI.registerTab("SETTINGS", "Ayarlar", buildSettingsTab)
end

return MainMenuClient
