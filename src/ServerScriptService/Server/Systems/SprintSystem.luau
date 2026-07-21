--!strict
-- Holding CTRL on the Public Map gives a small, capped speed boost on top of the player's base
-- speed (16, or 18 with the 100h playtime reward — see PlaytimeSystem), not a flight/speed-hack
-- scale boost. Server-authoritative so WalkSpeed can't be forged via remotes.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Modules.Remotes)
local ZoneTracker = require(script.Parent.Parent.Data.ZoneTracker)
local PlaytimeSystem = require(script.Parent.PlaytimeSystem)

local SprintSystem = {}

local PUBLIC_MAP_ZONE_TAG = "PublicMapZone"
local NORMAL_SPEED = 16
local BOOSTED_SPEED = 18
local SPRINT_ADD = 4

local setSprintingEvent = Remotes.getEvent("SetSprinting")

local function getBaseSpeed(player: Player): number
	return if PlaytimeSystem.hasSpeedBoost(player) then BOOSTED_SPEED else NORMAL_SPEED
end

local function onSetSprinting(player: Player, wantsSprint: any)
	if type(wantsSprint) ~= "boolean" then
		return
	end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local baseSpeed = getBaseSpeed(player)
	local canSprint = wantsSprint and ZoneTracker.isPlayerInTag(player, PUBLIC_MAP_ZONE_TAG)
	humanoid.WalkSpeed = if canSprint then baseSpeed + SPRINT_ADD else baseSpeed
end

function SprintSystem.init()
	setSprintingEvent.OnServerEvent:Connect(onSetSprinting)

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			local humanoid = character:WaitForChild("Humanoid") :: Humanoid
			humanoid.WalkSpeed = getBaseSpeed(player)
		end)
	end)
end

return SprintSystem
