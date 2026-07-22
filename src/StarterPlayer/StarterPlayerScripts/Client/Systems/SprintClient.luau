--!strict
-- CTRL to sprint on keyboard; on touch devices, a press-and-hold on-screen button does the same
-- thing (SprintSystem doesn't care which input source triggered SetSprinting).

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Modules.Theme)
local Remotes = require(ReplicatedStorage.Modules.Remotes)

local SprintClient = {}

local setSprintingEvent = Remotes.getEvent("SetSprinting")

local function onInputBegan(input: InputObject, gameProcessed: boolean)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
		setSprintingEvent:FireServer(true)
	end
end

local function onInputEnded(input: InputObject, _gameProcessed: boolean)
	-- Deliberately ignores gameProcessed here: always try to cancel sprinting on key release so
	-- a focus change mid-hold (e.g. clicking a textbox) can't leave the player stuck sprinting.
	if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
		setSprintingEvent:FireServer(false)
	end
end

local function buildMobileButton()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SprintButtonGui"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 20
	screenGui.Parent = playerGui

	-- Sits above where the Dance button appears during a party (see DanceMenuClient), so the
	-- two never overlap even when both are visible on a mobile device mid-party.
	local button = Instance.new("TextButton")
	button.Name = "SprintButton"
	button.AnchorPoint = Vector2.new(0, 1)
	button.Position = UDim2.new(0, 24, 1, -100)
	button.Size = UDim2.fromOffset(58, 58)
	button.BackgroundColor3 = Theme.Colors.Surface
	button.Font = Theme.FontBold
	button.TextSize = 22
	button.TextColor3 = Theme.Colors.TextPrimary
	button.Text = "🏃"
	button.Parent = screenGui
	Theme.applyCorner(button, UDim.new(1, 0))
	Theme.applyGlass(button)

	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			setSprintingEvent:FireServer(true)
			button.BackgroundColor3 = Theme.Colors.AccentRed
		end
	end)
	button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			setSprintingEvent:FireServer(false)
			button.BackgroundColor3 = Theme.Colors.Surface
		end
	end)
end

function SprintClient.init()
	UserInputService.InputBegan:Connect(onInputBegan)
	UserInputService.InputEnded:Connect(onInputEnded)

	if UserInputService.TouchEnabled then
		buildMobileButton()
	end
end

return SprintClient
