--!strict
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Modules.Remotes)

local SprintClient = {}

local setSprintingEvent = Remotes.getEvent("SetSprinting")

local function onInputBegan(input: InputObject, gameProcessed: boolean)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
		setSprintingEvent:FireServer(true)
	end
end

local function onInputEnded(input: InputObject, _gameProcessed: boolean)
	-- Deliberately ignores gameProcessed here: always try to cancel sprinting on key release so
	-- a focus change mid-hold (e.g. clicking a textbox) can't leave the player stuck sprinting.
	if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
		setSprintingEvent:FireServer(false)
	end
end

function SprintClient.init()
	UserInputService.InputBegan:Connect(onInputBegan)
	UserInputService.InputEnded:Connect(onInputEnded)
end

return SprintClient
