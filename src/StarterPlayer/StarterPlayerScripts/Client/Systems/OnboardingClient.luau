--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Modules.Remotes)
local OnboardingUI = require(script.Parent.Parent.UI.OnboardingUI)

local OnboardingClient = {}

local showOnboardingEvent = Remotes.getEvent("ShowOnboarding")
local onboardingCompletedEvent = Remotes.getEvent("OnboardingCompleted")
local replayOnboardingEvent = Remotes.getEvent("ReplayOnboarding")

function OnboardingClient.init()
	showOnboardingEvent.OnClientEvent:Connect(function()
		OnboardingUI.show(function()
			onboardingCompletedEvent:FireServer()
		end)
	end)
end

--- Called from the + menu's "Onboarding'i Tekrar Gör" button.
function OnboardingClient.replay()
	replayOnboardingEvent:FireServer()
end

return OnboardingClient
