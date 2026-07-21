--!strict
-- Plays whatever track a Mod/Admin has broadcast server-wide via "/radio play <trackId>".

local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Modules.Remotes)
local PartyTracks = require(ReplicatedStorage.Modules.PartyTracks)

local ModRadioClient = {}

local radioStateEvent = Remotes.getEvent("ModRadioStateChanged")

local trackAssetsById: { [string]: string } = {}
for _, track in ipairs(PartyTracks) do
	trackAssetsById[track.id] = track.assetId
end

local currentSound: Sound? = nil

local function stopCurrentSound()
	if currentSound then
		currentSound:Stop()
		currentSound:Destroy()
		currentSound = nil
	end
end

local function playTrack(assetId: string, startedAt: number)
	stopCurrentSound()

	local sound = Instance.new("Sound")
	sound.Name = "ModRadio"
	sound.SoundId = assetId
	sound.Looped = true
	sound.Volume = 0.5
	sound.Parent = SoundService
	sound.TimePosition = math.max(0, os.time() - startedAt)
	sound:Play()
	currentSound = sound
end

function ModRadioClient.init()
	radioStateEvent.OnClientEvent:Connect(function(state)
		if not state or not state.isPlaying or not state.trackId then
			stopCurrentSound()
			return
		end
		local assetId = trackAssetsById[state.trackId]
		if assetId then
			playTrack(assetId, state.startedAt)
		end
	end)
end

return ModRadioClient
