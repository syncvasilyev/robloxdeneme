--!strict
-- Lets the local player privately adjust how loud each other player's voice chat sounds to
-- them (0-100%, default 50%). This only ever affects local playback — nobody else's audio
-- changes, and nothing here is replicated except the saved preference itself.
--
-- Built on Roblox's Audio API (AudioDeviceInput/AudioDeviceOutput/Wire), adapted from the
-- official "Non-Proximity Chat" sample (https://create.roblox.com/docs/chat/voice-chat):
-- instead of one shared global fader, each remote player gets their own AudioDeviceInput whose
-- own Volume property (0-3, confirmed via Roblox's class reference) is the per-listener gain.
-- Wiring voice through a custom AudioDeviceInput -> AudioDeviceOutput graph like this makes
-- that player's voice non-spatial (no distance falloff) while active, per Roblox's own docs.
--
-- Voice Chat must be enabled for this experience (and the listening player must have voice
-- access) for any of this to produce sound. This could not be tested against a live microphone
-- in this environment — verify with two real accounts in Studio and report back what you see so
-- this can be adjusted if the actual behavior differs from the documented API.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Modules.Remotes)

local PlayerVoiceVolumeClient = {}

local getSettingsFunction = Remotes.getFunction("GetSettings")
local setPlayerVolumeEvent = Remotes.getEvent("SetPlayerVolumeOverride")

local localPlayer = Players.LocalPlayer

local sharedOutput: Instance? = nil
local devices: { [Player]: AudioDeviceInput } = {}
local savedOverrides: { [string]: number } = {}

local function wireUp(source: Instance, target: Instance)
	local wire = Instance.new("Wire")
	wire.SourceInstance = source
	wire.TargetInstance = target
	wire.Parent = source
end

local function ensureSharedOutput(): Instance
	if not sharedOutput then
		local output = Instance.new("AudioDeviceOutput")
		output.Parent = localPlayer
		sharedOutput = output
	end
	return sharedOutput :: Instance
end

local function ensureDevice(player: Player): AudioDeviceInput
	local existing = devices[player]
	if existing then
		return existing
	end

	local device = Instance.new("AudioDeviceInput") :: AudioDeviceInput
	device.Player = player
	device.Volume = savedOverrides[tostring(player.UserId)] or 0.5
	device.Parent = localPlayer

	wireUp(device, ensureSharedOutput())

	devices[player] = device
	return device
end

function PlayerVoiceVolumeClient.getVolume(player: Player): number
	local device = devices[player]
	return if device then device.Volume else (savedOverrides[tostring(player.UserId)] or 0.5)
end

function PlayerVoiceVolumeClient.setVolume(player: Player, volume: number)
	volume = math.clamp(volume, 0, 1)
	local device = ensureDevice(player)
	device.Volume = volume
	savedOverrides[tostring(player.UserId)] = volume
	setPlayerVolumeEvent:FireServer({ targetUserId = player.UserId, volume = volume })
end

function PlayerVoiceVolumeClient.init()
	local success, settings = pcall(function()
		return getSettingsFunction:InvokeServer()
	end)
	if success and settings and settings.playerVolumeOverrides then
		savedOverrides = settings.playerVolumeOverrides
	end

	local function onPlayerAdded(player: Player)
		if player == localPlayer then
			return
		end
		ensureDevice(player)
	end

	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end
	Players.PlayerAdded:Connect(onPlayerAdded)

	Players.PlayerRemoving:Connect(function(player)
		devices[player] = nil
	end)
end

return PlayerVoiceVolumeClient
