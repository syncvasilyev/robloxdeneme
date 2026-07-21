--!strict
-- Replaces Roblox's default floating name with a custom BillboardGui, so the player's chosen
-- nickname (not just their Roblox username) and group color can be shown above their head.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
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
	billboard.Size = UDim2.fromOffset(200, 58)
	billboard.StudsOffset = Vector3.new(0, 2.4, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, 0, 0, 16)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Theme.FontBold
	titleLabel.TextSize = 12
	titleLabel.TextStrokeTransparency = 0.5
	titleLabel.TextColor3 = Theme.Colors.AccentRedBright
	titleLabel.Text = ""
	titleLabel.Visible = false
	titleLabel.Parent = billboard

	local label = Instance.new("TextLabel")
	label.Position = UDim2.new(0, 0, 0, 18)
	label.Size = UDim2.new(1, 0, 0, 40)
	label.BackgroundTransparency = 1
	label.Font = Theme.FontBold
	label.TextSize = 16
	label.TextStrokeTransparency = 0.5
	label.Text = (player:GetAttribute("Nickname") :: string?) or player.DisplayName
	label.TextColor3 = (player:GetAttribute("NicknameColor") :: Color3?) or Theme.Colors.TextPrimary
	label.Parent = billboard

	local function updateTitle()
		local title = player:GetAttribute("PartyHostTitle") :: string?
		titleLabel.Text = title or ""
		titleLabel.Visible = title ~= nil
	end
	updateTitle()
	player:GetAttributeChangedSignal("PartyHostTitle"):Connect(updateTitle)

	player:GetAttributeChangedSignal("Nickname"):Connect(function()
		label.Text = (player:GetAttribute("Nickname") :: string?) or player.DisplayName
	end)
	player:GetAttributeChangedSignal("NicknameColor"):Connect(function()
		if not player:GetAttribute("RainbowNickname") then
			label.TextColor3 = (player:GetAttribute("NicknameColor") :: Color3?) or Theme.Colors.TextPrimary
		end
	end)

	local rainbowConnection: RBXScriptConnection? = nil
	local function updateRainbowState()
		local isRainbow = player:GetAttribute("RainbowNickname") == true
		if isRainbow and not rainbowConnection then
			rainbowConnection = RunService.Heartbeat:Connect(function()
				local hue = (os.clock() * 0.15) % 1
				label.TextColor3 = Color3.fromHSV(hue, 0.85, 1)
			end)
		elseif not isRainbow and rainbowConnection then
			rainbowConnection:Disconnect()
			rainbowConnection = nil
			label.TextColor3 = (player:GetAttribute("NicknameColor") :: Color3?) or Theme.Colors.TextPrimary
		end
	end
	updateRainbowState()
	player:GetAttributeChangedSignal("RainbowNickname"):Connect(updateRainbowState)

	billboard.AncestryChanged:Connect(function()
		if not billboard:IsDescendantOf(game) and rainbowConnection then
			rainbowConnection:Disconnect()
			rainbowConnection = nil
		end
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
