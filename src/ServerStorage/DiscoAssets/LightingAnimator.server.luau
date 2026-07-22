--!strict
-- Cycles ceiling/wall disco light colors, offset per fixture. Same clone-and-run pattern as
-- DanceFloorAnimator.server.luau — inert in ServerStorage, self-starts once cloned into a live
-- party instance's light-fixture folder.

local TweenService = game:GetService("TweenService")

local COLORS = {
	Color3.fromRGB(220, 30, 60),
	Color3.fromRGB(40, 90, 230),
	Color3.fromRGB(170, 40, 220),
	Color3.fromRGB(230, 50, 160),
	Color3.fromRGB(40, 210, 120),
}

local function animateFixture(fixture: BasePart, light: Light)
	task.wait(math.random() * 2)
	while fixture.Parent do
		local color = COLORS[math.random(1, #COLORS)]
		TweenService:Create(light, TweenInfo.new(1, Enum.EasingStyle.Sine), { Color = color }):Play()
		TweenService:Create(fixture, TweenInfo.new(1, Enum.EasingStyle.Sine), { Color = color }):Play()
		task.wait(1.5 + math.random())
	end
end

for _, child in ipairs(script.Parent:GetChildren()) do
	if child:IsA("BasePart") then
		local light = child:FindFirstChildOfClass("SpotLight") or child:FindFirstChildOfClass("PointLight")
		if light then
			task.spawn(animateFixture, child, light)
		end
	end
end
