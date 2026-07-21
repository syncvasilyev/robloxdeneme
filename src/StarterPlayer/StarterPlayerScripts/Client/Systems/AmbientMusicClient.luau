--!strict
-- Soft background atmosphere music, respecting the player's saved volume preference.

local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Modules.Remotes)

local AmbientMusicClient = {}

local getSettingsFunction = Remotes.getFunction("GetSettings")

local ambientSound: Sound? = nil

function AmbientMusicClient.setVolume(volume: number)
	if ambientSound then
		ambientSound.Volume = volume
	end
end

function AmbientMusicClient.init()
	local sound = Instance.new("Sound")
	sound.Name = "AmbientMusic"
	sound.SoundId = "rbxassetid://0" -- TODO: replace with a licensed ambient track
	sound.Looped = true
	sound.Volume = 0.5
	sound.Parent = SoundService
	ambientSound = sound

	task.spawn(function()
		local success, settings = pcall(function()
			return getSettingsFunction:InvokeServer()
		end)
		if success and settings then
			sound.Volume = settings.musicVolume
		end
		sound:Play()
	end)
end

return AmbientMusicClient
