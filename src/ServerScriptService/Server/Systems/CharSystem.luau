--!strict
-- "/char <name>" copies another player's avatar appearance onto your own character (visual
-- only — your name, data, and identity are untouched). "/unchar" restores your real appearance.
-- Only usable inside Public Map / Disco (parts tagged "CharZone" in Studio; see ZoneTracker),
-- and staff (Mods/Admins) can't be impersonated to prevent staff-impersonation scams.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Modules.Remotes)
local StaffService = require(script.Parent.Parent.Data.StaffService)
local ZoneTracker = require(script.Parent.Parent.Data.ZoneTracker)

local CharSystem = {}

local CHAR_ZONE_TAG = "CharZone"

local systemFeedbackEvent = Remotes.getEvent("SystemFeedback")

local originalDescriptions: { [Player]: HumanoidDescription } = {}

local function feedback(player: Player, message: string)
	systemFeedbackEvent:FireClient(player, message)
end

local function findPlayerByPartialName(query: string): Player?
	query = query:lower()
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Name:lower() == query then
			return player
		end
	end
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Name:lower():sub(1, #query) == query then
			return player
		end
	end
	return nil
end

local function applyDescription(player: Player, description: HumanoidDescription): boolean
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return false
	end
	local success, err = pcall(function()
		humanoid:ApplyDescription(description)
	end)
	if not success then
		warn(("CharSystem: failed to apply description for %s: %s"):format(player.Name, tostring(err)))
	end
	return success
end

local function onChar(player: Player, targetQuery: string)
	if not ZoneTracker.isPlayerInTag(player, CHAR_ZONE_TAG) then
		feedback(player, "Bu özellik sadece Public Map ve Disco'da kullanılabilir.")
		return
	end

	local target = findPlayerByPartialName(targetQuery)
	if not target or target == player then
		feedback(player, "Oyuncu bulunamadı.")
		return
	end
	if StaffService.isMod(target) then
		feedback(player, "Bu kullanıcı taklit edilemez.")
		return
	end

	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	local targetHumanoid = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid or not targetHumanoid then
		feedback(player, "Şu an bu işlem yapılamıyor.")
		return
	end

	if not originalDescriptions[player] then
		originalDescriptions[player] = humanoid:GetAppliedDescription()
	end

	if applyDescription(player, targetHumanoid:GetAppliedDescription()) then
		feedback(player, ("Artık %s gibi görünüyorsun. (/unchar ile geri dön)"):format(target.Name))
	end
end

local function onUnchar(player: Player)
	local original = originalDescriptions[player]
	if not original then
		return
	end
	if applyDescription(player, original) then
		originalDescriptions[player] = nil
		feedback(player, "Kendi görünümüne döndün.")
	end
end

local function onChatted(player: Player, message: string)
	local charTarget = message:match("^/char%s+(.+)$")
	if charTarget then
		onChar(player, charTarget)
		return
	end
	if message:match("^/unchar%s*$") then
		onUnchar(player)
	end
end

function CharSystem.init()
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(message)
			onChatted(player, message)
		end)
		player.CharacterAdded:Connect(function()
			originalDescriptions[player] = nil
		end)
	end)

	Players.PlayerRemoving:Connect(function(player)
		originalDescriptions[player] = nil
	end)
end

return CharSystem
