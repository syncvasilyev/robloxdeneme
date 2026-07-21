--!strict
-- Collects short notifications (Duo invites, system feedback messages) into an in-memory,
-- per-session rolling list shown in the phone's Bildirimler app. Not persisted across sessions.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Modules.Remotes)

local NotificationsClient = {}

local systemFeedbackEvent = Remotes.getEvent("SystemFeedback")
local duoInviteReceivedEvent = Remotes.getEvent("DuoInviteReceived")

local MAX_NOTIFICATIONS = 30
local notifications: { { text: string, time: number } } = {}
local listeners: { (any) -> () } = {}

local function push(text: string)
	table.insert(notifications, 1, { text = text, time = os.time() })
	while #notifications > MAX_NOTIFICATIONS do
		table.remove(notifications)
	end
	for _, listener in ipairs(listeners) do
		listener(notifications)
	end
end

function NotificationsClient.getAll(): { { text: string, time: number } }
	return notifications
end

function NotificationsClient.onChanged(callback: (any) -> ())
	table.insert(listeners, callback)
end

function NotificationsClient.init()
	systemFeedbackEvent.OnClientEvent:Connect(function(message: string)
		push(message)
	end)
	duoInviteReceivedEvent.OnClientEvent:Connect(function(payload)
		if payload and type(payload.fromName) == "string" then
			push(("%s seni Duo bulmaya davet etti."):format(payload.fromName))
		end
	end)
end

return NotificationsClient
