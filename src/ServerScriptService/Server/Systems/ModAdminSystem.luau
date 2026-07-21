--!strict
-- Mod/Admin toolkit via chat commands: /fly, /speed, /jump, /tp, /mute, /unmute (Mod gamepass
-- or Admin), /kick and /radio (Admin only for kick; radio open to any Mod). None of this affects
-- gameplay balance since there's no PvP/economy to be "pay to win" against — it's moderation and
-- QoL tooling, per the spec's own "not pay-to-win" requirement.

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Modules.Remotes)
local StaffService = require(script.Parent.Parent.Data.StaffService)
local ModRadioSystem = require(script.Parent.ModRadioSystem)

local ModAdminSystem = {}

local MAX_SPEED = 100
local MAX_JUMP_POWER = 200

local systemFeedbackEvent = Remotes.getEvent("SystemFeedback")
local flyStateEvent = Remotes.getEvent("FlyStateChanged")

local flyingState: { [Player]: boolean } = {}

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

local function setMuted(targetUserId: number, muted: boolean)
	for _, channel in ipairs(TextChatService.TextChannels:GetChildren()) do
		for _, source in ipairs(channel:GetChildren()) do
			if source:IsA("TextSource") and source.UserId == targetUserId then
				source.CanSend = not muted
			end
		end
	end
end

local function onFlyCommand(player: Player)
	local newState = not (flyingState[player] or false)
	flyingState[player] = newState

	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = newState
	end

	flyStateEvent:FireClient(player, newState)
	feedback(player, if newState then "Uçuş açıldı." else "Uçuş kapatıldı.")
end

local function onSpeedCommand(player: Player, amountText: string)
	local amount = tonumber(amountText)
	if not amount then
		return
	end
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = math.clamp(amount, 16, MAX_SPEED)
		feedback(player, ("Hız %d olarak ayarlandı."):format(humanoid.WalkSpeed))
	end
end

local function onJumpCommand(player: Player, amountText: string)
	local amount = tonumber(amountText)
	if not amount then
		return
	end
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.JumpPower = math.clamp(amount, 50, MAX_JUMP_POWER)
		feedback(player, ("Zıplama gücü %d olarak ayarlandı."):format(humanoid.JumpPower))
	end
end

local function onTeleportCommand(player: Player, targetQuery: string)
	local target = findPlayerByPartialName(targetQuery)
	if not target then
		feedback(player, "Oyuncu bulunamadı.")
		return
	end
	local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local targetRootPart = target.Character and target.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if rootPart and targetRootPart then
		rootPart.CFrame = targetRootPart.CFrame + Vector3.new(0, 3, 0)
		feedback(player, ("%s yanına ışınlandın."):format(target.Name))
	end
end

local function onKickCommand(player: Player, rest: string)
	local targetQuery, reason = rest:match("^(%S+)%s*(.*)$")
	if not targetQuery then
		return
	end
	local target = findPlayerByPartialName(targetQuery)
	if not target then
		feedback(player, "Oyuncu bulunamadı.")
		return
	end
	target:Kick(if reason ~= "" then ("Atıldın: %s"):format(reason) else "Sunucudan atıldın.")
end

local function onMuteCommand(player: Player, targetQuery: string, muted: boolean)
	local target = findPlayerByPartialName(targetQuery)
	if not target then
		feedback(player, "Oyuncu bulunamadı.")
		return
	end
	setMuted(target.UserId, muted)
	feedback(
		player,
		if muted then ("%s susturuldu."):format(target.Name) else ("%s susturması kaldırıldı."):format(target.Name)
	)
end

local function onChatted(player: Player, message: string)
	if not StaffService.isMod(player) then
		return
	end

	if message:match("^/fly%s*$") then
		onFlyCommand(player)
		return
	end

	local speedArg = message:match("^/speed%s+(%S+)$")
	if speedArg then
		onSpeedCommand(player, speedArg)
		return
	end

	local jumpArg = message:match("^/jump%s+(%S+)$")
	if jumpArg then
		onJumpCommand(player, jumpArg)
		return
	end

	local tpArg = message:match("^/tp%s+(.+)$")
	if tpArg then
		onTeleportCommand(player, tpArg)
		return
	end

	local muteArg = message:match("^/mute%s+(.+)$")
	if muteArg then
		onMuteCommand(player, muteArg, true)
		return
	end

	local unmuteArg = message:match("^/unmute%s+(.+)$")
	if unmuteArg then
		onMuteCommand(player, unmuteArg, false)
		return
	end

	local radioPlayArg = message:match("^/radio%s+play%s+(%S+)$")
	if radioPlayArg then
		if ModRadioSystem.playTrack(radioPlayArg) then
			feedback(player, "Radio çalıyor.")
		else
			feedback(player, "Geçersiz track id.")
		end
		return
	end
	if message:match("^/radio%s+stop%s*$") then
		ModRadioSystem.stop()
		feedback(player, "Radio durduruldu.")
		return
	end

	if StaffService.isAdmin(player) then
		local kickArg = message:match("^/kick%s+(.+)$")
		if kickArg then
			onKickCommand(player, kickArg)
			return
		end
	end
end

function ModAdminSystem.init()
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(message)
			onChatted(player, message)
		end)
		player.CharacterAdded:Connect(function()
			flyingState[player] = nil
		end)
	end)

	Players.PlayerRemoving:Connect(function(player)
		flyingState[player] = nil
	end)
end

return ModAdminSystem
