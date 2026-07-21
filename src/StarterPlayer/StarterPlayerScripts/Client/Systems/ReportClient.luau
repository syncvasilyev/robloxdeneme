--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Modules.Remotes)

local ReportClient = {}

local reportPlayerEvent = Remotes.getEvent("ReportPlayer")

function ReportClient.report(target: Player, reason: string)
	reportPlayerEvent:FireServer({
		targetUserId = target.UserId,
		targetName = target.Name,
		reason = reason,
	})
end

return ReportClient
