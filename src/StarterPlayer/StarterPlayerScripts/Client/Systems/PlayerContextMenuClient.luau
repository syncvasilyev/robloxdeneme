--!strict
-- Adds a ClickDetector to every other player's character so clicking them opens the
-- azalt/yükselt/rapor et menu.

local Players = game:GetService("Players")

local PlayerVoiceVolumeClient = require(script.Parent.PlayerVoiceVolumeClient)
local ReportClient = require(script.Parent.ReportClient)
local PlayerContextMenuUI = require(script.Parent.Parent.UI.PlayerContextMenuUI)

local PlayerContextMenuClient = {}

local localPlayer = Players.LocalPlayer

local function attachClickDetector(player: Player, character: Model)
	local rootPart = character:WaitForChild("HumanoidRootPart", 5) :: BasePart?
	if not rootPart then
		return
	end

	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 24
	clickDetector.Parent = rootPart

	clickDetector.MouseClick:Connect(function(clickingPlayer)
		if clickingPlayer == localPlayer then
			PlayerContextMenuUI.show(player, PlayerVoiceVolumeClient, ReportClient)
		end
	end)
end

local function onPlayerAdded(player: Player)
	if player == localPlayer then
		return
	end
	if player.Character then
		attachClickDetector(player, player.Character)
	end
	player.CharacterAdded:Connect(function(character)
		attachClickDetector(player, character)
	end)
end

function PlayerContextMenuClient.init()
	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end
	Players.PlayerAdded:Connect(onPlayerAdded)
end

return PlayerContextMenuClient
