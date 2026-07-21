--!strict
-- Visual for the 50h playtime reward: a heart-shaped balloon that floats above a player's hand
-- and bobs gently. Purely cosmetic and purely local rendering, driven by the "HasBalloon50h"
-- attribute (see PlaytimeSystem), same pattern as NametagClient's attribute-driven visuals.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local BalloonClient = {}

local function attachBalloon(player: Player, character: Model)
	local hand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	if not hand or not hand:IsA("BasePart") then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "BalloonAttachment"
	attachment.Position = Vector3.new(0, 1, 0)
	attachment.Parent = hand

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Balloon50h"
	billboard.Size = UDim2.fromOffset(40, 40)
	billboard.AlwaysOnTop = true
	billboard.Adornee = attachment
	billboard.Parent = hand

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "❤️"
	label.TextScaled = true
	label.Parent = billboard

	local connection: RBXScriptConnection
	connection = RunService.Heartbeat:Connect(function()
		if not billboard.Parent then
			connection:Disconnect()
			return
		end
		billboard.StudsOffset = Vector3.new(0, 0.3 * math.sin(os.clock() * 2), 0)
	end)
end

local function shouldHaveBalloon(player: Player): boolean
	return player:GetAttribute("HasBalloon50h") == true
end

local function onCharacterAdded(player: Player, character: Model)
	if shouldHaveBalloon(player) then
		attachBalloon(player, character)
	end
end

local function onPlayerAdded(player: Player)
	if player.Character then
		onCharacterAdded(player, player.Character)
	end
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
	player:GetAttributeChangedSignal("HasBalloon50h"):Connect(function()
		if shouldHaveBalloon(player) and player.Character then
			attachBalloon(player, player.Character)
		end
	end)
end

function BalloonClient.init()
	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end
	Players.PlayerAdded:Connect(onPlayerAdded)
end

return BalloonClient
