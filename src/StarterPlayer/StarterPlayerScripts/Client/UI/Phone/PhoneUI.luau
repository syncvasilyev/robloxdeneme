--!strict
-- A literal phone-shaped UI (rounded body, notch, screen), separate from the + control-center
-- menu (see MainMenu/MainMenuUI.luau). Home screen shows app icons; tapping one opens that
-- app's content with a back button. Other client systems call PhoneUI.registerApp(...) to plug
-- in, same registration pattern as MainMenuUI.registerTab — safe before or after PhoneUI.init().

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Modules.Theme)

local PhoneUI = {}

type AppDefinition = {
	id: string,
	label: string,
	icon: string,
	build: (Frame) -> (),
}

local appOrder: { string } = {}
local appDefinitions: { [string]: AppDefinition } = {}
local appContentFrames: { [string]: Frame } = {}
local appBuilt: { [string]: boolean } = {}

local phoneBody: Frame? = nil
local homeScreen: Frame? = nil
local appGrid: ScrollingFrame? = nil
local contentHost: Frame? = nil
local backButton: TextButton? = nil
local titleLabel: TextLabel? = nil
local isOpen = false

local function createCorner(parent: Instance, radius: UDim)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius
	corner.Parent = parent
end

local function showHome()
	if homeScreen then
		homeScreen.Visible = true
	end
	for _, frame in pairs(appContentFrames) do
		frame.Visible = false
	end
	if backButton then
		backButton.Visible = false
	end
	if titleLabel then
		titleLabel.Text = "Telefon"
	end
end

local function openApp(id: string)
	local definition = appDefinitions[id]
	if not definition then
		return
	end

	if homeScreen then
		homeScreen.Visible = false
	end
	local frame = appContentFrames[id]
	if not appBuilt[id] then
		definition.build(frame)
		appBuilt[id] = true
	end
	frame.Visible = true

	if backButton then
		backButton.Visible = true
	end
	if titleLabel then
		titleLabel.Text = definition.label
	end
end

local function mountApp(id: string)
	local definition = appDefinitions[id]
	assert(appGrid and contentHost, "PhoneUI.init() must run before mounting apps")

	local iconButton = Instance.new("TextButton")
	iconButton.Name = id .. "Icon"
	iconButton.Size = UDim2.fromOffset(64, 64)
	iconButton.BackgroundColor3 = Theme.Colors.SurfaceGlass
	iconButton.Text = definition.icon
	iconButton.Font = Theme.Font
	iconButton.TextSize = 26
	iconButton.LayoutOrder = #appOrder
	iconButton.Parent = appGrid
	createCorner(iconButton, UDim.new(0, 16))

	local caption = Instance.new("TextLabel")
	caption.Size = UDim2.new(1, 0, 0, 16)
	caption.Position = UDim2.new(0, 0, 1, 2)
	caption.BackgroundTransparency = 1
	caption.Font = Theme.Font
	caption.TextSize = 10
	caption.TextColor3 = Theme.Colors.TextSecondary
	caption.Text = definition.label
	caption.Parent = iconButton

	iconButton.MouseButton1Click:Connect(function()
		openApp(id)
	end)

	local content = Instance.new("Frame")
	content.Name = id .. "Content"
	content.Size = UDim2.fromScale(1, 1)
	content.BackgroundTransparency = 1
	content.Visible = false
	content.Parent = contentHost
	appContentFrames[id] = content
end

--- Registers an app. Safe to call before or after PhoneUI.init().
function PhoneUI.registerApp(id: string, label: string, icon: string, build: (Frame) -> ())
	appDefinitions[id] = { id = id, label = label, icon = icon, build = build }
	table.insert(appOrder, id)
	if appGrid then
		mountApp(id)
	end
end

local function setOpen(open: boolean)
	isOpen = open
	assert(phoneBody, "PhoneUI.init() must run before toggling")
	local goalPosition = if open then UDim2.new(0.5, 0, 0.5, 0) else UDim2.new(0.5, 0, 1.5, 0)
	TweenService:Create(phoneBody, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Position = goalPosition }):Play()
	if open then
		showHome()
	end
end

function PhoneUI.toggle()
	setOpen(not isOpen)
end

function PhoneUI.close()
	if isOpen then
		setOpen(false)
	end
end

function PhoneUI.init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PhoneGui"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 15
	screenGui.Parent = playerGui

	local phoneButton = Instance.new("TextButton")
	phoneButton.Name = "PhoneButton"
	phoneButton.AnchorPoint = Vector2.new(1, 1)
	phoneButton.Position = UDim2.new(1, -96, 1, -24)
	phoneButton.Size = UDim2.fromOffset(56, 56)
	phoneButton.BackgroundColor3 = Theme.Colors.Surface
	phoneButton.Font = Theme.FontBold
	phoneButton.TextSize = 24
	phoneButton.TextColor3 = Theme.Colors.TextPrimary
	phoneButton.Text = "📱"
	phoneButton.Parent = screenGui
	createCorner(phoneButton, UDim.new(1, 0))
	Theme.applyGlass(phoneButton)
	phoneButton.MouseButton1Click:Connect(function()
		PhoneUI.toggle()
	end)

	local body = Instance.new("Frame")
	body.Name = "PhoneBody"
	body.AnchorPoint = Vector2.new(0.5, 0.5)
	body.Position = UDim2.new(0.5, 0, 1.5, 0)
	body.Size = UDim2.new(0, 300, 0, 560)
	body.BackgroundColor3 = Color3.fromRGB(8, 7, 7)
	body.BorderSizePixel = 0
	body.Parent = screenGui
	createCorner(body, UDim.new(0, 36))
	Theme.applyGlass(body)
	phoneBody = body

	local screenFrame = Instance.new("Frame")
	screenFrame.Name = "Screen"
	screenFrame.Position = UDim2.new(0, 10, 0, 10)
	screenFrame.Size = UDim2.new(1, -20, 1, -20)
	screenFrame.BackgroundColor3 = Theme.Colors.Background
	screenFrame.BorderSizePixel = 0
	screenFrame.ClipsDescendants = true
	screenFrame.Parent = body
	createCorner(screenFrame, UDim.new(0, 28))

	local notch = Instance.new("Frame")
	notch.AnchorPoint = Vector2.new(0.5, 0)
	notch.Position = UDim2.new(0.5, 0, 0, 6)
	notch.Size = UDim2.new(0, 90, 0, 14)
	notch.BackgroundColor3 = Color3.fromRGB(10, 9, 9)
	notch.ZIndex = 3
	notch.Parent = screenFrame
	createCorner(notch, UDim.new(1, 0))

	local topBarFrame = Instance.new("Frame")
	topBarFrame.Name = "TopBar"
	topBarFrame.Size = UDim2.new(1, 0, 0, 44)
	topBarFrame.Position = UDim2.new(0, 0, 0, 24)
	topBarFrame.BackgroundTransparency = 1
	topBarFrame.Parent = screenFrame

	local title = Instance.new("TextLabel")
	title.Name = "TitleLabel"
	title.Position = UDim2.new(0, 44, 0, 0)
	title.Size = UDim2.new(1, -88, 1, 0)
	title.BackgroundTransparency = 1
	title.Font = Theme.FontBlack
	title.TextSize = 17
	title.TextColor3 = Theme.Colors.TextPrimary
	title.Text = "Telefon"
	title.Parent = topBarFrame
	titleLabel = title

	local back = Instance.new("TextButton")
	back.Name = "BackButton"
	back.Position = UDim2.new(0, 8, 0, 6)
	back.Size = UDim2.fromOffset(32, 32)
	back.BackgroundColor3 = Theme.Colors.Surface
	back.Font = Theme.FontBold
	back.TextSize = 16
	back.TextColor3 = Theme.Colors.TextPrimary
	back.Text = "<"
	back.Visible = false
	back.Parent = topBarFrame
	createCorner(back, UDim.new(0, 8))
	back.MouseButton1Click:Connect(showHome)
	backButton = back

	local closeButton = Instance.new("TextButton")
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Position = UDim2.new(1, -8, 0, 6)
	closeButton.Size = UDim2.fromOffset(32, 32)
	closeButton.BackgroundColor3 = Theme.Colors.Surface
	closeButton.Font = Theme.FontBold
	closeButton.TextSize = 16
	closeButton.TextColor3 = Theme.Colors.TextPrimary
	closeButton.Text = "X"
	closeButton.Parent = topBarFrame
	createCorner(closeButton, UDim.new(0, 8))
	closeButton.MouseButton1Click:Connect(function()
		PhoneUI.close()
	end)

	local home = Instance.new("Frame")
	home.Name = "HomeScreen"
	home.Position = UDim2.new(0, 0, 0, 72)
	home.Size = UDim2.new(1, 0, 1, -72)
	home.BackgroundTransparency = 1
	home.Parent = screenFrame
	homeScreen = home

	local grid = Instance.new("ScrollingFrame")
	grid.Position = UDim2.new(0, 16, 0, 16)
	grid.Size = UDim2.new(1, -32, 1, -32)
	grid.BackgroundTransparency = 1
	grid.BorderSizePixel = 0
	grid.ScrollBarThickness = 4
	grid.CanvasSize = UDim2.new(0, 0, 0, 0)
	grid.AutomaticCanvasSize = Enum.AutomaticSize.Y
	grid.Parent = home
	appGrid = grid

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.fromOffset(64, 80)
	gridLayout.CellPadding = UDim2.fromOffset(16, 16)
	gridLayout.Parent = grid

	local contentHostFrame = Instance.new("Frame")
	contentHostFrame.Name = "ContentHost"
	contentHostFrame.Position = UDim2.new(0, 0, 0, 72)
	contentHostFrame.Size = UDim2.new(1, 0, 1, -72)
	contentHostFrame.BackgroundTransparency = 1
	contentHostFrame.Parent = screenFrame
	contentHost = contentHostFrame

	for _, id in ipairs(appOrder) do
		mountApp(id)
	end
end

return PhoneUI
