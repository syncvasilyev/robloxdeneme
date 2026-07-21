--!strict
-- First-login onboarding flow. Players see the intro only on their first ever join; from their
-- 2nd login onward they spawn straight into the Public Map. Players can also re-open onboarding
-- voluntarily from the + menu via ReplayOnboarding.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Remotes = require(ReplicatedStorage.Modules.Remotes)
local PlayerDataStore = require(script.Parent.Parent.Data.PlayerDataStore)

local OnboardingSystem = {}

local showOnboardingEvent = Remotes.getEvent("ShowOnboarding")
local onboardingCompletedEvent = Remotes.getEvent("OnboardingCompleted")
local replayOnboardingEvent = Remotes.getEvent("ReplayOnboarding")

local function findPublicMapSpawn(): BasePart?
	local spawn = Workspace:FindFirstChild("PublicMapSpawn", true)
	if spawn and spawn:IsA("BasePart") then
		return spawn
	end
	return nil
end

local function moveToPublicMap(player: Player)
	local spawn = findPublicMapSpawn()
	if not spawn then
		-- Map not built yet in Studio; leave the player at the default spawn.
		return
	end

	local character = player.Character
	if not character then
		return
	end
	local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if rootPart then
		rootPart.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
	end
end

local function onPlayerAdded(player: Player)
	local data = PlayerDataStore.waitForProfile(player)
	if not data then
		return
	end

	if data.onboardingCompleted then
		if player.Character then
			moveToPublicMap(player)
		end
		local connection: RBXScriptConnection
		connection = player.CharacterAdded:Connect(function()
			moveToPublicMap(player)
			connection:Disconnect()
		end)
	else
		showOnboardingEvent:FireClient(player)
	end
end

local function onOnboardingCompleted(player: Player)
	local data = PlayerDataStore.get(player)
	if not data then
		return
	end
	data.onboardingCompleted = true
	PlayerDataStore.save(player)
	moveToPublicMap(player)
end

local function onReplayOnboarding(player: Player)
	showOnboardingEvent:FireClient(player)
end

function OnboardingSystem.init()
	Players.PlayerAdded:Connect(onPlayerAdded)
	onboardingCompletedEvent.OnServerEvent:Connect(onOnboardingCompleted)
	replayOnboardingEvent.OnServerEvent:Connect(onReplayOnboarding)
end

return OnboardingSystem
