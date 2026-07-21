--!strict
-- Logs player reports for staff to review later. Each report is stored under its own DataStore
-- key (rather than one growing list) to avoid write-conflicts and the ~4MB per-key size limit.
-- This is a supplementary in-game log, not a replacement for Roblox's own built-in "Report
-- Abuse" flow, which players can still use from the Roblox menu regardless of this system.

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Modules.Remotes)

local ReportSystem = {}

local reportsStore = DataStoreService:GetDataStore("PlayerReports_v1")
local reportPlayerEvent = Remotes.getEvent("ReportPlayer")

local REPORT_COOLDOWN_SECONDS = 30
local lastReportAt: { [Player]: number } = {}

local function onReportPlayer(player: Player, payload: any)
	local last = lastReportAt[player]
	if last and os.clock() - last < REPORT_COOLDOWN_SECONDS then
		return
	end

	if type(payload) ~= "table" or type(payload.targetUserId) ~= "number" then
		return
	end
	local reason = if type(payload.reason) == "string" then payload.reason:sub(1, 200) else ""

	lastReportAt[player] = os.clock()

	local key = ("Report_%d_%d"):format(os.time(), player.UserId)
	local success, err = pcall(function()
		reportsStore:SetAsync(key, {
			reporterUserId = player.UserId,
			reporterName = player.Name,
			targetUserId = payload.targetUserId,
			targetName = if type(payload.targetName) == "string" then payload.targetName else "",
			reason = reason,
			timestamp = os.time(),
		})
	end)
	if not success then
		warn(("ReportSystem: failed to save report from %s: %s"):format(player.Name, tostring(err)))
	end
end

function ReportSystem.init()
	reportPlayerEvent.OnServerEvent:Connect(onReportPlayer)
end

return ReportSystem
