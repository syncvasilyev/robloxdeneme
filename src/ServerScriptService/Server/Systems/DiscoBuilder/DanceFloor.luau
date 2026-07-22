--!strict
-- The center-stage square-tile disco floor. Each tile is an independent Part; the actual color
-- cycling comes from DanceFloorAnimator.server.luau (ServerStorage.DiscoAssets), cloned in here
-- so it starts running the moment this whole template gets cloned into a live party instance.

local ServerStorage = game:GetService("ServerStorage")

local DanceFloor = {}

local GRID_SIZE = 10
local TILE_SIZE = 3.2
local TILE_GAP = 0.15

function DanceFloor.build(container: Instance)
	local zone = Instance.new("Folder")
	zone.Name = "DanceFloor"
	zone.Parent = container

	local tilesFolder = Instance.new("Folder")
	tilesFolder.Name = "Tiles"
	tilesFolder.Parent = zone

	local step = TILE_SIZE + TILE_GAP
	local totalSpan = GRID_SIZE * step
	local startOffset = -totalSpan / 2 + step / 2

	for row = 0, GRID_SIZE - 1 do
		for col = 0, GRID_SIZE - 1 do
			local tile = Instance.new("Part")
			tile.Name = ("Tile_%d_%d"):format(row, col)
			tile.Anchored = true
			tile.Size = Vector3.new(TILE_SIZE, 0.3, TILE_SIZE)
			tile.CFrame = CFrame.new(startOffset + col * step, 0.15, startOffset + row * step)
			tile.Color = Color3.fromRGB(60, 20, 40)
			tile.Material = Enum.Material.Neon
			tile.Parent = tilesFolder
		end
	end

	-- Raised platform border around the tile grid so it reads as a distinct dance stage.
	local border = Instance.new("Part")
	border.Name = "FloorBorder"
	border.Anchored = true
	border.Size = Vector3.new(totalSpan + 2, 0.2, totalSpan + 2)
	border.CFrame = CFrame.new(0, -0.2, 0)
	border.Color = Color3.fromRGB(20, 18, 20)
	border.Material = Enum.Material.Metal
	border.Parent = zone

	local animatorTemplate = ServerStorage.DiscoAssets:FindFirstChild("DanceFloorAnimator")
	if animatorTemplate then
		local animator = animatorTemplate:Clone()
		animator.Parent = tilesFolder
	end

	return zone
end

return DanceFloor
