--!strict
-- Holding CTRL on the Public Map gives a small, capped speed boost (16 -> 20), not a
-- flight/speed-hack-scale boost. Server-authoritative so WalkSpeed can't be forged via remotes.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Modules.Remotes)
local ZoneTracker = require(script.Parent.Parent.Data.ZoneTracker)

local SprintSystem = {}

local PUBLIC_MAP_ZONE_TAG = "PublicMapZone"
local NORMAL_SPEED = 16
local SPRINT_SPEED = 20

local setSprintingEvent = Remotes.getEvent("SetSprinting")

local function onSetSprinting(player: Player, wantsSprint: any)
	if type(wantsSprint) ~= "boolean" then
		return
	end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local canSprint = wantsSprint and ZoneTracker.isPlayerInTag(player, PUBLIC_MAP_ZONE_TAG)
	humanoid.WalkSpeed = if canSprint then SPRINT_SPEED else NORMAL_SPEED
end

function SprintSystem.init()
	setSprintingEvent.OnServerEvent:Connect(onSetSprinting)

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			local humanoid = character:WaitForChild("Humanoid") :: Humanoid
			humanoid.WalkSpeed = NORMAL_SPEED
		end)
	end)
end

return SprintSystem
