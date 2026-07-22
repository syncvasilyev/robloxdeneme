--!strict
-- Builds the reusable Disco/Party template once at server start and stores it in
-- ServerStorage (never in Workspace directly — PartySystem clones a fresh copy per active
-- party so parties stay physically isolated from each other; see PartySystem.luau).

local ServerStorage = game:GetService("ServerStorage")

local ClubShell = require(script.ClubShell)
local DanceFloor = require(script.DanceFloor)
local DjBooth = require(script.DjBooth)
local VipFloor = require(script.VipFloor)
local LightingRig = require(script.LightingRig)

local DiscoBuilder = {}

local template: Model? = nil

function DiscoBuilder.init()
	local existing = ServerStorage:FindFirstChild("DiscoTemplate")
	if existing then
		existing:Destroy()
	end

	local model = Instance.new("Model")
	model.Name = "DiscoTemplate"

	local _, roomSize = ClubShell.build(model)
	DanceFloor.build(model)
	DjBooth.build(model, CFrame.new(0, 0, -roomSize.Z / 2 + 5))
	VipFloor.build(model, roomSize)
	LightingRig.build(model, roomSize)

	local spawnMarker = Instance.new("Part")
	spawnMarker.Name = "InstanceSpawn"
	spawnMarker.Anchored = true
	spawnMarker.CanCollide = false
	spawnMarker.Transparency = 1
	spawnMarker.Size = Vector3.new(4, 1, 4)
	spawnMarker.CFrame = CFrame.new(0, 1, roomSize.Z / 2 - 6) * CFrame.Angles(0, math.rad(180), 0)
	spawnMarker.Parent = model

	model.Parent = ServerStorage
	template = model
end

--- Every script in the returned clone that was Disabled in the template (see
--- ServerStorage/DiscoAssets) needs enabling once it's actually parented into Workspace, since
--- Scripts don't auto-run while sitting inert in ServerStorage.
function DiscoBuilder.cloneInstance(): Model
	assert(template, "DiscoBuilder.init() must run before cloning instances")
	local clone = template:Clone()
	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("Script") then
			descendant.Disabled = false
		end
	end
	return clone
end

return DiscoBuilder
