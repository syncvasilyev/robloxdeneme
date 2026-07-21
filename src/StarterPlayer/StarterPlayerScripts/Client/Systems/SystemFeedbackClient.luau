--!strict
-- Shows short server-driven notices (e.g. /char, /unchar, mod command results) as chat system
-- messages.

local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Modules.Remotes)

local SystemFeedbackClient = {}

local systemFeedbackEvent = Remotes.getEvent("SystemFeedback")

function SystemFeedbackClient.init()
	systemFeedbackEvent.OnClientEvent:Connect(function(message: string)
		pcall(function()
			StarterGui:SetCore("ChatMakeSystemMessage", {
				Text = message,
				Color = Color3.fromRGB(220, 20, 60),
				Font = Enum.Font.GothamBold,
			})
		end)
	end)
end

return SystemFeedbackClient
