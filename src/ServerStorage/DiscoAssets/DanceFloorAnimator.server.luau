--!strict
-- Cycles each dance-floor tile through soft color transitions, offset per tile for an organic
-- shimmer rather than a uniform strobe. Lives in ServerStorage as an inert template piece —
-- DiscoBuilder clones it into each live party instance's tile folder, where it starts running
-- automatically (it drives itself purely from script.Parent's children, no external wiring).

local TweenService = game:GetService("TweenService")

local COLORS = {
	Color3.fromRGB(220, 30, 60),
	Color3.fromRGB(40, 90, 230),
	Color3.fromRGB(170, 40, 220),
	Color3.fromRGB(230, 50, 160),
	Color3.fromRGB(40, 210, 120),
	Color3.fromRGB(240, 190, 40),
}

local function animateTile(tile: BasePart)
	task.wait(math.random() * 2)
	while tile.Parent do
		local color = COLORS[math.random(1, #COLORS)]
		TweenService:Create(tile, TweenInfo.new(1.2, Enum.EasingStyle.Sine), { Color = color }):Play()
		task.wait(1 + math.random() * 1.5)
	end
end

for _, child in ipairs(script.Parent:GetChildren()) do
	if child:IsA("BasePart") then
		task.spawn(animateTile, child)
	end
end
