--!strict
-- Renders the fly movement locally once the server confirms (via /fly) that this player is
-- allowed to fly. The server is the source of truth for whether flying is currently permitted;
-- this only drives the local camera-relative movement while it's on.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Modules.Remotes)

local FlyClient = {}

local flyStateEvent = Remotes.getEvent("FlyStateChanged")

local FLY_SPEED = 50
local flying = false

local function onRenderStep(dt: number)
	if not flying then
		return
	end

	local player = Players.LocalPlayer
	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local camera = Workspace.CurrentCamera
	if not rootPart or not camera then
		return
	end

	local moveVector = Vector3.new(0, 0, 0)
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		moveVector += camera.CFrame.LookVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		moveVector -= camera.CFrame.LookVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		moveVector -= camera.CFrame.RightVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		moveVector += camera.CFrame.RightVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		moveVector += Vector3.new(0, 1, 0)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
		moveVector -= Vector3.new(0, 1, 0)
	end

	if moveVector.Magnitude > 0 then
		rootPart.CFrame = rootPart.CFrame + moveVector.Unit * FLY_SPEED * dt
	end
end

function FlyClient.init()
	flyStateEvent.OnClientEvent:Connect(function(enabled: boolean)
		flying = enabled
	end)
	RunService.RenderStepped:Connect(onRenderStep)
end

return FlyClient
