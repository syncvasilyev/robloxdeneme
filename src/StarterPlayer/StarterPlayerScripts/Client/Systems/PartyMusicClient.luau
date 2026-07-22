--!strict
-- Plays the active party's currently selected track (a preset or a DJ-entered custom asset ID),
-- roughly synced across party members using the server-provided start timestamp. Ambient via
-- SoundService rather than positional — party members should hear it throughout their disco
-- instance, not just near a specific speaker part.

local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Modules.Remotes)
local PartyTracks = require(ReplicatedStorage.Modules.PartyTracks)

local PartyMusicClient = {}

local partyStateEvent = Remotes.getEvent("PartyStateChanged")

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
	sound.Name = "PartyMusic"
	sound.SoundId = assetId
	sound.Looped = true
	sound.Volume = 0.5
	sound.Parent = SoundService
	sound.TimePosition = math.max(0, os.time() - startedAt)
	sound:Play()
	currentSound = sound
end

function PartyMusicClient.init()
	partyStateEvent.OnClientEvent:Connect(function(state)
		if not state or not state.music or not state.music.isPlaying then
			stopCurrentSound()
			return
		end

		if state.music.customAssetId then
			playTrack(state.music.customAssetId, state.music.startedAt)
			return
		end

		if not state.music.trackId then
			stopCurrentSound()
			return
		end
		local assetId = trackAssetsById[state.music.trackId]
		if assetId then
			playTrack(assetId, state.music.startedAt)
		end
	end)
end

return PartyMusicClient
