--!strict
-- Shows the local player's own playtime in a screen corner, e.g. "Playtime: 24h 32m". Other
-- players can't see this by default; Mods/Admins can query it via GetPlaytime with a userId.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Modules.Theme)
local Remotes = require(ReplicatedStorage.Modules.Remotes)

local PlaytimeClient = {}

local getPlaytimeFunction = Remotes.getFunction("GetPlaytime")

local REFRESH_INTERVAL_SECONDS = 60

local function formatPlaytime(totalSeconds: number): string
	local hours = math.floor(totalSeconds / 3600)
	local minutes = math.floor((totalSeconds % 3600) / 60)
	return ("Playtime: %dh %dm"):format(hours, minutes)
end

function PlaytimeClient.init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PlaytimeGui"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 5
	screenGui.Parent = playerGui

	local label = Instance.new("TextLabel")
	label.Name = "PlaytimeLabel"
	label.AnchorPoint = Vector2.new(1, 0)
	label.Position = UDim2.new(1, -16, 0, 16)
	label.Size = UDim2.new(0, 160, 0, 20)
	label.BackgroundTransparency = 1
	label.Font = Theme.Font
	label.TextSize = 13
	label.TextColor3 = Theme.Colors.TextSecondary
	label.TextXAlignment = Enum.TextXAlignment.Right
	label.Text = "Playtime: ..."
	label.Parent = screenGui

	task.spawn(function()
		while true do
			local success, seconds = pcall(function()
				return getPlaytimeFunction:InvokeServer(nil)
			end)
			if success and seconds then
				label.Text = formatPlaytime(seconds)
			end
			task.wait(REFRESH_INTERVAL_SECONDS)
		end
	end)
end

return PlaytimeClient
