--!strict
-- Server-wide radio Mods/Admins can broadcast to every player (distinct from PartySystem's
-- party-scoped DJ music). Triggered via chat commands in ModAdminSystem, not its own remotes,
-- since there's no dedicated Mod Radio UI — the outbound state broadcast is the only remote.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Modules.Remotes)
local PartyTracks = require(ReplicatedStorage.Modules.PartyTracks)

local ModRadioSystem = {}

local radioStateEvent = Remotes.getEvent("ModRadioStateChanged")

local currentState: { trackId: string?, startedAt: number, isPlaying: boolean } = {
	trackId = nil,
	startedAt = 0,
	isPlaying = false,
}

local function broadcastState()
	for _, player in ipairs(Players:GetPlayers()) do
		radioStateEvent:FireClient(player, currentState)
	end
end

function ModRadioSystem.playTrack(trackId: string): boolean
	local exists = false
	for _, track in ipairs(PartyTracks) do
		if track.id == trackId then
			exists = true
			break
		end
	end
	if not exists then
		return false
	end

	currentState = { trackId = trackId, startedAt = os.time(), isPlaying = true }
	broadcastState()
	return true
end

function ModRadioSystem.stop()
	currentState = { trackId = nil, startedAt = 0, isPlaying = false }
	broadcastState()
end

function ModRadioSystem.init()
	Players.PlayerAdded:Connect(function(player)
		radioStateEvent:FireClient(player, currentState)
	end)
end

return ModRadioSystem
