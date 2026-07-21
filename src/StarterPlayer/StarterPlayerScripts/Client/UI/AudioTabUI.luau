--!strict
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage.Modules.Theme)
local Remotes = require(ReplicatedStorage.Modules.Remotes)

local AudioTabUI = {}

local updateSettingsFunction = Remotes.getFunction("UpdateSettings")

local function createCorner(parent: Instance, radius: UDim)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius
	corner.Parent = parent
end

function AudioTabUI.build(parent: Frame, AmbientMusicClient: any)
	local label = Instance.new("TextLabel")
	label.Position = UDim2.new(0, 16, 0, 16)
	label.Size = UDim2.new(1, -32, 0, 20)
	label.BackgroundTransparency = 1
	label.Font = Theme.Font
	label.TextSize = 13
	label.TextColor3 = Theme.Colors.TextSecondary
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = "Oyun Müziği"
	label.Parent = parent

	local track = Instance.new("Frame")
	track.Position = UDim2.new(0, 16, 0, 44)
	track.Size = UDim2.new(1, -32, 0, 6)
	track.BackgroundColor3 = Theme.Colors.Divider
	track.BorderSizePixel = 0
	track.Parent = parent
	createCorner(track, UDim.new(1, 0))

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0.5, 0, 1, 0)
	fill.BackgroundColor3 = Theme.Colors.AccentRed
	fill.BorderSizePixel = 0
	fill.Parent = track
	createCorner(fill, UDim.new(1, 0))

	local handle = Instance.new("TextButton")
	handle.AnchorPoint = Vector2.new(0.5, 0.5)
	handle.Position = UDim2.new(1, 0, 0.5, 0)
	handle.Size = UDim2.fromOffset(18, 18)
	handle.BackgroundColor3 = Theme.Colors.TextPrimary
	handle.AutoButtonColor = false
	handle.Text = ""
	handle.Parent = fill
	createCorner(handle, UDim.new(1, 0))

	local dragging = false

	local function setVolumeFromScale(scale: number)
		scale = math.clamp(scale, 0, 1)
		fill.Size = UDim2.new(scale, 0, 1, 0)
		AmbientMusicClient.setVolume(scale)
		updateSettingsFunction:InvokeServer({ musicVolume = scale })
	end

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local relativeX = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
			setVolumeFromScale(relativeX)
		end
	end)

	local muteButton = Instance.new("TextButton")
	muteButton.Position = UDim2.new(0, 16, 0, 68)
	muteButton.Size = UDim2.new(1, -32, 0, 36)
	muteButton.BackgroundColor3 = Theme.Colors.Surface
	muteButton.Font = Theme.Font
	muteButton.TextSize = 13
	muteButton.TextColor3 = Theme.Colors.TextSecondary
	muteButton.Text = "Sustur"
	muteButton.Parent = parent
	createCorner(muteButton, UDim.new(0, 8))
	muteButton.MouseButton1Click:Connect(function()
		setVolumeFromScale(0)
	end)
end

return AudioTabUI
