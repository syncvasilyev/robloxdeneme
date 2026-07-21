--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Theme = require(ReplicatedStorage.Modules.Theme)

local NotificationsAppUI = {}

local function createCorner(parent: Instance, radius: UDim)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius
	corner.Parent = parent
end

function NotificationsAppUI.build(parent: Frame, NotificationsClient: any)
	local list = Instance.new("ScrollingFrame")
	list.Size = UDim2.fromScale(1, 1)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 4
	list.CanvasSize = UDim2.new(0, 0, 0, 0)
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.Parent = parent

	local function render()
		list:ClearAllChildren()
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 6)
		layout.Parent = list

		local notifications = NotificationsClient.getAll()
		if #notifications == 0 then
			local emptyLabel = Instance.new("TextLabel")
			emptyLabel.Size = UDim2.new(1, 0, 0, 40)
			emptyLabel.BackgroundTransparency = 1
			emptyLabel.Font = Theme.Font
			emptyLabel.TextSize = 13
			emptyLabel.TextColor3 = Theme.Colors.TextSecondary
			emptyLabel.Text = "Henüz bildirim yok."
			emptyLabel.Parent = list
			return
		end

		for _, notification in ipairs(notifications) do
			local row = Instance.new("TextLabel")
			row.Size = UDim2.new(1, 0, 0, 40)
			row.BackgroundColor3 = Theme.Colors.SurfaceGlass
			row.Font = Theme.Font
			row.TextSize = 12
			row.TextColor3 = Theme.Colors.TextPrimary
			row.TextWrapped = true
			row.TextXAlignment = Enum.TextXAlignment.Left
			row.Text = "  " .. notification.text
			row.Parent = list
			createCorner(row, UDim.new(0, 8))
		end
	end

	NotificationsClient.onChanged(render)
	render()
end

return NotificationsAppUI
