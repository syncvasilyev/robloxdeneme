--!strict
-- The club's black-box shell: floor, walls, ceiling, and a lit entrance archway. Everything else
-- (dance floor, DJ booth, VIP floor, lighting rig) is built inside this room by DiscoBuilder.

local ClubShell = {}

local ROOM_SIZE = Vector3.new(74, 22, 90)

function ClubShell.build(container: Instance)
	local zone = Instance.new("Folder")
	zone.Name = "ClubShell"
	zone.Parent = container

	local floor = Instance.new("Part")
	floor.Name = "ClubFloor"
	floor.Anchored = true
	floor.Size = Vector3.new(ROOM_SIZE.X, 1, ROOM_SIZE.Z)
	floor.CFrame = CFrame.new(0, -0.5, 0)
	floor.Color = Color3.fromRGB(14, 12, 14)
	floor.Material = Enum.Material.Marble
	floor.Reflectance = 0.08
	floor.Parent = zone

	local ceiling = Instance.new("Part")
	ceiling.Name = "ClubCeiling"
	ceiling.Anchored = true
	ceiling.Size = Vector3.new(ROOM_SIZE.X, 1, ROOM_SIZE.Z)
	ceiling.CFrame = CFrame.new(0, ROOM_SIZE.Y, 0)
	ceiling.Color = Color3.fromRGB(8, 8, 10)
	ceiling.Material = Enum.Material.Metal
	ceiling.Parent = zone

	local wallThickness = 1
	local wallSpecs = {
		{ size = Vector3.new(ROOM_SIZE.X, ROOM_SIZE.Y, wallThickness), cframe = CFrame.new(0, ROOM_SIZE.Y / 2, -ROOM_SIZE.Z / 2) },
		{ size = Vector3.new(wallThickness, ROOM_SIZE.Y, ROOM_SIZE.Z), cframe = CFrame.new(-ROOM_SIZE.X / 2, ROOM_SIZE.Y / 2, 0) },
		{ size = Vector3.new(wallThickness, ROOM_SIZE.Y, ROOM_SIZE.Z), cframe = CFrame.new(ROOM_SIZE.X / 2, ROOM_SIZE.Y / 2, 0) },
	}
	for i, spec in ipairs(wallSpecs) do
		local wall = Instance.new("Part")
		wall.Name = "Wall" .. i
		wall.Anchored = true
		wall.Size = spec.size
		wall.CFrame = spec.cframe
		wall.Color = Color3.fromRGB(16, 15, 17)
		wall.Material = Enum.Material.Metal
		wall.Parent = zone
	end

	-- Front wall has a gap for the entrance archway.
	local doorWidth = 10
	local frontHalf = (ROOM_SIZE.X - doorWidth) / 2
	for _, sign in ipairs({ -1, 1 }) do
		local segment = Instance.new("Part")
		segment.Name = "FrontWallSegment"
		segment.Anchored = true
		segment.Size = Vector3.new(frontHalf, ROOM_SIZE.Y, wallThickness)
		segment.CFrame = CFrame.new(sign * (doorWidth / 2 + frontHalf / 2), ROOM_SIZE.Y / 2, ROOM_SIZE.Z / 2)
		segment.Color = Color3.fromRGB(16, 15, 17)
		segment.Material = Enum.Material.Metal
		segment.Parent = zone
	end

	-- Entrance archway with a neon strip outline.
	local archTop = Instance.new("Part")
	archTop.Name = "ArchTop"
	archTop.Anchored = true
	archTop.Size = Vector3.new(doorWidth + 2, 1, wallThickness)
	archTop.CFrame = CFrame.new(0, 9, ROOM_SIZE.Z / 2)
	archTop.Color = Color3.fromRGB(16, 15, 17)
	archTop.Material = Enum.Material.Metal
	archTop.Parent = zone
	local archNeon = Instance.new("Part")
	archNeon.Name = "ArchNeon"
	archNeon.Anchored = true
	archNeon.CanCollide = false
	archNeon.Size = Vector3.new(doorWidth + 2.4, 0.3, 0.2)
	archNeon.CFrame = CFrame.new(0, 8.3, ROOM_SIZE.Z / 2 - 0.3)
	archNeon.Color = Color3.fromRGB(180, 40, 220)
	archNeon.Material = Enum.Material.Neon
	archNeon.Parent = zone

	-- Slim accent columns along the side walls — breaks up the flat black surfaces.
	for _, xSign in ipairs({ -1, 1 }) do
		for zOffset = -30, 30, 20 do
			local column = Instance.new("Part")
			column.Name = "AccentColumn"
			column.Anchored = true
			column.CanCollide = false
			column.Size = Vector3.new(0.3, ROOM_SIZE.Y - 2, 1.6)
			column.CFrame = CFrame.new(xSign * (ROOM_SIZE.X / 2 - 0.6), ROOM_SIZE.Y / 2, zOffset)
			column.Color = Color3.fromRGB(140, 30, 60)
			column.Material = Enum.Material.Neon
			column.Transparency = 0.15
			column.Parent = zone
		end
	end

	return zone, ROOM_SIZE
end

return ClubShell
