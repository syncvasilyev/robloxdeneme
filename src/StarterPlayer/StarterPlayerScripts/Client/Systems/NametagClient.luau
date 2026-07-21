--!strict
-- Replaces Roblox's default floating name with a custom BillboardGui, so the player's chosen
-- nickname (not just their Roblox username) and group color can be shown above their head.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Modules.Theme)

local NametagClient = {}

local function attachNametag(player: Player, character: Model)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not (humanoid and humanoid:IsA("Humanoid")) then
		return
	end
	humanoid.NameDisplayDistance = 0
	humanoid.HealthDisplayDistance = 0

	local head = character:WaitForChild("Head", 5)
	if not head then
		return
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "NicknameTag"
	billboard.Size = UDim2.fromOffset(200, 40)
	billboard.StudsOffset = Vector3.new(0, 2.2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Theme.FontBold
	label.TextSize = 16
	label.TextStrokeTransparency = 0.5
	label.Text = (player:GetAttribute("Nickname") :: string?) or player.DisplayName
	label.TextColor3 = (player:GetAttribute("NicknameColor") :: Color3?) or Theme.Colors.TextPrimary
	label.Parent = billboard

	player:GetAttributeChangedSignal("Nickname"):Connect(function()
		label.Text = (player:GetAttribute("Nickname") :: string?) or player.DisplayName
	end)
	player:GetAttributeChangedSignal("NicknameColor"):Connect(function()
		label.TextColor3 = (player:GetAttribute("NicknameColor") :: Color3?) or Theme.Colors.TextPrimary
	end)
end

local function onPlayerAdded(player: Player)
	if player.Character then
		attachNametag(player, player.Character)
	end
	player.CharacterAdded:Connect(function(character)
		attachNametag(player, character)
	end)
end

function NametagClient.init()
	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end
	Players.PlayerAdded:Connect(onPlayerAdded)
end

return NametagClient
