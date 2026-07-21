--!strict
-- Shows /char and /unchar results (errors, confirmations) as chat system messages.

local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Modules.Remotes)

local CharFeedbackClient = {}

local charFeedbackEvent = Remotes.getEvent("CharFeedback")

function CharFeedbackClient.init()
	charFeedbackEvent.OnClientEvent:Connect(function(message: string)
		pcall(function()
			StarterGui:SetCore("ChatMakeSystemMessage", {
				Text = message,
				Color = Color3.fromRGB(220, 20, 60),
				Font = Enum.Font.GothamBold,
			})
		end)
	end)
end

return CharFeedbackClient
