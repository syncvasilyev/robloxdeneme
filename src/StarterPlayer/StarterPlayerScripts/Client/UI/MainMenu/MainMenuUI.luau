--!strict
-- Floating "+" button and sliding side panel that hosts all feature tabs. Other client systems
-- call MainMenuUI.registerTab(id, label, build) to plug their own UI into a tab without this
-- module needing to know about them. registerTab works whether it's called before or after
-- MainMenuUI.init() runs.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Modules.Theme)

local MainMenuUI = {}

type TabDefinition = {
	id: string,
	label: string,
	build: (Frame) -> (),
}

local tabOrder: { string } = {}
local tabDefinitions: { [string]: TabDefinition } = {}
local tabButtons: { [string]: TextButton } = {}
local tabContentFrames: { [string]: Frame } = {}
local tabBuilt: { [string]: boolean } = {}

local panel: Frame? = nil
local tabBarFrame: ScrollingFrame? = nil
local contentHost: Frame? = nil
local selectedTabId: string? = nil
local isOpen = false

local function createCorner(parent: Instance, radius: UDim)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius
	corner.Parent = parent
end

local function selectTab(id: string)
	if selectedTabId == id then
		return
	end
	if selectedTabId and tabContentFrames[selectedTabId] then
		tabContentFrames[selectedTabId].Visible = false
		tabButtons[selectedTabId].BackgroundColor3 = Theme.Colors.Surface
	end

	selectedTabId = id
	local definition = tabDefinitions[id]
	local frame = tabContentFrames[id]

	if not tabBuilt[id] then
		definition.build(frame)
		tabBuilt[id] = true
	end

	frame.Visible = true
	tabButtons[id].BackgroundColor3 = Theme.Colors.AccentRed
end

local function mountTab(id: string)
	local definition = tabDefinitions[id]
	assert(panel and tabBarFrame and contentHost, "MainMenuUI.init() must run before mounting tabs")

	local button = Instance.new("TextButton")
	button.Name = id .. "Tab"
	button.Size = UDim2.new(1, 0, 0, 44)
	button.BackgroundColor3 = Theme.Colors.Surface
	button.Font = Theme.Font
	button.TextSize = 15
	button.TextColor3 = Theme.Colors.TextPrimary
	button.Text = definition.label
	button.AutoButtonColor = true
	button.LayoutOrder = #tabOrder
	button.Parent = tabBarFrame
	createCorner(button, UDim.new(0, 8))
	tabButtons[id] = button

	local content = Instance.new("Frame")
	content.Name = id .. "Content"
	content.Size = UDim2.fromScale(1, 1)
	content.BackgroundTransparency = 1
	content.Visible = false
	content.Parent = contentHost
	tabContentFrames[id] = content

	button.MouseButton1Click:Connect(function()
		selectTab(id)
	end)
end

--- Registers a tab. Safe to call before or after MainMenuUI.init().
function MainMenuUI.registerTab(id: string, label: string, build: (Frame) -> ())
	tabDefinitions[id] = { id = id, label = label, build = build }
	table.insert(tabOrder, id)

	if panel then
		mountTab(id)
		if not selectedTabId then
			selectTab(id)
		end
	end
end

local function setOpen(open: boolean)
	isOpen = open
	assert(panel, "MainMenuUI.init() must run before toggling the menu")
	local goalPosition = if open then UDim2.new(1, -420, 0.5, 0) else UDim2.new(1, 40, 0.5, 0)
	TweenService:Create(panel, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Position = goalPosition }):Play()
end

function MainMenuUI.toggle()
	setOpen(not isOpen)
end

function MainMenuUI.close()
	if isOpen then
		setOpen(false)
	end
end

function MainMenuUI.init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MainMenuGui"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 10
	screenGui.Parent = playerGui

	local plusButton = Instance.new("TextButton")
	plusButton.Name = "PlusButton"
	plusButton.AnchorPoint = Vector2.new(1, 1)
	plusButton.Position = UDim2.new(1, -24, 1, -24)
	plusButton.Size = UDim2.fromOffset(56, 56)
	plusButton.BackgroundColor3 = Theme.Colors.AccentRed
	plusButton.Font = Theme.FontBold
	plusButton.TextSize = 30
	plusButton.TextColor3 = Theme.Colors.TextPrimary
	plusButton.Text = "+"
	plusButton.Parent = screenGui
	createCorner(plusButton, UDim.new(1, 0))
	plusButton.MouseButton1Click:Connect(function()
		MainMenuUI.toggle()
	end)

	local panelFrame = Instance.new("Frame")
	panelFrame.Name = "Panel"
	panelFrame.AnchorPoint = Vector2.new(0, 0.5)
	panelFrame.Position = UDim2.new(1, 40, 0.5, 0)
	panelFrame.Size = UDim2.new(0, 460, 0, 560)
	panelFrame.BackgroundColor3 = Theme.Colors.Background
	panelFrame.BorderSizePixel = 0
	panelFrame.Parent = screenGui
	createCorner(panelFrame, Theme.CornerRadius)
	panel = panelFrame

	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Position = UDim2.new(1, -12, 0, 12)
	closeButton.Size = UDim2.fromOffset(32, 32)
	closeButton.BackgroundColor3 = Theme.Colors.Surface
	closeButton.Font = Theme.FontBold
	closeButton.TextSize = 18
	closeButton.TextColor3 = Theme.Colors.TextPrimary
	closeButton.Text = "X"
	closeButton.Parent = panelFrame
	createCorner(closeButton, UDim.new(0, 8))
	closeButton.MouseButton1Click:Connect(function()
		MainMenuUI.close()
	end)

	local tabBar = Instance.new("ScrollingFrame")
	tabBar.Name = "TabBar"
	tabBar.Position = UDim2.new(0, 16, 0, 60)
	tabBar.Size = UDim2.new(0, 130, 1, -76)
	tabBar.BackgroundTransparency = 1
	tabBar.BorderSizePixel = 0
	tabBar.ScrollBarThickness = 4
	tabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabBar.Parent = panelFrame
	tabBarFrame = tabBar

	local tabBarLayout = Instance.new("UIListLayout")
	tabBarLayout.Padding = UDim.new(0, 6)
	tabBarLayout.Parent = tabBar

	local contentHostFrame = Instance.new("Frame")
	contentHostFrame.Name = "ContentHost"
	contentHostFrame.Position = UDim2.new(0, 162, 0, 60)
	contentHostFrame.Size = UDim2.new(1, -178, 1, -76)
	contentHostFrame.BackgroundColor3 = Theme.Colors.Surface
	contentHostFrame.BorderSizePixel = 0
	contentHostFrame.Parent = panelFrame
	createCorner(contentHostFrame, UDim.new(0, 10))
	contentHost = contentHostFrame

	for _, id in ipairs(tabOrder) do
		mountTab(id)
	end
	if tabOrder[1] then
		selectTab(tabOrder[1])
	end
end

return MainMenuUI
