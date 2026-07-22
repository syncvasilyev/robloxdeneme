--!strict
-- A dance/emote button + menu, visible only while the local player is actively in a party (which,
-- per PartySystem, always means physically inside that party's disco instance). Plays one of
-- Roblox's default bundled R15 emote animations at a time; picking a new one stops the last.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Modules.Theme)
local Remotes = require(ReplicatedStorage.Modules.Remotes)

local DanceMenuClient = {}

local partyStateEvent = Remotes.getEvent("PartyStateChanged")

-- Default animations bundled with every R15 avatar — usable without any extra permissions.
local EMOTES = {
	{ label = "Dans 1", icon = "💃", id = "rbxassetid://507771019" },
	{ label = "Dans 2", icon = "🕺", id = "rbxassetid://507776043" },
	{ label = "Dans 3", icon = "✨", id = "rbxassetid://507777268" },
	{ label = "Sallan", icon = "👋", id = "rbxassetid://507770239" },
	{ label = "Kutla", icon = "🎉", id = "rbxassetid://507770677" },
	{ label = "Gül", icon = "😂", id = "rbxassetid://507770818" },
}

local currentTrack: AnimationTrack? = nil

local function stopEmote()
	if currentTrack then
		currentTrack:Stop(0.15)
		currentTrack = nil
	end
end

local function playEmote(animationId: string)
	local player = Players.LocalPlayer
	local character = player.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

	stopEmote()

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local success, track = pcall(function()
		return animator:LoadAnimation(animation)
	end)
	if success and track then
		track.Priority = Enum.AnimationPriority.Action
		track.Looped = true
		track:Play(0.15)
		currentTrack = track
	end
end

function DanceMenuClient.init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DanceMenuGui"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 20
	screenGui.Parent = playerGui

	local danceButton = Instance.new("TextButton")
	danceButton.Name = "DanceButton"
	danceButton.AnchorPoint = Vector2.new(0, 1)
	danceButton.Position = UDim2.new(0, 24, 1, -24)
	danceButton.Size = UDim2.fromOffset(58, 58)
	danceButton.BackgroundColor3 = Theme.Colors.AccentRed
	danceButton.Font = Theme.FontBlack
	danceButton.TextSize = 24
	danceButton.TextColor3 = Theme.Colors.TextPrimary
	danceButton.Text = "💃"
	danceButton.Visible = false
	danceButton.Parent = screenGui
	Theme.applyCorner(danceButton, UDim.new(1, 0))
	Theme.applyGlass(danceButton)

	local panel = Instance.new("Frame")
	panel.Name = "DancePanel"
	panel.AnchorPoint = Vector2.new(0, 1)
	panel.Position = UDim2.new(0, 24, 1, -92)
	panel.Size = UDim2.new(0, 280, 0, 220)
	panel.BackgroundColor3 = Theme.Colors.Surface
	panel.Visible = false
	panel.Parent = screenGui
	Theme.applyCorner(panel, Theme.CornerRadius)
	Theme.applyGlass(panel)

	local title = Instance.new("TextLabel")
	title.Position = UDim2.new(0, 16, 0, 12)
	title.Size = UDim2.new(1, -32, 0, 24)
	title.BackgroundTransparency = 1
	title.Font = Theme.FontBold
	title.TextSize = 15
	title.TextColor3 = Theme.Colors.TextPrimary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "Dans / Emote"
	title.Parent = panel

	local grid = Instance.new("ScrollingFrame")
	grid.Position = UDim2.new(0, 16, 0, 44)
	grid.Size = UDim2.new(1, -32, 0, 120)
	grid.BackgroundTransparency = 1
	grid.BorderSizePixel = 0
	grid.ScrollBarThickness = 4
	grid.CanvasSize = UDim2.new(0, 0, 0, 0)
	grid.AutomaticCanvasSize = Enum.AutomaticSize.Y
	grid.Parent = panel

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.fromOffset(76, 56)
	gridLayout.CellPadding = UDim2.fromOffset(8, 8)
	gridLayout.Parent = grid

	for _, emote in ipairs(EMOTES) do
		local emoteButton = Instance.new("TextButton")
		emoteButton.Size = UDim2.fromOffset(76, 56)
		emoteButton.BackgroundColor3 = Theme.Colors.SurfaceGlass
		emoteButton.Font = Theme.Font
		emoteButton.TextSize = 12
		emoteButton.TextColor3 = Theme.Colors.TextPrimary
		emoteButton.Text = emote.icon .. "\n" .. emote.label
		emoteButton.TextWrapped = true
		emoteButton.Parent = grid
		Theme.applyCorner(emoteButton, UDim.new(0, 8))
		emoteButton.MouseButton1Click:Connect(function()
			playEmote(emote.id)
		end)
	end

	local stopButton = Instance.new("TextButton")
	stopButton.Position = UDim2.new(0, 16, 1, -44)
	stopButton.Size = UDim2.new(1, -32, 0, 32)
	stopButton.BackgroundColor3 = Theme.Colors.Surface
	stopButton.Font = Theme.FontBold
	stopButton.TextSize = 13
	stopButton.TextColor3 = Theme.Colors.TextSecondary
	stopButton.Text = "⏹ Durdur"
	stopButton.Parent = panel
	Theme.applyCorner(stopButton, UDim.new(0, 8))
	stopButton.MouseButton1Click:Connect(stopEmote)

	danceButton.MouseButton1Click:Connect(function()
		panel.Visible = not panel.Visible
	end)

	partyStateEvent.OnClientEvent:Connect(function(state)
		local inParty = state ~= nil and not state.error
		danceButton.Visible = inParty
		if not inParty then
			panel.Visible = false
			stopEmote()
		end
	end)

	player.CharacterAdded:Connect(function()
		currentTrack = nil
	end)
end

return DanceMenuClient
