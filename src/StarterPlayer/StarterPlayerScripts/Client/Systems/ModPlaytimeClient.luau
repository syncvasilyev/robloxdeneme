--!strict
-- Shows every other player's total playtime under their nametag — but only for the local viewer
-- if they're a Mod/Admin. The server-side gate lives in PlaytimeSystem's GetPlaytime remote
-- (StaffService.isMod check); this client just asks for everyone and quietly gets nothing back
-- if the local player isn't staff, so no client-side "am I a mod" check is needed here.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Modules.Remotes)
local NametagClient = require(script.Parent.NametagClient)

local ModPlaytimeClient = {}

local POLL_INTERVAL_SECONDS = 20

local getPlaytimeFunction = Remotes.getFunction("GetPlaytime")

local function formatHours(seconds: number): string
	return ("%dH"):format(math.floor(seconds / 3600))
end

local function refreshAll()
	local localPlayer = Players.LocalPlayer
	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= localPlayer then
			local success, seconds = pcall(function()
				return getPlaytimeFunction:InvokeServer(target.UserId)
			end)
			if success and type(seconds) == "number" then
				NametagClient.setPlaytimeText(target, formatHours(seconds))
			end
		end
	end
end

function ModPlaytimeClient.init()
	task.spawn(function()
		while true do
			refreshAll()
			task.wait(POLL_INTERVAL_SECONDS)
		end
	end)
end

return ModPlaytimeClient
