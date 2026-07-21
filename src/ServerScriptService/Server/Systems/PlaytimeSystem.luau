--!strict
-- Tracks total playtime (via PlayerDataStore's live counter) and grants one-time rewards at
-- hour thresholds: 50h -> a cosmetic floating balloon, 100h -> a small permanent speed boost.
-- More thresholds can be added to grantRewards later. Players see only their own playtime;
-- Mods/Admins can query anyone's.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Modules.Remotes)
local StaffService = require(script.Parent.Parent.Data.StaffService)
local PlayerDataStore = require(script.Parent.Parent.Data.PlayerDataStore)

local PlaytimeSystem = {}

local HOUR_SECONDS = 3600
local CHECK_INTERVAL_SECONDS = 60
local BOOSTED_BASE_SPEED = 18

local getPlaytimeFunction = Remotes.getFunction("GetPlaytime")

local function livePlaytimeSeconds(player: Player): number
	return PlayerDataStore.getLivePlaytimeSeconds(player) or 0
end

local function onGetPlaytime(player: Player, targetUserId: any)
	if targetUserId ~= nil then
		if type(targetUserId) ~= "number" or not StaffService.isMod(player) then
			return nil
		end
		local target = Players:GetPlayerByUserId(targetUserId)
		if not target then
			return nil
		end
		return livePlaytimeSeconds(target)
	end
	return livePlaytimeSeconds(player)
end

local function grantRewards(player: Player)
	local data = PlayerDataStore.get(player)
	if not data then
		return
	end
	local seconds = livePlaytimeSeconds(player)

	if not data.rewards.balloon50h and seconds >= 50 * HOUR_SECONDS then
		data.rewards.balloon50h = true
		PlayerDataStore.save(player)
		player:SetAttribute("HasBalloon50h", true)
	end

	if not data.rewards.speedBoost100h and seconds >= 100 * HOUR_SECONDS then
		data.rewards.speedBoost100h = true
		PlayerDataStore.save(player)
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = BOOSTED_BASE_SPEED
		end
	end
end

--- Used by SprintSystem to pick the right base WalkSpeed (before/after the CTRL boost) for a
--- given player.
function PlaytimeSystem.hasSpeedBoost(player: Player): boolean
	local data = PlayerDataStore.get(player)
	return data ~= nil and data.rewards.speedBoost100h == true
end

function PlaytimeSystem.init()
	getPlaytimeFunction.OnServerInvoke = onGetPlaytime

	Players.PlayerAdded:Connect(function(player)
		task.spawn(function()
			local data = PlayerDataStore.waitForProfile(player)
			if data and data.rewards.balloon50h then
				player:SetAttribute("HasBalloon50h", true)
			end
			grantRewards(player)
		end)
	end)

	task.spawn(function()
		while true do
			task.wait(CHECK_INTERVAL_SECONDS)
			for _, player in ipairs(Players:GetPlayers()) do
				grantRewards(player)
			end
		end
	end)
end

return PlaytimeSystem
