--!strict
-- Builds a 3-slide onboarding card entirely in code (no pre-authored Studio GUI needed yet).
-- Swap this for hand-designed GUI once the real UI art exists in Studio.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Modules.Theme)

local OnboardingUI = {}

local SLIDES = {
	{
		title = "Hoş Geldin",
		body = "Burası arkadaşlarınla vakit geçirebileceğin, sosyalleşebileceğin premium bir dünya.",
	},
	{
		title = "Sosyal Sistemler",
		body = "Grup kur, parti başlat, Disco'da dans et. Ekranındaki + menüsünden tüm özelliklere ulaşabilirsin.",
	},
	{
		title = "Profilini Oluştur",
		body = "Telefonundan profil fotoğrafını, nickname'ini ve bio'nu ayarlayabilirsin. Hazır olduğunda başlayalım!",
	},
}

local function createCorner(parent: Instance, radius: UDim)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius
	corner.Parent = parent
end

function OnboardingUI.show(onComplete: () -> ())
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local existing = playerGui:FindFirstChild("OnboardingGui")
	if existing then
		existing:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "OnboardingGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 100
	screenGui.Parent = playerGui

	local backdrop = Instance.new("Frame")
	backdrop.Name = "Backdrop"
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Theme.Colors.Background
	backdrop.BackgroundTransparency = 0
	backdrop.BorderSizePixel = 0
	backdrop.Parent = screenGui

	local card = Instance.new("Frame")
	card.Name = "Card"
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.Size = UDim2.new(0, 460, 0, 320)
	card.BackgroundColor3 = Theme.Colors.Surface
	card.BorderSizePixel = 0
	card.Parent = backdrop
	createCorner(card, Theme.CornerRadius)
	Theme.applyGlass(card)
	Theme.popIn(card)

	local accentBar = Instance.new("Frame")
	accentBar.Name = "AccentBar"
	accentBar.Size = UDim2.new(1, 0, 0, 6)
	accentBar.BackgroundColor3 = Theme.Colors.AccentRed
	accentBar.BorderSizePixel = 0
	accentBar.Parent = card
	createCorner(accentBar, UDim.new(0, 3))

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Position = UDim2.new(0, 32, 0, 40)
	title.Size = UDim2.new(1, -64, 0, 40)
	title.BackgroundTransparency = 1
	title.Font = Theme.FontBold
	title.TextSize = 28
	title.TextColor3 = Theme.Colors.TextPrimary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = card

	local body = Instance.new("TextLabel")
	body.Name = "Body"
	body.Position = UDim2.new(0, 32, 0, 90)
	body.Size = UDim2.new(1, -64, 0, 120)
	body.BackgroundTransparency = 1
	body.Font = Theme.Font
	body.TextSize = 18
	body.TextColor3 = Theme.Colors.TextSecondary
	body.TextWrapped = true
	body.TextXAlignment = Enum.TextXAlignment.Left
	body.TextYAlignment = Enum.TextYAlignment.Top
	body.Parent = card

	local dots = Instance.new("Frame")
	dots.Name = "Dots"
	dots.AnchorPoint = Vector2.new(0.5, 0)
	dots.Position = UDim2.new(0.5, 0, 0, 232)
	dots.Size = UDim2.new(0, #SLIDES * 20, 0, 10)
	dots.BackgroundTransparency = 1
	dots.Parent = card

	local dotsLayout = Instance.new("UIListLayout")
	dotsLayout.FillDirection = Enum.FillDirection.Horizontal
	dotsLayout.Padding = UDim.new(0, 8)
	dotsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	dotsLayout.Parent = dots

	local dotObjects = {}
	for i = 1, #SLIDES do
		local dot = Instance.new("Frame")
		dot.Name = "Dot" .. i
		dot.Size = UDim2.fromOffset(10, 10)
		dot.BackgroundColor3 = Theme.Colors.Divider
		dot.BorderSizePixel = 0
		dot.LayoutOrder = i
		dot.Parent = dots
		createCorner(dot, UDim.new(1, 0))
		dotObjects[i] = dot
	end

	local nextButton = Instance.new("TextButton")
	nextButton.Name = "NextButton"
	nextButton.AnchorPoint = Vector2.new(0.5, 1)
	nextButton.Position = UDim2.new(0.5, 0, 1, -32)
	nextButton.Size = UDim2.new(1, -64, 0, 48)
	nextButton.BackgroundColor3 = Theme.Colors.AccentRed
	nextButton.Font = Theme.FontBold
	nextButton.TextSize = 18
	nextButton.TextColor3 = Theme.Colors.TextPrimary
	nextButton.AutoButtonColor = true
	nextButton.Parent = card
	createCorner(nextButton, UDim.new(0, 10))

	local currentSlide = 1

	local function renderSlide()
		local slide = SLIDES[currentSlide]
		title.Text = slide.title
		body.Text = slide.body
		nextButton.Text = if currentSlide == #SLIDES then "Başla" else "Devam Et"

		for i, dot in ipairs(dotObjects) do
			dot.BackgroundColor3 = if i == currentSlide then Theme.Colors.AccentRedBright else Theme.Colors.Divider
		end
	end

	nextButton.MouseButton1Click:Connect(function()
		if currentSlide < #SLIDES then
			currentSlide += 1
			renderSlide()
		else
			local tween = TweenService:Create(backdrop, TweenInfo.new(0.35), { BackgroundTransparency = 1 })
			tween:Play()
			tween.Completed:Wait()
			screenGui:Destroy()
			onComplete()
		end
	end)

	renderSlide()
end

return OnboardingUI
