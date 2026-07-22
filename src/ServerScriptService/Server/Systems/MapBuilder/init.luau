--!strict
-- Builds the entire Public Map procedurally at server start, so nothing needs to be hand-placed
-- in Studio. Re-running (e.g. on every server start) clears and rebuilds the "GeneratedMap"
-- folder, so it's always in sync with this code — no drift between what's in the repo and what's
-- actually in the place file.

local Workspace = game:GetService("Workspace")

local AtmosphereSetup = require(script.AtmosphereSetup)
local PropLibrary = require(script.PropLibrary)
local RainSystem = require(script.RainSystem)
local MapLayout = require(script.MapLayout)

local MainSquare = require(script.Zones.MainSquare)
local Park = require(script.Zones.Park)
local RainyStreet = require(script.Zones.RainyStreet)
local PlushShop = require(script.Zones.PlushShop)
local Cafeteria = require(script.Zones.Cafeteria)
local PondBridge = require(script.Zones.PondBridge)
local HiddenAreas = require(script.Zones.HiddenAreas)
local DetailPass = require(script.Zones.DetailPass)

local MapBuilder = {}

local function buildGroundBase(container: Instance)
	local bounds = MapLayout.GroundBounds
	local sizeX = bounds.maxX - bounds.minX
	local sizeZ = bounds.maxZ - bounds.minZ
	local centerX = (bounds.maxX + bounds.minX) / 2
	local centerZ = (bounds.maxZ + bounds.minZ) / 2

	local base = Instance.new("Part")
	base.Name = "GroundBase"
	base.Anchored = true
	base.Size = Vector3.new(sizeX, 2, sizeZ)
	base.CFrame = CFrame.new(centerX, -1, centerZ)
	base.Color = Color3.fromRGB(40, 58, 40)
	base.Material = Enum.Material.Grass
	base.Parent = container
end

function MapBuilder.init()
	local existing = Workspace:FindFirstChild("GeneratedMap")
	if existing then
		existing:Destroy()
	end

	local mapFolder = Instance.new("Folder")
	mapFolder.Name = "GeneratedMap"
	mapFolder.Parent = Workspace

	AtmosphereSetup.apply()
	buildGroundBase(mapFolder)

	MainSquare.build(mapFolder, PropLibrary, MapLayout.MainSquare)
	Park.build(mapFolder, PropLibrary, MapLayout.Park)
	RainyStreet.build(mapFolder, PropLibrary, RainSystem, MapLayout.RainyStreet)
	PlushShop.build(mapFolder, PropLibrary, MapLayout.PlushShop)
	Cafeteria.build(mapFolder, PropLibrary, MapLayout.Cafeteria)
	PondBridge.build(mapFolder, PropLibrary, MapLayout.PondBridge)

	HiddenAreas.buildShopAlley(mapFolder, PropLibrary, MapLayout.PlushShop)
	HiddenAreas.buildSecretHideout(mapFolder, PropLibrary, MapLayout.PondBridge)

	DetailPass.buildConnectors(mapFolder, MapLayout)
	DetailPass.buildSignposts(mapFolder, PropLibrary, MapLayout.MainSquare)
end

return MapBuilder
