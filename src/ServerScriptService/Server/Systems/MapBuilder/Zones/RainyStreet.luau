--!strict
-- A rain-slicked side street, east of the main square. Rain only covers part of the strip — the
-- far end stays dry under a sheltered awning, per "yağmur bütün haritada olmak zorunda değil".

local RainyStreet = {}

function RainyStreet.build(container: Instance, PropLibrary: any, RainSystem: any, origin: CFrame)
	local zone = Instance.new("Folder")
	zone.Name = "RainyStreet"
	zone.Parent = container

	local road = Instance.new("Part")
	road.Name = "RoadGround"
	road.Anchored = true
	road.Size = Vector3.new(16, 1, 74)
	road.CFrame = origin * CFrame.new(0, 0.5, 0)
	road.Color = Color3.fromRGB(38, 38, 40)
	road.Material = Enum.Material.Asphalt
	road.Parent = zone
	RainSystem.wetten(road)

	for _, xOffset in ipairs({ -9, 9 }) do
		local sidewalk = Instance.new("Part")
		sidewalk.Name = "Sidewalk"
		sidewalk.Anchored = true
		sidewalk.Size = Vector3.new(4, 1.2, 74)
		sidewalk.CFrame = origin * CFrame.new(xOffset, 0.6, 0)
		sidewalk.Color = Color3.fromRGB(80, 78, 76)
		sidewalk.Material = Enum.Material.Concrete
		sidewalk.Parent = zone
	end

	-- A row of connected shopfront facades along the west side — backdrop, not enterable, but
	-- their glowing windows give the wet street something to reflect and look alive.
	for i, z in ipairs({ -28, -10, 8 }) do
		local facade = Instance.new("Part")
		facade.Name = "Facade"
		facade.Anchored = true
		facade.Size = Vector3.new(1, 14, 16)
		facade.CFrame = origin * CFrame.new(-11, 7, z)
		facade.Color = if i % 2 == 0 then Color3.fromRGB(52, 44, 40) else Color3.fromRGB(44, 46, 52)
		facade.Material = Enum.Material.Brick
		facade.Parent = zone

		for _, wy in ipairs({ 4, 9 }) do
			PropLibrary.windowLight(zone, origin * CFrame.new(-10.4, wy, z - 3), Vector3.new(0.2, 2.2, 2.6))
			PropLibrary.windowLight(zone, origin * CFrame.new(-10.4, wy, z + 3), Vector3.new(0.2, 2.2, 2.6))
		end
	end

	-- Rain only over the northern two-thirds of the street.
	RainSystem.createRainRegion(zone, origin * CFrame.new(0, 0, -10), Vector2.new(16, 50))

	for _, z in ipairs({ -30, -14, 2 }) do
		PropLibrary.streetLamp(zone, origin * CFrame.new(9.5, 0, z), 1)
	end
	PropLibrary.streetSign(zone, origin * CFrame.new(9.5, 0, -34), "YAĞMUR SOKAĞI")

	-- Dry, sheltered nook at the south end: an awning roof over a bench, out of the rain.
	local shelterRoof = Instance.new("Part")
	shelterRoof.Name = "ShelterAwning"
	shelterRoof.Anchored = true
	shelterRoof.CanCollide = false
	shelterRoof.Size = Vector3.new(9, 0.4, 7)
	shelterRoof.CFrame = origin * CFrame.new(-8, 8, 25) * CFrame.Angles(0, 0, math.rad(-6))
	shelterRoof.Color = Color3.fromRGB(90, 30, 34)
	shelterRoof.Material = Enum.Material.Fabric
	shelterRoof.Parent = zone
	for _, offset in ipairs({ Vector3.new(-3.5, 0, -2.5), Vector3.new(3.5, 0, -2.5), Vector3.new(-3.5, 0, 2.5), Vector3.new(3.5, 0, 2.5) }) do
		local post = Instance.new("Part")
		post.Name = "AwningPost"
		post.Anchored = true
		post.Size = Vector3.new(0.3, 8, 0.3)
		post.CFrame = origin * CFrame.new(-8, 4, 25) * CFrame.new(offset)
		post.Color = Color3.fromRGB(30, 30, 32)
		post.Material = Enum.Material.Metal
		post.Parent = zone
	end
	PropLibrary.bench(zone, origin * CFrame.new(-8, 0, 25) * CFrame.Angles(0, math.rad(90), 0), 2)
	PropLibrary.lanternPost(zone, origin * CFrame.new(-4, 0, 22))

	return zone
end

return RainyStreet
