--!strict
-- Ground connectors between zones (so the map reads as one place, not five disconnected pads)
-- plus wayfinding signposts at the plaza — the last "make it feel lived-in" pass.

local DetailPass = {}

local function buildPath(container: Instance, fromPoint: Vector3, toPoint: Vector3, width: number)
	local mid = (fromPoint + toPoint) / 2
	local length = (toPoint - fromPoint).Magnitude
	local direction = (toPoint - fromPoint).Unit
	local angle = math.atan2(direction.X, direction.Z)

	local path = Instance.new("Part")
	path.Name = "Path"
	path.Anchored = true
	path.Size = Vector3.new(width, 0.3, length)
	path.CFrame = CFrame.new(mid + Vector3.new(0, 0.7, 0)) * CFrame.Angles(0, angle, 0)
	path.Color = Color3.fromRGB(104, 98, 90)
	path.Material = Enum.Material.Concrete
	path.Parent = container
end

function DetailPass.buildConnectors(container: Instance, layout: any)
	local zone = Instance.new("Folder")
	zone.Name = "PathConnectors"
	zone.Parent = container

	buildPath(zone, (layout.MainSquare * CFrame.new(0, 0, 34)).Position, (layout.Park * CFrame.new(0, 0, -32)).Position, 9)
	buildPath(zone, (layout.MainSquare * CFrame.new(30, 0, 0)).Position, (layout.RainyStreet * CFrame.new(0, 0, -34)).Position, 9)
	buildPath(zone, (layout.MainSquare * CFrame.new(0, 0, -30)).Position, (layout.PondBridge * CFrame.new(0, 0, 42)).Position, 9)
	buildPath(zone, (layout.MainSquare * CFrame.new(-24, 0, 12)).Position, (layout.PlushShop.Position), 7)
	buildPath(zone, (layout.MainSquare * CFrame.new(24, 0, -12)).Position, (layout.Cafeteria.Position), 7)

	return zone
end

function DetailPass.buildSignposts(container: Instance, PropLibrary: any, origin: CFrame)
	local zone = Instance.new("Folder")
	zone.Name = "Signposts"
	zone.Parent = container

	local signSpots = {
		{ offset = Vector3.new(4, 0, 30), text = "🌳 PARK" },
		{ offset = Vector3.new(28, 0, 4), text = "🌧️ YAĞMUR SOKAĞI" },
		{ offset = Vector3.new(-4, 0, -28), text = "🌊 GÖLET" },
		{ offset = Vector3.new(-26, 0, 8), text = "🧸 PATİLİ DOSTLAR" },
		{ offset = Vector3.new(26, 0, -8), text = "☕ KAFETERYA" },
	}
	for _, spot in ipairs(signSpots) do
		PropLibrary.streetSign(zone, origin * CFrame.new(spot.offset), spot.text)
	end

	return zone
end

return DetailPass
